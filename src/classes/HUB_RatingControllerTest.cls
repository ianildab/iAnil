@isTest
public class HUB_RatingControllerTest {
	 static testMethod void myUnitTest() {
        HUB_Best_Practices__c bp = new HUB_Best_Practices__c();
        bp.Title__c = 'sample Learning sample Learning sample Learning sample Learning sample Learning';
        bp.Description__c = 'test description';
        bp.Learning_Type__c = 'type';
        insert bp;
		
		PageReference pageRef = Page.HUB_Ratelearning;
		Test.setCurrentPage(pageRef);
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(bp);
		ApexPages.currentPage().getParameters().put('Id',bp.id);
	    HUB_RatingController obj = new HUB_RatingController(sc);

		obj.chatterOpt = '1';
		obj.saveRating();
		obj.getChatterOptions();

    }
}