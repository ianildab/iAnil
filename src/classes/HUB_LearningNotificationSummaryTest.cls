@isTest
public class HUB_LearningNotificationSummaryTest {
	
	    static testMethod void myUnitTest() {
        HUB_Best_Practices__c bp = new HUB_Best_Practices__c();
        bp.Title__c = 'sample Learning sample Learning sample Learning sample Learning sample Learning';
        bp.Description__c = 'test description';
        bp.Learning_Type__c = 'type';
        insert bp;
        
        Test.startTest();
        
		HUB_LearningNotificationSummary obj = new HUB_LearningNotificationSummary();
		obj = new HUB_LearningNotificationSummary('xxxxx');
		obj.setAsBatch(false);
		obj.execute(null);
		obj.finish(null);
        Test.stopTest();
    }
	
}