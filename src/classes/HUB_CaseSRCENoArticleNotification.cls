/*** Author,email : Aldrin Rasdas , arasdas@coca-cola.com
* Date Create : May 28, 2013
* Description : A class that is used to send notification when Status=Respond and
*               Content Status is existing and no article is attached to the case
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
public class HUB_CaseSRCENoArticleNotification
    extends HUB_ScheduledApexJobBase
    implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
            
    static String jobCode = 'HUB_CaseSRCENoArticleNotification';
    private Boolean execAsBatch = false; 
    
    public void setAsBatch(boolean flag) {
        this.execAsBatch = flag;
    }   
        
    public HUB_CaseSRCENoArticleNotification() {
        super(jobCode);     
    }
    
    public HUB_CaseSRCENoArticleNotification(String newJobID) {
        super(newJobID);
        jobCode = newJobID;
    }
    
    public void execute(SchedulableContext sc) {
        
        if (execAsBatch) {
            Database.executeBatch(this);
        } else {
            DateTime lastRunDate = this.lastRun;
            Database.Querylocator loc = this.start(null);
            Datetime dt = System.now().addDays(-HUB_Notification.CaseStageRespondContentStatusExistingNoKALeadDay);
            dt.addHours(-HUB_Notification.CaseStageRespondContentStatusExistingNoKALeadTime);            
            //List<Sobject> recs = [Select id, Subject, OwnerId, CaseNumber, (select id from CaseArticles) From Case where (Status='Respond' AND HUB_Content_Status__c='Existing' AND HUB_SRCEStartDate__c<=:dt AND RecordType.DeveloperName = 'HUB_Issue_Tracker')];
            List<Sobject> recs = [Select id, Subject, OwnerId, CaseNumber, (select id from CaseArticles) From Case where (Status='Respond'  AND HUB_SRCEStartDate__c<=:dt AND RecordType.DeveloperName = 'HUB_Issue_Tracker')];
            
            this.processJob(recs);
                            
            super.finalize(); //if it will not execute it's batch procedure then call this          
        }       
    }   
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Access initialState here
        Datetime dt = System.now().addDays(-HUB_Notification.CaseStageRespondContentStatusExistingNoKALeadDay);
        dt.addHours(-HUB_Notification.CaseStageRespondContentStatusExistingNoKALeadTime);     
        //return Database.getQueryLocator([Select id, Subject, OwnerId, CaseNumber, (select id from CaseArticles) From Case where (Status='Respond' AND HUB_Content_Status__c='Existing' AND HUB_SRCEStartDate__c<=:dt AND RecordType.DeveloperName = 'HUB_Issue_Tracker')]);
        return Database.getQueryLocator([Select id, Subject, OwnerId, CaseNumber, (select id from CaseArticles) From Case where (Status='Respond'  AND HUB_SRCEStartDate__c<=:dt AND RecordType.DeveloperName = 'HUB_Issue_Tracker')]);
        
    }

    public void execute(Database.BatchableContext BC,  List<sObject> batch) {
        processJob(batch);
    }
    
    public void processJob(List<sObject> batch) {
        String templateId = HUB_Notification.getEmailTemplateId(label.HUB_EmailTemplateSRCENoArticleAttached); 
        List<Messaging.Singleemailmessage> emails = new List<Messaging.Singleemailmessage>();
        Messaging.Singleemailmessage email;
        for (Case ca : (List<Case>) batch) {
            if (ca.caseArticles.size()==0) {            
            system.debug('**OwnerId'+ca.OwnerId);
                email = HUB_Notification.composeEmailFromTemplate(templateId, ca.id); //new Messaging.Singleemailmessage();                
                email.setTargetObjectId(ca.OwnerId);         
                emails.add(email);
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