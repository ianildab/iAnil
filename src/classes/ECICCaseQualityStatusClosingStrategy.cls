public class ECICCaseQualityStatusClosingStrategy extends ECICCaseProcessingStrategyAbstract {

    public override boolean OnBeforeInsert(List<sObject> newValues) {
        setQualityStatusClosed((List<Case>)newValues);
        return true;
    }

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        setQualityStatusClosed((List<Case>)newValuesMap.values());
        return true;
    }

    @testVisible private void setQualityStatusClosed(Case[] casesList) 
    {
    	for (Case currentCase : filterQualityComplaintCases(casesList)) 
    	{
	        if ( 
	                   (currentCase.status         == ECICCommonConstants.STATUS_CLOSED) 
	               &&  (currentCase.action_plan__c == null                             )
	           ) 
	        {
	            currentCase.quality_status__c = ECICCommonConstants.STATUS_CLOSED ;    
	        }
    	}
    }
}