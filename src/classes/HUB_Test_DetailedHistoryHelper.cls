@isTest
public class HUB_Test_DetailedHistoryHelper {
static testMethod void testHubDetailedHistoryHelper(){
     HUB_Best_Practices__c bp=new HUB_Best_Practices__c(Description__c='test class',Learning_Type__c='Report',Title__c='test class');
     insert bp;
    
     List<FeedItem> addFeeds=new List<FeedItem>();
     FeedItem post = new FeedItem();
     post.ParentId =bp.id;
     post.Body = 'HUB Test Class';
     post.createdById =UserInfo.getUserId();
     addFeeds.add(post);
     insert addFeeds; 
     system.assert(addFeeds.size()!=0);
    
    List<HUB_Detailed_History__c> detailedHistoryLog=new List<HUB_Detailed_History__c>();
    for(FeedItem f: addFeeds){
        HUB_Detailed_History__c newInstance=new HUB_Detailed_History__c();
        newInstance.Best_Practices__c=f.ParentId;
        newInstance.Feed_Created_Date__c=f.CreatedDate;
        newInstance.Feed_Inserted_By__c=f.CreatedById;
        newInstance.FeedType__c=f.Type;
        newInstance.Query_Id__c=f.ParentId;
        newInstance.Title__c=f.Title;
        detailedHistoryLog.add(newInstance);
    }
    system.assert(detailedHistoryLog.size()!=0);
    
    if(detailedHistoryLog.size()>0){
            insert detailedHistoryLog;
        }
    HUB_DetailedHistoryHelper helperInstance=new HUB_DetailedHistoryHelper();
    helperInstance.deleteFeedFromLearning(addFeeds);
    
  }
}