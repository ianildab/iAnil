public class ECICCaseChannelChangeValidationStrategy extends ECICCaseProcessingStrategyAbstract 
{

    public override boolean OnBeforeInsert(List<sObject> newValues) {
        return execute((List<Case>)newValues);
    }

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        return execute((List<Case>)newValuesMap.values());
    }
    
    @testVisible private boolean execute(Case[] casesList) 
    {
        boolean result = true;
        for (Case currentCase : casesList) 
        {
            if (
                     ( ECICCaseHelper.isGroupId(currentCase.OwnerId)                )
                 &&  ( currentCase.Status != ECICCommonConstants.STATUS_NEW         )
                 &&  ( currentCase.Status != ECICCommonConstants.STATUS_REOPENED    )
                 &&  ( currentCase.Status != ECICCommonConstants.STATUS_CANCELLED   )
               )
            {
                currentCase.addError(Label.ownerIsQueueError);
                result = false;
            }
        }
        return result;      
    }
}