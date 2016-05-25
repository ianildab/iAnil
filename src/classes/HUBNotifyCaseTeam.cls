/* This Class Sends Email Notifications to HUB Case Team Members when any Post, URL, CaseComment, Related Learning,Related Content,Related Case,etc are added to Case
 * Author       -  Sagar Madkaikar
 * Created on   -  18th Dec 2015 
 * 
*/
public class HUBNotifyCaseTeam
{
    public static Case caseObj;
    public static LIST<String> caseTeamMembersEmail = new LIST<String>();   
    public static String emailBody;
    public static String emailSubject;
    public static String childLink;
    public static Map<String,String> childTypeMap = new Map<String,String>{'TextPost' => 'Text Post' , 'LinkPost' => 'URL' ,'ContentPost' => 'File' ,'CaseComment Creation/Updation' => 'Case Comment' , 'Impacted Region Created' => 'Impacted Region' ,'Related Learning' => 'Related Learning' ,'TextPost' => 'Text Post' , 'URL Record Creation' => 'URL' , 'Related Content' => 'Related Content' , 'Related Case' => 'Related Case'};
    public static LIST<Id> contactIds = new LIST<Id>();
    private static String hubRecordType = 'HUB_Issue_Tracker';
    
    public Static void notifyCaseTeamOnInsert(LIST<HUB_Consolidated_Log__c> detailList)
    {
        for(HUB_Consolidated_Log__c details : detailList)
        {
            if(childTypeMap.containsKey(details.FeedType__c))
            {
                caseObj = [Select Id,CaseNumber,HUB_Risk_type__c,Createdby.Name,CreatedDate,Subject,HUB_Risk__c, recordType.developerName from Case where Id=:details.Case__c];
                if(caseObj.recordType.developerName.equalsIgnoreCase(hubRecordType)){
                    caseTeamMembersEmail = getCaseTeamMembersEmail(caseObj.Id);
                    emailSubject = generateSubject(details,caseObj);
                    emailBody = generateEmailBody(details,caseObj);
                    sendTemplatedEmail(caseTeamMembersEmail,emailSubject,emailBody);
                }
                              
            }
        }
    }
    
    // This method returns email ids of all the case team members related to caseId
    private Static LIST<String> getCaseTeamMembersEmail(Id caseId)
    {       
        List<String> memberEmailsList = new LIST<String>();
        
        For(CaseTeamMember c:[select Member.Email,Member.Id from CaseTeamMember where ParentId =:caseId])
        {
            if(c != null)
            {
                if(c.Member.Id!=null && Schema.Contact.SObjectType == c.Member.Id.getSobjectType())
                {
                    contactIds.add(c.Member.Id);               
                }
                else
                {
                    if(c.Member.Email!=null){memberEmailsList.add(c.Member.Email);}
                }
                
            }
        }
        for(Contact cont:[Select Email From Contact where Id IN :contactIds])
        {
            if(cont.Email !=null){memberEmailsList.add(cont.Email);}
        }       
        return memberEmailsList;
    }
    
