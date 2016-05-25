public class ECICCaseOwnerLookupSetterStrategy extends ECICCaseProcessingStrategyAbstract {

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
        	currentCase.Owner_Lookup__c = ECICCaseHelper.isUserId(currentCase.OwnerId) ? currentCase.OwnerId : null;
        }
    }
}