public class ECICCaseQComplaintReopenStrategy extends ECICCaseProcessingStrategyAbstract 
{
    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) 
    {
		Map<ID, Case> oldCasesMap = (Map<ID, Case>)oldValuesMap;
		Map<ID, Case> newCasesMap = (Map<ID, Case>)newValuesMap;
		
        Case[] qualityComplaintCases = filterQualityComplaintCases(newValuesMap.values());
    	
        for (Case newCase : qualityComplaintCases) 
        {
            Case oldCase = oldCasesMap.get(newCase.id);
            
            if (canRenew (newCase, oldCase))    // @see ECIC-2485 
            {
                newCase.Status = ECICCommonConstants.STATUS_NEW;
                newCase.Process_Type__c = 'Other';
            }
        }
        
        return true;      
    }
    
    @testVisible private Boolean canRenew (Case newCase, Case oldCase)
    {
    	return (
                        (newCase.Action_Plan__c == null) 
                    &&  (newCase.Status         != ECICCommonConstants.STATUS_CLOSED) 
                    &&  (oldCase.Status         == ECICCommonConstants.STATUS_CLOSED)
               );
    }
}