public class ECICCaseHighPriorityIfHighRiskStrategy extends ECICCaseProcessingStrategyAbstract
{

    public override boolean OnBeforeInsert(List<sObject> newValues) {
        execute((List<Case>)newValues);
        return true;
    }

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        execute((List<Case>)newValuesMap.values());
        return true;
    }


    @testVisible private void execute(Case[] casesList) 
    {
        for (Case currentCase : casesList) 
        {
	        if( currentCase.Potential_Risk__c == 'High Risk')
	        {
                currentCase.Priority = 'High';
	        }
        }
    }
}