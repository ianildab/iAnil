public class ECICCaseCancelNotModifiedTasksStrategy extends ECICCaseProcessingStrategyAbstract {

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) 
    {
	    Map<ID, Case> oldCasesMap = new Map<ID, Case>((List<Case>) oldValuesMap.values());
	    Map<ID, Case> newCasesMap = new Map<ID, Case>((List<Case>) newValuesMap.values());
    
        Set<Id> caseIdsOfTasksToCancel = new Set<Id>();
        
        /* Find cases where Status field is changed to STATUS_CANCELLED */
        for (Case c : newCasesMap.values()) {
            if (ECICUtils.isFieldChanged(oldCasesMap.get(c.id), c, 'Status') && c.Status == ECICCommonConstants.STATUS_CANCELLED) {
                caseIdsOfTasksToCancel.add(c.id);
            }
        }
        
        /* Delete autogenerated tasks of the cancelled cases */
        if(!caseIdsOfTasksToCancel.isEmpty()) 
        {
        	ECICCaseTriggerTaskCache.addTasksToDeleteByCaseIdSet(caseIdsOfTasksToCancel);  
        }
        
        return true;
    }

}