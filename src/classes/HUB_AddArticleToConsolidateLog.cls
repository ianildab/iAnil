public with sharing class HUB_AddArticleToConsolidateLog {
    
    public void AddToConsolidatedLog(){
        
                                
        set<string> attachedArticle = new set<string>();
        list<HUB_Consolidated_Log__c> lstConLog = [select id,isArticle__c, Query_Id__c from HUB_Consolidated_Log__c where isArticle__c = true and CreatedDate = today];
        List<HUB_Article_Types__c> ghubArticleTypes = HUB_Article_Types__c.getAll().values();
        List<String> ghubArticleTypesList = New List<String>();
        for(HUB_Article_Types__c article:ghubArticleTypes ){
            ghubArticleTypesList.add(article.Article_Name__c);
        }
        
        map<id,string> mapTitleID = new map<id,string> ();
            list<KnowledgeArticleVersion> KnowArticleList = [select Id, title,KnowledgeArticleId from KnowledgeArticleVersion 
            where PublishStatus=:'Online' and Language =: 'en_US' and ArticleType IN: ghubArticleTypesList];
            
            for(KnowledgeArticleVersion obj: KnowArticleList){
                mapTitleID.put(obj.KnowledgeArticleId,obj.title);
            }
        
        if(lstConLog.size() > 0){
            for(HUB_Consolidated_Log__c objConLog: lstConLog){ 
                attachedArticle.add(objConLog.Query_Id__c);
            }
            
            list<CaseArticle> lstArticle = [SELECT Id,CaseId,KnowledgeArticleId,CreatedDate,CreatedById, KnowledgeArticle.ArticleNumber FROM 
                                CaseArticle where CreatedDate = today and Id not in : attachedArticle and case.Recordtype.Developername='Issue_tracker'];
                                
            system.debug(lstArticle+'lstArticle+++');
            list<HUB_Consolidated_Log__c> lstConLogToInserted = new list<HUB_Consolidated_Log__c>();
            
            
            
            for(CaseArticle objArticle: lstArticle){
                
                HUB_Consolidated_Log__c objNewConsLog = new HUB_Consolidated_Log__c();
                objNewConsLog.Case__c = objArticle.CaseId;
                objNewConsLog.Feed_Inserted_By__c = objArticle.CreatedById;
                objNewConsLog.Feed_Created_Date__c = objArticle.CreatedDate;
                objNewConsLog.isArticle__c = true;
                objNewConsLog.Query_Id__c = objArticle.Id;
                objNewConsLog.Title__c =  mapTitleID.get(objArticle.KnowledgeArticleId) + ' has been attached'; 
                objNewConsLog.FeedType__c = 'Knowledge Article Attached';
                lstConLogToInserted.add(objNewConsLog);
                
            }
            
            if(lstConLogToInserted.size()>0 ){
                insert lstConLogToInserted;
            }
            
        }else{
            list<CaseArticle> lstArticle = [SELECT Id,CaseId,KnowledgeArticleId,CreatedDate,CreatedById FROM 
                                CaseArticle where CreatedDate = today and case.Recordtype.Developername='Issue_tracker'];
                                
            system.debug(lstArticle+'lstArticle+++');
            list<HUB_Consolidated_Log__c> lstConLogToInserted = new list<HUB_Consolidated_Log__c>();

            for(CaseArticle objArticle: lstArticle){
                
                HUB_Consolidated_Log__c objNewConsLog = new HUB_Consolidated_Log__c();
                objNewConsLog.Case__c = objArticle.CaseId;
                objNewConsLog.Feed_Inserted_By__c = objArticle.CreatedById;
                objNewConsLog.Feed_Created_Date__c = objArticle.CreatedDate;
                objNewConsLog.isArticle__c = true;
                objNewConsLog.Query_Id__c = objArticle.Id;
                objNewConsLog.Title__c = mapTitleID.get(objArticle.KnowledgeArticleId) + ' has been attached'; 
                objNewConsLog.FeedType__c = 'Knowledge Article Attached';
                lstConLogToInserted.add(objNewConsLog);
                
            }
            
            if(lstConLogToInserted.size()>0 ){
                insert lstConLogToInserted;
            }
            
            
        }
        
        
        
    }
}