public without sharing class HUB_DynamicDashboard{
   
   public Map<Id,Case> caseMap{get;set;}
   public Map<Id,Case> caseMapMostActive{get;set;}
   public Map<Id,Case> caseMapRecent{get;set;}
   public Map<Id,HUB_Impacted_Region__c> impactRegionMap{get;set;}
   public Map<Id,HUB_URL__c> urlMap{get;set;}
   public Map<Id,User> userName{get;set;} 
   public Map<Id,HUB_Case_Best_Practice_Association__c > bestPracticeMap{get;set;}
   public Map<Id,HUB_Related_Content__c > relatedContentMap{get;set;}
   public Map<Id,HUB_Best_Practices__c> learningMap{get;set;} 
   public Map<Id,HUB_Contents__c> contentMap{get;set;} 
   public Map<String, String> fieldLabelMap{get;set;}
   public Map<String, String> fieldLabelMapForLearning{get;set;}
   public Map<String, String> fieldLabelMapForContent{get;set;}
   public Set<String> ParentIds{get;set;}
   public String casePrefix{get;set;}
   public String impactedRegionPrefix{get;set;}
   public String caseBestPracticePrefix{get;set;}
   public String relatedContentPrefix{get;set;}
   public String urlPrefix{get;set;}
   public String userPrefix{get;set;}
   public Id recordTypeId{get;set;}  
   public string BPUrl {get;set;}
   public string contentUrl {get;set;}
   public String businessUnitFilter{get;set;}       
   public String categoryFilter{get;set;}       
   public String brandFilter{get;set;}      
   public List<Id> returnValuesForRecentCreatedUpdatedCases{get;set;}       
   public List<Id> returnValuesForMostActiveCases{get;set;} 
   public Decimal chatterOpt{get;set;}
   public String FeedSectionHeader {get;set;}
   public String ChatterPrefix{get;set;}
   public String contentPrefix{get;set;}
   public Map<Id,HUB_Contents__c> contentOppMap{get;set;}
   public boolean Knowledgevisibility {get;set;}
   
    public HUB_DynamicDashboard(ApexPages.StandardController controller) {
      //recordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Topic Tracker').getRecordTypeId();
      Map<string,Id> RecordtypeMap= new Map<string,Id>();
     // for(RecordType rt: [SELECT DeveloperName,Id FROM RecordType WHERE SObjectType='Case'])
      for(RecordType rt: ECICCaseTriggerRegionCache.getRecordType(ECICCommonConstants.RECORDTYPE_BY_SOBJECT_TYPE,'Case').Values())
          {
              RecordtypeMap.put(rt.DeveloperName,rt.id);
          }
     recordTypeId=RecordtypeMap.get('HUB_Issue_Tracker');
      
      returnValuesForMostActiveCases=new List<Id>();        
      returnValuesForRecentCreatedUpdatedCases=new List<Id>(); 
 
      ParentIds=new Set<String>();
      
      impactRegionMap=new Map<Id,HUB_Impacted_Region__c>();
      urlMap=new Map<Id,HUB_URL__c>();
      bestPracticeMap=new Map<Id,HUB_Case_Best_Practice_Association__c >();
      relatedContentMap=new Map<Id,HUB_Related_Content__c >();
      caseMap=new Map<Id,Case>();
      userName=new Map<Id,User>();
      learningMap=new Map<Id,HUB_Best_Practices__c>();
      contentMap=new Map<Id,HUB_Contents__c>();
      caseMapMostActive=new Map<Id,Case>();
      caseMapRecent=new Map<Id,Case>();
      
      
      /*Fetch Sobject key Prefix*/
      userPrefix=User.sObjectType.getDescribe().getKeyPrefix();
      
      casePrefix=Case.sObjectType.getDescribe().getKeyPrefix();
     
      impactedRegionPrefix = HUB_Impacted_Region__c.sObjectType.getDescribe().getKeyPrefix();
     
      urlprefix = HUB_URL__c.sObjectType.getDescribe().getKeyPrefix();
      
      contentPrefix=HUB_Contents__c.sObjectType.getDescribe().getKeyPrefix();
      fieldLabelMapForContent=new Map<String,String>();
      
      caseBestPracticePrefix = HUB_Case_Best_Practice_Association__c.sObjectType.getDescribe().getKeyPrefix();
      relatedContentPrefix = HUB_Related_Content__c.sObjectType.getDescribe().getKeyPrefix();
      fieldLabelMapForLearning=new Map<String,String>();
      
      
      /*Create a Map of Field Name and Field Label For Case*/
      fieldLabelMap=new Map<String,String>();
        for(Schema.SObjectField f : Case.getsObjectType().getDescribe().Fields.getMap().values()){
         if(f.getDescribe().getName()=='ParentId'){
            fieldLabelMap.put('Parent',f.getDescribe().getLabel());
          }
          if(f.getDescribe().getName()=='AccountId'){
            fieldLabelMap.put('Account',f.getDescribe().getLabel());
          }
          if(f.getDescribe().getName()=='ContactId'){
            fieldLabelMap.put('Contact',f.getDescribe().getLabel());
          }
          if(f.getDescribe().getName()=='OwnerId'){
            fieldLabelMap.put('Owner','Case Owner'); 
          }
          if(f.getDescribe().getName()=='AssetId'){
            fieldLabelMap.put('Asset',f.getDescribe().getLabel()); 
          }
          if(f.getDescribe().getName()=='BusinessHoursId'){
            fieldLabelMap.put('BusinessHours',f.getDescribe().getLabel()); 
          }
         fieldLabelMap.put(f.getDescribe().getName(),f.getDescribe().getLabel());
         
        }
        
        /*Create a Map of Field Name and Field Label For For Learning Object*/
        for(Schema.SObjectField f : HUB_Best_Practices__c.getsObjectType().getDescribe().Fields.getMap().values()){
         
         fieldLabelMapForLearning.put(f.getDescribe().getName(),f.getDescribe().getLabel());
         
        }
        /*Create a Map of Field Name and Field Label For For Content Object*/ 
        for(Schema.SObjectField f : HUB_Contents__c.getsObjectType().getDescribe().Fields.getMap().values()){
         
         fieldLabelMapForContent.put(f.getDescribe().getName(),f.getDescribe().getLabel());
         
        }
        
       FilterByInput();
       
       Schema.DescribeSObjectResult r = HUB_Best_Practices__c.sObjectType.getDescribe();
       BPUrl = r.getKeyPrefix();
       ChatterPrefix = CollaborationGroup.sObjectType.getDescribe().getKeyPrefix();
       contentUrl = HUB_Contents__c.sObjectType.getDescribe().getKeyPrefix();
       
       /*Feed Options for the Organization. Settings fetched from the Custom Setting*/
       HUB_Dashboard__c hd= HUB_Dashboard__c.getValues('FeedOptions');
       chatterOpt  = hd.Feed_Options__c;
       system.debug('chatterOpt++'+chatterOpt);  
       //User u = [select Id, username, Dash_Board_Feed_Options__c from User where Id = :UserInfo.getUserId()];
       //chatterOpt = (u.Dash_Board_Feed_Options__c != null) ? u.Dash_Board_Feed_Options__c : 'All Posts';
       if(chatterOpt == 1){
            FeedSectionHeader = 'Recent Posts';
       }else if(chatterOpt == 2){
            FeedSectionHeader = 'Recent Chatter Posts';
       }else{
            FeedSectionHeader = 'Recent Case Posts';
       }
       
       User u = [select Id, UserPermissionsKnowledgeUser, UserType from User where Id = :UserInfo.getUserId() limit 1];
       if(u.UserPermissionsKnowledgeUser && u.UserType != 'PowerPartner'){
            Knowledgevisibility =  true;
       }else{
         Knowledgevisibility =  false;
       }
       
    }
  
  /*Business Unit Values of Case Fields*/
  public List<SelectOption> getBusinessUnits()
    {
      List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult=Case.HUB_Business_Unit__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('','All'));    
       for( Schema.PicklistEntry f : ple)
       {
          
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    } 
    
    /*Category Values of Case Fields*/
    public List<SelectOption> getCategory()
    {
      List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult=Case.HUB_Category__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       options.add(new SelectOption('','All'));    
       for( Schema.PicklistEntry f : ple)
       {
          
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    } 
    
    /*Brand Values of Case Fields*/
    public List<SelectOption> getBrands()
    {
      List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult=Case.HUB_Brand__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       options.add(new SelectOption('','All'));    
       for( Schema.PicklistEntry f : ple)
       {
          
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    } 
    
   /*Method used to Filter Case result bases on Filter Criteria for (Recently Created / Updated Cases and Most Active Cases in last 7 days)*/
   public PageReference FilterByInput() {
      List<Id> mostActiveCaseIds=new List<ID>();
      List<Id> newUpdatedCaseIds=new List<ID>();
      
      returnValuesForMostActiveCases.clear();
      returnValuesForRecentCreatedUpdatedCases.clear();
      //Recently Created / Updated Cases
      Set<String> caseIds = new Set<String>();
      List<HUB_Impacted_Region__c> irList = new List<HUB_Impacted_Region__c> ();
      if(businessUnitFilter !=null){
        irList = [select Case__c from HUB_Impacted_Region__c where Impacted_Region__c=:businessUnitFilter order by lastmodifieddate desc limit 1000];
      }else{
        irList = [select Case__c from HUB_Impacted_Region__c  order by lastmodifieddate desc limit 1000];
      }
      
      for(HUB_Impacted_Region__c ir :irList )
      {
      caseIds.add(ir.Case__c);
      }
      if(caseIds.size()>0){
      
          List<AggregateResult> logList=[SELECT Case__c,MAX(CreatedDate) FROM HUB_Consolidated_Log__c where Case__c in:[select Id from Case where Id in:caseIds] group by Case__c order by MAX(CreatedDate) desc limit 5];
          for(AggregateResult ar:logList){
            newUpdatedCaseIds.add((Id)ar.get('Case__c'));
          }
      }
      
     //Most Active Cases in last 7 days 
     
     
     List<AggregateResult> logList=[SELECT Case__c,COUNT(ID),MAX(CreatedDate) FROM HUB_Consolidated_Log__c where CreatedDate >= LAST_N_DAYS:7 and Case__c in:[select Id from Case where Id in:caseIds] group by Case__c  order by COUNT(ID) desc limit 5];
  
      for(AggregateResult ar:logList){
        mostActiveCaseIds.add((Id)ar.get('Case__c'));
      }
      
         //for Most Active Cases in last 7 days 
         String strActiveCaseQuery = null;
         strActiveCaseQuery = 'select id,CaseNumber,Subject,Type,Priority,CreatedDate,LastModifiedDate,HUB_Risk__c, HUB_Risk_Type__c from Case where id in:mostActiveCaseIds and RecordTypeId=:recordTypeId' ;
        /* if(businessUnitFilter !=null){
                        strActiveCaseQuery+= ' and HUB_Business_Unit__c=:businessUnitFilter ';
                       // impactedBusinessUnit = [select id,Name,Case__c,Region__c,Country__c  from HUB_Impacted_Region__c where Impacted_Region__c =:businessUnitFilter];
                   }*/
         if(categoryFilter!=null){
                        strActiveCaseQuery+= ' and HUB_Category__c=:categoryFilter ';
                   }
         if(brandFilter!=null){
                        strActiveCaseQuery+= ' and HUB_Brand__c=:brandFilter ';
                   }
         
         for(Case cs:Database.query(strActiveCaseQuery)){
             caseMapMostActive.put(cs.id,cs);
             returnValuesForMostActiveCases.add(cs.id);
         }
         
        
         //Query to filter for Recently Created / Updated Cases
         String strRecentCaseQuery = null;
         strRecentCaseQuery = 'select id,CaseNumber,Subject,Type,Priority,HUB_Country__c,CreatedDate,LastModifiedDate,Status,HUB_Risk__c, HUB_Risk_Type__c from Case where id in:newUpdatedCaseIds and RecordTypeId=:recordTypeId'; 
         /*if(businessUnitFilter!=null){
                        strRecentCaseQuery+= ' and HUB_Business_Unit__c=:businessUnitFilter ';
                   }*/
         if(categoryFilter!=null){
                        strRecentCaseQuery+= ' and HUB_Category__c=:categoryFilter ';
                   }
         if(brandFilter!=null){
                        strRecentCaseQuery+= ' and HUB_Brand__c=:brandFilter ';
                   }
         strRecentCaseQuery+= ' order by LastModifiedDate desc';
         for(Case cs:Database.query(strRecentCaseQuery)){
                    caseMapRecent.put(cs.id,cs); 
                    returnValuesForRecentCreatedUpdatedCases.add(cs.id);
                  }
         
         
        getNewsFeed();
    return null;
} 
 /*Result for New Knowledge Base Articles Section*/
 public List<KnowledgeArticleVersion> getNewCreatedArticles(){
  Set<Id> articleIds=new Set<Id>();
  List<KnowledgeArticle> listOfArticles=[Select Id,CreatedDate,ArticleNumber From KnowledgeArticle k order by CreatedDate desc limit 10000];
  for(KnowledgeArticle ka:listOfArticles){
     articleIds.add(ka.Id);
  }
  List<HUB_Article_Types__c> ghubArticleTypes = HUB_Article_Types__c.getAll().values();
  List<String> ghubArticleTypesList = New List<String>();
  for(HUB_Article_Types__c article:ghubArticleTypes ){
        ghubArticleTypesList.add(article.Article_Name__c);
  }
  List<KnowledgeArticleVersion> toBeReturnedList=[SELECT Title,KnowledgeArticleId,FirstPublishedDate,CreatedDate FROM KnowledgeArticleVersion WHERE PublishStatus='Online' AND KnowledgeArticleId in:articleIds AND ArticleType IN: ghubArticleTypesList order by FirstPublishedDate desc limit 5];
  return toBeReturnedList;
  
 }
 
  /*Result for Recently Created / Updated Learnings Section*/
 public List<HUB_Best_Practices__c> getNewUpdatedBestPractice(){
  List<HUB_Best_Practices__c> bestPracticeList=[select id,Name,Title__c, Learning_Type__c,CreatedDate, LastModifiedDate, Total_Vote__c, Average__c from HUB_Best_Practices__c order by LastModifiedDate desc limit 5];
  return bestPracticeList;
  
 }
 
  /*Result for Highest Rated Learnings in last 90 days Section*/
 public List<HUB_Best_Practices__c> getHighlyRatedLearning(){
    DateTime dat = system.today().addDays(-90);
    List<HUB_Best_Practices__c> learningList = [select id,Name,Title__c, Learning_Type__c,CreatedDate, LastModifiedDate, Total_Vote__c, Average__c from HUB_Best_Practices__c where LastModifiedDate > :dat order by Average__c DESC NULLS LAST limit 5];
    return learningList;
  
 }

 /*Result for Content Opportunities - Next 3 Months Section*/
 public List<Event> getContentOpportunities(){
    contentOppMap = new Map<Id,HUB_Contents__c>();
    List<HUB_Contents__c> contentList = [select id,Name,contentType__c, CreatedDate, LastModifiedDate, Date__c,Title__c from HUB_Contents__c limit 50000];
    for(HUB_Contents__c objContent :contentList){
        contentOppMap.Put(objContent.ID,objContent);
    }
    
    Date toDate = Date.valueOf(system.today().addMonths(3));
    Date fromDate = Date.valueOf(system.today());
    List<Event> contentOppList = [select id,WhatId,ActivityDate,EndDateTime,StartDateTime from Event where EndDateTime >= :fromDate and EndDateTime <= :toDate and Subject=:'HubContentStart' order by ActivityDate limit 500];
    system.debug(contentOppList.size()+'contentOppList+++');
    return contentOppList;
  
 }
 
 /*Method returns Result for Recent Posts Section*/
 public List<FeedItem> getNewsFeed()  { 
        
        ParentIds.clear();
        
        if(chatterOpt == 3 || chatterOpt == 1){
            //Query all Case Feeds related to Case of 'Topic Tracker' RecordType
            
            Set<String> caseIds = new Set<String>();
            List<HUB_Impacted_Region__c> irList = new List<HUB_Impacted_Region__c> ();
            if(businessUnitFilter !=null){
                 irList = [select Case__c from HUB_Impacted_Region__c where Impacted_Region__c=:businessUnitFilter order by lastmodifieddate desc limit 1000];
            }else{
                 irList = [select Case__c from HUB_Impacted_Region__c  order by lastmodifieddate desc limit 1000];
            }
            for(HUB_Impacted_Region__c ir :irList ){
               caseIds.add(ir.Case__c);
            }
            String CaseFeedQuery = 'select Query_Id__c,Case__c,CreatedDate from HUB_Consolidated_Log__c where Case__r.RecordTypeId=:recordTypeId and Case__c in : caseIds' ;
            List<HUB_Impacted_Region__c> impactedBusinessUnit =  new  List<HUB_Impacted_Region__c>();
                
            /*if(businessUnitFilter!=null){
                            CaseFeedQuery+= ' and Case__r.HUB_Business_Unit__c=:businessUnitFilter ';
                            impactedBusinessUnit = [select id,Name,Case__c,Region__c,Country__c  from HUB_Impacted_Region__c where Impacted_Region__c =:businessUnitFilter];
                            
                       }*/
            if(categoryFilter!=null){
                            CaseFeedQuery+= ' and Case__r.HUB_Category__c=:categoryFilter ';
                       }
            if(brandFilter!=null){
                            CaseFeedQuery+= ' and Case__r.HUB_Brand__c=:brandFilter ';
                       }
            
            CaseFeedQuery += ' order by CreatedDate desc limit 20';
            
            //Fetching ParentIds from Consolidated Log Object 
            for(HUB_Consolidated_Log__c  cl:Database.query(CaseFeedQuery)){
                  ParentIds.add(cl.Query_Id__c);
                  ParentIds.add(cl.Case__c);
                 }
                 
            for(HUB_Impacted_Region__c  impBu:impactedBusinessUnit ){
                  ParentIds.add(impBu.Case__c);
                 }
            //Fetching Imacted Region details for a Case
            for(List<HUB_Impacted_Region__c> impactRegionList :[select id,Name,Case__c,Region__c,Country__c  from HUB_Impacted_Region__c where id in:ParentIds]){
                for(HUB_Impacted_Region__c imr:impactRegionList){
                 impactRegionMap.put(imr.id,imr);
                 }
             }
             
              //Fetching URL details for a Case
            for(List<HUB_URL__c> urlList :[select id,Name,URL__c,Description__c,Case__c from HUB_URL__c where  id in:ParentIds]){
                for(HUB_URL__c url:urlList){
                 urlMap.put(url.id,url);
                 }
              }
              //Fetching Case/Best Practice Association  details for a Case
             for(List<HUB_Case_Best_Practice_Association__c> bestPracticeList :[select id,Name,Title__c,Description__c,Case_BestPractice__c from HUB_Case_Best_Practice_Association__c where id in:ParentIds]){
                for(HUB_Case_Best_Practice_Association__c bpc:bestPracticeList){
                 bestPracticeMap.put(bpc.id,bpc);
                 }
              }
               //Map creation for Case with 'Topic Tracker' Record Type
              for(List<Case> caseList:[select id,CaseNumber,Subject,Type,Priority,CreatedDate,LastModifiedDate from Case where RecordTypeId=:recordTypeId order by LastModifiedDate desc limit 50000]){
                for(Case cs:caseList){
                 caseMap.put(cs.id,cs);
                 }
             }
             
              //Fetching related Content for a Case
             for(List<HUB_Related_Content__c> relatedContentList :[select id,Name,case__c,Content__c,Content_Title__c from HUB_Related_Content__c where id in:ParentIds]){
                for(HUB_Related_Content__c rc:relatedContentList){
                 relatedContentMap.put(rc.id,rc);
                 }
              }
        }
        
        
        If(chatterOpt == 2 || chatterOpt == 1){
            //Fetching Feed Item's ParentId from Group interaction
            list<CollaborationGroup> lstColbGroup = [Select Id,Name from CollaborationGroup where Name=:'The Hub Network'];
            for(CollaborationGroup  cg :lstColbGroup){
                  ParentIds.add(cg.Id); 
                }
                
                System.debug('**ParentIds'+ParentIds);
        }
        If(chatterOpt == 1){
        
           //Fetching Feed Item's ParentId from Learnings
            String learningFeedQuery='select Query_Id__c,Best_Practices__c,CreatedDate  from HUB_Detailed_History__c order by CreatedDate desc limit 20';
            for(HUB_Detailed_History__c cl:Database.query(learningFeedQuery)){          
                  ParentIds.add(cl.Query_Id__c);        
                }  
                
            //Fetching Learning  details for a Feed Item associated to Learning   
            for(List<HUB_Best_Practices__c> learningList :[select id,Name,Title__c,ShortDescription__c,Learning_Type__c,Description__c from HUB_Best_Practices__c where id in:ParentIds]){
                for(HUB_Best_Practices__c lrn:learningList){
                  learningMap.put(lrn.id,lrn);
                 }
              } 
              
            //Fetching Content details for a Feed Item associated to content   
            for(List<HUB_Contents__c> contentList :[select id,Name,Title__c,contentType__c,Date__c,Description__c,Source__c,URL__c from HUB_Contents__c where id in:ParentIds]){
                for(HUB_Contents__c con:contentList ){
                  contentMap.put(con.id,con);
                 }
              }
              
        }
        
         //Fetch FeedItems  
         List<Feeditem> myfeed = [SELECT Id,Type,Body,ContentFileName,InsertedById,
         InsertedBy.Name,ParentId,Parent.Name,Title,CreatedDate,LinkUrl,
         (select Id,CommentBody,CommentType,FeedItemId,InsertedById,ParentId,RelatedRecordId,CreatedDate  from FeedComments ORDER BY CreatedDate DESC),
         (SELECT ID, FieldName,OldValue, NewValue FROM FeedTrackedChanges ORDER BY Id DESC )
          from feeditem where ParentId in:ParentIds and IsDeleted=:false and Type IN('CreateRecordEvent','TrackedChange','ChangeStatusPost','ContentPost','TextPost','CaseCommentPost','AttachArticleEvent','PollPost','LinkPost','AdvancedTextPost') ORDER BY CreatedDate DESC
                          LIMIT 20];
      
      //Creating User Map                  
        Set<Id> userIds=new set<Id>();   
        List<FeedComment> feedComm=new List<FeedComment>(); 
        if(myfeed.size()>0){
          for(FeedItem fi: myfeed){
              feedComm=fi.FeedComments;
                  for(FeedComment fc: feedComm){
                    userIds.add(fc.InsertedById);
                     }
              }
        }             
        
        List<User> userRecords=[select id,Name from User where id in:userIds];
        for(User usr: userRecords){
          userName.put(usr.id,usr);
        }                    
   
       return myfeed;
     }
     
   
 //Action Poller Method is Called in a interval of 60sec     
 public PageReference refreshPages() {
   
    FilterByInput();
    return null;
}

/*Logged in User Details are stored in a Custom Object to Track login History. 
Whenever a User lands on this page with a Unique Session a corresponding record is created in the Custom Object*/

public void createUser() {
   List<User> userList=[select FirstName,LastName,Username,HUB_Country__c,LastLoginDate from User where id=:UserInfo.getUserId()];
   List<HUB_Profiles__c> profileList = HUB_Profiles__c.getAll().values();
      List<String> hubProfiles=new List<String>();
      for(HUB_Profiles__c pf : profileList ){
            hubProfiles.add(pf.Profile_Name__c);
      }
     
     
  //Integer totalUsers=[Select count() from user where isActive=true and Profile.Name like 'Hub%' ];
  Integer totalUsers=[Select count() from user where isActive=true and Profile.Name In: hubProfiles];
   dateTime lastLoggedIn = userList[0].LastLoginDate;
   system.debug('Totalo'+totalUsers);
  //Integer totalUsersInMarket=[Select count() from user where isActive=true and HUB_Country__c=:userList[0].HUB_Country__c  and (Profile.Name like 'Hub%' or usertype = 'PowerPartner')];
  Integer totalUsersInMarket=[Select count() from user where isActive=true and HUB_Country__c=:userList[0].HUB_Country__c  and Profile.Name In: hubProfiles];
   
   system.debug('Marketo'+totalUsersInMarket);
   List<HUB_User_Login_History__c> toInsert=new List<HUB_User_Login_History__c>();
   List<HUB_User_Login_History__c> userHistory=[select First_Name__c,Last_Name__c,Username__c,Hub_Market__c from HUB_User_Login_History__c where CreatedById=:UserInfo.getUserId() and Last_Logged_in_Time__c =:lastLoggedIn];
   if(userHistory.size()==0){
        for(User us: userList){
           HUB_User_Login_History__c hist=new HUB_User_Login_History__c();
           hist.First_Name__c=us.FirstName;
           hist.Last_Name__c=us.LastName;
           hist.Username__c=us.Username;
           hist.User__c=UserInfo.getUserId();
           hist.Total_Active_Users__c=totalUsers;
           hist.Total_Active_Users_in_Market__c=totalUsersInMarket;
           hist.Hub_Market__c=us.HUB_Country__c;
           hist.Session_ID__c=UserInfo.getSessionId();
           hist.Last_Logged_in_Time__c = us.LastLoginDate;
           toInsert.add(hist);
        }
   }
   else{
       toInsert.clear();
   }
    system.debug('toInsert User Login'+toInsert);
    if(toInsert.size()>0){
      insert toInsert;
    }
  }
 
}