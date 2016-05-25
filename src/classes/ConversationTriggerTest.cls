@isTest(SeeAllData=true)
private class ConversationTriggerTest{
    static testmethod void testupdate() {
    List<sf4twitter__Twitter_Account__c> lstTwiAcc = TestDataUtility.createTwitterAcc(1);
    List<sf4twitter__Twitter_Conversation__c>  lstConv = TestDataUtility.createconversation(2);
    
    sf4twitter__Twitter_Account__c twitteraccount = lstTwiAcc[0];
    insert twitteraccount;
    
    List<sf4twitter__Twitter_Account__c> lstTwiAccinserted = [Select Id,Name from sf4twitter__Twitter_Account__c where Name =: twitteraccount.Name];
    
    sf4twitter__Twitter_Conversation__c a = lstConv[0];
    a.sf4twitter__Twitter_Account__c = lstTwiAccinserted[0].Id;
    insert a;
    
    Case c = new Case(Status = 'New',Origin = 'Phone',Reason='Sponsoring');
    insert c;
        
    Test.startTest();
    a = [Select sf4twitter__Case__c from sf4twitter__Twitter_Conversation__c where Id =: a.Id];
    a.sf4twitter__Case__c = c.Id;
    update a;
    Test.stopTest();
    
    }
}