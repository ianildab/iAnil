@isTest
public with sharing class HUB_TestAddArticleToConsolidatedLog {
	@isTest static void testSuggestedArea() {
		HUB_Approved_External_Messaging__kav testArticle= new HUB_Approved_External_Messaging__kav(Title = 'TestTitle', UrlName = 'TestTitle');
        	insert testArticle;
        	
        HUB_Approved_External_Messaging__kav testArticleID = [Select KnowledgeArticleId from HUB_Approved_External_Messaging__kav where ID = :testArticle.Id];
        
        // Publish
		KbManagement.PublishingService.publishArticle(testArticleID.KnowledgeArticleId, true); 
        
        String publish = 'Online';
		string lang = 'en_US';
        
		KnowledgeArticleVersion kn  = [select title,id,KnowledgeArticleId from KnowledgeArticleVersion where PublishStatus='Online' and Language ='en_US' limit 1];
		
		case cs = new case();
	    cs.subject = 'tested';
	    cs.description = 'asdasdaerer';
	    cs.HUB_Region__c = 'Global';
	    insert cs;		
				
		CaseArticle objArticle = new CaseArticle();
		objArticle.KnowledgeArticleId = Kn.KnowledgeArticleId;
		objArticle.caseid=cs.id;
		insert objArticle;
		
		HUB_Consolidated_Log__c objNewConsLog = new HUB_Consolidated_Log__c();
		objNewConsLog.Case__c = cs.Id;
		objNewConsLog.Feed_Inserted_By__c = UserInfo.getUserId();
		objNewConsLog.Feed_Created_Date__c = Date.today();
		objNewConsLog.isArticle__c = false;
		objNewConsLog.Query_Id__c = objArticle.Id;
		objNewConsLog.Title__c = 'con sol been attached'; 
		objNewConsLog.FeedType__c = 'Knowledge Article Attached';
		insert objNewConsLog;
		
		Hub_AddArticleToConsolidateLog objClass = new Hub_AddArticleToConsolidateLog();
		objClass.AddToConsolidatedLog();
	}
	
	@isTest static void testSuggestedArea1() {
		 
		case cs = new case();
	    cs.subject = 'tested';
	    cs.description = 'asdasdaerer';
	    cs.HUB_Region__c = 'Global';
	    insert cs;		
				
		HUB_Consolidated_Log__c objNewConsLog = new HUB_Consolidated_Log__c();
		objNewConsLog.Case__c = cs.Id;
		objNewConsLog.Feed_Inserted_By__c = UserInfo.getUserId();
		objNewConsLog.Feed_Created_Date__c = Date.today().addDays(-1);
		objNewConsLog.isArticle__c = true;
		objNewConsLog.Query_Id__c = '12345678912345';
		objNewConsLog.Title__c = 'con sol been attached'; 
		objNewConsLog.FeedType__c = 'Knowledge Article Attached';
		insert objNewConsLog;
		
		
		Hub_AddArticleToConsolidateLog objClass = new Hub_AddArticleToConsolidateLog();
		objClass.AddToConsolidatedLog();
	}
	
	@isTest static void addArticle() {
		HUB_Approved_External_Messaging__kav testArticle= new HUB_Approved_External_Messaging__kav(Title = 'TestTitle', UrlName = 'TestTitle');
        insert testArticle;
        	
        HUB_Approved_External_Messaging__kav testArticleID = [Select KnowledgeArticleId from HUB_Approved_External_Messaging__kav where ID = :testArticle.Id];
        
        // Publish
		KbManagement.PublishingService.publishArticle(testArticleID.KnowledgeArticleId, true); 
        
        String publish = 'Online';
		string lang = 'en_US';
		KnowledgeArticleVersion kn1  = [select title,id,KnowledgeArticleId from KnowledgeArticleVersion where PublishStatus='Online' and Language ='en_US' limit 1];
		
		case cs1 = new case();
	    cs1.subject = 'tested-Teste';
	    cs1.description = 'asdasdaerer';
	    cs1.HUB_Region__c = 'Global';
	    insert cs1;		
				
		CaseArticle objArticle1 = new CaseArticle();
		objArticle1.KnowledgeArticleId = Kn1.KnowledgeArticleId;
		objArticle1.caseid=cs1.id;
		insert objArticle1;
		
		HUB_Consolidated_Log__c objNewConsLog = new HUB_Consolidated_Log__c();
		objNewConsLog.Case__c = cs1.Id;
		objNewConsLog.Feed_Inserted_By__c = UserInfo.getUserId();
		objNewConsLog.Feed_Created_Date__c = Date.today();
		objNewConsLog.isArticle__c = true;
		objNewConsLog.Query_Id__c = '1234567891234515';
		objNewConsLog.Title__c = 'con sol been attached'; 
		objNewConsLog.FeedType__c = 'Knowledge Article Attached';
		insert objNewConsLog;
		
		Hub_AddArticleToConsolidateLog objClass = new Hub_AddArticleToConsolidateLog();
		objClass.AddToConsolidatedLog();
	}
}