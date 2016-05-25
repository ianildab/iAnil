/**
JIRA:STM-391 Set up the permissions for "campaign manager" profile
*/
trigger STMUserTrigger on User (before insert, before update) {
	Id STMGCampaignManagerProfileId = [SELECT Id FROM Profile WHERE Name = 'STMG_Campaign Manager' LIMIT 1].Id; 
    for (User u: Trigger.new) {
    	if (u.ProfileId == STMGCampaignManagerProfileId) {
    		u.UserPermissionsMarketingUser = true;
    	}
    } 
}