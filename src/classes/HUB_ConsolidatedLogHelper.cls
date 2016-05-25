public class HUB_ConsolidatedLogHelper{
public Set<Id> caseFeedIds= new Set<Id>();
public Set<Id> taskFeedIds= new Set<Id>();
public Set<Id> impactRegionFeedIds= new Set<Id>();
public Set<Id> urlFeedIds= new Set<Id>();
public Set<Id> caseBestPracticeFeedIds= new Set<Id>();
public List<HUB_Consolidated_Log__c> clist = new List<HUB_Consolidated_Log__c>();
public List<HUB_Consolidated_Log__c> clist1 = new List<HUB_Consolidated_Log__c>();
public List<HUB_Consolidated_Log__c> clist2 = new List<HUB_Consolidated_Log__c>();
public List<HUB_Consolidated_Log__c> clist3 = new List<HUB_Consolidated_Log__c>();
public LIST<Id> parentCaseId = new LIST<Id>();
public Map<Id,case> childCaseMap = new Map<Id,Case>();    
public String casePrefix = Case.sObjectType.getDescribe().getKeyPrefix();
//public Id recordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Topic Tracker').getRecordTypeId();
public Id recordTypeId= ECICCaseTriggerRegionCache.getRecordType(ECICCommonConstants.RECORDTYPE_BY_DEVELOPERNAME_EQUAL,'HUB_Issue_Tracker').Values().Id;
//[Select ID,DeveloperName From RecordType Where DeveloperName='HUB_Issue_Tracker'].id;
public Map<ID,Case> rt_Map = New Map<ID,Case>([Select ID,RecordTypeId From Case Where RecordTypeId=:recordTypeId]);
public List<HUB_Impacted_Region__c> lstImapToinsert  = new list<HUB_Impacted_Region__c> ();

/*Method Called after Feed Item is created*/
public void afterInsertUpdate(List<FeedItem> feedList){
 
 for(FeedItem f:feedList){
             if(String.valueOf(f.ParentId).startsWith(casePrefix)){
               caseFeedIds.add(f.ParentId);
               }
         if(caseFeedIds.size()>0)  {
           InsertLogForCaseFeed(feedList); 
         }

  }
 }
 
 /*Feed Item details with Parent Id as Detailed History Id are deleted */  
 @future
 public static void DeletefeedConsol(set<Id> feedList){
  List<feedItem> f = [select Id from Feeditem where ParentId in:feedList];

  if(f.size()>0)
   {
   HUB_Validator_cls.setAlreadyDone();
    delete f;
 
    }
  }
  
  /*Feed Item details with Parent Id as Case Id are inserted in Detailed History Object*/  
  public void InsertLogForCaseFeed(List<FeedItem> feedList){
     List<Case> cs = [select Id from Case where Id in:caseFeedIds and RecordTypeId=:recordTypeId];
     if(cs.size()>0)
     {
        for(Case c:cs)
        {
            for(FeedItem f:feedList)
            
            {
               HUB_Consolidated_Log__c hc = new HUB_Consolidated_Log__c();
                hc.Query_Id__c = f.ParentId;
                hc.FeedType__c = f.Type;
                hc.Title__c = f.Title;
                hc.Feed_Inserted_By__c = f.CreatedById;
                hc.Feed_Created_Date__c = f.CreatedDate;
                hc.Case__c = c.Id;
                clist.add(hc);
                     
            }
        }
    system.debug('Feed Items'+clist);
    insert clist;
    }
            
  
    
   }
   
   /*Feed Item details with Parent Id as Case Id when deleted, a record is inserted in Detailed History Object*/  
   public void beforeDelete(List<FeedItem> feedList){ 
    
            for(FeedItem f:feedList) 
           {
                 if(f.ParentId.getSObjectType() == Case.SObjectType)
                 {
               HUB_Consolidated_Log__c hc = new HUB_Consolidated_Log__c();
                hc.Query_Id__c = f.Id;
                hc.FeedType__c = f.Type;
                hc.Title__c = f.Title + ' has been deleted';
                hc.Feed_Inserted_By__c = f.CreatedById;
                hc.Feed_Created_Date__c = f.CreatedDate;
                hc.Case__c = f.ParentId;
                clist1.add(hc);              
                }
            }
            if(clist1.size()>0)
            {
    insert clist1; 
    }
    }
    
    /*Feed Item details with Parent Id as Related Learnings Id is inserted in Detailed History Object*/  
    public void afterInsertBestPracticeAssociation(List<HUB_Case_Best_Practice_Association__c> bestPracticeList){
     map<id,string> mapLearningNameId = new map<id,string> ();
     list<HUB_Best_Practices__c> learninglist = [select id,title__c from HUB_Best_Practices__c];
     for(HUB_Best_Practices__c obj : learninglist ){
        mapLearningNameId.put(obj.Id,obj.title__c);
     }
     for(HUB_Case_Best_Practice_Association__c cb: bestPracticeList){

        if(rt_map.get(cb.Case_BestPractice__c).RecordTypeId==recordTypeId && rt_map!=null){
            HUB_Consolidated_Log__c hc = new HUB_Consolidated_Log__c();
                    hc.Query_Id__c = cb.Id;
                    hc.FeedType__c = 'Related Learning';
                    hc.Title__c = mapLearningNameId.get(cb.Best_Practices_Cases__c)+' Related Learning has been created';
                    hc.Feed_Inserted_By__c = cb.CreatedById;
                    hc.Feed_Created_Date__c = cb.CreatedDate;
                    hc.Case__c = cb.Case_BestPractice__c;
                    clist2.add(hc);  
        
        }
                   
    
      }
      if(clist2.size()>0)
      {
          insert clist2;
      }
   }
   
    /*Feed Item details with Parent Id as URL Id is inserted in Detailed History Object*/  
    public void insertURLConsolidatedLog(List<HUB_URL__c> urlList){
        List<HUB_Consolidated_Log__c> logList=new List<HUB_Consolidated_Log__c>();
        for(HUB_URL__c uc:urlList){
          if(rt_map.get(uc.Case__c).RecordTypeId==recordTypeId && rt_map!=null){
            HUB_Consolidated_Log__c hc = new HUB_Consolidated_Log__c();
            hc.Case__c=uc.Case__c;
            hc.Feed_Inserted_By__c=uc.CreatedById;
            hc.Feed_Created_Date__c=uc.CreatedDate ;
            hc.FeedType__c ='URL Record Creation';
            hc.Query_Id__c=uc.id;
            hc.title__c = uc.Name + ' has been created'; 
            logList.add(hc);
          }
            
        }
        system.debug('logList'+logList);
            if(logList.size()>0){
                insert logList;
            }
    }
     /*Feed Item details when a Case Comment is posted, a record is inserted in Detailed History Object*/  
        public void insertCaseCommentConsolidatedLog(List<CaseComment> consolList){
        List<HUB_Consolidated_Log__c> logList=new List<HUB_Consolidated_Log__c>();
        for(CaseComment uc: consolList){
          if(rt_map.get(uc.ParentId).RecordTypeId==recordTypeId && rt_map!=null){
            HUB_Consolidated_Log__c hc = new HUB_Consolidated_Log__c();
            hc.Case__c=uc.ParentId;
            hc.Feed_Inserted_By__c=uc.CreatedById;
            hc.Feed_Created_Date__c=uc.CreatedDate ;
            hc.FeedType__c ='CaseComment Creation/Updation';
            hc.Query_Id__c=uc.id;
            hc.title__c = 'Case comment has been Created/Updated'; 
            logList.add(hc);
          }
            
        }
        system.debug('logList'+logList);
            if(logList.size()>0){
                upsert logList;
            }
    }
   
   /*Feed Item details when a Case is updated , a record is inserted in Detailed History Object*/  
   public void afterUpdateCase(List<Case> caseList,Map<Id,Case> caseMap){
        List<HUB_Consolidated_Log__c> logList=new List<HUB_Consolidated_Log__c>();
        //List<HUB_Consolidated_Log__c> logListforUpdate=new List<HUB_Consolidated_Log__c>();
        List<Case> caseListForRecType=new List<Case>();
        List<String> caseId=new List<String>();
        List<FeedItem> tobeUsedForAfterUpdateCase=new List<FeedItem>();
        for(Case cs:caseList){
          if(cs.RecordTypeId==recordTypeId ){
            caseListForRecType.add(cs);
            caseId.add(cs.id);
          }
        }
        if(caseListForRecType.size()>0 && !caseListForRecType.isEmpty()){
        //List<HUB_Impacted_Region__c> impactRegionList=[select id,Name,Case__c from HUB_Impacted_Region__c where Case__c=:caseId order by CreatedDate desc limit 1];
        List<HUB_Impacted_Region__c> impactRegionList=[select id,Name,Case__c,CreatedById,CreatedDate  from HUB_Impacted_Region__c where Case__c in:caseId order by CreatedDate desc limit 1];
        
        for(Case cs:caseListForRecType){
              if(cs.HUB_Impacted_Regions_Count__c!=caseMap.get(cs.id).HUB_Impacted_Regions_Count__c){
                for(HUB_Impacted_Region__c imr:impactRegionList){
                HUB_Consolidated_Log__c hc1 = new HUB_Consolidated_Log__c();
                    hc1.Case__c=cs.Id;
                    hc1.Feed_Inserted_By__c=imr.CreatedById;
                    hc1.Feed_Created_Date__c=imr.CreatedDate;
                    hc1.FeedType__c ='Impacted Region Created';
                    hc1.title__c = 'impacted region been Created/Updated'; 
                    hc1.Query_Id__c=imr.id;
                    logList.add(hc1);
                }
                
              }
              else{
                
                 HUB_Consolidated_Log__c hc = new HUB_Consolidated_Log__c();
                    hc.Case__c=cs.Id;
                    hc.Feed_Inserted_By__c=cs.LastModifiedById;
                    hc.Feed_Created_Date__c=cs.LastModifiedDate;
                    hc.FeedType__c ='Case Field Value Update';
                    hc.Query_Id__c=cs.Id;
                    logList.add(hc);
                    
               
              }
            
            if(cs.ParentId!=null&& caseMap.get(cs.Id).ParentId == null)
             {
                       parentCaseId.add(cs.ParentId);
                       childCaseMap.put(cs.ParentId, cs);
             }
        }
       }
        system.debug('logList'+logList);
        if(logList.size()>0){
            insert logList;
        }
       if(parentCaseId!=null)
       {
           addConsolidatedLogForChildCase(parentCaseId,childCaseMap);
       }
    }
   
   /*Impact Region record is Created whenever Case is created based on Region,Business Unit and Country Value*/  
   public void afterInsertCase(List<Case> caseList){
   List<Case> caseListForRecType=new List<Case>();
   for(case cs:caseList){
     if(cs.RecordTypeId==recordTypeId ){
            caseListForRecType.add(cs);
          }
     }
    if(caseListForRecType.size()>0 && !caseListForRecType.isEmpty()){
     
          if(!HUB_Validator_cls.hasAlreadyDone()) 
            { 
              for(case cs:caseListForRecType)
               {
                  HUB_Impacted_Region__c objImp= new HUB_Impacted_Region__c();
                  objImp.Case__c     = cs.ID ;
                  objImp.Region__c= cs.HUB_Region__c;
                  objImp.Impacted_Region__c= cs.HUB_Business_Unit__c;
                  objImp.Country__c= cs.HUB_Country__c;
                  objImp.isCaseCreation__c  = true;
                  lstImapToinsert.add(objImp);
                   
                   if(cs.ParentId!=null)
                   {
                       parentCaseId.add(cs.ParentId);
                       childCaseMap.put(cs.ParentId, cs);
                   }
          
               }
          }
      } 
       if(lstImapToinsert.size()>0)
        {
          
          insert lstImapToinsert;
          HUB_Validator_cls.setAlreadyDone();
        }
       
       if(parentCaseId!=null)
       {
           addConsolidatedLogForChildCase(parentCaseId,childCaseMap);
       }

   }
   
   
    /*Feed Item details with Parent Id as Related Learnings Id is inserted in Detailed History Object*/  
    public void afterInsertRelatedContent(List<HUB_Related_Content__c> relatedContentList){
     for(HUB_Related_Content__c rc: relatedContentList){
        
        if(rt_map.get(rc.case__c).RecordTypeId==recordTypeId && rt_map!=null){
            HUB_Consolidated_Log__c hc = new HUB_Consolidated_Log__c();
                    hc.Query_Id__c = rc.Id;
                    hc.FeedType__c = 'Related Content';
                    hc.Title__c = 'Related Content created';
                    hc.Feed_Inserted_By__c = rc.CreatedById;
                    hc.Feed_Created_Date__c = rc.CreatedDate;
                    hc.Case__c = rc.case__c;
                    clist2.add(hc);  
        
        }
       
      }
      if(clist2.size()>0)
      {
          insert clist2;
      }
   }
    /* ------------- Added By Sagar Madkaikar --------------*/
    public void addConsolidatedLogForChildCase(LIST<Id> parentCaseId,Map<Id,Case> childCaseMap)
    {
        List<Case> parentCase = [Select Id,CreatedById,CreatedDate from Case where Id IN :parentCaseId];
        for(Case c:parentCase)
        {
            HUB_Consolidated_Log__c hcl = new HUB_Consolidated_Log__c();
                    hcl.Query_Id__c = childCaseMap.get(c.Id).Id;
                    hcl.FeedType__c = 'Related Case';
                    hcl.Title__c = 'Related Case Added';
                    hcl.Feed_Inserted_By__c = childCaseMap.get(c.Id).CreatedById;
                    hcl.Feed_Created_Date__c = childCaseMap.get(c.Id).CreatedDate;
                    hcl.Case__c = c.Id;
                    clist3.add(hcl);  
        }
        if(clist3.size()>0)
      	{ 
          	insert clist3;
      	}
    }
}