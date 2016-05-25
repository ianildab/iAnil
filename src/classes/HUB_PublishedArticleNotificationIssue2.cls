/*** Author,email : Aldrin Rasdas , arasdas@coca-cola.com
* Date Create : May 28, 2013
* Description : A class that is used to send notification when the 'Issue' of a (recently)
*               published article matches a case's issue field
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
public class HUB_PublishedArticleNotificationIssue2
    extends HUB_ScheduledApexJobBase
    implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
            
    private static String jobCode = 'HUB_PublishedArticleNotificationIssue2';
    private Boolean execAsBatch = false;     
    public void setAsBatch(boolean flag) {
        this.execAsBatch = flag;
    }       
    
        
    public HUB_PublishedArticleNotificationIssue2() {
        super(jobCode);     
    }
    
    public HUB_PublishedArticleNotificationIssue2(String newJobID) {
        super(newJobID);
        jobCode = newJobID;
    }
    
    public void execute(SchedulableContext sc) {
        if (this.execAsBatch) {
            Database.executeBatch(this);    
        } else {     
        
            DateTime lastRunDate = this.lastRun;
            Database.Querylocator loc = this.start(null);
            List<Sobject> recs = [SELECT Title, Summary, (Select DataCategoryGroupName, toLabel(DataCategoryName) From DataCategorySelections) FROM HUB_Internal_Use_Only_Core_Message__kav WHERE PublishStatus = 'Online' AND Language = 'en_US'  AND LastPublishedDate > :lastRunDate];
            
            this.processJob(recs);
                            
            super.finalize(); //if it will not execute it's batch procedure then call this
        }
    }   
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Access initialState here     
        return Database.getQueryLocator([SELECT Title, Summary, (Select DataCategoryGroupName, toLabel(DataCategoryName) From DataCategorySelections) FROM HUB_Internal_Use_Only_Core_Message__kav WHERE PublishStatus = 'Online' AND Language = 'en_US'  AND LastPublishedDate > :this.lastRun]);
    }

    public void execute(Database.BatchableContext BC,  List<sObject> batch) {
        processJob(batch);
    }
    
    public void processJob(List<sObject> batch) {       
        Map<String,List<HUB_Internal_Use_Only_Core_Message__kav>> kavMap = new Map<String,List<HUB_Internal_Use_Only_Core_Message__kav>>();
        String templateId = HUB_Notification.getEmailTemplateId(label.HUB_EmailTemplateNewArticlePublishedIssueMatches1);
        List<Messaging.Singleemailmessage> emails = new List<Messaging.Singleemailmessage>();
        List<HUB_Internal_Use_Only_Core_Message__kav> kavList;// = new List<HUB_Internal_Use_Only_Core_Message__kav> (); 
        //Messaging.Singleemailmessage email;
        for (HUB_Internal_Use_Only_Core_Message__kav ka : (List<HUB_Internal_Use_Only_Core_Message__kav>) batch) {
            for (HUB_Internal_Use_Only_Core_Message__DataCategorySelection cat : ka.DataCategorySelections) {
                if (cat.DataCategoryGroupName == 'Issue') {
                    String issue = cat.DataCategoryName;
                    kavList = null;
                    if (kavMap.containsKey(issue)) {
                        kavList = kavMap.get(issue);
                    } else {
                        kavList = new List<HUB_Internal_Use_Only_Core_Message__kav> ();
                    }
                    
                    kavList.add(ka);
                    kavMap.put(issue, kavList);
                }
            }                           
        }    
        
        //List<Case> affectedCases = [select id, ownerid, HUB_Issue__c, (Select Country__c, Impacted_Region__c From Impacted_Regions__r) from Case where (HUB_Issue__c in :kavMap.keySet()) AND (HUB_Content_Status__c='Requested')];
        List<Case> affectedCases = [select id, ownerid, HUB_Issue__c, (Select Country__c, Impacted_Region__c From Impacted_Regions__r) from Case where (HUB_Issue__c in :kavMap.keySet())];
        for (Case c : affectedCases ) {
            String key = c.HUB_Issue__c;
            List<String> recipients = new List<String>();
            List<String> partialRcpts;              
            List <HUB_Internal_Use_Only_Core_Message__kav> kas = kavMap.get(key);
            for (HUB_Impacted_Region__c reg: c.Impacted_Regions__r) {
                if (reg.Impacted_Region__c != '') {
                    if (reg.Country__c != '') {
                        partialRcpts = HUB_Notification.getCountryCaseManagerIdsList( reg.Country__c);
                        
                        if (partialRcpts.size()>0) {
                            recipients.addAll(partialRcpts);
                        }
                    }                       
                }
            }
            
            Messaging.Singleemailmessage email;
            recipients.add( c.OwnerId );
            for (HUB_Internal_Use_Only_Core_Message__kav kav : kas) {
                /*for (String recipient : recipients) {
                    email = new Messaging.Singleemailmessage();
                    email.setTemplateId(templateId);
                    email.setTargetObjectId(recipient);
                    email.setWhatId(kav.id);
                    email.setSaveAsActivity(false);
                    emails.add(email);          
                } */
                
                emails.addall( HUB_Notification.prepareIndividualMails(recipients, kav.id, templateId));               
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