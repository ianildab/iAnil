/**
 *    ECIC-12 - Change owner Logic:
 *    As a System User, I want to be able to change the owner of a case (re-assignment) with the system automatically
 *    sending an email notification to the old assignee that s/he is no longer responsible for the case, so that the old
 *    user is aware that s/he is no longer responsible for the case.
 */
public class ECICCasePreviousOwnerSetterStrategy extends ECICCaseProcessingStrategyAbstract 
{
    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) 
    {
    	Map<ID, Case> oldCasesMap = (Map<ID, Case>)oldValuesMap;
    	Map<ID, Case> newCasesMap = (Map<ID, Case>)newValuesMap;
    	
        for (Case newCase: newCasesMap.values()) 
        {
            Case oldCase = oldCasesMap.get(newCase.id);

            if (
            		(oldCase.ownerId != newCase.ownerId)
                && (! ECICCaseHelper.isGroupId(oldCase.ownerId))) 
            {
                newCase.previous_owner__c = oldCase.ownerId;
            }
        }

        return true;
    }
}