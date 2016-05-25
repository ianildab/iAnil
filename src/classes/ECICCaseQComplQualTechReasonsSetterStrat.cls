public class ECICCaseQComplQualTechReasonsSetterStrat extends ECICCaseProcessingStrategyAbstract 
{
    public override boolean OnBeforeInsert(List<sObject> newValues) 
    {
    	execute(null, (List<Case>)newValues);
        return true;
    }

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) 
    {
        execute((Map<ID, Case>)oldValuesMap, (List<Case>)newValuesMap.values());
        return true;
    }
    
    @testVisible private void execute(Map<ID, Case> oldCasesMap, Case[] newCasesList) 
    {
        for (Case newCase : filterQualityComplaintCases(newCasesList)) 
        {
            Case oldCase = (oldCasesMap != null) ? oldCasesMap.get(newCase.id) : null;
            
            if (
                    (oldCase == null)
                ||  (newCase.Category_Level4__c != oldCase.Category_Level4__c)
               ) 
            {
                    newCase.Quality_Technical_Reason__c = newCase.Category_Level4__c; //Quality_Technical_Reason__c=Final Categorization
                }
        	}
        }
    }