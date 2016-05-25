public with sharing class HUB_AddBestPracticeController {
    public ContentVersion attach {get;set; }
    public HUB_Best_Practices__c obj  {get;set;}
    
    public HUB_AddBestPracticeController(ApexPages.StandardController controller) {
        obj = (HUB_Best_Practices__c) controller.getRecord();
    }
    /*
    public List<ContentDocument> topContent {get;set;}
    public List<ContentDocument> getTopContent()
    {
        system.debug(topContent+'topContent--');
        return topContent;
    }

    public PageReference loadDocuments()
    {
            topContent = [select Id,Title from ContentDocument limit 10];
            system.debug(topContent.size()+'topContent+++');
         return null;
    }*/
    /*
    public List <ContentDocument> getAccountsContentDocuments () {
        Map<Id, ContentDocumentLink> m = new Map<Id, ContentDocumentLink>();
        
        for (ContentDocumentLink cl: [Select ContentDocumentId from ContentDocumentLink where LinkedEntityId =: obj.id ])
            {
                m.put(cl.ContentDocumentId, cl);
            }
            system.debug(m.keySet()+'keyset++');
            list<ContentDocument> lstContentDocument = [
                select Title, OwnerId, ParentId, PublishStatus, FileType, Id, LatestPublishedVersionId 
                from ContentDocument
                where Id in :m.keySet()
                order by Title
                ];
             
            system.debug(lstContentDocument.size()+'lstContentDocument+++++');    
            return lstContentDocument;
    }
    */
   public List <FeedItem > getFiles () {
        //Map<Id, ContentDocumentLink> m = new Map<Id, ContentDocumentLink>();
            list<FeedItem > lstContentDocument = [
                select ContentFileName, ContentType, RelatedRecordId, Title, CreatedBy.Name 
                from FeedItem 
                where ParentId  =: obj.Id and type =:'ContentPost'];
             
            system.debug(lstContentDocument.size()+'lstContentDocument+++++');    
            return lstContentDocument;
    }
    
}