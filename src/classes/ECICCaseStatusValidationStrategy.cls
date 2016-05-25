/**
 *  Intended as a "quickfix" to resolve inability to open cases.
 *
 *  Problem caused because Users cannot edit or add tasks for closed cases,
 *  BUT the very process of attempting to reopen the case attempts to add or edit Tasks.
 *
 *	@see https://tcccdiam.atlassian.net/i#browse/CIC-888
 **/ 
public class ECICCaseStatusValidationStrategy  extends ECICCaseProcessingStrategyAbstract
{
    public override boolean onBeforeUpdate(Map<ID, sObject> oldSObjectValueMap, Map<ID, sObject> newSObjectValueMap) 
    {
        Boolean isAtLeastOneValid = false;
        for (Case newCase : (List<Case>) newSObjectValueMap.values()) 
        {
            Case oldCase = (Case) oldSObjectValueMap.get(newCase.Id);
            if ( (oldCase.isClosed) && (newCase.Status == 'Open') && (newCase.Action_Plan__c == null) ) 
            { 
            	newCase.addError(Label.Reopened_case_must_have_new_status); 
            }
            else { isAtLeastOneValid = true; }
        }
        return isAtLeastOneValid;
    }
}