    //This method dynamically generates email body based on the HUB_Consolidated_Log__c
    private Static String generateEmailBody(HUB_Consolidated_Log__c details,Case cObj)
    {
        
        String objectTypeName =childTypeMap.get(details.FeedType__c); 
        String border  = cObj.HUB_Risk_Type__c=='Risk'?'1px solid':'none';
        String bColor  = cObj.HUB_Risk_Type__c=='Risk'?cObj.HUB_Risk__c:'White';
        String display = cObj.HUB_Risk_Type__c=='Risk'?'':'none';
        
        String body = '<style type="text/css"> td{font-family:Calibri,Arial;} span{font-family:Calibri,Arial;} .datatable { border:1px solid #c0c0c0; border-collapse:collapse;}.datacell{border:1px solid #c0c0c0;border-collapse:collapse;font-size: 13px;font-family:Calibri;} .tdh{background-color:#c0c0c0; font-size: 13px;font-family:Calibri; border:1px solid #c0c0c0;}</style>';
        
        body += '<body style="font-size: 13px;font-family:Calibri"><table style="border:1px solid black;"><tr>';
        body += '<td id="header" style="width:605px;"><img src="' + label.HUB_EmailLinkHeaderLogo + '"/></td></tr>';
        body += '<tr><td align="center" style="width:605px;"><table><tr>';
        body += '<td style="border:'+border+';background-color:'+bColor+';text-align:center; height:20px;padding:10px;font-size: 20px;font-family:Calibri; font-weight:bold; display:'+display+';">'+ cObj.HUB_Risk__c+'</td>';
        body += '<td>&nbsp;&nbsp;&nbsp;&nbsp;</td>';
        body += '<td  style="font-size: 20px;font-family:Calibri; font-weight:bold;">CASE DESIGNATION: '+cObj.HUB_Risk_type__c +'</td>';
        body += '</tr></table></td></tr>';
        body += '<tr><td style="padding: 15px; width:585px; font-size: 13px;font-family:Calibri"><b>A Case has been updated in the Nexus Platform.</b><br/><br/>';
        body += '<b>Case Subject:</b> '+cObj.Subject+'<br/><br/>';
        body += '<b>Update:</b> '+objectTypeName+'<br/><br/>';
        if(details.FeedType__c=='Impacted Region Created')
        {
            HUB_Impacted_Region__c impactedRObj = [Select Id,Country__c from HUB_Impacted_Region__c where Id=:details.Query_Id__c];
            body += '<b>Update from the '+Label.HUB_Platform_name+': '+impactedRObj.Country__c+' has been added as an Impacted market/region to the following case.</b><br/>';
            childLink = impactedRObj.Id;
        }
        else if(details.FeedType__c=='CaseComment Creation/Updation')
        {
            childLink = cObj.Id;
        }
        else
        {
            body += 'New '+objectTypeName+' has been added to the following case.</b><br/><br/> ';
            childLink = details.Query_Id__c;
            
        }
        body += '<b>Nexus access required to view:</b><a href=" '+Label.HUB_EmailLinkInstanceURL + childLink+'">Click Here</a><br/><br/>';
        body += '<b>Created By:</b> '+cObj.Createdby.Name+'<br/>';
        body += '<b>Creation Date:</b> '+cObj.CreatedDate+'<br/>';
        body += '<b>Case Number:</b> '+cObj.CaseNumber+'<br/> <br/>';
        body += 'To view more details of this case, click <a href=" '+Label.HUB_EmailLinkInstanceURL + cObj.Id+'">here</a><br/> <br/>';
        body += 'To access the Nexus Platform, click <a href=" '+Label.HUB_EmailLinkInstanceURL + Label.HUB_emailLinkHomepageURL+'">here</a><br/> <br/>';
        body += '<b>*** DO NOT REPLY TO THIS NOTIFICATION, EMAIL BOX NOT MONITORED ***</b></td></tr>';
        body += '<tr><td style="width:605px;text-align:center; font-size: 13px;font-family:Calibri">If you see something, say something: <a href="mailto:'+Label.HUB_SupportEmailLink+'">'+Label.HUB_SupportEmailLink+'</a></td></tr>';
        body += '<tr><td id="footer" style="width:605px;background-color:#ED1E02;text-align:center; color:#fff; font-size: 13px;font-family:Calibri"> The Nexus Platform | Social Connections | The Coca-Cola Company</td></tr></table></body>';
        
        return body;
    }
    
    //This method dynamically generates email sublect line based on the HUB_Consolidated_Log__c
    private Static String generateSubject(HUB_Consolidated_Log__c details, Case cObj)
    {     
        String objectTypeName =childTypeMap.get(details.FeedType__c);       
        return 'A new '+objectTypeName+' has been added to Case '+cObj.CaseNumber;
    }
    
    // this method actually fires the email
    public static void sendTemplatedEmail(String[] toRecipients, String subject, String body)
    {
        if(toRecipients.size()>0)
        {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(toRecipients);
            email.setSubject(subject);
            email.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});          
            return;
        } 
    }  
}