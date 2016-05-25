public class ECICCaseEmailMessageCreatorStrategy extends ECICCaseProcessingStrategyAbstract 
{
    @testVisible private class WebCaseData
    {
       	@testVisible private Map<ID, Case> webCaseByIdMap      = new Map<ID, Case>();
       	@testVisible private Set<ID>       webCaseContactIdSet = new Set<ID>();
    }

	@testVisible private List<EmailMessage> existingEmailMessages = null;
    @testVisible private Map<ID, Contact>   webCaseContactByIdMap = null; 

    public override boolean OnAfterInsert(Map<ID, sObject> newValuesMap) 
    {
        createEmailMessagesForWebCases((List<Case>)newValuesMap.values());
        return true;
    }

    @testVisible private void createEmailMessagesForWebCases(List<Case> newCaseList) 
    {
       WebCaseData 		  webCaseData 		  = filterWebCases(newCaseList);
       Map<ID, Case>      webCaseByIdMap      = webCaseData.webCaseByIdMap;
       Set<ID>            webCaseContactIdSet = webCaseData.webCaseContactIdSet;
       
       if (! webCaseByIdMap.isEmpty()) 
       {
            existingEmailMessages = ECICCaseTriggerEmailMessageCache.getWebCaseEmailList();
            webCaseContactByIdMap = ECICCaseTriggerContactCache.getWebCaseContactByIdMap(); 

            for (Case currentCase : webCaseByIdMap.values()) 
            {
            	createEmailMessageForWebCase(currentCase);
            }
        }
    }

    @testVisible private void createEmailMessageForWebCase(Case currentCase)
    {
                // Try to avoid creating duplicates...
                // This step is NOT obsolote as the custom ECIC email2case can create Cases with Origin = 'Web'
                // where a real incoming email is attached to the new Case.
        if (! hasEmailByCaseIdAndSubject(currentCase.id, currentCase.Subject)) 
                {
                    if ((currentCase.contactId != null) && (webCaseContactByIdMap.containsKey(currentCase.contactId))) 
                    {
                        Contact contact = webCaseContactByIdMap.get(currentCase.contactId);  
              
                        EmailMessage newEmail = new EmailMessage();                    
                        newEmail.Incoming       = true;
                        newEmail.parentId       = currentCase.id;
                        newEmail.FromAddress    = contact.Email;
                        newEmail.Subject        = currentCase.Subject;
                        newEmail.TextBody = currentCase.Description;
                        newEmail.MessageDate    = System.now();
                        newEmail.Status         = '0'; // set status = 'New'
                
                ECICCaseTriggerEmailMessageCache.addEmailMessageToInsertList(newEmail);
            } 
            else 
            {
                        System.debug(LoggingLevel.WARN, '----- No email attachement created for Case ['+currentCase.id+'] as Contact is empty.');
                    }
                }
            }
  
  	@testVisible private WebCaseData filterWebCases(List<Case> caseList)
            {
  		WebCaseData webCaseData = new WebCaseData();
        for (Case currentCase : caseList) 
        {
             if ((currentCase.Origin == 'Web') && (currentCase.ContactId != null)) 
             {
                 webCaseData.webCaseByIdMap.put(currentCase.id, currentCase);
                 webCaseData.webCaseContactIdSet.add(currentCase.ContactId);
             }
        }
        return webCaseData;
  	}
    
    @testVisible private boolean hasEmailByCaseIdAndSubject(ID caseId, String subject) {
        boolean result = false;
       
        for (EmailMessage email : existingEmailMessages) {
            if (email.parentId == caseId
               && email.subject == subject) {
                    
                result = true;
                break;
            }
       }
       
       return result;
    }
}