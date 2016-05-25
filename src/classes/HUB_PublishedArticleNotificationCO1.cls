/*** Author,email : Aldrin Rasdas , arasdas@coca-cola.com
* Date Create : May 28, 2013
* Description : A class that is used to send notification when a Content Origin of a (recently)
*               published article matches the case owner's country
* REVISION HISTORY
*
* Author,email :
* Date Revised :
* Description :
*
*
* FOR HUB 1.2
*/
public class HUB_PublishedArticleNotificationCO1
    extends HUB_ScheduledApexJobBase
    implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
            
    private static String jobCode = 'HUB_PublishedArticleNotificationCO1';
    private Boolean execAsBatch = false;     
    public void setAsBatch(boolean flag) {
        this.execAsBatch = flag;
    }     
    
        
    public HUB_PublishedArticleNotificationCO1() {
        super(jobCode);     
    }
    
    public HUB_PublishedArticleNotificationCO1(String newJobID) {
        super(newJobID);
        jobCode = newJobID;
    }
    
    public void execute(SchedulableContext sc) {
        if (this.execAsBatch) {
            Database.executeBatch(this);
        } else {
        
            DateTime lastRunDate = this.lastRun;
            Database.Querylocator loc = this.start(null);
            List<Sobject> recs = [SELECT Title, Summary, (Select DataCategoryGroupName, toLabel(DataCategoryName) From DataCategorySelections) FROM HUB_Approved_External_Messaging__kav WHERE PublishStatus = 'Online' AND Language = 'en_US'  AND LastPublishedDate > :lastRunDate];
            
            this.processJob(recs);
                            
            super.finalize(); //if it will not execute it's batch procedure then call this
        }
    }   
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Access initialState here     
        return Database.getQueryLocator([SELECT Title, Summary, (Select DataCategoryGroupName, toLabel(DataCategoryName) From DataCategorySelections) FROM HUB_Approved_External_Messaging__kav WHERE PublishStatus = 'Online' AND Language = 'en_US'  AND LastPublishedDate > :this.lastRun]);
    }

    public void execute(Database.BatchableContext BC,  List<sObject> batch) {
        processJob(batch);
    }
    
    public void processJob(List<sObject> batch) {       
        Map<String,List<HUB_Approved_External_Messaging__kav>> kavMap = new Map<String,List<HUB_Approved_External_Messaging__kav>>();
        String templateId = HUB_Notification.getEmailTemplateId(label.HUB_EmailTemplateNewArticlePublishedRelatedConOrg);
        String templateIdCommunity = HUB_Notification.getEmailTemplateId(label.HUB_EmailTemplateNewArticlePublishedRelatedConOrgCommunity);
        
        List<Messaging.Singleemailmessage> emails = new List<Messaging.Singleemailmessage>();
        List<HUB_Approved_External_Messaging__kav> kavList;// = new List<HUB_Approved_External_Messaging__kav> (); 
        for (HUB_Approved_External_Messaging__kav ka : (List<HUB_Approved_External_Messaging__kav>) batch) {
            for (HUB_Approved_External_Messaging__DataCategorySelection cat : ka.DataCategorySelections) {
                if (cat.DataCategoryGroupName == 'Content_Origin') {
                    String market = cat.DataCategoryName;
                    kavList = null;
                    if (kavMap.containsKey(market)) {
                        kavList = kavMap.get(market);
                    } else {
                        kavList = new List<HUB_Approved_External_Messaging__kav> ();
                    }
                                
                    
                    kavList.add(ka);
                    kavMap.put(market, kavList);
                }
            }                           
        }    
        
        Map<String, String> mapIdAndType = new Map<String, String>();
        List<String> recipientsStandard = new List<String>();
        List<String> recipientsCommunity = new List<String>();
        for (String key : kavMap.keySet()) {
            mapIdAndType = HUB_Notification.getCountryUserIds(key);
            
             for(String id : mapIdAndType.keySet()){
                 	if(mapIdAndType.get(id) == 'Standard'){
                 		recipientsStandard.add(id);
                 	}else{
                 		recipientsCommunity.add(id);
                 	}
                 }
            
            if (recipientsStandard.size()>0) { //check first if we got some crowd...
                List <HUB_Approved_External_Messaging__kav> kas = kavMap.get(key);
                
                Messaging.Singleemailmessage email;
                for (HUB_Approved_External_Messaging__kav kav : kas) {
                    List<Messaging.Singleemailmessage> partialMails = HUB_Notification.prepareIndividualMails(recipientsStandard, kav.id, templateId);
                    if (partialMails.size()>0) {
                        emails.addAll(partialMails);
                    }                     
                }                   
            }  
            
            if (recipientsCommunity.size()>0) { //check first if we got some crowd...
                List <HUB_Approved_External_Messaging__kav> kas = kavMap.get(key);
                
                Messaging.Singleemailmessage email;
                for (HUB_Approved_External_Messaging__kav kav : kas) {
                    List<Messaging.Singleemailmessage> partialMails = HUB_Notification.prepareIndividualMails(recipientsCommunity, kav.id, templateIdCommunity);
                    if (partialMails.size()>0) {
                        emails.addAll(partialMails);
                    }                     
                }                   
            }               
        }                   
        
        if (emails.size()>0) {
            Messaging.sendEmail(emails);
        }
    }

    public void finish(Database.BatchableContext BC) {          
        super.finalize();   
    }
}