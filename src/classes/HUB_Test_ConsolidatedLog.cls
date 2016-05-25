@isTest
public class HUB_Test_ConsolidatedLog {
    static testMethod void testHubConsolidatedLog(){
      Test.StartTest();
      Case cs=new Case(Subject='Test Class',Description='Test Class',HUB_Risk__c='Green',HUB_Category__c='Business',
                     HUB_Issue__c='Addiction',Origin='Call Center',Priority='Medium',Status='Monitor',HUB_Velocity__c='Medium',
                     HUB_Impact__c='Brand',HUB_Brand__c='Sprite',HUB_Channel__c='Traditional Media',HUB_Region__c='Global',HUB_Business_Unit__c='Global',HUB_Country__c='');
     insert cs; 
     
     List<FeedItem> addFeeds=new List<FeedItem>();
     FeedItem post = new FeedItem();
    
     post.ParentId =cs.id;
     post.Body = 'HUB Test Class';
     post.createdById =UserInfo.getUserId();
     addFeeds.add(post);
      
     HUB_Validator_cls.blnAlreadyDone=false;  
     insert addFeeds;
   
     HUB_ConsolidatedLogHelper hcl=new HUB_ConsolidatedLogHelper();
     hcl.afterInsertUpdate(addFeeds);
     
     Test.StopTest();
    }
    
    
    static testMethod void testHubConsolidatedLog1(){
      Test.StartTest();
      
        
      Case cs=new Case(Subject='Test Class',Description='Test Class',HUB_Risk__c='Green',HUB_Category__c='Business',
                     HUB_Issue__c='Addiction',Origin='Call Center',Priority='Medium',Status='Monitor',HUB_Velocity__c='Medium',
                     HUB_Impact__c='Brand',HUB_Brand__c='Sprite',HUB_Channel__c='Traditional Media',HUB_Region__c='Global',HUB_Business_Unit__c='Global',HUB_Country__c='');
     insert cs; 
     
     List<FeedItem> addFeeds=new List<FeedItem>();
     FeedItem post = new FeedItem();
    
     post.ParentId =cs.id;
     post.Body = 'HUB Test Class';
     post.createdById =UserInfo.getUserId();
     addFeeds.add(post);
     insert addFeeds; 
      

     
   HUB_ConsolidatedLogHelper hcl=new HUB_ConsolidatedLogHelper(); 
   HUB_Validator_cls.blnAlreadyDone=false;  
   delete addFeeds;
        
     hcl.beforeDelete(addFeeds);
     Test.StopTest();
    }
    
    static testMethod void testHubConsolidatedLogURLBPComment(){
       //Test.StartTest();
        RecordType rt = [select id,Name,DeveloperName from RecordType where SobjectType='Case' and DeveloperName='HUB_Issue_Tracker' Limit 1];

         Case cs=new Case(Subject='Test Class',Description='Test Class',HUB_Risk__c='Green',HUB_Category__c='Business',
                     HUB_Issue__c='Addiction',Origin='Call Center',Priority='Medium',Status='Monitor',HUB_Velocity__c='Medium',
                     HUB_Impact__c='Brand',HUB_Brand__c='Sprite',HUB_Channel__c='Traditional Media',HUB_Region__c='Global'
                          ,HUB_Business_Unit__c='Global',HUB_Country__c='',recordTypeId=rt.id);
      
        insert cs; 
     HUB_Best_Practices__c bestPrac=new HUB_Best_Practices__c(Title__c='Test Class',Description__c='Test Class');
     insert bestPrac;
     
     
        
     List<HUB_URL__c> urlList=new List<HUB_URL__c>();
     HUB_URL__c url=new HUB_URL__c(Case__c=cs.id,URL__c='www.google.com',Description__c='Test Class',Short_Description_Text__c='Test Class');
     urlList.add(url);
     insert urlList;
        
     HUB_ConsolidatedLogHelper hcl=new HUB_ConsolidatedLogHelper();
     hcl.insertURLConsolidatedLog(urlList);   
     
     List<CaseComment> commList=new List<CaseComment>();
     CaseComment comm=new CaseComment(ParentId=cs.Id,CommentBody='Test Class');
     commList.add(comm);
     HUB_Validator_cls.blnAlreadyDone=false; 
     insert commList;
     hcl.insertCaseCommentConsolidatedLog(commList);
      
      Integer MAX_QUERY = Limits.getLimitQueries(); 
      Integer NUM_QUERY = MAX_QUERY - 1;
      System.assertEquals(NUM_QUERY, 99); 
      Test.StartTest();
      System.assertEquals(NUM_QUERY, 99); 
      List<CaseComment> commListUpdate=new List<CaseComment>();
        for(CaseComment cc:commList){
           CaseComment caseComment=[select id,ParentId,CommentBody from CaseComment where id =:cc.id limit 1];
           caseComment.CommentBody='Update Test Class';
           commListUpdate.add(caseComment);
        }
     HUB_Validator_cls.blnAlreadyDone=false; 
     update commListUpdate;
     hcl.insertCaseCommentConsolidatedLog(commListUpdate);
        
        
     List<HUB_Case_Best_Practice_Association__c> bpList=new List<HUB_Case_Best_Practice_Association__c>();
     HUB_Case_Best_Practice_Association__c bestPractice=new HUB_Case_Best_Practice_Association__c(Case_BestPractice__c=cs.Id,Best_Practices_Cases__c=bestPrac.Id);
     bpList.add(bestPractice);   
     insert bpList;
     hcl.afterInsertBestPracticeAssociation(bpList);   
      Test.StopTest();
    }
     

    static testMethod void testHubConsolidatedLogFutureMethod(){
        Test.StartTest();
        RecordType rt = [select id,Name,DeveloperName from RecordType where SobjectType='Case' and DeveloperName='HUB_Issue_Tracker' Limit 1];
        
         Case cs=new Case(Subject='Test Class',Description='Test Class',HUB_Risk__c='Green',HUB_Category__c='Business',
                     HUB_Issue__c='Addiction',Origin='Call Center',Priority='Medium',Status='Monitor',HUB_Velocity__c='Medium',
                     HUB_Impact__c='Brand',HUB_Brand__c='Sprite',HUB_Channel__c='Traditional Media',
                     HUB_Region__c='Global',HUB_Business_Unit__c='Global',HUB_Country__c='',recordTypeId=rt.id);
      insert cs; 
      
     //List<HUB_URL__c> urlList=new List<HUB_URL__c>();
     HUB_URL__c url=new HUB_URL__c(Case__c=cs.id,URL__c='www.google.com',Description__c='Test Class',Short_Description_Text__c='Test Class');
     //urlList.add(url);
     insert url;
     List<HUB_Consolidated_Log__c> logList=new List<HUB_Consolidated_Log__c>();
     HUB_Consolidated_Log__c logRecord =new HUB_Consolidated_Log__c(Case__c=cs.id,Feed_Inserted_By__c=UserInfo.getUserId(),Query_Id__c=url.id,FeedType__c='URL Creation');
     logList.add(logRecord);
     insert logList;
     Set<Id> logIds=new Set<Id>();
        for(HUB_Consolidated_Log__c cl:logList){
            logIds.add(cl.id);
        }
     HUB_ConsolidatedLogHelper.DeletefeedConsol(logIds);
    }
}