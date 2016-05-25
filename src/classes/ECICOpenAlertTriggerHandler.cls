public with sharing class ECICOpenAlertTriggerHandler extends SEPTriggerHandlerAbstract 
{
    public static Boolean                                    openAlertTriggerIsExecuting = false;  // We need this to communicate to Case trigger handler not to update Open Alerts during an Open Alert's update of Case.
    public static Map<String, List<Open_Alert_Case__c>>      matchedOpenAlertCaseListMap = null; 
    public static List<ECICLinkCaseAndOpenAlertsConfigEntry> openAlertConfigEntryList    = null;
    
    public ECICOpenAlertTriggerHandler(boolean isTriggerExecuting) 
    {
        super(isTriggerExecuting);        
        openAlertTriggerIsExecuting = true;
    }
    
    public override void OnBeforeInsert(List<sObject> newSObjectList) 
    {
        List<Open_Alert__c> openAlertList = (List<Open_Alert__c>) newSObjectList;
        for (Open_Alert__c openAlert : openAlertList) 
        { 
            openAlert.country_code_string__c = openAlert.country_code__c; 
        }
        openAlertTriggerIsExecuting = false;
    }
    
    public override void OnAfterInsert(List<sObject> newSObjectList, Map<ID, sObject> newValuesMap) 
    {
        List<Open_Alert__c>                         activeOpenAlertList = filterActiveOpenAlertList((List<Open_Alert__c>) newSObjectList);
        Map<String, Set<String>> conditionMap = new Map<String, Set<String>>();
        List<ECICLinkCaseAndOpenAlertsConfigEntry>  openAlertConfigList = buildOpenAlertConfigEntryList(activeOpenAlertList, conditionMap);
        
        if (!openAlertConfigList.isEmpty()) 
        {
            List<Case> caseList = getCases(conditionMap);
            ECICLinkCaseAndOpenAlertsHandler.linkCasesAndOpenAlerts(ECICLinkCaseAndOpenAlertsConfigEntry.getConfigs(caseList), openAlertConfigList);
            if (matchedOpenAlertCaseListMap != null) { updateOpenAlertCases(); }
        }
        openAlertTriggerIsExecuting = false;
    }
    
    public override void OnBeforeUpdate(List<sObject> oldValues, List<sObject> newSObjectList, Map<ID, sObject> oldObjectsByIdMap, Map<ID, sObject> newSObjectsByIdMap) 
    {
        List<Open_Alert__c>                         qualifiedOpenAlertList = filterQualifiedOpenAlertList((Map<Id, Open_Alert__c>) newSObjectsByIdMap, (Map<Id, Open_Alert__c>) oldObjectsByIdMap);
        Map<String, Set<String>> conditionMap = new Map<String, Set<String>>();
        List<ECICLinkCaseAndOpenAlertsConfigEntry>  openAlertConfigList    = buildOpenAlertConfigEntryList(qualifiedOpenAlertList, conditionMap);
        
        if (!openAlertConfigList.isEmpty()) 
        {
            List<Case> caseList = getCases(conditionMap);
            ECICLinkCaseAndOpenAlertsHandler.linkCasesAndOpenAlerts(ECICLinkCaseAndOpenAlertsConfigEntry.getConfigs(caseList), openAlertConfigList, newSObjectsByIdMap.keySet());
            if (matchedOpenAlertCaseListMap != null) { updateOpenAlertCases(); }
        }
        openAlertTriggerIsExecuting = false;
    }

    // Work around against circular logic exception in ECICLinkCaseAndOpenAlertsHandler.updateOpenAlertCases() 
    @testVisible private static void updateOpenAlertCases ()
    {
        insertOpenAlertCaseUpdaterHolders();
        ECICOpenAlertCaseUpdateSchedulable.scheduleJob();  
    }
    
    @testVisible private static void insertOpenAlertCaseUpdaterHolders()
    {
        List<Open_Alert_Case_Update_Holder__c> updateHolderList = new List<Open_Alert_Case_Update_Holder__c>();
                                               updateHolderList.addAll (buildOpenAlertCaseToUpdateList());
                                               updateHolderList.addAll (buildOpenAlertCaseToDeleteList());
                                        insert updateHolderList;
    }

    @testVisible private static List<Open_Alert_Case_Update_Holder__c> buildOpenAlertCaseToUpdateList()
    {
        Set<Id> configEntryIdSet = new Set<Id>();           // The Open_Alert__c ids in this set will be used to identify when it is required to generate emails.
        if ((openAlertConfigEntryList != null) && (!openAlertConfigEntryList.isEmpty()))
        {
        for (ECICLinkCaseAndOpenAlertsConfigEntry openAlertConfigEntry : openAlertConfigEntryList) { configEntryIdSet.add(openAlertConfigEntry.id); }
        }

        List<Open_Alert_Case_Update_Holder__c> updateHolderList = new List<Open_Alert_Case_Update_Holder__c>();
        for (Open_Alert_Case__c openAlertCase : matchedOpenAlertCaseListMap.get('openAlertLinkedCaseList'))
        {
            updateHolderList.add (new Open_Alert_Case_Update_Holder__c(
                                                           type__c                  = 'Upsert',
                                                           open_alert_case__c   = openAlertCase.id,
                                                           open_alert_case_name__c = openAlertCase.name,
                                                           open_alert__c        = openAlertCase.open_alert__c,
                                                           case__c              = openAlertCase.case__c,
                                                           requires_email__c    = configEntryIdSet.contains(openAlertCase.open_alert__c)
                                  ));
        }
        return updateHolderList;
        
    }
    
    @testVisible private static List<Open_Alert_Case_Update_Holder__c> buildOpenAlertCaseToDeleteList()
    {
        List<Open_Alert_Case_Update_Holder__c> updateHolderList = new List<Open_Alert_Case_Update_Holder__c>();
        for (Open_Alert_Case__c openAlertCase : matchedOpenAlertCaseListMap.get('toDeleteOpenAlertLinkedCaseList'))
        {
            updateHolderList.add (new Open_Alert_Case_Update_Holder__c(
                                                           type__c            = 'Delete',
                                                           open_alert_case__c = openAlertCase.id
                                  ));
        }
        return updateHolderList;
    } 
    
    @testVisible private static Map<Id, Integer> buildCountMap(Set<Id> openAlertIdSet)
    {
        List<AggregateResult> resultOpenAlertList = [SELECT count(id) openAlertCount, open_alert__c FROM Open_Alert_Case__c WHERE Open_Alert__c IN :openAlertIdSet GROUP BY Open_Alert__c];
            
        Map<Id, Integer> openAlertCountMap = new Map<Id, Integer>();
        for (AggregateResult resultOpenAlert : resultOpenAlertList) 
        {
            ID      openAlertId    = (ID)      resultOpenAlert.get('open_alert__c');
            Integer openAlertCount = (Integer) resultOpenAlert.get('openAlertCount');
            openAlertCountMap.put(openAlertId, openAlertCount);
        }
        return openAlertCountMap;
    } 
    
    @testVisible  private static List<ECICLinkCaseAndOpenAlertsConfigEntry> buildOpenAlertConfigEntryList(List<Open_Alert__c> qualifiedOpenAlertList, Map<String, Set<String>> conditionMap)
    {
        List<ECICLinkCaseAndOpenAlertsConfigEntry>  openAlertConfigList = new List<ECICLinkCaseAndOpenAlertsConfigEntry >();
        for (Open_Alert__c openAlert : qualifiedOpenAlertList) 
        { 
            openAlertConfigList.add(buildOpenAlertConfigEntry(openAlert, conditionMap)); 
        }
        return openAlertConfigList;
    }
    
    @testVisible private static ECICLinkCaseAndOpenAlertsConfigEntry buildOpenAlertConfigEntry(Open_Alert__c openAlert, Map<String, Set<String>> conditionMap)
    {
            ECICLinkCaseAndOpenAlertsConfigEntry openAlertConfigEntry = new ECICLinkCaseAndOpenAlertsConfigEntry(openAlert);
            for (Schema.FieldSetMember openAlertFieldSetMember : ECICCommonConstants.OPEN_ALERT_CASE_FIELDS) 
            {                    
                Object openAlertValue = openAlert.get(openAlertFieldSetMember.FieldPath);
                ECICLinkCaseAndOpenAlertsHandler.addCondition(conditionMap, openAlertFieldSetMember.FieldPath, openAlertValue );
                openAlertConfigEntry.getArgs().add(String.valueOf(openAlertValue));
            }
            return openAlertConfigEntry;
    }
    
    @testVisible private static List<Open_Alert__c> filterActiveOpenAlertList (List<Open_Alert__c> openAlertList)
    {
        List<Open_Alert__c> activeOpenAlertList = new List<Open_Alert__c>();
        for (Open_Alert__c openAlert : openAlertList) 
        {
            String  activeString = (String) openAlert.get(ECICCommonConstants.FIELD_ACTIVE);
            Boolean isActive     = ((activeString != null) || (!Test.isRunningTest()))
                                        ? Boolean.valueOf(activeString)
                                        : TEST_MockHelper.getMockBoolean(openAlert.id, ECICCommonConstants.FIELD_ACTIVE);
            if (isActive)  { activeOpenAlertList.add (openAlert); }
        }       
        return activeOpenAlertList;
    }

    @testVisible private static List<Open_Alert__c> filterQualifiedOpenAlertList (Map<Id, Open_Alert__c> newOpenAlertsByIdMap, Map<Id, Open_Alert__c> oldOpenAlertsByIdMap)
    {
        Map<Id, Integer> openAlertCountMap = buildCountMap(newOpenAlertsByIdMap.keySet());
    
        List<Open_Alert__c> qualifiedOpenAlertList = new List<Open_Alert__c>();
        for (Open_Alert__c newOpenAlert : newOpenAlertsByIdMap.values()) 
        {
            Open_Alert__c   oldOpenAlert            = oldOpenAlertsByIdMap.get(newOpenAlert.Id);
            Boolean         isCountryCodeChanged    = isCountryCodeChanged(newOpenAlert, oldOpenAlert);
            Boolean         isActive                = Boolean.valueOf(newOpenAlert.get(ECICCommonConstants.FIELD_ACTIVE));
            Boolean         isChanged               = (isCaseFieldsChanged(newOpenAlert, oldOpenAlert)) || (isCountryCodeChanged);

            if (
                       (!openAlertWithAssignedCasesRequireChanges(newOpenAlert, oldOpenAlert, isChanged, openAlertCountMap.get(newOpenAlert.id)))
                    && (    (isEndDateChanged(newOpenAlert, oldOpenAlert))     ||   (isNowActive(isActive, isChanged, oldOpenAlert))    )
               )
            {
                qualifiedOpenAlertList.add(newOpenAlert);
            }
        }
               
        return qualifiedOpenAlertList;
    }
    
    @testVisible private List<case> getCases(Map<String, Set<String>> conditionMap) 
    {
        String[] queryFieldArray = new String[]{'ownerId', 'CreatedDate', 'CreatedById', 'Infoline_Supervisor__c', 'Casenumber', 'Country_Code__c'};
                 queryFieldArray.addAll(ECICCommonConstants.REGION_USER_FIELDS);
                 queryFieldArray.addAll(ECICCommonConstants.USER_FIELDS);

        String[]   fieldCondtionArray = new String[]{'status NOT IN (\'New\', \'Closed\', \'Cancelled\')'};
        
        return Database.query(ECICUtils.buildQuery(conditionMap, queryFieldArray , 'Case', fieldCondtionArray));
    }
    
    @testVisible private static Boolean isCaseFieldsChanged(Open_Alert__c newOpenAlert, Open_Alert__c oldOpenAlert) 
    {
        for (Schema.FieldSetMember fieldSetMember : ECICCommonConstants.OPEN_ALERT_CASE_FIELDS)
        {
            if (newOpenAlert.get(fieldSetMember.fieldPath) != oldOpenAlert.get(fieldSetMember.fieldPath)) { return true; }          
}
        return false;
    }
    
    @testVisible private static Boolean isCaseFieldsEmpty(Open_Alert__c newOpenAlert) 
    {
        for (Schema.FieldSetMember fieldSetMember : ECICCommonConstants.OPEN_ALERT_CASE_FIELDS)
        {
            if (newOpenAlert.get(fieldSetMember.fieldPath) == null) { return true; }
        }
        return false;
    }

    @testVisible private static Boolean isCountryCodeChanged(Open_Alert__c newOpenAlert, Open_Alert__c oldOpenAlert)
    {
        return newOpenAlert.country_code__c != oldOpenAlert.country_code__c;
        
    }

    @testVisible private static Boolean isEndDateChanged(Open_Alert__c newOpenAlert, Open_Alert__c oldOpenAlert)
    {
        if (newOpenAlert.end_date__c < newOpenAlert.start_date__c)
        {
            SEPErrorHelper.addError(newOpenAlert, Label.End_Date_cannot_be_before_Start_Date, false);
            return false;
        }                               

        // Note: Change will be ignored if/when newOpenAlert.End_Date__c becomes NULL!
        return ((newOpenAlert.End_Date__c != null) && (newOpenAlert.End_Date__c != oldOpenAlert.End_Date__c));                      
    } 

    @testVisible private static Boolean isNowActive(Boolean isActive, Boolean isChanged, Open_Alert__c oldOpenAlert)
    {
        String  oldActiveString = (String) oldOpenAlert.get(ECICCommonConstants.FIELD_ACTIVE);
        Boolean wasOldActive    = ((oldActiveString != null) || (!Test.isRunningTest()))
                                    ? (isActive != Boolean.valueOf(oldActiveString))
                                    : TEST_MockHelper.getMockBoolean(oldOpenAlert.id, ECICCommonConstants.FIELD_ACTIVE);
                                    
        return (
                    (                  (isActive)                 )
                 && (  (isChanged)  || (isActive != wasOldActive) )
                );    
    }

    @testVisible private static Boolean openAlertWithAssignedCasesRequireChanges (Open_Alert__c newOpenAlert, Open_Alert__c oldOpenAlert, Boolean isChanged, Integer openAlertCount)
    {
        Boolean isStartDateChanged = (newOpenAlert.start_date__c != null) && (newOpenAlert.start_date__c != oldOpenAlert.start_date__c);
        if (isChanged || isStartDateChanged) 
        {
            if (openAlertCount == 0) { return true;                                                }
            else                     { SEPErrorHelper.addError(newOpenAlert, Label.Open_Alert_has_assigned_cases, false); }  // Prevent changes to Open Alerts with assigned cases.
        }
        return false;
    }
    

}