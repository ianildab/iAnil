public class ECICCaseNWENTasksOnResolvedValidationStr extends ECICCaseProcessingStrategyAbstract{
    
    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        Map<ID, Case> oldCasesMap = (Map<ID, Case>)oldValuesMap;
        Map<ID, Case> newCasesMap = (Map<ID, Case>)newValuesMap;
        
        boolean result = true;
        
        Set<ID> NWENResolvedCaseIds = filterNWENNewCases(ECICCommonConstants.STATUS_RESOLVED, oldCasesMap.values(), newCasesMap);
        
        if (! NWENResolvedCaseIds.isEmpty()) {
            Map<ID, Decimal> numberOfUncompletedTasksByCaseIds = ECICCaseTriggerTaskCache.getNumberOfAllIncompleteTasksByCaseIdMap();

            result = checkNumberOfIncompleteTasks(numberOfUncompletedTasksByCaseIds, newCasesMap);
        }
        
        return result;
    }

}