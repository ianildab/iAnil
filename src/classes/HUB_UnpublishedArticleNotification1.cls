/*** Author,email : Aldrin Rasdas , arasdas@coca-cola.com
* Date Create : May 28, 2013
* Description : A class that is used to notifiy assignee of unpublished articles 
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
public class HUB_UnpublishedArticleNotification1
    extends HUB_ScheduledApexJobBase
    implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
            
    private static String jobCode = 'HUB_UnpublishedArticleNotification1';
    private Boolean execAsBatch = false;     
    public void setAsBatch(boolean flag) {
        this.execAsBatch = flag;
    }     
    
        
    public HUB_UnpublishedArticleNotification1() {
        super(jobCode);     
    }
    
    public HUB_UnpublishedArticleNotification1(String newJobID) {
        super(newJobID);
        jobCode = newJobID;
    }
    
    public void execute(SchedulableContext sc) {
        if (this.execAsBatch) {
            Database.executeBatch(this);
        } else {
        
            DateTime lastRunDate = this.lastRun;
            Database.Querylocator loc = this.start(null);
            List<Sobject> recs = [SELECT id,Title, Summary,articlenumber FROM HUB_Approved_External_Messaging__kav WHERE PublishStatus = 'Draft' AND Language = 'en_US'];
            
            this.processJob(recs);
                            
            super.finalize(); //if it will not execute it's batch procedure then call this
        }
    }   
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Access initialState here     
        return Database.getQueryLocator([SELECT id,Title, Summary,articlenumber FROM HUB_Approved_External_Messaging__kav WHERE PublishStatus = 'Draft' AND Language = 'en_US']);
    }

    public void execute(Database.BatchableContext BC,  List<sObject> batch) {
        processJob(batch);
    }
    
    public void processJob(List<sObject> batch) {
        String templateId = HUB_Notification.getEmailTemplateId(label.HUB_EmailTemplateAssignedNotPublished);            
        List<String> ids = new List<String>();
        //Select  Status, LastModifiedDate, (Select ActorId From Workitems) From ProcessInstance where targetObjectId
        List<Messaging.Singleemailmessage> emails = new List<Messaging.Singleemailmessage>();
        Messaging.Singleemailmessage email;
        Map<String, HUB_Approved_External_Messaging__kav> kavMap = new Map<String, HUB_Approved_External_Messaging__kav>(); 
        Map<String, ProcessInstance> procMap = new Map<String, ProcessInstance>();
        for (HUB_Approved_External_Messaging__kav kav : (List<HUB_Approved_External_Messaging__kav>) batch) {
            ids.add(kav.articlenumber);
            kavMap.put(kav.articlenumber, kav);
        }
        
        List<KnowledgeArticle> artIds = [select id,articlenumber from KnowledgeArticle where articlenumber in :ids];
        
        ids.clear();
        for (KnowledgeArticle ka : artIds) {
            ids.add(ka.id);
        }                   
        
        
        DateTime tday = System.now();
        tday.addDays(-HUB_Notification.ArticleAssignedNotPublishedLeadDay);
        tday.addHours(-HUB_Notification.ArticleAssignedNotPublishedLeadTime);
        
        for (ProcessInstance proc : [Select  Status, TargetObjectId, LastModifiedDate, (Select ActorId From Workitems) From ProcessInstance where targetObjectId in :ids]) {
            String ArticleId = '';
            for (KnowledgeArticle ka : artIds) {
                if (proc.TargetObjectId == ka.id) {
                    procMap.put( ka.articlenumber, proc);
                }
            }                                   
        }
        
        ProcessInstance proc;
        HUB_Approved_External_Messaging__kav kav;
        for (String id : kavMap.keySet()) {
            proc=null; kav=null;
            kav = kavMap.get(id);
            if (procMap.containsKey(id)) {
                proc = procMap.get(id);
            }
                        
            if (!(proc==null)) {
                if (proc.Status == 'Started') {
                    DateTime dt = proc.LastModifiedDate;
                    if (dt <= tday) { 
                        email = HUB_Notification.composeEmailFromTemplate(templateId, kav.id);
                        for (ProcessInstanceWorkitem wi : proc.Workitems ) {
                            email.setTargetObjectId( wi.ActorId );
                            emails.add(email);
                            break;
                        }
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