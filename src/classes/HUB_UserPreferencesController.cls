public with sharing class HUB_UserPreferencesController {
    public User currentuser{get;set;}
    public HUB_UserPreferencesController(ApexPages.StandardController controller) {
       /*Query to fetch existing preferences of the Logged In User*/
       currentuser=[Select Id,HUB_Opt_Out__c,HUB_Function__c,HUB_Relevant_Brands__c,HUB_Rcv_Weekly_Learning_Summary_mails__c,HUB_Receive_Content_Digest_Emails__c,HUB_Region__c,
                    HUB_Group__c,HUB_Country__c,HUB_MarketsObserved1__c,HUB_MarketsObserved2__c,HUB_Frequency_EAG__c,HUB_Frequency_APAC__c,
                    HUB_Frequency_EG__c,HUB_New_Case_EAG__c,HUB_New_Case_APAC__c,HUB_New_Case_EG__c,HUB_Frequency_LAG__c,HUB_Frequency_Global__c,
                    HUB_Frequency_NA__c,HUB_New_Case_LAG__c,HUB_New_Case_Global__c,HUB_New_Case_NA__c,HUB_Receive_Relevant_Brand_Case_Alerts__c,HUB_Receive_High_Level_fun_Case_Alerts__c, HUB_Receive_Creation_Alert_for_Cases__c from User where Id=:userinfo.getuserId()];
    }
    
    /*Method to Update User Preferences*/
    public PageReference savePreferences(){
     update currentuser;
     PageReference pageRef = Page.HUB_UserPreferencesForCommunityUsersOP;
     return pageRef;
    }
    
    /*Method to Redirect Page*/
    public PageReference cancel(){
     PageReference pageRef = Page.HUB_UserPreferencesForCommunityUsersOP;
     return pageRef;
    }
}