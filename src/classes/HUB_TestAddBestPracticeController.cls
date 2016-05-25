@isTest
public class HUB_TestAddBestPracticeController {
	static testMethod void testFeed() {
	     	HUB_Best_Practices__c bp = new HUB_Best_Practices__c();
	     	bp.title__c = 'test';
	     	bp.description__c = 'asdasda';
	     	insert bp;
	     	
	     	Hub_AddBestPracticeController objClass = new Hub_AddBestPracticeController(new ApexPages.StandardController(bp));
	     	objClass.obj = bp;
	     	objClass.getFiles();
    } 

}