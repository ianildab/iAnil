public class ECICAccountDao 
{
    private final static String[] ACCOUNT_FIELDS = ECICUtils.getSObjectEditableFields(Account.sObjectType);
    @testVisible private final static String[] BUSINESS_ACCOUNT_FIELDS_TO_CLONE;
    @testVisible private final static String[] PERSON_ACCOUNT_FIELDS_TO_CLONE;
    
    // Read-only and unique fields of Person/Business Accounts ARE excluded from cloning
    static 
    {
        BUSINESS_ACCOUNT_FIELDS_TO_CLONE = new String[0];
        PERSON_ACCOUNT_FIELDS_TO_CLONE = new String[0];
        
        Set<String> excludeBusinessAccountFields = new Set<String>
        {
            'Account_Ext_Id__c', 'Authorisation_Data_Usage__pc', 
            'sf4twitter__followed__pc',
            'STMActive__pc', 'STMOptRecieveInfo__pc', 'STMInvitations_Optin_to_recieve__pc', 'STM_Opt_out__pc'
        };

        Set<String> excludePersonAccountFields = new Set<String>
        {
            'Account_Ext_Id__c', 'Contact_Ext_Id__pc', 'Name', 'FirstName', 'LastName', 'PersonContactId',
            'sf4twitter__Twitter_User_Id__pc', 'sf4twitter__Fcbk_User_Id__pc'
        };

        for (String field : ACCOUNT_FIELDS) 
        {
            if (! excludeBusinessAccountFields.contains(field)) {  BUSINESS_ACCOUNT_FIELDS_TO_CLONE.add(field); }
            if (! excludePersonAccountFields.contains(field))   {  PERSON_ACCOUNT_FIELDS_TO_CLONE.add(field);   }
        }
    }
    
    public static Map<ID, Account> findBusinessAccountsByIdsToClone(Set<ID> ids) 
    {
        List<String> conds = new List<String>();
        conds.add('IsPersonAccount = false');
        return findByIds(ids, BUSINESS_ACCOUNT_FIELDS_TO_CLONE, conds);
    }
    
    public static Map<ID, Account> findPersonAccountsByIdsToClone(Set<ID> ids) 
    {
        List<String> conds = new List<String>();
        conds.add('IsPersonAccount = true');
        return findByIds(ids, PERSON_ACCOUNT_FIELDS_TO_CLONE, conds);
    }
    
    public static Map<ID, Account> findCombinedAccountsByIdsToClone(Set<ID> ids) 
    {
        List<String> conds = new List<String>();        
        return findByIds(ids, PERSON_ACCOUNT_FIELDS_TO_CLONE, conds);
    }
    
    @testVisible private static Map<Id, Account> findByIds(Set<Id> idSet, String[] fieldsToQueryArray, String[] whereConditionsArray) 
    {
    	if (idSet.isEmpty()) { return new Map<Id, Account>(); }            // If idSet is empty, there can't be any matching results, so no query is attempted.
    	
        String query = 'SELECT id, PersonContactId, IsPersonAccount ';
        if ((fieldsToQueryArray != null) && (! fieldsToQueryArray.isEmpty())) 
        {
        	query += ', ' + String.join(fieldsToQueryArray, ', '); 
        }
        
        query += ' FROM Account WHERE id IN :idSet';
        if ((whereConditionsArray != null) && (! whereConditionsArray.isEmpty())) 
        { 
        	query += ' AND ' + String.join(whereConditionsArray, ' AND '); 
        }

        return new Map<Id, Account>((List<Account>) Database.query(query));
    }
        
    public static Map<ID, Account> findByIds(Set<ID> ids)  { return findByIds(ids, ACCOUNT_FIELDS, null); }
    
    public static Account clone (Account originalAccount)
    {
        List<String> fieldsToCloneList = (originalAccount.isPersonAccount) ? PERSON_ACCOUNT_FIELDS_TO_CLONE : BUSINESS_ACCOUNT_FIELDS_TO_CLONE;
        
        Account cloneAccount = new Account();
        for (String fieldToClone : fieldsToCloneList)
        {
            if (originalAccount.get(fieldToClone) != null) { cloneAccount.put(fieldToClone, originalAccount.get(fieldToClone)); }
        }
        return cloneAccount;
    }
    
}