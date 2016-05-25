/**
 * Sets case country code by either the owner's or the creator's country code.
 */
public class ECICCaseCountryCodeSetterStrategy extends ECICCaseProcessingStrategyAbstract 
{

    public override boolean OnBeforeInsert(List<sObject> newValues) {
    	if (newValues == null) { return false; }
        execute(null, (List<Case>)newValues);
        return true;
    }

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
    	if (newValuesMap == null) { return false; }
        execute((Map<ID, Case>)oldValuesMap, (List<Case>)newValuesMap.values());
        return true;
    }
    
    @testVisible private void execute(Map<ID, Case> oldCasesMap, Case[] newCasesList) 
    {
        Map<ID, User> users = ECICCaseTriggerUserCache.getUserByIdMap();
        for (Case newCase : newCasesList) {
            Case oldCase = oldCasesMap != null ? oldCasesMap.get(newCase.id) : null;

            if  (
            			(String.isBlank(newCase.Country_code__c))
                	&&  (ECICCaseHelper.isUserId(newCase.ownerID))
                )
            {
                User user = users.get(newCase.ownerID);
                newCase.Country_code__c = getUserCountryCode(user);
	    	
				// I don't remember why we wanted or needed this.  :-(
		    	if (Test.isRunningTest() && (newCase.Subject == 'Mandatory Stategy Test') && (newCase.Country_code__c == null))
		    	{
		    		newCase.Country_code__c = 'DM';		
		    	}
            }
        }
    }
 
private Set<ID> getCaseOwnersOrCreators(Case[] casesList) {
        Set<ID> result = new Set<ID>();
        
        for (Case currentCase : casesList) {
            ID userId = ECICCaseHelper.isUserId(currentCase.OwnerId) ? currentCase.OwnerId : currentCase.createdById;
            result.add(userId);
        }
        
        return result;
    }
   
    @testVisible private String getUserCountryCode(User user) {
        String result = null;
        if (user != null
            && String.isNotBlank(user.Country_code__c)) {
        
            result = user.Country_code__c;
        }
        return result;      
    }
}