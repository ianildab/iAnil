@isTest

public class HUB_TestSuggestedArtcleAreaController {
	static testMethod void testSuggestedArea() {
	     	RecordType rt = [select id,Name from RecordType where SobjectType='Case' and DeveloperName='HUB_Issue_Tracker' Limit 1];
      	  	case cs = new case();
	     	cs.subject = 'test';
	     	cs.description = 'asdasda';
	     	cs.HUB_Region__c = 'Global';
        	cs.recordTypeId=rt.id;
	     	insert cs;
	     	
	     	PageReference pageRef = Page.Hub_SuggestedArticlesArea;
			Test.setCurrentPage(pageRef);
			ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(cs);
			ApexPages.currentPage().getParameters().put('Id',cs.id);
	     	Hub_SuggestedArtcleAreaController objClass = new Hub_SuggestedArtcleAreaController(sc);

    } 
    
    
    static testMethod void testSuggestedArea1() {
        	RecordType rt = [select id,Name from RecordType where SobjectType='Case' and DeveloperName='HUB_Issue_Tracker' Limit 1];
      	  	case cs = new case();
	     	cs.subject = 'tested';
	     	cs.description = 'asdasdaerer';
	     	cs.HUB_Region__c = 'Global';
        	cs.recordTypeId=rt.id;
        
      		insert cs;
	     	
	     	HUB_Best_Practices__c bp = new HUB_Best_Practices__c();
	     	bp.title__c = 'test';
	     	bp.description__c = 'asdasda';
	     	insert bp;
	     	
	     	HUB_Case_Best_Practice_Association__c objBPCase = new HUB_Case_Best_Practice_Association__c();
		    objBPCase.Case_BestPractice__c=cs.id;
		    objBPCase.Best_Practices_Cases__c = bp.Id;
		    insert objBPCase;
	     	
	     	case cs1 = new case();
	     	cs1.subject='tested';
	     	cs1.description = 'asdasdaerer';
	     	cs1.ParentId = cs.Id;
	     	cs1.HUB_Region__c = 'Global';
        	cs1.recordTypeId=rt.id;
	     	insert cs1;
	    	
        	HUB_Approved_External_Messaging__kav testArticle= new HUB_Approved_External_Messaging__kav(Title = 'TestTitle', UrlName = 'TestTitle');
        	insert testArticle;
        	HUB_Approved_External_Messaging__kav testArticleID = [Select KnowledgeArticleId from HUB_Approved_External_Messaging__kav where ID = :testArticle.Id];
        	KbManagement.PublishingService.publishArticle(testArticleID.KnowledgeArticleId, true); 
        	
        	HUB_Internal_Use_Only_Core_Message__kav testIntArticle= new HUB_Internal_Use_Only_Core_Message__kav(Title = 'Test Internal Article', UrlName = 'TestTitle1');
        	insert testIntArticle;
        	HUB_Internal_Use_Only_Core_Message__kav testIntArticleID = [Select KnowledgeArticleId from HUB_Internal_Use_Only_Core_Message__kav where ID = :testIntArticle.Id];
        	KbManagement.PublishingService.publishArticle(testIntArticleID.KnowledgeArticleId, true); 
        
	     	String publish = 'Online';
			string lang = 'en_US';
	     	KnowledgeArticleVersion kn  = [select title,id,KnowledgeArticleId from KnowledgeArticleVersion where PublishStatus='Online' and Language ='en_US' limit 1];
			
			
			CaseArticle ca = new CaseArticle();
		    ca.KnowledgeArticleId = Kn.KnowledgeArticleId;
		    ca.caseid=cs.id;
		    insert ca;
	     	 
	     	PageReference pageRef = Page.Hub_SuggestedArticlesArea;
			Test.setCurrentPage(pageRef);
			ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(cs);
			ApexPages.currentPage().getParameters().put('Id',cs.id);
	     	Hub_SuggestedArtcleAreaController objClass = new Hub_SuggestedArtcleAreaController(sc);
	     	
	     	Hub_SuggestedArtcleAreaController.suggestedBestPractice bpWraper = new Hub_SuggestedArtcleAreaController.suggestedBestPractice(bp);
	     	bpWraper.selected = true;
	     	
	     	Hub_SuggestedArtcleAreaController.suggestedArticleWraaper ArticleWrapper = new Hub_SuggestedArtcleAreaController.suggestedArticleWraaper(kn);
	     	ArticleWrapper.selected = true;
	     	
	     	Hub_SuggestedArtcleAreaController.suggestedCases caseWrapper = new Hub_SuggestedArtcleAreaController.suggestedCases(cs);
	     	caseWrapper.selected = true;
	     	
	     	
	     	objClass.searchString = 'test';
	     	objClass.attachArticle();
	     	objClass.attachBP();
	     	objClass.attachCase();
	     	objClass.getBestpractice('test');
	     	objClass.getCases('test');
        test.startTest();
	     	objClass.SearchContents();
        test.stopTest();
    } 
    
    static testMethod void testSuggestedArea2() {
	     	RecordType rt = [select id,Name from RecordType where SobjectType='Case' and DeveloperName='HUB_Issue_Tracker' Limit 1];
      	  	
        	case cs = new case();
	     	cs.subject = 'tested';
	     	cs.description = 'asdasdaerer';
	     	cs.HUB_Region__c = 'Global';
       		cs.recordTypeId=rt.id;
	     	insert cs;
	     	
	     	HUB_Best_Practices__c bp = new HUB_Best_Practices__c();
	     	bp.title__c = 'test';
	     	bp.description__c = 'asdasda';
	     	insert bp;
	     	
	     	PageReference pageRef = Page.Hub_SuggestedArticlesArea;
			Test.setCurrentPage(pageRef);
			ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(cs);
			ApexPages.currentPage().getParameters().put('Id',cs.id);
	     	Hub_SuggestedArtcleAreaController objClass = new Hub_SuggestedArtcleAreaController(sc);

	     	objClass.searchString = null;
	     	objClass.SearchContents();
    } 
}