/*** Author,email : Aldrin Rasdas , arasdas@coca-cola.com
* Date Create : May 28, 2013
* Description : A class that is used to send notification to all hubs users. Sending is batched.
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
public class HUB_AllUserNotificationProcessor  
    implements Database.Batchable<sObject> {
        
    private String pQuery = '';
    private String pTemplateId = '';
    private sObject pObject = null;
    private List<String> recipients;
    private String pSubject = '';
    private String pHTML = '';
    private String pHTMLCommunity = '';
    private String pTemplateIdCommunity = '';
        
    public HUB_AllUserNotificationProcessor(String query, String templateId, sObject targetObject, List<String> rcpt) {
        this.pQuery = query;
        this.pTemplateId = templateId;
        this.pObject = targetObject;
        this.recipients = rcpt;
    }
    
    public HUB_AllUserNotificationProcessor(String query, String templateId,String templateIdCommunity, sObject targetObject, List<String> rcpt) {
        this.pQuery = query;
        this.pTemplateId = templateId;
        this.pObject = targetObject;
        this.recipients = rcpt;
        this.pTemplateIdCommunity = templateIdCommunity;
    }
    
    public HUB_AllUserNotificationProcessor(String query, String subject, String htmlContent, List<String> rcpt) {
        this.pQuery = query;
        this.pSubject = subject;
        this.pHTML = htmlContent;
        this.recipients = rcpt;
    }
    
    
    
    public HUB_AllUserNotificationProcessor(String query, String subject, String htmlContent, String htmlContentCommunity, List<String> rcpt) {
        this.pQuery = query;
        this.pSubject = subject;
        this.pHTML = htmlContent;
        this.pHTMLCommunity = htmlContentCommunity;
        this.recipients = rcpt;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Access initialState here         
        if (this.pQuery != '') {
            return Database.getQueryLocator(this.pQuery);
        } else {
            return Database.getQueryLocator( [select id, UserType from user where lastname='' limit 1]);          
        }
    }

    public void execute(Database.BatchableContext BC,  List<sObject> batch) {
        List<String>rcpts = new List<String>();
        List<Messaging.Singleemailmessage> emails = new List<Messaging.Singleemailmessage>();
        Messaging.Singleemailmessage mail;
        
        Map<Id, String> mapUserIdVsType = new Map<Id, String>();
        for (User u : (User[]) batch) {
            rcpts.add(u.id);
            mapUserIdVsType.put(u.Id, u.UserType);
        }
        
        rcpts = HUB_Notification.UniqueStringList(rcpts);
        
        if (this.pObject==null) {
            for (String id : rcpts) {
                mail = HUB_Notification.composeEmailFromTemplate(null, null);//new Messaging.Singleemailmessage();
                mail.setSubject( this.pSubject);
                mail.setSaveAsActivity(false);
                mail.setTargetObjectId(id);
                
                if(pHTMLCommunity != '' && mapUserIdVsType.get(id) != 'Standard'){
                    mail.setHtmlBody( this.pHTMLCommunity);
                }else{
                    mail.setHtmlBody( this.pHTML);
                }
                
                emails.add(mail);
            }
            
            if (emails.size()>0) {
                Messaging.sendEmail(emails);
            }
            
        } else {
             List<String> recipientsStandard = new List<String>();
             List<String> recipientsCommunity = new List<String>();
            for(String id : rcpts){
                    if(mapUserIdVsType.get(id) != 'Standard'){
                        recipientsStandard.add(id);
                        
                    }else{
                        recipientsCommunity.add(id);
                        
                    }
                 }
            HUB_Notification.sendNotificationToList(recipientsStandard, this.pObject.id, this.pTemplateId);
            HUB_Notification.sendNotificationToList(recipientsCommunity, this.pObject.id, this.pTemplateIdCommunity);
            //HUB_Notification.sendNotificationToList(rcpts, this.pObject.id, this.pTemplateId);
        }       
    }

    public void finish(Database.BatchableContext BC) {
        //would we add something here?
    }
}