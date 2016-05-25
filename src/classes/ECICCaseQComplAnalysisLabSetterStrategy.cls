/*
 *   If the “Sample collected” check box is checked in the Laboratory of Analysis field
 *   must be filled automatically with “Plant’s Laboratory” value.
 */
public /* with sharing */ class ECICCaseQComplAnalysisLabSetterStrategy extends ECICCaseProcessingStrategyAbstract {
    
    public override boolean OnBeforeInsert(List<sObject> newValues) {
        Case[] qualityComplaintCases = filterQualityComplaintCases((List<Case>)newValues);
        execute(qualityComplaintCases);
        
        return true;
    }
    
    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        Case[] qualityComplaintCases = filterQualityComplaintCases((List<Case>)newValuesMap.values());
        execute(qualityComplaintCases);
        
        return true;
    }
    
    @testVisible private void execute(Case[] casesList) {
        if (! casesList.isEmpty()) {
            for (Case currentCase : casesList) {
                if (currentCase.Sample_Collected__c) {
                    if (
                        (Country_Specific_Settings__c.getValues(currentCase.Country_code__c) != null) 
                        && !String.isEmpty(Country_Specific_Settings__c.getValues(currentCase.Country_code__c).Laboratory_of_Analysis__c)
                       )
                    {
                       currentCase.Laboratory_of_Analysis__c = Country_Specific_Settings__c.getValues(currentCase.Country_code__c).Laboratory_of_Analysis__c;
                    } else {
                        currentCase.addError ( System.Label.No_plant_laboratory_is_set_for_this_Case_country );
                    }
                }
            }
        }
    }
    

}