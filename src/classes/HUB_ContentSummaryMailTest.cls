@isTest
public class HUB_ContentSummaryMailTest {
	    static testMethod void myUnitTest() {
        HUB_Contents__c  c = new HUB_Contents__c ();
        c.Title__c = 'test content';
        c.Description__c = 'test description';
        c.contentType__c = 'type';
        c.URL__c = 'WWW.abc.com';
        c.Source__c = 'DMX';
        c.Date__c = Date.today();
        c.End_Date__c = Date.today();
        insert c;
        
        Test.startTest();
        
		HUB_ContentSummaryMail obj = new HUB_ContentSummaryMail();
		obj = new HUB_ContentSummaryMail('xxxxx');
		obj.setAsBatch(false);
		obj.execute(null);
		obj.finish(null);
        Test.stopTest();
    }

}