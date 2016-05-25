public class ECICLinkCaseAndOpenAlertsHandler  
{
    public static void addCondition(Map<String, Set<String>> conditionMap, String fieldName, Object fieldValue ) 
    {    
        if (fieldValue != null) 
        {
            Set<String> fieldValueValueSet;
                        fieldValueValueSet = (conditionMap.containsKey(fieldName)) ? conditionMap.get(fieldName) : new Set<String>(); 
                        fieldValueValueSet.add(
                                                (fieldValue instanceOf Datetime) 
                                                    ? ((Datetime) fieldValue).format('yyyy-MM-dd') 
                                                    : ('\'' + String.valueOf(fieldValue) + '\'')
                                                );                  
            conditionMap.put(fieldName, fieldValueValueSet);
        } 
    }
    
    /**
     * ECICCaseTriggerHandler uses this method for both onAfterInsert() and onAfterUpdate() 
     * to create junction objects between Case and corresponding Open_Alert__c records.
     *
     * In the medium-to-long term, while this functionality may (or may not) remain within this class,
     * it should be invoked be a Case Trigger Strategy, instead of directly by the handler.
     *
     * @param List<Case> caseList  : comes from the Case trigger's newValuesList.
     * @param Set<Id>    caseIdSet : comes from the Case trigger's newValuesByIdMap keySet.
     **/
    public static void linkCasesAndOpenAlerts(List<Case> caseList, Set<Id> caseIdSet) 
    {
        Map<String, Set<String>> conditionMap = new Map<String, Set<String>>();                                                                     // Creates new (empty) map for conditions to match.
        
        Map<String, List<Object>> linkedCasesAndOpenAlertsSublistMap = sublistLinkedCasesAndOpenAlerts(caseList, conditionMap);
        List<ECICLinkCaseAndOpenAlertsConfigEntry> caseConfigEntryList = (List<ECICLinkCaseAndOpenAlertsConfigEntry>) linkedCasesAndOpenAlertsSublistMap.get('caseConfigEntryList');
        List<Id>          cancelledIdList     = (List<Id>)          linkedCasesAndOpenAlertsSublistMap.get('cancelledIdList');
        
        if (!cancelledIdList.isEmpty())  { delete [SELECT id FROM Open_alert_case__c WHERE case__c in :cancelledIdList]; }
        if ((caseConfigEntryList.isEmpty()) || (conditionMap.isEmpty())) { return; }
        
        List<Open_Alert__c> openAlertList = queryOpenAlertList(conditionMap);
        if (openAlertList.isEmpty()) 
        { 
            delete [select id from Open_alert_case__c where case__c in :caseIdSet]; 
            return; 
        }
        
        deleteOpenAlertCases  (caseIdSet, openAlertList);
        linkCasesAndOpenAlerts(caseConfigEntryList, ECICLinkCaseAndOpenAlertsConfigEntry.getConfigs(openAlertList), caseIdSet);
    }
    
    /**
     *   Divides Cases between those which might be linked and those links which have been canceled
     *   (But where is the Open Alert data coming from?)
     *
     * @param List<Case>               caseList     : comes from the Case trigger's newValuesList.
     * @param Map<String, Set<String>> conditionMap : a non-null, but empty map to contain conditions for building SOQL query..
     **/
    @testVisible private static Map<String, List<Object>> sublistLinkedCasesAndOpenAlerts(List<Case> caseList,  Map<String, Set<String>> conditionMap)
    {
        List<ECICLinkCaseAndOpenAlertsConfigEntry>  caseConfigEntryList = new List<ECICLinkCaseAndOpenAlertsConfigEntry >();
        List<Id>                 cancelledIdList     = new List<Id>();
        
        for (Case currentCase : caseList) 
        {
            if     ((currentCase.status == ECICCommonConstants.STATUS_NEW) || (currentCase.status == ECICCommonConstants.STATUS_CLOSED)) { continue; }
            else if (currentCase.status == ECICCommonConstants.STATUS_CANCELLED) 
            {
                cancelledIdList.add(currentCase.id);
                continue;
            }
            
            ECICLinkCaseAndOpenAlertsConfigEntry caseConfigEntry = new ECICLinkCaseAndOpenAlertsConfigEntry (currentCase);            // Constructs new instance of ECICLinkCaseAndOpenAlertsConfigEntry subclass with current Case as [s]Object
                                                 caseConfigEntryList.add(caseConfigEntry);                                            // Adds new ECICLinkCaseAndOpenAlertsConfigEntry to a list of ConfigEntries.                             
                        
            for (Schema.FieldSetMember openAlertFieldSetMember : ECICCommonConstants.OPEN_ALERT_CASE_FIELDS)               // Iterates through Open_Alert__c field names
            {
                Object caseFieldValue = currentCase.get(openAlertFieldSetMember.FieldPath);                                // Captures value from current Case's field with identical name to Open Alert field
                addCondition(conditionMap, openAlertFieldSetMember.FieldPath, caseFieldValue );                            // Adds fieldName and fieldValue pair into conditionMap
                caseConfigEntry.getArgs().add(String.valueOf(caseFieldValue));                                             // Adds fieldValue into current ECICLinkCaseAndOpenAlertsConfigEntry; this should update the Entry within the EntryList because it is added as/by reference, not as a copy.
            }      
        }
        Map<String, List<Object>> linkedCasesAndOpenAlertsSublistMap = new Map<String, List<Object>>();                 // Creates a map of lists to return.
                                  linkedCasesAndOpenAlertsSublistMap.put ('caseConfigEntryList', caseConfigEntryList);  
                                  linkedCasesAndOpenAlertsSublistMap.put ('cancelledIdList',     cancelledIdList);
                           return linkedCasesAndOpenAlertsSublistMap;                                                   // Updates to conditionMap are also "returned" because it was passed by reference, not as copy. 
    }
    
    @testVisible  private static List<Open_Alert__c> queryOpenAlertList(Map<String, Set<String>> conditionMap)
    {
        String query = ECICUtils.buildQuery(
                            conditionMap, 
                            new String[]{'Name', 'Start_Date__c', 'End_Date__c', 'Additional_To__c', 'Recipients__c', 'Country_Code_String__c', 'ownerId', 'threshold__c', 'case_count__c', ECICCommonConstants.FIELD_ACTIVE}, 
                            Schema.SObjectType.Open_Alert__c.getName(), 
                            new String[]{}
                        );
        return database.query(query);
    }
    
    @testVisible  private static void deleteOpenAlertCases(Set<Id> caseIdSet, List<Open_Alert__c> openAlertList)
    {
        Set<Id> openAlertIdSet = new Map<Id, Open_Alert__c>(openAlertList).keySet();
        delete [ SELECT case__c, Open_alert__c, id FROM Open_alert_case__c WHERE (case__c in :caseIdSet) AND (Open_alert__c NOT IN :openAlertIdSet) ];
    }
        
    
    public static void linkCasesAndOpenAlerts(List<ECICLinkCaseAndOpenAlertsConfigEntry> caseECICLinkCaseAndOpenAlertsConfigEntryList, List<ECICLinkCaseAndOpenAlertsConfigEntry> openAlertConfigEntryList, Set<Id> idSet) 
    {        
        // Select Open_Alert_Case__c records where either the Case or the Open Alert is within the parameter-supplied Set<Id>
        List<Open_alert_case__c> openAlertCaseLinkList = [
                                                            SELECT case__c, Open_alert__c, id 
                                                            FROM Open_alert_case__c 
                                                            WHERE (case__c IN :idSet) OR (Open_alert__c IN :idSet) 
                                                         ];
                                                         
        // Create a map of the Open_Alert_Cases, using the combined Case and Open Alert Ids as a key.                                                         
        Map<String, ID> openAlertCaseLinksMap = new Map<String, ID>();
        for (Open_alert_case__c openAlertCaseLink : openAlertCaseLinkList)  
        { 
            openAlertCaseLinksMap.put(openAlertCaseLink.case__c + '_' + openAlertCaseLink.Open_alert__c, openAlertCaseLink.id); 
        }

        // Updates map of matched Cases and Open Alerts
        Map<String, List<Open_Alert_Case__c>>  matchedOpenAlertCaseListMap = ECICLinkCaseAndOpenAlertsMatchable.matchOpenAlertsAndCases(caseECICLinkCaseAndOpenAlertsConfigEntryList, openAlertConfigEntryList, openAlertCaseLinksMap);    

        if (!ECICOpenAlertTriggerHandler.openAlertTriggerIsExecuting)
        {
        	updateOpenAlertCases (matchedOpenAlertCaseListMap, openAlertConfigEntryList);
        } 
        else
        {
            ECICOpenAlertTriggerHandler.matchedOpenAlertCaseListMap = matchedOpenAlertCaseListMap;
            ECICOpenAlertTriggerHandler.openAlertConfigEntryList    = openAlertConfigEntryList;
        }
    }   
    
    @testVisible private static void updateOpenAlertCases (Map<String, List<Open_Alert_Case__c>>  matchedOpenAlertCaseListMap, List<ECICLinkCaseAndOpenAlertsConfigEntry> openAlertConfigEntryList)
    {
        // Gets list of NEW junction objects.
        List<Open_Alert_Case__c> openAlertLinkedCaseList         = matchedOpenAlertCaseListMap.get('openAlertLinkedCaseList');
        if (!openAlertLinkedCaseList.isEmpty()) 
        { 
        	upsert openAlertLinkedCaseList; 
            ECICLinkCaseAndOpenAlertsEmailHelper.generateEmails(openAlertConfigEntryList, openAlertLinkedCaseList); 
        } 

        List<Open_Alert_Case__c> toDeleteOpenAlertLinkedCaseList = matchedOpenAlertCaseListMap.get('toDeleteOpenAlertLinkedCaseList');
        if (!toDeleteOpenAlertLinkedCaseList.isEmpty()) { delete toDeleteOpenAlertLinkedCaseList; }
    }   
    
    public static void linkCasesAndOpenAlerts(List<ECICLinkCaseAndOpenAlertsConfigEntry> caseECICLinkCaseAndOpenAlertsConfigEntryList, List<ECICLinkCaseAndOpenAlertsConfigEntry> openAlertConfigEntryList) 
    {
        if (caseECICLinkCaseAndOpenAlertsConfigEntryList.isEmpty() || openAlertConfigEntryList.isEmpty()) { return; }
        
        List<Open_Alert_Case__c> openAlertLinkedCaseList         = new List<Open_Alert_Case__c>();
        List<Open_Alert__c>      emailedOpenAlertList    = new List<Open_Alert__c>();

        for (ECICLinkCaseAndOpenAlertsConfigEntry configEntry : caseECICLinkCaseAndOpenAlertsConfigEntryList) 
        {
            ECICLinkCaseAndOpenAlertsMatchable matchable   = new ECICLinkCaseAndOpenAlertsMatchable (configEntry.args);
            Case      currentCase = (Case) configEntry.obj;
            for (ECICLinkCaseAndOpenAlertsConfigEntry openAlertConfigEntry : openAlertConfigEntryList ) 
            {  
                
                Open_Alert__c   openAlert               = (Open_Alert__c) openAlertConfigEntry.obj;
                Boolean       isCountryCodeMatched    = ECICLinkCaseAndOpenAlertsMatchable.isCountryCodeMatched(openAlert, currentCase);
                
                if (isCountryCodeMatched) 
                {
                    boolean isMatched = matchable.matchTo(openAlertConfigEntry.args) && ECICLinkCaseAndOpenAlertsMatchable.matchCreationDate(currentCase.CreatedDate, openAlert.Start_Date__c, openAlert.End_Date__c);
                    
                    if (isMatched) 
                    {
                        openAlertLinkedCaseList.add(ECICOpenAlertCaseHelper.createOpenAlertCase(configEntry, openAlertConfigEntry ));
                        emailedOpenAlertList.add((Open_Alert__c) openAlertConfigEntry.obj);
                    }
                }
            }
        }
        
        insert         openAlertLinkedCaseList;
        ECICLinkCaseAndOpenAlertsEmailHelper.generateEmails(openAlertConfigEntryList, openAlertLinkedCaseList); 
    } 

}