/*** Author,email : Aldrin Rasdas , arasdas@coca-cola.com
* Date Create : May 28, 2013
* Description : A class that is used to notify the knowledge article author that the article he/she
*               created has just been published 
*
* REVISION HISTORY
*
* Author,email :
* Date Revised :
* Description :
*
*
* FOR HUB 1.2
*/
public class HUB_PublishedArticleNotificationSingle1
    extends HUB_ScheduledApexJobBase
    implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
            
    private static String jobCode = 'HUB_PublishedArticleNotificationSingle1';
    private Boolean execAsBatch = false;     
    public void setAsBatch(boolean flag) {
        this.execAsBatch = flag;
    }          
    
        
    public HUB_PublishedArticleNotificationSingle1() {
        super(jobCode);     
    }
    
    public HUB_PublishedArticleNotificationSingle1(String newJobID) {
        super(newJobID);
        jobCode = newJobID;
    }
    
    public void execute(SchedulableContext sc) {
        if (this.execAsBatch) {
            Database.executeBatch(this);
        } else {        
            DateTime lastRunDate = this.lastRun;
            Database.Querylocator loc = this.start(null);
            List<Sobject> recs = [SELECT Title, Summary, OwnerId FROM HUB_Approved_External_Messaging__kav WHERE PublishStatus = 'Online' AND Language = 'en_US'  AND LastPublishedDate > :lastRunDate];
            
            this.processJob(recs);
                            
            super.finalize(); //if it will not execute it's batch procedure then call this
        }
    }   
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Access initialState here     
        return Database.getQueryLocator([SELECT Title, Summary, OwnerId FROM HUB_Approved_External_Messaging__kav WHERE PublishStatus = 'Online' AND Language = 'en_US'  AND LastPublishedDate > :this.lastRun]);
    }

    public void execute(Database.BatchableContext BC,  List<sObject> batch) {
        processJob(batch);
    }
    
    public void processJob(List<sObject> batch) {
        String templateId = HUB_Notification.getEmailTemplateId(label.HUB_EmailTemplateNewArticlePublishedToOwner);
        List<Messaging.Singleemailmessage> emails = new List<Messaging.Singleemailmessage>();
        Messaging.Singleemailmessage email;
        for (HUB_Approved_External_Messaging__kav ka : (List<HUB_Approved_External_Messaging__kav>) batch) {
            email = HUB_Notification.composeEmailFromTemplate(templateId, ka.id);//new  Messaging.Singleemailmessage();
            email.setTargetObjectId(ka.OwnerId);            
            emails.add(email);
        }       
        
        if (emails.size()>0) {
            Messaging.sendEmail(emails);
        }
    }

    public void finish(Database.BatchableContext BC) {          
        super.finalize();   
    }
}