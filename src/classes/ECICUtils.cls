public class ECICUtils {
    private final static String DELIMITER = ';';
    private static final String OWNER_ID= 'ownerID';
    private static final String CREATED_BY_ID= 'createdById';
    private static final String COUNTRY_CODE= 'Country_code__c';
    private static final String USER_PREFIX = '005';
    
    public static boolean isEmpty(String str) {
        return (str == null) || (str.length() == 0);
    }    
    
    // @depreciated: Use SEPEmailSendHelper.createMail(sObject o, Id templateId, String[] addresses, Id targetId);
    public static Messaging.SingleEmailMessage createMail(sObject o, Id templateId, String[] addresses, Id targetId) { return SEPEmailSendHelper.createMail(o, templateId, addresses, targetId); }
    
    // @depreciated: Use SEPEmailSendHelper.sendMails(List<Messaging.Email> mails, boolean allOrNone);
    public static List<Messaging.SendEmailResult> sendMails(List<Messaging.Email> mails, boolean allOrNone) { return SEPEmailSendHelper.sendMails(mails, allOrNone) ; }
    
    // @depreciated: Use SEPEmailSendHelper.sendMails(List<Messaging.Email> mails);
    public static void sendMails(List<Messaging.Email> mails)  { SEPEmailSendHelper.sendMails(mails) ; }

    // @depreciated: Use SEPEmailSendHelper.collectRecipientsAddressesAndCreateMails(Map<sObject, Set<Id>> recipientsMap,  Set<Id> allRecipientIds, ID templateId);
    public static List<Messaging.Email> collectRecipientsAddressesAndCreateMails(Map<sObject, Set<Id>> recipientsMap,  Set<Id> allRecipientIds, ID templateId)  { return SEPEmailSendHelper.collectRecipientsAddressesAndCreateMails(recipientsMap,  allRecipientIds, templateId); }   

    // @depreciated: Use SEPEmailSendHelper.getRecipients(List<Case> caseList, String recipientUserFieldString);
    public static Set<Id> getRecipients(List<Case> cases, String recipientsStr) { return SEPEmailSendHelper.getRecipients(cases, recipientsStr); }
    
    // @depreciated: Use SEPEmailSendHelper.getRecipients(List<Case> caseList, String[] recipientUserFieldArray);
    public static Set<Id> getRecipients(List<Case> cases, String[] recipients)  { return SEPEmailSendHelper.getRecipients(cases, recipients); }
 
    /**
    * @author       Natallia Bahlai (Natallia_Bahlai@epam.com)
    * @date         MM/DD/YYYY
    * @description  
    * @param        
    * @return       
    */    
    public static String buildQuery(Map<String, Set<String>> conditionMap, String[] queryFieldArray, String fromObject, String[] fieldCondtionArray) 
    {
        List<String> conditionList = new List<String>();
        
        for (Schema.FieldSetMember fieldSetMember : ECICCommonConstants.OPEN_ALERT_CASE_FIELDS) 
        {
            queryFieldArray.add(fieldSetMember.FieldPath);
            Set<String> entryStringSet = conditionMap.get(fieldSetMember.FieldPath);
            
            if ((entryStringSet != null) && (!entryStringSet.isEmpty())) 
            {                
                conditionList.add(fieldSetMember.FieldPath + ' IN (' + String.join(new List<String>( entryStringSet ), ECICCommonConstants.COMMA_DEL) + ')');            
            }
        }
    	
        return     'SELECT ' + String.join(queryFieldArray, ECICCommonConstants.COMMA_DEL) 
                + ' FROM ' + fromObject
                + ' WHERE '
                                + ((fieldCondtionArray.isEmpty()                             ) ? ( ''      ) : (        String.join(fieldCondtionArray, ' AND ') ) )
                                + ((!fieldCondtionArray.isEmpty() && !conditionList.isEmpty()) ? ( ' AND ' ) : ( ''                                              ) )  
                                + ((conditionList.isEmpty()                                  ) ? ( ''      ) : ( ' (' + String.join(conditionList, ' OR ') + ')' ) )
            + 'AND CreatedDate = LAST_90_DAYS' ;
    }

    /**
    * @author       Natallia Bahlai (Natallia_Bahlai@epam.com)
    * @date         MM/DD/YYYY
    * @description  
    * @param        
    * @return       
    */    
    public static List<String> createCategoryKeys(String channel, Action_Plan__c ap) {
        List<String> keys = new List<String>();
        // in fact, as only one of the cat levels are filled, only one cycle will run.
        if (!isEmpty(ap.Case_Reason__c)) {
            for (String reason : ap.Case_Reason__c.split(DELIMITER , -1)) {
                keys.add(ap.Country_Code__c + '_' + channel + '_2_' + reason);
            }
        }
        
        if (!isEmpty(ap.Category_Level3__c)) {
            for (String cat3 : ap.Category_Level3__c.split(DELIMITER , -1)) {
                keys.add(ap.Country_Code__c + '_' + channel + '_3_' + cat3);
            }
        }
        
        if (!isEmpty(ap.Category_Level4__c)) {
            for (String cat4 : ap.Category_Level4__c.split(DELIMITER , -1)) {
                keys.add(ap.Country_Code__c + '_' + channel + '_4_' + cat4);
            }
        }
        
        if (!isEmpty(channel) && isEmpty(ap.Case_Reason__c) && isEmpty(ap.Category_Level3__c) && isEmpty(ap.Category_Level4__c)) {
            keys.add(ap.Country_Code__c + '_' + channel);
        }
        
        return keys;
    }
    
    /**
    *    Insert AP keys from more specific, to least specific. stop when found
    */
    public static List<string> createCategoryKeys(Case c) {
        List<String> keys = new List<String>();
        String channel = c.Origin;
        String cntrCode = c.Country_Code__c;
        keys.add(cntrCode + '_' + channel + '_4_' + c.Category_Level4__c);
        keys.add(cntrCode + '__4_' + c.Category_Level4__c);
        keys.add(cntrCode + '_' + channel + '_3_' + c.Category_Level3__c);
        keys.add(cntrCode + '__3_' + c.Category_Level3__c);
        keys.add(cntrCode + '_' + channel + '_2_' + c.Reason);
        keys.add(cntrCode + '__2_' + c.Reason);
        keys.add(cntrCode + '_' + channel);
        
        return keys;
    }
    

    public static boolean triggerActive(String triggerNames){
        Boolean isActiveTrigger = false;
        try{
            if([SELECT Status FROM ApexTrigger WHERE Name =:triggerNames].Status == 'Active'){
                isActiveTrigger = true; 
            }
        }catch(System.Exception ex){
            System.debug( Logginglevel.ERROR , ex );
        }
        return isActiveTrigger;
    }
    
    public static void resolveOwner(List<sObject> objs, Map<Id, sObject> oldMap, boolean isInsert) {
        for (sObject c : objs) {
            String ownerID = (String) c.get(OWNER_ID);
            if (ownerID.startsWith(USER_PREFIX)) {
                c.put('Owner_Lookup__c', ownerID);
            } else {
                c.put('Owner_Lookup__c', null);
            }
        }
    }
    
    public static void resolveCountryCode(List<sObject> objs, Map<Id, sObject> oldMap, boolean isInsert) {
        Set<ID> userIds = new Set<ID>();
        for (sObject c : objs) {
            String ownerID = (String) c.get(OWNER_ID);
            userIds.add(ownerID.startsWith(USER_PREFIX) ? ownerID : (String) c.get(CREATED_BY_ID));
        }
        
        if (userids.isEmpty()) {
            return ;
        }
        
        Map<Id, User> users = new Map<Id, User>([SELECT Id, Country_Code__c FROM User WHERE id IN :userids]);
        for(sObject c : objs) 
        {
            // Note: During update, this code does presently give any special handling in the unlikely event that the new value for
            // country_code__c is null or empty.
            // In other words, it will default to the owner's or creator's country_code__c instead of either
            // throwing an exception or trying to restore the original value.
            c.put(COUNTRY_CODE, chooseCountryCode (c, users));
        }
        }
    
   @testVisible private static String chooseCountryCode (SObject currentSObject, Map<Id,User> userIdMap)
    {
        if ((currentSObject.get(COUNTRY_CODE) == null) || (currentSObject.get(COUNTRY_CODE) == ''))
        {
            String ownerId = (String) currentSObject.get(OWNER_ID);
            User currentUser = userIdMap.get(ownerId.startsWith(USER_PREFIX) ? ownerId : (String) currentSObject.get(CREATED_BY_ID));
            if ((currentUser.Country_Code__c == null) || (currentUser.Country_Code__c == ''))  // This should never happen!
            {
                currentUser =  userIdMap.get((String) currentSObject.get(CREATED_BY_ID));
            }
            if ((currentUser != null) && (!String.isEmpty(currentUser.Country_Code__c))) {  return currentUser.Country_Code__c; }
        }
        return (String) currentSObject.get(COUNTRY_CODE);
    }
    
    
    public static boolean isFieldChanged(sObject old, sObject o, String field) {
        return old.get(field) != o.get(field);
    }
    
    public static String getCountryCode(String email) {
        if (String.isEmpty(email)) {
            return null;
        }
        
        String cc = email.substringAfterLast('.');
        if (cc.length() != 2 ) { 
            cc = email.substringBefore('.');
            return (cc.length() == 2 ) ? cc.toUppercase() : null;
        }
        return cc.toUppercase();
    }
    
    public static List<String> getSObjectEditableFields(String sObjectName) {
        return getSObjectEditableFields(Schema.getGlobalDescribe().get(sObjectName.toLowerCase()));
    }

    public static List<String> getSObjectEditableFields(Schema.SObjectType sObjectType) {
        List<String> result = null;

        //Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectName.toLowerCase());
        
        if (sObjectType != null) {
            result = new List<String>();
            Map<String, Schema.SObjectField> objectFieldsMap = sObjectType.getDescribe().Fields.getMap();
            
            if (objectFieldsMap != null) {
                for (Schema.SObjectField objectField : objectFieldsMap.values()) {
                    Schema.DescribeFieldResult objectFieldDescribe = objectField.getDescribe();
                    
                    if (objectFieldDescribe.isCreateable()) { // field is creatable
                        result.add(objectFieldDescribe.getName());
                    }
                }
            }
        }
        
        return result;
    }
}