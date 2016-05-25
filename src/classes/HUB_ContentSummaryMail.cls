public  class HUB_ContentSummaryMail extends HUB_ScheduledApexJobBase implements Database.Batchable<sObject>,  Schedulable  
   {
    private static String jobCode = 'ContentNotificationSummary';
    private Boolean execAsBatch = false;     
    public void setAsBatch(boolean flag) {
        //this.execAsBatch = flag;
    }      
    
        
    public HUB_ContentSummaryMail() {
        super(jobCode);     
    }
    
    public HUB_ContentSummaryMail(String newJobID) {
        super(newJobID);
        jobCode = newJobID;
    }
    
    public void execute(SchedulableContext sc) {
        if (this.execAsBatch) {
            Database.executeBatch(this);
        } else {       
            DateTime lastRunDate = this.lastRun;
            Database.Querylocator loc = this.start(null);// Change 1
            List<Sobject> recs = [SELECT id, Title__c,Description__c,contentType__c,End_Date__c,Date__c,Source__c,URL__c, LastModifiedBy.name, LastModifiedDate FROM HUB_Contents__c  WHERE  LastModifiedDate> :lastRunDate];
            
            this.processJob(recs);
                            
            super.finalize(); //if it will not execute it's batch procedure then call this
        }
    }   
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Access initialState here     Change 2
        return Database.getQueryLocator([SELECT id, Title__c,Description__c,contentType__c,End_Date__c,Date__c,Source__c,URL__c, LastModifiedBy.name, LastModifiedDate FROM HUB_Contents__c  WHERE LastModifiedDate> :this.lastRun]);
    }

    public void execute(Database.BatchableContext BC,  List<sObject> batch) {
        processJob(batch);
    }
    
    public void processJob(List<sObject> batch) {
        String headerLogoURL = label.HUB_EmailLinkHeaderLogo;
        String emailSupportLink = label.HUB_SupportEmailLink;
        String html = ''; 
        String htmlCommunity = '';       
        Boolean sendEmail = false;
  
        html = '<style type="text/css"> td{font-family:Calibri,Arial;} span{font-family:Calibri,Arial;} .datatable { border:1px solid #c0c0c0; border-collapse:collapse;}.datacell{border:1px solid #c0c0c0;border-collapse:collapse;font-size: 13px;font-family:Calibri;} .tdh{background-color:#c0c0c0; font-size: 13px;font-family:Calibri; border:1px solid #c0c0c0;}</style>';
        html += '<body style="font-size: 13px;font-family:Calibri"><table style="border:1px solid black;"><tr>';
        html += '<td id="header" style="width:605px;"><img src="' + headerLogoURL + '"/></td></tr><tr><td align="center" style="width:605px;"> <br/>';
        html += '<div style="font-size: 13px;font-family:Calibri;text-align:left;"><b>Update from Nexus: Here is a summary of all recently created or updated Content:</b><br/><br/></div>';
        html += '<table border="0" cellspacing="0" cellpadding="3" width="100%">';
        html += '<tr>';
        html += '<td class="tdh"><b>Title</b></td>';
        html += '<td class="tdh"><b>Description</b></td>';
        html += '<td class="tdh"><b>Source</b></td>';
        html += '<td class="tdh"><b>Content Type</b></td>';
        html += '<td class="tdh"><b>Start Date</b></td>';
        html += '<td class="tdh"><b>End Date</b></td>';
        html += '<td class="tdh"><b>Modified by</b></td>';
        html += '</tr>';
        
        htmlCommunity = html;
            // Change 3
        for (HUB_Contents__c  c: (List<HUB_Contents__c  >) batch) {
            String link = label.HUB_EmailLinkInstanceURL + c.id;
            String linkCommunity = label.HUB_EmailLinkIMCCommunityURL + c.id;
            String title = c.Title__c;
            String description = c.Description__c;
            String contentType = c.contentType__c;
            String source = c.Source__c;
            
            if (description == null) {
                description = 'None';
            }
            
            if (title == null) {
                title = 'None';
            }
            
            if(contentType == null){
                contentType = 'None';
            }
            if(source == null){
                source = 'None';
            }
            
            if (title.length() > 30) {
                title = c.Title__c==null ? '' : c.Title__c;
                title = this.truncateString(title, 30);
            }
            if (description.length() > 30) {
                description = c.Description__c==null ? '' : c.Description__c;
                description = this.truncateString(description, 30);
            }
            html +='<tr>';
            html += '<td class="datacell"><a href="' + link + '">' + title + '</a></td>';
            html +='<td class="datacell">' + description + '</td>';
            html +='<td class="datacell">' + source + '</td>';
            html +='<td class="datacell">' + contentType + '</td>';
            html +='<td class="datacell">' + String.valueOf(c.Date__c) + '</td>';
            html +='<td class="datacell">' + String.valueOf(c.End_Date__c) + '</td>';
            html +='<td class="datacell">' + c.LastModifiedBy.name + '</td>';
            html += '</tr>';
            
            htmlCommunity +='<tr>';
            htmlCommunity += '<td class="datacell"><a href="' + linkCommunity + '">' + title + '</a></td>';
            htmlCommunity +='<td class="datacell">' + description + '</td>';
            htmlCommunity +='<td class="datacell">' + source + '</td>';
            htmlCommunity +='<td class="datacell">' + contentType + '</td>';
            htmlCommunity +='<td class="datacell">' + String.valueOf(c.Date__c) + '</td>';
            htmlCommunity +='<td class="datacell">' + String.valueOf(c.End_Date__c) + '</td>';
            htmlCommunity +='<td class="datacell">' + c.LastModifiedBy.name + '</td>';
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
                query = 'select id,UserType from user where id in :recipients AND HUB_Receive_Content_Digest_Emails__c=\'Weekly\')';
            }  else {
                query = 'select id,UserType from user where (HUB_Region__c != \'\') AND (isactive=true AND email != \'\') and (HUB_Receive_Content_Digest_Emails__c=\'Weekly\')';
            }       
        
            HUB_AllUserNotificationProcessor allNotify = new HUB_AllUserNotificationProcessor(query, 'New Content added to Nexus', html, htmlCommunity, recipients);
            
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