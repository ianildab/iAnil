/*** Author,email : Aldrin Rasdas , arasdas@coca-cola.com
* Date Create : May 28, 2013
* Description : A class that is used to notify hub user about the latest articles published within the current period 
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
public class HUB_PublishedArticleNotificationSummary1
    extends HUB_ScheduledApexJobBase
    implements Database.Batchable<sObject>,  Schedulable {
            
    private static String jobCode = 'HUB_PublishedArticleNotificationSummary1';
    private Boolean execAsBatch = false;     
    public void setAsBatch(boolean flag) {
        //this.execAsBatch = flag;
    }      
    
        
    public HUB_PublishedArticleNotificationSummary1() {
        super(jobCode);     
    }
    
    public HUB_PublishedArticleNotificationSummary1(String newJobID) {
        super(newJobID);
        jobCode = newJobID;
    }
    
    public void execute(SchedulableContext sc) {
        if (this.execAsBatch) {
            Database.executeBatch(this);
        } else {       
            DateTime lastRunDate = this.lastRun;
            Database.Querylocator loc = this.start(null);
            List<Sobject> recs = [SELECT id, Title, LastModifiedBy.name, LastPublishedDate, Summary, OwnerId FROM HUB_Approved_External_Messaging__kav WHERE PublishStatus = 'Online' AND Language = 'en_US'  AND LastPublishedDate > :lastRunDate];
            
            this.processJob(recs);
                            
            super.finalize(); //if it will not execute it's batch procedure then call this
        }
    }   
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Access initialState here     
        return Database.getQueryLocator([SELECT id, Title, LastModifiedBy.name, LastPublishedDate, Summary, OwnerId FROM HUB_Approved_External_Messaging__kav WHERE PublishStatus = 'Online' AND Language = 'en_US'  AND LastPublishedDate > :this.lastRun]);
    }

    public void execute(Database.BatchableContext BC,  List<sObject> batch) {
        processJob(batch);
    }
    
    public void processJob(List<sObject> batch) {
        String templateId = HUB_Notification.getEmailTemplateId(label.HUB_EmailTemplateNewArticlePublishedToOwner);
        String headerLogoURL = label.HUB_EmailLinkHeaderLogo;
        String emailSupportLink = label.HUB_SupportEmailLink;
        String html = ''; 
        String htmlCommunity = '';       
        Boolean sendEmail = false;
  
        html = '<style type="text/css"> td{font-family:Calibri,Arial;} span{font-family:Calibri,Arial;} .datatable { border:1px solid #c0c0c0; border-collapse:collapse;}.datacell{border:1px solid #c0c0c0;border-collapse:collapse;font-size: 13px;font-family:Calibri;} .tdh{background-color:#c0c0c0; font-size: 13px;font-family:Calibri; border:1px solid #c0c0c0;}</style>';
        html += '<body style="font-size: 13px;font-family:Calibri"><table style="border:1px solid black;"><tr>';
        html += '<td id="header" style="width:605px;"><img src="' + headerLogoURL + '"/></td></tr><tr><td align="center" style="width:605px;">';
        html += '<div style="font-size: 13px;font-family:Calibri;text-align:left;"><b>Update from Nexus: Here is a summary of all recently published Knowledge Articles:</b><br/><br/></div>';
        html += '<table border="0" cellspacing="0" cellpadding="3" width="100%">';
        html += '<tr>';
        html += '<td class="tdh"><b>Title</b></td>';
        html += '<td class="tdh"><b>Summary</b></td>';
        html += '<td class="tdh"><b>Date Published</b></td>';
        html += '<td class="tdh"><b>Published By</b></td>';
        html += '</tr>';
        
        htmlCommunity = html;
          
        for (HUB_Approved_External_Messaging__kav ka : (List<HUB_Approved_External_Messaging__kav>) batch) {
            String link = label.HUB_EmailLinkInstanceURL + ka.id;
            String linkCommunity = label.HUB_EmailLinkIMCCommunityURL + ka.id;
            String title = ka.Title;
            String summary = ka.summary;
            
            if (summary == null) {
                summary = 'None';
            }
            
            if (title == null) {
                title = '';
            }
            
            if (title.length() > 30) {
                title = ka.Title==null ? '' : ka.Title;
                title = this.truncateString(title, 30);
            }
            html +='<tr>';
            html += '<td class="datacell"><a href="' + link + '">' + title + '</a></td>';
            html +='<td class="datacell">' + summary + '</td>';
            html +='<td class="datacell">' + String.valueOf(ka.LastPublishedDate) + '</td>';
            html +='<td class="datacell">' + ka.LastModifiedBy.name + '</td>';
            html += '</tr>';
            
            htmlCommunity +='<tr>';
            htmlCommunity += '<td class="datacell"><a href="' + linkCommunity + '">' + title + '</a></td>';
            htmlCommunity +='<td class="datacell">' + summary + '</td>';
            htmlCommunity +='<td class="datacell">' + String.valueOf(ka.LastPublishedDate) + '</td>';
            htmlCommunity +='<td class="datacell">' + ka.LastModifiedBy.name + '</td>';
            htmlCommunity += '</tr>';
            sendEmail = true;
        }               
        html +='</table></td></tr>';
        htmlCommunity +='</table></td></tr>';
        
        html +='<tr><td align="center" style="font-size: 13px;font-family:Calibri"><br/><b>*** DO NOT REPLY TO THIS NOTIFICATION, EMAIL BOX NOT MONITORED ***</b></td></tr>';
        htmlCommunity +='<tr><td align="center" style="font-size: 13px;font-family:Calibri"><br/><b>*** DO NOT REPLY TO THIS NOTIFICATION, EMAIL BOX NOT MONITORED ***</b></td></tr>';
        
        html += '<tr><td style="width:605px;text-align:center; font-size: 13px;font-family:Calibri"><br/><br/>If you see something, say something: <a href="mailto:' + emailSupportLink + '">' + emailSupportLink + '</a></td></tr>';
        htmlCommunity += '<tr><td style="width:605px;text-align:center; font-size: 13px;font-family:Calibri"><br/><br/>If you see something, say something: <a href="mailto:' + emailSupportLink + '">' + emailSupportLink + '</a></td></tr>';
        
        html +='<tr><td id="footer" style="width:605px;background-color:#ED1E02;text-align:center; color:#fff; font-size: 13px;font-family:Calibri">The Nexus Network | Social Connections | The Coca-Cola Company</td></tr>';
        htmlCommunity +='<tr><td id="footer" style="width:605px;background-color:#ED1E02;text-align:center; color:#fff; font-size: 13px;font-family:Calibri">The Nexus Network | Social Connections | The Coca-Cola Company</td></tr>';
        
        html +='</table>';
        htmlCommunity +='</table>';
        
        if (sendEmail) {     
    
            List <String> recipients;
            String query = ''; 
            String allUsersGroup = '';
            if (allUsersGroup!='') {
                recipients = HUB_Notification.getGroupMemberUserData(allUsersGroup, 'id');
                query = 'select id,UserType from user where id in :recipients';
            }  else {
                query = 'select id,UserType from user where (HUB_Region__c != \'\') AND (isactive=true AND email != \'\')';
            }       
        
            HUB_AllUserNotificationProcessor allNotify = new HUB_AllUserNotificationProcessor(query, label.HUB_EmailArticleSummarySubjectLine, html, htmlCommunity, recipients);
            
            if (!Test.IsRunningTest()) {
              Database.executeBatch(allNotify, 200);               
              //allNotify.execute(null, [select id from user where id=:userInfo.getUserId() AND (isactive=true AND email != '')]);
            }
        }
        
    }

    public void finish(Database.BatchableContext BC) {          
        super.finalize();   
    }
    
    private String truncateString(String s, Integer len) {
        String v = s;
        Boolean goodTruncate = false;
        
        if (v.length()>len) {
            if (v.substring(len,len+1)==' ') {
                goodTruncate = true;
            } 
            
            v = v.substring(0,len);         
            if (!goodTruncate) {
                List<String> v2 = new List<String>();
                List<String> parts = v.split(' ');
                Integer count = parts.size()-1;
                for (Integer i=0; i<count; i++) {
                    v2.add(parts[i]);
                }
                
                v = String.join(v2,' ');                
            }
            v+='...';
        }
        
        return v;
    }
}