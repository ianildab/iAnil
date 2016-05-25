public class SEPEmailSendHelper 
{
    public static Messaging.SingleEmailMessage createMail(sObject currentSObject, Id templateId, String[] addressArray, Id targetUserId) 
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage ();
                                     mail.settoAddresses(addressArray); 
                                     mail.setTargetObjectId(targetUserId);   //setting this field is workaround to support email template. If it's not defined template can not be used.
                                     mail.setTemplateID(templateId);
                                     mail.setWhatId(currentSObject.id);
                                     mail.setorgWideEmailAddressId(General_Settings__c.getInstance().Org_Wide_Email_Address__c);
                                     mail.setSaveAsActivity (false);
                              return mail;
    }

    public static Messaging.SingleEmailMessage createNotificationMail (List<String> addressList, String subject, String messageBody, Boolean useHTMLBody, LoggingLevel loggingLevel, String logPrefix)
    {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                     email.setToAddresses(addressList);
                                     email.setSubject(subject);
                                     
        if (useHTMLBody) {           email.setHtmlBody(messageBody);      }
        else             {           email.setPlainTextBody(messageBody); }
        
                                     email.saveAsActivity = false;
                              return email;
    }

    public static Messaging.SingleEmailMessage createNotificationMail (List<String> addressList, String subject, String messageBody)
    {
    	return createNotificationMail(addressList, subject, messageBody, false, null, null);
    }
        
    //-------------------------------------------------------------------------------------------------------------------------    

    private static Map<Id, User> getUserMapForSpecifiedIds(Set<Id> allrecipientUserIdSet) 
    {
        if ((allrecipientUserIdSet != null) && (!allrecipientUserIdSet.isEmpty()))
        {
            return new Map<ID, User>([SELECT email FROM User WHERE Id IN :allrecipientUserIdSet ]);
        }
        
        return null;
    } 

    public static List<Messaging.Email> collectRecipientsAddressesAndCreateMails(Map<sObject, Set<Id>> recipientsIdSetBySOBjectMap,  Set<Id> allRecipientIdSet, ID templateId) 
    {
        Set<sObject>          sObjectSet   = recipientsIdSetBySOBjectMap.keySet();
        Map<Id, User>         usersByIdMap = getUserMapForSpecifiedIds(allRecipientIdSet); 

        List<Messaging.Email> mailList        = new List<Messaging.Email>();
        for (sObject currentSObject : sObjectSet) 
        {
            Set<Id>     recipientUserIdSet = recipientsIdSetBySOBjectMap.get(currentSObject);
            Id          targetUserId       = ((recipientUserIdSet != null) && (!recipientUserIdSet.isEmpty())) 
                                                ? ((new List<Id> (recipientUserIdSet))[0]) 
                                                : ((Id) currentSObject.get('ownerId'));

            Set<String> addressSet         = buildAddressSet(usersByIdMap, recipientUserIdSet, (String) currentSObject.get('Additional_To__c'));
            if (!addressSet.isEmpty())  { mailList.add(createMail(currentSObject, templateId, new List<String>(addressSet), targetUserId)); }
        }

        return mailList;
    }   

    private static Set<String> buildAddressSet(Map<Id, User> usersByIdMap, Set<Id> recipientUserIdSet, String additionalToAddresses)
    {
        Set<String> addressSet = new Set<String>();
        if (((recipientUserIdSet != null) && (!recipientUserIdSet.isEmpty()))) { addressSet.addAll(buildAddressSet(usersByIdMap, recipientUserIdSet));           }
        if (String.isNotEmpty(additionalToAddresses))                          { addressSet.addAll(additionalToAddresses.split(ECICCommonConstants.SEMICOLON));  } 

        //TODO: validate email addresses.

        return addressSet;    	
    }

    private static Set<String> buildAddressSet(Map<Id, User> usersByIdMap, Set<Id> recipientUserIdSet)
    {
        Set<String> addressSet = new Set<String>();
        for (Id recipientUserId : recipientUserIdSet) 
        {
            if (usersByIdMap.containsKey(recipientUserId)) {  addressSet.add(usersByIdMap.get(recipientUserId).email); } 
            else { System.debug (LoggingLevel.ERROR, '!!!!!!!! recipientUserId' + recipientUserId + ' is not in usersByIdMap.'); }
        }
        return addressSet;      
    }
    
    // ------------------------------------------------------------------------------------------------------------------------
    
    public static List<Messaging.SendEmailResult> sendMails(List<Messaging.Email> emailList, boolean allOrNone) 
    {
        Messaging.reserveSingleEmailCapacity(emailList.size());
    	
        List<Messaging.SendEmailResult> resultList = null;
        
        try                            { resultList = Messaging.sendEmail(emailList, allOrNone);                }
        catch(DmlException e)          { System.debug(LoggingLevel.ERROR, '!!!!!!!!! ' + e.getMessage());       }
        catch(System.EmailException e) { System.debug(LoggingLevel.ERROR, '!!!!!!!!! ' + e.getMessage());       }

        if (Test.isRunningTest()) { cacheResults(resultList); }

        return resultList;
    }
    
    public static List<Messaging.SendEmailResult> sendMails(List<Messaging.SingleEmailMessage> emailList, boolean allOrNone) 
    {
        Messaging.reserveSingleEmailCapacity(emailList.size());
        
        List<Messaging.SendEmailResult>  resultList = null;
        try                            { resultList = Messaging.sendEmail(emailList, allOrNone);                             }
        catch(DmlException e)          { System.debug(LoggingLevel.ERROR, '!!!!!!!!! ' + e.getMessage());       }
        catch(System.EmailException e) { System.debug(LoggingLevel.ERROR, '!!!!!!!!! ' + e.getMessage());       }

        if (Test.isRunningTest()) { cacheResults(resultList); }
        	
        return resultList;
    }

    private static void cacheResults(List<Messaging.SendEmailResult> resultList)
    {
        Integer i=0;
        for (Messaging.SendEmailResult result : resultList)
        {
            TEST_MockHelper.setMockBoolean('sendEmailResult['+i+']', 'isSuccess', result.isSuccess());
            TEST_MockHelper.setMockString ('sendEmailResult['+i+']', 'errors',    String.valueOf(result.getErrors()));
            i++;
        }
    }

    public static void sendMails(List<Messaging.Email> emailList) 
    {
        List<Messaging.SendEmailResult> resultList = sendMails(emailList, false);
        reportEmailFailures (emailList, resultList);
    }
    
    public static void sendMails(List<Messaging.SingleEmailMessage> emailList) 
    {
        List<Messaging.SendEmailResult> resultList = sendMails(emailList, false);
        reportEmailFailures (emailList, resultList);
    }

    // ------------------------------------------------------------------------------------------------------------------------
    
    private static void reportEmailFailures (List<Messaging.Email> emailList, List<Messaging.SendEmailResult> resultList)
    {
        Integer emailIndex   = 0;
        String  failedEmailSendResultString = '';
        
        for (Messaging.SendEmailResult result : resultList) 
        {
            if (!result.isSuccess())  
            {   
                System.debug(LoggingLevel.ERROR, '!!!!!!! Messaging.SendEmailResult FAIL :' + result);
                failedEmailSendResultString += getFailedResultString((Messaging.SingleEmailMessage) emailList.get(emailIndex++)); 
            }  
        }
        
        if (String.isNotEmpty(failedEmailSendResultString)) { sendFailedEmailNotificationToSupport(failedEmailSendResultString); }
    }


    private static String getFailedResultString(Messaging.SingleEmailMessage email)
    {
       return String.format (
                                'Object Id={0}; Recipients={1}; Target Recipient Id={2};<br/>', 
                                new String[]
                                {
                                    '<a href=' + General_Settings__c.getInstance().Host__c + '/' + email.WhatId + '>' + email.WhatId + '</a>', 
                                    String.valueOf(email.toAddresses), 
                                    String.valueOf(email.TargetObjectId)
                                }
                             );
    }

    // ------------------------------------------------------------------------------------------------------------------------

    public static void sendNotificationMail(List<String> addressList, String subject, String messageBody, Boolean useHTMLBody, LoggingLevel loggingLevel, String logPrefix)
    {
        Messaging.reserveSingleEmailCapacity(1);
        Messaging.SingleEmailMessage email = createNotificationMail (addressList, subject, messageBody, useHTMLBody, loggingLevel, logPrefix);
                                     
        if (loggingLevel != null) { System.debug (loggingLevel, logPrefix + email); }
        
        sendMails(new List<Messaging.SingleEmailMessage> { email }, false);
    } 
    
    // @see http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_forcecom_email_outbound.htm
    public static void sendNotificationMail(List<String> addressList, String subject, String messageBody) 
    {
    	sendNotificationMail(addressList, subject, messageBody, false, null, null);
    }
    
    public static void sendNotificationMail(String addressee, String subject, String messageBody)
    {
        sendNotificationMail(new List<String> {addressee}, subject, messageBody, false, null, null);
    }

    private static void sendFailedEmailNotificationToSupport(String failedEmailSendResultString)
    {
        String addressList = General_Settings__c.getInstance().supportEmail__c;
        if (String.isEmpty(addressList)) 
        { 
            System.debug (LoggingLevel.ERROR, '!!!!! General_Settings__c.getInstance().supportEmail__c not set.');
            return; 
        }
        
        String subject = 'The following emails cannot be delivered';
        sendNotificationMail((new List<String> { addressList }), (subject), (subject + ':<br/>' + failedEmailSendResultString), true, Logginglevel.ERROR, '---- Failed emails: ');
    }

    // -----------------------------------------------------------------------------------------------------------------------

    public static Set<Id> getRecipients(List<Case> caseList, String recipientUserFieldString) 
    {
        if (String.isEmpty(recipientUserFieldString)) { return null; }
        
        String[] recipientUserFieldArray = recipientUserFieldString.split(ECICCommonConstants.SEMICOLON);
        return getRecipients(caseList, recipientUserFieldArray);
    }
    
    public static Set<Id> getRecipients(List<Case> caseList, String[] recipientUserFieldArray) 
    {    
        Set<Id> idSet = new Set<ID>();
        for (Case currentCase : caseList) 
        {
            for (String userField : recipientUserFieldArray) 
            {
                Id userId = (Id) currentCase.get(userField);
                if (userId != null) { idSet.add(userId); }     
            }
        }
        return idSet;
    }



}