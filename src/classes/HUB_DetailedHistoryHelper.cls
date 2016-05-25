/*Helper Class for Trigger Operations HUB */

public class HUB_DetailedHistoryHelper {
public Set<Id> learningIds=new Set<Id>();
public Set<Id> contentIds=new Set<Id>();
public Map<Id,FeedItem> learningFeedIds= new Map<Id,FeedItem>();
public Map<Id,FeedItem> contentFeedIds= new Map<Id,FeedItem>();
public String learningPrefix = HUB_Best_Practices__c.sObjectType.getDescribe().getKeyPrefix();
public String contentPrefix = HUB_Contents__c.sObjectType.getDescribe().getKeyPrefix();

/*Method Called after Feed Item is created*/
    public void afterInsert(List<FeedItem> feedList){
        for(FeedItem f: feedList){
            if(String.valueOf(f.ParentId).startswith(learningPrefix)){
                learningIds.add(f.ParentId);
                learningFeedIds.put(f.Id,f);
            }
            if(String.valueOf(f.ParentId).startswith(contentPrefix)){
                contentIds.add(f.ParentId);
                contentFeedIds.put(f.Id,f);
            }
            
        }
        if(learningFeedIds.size()>0 && learningIds.size()>0){
            insertDetailedHistoryForLearning();
        }
        if(contentFeedIds.size()>0 && contentIds.size()>0){
            insertDetailedHistoryForContent();
        }
    }
    
    /*Feed Item details with Parent Id as Learning Id are inserted in Detailed History Object*/  
    public void insertDetailedHistoryForLearning(){
     List<HUB_Detailed_History__c> detailedHistoryLog=new List<HUB_Detailed_History__c>();
     List<HUB_Best_Practices__c> learningList = [select Id from HUB_Best_Practices__c where Id in:learningIds];
        if(learningList.size()>0){
            for(HUB_Best_Practices__c bp: learningList){
                for(FeedItem fMap : learningFeedIds.values()){
                    if(bp.Id==fMap.ParentId){
                        HUB_Detailed_History__c newInstance=new HUB_Detailed_History__c();
                        newInstance.Best_Practices__c=fMap.ParentId;
                        newInstance.Feed_Created_Date__c=fMap.CreatedDate;
                        newInstance.Feed_Inserted_By__c=fMap.CreatedById;
                        newInstance.FeedType__c=fMap.Type;
                        newInstance.Query_Id__c=fMap.ParentId;
                        newInstance.Title__c=fMap.Title;
                        detailedHistoryLog.add(newInstance);
                    }
                }
            }
        }
        system.debug('Feed for Learning'+detailedHistoryLog);
        if(detailedHistoryLog.size()>0){
            insert detailedHistoryLog;
        }
    }
    
     /*Feed Item details with Parent Id as Case Id when deleted, a record is inserted in Detailed History Object*/  
    public void deleteFeedFromLearning(List <FeedItem> feedList){
        List<HUB_Detailed_History__c> detailedHistoryLog1=new List<HUB_Detailed_History__c>();
        for(FeedItem f: feedList){
            if(f.ParentId.getSObjectType()==HUB_Best_Practices__c.SObjectType){
                HUB_Detailed_History__c newInstance=new HUB_Detailed_History__c();
                newInstance.Best_Practices__c=f.ParentId;
                newInstance.Feed_Created_Date__c=f.CreatedDate;
                newInstance.Feed_Inserted_By__c=f.CreatedById;
                newInstance.FeedType__c=f.Type;
                newInstance.Query_Id__c=f.ParentId;
                newInstance.Title__c=f.Title+' has been deleted';
                detailedHistoryLog1.add(newInstance);
            }
        }
        if(detailedHistoryLog1.size()>0){
            insert detailedHistoryLog1;
        }
    }
    
     /*Feed Item details with Parent Id as Learnings Id is inserted in Detailed History Object*/  
    public void afterInsertLearning(List<HUB_Best_Practices__c > bestPracticeList){
     List<HUB_Detailed_History__c> detailedHistoryLog1=new List<HUB_Detailed_History__c>();
     
     for(HUB_Best_Practices__c cb: bestPracticeList){
                    HUB_Detailed_History__c log= new HUB_Detailed_History__c();
                    log.Best_Practices__c=cb.Id;
                    log.Feed_Created_Date__c=cb.CreatedDate;
                    log.Feed_Inserted_By__c=cb.CreatedById;
                    log.FeedType__c='CreatRecordEvent';
                    log.Query_Id__c=cb.Id;
                    log.Title__c=cb.Name +' has been created';
                    detailedHistoryLog1.add(log);
      }
      if(detailedHistoryLog1.size()>0)
      {
          insert detailedHistoryLog1;
      }
      
   }
   
