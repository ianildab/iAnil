/**
 * Check if production line belongs to the plant set on the Case
 */
public class ECICCaseValidateProdlineStrategy extends ECICCaseProcessingStrategyAbstract 
{
	private static final Map<Id, Set<Id>> PRODUCTION_LINE_SET_BY_PLANT_ID_MAP = ECICCaseTriggerProductionLineCache.getProductionLineIdSetByPlantIdMap();
    
    public override Boolean onBeforeInsert(List<sObject> newCasesList) 
    {
        return checkAndExecute(null, (List<Case>)newCasesList);
    }
    
    public override Boolean onBeforeUpdate(Map<ID, sObject> oldCasesMap, Map<ID, sObject> newCasesMap) 
    {
    	return checkAndExecute((Map<ID, Case>)oldCasesMap, (List<Case>)newCasesMap.values());
    }
    
    @testVisible private Boolean checkAndExecute(Map<ID, Case> oldCasesMap, List<Case> newCasesList) 
    {
        List<Case> qualityComplaintCaseList = filterQualityComplaintCases(newCasesList);
        boolean result = true;
        
        // Check if we have to execute the whole strategy process on update.
        if (isExecutionRequired(oldCasesMap, qualityComplaintCaseList)) 
        {
            result = doExecution(qualityComplaintCaseList);
        }
        
        return result;
    }

    @testVisible private Boolean isExecutionRequired(Map<ID, Case> oldCaseByIdMap, List<Case> qualityComplaintCaseList) 
    {
    	for (Case qualityComplaintCase : qualityComplaintCaseList) 
    	{
            Case oldCase = (oldCaseByIdMap != null) ? oldCaseByIdMap.get(qualityComplaintCase.id) : null;
        	if (isExecutionRequired(oldCase, qualityComplaintCase)) { return true; }
    	}
                
    	return false;    	
    }
    
    @testVisible private Boolean isExecutionRequired(Case oldCase, Case qualityComplaintCase)
    {
    	return (
                       (oldCase                                 == null)
                    || (qualityComplaintCase.Production_Line__c != oldCase.Production_Line__c) 
                    || (qualityComplaintCase.Plant__c           != oldCase.Plant__c)
               );
    }
    
    @testVisible private Boolean doExecution(List<Case> qualityComplaintCaseList) 
    {
        boolean successExecution = true;
        for (Case qualityComplaintCase : qualityComplaintCaseList) 
        {
            successExecution = doExecution(qualityComplaintCase);
        }
        return successExecution;
    }

    @testVisible private Boolean doExecution(Case qualityComplaintCase) 
    {
        Set<Id> plantProductionLineIdSet = PRODUCTION_LINE_SET_BY_PLANT_ID_MAP.get((Id)qualityComplaintCase.Plant__c);
        if ( ( (qualityComplaintCase.Plant__c != null) && (qualityComplaintCase.Production_Line__c != null) ) )
        {
        	if ( 
        	           (  plantProductionLineIdSet      == null                                       ) 
        	       ||  (! plantProductionLineIdSet.contains(qualityComplaintCase.Production_Line__c)  ) 
        	   ) 
	        {
	            SEPErrorHelper.addError(qualityComplaintCase, System.Label.ProdLineDependsOnPlant, false);
	            return false;
	        }
	        
	        // No error (here) for incomplete information.  (Why not?)
        }
        return true;
    }
}