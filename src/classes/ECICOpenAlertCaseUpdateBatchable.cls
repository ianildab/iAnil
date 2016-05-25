global class ECICOpenAlertCaseUpdateBatchable implements Database.Batchable<SObject>   
{
    global final String BATCHABLE_QUERY =       ' SELECT id, type__c, open_alert_case__c, open_alert_case_name__c, open_alert__c, case__c, created_by__c, last_modified_by__c, requires_email__c ' 
                                              + ' FROM Open_Alert_Case_Update_Holder__c '; 

    @testVisible private static final List<String> RECIPIENT_LIST                = ECICCommonConstants.OPEN_ALERT_RECIPIENT_FIELDS; 
    @testVisible private static final List<String> OPEN_ALERT_REQIRED_FIELD_LIST = new List<String> { 'case_count__c', 'threshold__c', 'ownerId', 'recipients__c', 'additional_to__c' };

    @testVisible private static Map<Id, Open_Alert__c> openAlertToNotifyByIdMap  = null;
    @testVisible private static Map<Id, Case>          caseToNotifyByIdMap       = null;

    global Database.QueryLocator start(Database.BatchableContext batchableContext)             { return Database.getQueryLocator(BATCHABLE_QUERY); }

    global void execute(Database.BatchableContext batchableContext, List<SObject> sObjectList) { execute ((List<Open_Alert_Case_Update_Holder__c>) sObjectList); }
    
    @testVisible private static void execute(List<Open_Alert_Case_Update_Holder__c> openAlertCaseUpdateHolderList) 
    {
        List<Open_Alert_Case_Update_Holder__c> holderToInsertList               = new List<Open_Alert_Case_Update_Holder__c>();
        List<Open_Alert_Case_Update_Holder__c> holderToUpdateList               = new List<Open_Alert_Case_Update_Holder__c>();
        Set<Id>                                updateRequiredOpenAlertCaseIdSet = new Set<Id>();
    	Set<Id>                                emailRequiredOpenAlertIdSet      = new Set<Id>();
        Set<Id>                                         emailRequiredCaseIdSet                   = new Set<Id>();
        Set<Id>                                openAlertCaseToDeleteIdSet       = new Set<Id>();
    	
    	for (Open_Alert_Case_Update_Holder__c updateHolder : openAlertCaseUpdateHolderList)
    	{
    		if (updateHolder.type__c == 'Upsert')
    		{
    			((updateHolder.open_alert_case__c != null) ? holderToUpdateList : holderToInsertList ).add(updateHolder);
                updateRequiredOpenAlertCaseIdSet.add(updateHolder.open_alert_case__c);
                emailRequiredOpenAlertIdSet.add(updateHolder.open_alert__c);
                emailRequiredCaseIdSet.add(updateHolder.case__c);
    		}
    	    else if (updateHolder.type__c == 'Delete') { openAlertCaseToDeleteIdSet.add(updateHolder.open_alert_case__c); }
    	}
    	
        selectOpenAlertToNotifyByIdMap(emailRequiredOpenAlertIdSet);
        selectCaseToNotifyByIdMap(emailRequiredCaseIdSet);
    	
        List<Open_Alert_Case__c> openAlertCaseToUpsertList = prepareOpenAlertCaseUpdateList(updateRequiredOpenAlertCaseIdSet, holderToUpdateList);
                                 openAlertCaseToUpsertList.addAll(prepareOpenAlertCaseInsertList(holderToInsertList));
                          upsert openAlertCaseToUpsertList;

        List<ECICLinkCaseAndOpenAlertsConfigEntry> openAlertConfigEntryList = prepareOpenAlertConfigEntryList();
        ECICLinkCaseAndOpenAlertsEmailHelper.generateEmails(openAlertConfigEntryList, openAlertCaseToUpsertList); 

        delete [SELECT id FROM Open_Alert_Case__c WHERE id IN :openAlertCaseToDeleteIdSet];
        delete openAlertCaseUpdateHolderList;
    } 

    @testVisible private static List<Open_Alert_Case__c> prepareOpenAlertCaseUpdateList(Set<Id> updateRequiredOpenAlertCaseIdSet,  List<Open_Alert_Case_Update_Holder__c> holderToUpdateList)
    {
        updateRequiredOpenAlertCaseIdSet.remove(null);
        String soqlQuery =    ' SELECT  id, '
                            + ' open_alert__c, ' + SEPStringHelper.joinRelatedRecordFields ('open_alert__c', OPEN_ALERT_REQIRED_FIELD_LIST, ', ') + ', '
                            + ' case__c, '       + SEPStringHelper.joinRelatedRecordFields ('case__c',       RECIPIENT_LIST,                ', ') 
                            + ' FROM Open_Alert_Case__c '
                            + ' WHERE id IN :updateRequiredOpenAlertCaseIdSet ';
        Map<Id, Open_Alert_Case__c> openAlertCaseToUpdateByIdMap = new Map<Id, Open_Alert_Case__c> ((List<Open_Alert_Case__c>) Database.query(soqlQuery));
        return prepareOpenAlertCaseList(holderToUpdateList, openAlertCaseToUpdateByIdMap);
    }
       
    @testVisible private static List<Open_Alert_Case__c> prepareOpenAlertCaseInsertList(List<Open_Alert_Case_Update_Holder__c> holderToInsertList)
    {
    	return prepareOpenAlertCaseList(holderToInsertList, null);
    }

    @testVisible private static List<Open_Alert_Case__c> prepareOpenAlertCaseList(List<Open_Alert_Case_Update_Holder__c> holderList, Map<Id, Open_Alert_Case__c> openAlertCaseToUpdateByIdMap)
    {
        List<Open_Alert_Case__c> openAlertCaseList = new List<Open_Alert_Case__c>();
        for (Open_Alert_Case_Update_Holder__c holder : holderList)
        {
        	Boolean isUpdate = (holder.open_alert_case__c != null );
        	Open_Alert_Case__c openAlertCase = (isUpdate)
        	                                    ? openAlertCaseToUpdateByIdMap.get(holder.open_alert_case__c)
        	                                    : new Open_Alert_Case__c();
        	
            openAlertCaseList.add(transcribeOpenAlertCase (holder, openAlertCase, isUpdate));                               
        }
        return openAlertCaseList;
    }

    @testVisible private static Open_Alert_Case__c transcribeOpenAlertCase (Open_Alert_Case_Update_Holder__c updateHolder, Open_Alert_Case__c openAlertCase, Boolean isUpdate)
    {
               if (updateHolder.open_alert_case_name__c != null) { openAlertCase.name = updateHolder.open_alert_case_name__c; }
               
               if (!isUpdate)                                                           // Reparenting not allowed!
               {
               openAlertCase.case__c          = updateHolder.case__c;
	         if ((openAlertCase.case__c       != null) && (caseToNotifyByIdMap      != null)) { openAlertCase.case__r        = caseToNotifyByIdMap.get(openAlertCase.case__c); }
               
               openAlertCase.open_alert__c    = updateHolder.open_alert__c;
	         if ((openAlertCase.open_alert__c != null) && (openAlertToNotifyByIdMap != null)) {  openAlertCase.open_alert__r = openAlertToNotifyByIdMap.get(openAlertCase.open_alert__c); }
               }
        return openAlertCase;
    }

    @testVisible private static Map<Id, Open_Alert__c> selectOpenAlertToNotifyByIdMap (Set<Id> emailRequiredOpenAlertIdSet)
    {
        emailRequiredOpenAlertIdSet.remove(null);
        String soqlQuery         = ' SELECT id, ' + String.join (OPEN_ALERT_REQIRED_FIELD_LIST, ', ') + ' FROM Open_Alert__c ' + ' WHERE id IN :emailRequiredOpenAlertIdSet ';
        openAlertToNotifyByIdMap = new Map<Id, Open_Alert__c> ((List<Open_Alert__c>) Database.query(soqlQuery));
        return openAlertToNotifyByIdMap; 
    }

    @testVisible private static Map<Id, Case> selectCaseToNotifyByIdMap (Set<Id> emailRequiredCaseIdSet)
    { 
        emailRequiredCaseIdSet.remove(null);
        String soqlQuery    = ' SELECT id, ' + String.join (RECIPIENT_LIST, ', ') + ' FROM Case ' + ' WHERE id IN :emailRequiredCaseIdSet ';
        caseToNotifyByIdMap = new Map<Id, Case> ((List<Case>) Database.query(soqlQuery));
        return caseToNotifyByIdMap; 
    }
     
    @testVisible private static List<ECICLinkCaseAndOpenAlertsConfigEntry> prepareOpenAlertConfigEntryList ()
    {
        List<ECICLinkCaseAndOpenAlertsConfigEntry> openAlertConfigEntryList = new List<ECICLinkCaseAndOpenAlertsConfigEntry>();
        for (Open_Alert__c openAlertToNotify : openAlertToNotifyByIdMap.values()) 
        {  
            ECICLinkCaseAndOpenAlertsConfigEntry configEntry = new ECICLinkCaseAndOpenAlertsConfigEntry(openAlertToNotify); 
        	openAlertConfigEntryList.add(configEntry); 
        }
    	return openAlertConfigEntryList;
    }

    global void finish(Database.BatchableContext batchableContext) {}
}