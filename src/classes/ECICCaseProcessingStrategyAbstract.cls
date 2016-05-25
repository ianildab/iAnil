abstract public class ECICCaseProcessingStrategyAbstract extends SEPTriggerHandlerStrategyAbstract {

    @testVisible protected Case[] filterCasesByRecordTypes(Case[] casesList, Set<ID> recordTypeIds) 
    {
        List<Case> result = new List<Case>();
        for (Case currentCase : casesList) {
            if (recordTypeIds.contains(currentCase.RecordTypeId)) {
                result.add(currentCase);
            }
        }
        return result;
    }

    @testVisible protected Case[] filterQualityComplaintCases(Case[] casesList) {
        return filterCasesByRecordTypes(casesList,ECICCaseQualityComplaintRecordTypeHelper.QUALITY_COMPLAINT_ID_SET);
    }
    
    @testVisible protected Case[] filterAllComplaintCases(Case[] casesList) {
        Set<Id> complaintIdSet = ECICCaseQualityComplaintRecordTypeHelper.QUALITY_COMPLAINT_ID_SET;
                complaintIdSet.addAll (ECICCaseQualityComplaintRecordTypeHelper.buildNonQualityComplaintIdSet());
              //  ECICCaseQualityComplaintRecordTypeHelper.buildNonQualityComplaintIdSet(complaintIdSet);
        return filterCasesByRecordTypes(casesList, complaintIdSet); 
    }
    
    @testVisible protected Set<ID> filterNewCasesByStatusChangedTo(String newStatus, Case[] oldCases, Map<ID, Case> newCasesMap) {
        Set<ID> result = new Set<ID>();
        
        for (Case oldCase : oldCases) {
            Case newCase = newCasesMap.get(oldCase.id);
            try{
                if (oldCase.Status != newStatus
                      && newCase.Status == newStatus) {
    
                    result.add(newCase.id);
                }
            }
            catch(Exception ex){
                System.debug('Error : '+ex.getStackTraceString()+ 'Message : '+ex.getMessage());
            }
        }
        
        return result;
    }
    
    // Create function to get NWEN Cases
    @testVisible protected Set<ID> filterNWENNewCases(String newStatus, Case[] oldCases, Map<ID, Case> newCasesMap) {
        Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);
        Map<Id,Profile> PROFILE_BY_ID_MAP = SEPProfileCache.GetProfilesByIdMap();
        Id profileId=userinfo.getProfileId();
        String ProfileName = PROFILE_BY_ID_MAP.get(profileId).Name;
        Set<ID> result = new Set<ID>();
       
        for (Case oldCase : oldCases) {
            
            Case newCase = newCasesMap.get(oldCase.id);
            //newCase.addError('oldCases='+oldCases +'::newCasesMap='+newCasesMap);
        //return new Set<ID>();
       		
            String developerName;
        	if(RECORD_TYPES_BY_ID_MAP.get(oldCase.RecordTypeID).DeveloperName !='Quality_Complaint_SABU')
            	developerName = RECORD_TYPES_BY_ID_MAP.get(newCase.RecordTypeID).DeveloperName;
            
            try{
                if (developerName.contains(ECICCommonConstants.NWEN_QUALITY_COMPLAINT_DEVNAME) 
                    && newCase.Status == 'Resolved' 
                    && (ProfileName.contains(ECICCommonConstants.PROFILE_ECIC_NWEN_INFOLINE_AGENT) || ProfileName.contains(ECICCommonConstants.PROFILE_ECIC_NWEN_INFOLINE_SUPERVISOR))) {
                    result.add(newCase.id);
                }
            }
            catch(Exception ex){
                System.debug('Error : '+ex.getStackTraceString()+ 'Message : '+ex.getMessage());
            }
        }
        
        return result;
    }
    
    @testVisible protected boolean checkNumberOfIncompleteTasks(Map<ID, Decimal> numberOfUncompletedTasksByCaseIds, Map<ID, Case> casesMap) 
    {
        Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);
        boolean result = true;
        
        for (ID caseId : numberOfUncompletedTasksByCaseIds.keySet()) 
        {
            Decimal numberOfUncompletedTasks = numberOfUncompletedTasksByCaseIds.get(caseId);
            
            if (numberOfUncompletedTasks > 0) 
            {
                Case currentCase = casesMap.get(caseId);
                
               
                String developerName = RECORD_TYPES_BY_ID_MAP.get(currentCase.RecordTypeID).DeveloperName;  
                if (developerName.contains(ECICCommonConstants.NWEN_QUALITY_COMPLAINT_DEVNAME) && CurrentCase.Status == 'Resolved') 
                {
                    SEPErrorHelper.addError(currentCase, System.Label.Complete_all_tasks_NWEN, false);
                }
                else
                {
                    SEPErrorHelper.addError(currentCase, System.Label.Complete_all_tasks, false);
                }
                result = false;
            }
        }
        
        return result;
    }
}