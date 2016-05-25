/*
Author: Nick Hunt
Company: The Coca-Cola Company, Salesforce COE
Date: 5/27/14
Description: This trigger makes the default visibility of a Chatter feed post on the Case object to AllUsers given the user 
has a profiled contained in the custom label
 */

trigger HUB_ChatterDefaultPostAll on FeedItem (before insert, before update) {
    if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) { return; }
    String profiles = Label.HUB_IMC_Users;
    boolean execute = false;

    User currentUser = [Select Username, UserType, Title, ProfileId, Name, LastLoginDate, Id, Email, CompanyName, Alias, Profile.Name From User WHERE Id = :UserInfo.getUserId()];
    
    for(String singleProfile : profiles.split(',')){
        if(currentUser.Profile.Name == singleProfile){
            System.debug('profiles matched!: ' + currentUser.Profile.Name + ' == '  + singleProfile);
            execute = true;
        }
        else{
            System.debug('No match found: ' + currentUser.Profile.Name + ' == '  + singleProfile);
        }
    }
    
    System.debug('custom label: ' + profiles);

    if(execute == true){
        for(FeedItem fi: Trigger.New){
            if(fi.ParentId.getSObjectType() == Case.SObjectType || fi.ParentId.getSObjectType() == HUB_Best_Practices__c.SObjectType || fi.ParentId.getSObjectType() == HUB_Contents__c.SObjectType){
                System.debug('FeedItem visibility before: ' + fi.Visibility);
                fi.Visibility = 'AllUsers';
                System.debug('FeedItem visibility after: ' + fi.Visibility);
            }
        }
    }
    else{
        System.debug('no modification made - not a Hub or IMC user');
    }
}