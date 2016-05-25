/*
Author: Nick Hunt
Company: The Coca-Cola Company, Salesforce COE
Date: 5/27/14
Description: Test class for ChatterDefaultPostAll Trigger
 */

@isTest(SeeAllData = true)
private class HUB_ChatterDefaultPostAllTest{

    //This test method will run through full trigger
    static testMethod void runPositiveResult(){
    
        Profile userProfile = [SELECT id, name FROM Profile where Name = 'Hub Global Analyst' LIMIT 1];

        User u1 = new User(FirstName = 'Test', LastName = 'User123', Alias = 'tuser123', Email = 'tuser@email.com', Username = 'testUser123@email.com', CommunityNickname = 'IMC for test usage', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = userProfile.id, LanguageLocaleKey = 'en_US');

        Case singleCase = [SELECT id from Case Limit 1];

        System.RunAs(u1){

            FeedItem post = new FeedItem();
            post.ParentId = singleCase.Id;
            post.Body = 'Here is a test post.  Who can see this?';
            HUB_Validator_cls.setAlreadyDone();
            insert post;
        }
    }

    //This test method will run through only part of the trigger logic since the profile is not in the Custom Label
    static testMethod void runNegativeResult(){
    
        Profile userProfile = [SELECT id, name FROM Profile where Name = 'Standard User' LIMIT 1];

        User u2 = new User(FirstName = 'Test', LastName = 'User123', Alias = 'tuser123', Email = 'tuser@email.com', Username = 'testUser123@email.com', CommunityNickname = 'IMC for test usage', TimeZoneSidKey = 'GMT', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', ProfileId = userProfile.id , LanguageLocaleKey = 'en_US');

        Case singleCase = [SELECT id from Case Limit 1];

        System.RunAs(u2){

            FeedItem post = new FeedItem();
            post.ParentId = singleCase.Id;
            post.Body = 'Here is a test post.  Who can see this?';
            HUB_Validator_cls.setAlreadyDone();
            insert post;
        }
    }
}