/*** Author,email : Aldrin Rasdas , arasdas@coca-cola.com
* Date Create : May 28, 2013
* Description : A class that is used to send notification to related users when an article is attached to a case
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
public class HUB_AttachedArticleNotification
    extends HUB_ScheduledApexJobBase
    implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
            
    static String jobCode = 'HUB_AttachedArticleNotification';
    private Boolean execAsBatch = false;
         
    public void setAsBatch(boolean flag) {
        this.execAsBatch = flag;
    }   
        
    public HUB_AttachedArticleNotification() {
        super(jobCode);     
    }
    
    public HUB_AttachedArticleNotification(String newJobID) {
        super(newJobID);
        jobCode = newJobID;
    }
    
    public void execute(SchedulableContext sc) {
        
        if (execAsBatch) {
            Database.executeBatch(this);
        } else {
            DateTime lastRunDate = this.lastRun;
            Database.Querylocator loc = this.start(null);
            List<Sobject> recs = [Select id, KnowledgeArticleId, CaseId, Case.ownerid From CaseArticle WHERE CreatedDate > :lastRunDate AND Case.RecordType.DeveloperName = 'HUB_Issue_Tracker'];
            
            this.processJob(recs);
                            
            super.finalize(); //if it will not execute it's batch procedure then call this          
        }       
    }   
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Access initialState here     
        return Database.getQueryLocator([Select id, KnowledgeArticleId, CaseId, Case.ownerid From CaseArticle WHERE CreatedDate > :this.lastRun AND Case.RecordType.DeveloperName = 'HUB_Issue_Tracker']);
    }

    public void execute(Database.BatchableContext BC,  List<sObject> batch) {
        processJob(batch);
    }
    
    public void processJob(List<sObject> batch) {
        String templateId = HUB_Notification.getEmailTemplateId(label.HUB_EmailTemplateArticleAttachedToCase);
        String templateIdForCommunity = HUB_Notification.getEmailTemplateId(label.HUB_EmailTemplateArticleAttachedToCaseCommunity);
        set<Id> userIds = new set<Id>(); 
        Map<String, String> mapIdAndType = new Map<String, String>();
        List<Messaging.Singleemailmessage> emails = new List<Messaging.Singleemailmessage>();
        Messaging.Singleemailmessage email;
        for (CaseArticle ca : (List<CaseArticle>) batch) {
            userIds.add(ca.Case.ownerid);
        }   
        for(User u : [SELECT id, name, UserType from User where id in: userIds]) {
            mapIdAndType.put(u.id, u.UserType);
        }
        
         for (CaseArticle ca : (List<CaseArticle>) batch) {
            if(mapIdAndType.get(ca.Case.OwnerId) == 'Standard'){
                email = HUB_Notification.composeEmailFromTemplate(templateId,ca.CaseId);
                email.setTargetObjectId(ca.Case.OwnerId);            
                emails.add(email);
            }else{
                email = HUB_Notification.composeEmailFromTemplate(templateIdForCommunity,ca.CaseId);
                email.setTargetObjectId(ca.Case.OwnerId);            
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