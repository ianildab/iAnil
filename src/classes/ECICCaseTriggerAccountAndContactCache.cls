public class ECICCaseTriggerAccountAndContactCache 
{
    /**
     * CONSTANTS
     * These have fixed value for Case SObject, 
     * but may differ if/when we need to apply Account and Contact Setting against other SObjects
     * (e.g. Conversation__c)
     **/
    private static final String PLACE_FIELD_NAME                = 'Place_of_Purchase__c';
    private static final String COUNTRY_CODE_FIELD_NAME         = 'Country_code__c';
    private static final String DEFAULT_ACCOUNT_OWNER_PROFILE   = ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_SUPERVISOR ; //#CICTemplateTest
    
    // -------------------------------------------------------------------------------------------------------------------

    // Variables, setters, and getters.    
    
    private static Map<String, Case> emailAndWebCaseIdentStringMap = new Map<String, Case>();
    public  static Map<String, Case> getEmailAndWebCaseIdentStringMap() { return emailAndWebCaseIdentStringMap; }
    
    private static Map<String, Region__c> regionsByExtId = findRegionsByExtId();
    public  static Map<String, Region__c> getRegionsByExtId() { return regionsByExtId; }
        
    private static Set<String> countryCodeSet = generateCountryCodeSet();
    public  static Set<String> getCountryCodeSet() { return countryCodeSet; }
    
    // -------------------------------------------------------------------------------------------------------------------
    
    // Contact variables, setters, and getters.

   @TestVisible private static List<Contact> emailAndWebContactList  = ECICCaseTriggerContactCache.getEmailWebContactCache();
        
    private static List<Contact> updateCICContactList = new List<Contact>();
    public  static List<Contact> getUpdateCICContactList() { return updateCICContactList; }
    
    @TestVisible private static Map<String, Contact>   nonCICContactStringMap = new Map<String, Contact>();
    @TestVisible private static Map<String, Contact[]> cicContactStringMap    = new Map<String, Contact[]>();

    private static Map<String, Contact> newCICContactStringMap                = new Map<String, Contact>();
    public  static Map<String, Contact> getNewCICContactStringMap() { return newCICContactStringMap; }

    private static Map<ID, Contact> nonCICContactsByIdsToClone = new Map<ID, Contact>();
    public  static Map<ID, Contact> getNonCICContactsByIdsToClone() { return nonCICContactsByIdsToClone; }

    private static Map<String, ID> caseToNonCICContactStringIdentifierMap  = new Map<String, Id>();
    public  static Map<String, ID> getCaseToNonCICContactStringIdentifierMap() { return caseToNonCICContactStringIdentifierMap; }
    
    @TestVisible private static Map<String, Case> casesWithExistingContacts    = new Map<String, Case>();
    @TestVisible private static Map<String, Case> casesWithoutExistingContacts = new Map<String, Case>();

    // -------------------------------------------------------------------------------------------------------------------

    // Account variables, setters, and getters.
    
    private static Map<String, ID> caseToNonCICAccountStringIdentifierMap  = new Map<String, Id>();
    public  static Map<String, ID> getCaseToNonCICAccountStringIdentifierMap() { return caseToNonCICAccountStringIdentifierMap; }
        
    private static Map<ID, Account> businessAccountsByIdsToClone = new Map<ID, Account>();
    public  static Map<ID, Account> getBusinessAccountsByIdsToClone() { return businessAccountsByIdsToClone; }
        
    private static Map<ID, Account> personAccountsByIdsToClone = new Map<ID, Account>();
    public  static Map<ID, Account> getPersonAccountsByIdsToClone() { return personAccountsByIdsToClone; }
    
    private static Map<ID, Account>  combinedAccountsTypesByIdsToClone = new Map<ID, Account>();
    public  static Map<ID, Account> getCombinedAccountsTypesByIdsToClone() { return combinedAccountsTypesByIdsToClone; }

        private static Map<ID, Account>  combinedContactTypesByIdsToClone = new Map<ID, Account>();
    public  static Map<ID, Account> getCombinedContactTypesByIdsToClone() { return combinedContactTypesByIdsToClone; }

    
    private static Map<String, Account>     newCICAccountStringMap = new Map<String, Account>();
    public  static Map<String, Account> getNewCICAccountStringMap() { return newCICAccountStringMap; }
    
    private static Map<ID, Account> cicPersonAccountIdMap = new Map<ID, Account>();
    public  static Map<ID, Account> getCICPersonAccountIdMap() {return cicPersonAccountIdMap; }
    
    private static Map<String, User> defaultAccountOwnerUsersByCountryStringMap = new Map<String, User>();
    public  static Map<String, User> getDefaultAccountOwnerUsersByCountryStringMap() { return defaultAccountOwnerUsersByCountryStringMap; }

    // Core methods -------------------------------------------------------------------------------------------------------------------
    
    public static void populate(List<Case> currentCaseList)  
    {
        // Filter Case List by same criteria as used by ECICCaseAccountAndContactSetterStrategy, so we use same filter.  ;-)
        Map<String, Case> filteredCaseIdentStringMap = ECICCaseAccountAndContactSetterStrategy.buildEmailAndWebCaseIdentStringMap (currentCaseList);
        emailAndWebCaseIdentStringMap.putAll(filteredCaseIdentStringMap); 

        // If any Cases are qualified, populate the Caches.
        if (! emailAndWebCaseIdentStringMap.isEmpty()) 
        {
            countryCodeSet = generateCountryCodeSet();
            defaultAccountOwnerUsersByCountryStringMap = ECICUserDao.findAllFirstActiveByProfileNameAndCountryCode(DEFAULT_ACCOUNT_OWNER_PROFILE, countryCodeSet);
            caseCacheProcessing();
        }
    }
    
    private static void caseCacheProcessing() 
    {
        try
            {
                filterCasesByContacts();                                                                    // Divide Cases between those with and without Contants
                if(!casesWithoutExistingContacts.isEmpty()) { assignNotExistingAccountsAndContacts(); }     // Assign Accounts and Contacts...
                if(!casesWithExistingContacts.isEmpty())    { assignExistingAccountsAndContacts();    }     // ... as per filter above.
                finalProcessing();  
            }
            catch(Exception ex)
            {
                        System.debug(LoggingLevel.WARN, '!!!!!!! Exception: ' + ex.getMessage() + '\nException stack trace:\n' + ex.getStackTraceString());
                return; 
            }          
    }
    
    private static void filterCasesByContacts() 
    {
        for (String identString : emailAndWebCaseIdentStringMap.keySet()) 
        {
            Case currentCase = emailAndWebCaseIdentStringMap.get(identString);
            
            /** 
             *   Match current Case Supplied* Data within Email and Web Contacts already collected into Cache.
             *   If match can be found collect it,
             *   ... but keep it divided by workstream (CIC, CRM, STM).
             **/
            Map<ECICCaseAccountWorkstream.WorkstreamEnum, Contact[]> WorkstreamContactMap = ECICCaseAccountWorkstream.findWorkstreamContacts(
                           currentCase.SuppliedEmail,
                           currentCase.SuppliedPhone,
                           emailAndWebContactList);                                                 // From ECICCaseTriggerContactCache
            
            if (WorkstreamContactMap.isEmpty())                                                     // If there are NO matches, 
            {
                casesWithoutExistingContacts.put(identString, currentCase);                         // ... filter Case into appropriate Map
            } 
            else                                                                                    // If there IS a match
            {
                casesWithExistingContacts.put(identString, currentCase);                            //  1. Filter Case into appropriate Map
                getCICContacts(WorkstreamContactMap, identString);                                  //  2. Put CIC Contacts into an appropriate Case-Identified-String Map    
                getNonCICContacts(WorkstreamContactMap, identString);                               //  3. Put Non-CIC Contacts into an appropriate Case-Identified-String Map
            }
         }
    }
    
    //Processing Cases with existing CIC or nonCIC contacts in the system
    private static void assignExistingAccountsAndContacts() 
    {
        if (! cicContactStringMap.isEmpty())                                                        // If there are CIC Contacts, 
        {
            ECICCaseTriggerAccountAndContactCacheHlp.assignContactsToSObjects(cicContactStringMap); // ...  assign them to the Cases.
        }
        
        if (! nonCICContactStringMap.isEmpty()) 
        {                                                                                           // If there are any Non-CIC Contacts
            linkCaseStringIdentifier();                                                             // Link Cases with Accounts and Contacts (if PersonAccounts) by Case String Identifier
            
            /**
             *    Query SFDC for Account and Contact record details, 
             *    ... so these can be cloned.
             *
             *    TODO: Merge these queries (if possible with other Account and Contact Queries) and filter afterwards
             **/
             
             CombinedAccountsTypesByIdsToClone = ECICAccountDao.findCombinedAccountsByIdsToClone(new Set<ID>(caseToNonCICAccountStringIdentifierMap.values()));
            //split into two map - businessAccountsByIdsToClone(non person account) and personAccountsByIdsToClone (person accounts) 
            
             for (Id mapId : CombinedAccountsTypesByIdsToClone.keySet()){
                Account account =  CombinedAccountsTypesByIdsToClone.get(mapId);
                if(account.IsPersonAccount == true){personAccountsByIdsToClone.put(mapId,account);}else{businessAccountsByIdsToClone.put(mapId,account);}
             }
             
            /* CIC-1159: Old Non bulkified code that once signed off can be deleted.
            businessAccountsByIdsToClone    = ECICAccountDao.findBusinessAccountsByIdsToClone  (new Set<ID>(caseToNonCICAccountStringIdentifierMap.values()));
            personAccountsByIdsToClone      = ECICAccountDao.findPersonAccountsByIdsToClone    (new Set<ID>(caseToNonCICAccountStringIdentifierMap.values()));
            */
            nonCICContactsByIdsToClone      = ECICContactDao.findByIds                         (new Set<ID>(caseToNonCICContactStringIdentifierMap.values()));
            
            List<Map<String, SObject>> clonedAccountsAndContacts = ECICCaseTriggerAccountAndContactCacheHlp.createAccountsAndContactsToSObjectsIdMapList();
            ECICCaseTriggerAccountAndContactCacheHlp.createNewCICAccountStringMap (clonedAccountsAndContacts.get(0));  // Add Supplied* Data from Cases to clone Accounts and map them to the Case
            ECICCaseTriggerAccountAndContactCacheHlp.createNewCICContactStringMap (clonedAccountsAndContacts.get(1));  // Add Supplied* Data from Cases to clone Contacts and map them to the Case
        }
    }
    
    //Processing Cases without existing contacts in the system
    private static void assignNotExistingAccountsAndContacts() {
        ECICCaseTriggerAccountAndContactCacheHlp.createPersonAccountsToSObjectIdMap(casesWithoutExistingContacts);      //  Creates a new account, using Case Supplied* Data
    }
    
    private static void finalProcessing() 
    {
        if ((newCICAccountStringMap != null) && (! newCICAccountStringMap.isEmpty()))                                   // If there are new CIC Accounts
        {
            ECICCaseTriggerAccountAndContactCacheHlp.setOwnerIdOnAccountsAndContacts();                                 //  1. Set new account's OwnerId here                                 
            
            /**
             * FIXME:  These (below) seem "Premature"; we don't even know if these Accounts will be needed yet since the strategy hasn't executed.
             *          ... Plus Accounts which will be inserted should be consolidated into a single DML which will be executed AFTER Triggers have finished executing.
             *
             *  NOTE: We do need these values before they can be added to the Case, but just means we need to:
             *          1. During the Trigger:
             *                 + Collect the Cases which will require these (potential) Accounts during the Trigger.
             *                 + Filter the Accounts which will actually be required.
             *          2. After all the triggers have finished executing:
             *                 + Insert only the required Accounts.
             *                 + Link the inserted Accounts to the Cases.
             **/                          
    		system.debug('Email to Case Account Creation='+newCICAccountStringMap.size());
    		
            insert newCICAccountStringMap.values();                                                                     //  2. Insert the new Accounts
            ECICCaseTriggerAccountAndContactCacheHlp.insertBusinessAccountContacts();                                   //  3. Insert business Accounts

            /**
             * FIXME: Can we remove the need for the following function's additional SOQL query?  Or at least consolidate with other queries?
             **/
            generateCICPersonAccountIdMap();                                                                            // 4. Creates a map of the new Ids
        }
    }
    
    // Helper Methods --------------------------------------------------------------------------------------------------------------------------------------
    
    public static void doUpdates()  { if (!updateCICContactList.isEmpty()) { update updateCICContactList; } }

    private static void getCICContacts(Map<ECICCaseAccountWorkstream.WorkstreamEnum, Contact[]> currentContactMap, String identCaseString) 
    {
        List<Contact> cicContacts = currentContactMap.get(ECICCaseAccountWorkstream.WorkstreamEnum.CIC);
        if (cicContacts != null && !cicContacts.isEmpty()) 
        {
            cicContactStringMap.put(identCaseString, cicContacts);
        }
    }
    
    private static void getNonCICContacts(Map<ECICCaseAccountWorkstream.WorkstreamEnum, Contact[]> currentContactMap, String identCaseString) {
        if (!currentContactMap.containsKey(ECICCaseAccountWorkstream.WorkstreamEnum.CIC)) {
            Case    currentSObject  = emailAndWebCaseIdentStringMap.get(identCaseString);
            Contact nonCICContact   = ECICCaseAccountWorkstream.getWorkstreamContact (currentContactMap);
            
            if (nonCICContact != null) {
                nonCICContactStringMap.put(identCaseString, nonCICContact);
            }
        }
    }
    
    private static void linkCaseStringIdentifier() 
    {
        Set<String> caseStringIdentifierSet = nonCICContactStringMap.keySet();                                  // Get Keys for Cases with Non-CIC Contacts
        
        for (String caseStringIdentifier : caseStringIdentifierSet) 
        {
            Contact nonCICContact = nonCICContactStringMap.get(caseStringIdentifier);                           // Get Non-CIC Contact for Case
            caseToNonCICAccountStringIdentifierMap.put(caseStringIdentifier, nonCICContact.accountId);          // Map Non-CIC Account to Case by key
            if (! nonCICContact.Account.IsPersonAccount)                                                        // If Account is NOT PersonAccount
            {
                caseToNonCICContactStringIdentifierMap.put(caseStringIdentifier, nonCICContact.id);             // ... Map NON-CIC Contact to Case by key.
            }
        }
    }
    
    private static Map<String, Region__c> findRegionsByExtId() {
        Map<String, Region__c> regionsMap = new Map<String, Region__c>();
        Set<String> regionExtIds = new Set<String>();
        for (SObject currentSObject : emailAndWebCaseIdentStringMap.values()) {  // find place of purchase among Regions
            if (String.isNotBlank((String) currentSObject.get(PLACE_FIELD_NAME))) { regionExtIds.add((String) currentSObject.get(PLACE_FIELD_NAME)); }
        }
        
        Region__c[] regions = ECICRegionDao.findByExtIds(regionExtIds);                                // find Regions
        for (Region__c region : regions) { regionsMap.put(region.Region_Ext_Id__c, region); }      // sort Regions by ext id
        return regionsMap;
    }
    
    private static Set<String> generateCountryCodeSet() {
        Set<String> countryCodeStringSet = new Set<String>();
        for (SObject currentSObject : emailAndWebCaseIdentStringMap.values()) {
            if (String.isNotBlank((String) currentSObject.get(COUNTRY_CODE_FIELD_NAME))) {
                countryCodeStringSet.add((String) currentSObject.get(COUNTRY_CODE_FIELD_NAME));
            }
        }
        return countryCodeStringSet;
    }
    
    private static void generateCICPersonAccountIdMap() {
        Set<ID> newCICAccountIdSet = new Set<ID>();               // Collect the new CIC account ids
        for (Account account : newCICAccountStringMap.values()) {
            newCICAccountIdSet.add(account.id);
        }
        cicPersonAccountIdMap = ECICAccountDao.findByIds(newCICAccountIdSet);
    }
}