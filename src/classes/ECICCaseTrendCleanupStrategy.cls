public class ECICCaseTrendCleanupStrategy extends ECICCaseProcessingStrategyAbstract {

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
    	Map<ID, Case> oldCasesMap = (Map<ID, Case>)oldValuesMap;
    	Map<ID, Case> newCasesMap = (Map<ID, Case>)newValuesMap;

        // Filter for newly canceled Cases
        Set<Id> cancelledCaseIdSet = filterNewCasesByStatusChangedTo(ECICCommonConstants.STATUS_CANCELLED, oldCasesMap.values(), newCasesMap);
    	for (Id cancelledCaseId : cancelledCaseIdSet) 
    	{
    		Case newCase = newCasesMap.get(cancelledCaseId);
    		     newCase.Trend__c = null;  // We don't need to check if the value wasn't null because there is no harm to "reset" it to null when it already has that value.

                //TODO: delete trend if there is no trend anymore
            }
    	
    	return true;
    }
}