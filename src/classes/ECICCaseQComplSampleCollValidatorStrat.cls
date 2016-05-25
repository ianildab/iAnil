public /* with sharing */ class ECICCaseQComplSampleCollValidatorStrat extends ECICCaseProcessingStrategyAbstract {
    
    public override boolean OnBeforeInsert(List<sObject> newValues) {
        Case[] qualityComplaintCases = filterQualityComplaintCases((List<Case>)newValues);
        return execute(qualityComplaintCases);
    }

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        Case[] qualityComplaintCases = filterQualityComplaintCases((List<Case>)newValuesMap.values());
        return execute(qualityComplaintCases);
    }

    private boolean execute(Case[] casesList) {
    	boolean result = true;
    	
		for (Case currentCase : casesList) {
			
		    if (currentCase.Status != 'New' 
                && currentCase.Plant__c == null
                && currentCase.Bottler__c == null
                && currentCase.Sample_Collected__c) {
                	
		        if (! String.isEmpty(currentCase.Production_code__c)) {
		            currentCase.adderror(System.label.Failed_to_retrieve_plant_and_bottler);
		        } else {
		            currentCase.addError(System.label.Quality_Case_with_sample_collection);
		        }
		        
		        result = false;
		    }
		}
		
		return result;
    }
}