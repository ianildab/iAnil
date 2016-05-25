public class ECICCaseTriggerEmailMessageCache 
{
    @testVisible private static List<EmailMessage> webCaseEmailCache = new List<EmailMessage>();
    public  static List<EmailMessage> getWebCaseEmailList() { return webCaseEmailCache; }

    @testVisible private static List<EmailMessage> emailMessagesToInsertCache = new List<EmailMessage>();
    public static void addEmailMessageToInsertList  (EmailMessage       emailToInsertList)  { emailMessagesToInsertCache.add    (emailToInsertList);  }
    public static void addEmailMessagesToInsertList (List<EmailMessage> emailsToInsertList) { emailMessagesToInsertCache.addAll (emailsToInsertList); }

    @testVisible private static List<Messaging.SingleEmailMessage> emailMessagesToSendCache = new List<Messaging.SingleEmailMessage>();
    public static void addEmailMessageToSendList (List<String> addressList, String subject, String messageBody) 
    {
        if(Test.isRunningTest()){
          addressList= new List<String>{'from.dummy@example.com'};  
           
        }
              
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                     mail.setToAddresses(addressList);
                                     mail.setSubject(subject);
                                     mail.setPlainTextBody(messageBody);
                                     mail.saveAsActivity = false;
        emailMessagesToSendCache.add(mail);                          
    }
    public static void addEmailMessageToSendList(String addressee, String subject, String messageBody)
    {
        addEmailMessageToSendList(new List<String> {addressee}, subject, messageBody);
    }   
    
    public static void populate(List<Case> currentCaseList)
    {
       Set<Id> webCaseWithContactIdSet  = new Set<Id>();
       // filter Web originated Cases
       for (Case currentCase : currentCaseList) 
       {
            if ((currentCase.Origin == 'Web') && (currentCase.ContactId != null)) 
            {
                webCaseWithContactIdSet.add(currentCase.id);             
            }
       }
       
       List<EmailMessage> existingEmailMessageList = null;
       if (! webCaseWithContactIdSet.isEmpty())         { existingEmailMessageList = ECICEmailMessageDao.findByParentIds(webCaseWithContactIdSet); }
       if (existingEmailMessageList != null)            { webCaseEmailCache.addAll(existingEmailMessageList);                                      }
    }
    
    public static void doInsertions()
    { 
        if (!emailMessagesToInsertCache.isEmpty())
        {
            insert emailMessagesToInsertCache;
                   emailMessagesToInsertCache = new List<EmailMessage>(); // reset the list to empty so emails will not be inserted twice.
        }
    }
    
    public static List<Messaging.SendEmailResult> doSend()
    {
        List<Messaging.Email> emailToSendList      = new List<Messaging.Email>();
        Integer               emailsToSendQuantity = 0;
        
        for (Messaging.SingleEmailMessage emailMessage : emailMessagesToSendCache)
        {
            emailsToSendQuantity += emailMessage.getToAddresses().size();
            emailToSendList.add(emailMessage);
        }
        
        Messaging.reserveSingleEmailCapacity(emailsToSendQuantity);
        return Messaging.sendEmail(emailToSendList);
    }
}