     /*Feed Item details when a Learning is updated , a record is inserted in Detailed History Object*/  
   public void afterUpdateLearning(List<HUB_Best_Practices__c> newObj,List<HUB_Best_Practices__c> oldObj){
     List<HUB_Detailed_History__c> detailedHistoryLog1=new List<HUB_Detailed_History__c>();
     Schema.SObjectType objType = HUB_Best_Practices__c.getSObjectType(); 
     Map<String, Schema.SObjectField> M = Schema.SObjectType.HUB_Best_Practices__c.fields.getMap(); 
     
    
         try { 
        
             for(HUB_Best_Practices__c cbNew: newObj){ 
                  HUB_Detailed_History__c log= new HUB_Detailed_History__c();
                    log.Best_Practices__c=cbNew.Id;
                    log.Feed_Created_Date__c=cbNew.CreatedDate;
                    log.Feed_Inserted_By__c=cbNew.CreatedById;
                    log.FeedType__c='Field Update';
                    log.Query_Id__c=cbNew.Id;
                    log.Title__c='Field Update';
                    detailedHistoryLog1.add(log);
                  
                }
           
             if(detailedHistoryLog1.size()>0)
              {
                  insert detailedHistoryLog1;
              }
         } 
     catch (Exception e) {
          System.debug('Error: ' + e); 
     } 
 
      
      
   }
   /*************************************************************************************/
    /*Feed Item details with Parent Id as Content Id is inserted in Detailed History Object*/  
    public void afterInsertConent(List<HUB_Contents__c> contentList){
     List<HUB_Detailed_History__c> detailedHistoryLog1=new List<HUB_Detailed_History__c>();
     
     for(HUB_Contents__c cb: contentList){
                    HUB_Detailed_History__c log= new HUB_Detailed_History__c();
                    log.Content__c=cb.Id;
                    log.Feed_Created_Date__c=cb.CreatedDate;
                    log.Feed_Inserted_By__c=cb.CreatedById;
                    log.FeedType__c='CreatRecordEvent';
                    log.Query_Id__c=cb.Id;
                    log.Title__c=cb.Name +' has been created';
                    detailedHistoryLog1.add(log);
      }
      if(detailedHistoryLog1.size()>0)
      {
          insert detailedHistoryLog1;
      }
      
   }
   
   /*Feed Item details when a Content is updated , a record is inserted in Detailed History Object*/  
   public void afterUpdateContent(List<HUB_Contents__c> newObj,List<HUB_Contents__c> oldObj){
     List<HUB_Detailed_History__c> detailedHistoryLog1=new List<HUB_Detailed_History__c>();
     Schema.SObjectType objType = HUB_Contents__c.getSObjectType(); 
     Map<String, Schema.SObjectField> M = Schema.SObjectType.HUB_Contents__c.fields.getMap(); 
     
    
         try { 
             for(HUB_Contents__c cbNew: newObj){ 
                  HUB_Detailed_History__c log= new HUB_Detailed_History__c();
                    log.Content__c=cbNew.Id;
                    log.Feed_Created_Date__c=cbNew.CreatedDate;
                    log.Feed_Inserted_By__c=cbNew.CreatedById;
                    log.FeedType__c='Field Update';
                    log.Query_Id__c=cbNew.Id;
                    log.Title__c='Field Update';
                    detailedHistoryLog1.add(log);
                 
               }
             
             if(detailedHistoryLog1.size()>0)
              {
                  insert detailedHistoryLog1;
              }
         } 
     catch (Exception e) {
          System.debug('Error: ' + e); 
     } 
 
      
      
   }
   /*Insert a record in Detailed History Object whenever a Content record is created*/
   public void insertDetailedHistoryForContent(){
     List<HUB_Detailed_History__c> detailedHistoryLog=new List<HUB_Detailed_History__c>();
     List<HUB_Contents__c> contentList = [select Id from HUB_Contents__c where Id in:contentIds];
        if(contentList.size()>0){
            for(HUB_Contents__c bp: contentList ){
                for(FeedItem fMap : contentFeedIds.values()){
                    if(bp.Id==fMap.ParentId){
                        HUB_Detailed_History__c newInstance=new HUB_Detailed_History__c();
                        newInstance.Content__c=fMap.ParentId;
                        newInstance.Feed_Created_Date__c=fMap.CreatedDate;
                        newInstance.Feed_Inserted_By__c=fMap.CreatedById;
                        newInstance.FeedType__c=fMap.Type;
                        newInstance.Query_Id__c=fMap.ParentId;
                        newInstance.Title__c=fMap.Title;
                        detailedHistoryLog.add(newInstance);
                    }
                }
            }
        }
        system.debug('Feed for Learning'+detailedHistoryLog);
        if(detailedHistoryLog.size()>0){
            insert detailedHistoryLog;
        }
    }
    
    /*Insert a record in Detailed History Object whenever a Feed Item related to Content is deleted*/
    public void deleteFeedFromContent(List <FeedItem> feedList){
        List<HUB_Detailed_History__c> detailedHistoryLog1=new List<HUB_Detailed_History__c>();
        for(FeedItem f: feedList){
            if(f.ParentId.getSObjectType()==HUB_Contents__c.SObjectType){
                HUB_Detailed_History__c newInstance=new HUB_Detailed_History__c();
                newInstance.Content__c=f.ParentId;
                newInstance.Feed_Created_Date__c=f.CreatedDate;
                newInstance.Feed_Inserted_By__c=f.CreatedById;
                newInstance.FeedType__c=f.Type;
                newInstance.Query_Id__c=f.ParentId;
                newInstance.Title__c=f.Title+' has been deleted';
                detailedHistoryLog1.add(newInstance);
            }
        }
        if(detailedHistoryLog1.size()>0){
            insert detailedHistoryLog1;
        }
    }
    
   
   /*Delete feed Item for Detailed History Object*/
   @future
 public static void DeletefeedDetailedHistory(Set<Id> detailedHistoryIds){
  List<feedItem> f = [select Id from Feeditem where ParentId in:detailedHistoryIds];

  if(f.size()>0)
   {
   HUB_Validator_cls.setAlreadyDone();
    delete f;
 
    }
  }
   
}