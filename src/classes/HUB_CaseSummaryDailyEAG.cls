/*** Author,email : Aldrin Rasdas , arasdas@coca-cola.com
* Date Create : December 18, 2013
* Description : A class that is used to notify hub user about the latest cases created within the current period 
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
public class HUB_CaseSummaryDailyEAG   
    extends HUB_ScheduledApexJobBase
    implements Database.Batchable<sObject>,  Schedulable {
            
    private static String jobCode = 'HUB_CaseSummaryDailyEAG';
    private Boolean execAsBatch = false;     
    public void setAsBatch(boolean flag) {
        //this.execAsBatch = flag;
    }      
    
        
    public HUB_CaseSummaryDailyEAG() {
        super(jobCode);     
    }
    
    public HUB_CaseSummaryDailyEAG(String newJobID) {
        super(newJobID);
        jobCode = newJobID;
    }
    
    public void execute(SchedulableContext sc) {
        if (this.execAsBatch) {
            Database.executeBatch(this);
        } else {       
            DateTime lastRunDate = this.lastRun;
            Database.Querylocator loc = this.start(null);
            List<Sobject> recs = [SELECT id, Subject, Description, Createdby.Name, CaseNumber, Status, CreatedDate, LastModifiedDate, HUB_Risk__c, HUB_Risk_type__c, (SELECT Region__c FROM Impacted_Regions__r) FROM Case WHERE LastModifiedDate > :lastRunDate AND Id IN (SELECT Case__c FROM HUB_Impacted_Region__c WHERE Region__c = 'Eurasia & Africa')];
            
            this.processJob(recs);
                            
            super.finalize(); //if it will not execute it's batch procedure then call this
        }
    }   
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Access initialState here     
        return Database.getQueryLocator([SELECT id, Subject, Description, Createdby.Name, CaseNumber, Status, LastModifiedDate, HUB_Risk__c, HUB_Risk_type__c, (SELECT Region__c FROM Impacted_Regions__r) FROM Case WHERE LastModifiedDate> :this.lastRun AND Id IN (SELECT Case__c FROM HUB_Impacted_Region__c WHERE Region__c = 'Eurasia & Africa')]);
    }

    public void execute(Database.BatchableContext BC,  List<sObject> batch) {
        processJob(batch);
    }
    
    public void processJob(List<sObject> batch) {
        String templateId = HUB_Notification.getEmailTemplateId(label.HUB_EmailTemplateCaseCreated);
        String headerLogoURL = label.HUB_EmailLinkHeaderLogo;
        String emailSupportLink = label.HUB_SupportEmailLink;
        String html = '';     
        String htmlCommunity = '';  
        String subject = 'Daily Eurasia & Africa Digest: New cases have been added or updated to the system.';
        Boolean sendEmail = false;
  
        html = '<style type="text/css"> td{font-family:Calibri,Arial;} span{font-family:Calibri,Arial;} .datatable { border:1px solid #c0c0c0; border-collapse:collapse;}.datacell{border:1px solid #c0c0c0;border-collapse:collapse;font-size: 13px;font-family:Calibri;} .tdh{background-color:#c0c0c0; font-size: 13px;font-family:Calibri; border:1px solid #c0c0c0;}</style>';
        html += '<body style="font-size: 13px;font-family:Calibri"><table style="border:1px solid black;"><tr>';
        html += '<td id="header" style="width:605px;"><img src="' + headerLogoURL + '"/></td></tr><tr><td align="center" style="width:605px;">';
        html += '<div style="font-size: 13px;font-family:Calibri;text-align:left;"><b>Update from the Nexus Platform: A summary of all recently created or updated cases in the Eurasia & Africa region is now available.</b><br/><br/></div>';
        html += '<table border="0" cellspacing="0" cellpadding="3" width="100%">';
        html += '<tr>';
        html += '<td class="tdh"><b>Subject</b></td>';
        html += '<td class="tdh"><b>Description</b></td>';
        html += '<td class="tdh"><b>Case Designation</b></td>';
        html += '<td class="tdh"><b>Created by</b></td>';
        html += '<td class="tdh"><b>Case Number</b></td>';
        html += '<td class="tdh"><b>Date Created</b></td>';
        html += '</tr>';
        
        htmlCommunity = html; 
          
        for (Case ca : (List<Case>) batch) {
            String link = label.HUB_EmailLinkInstanceURL + ca.id;
            String linkCommunity = label.HUB_EmailLinkIMCCommunityURL + ca.id; 
            String summary = ca.Subject;
            String details = ca.Description;
            string background = ca.HUB_Risk_type__c== 'Risk' ? ca.HUB_Risk__c : '#fff';
            
            if (details == null) {
                details = '';
            }
            
            if (summary== null) {
                summary= '';
            }
            
            if (summary.length() > 30) {
                summary = ca.Subject==null ? '' : ca.Subject;
                summary = this.truncateString(summary, 30);
            }
             html +='<tr>';
            html += '<td class="datacell"><a href="' + link + '">' + summary + '</a></td>';
            html +='<td class="datacell">' + details + '</td>';
            html +='<td style="font-size: 13px;font-family:Calibri;border:1px solid #c0c0c0; border-collapse:collapse;background-color: ' + background + '">' + ca.HUB_Risk_type__c + '</td>';
            html +='<td class="datacell">' + ca.CreatedBy.name + '</td>';
            html +='<td class="datacell">' + ca.CaseNumber + '</td>';
            html +='<td class="datacell">' + String.valueOf(ca.CreatedDate) + '</td>';
            html += '</tr>';
            
                    
            htmlCommunity +='<tr>';         
            htmlCommunity += '<td class="datacell"><a href="' + linkCommunity + '">' + summary + '</a></td>';        
            htmlCommunity +='<td class="datacell">' + details + '</td>';  
            htmlCommunity +='<td style="font-size: 13px;font-family:Calibri;border:1px solid #c0c0c0; border-collapse:collapse;background-color: ' + background + '">' + ca.HUB_Risk_type__c + '</td>';       
            htmlCommunity +='<td class="datacell">' + ca.CreatedBy.name + '</td>';       
            htmlCommunity +='<td class="datacell">' + ca.CaseNumber + '</td>';       
            htmlCommunity +='<td class="datacell">' + String.valueOf(ca.CreatedDate) + '</td>';      
            htmlCommunity += '</tr>'; 
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
                query = 'select id, UserType from user where id in :recipients';
            }  else {
                query = 'SELECT id, UserType FROM user WHERE (HUB_Frequency_EAG__c = \'Daily\') AND (isactive=true AND email != \'\')';
            }       
        
            HUB_AllUserNotificationProcessor allNotify = new HUB_AllUserNotificationProcessor(query, subject, html, htmlCommunity, recipients);
            
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