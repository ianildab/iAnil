@isTest
private class HUB_Test_DynamicDashboard {

 static testMethod void DynamicDashboard() {
     
     HUB_Dashboard__c customSetting=new HUB_Dashboard__c(Name='FeedOptions',Feed_Options__c=1);
     insert customSetting;
     //Id caseRecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Topic Tracker').getRecordTypeId();
     Id recordTypeId=[Select ID,DeveloperName From RecordType Where DeveloperName='HUB_Issue_Tracker'].id;
     Case cs=new Case(Subject='Test Class',Description='Test Class',HUB_Risk__c='Green',HUB_Category__c='Business',
                     HUB_Issue__c='Addiction',Origin='Call Center',Priority='Medium',Status='Monitor',HUB_Velocity__c='Medium',
                     HUB_Impact__c='Brand',HUB_Brand__c='Sprite',HUB_Channel__c='Traditional Media',HUB_Region__c='Global',
                      HUB_Business_Unit__c='Global',HUB_Country__c='Global', recordTypeId = recordTypeId);
     insert cs;   
        
     FeedItem newFeed =new FeedItem(ParentId=cs.Id,Type='CreateRecordEvent');
     insert newFeed;
     
     FeedComment feedComm=new FeedComment(FeedItemId=newFeed.id,CommentBody='Testing comment');
     insert feedComm;
     
     HUB_URL__c url=new HUB_URL__c(Case__c=cs.id,URL__c='www.google.com');
     insert url;
     
     HUB_Impacted_Region__c imr=new HUB_Impacted_Region__c(Case__c=cs.id,Impacted_Region__c=cs.HUB_Business_Unit__c,Country__c=cs.HUB_Country__c,Region__c=cs.HUB_Region__c);
     insert imr;
     HUB_Best_Practices__c bestPrac=new HUB_Best_Practices__c(Title__c='Test Class',Description__c='Test Class');
     insert bestPrac;
     
     Date todaydate = Date.valueOf(system.today());
     Date dateLater = Date.valueOf(system.today().addMonths(3));
     HUB_Contents__c  newContent=new HUB_Contents__c (contentType__c='Always On', Date__c=todaydate,URL__c='www.google.com',End_Date__c=dateLater ,Title__c='Test Content');
     insert newContent;
     
     HUB_Case_Best_Practice_Association__c bestPractice=new HUB_Case_Best_Practice_Association__c(Case_BestPractice__c=cs.Id,Best_Practices_Cases__c=bestPrac.Id);
     insert bestPractice;
     
     HUB_Consolidated_Log__c log=new HUB_Consolidated_Log__c(Case__c=cs.id,Query_Id__c=url.id);
     
     
     PageReference pageRef = Page.HUB_DynamicDashboard;
     Test.setCurrentPage(pageRef);
     ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(cs);
     HUB_DynamicDashboard objClass = new HUB_DynamicDashboard(sc);
     objClass.getBusinessUnits();
     objClass.getCategory();
     objClass.getBrands();
     objClass.getNewCreatedArticles();
     test.startTest();
     objClass.getNewUpdatedBestPractice();
     List<HUB_Best_Practices__c> bpList=objClass.getHighlyRatedLearning();
     
     system.assert(bpList.size()>0);
     objClass.getContentOpportunities();
     objClass.refreshPages();
    
     objClass.categoryFilter='Business';
     objClass.businessUnitFilter='Global';
     objClass.brandFilter='Sprite';
     
     objClass.FilterByInput();
     test.stopTest();  
     system.assert(objClass.returnValuesForMostActiveCases.size()>0);
     system.assert(objClass.returnValuesForRecentCreatedUpdatedCases.size()>0);
     system.assert(objClass.ParentIds.size()>0);
      //objClass.createUser();
    
     
    }
    
    static testMethod void DynamicDashboardNegative() {
   
     HUB_Dashboard__c customSetting=new HUB_Dashboard__c(Name='FeedOptions',Feed_Options__c=2);
     insert customSetting;
     //Id caseRecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Topic Tracker').getRecordTypeId();
     Id recordTypeId=[Select ID,DeveloperName From RecordType Where DeveloperName='HUB_Issue_Tracker'].id;
     Test.startTest();  
     Case cs=new Case(Subject='Test Class',Description='Test Class',HUB_Risk__c='Green',HUB_Category__c='Business',
                     HUB_Issue__c='Addiction',Origin='Call Center',Priority='Medium',Status='Monitor',HUB_Velocity__c='Medium',
                     HUB_Impact__c='Brand',HUB_Brand__c='Sprite',HUB_Channel__c='Traditional Media',HUB_Region__c='Global',
                      HUB_Business_Unit__c='Global',HUB_Country__c='Global', recordTypeId = recordTypeId);
     insert cs; 
     Test.stopTest();  
     
     FeedItem newFeed =new FeedItem(ParentId=cs.Id,Type='CreateRecordEvent');
     insert newFeed;
     
     FeedComment feedComm=new FeedComment(FeedItemId=newFeed.id,CommentBody='Testing comment');
     insert feedComm;
     
     HUB_URL__c url=new HUB_URL__c(Case__c=cs.id,URL__c='www.google.com');
     insert url;
     
     HUB_Impacted_Region__c imr=new HUB_Impacted_Region__c(Case__c=cs.id,Impacted_Region__c=cs.HUB_Business_Unit__c,Country__c=cs.HUB_Country__c,Region__c=cs.HUB_Region__c);
     insert imr;
     HUB_Best_Practices__c bestPrac=new HUB_Best_Practices__c(Title__c='Test Class',Description__c='Test Class');
     insert bestPrac;
     
     Date todaydate = Date.valueOf(system.today());
     Date dateLater = Date.valueOf(system.today().addMonths(3));
     HUB_Contents__c  newContent=new HUB_Contents__c (contentType__c='Always On', Date__c=todaydate,URL__c='www.google.com',End_Date__c=dateLater ,Title__c='Test Content');
     insert newContent;
     
     HUB_Case_Best_Practice_Association__c bestPractice=new HUB_Case_Best_Practice_Association__c(Case_BestPractice__c=cs.Id,Best_Practices_Cases__c=bestPrac.Id);
     insert bestPractice;
     
     HUB_Consolidated_Log__c log=new HUB_Consolidated_Log__c(Case__c=cs.id,Query_Id__c=url.id);
     
     
     PageReference pageRef = Page.HUB_DynamicDashboard;
      Test.setCurrentPage(pageRef);
      ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(cs);
      HUB_DynamicDashboard objClass = new HUB_DynamicDashboard(sc);
     objClass.getBusinessUnits();
     objClass.getCategory();
     objClass.getBrands();
     objClass.getNewCreatedArticles();
     objClass.getNewUpdatedBestPractice();
     List<HUB_Best_Practices__c> bpList=objClass.getHighlyRatedLearning();
     system.assert(bpList.size()>0);
     objClass.getContentOpportunities();
     objClass.refreshPages();
     
     objClass.categoryFilter='Business';
     objClass.businessUnitFilter='Global';
     objClass.brandFilter='Sprite';
     objClass.FilterByInput();
     system.assert(objClass.returnValuesForMostActiveCases.size()>0);
     system.assert(objClass.returnValuesForRecentCreatedUpdatedCases.size()>0);
      //objClass.createUser();
   
     
    }
  
}