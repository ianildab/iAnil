global class ECICEmail2CaseService implements Messaging.InboundEmailHandler 
{
    private static final Pattern CASE_EMAIL_THREAD_ID_PATTERN = Pattern.compile('^([A-Za-z0-9]{5})([A-Za-z0-9]*)([A-Za-z0-9]{5})$');
    private static final Pattern EMAIL_HEADER_DATE_PATTERN = Pattern.compile('.*((Mon|Tue|Wed|Thu|Fri|Sat|Sun),\\s+)(\\d\\d?)\\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\\s+(\\d\\d\\d\\d)\\s+(\\d\\d):(\\d\\d):(\\d\\d)\\s*([+-]\\d\\d\\d\\d)?.*'); // http://tools.ietf.org/html/rfc2822#page-14
    private static final Pattern EMAIL_BODY_PATTERN = Pattern.compile('(?iu).*<body>(.*)?</body>.*');
    private static final String ACCEPTED_EMAILS_SEPARATOR = ';';
    private static final String SERVICE_NAME = 'Email-to-Case';
    private static final Map<String, Integer> MONTH_NAMES_TO_NUMBERS_MAP = new Map<String, Integer>{'Jan'=>1,'Feb'=>2,'Mar'=>3,'Apr'=>4,'May'=>5,'Jun'=>6,'Jul'=>7,'Aug'=>8,'Sep'=>9,'Oct'=>10,'Nov'=>11,'Dec'=>12};
    @testVisible 
    private static final String FAILED_TO_PROCESS_INBOUND = 'Failed to process inbound email.';
    private static final Integer EMAIL_BODY_MAX_LENGTH = 32000; // same for Case.Description; size of SFDC Textarea data type

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) 
    {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        try 
        {   
            email.subject = email.subject != null ? email.subject : ''; // Added in case the email subject is null.
            if(ECICEmail2CaseServiceUtility.filterSpamEmails(email, true)){
                return result;
            }
            if(ECICEmail2CaseServiceUtility.filterSpamEmails(email, false)){
                return result;
            }
            String strEmailBody = String.isNotBlank(email.plainTextBody) ? email.plainTextBody : email.htmlBody;
            strEmailBody.toLowerCase();
            String strQualitycomplaintNWEN=ECICCommonConstants.QUALITY_COMPLAINT_NWEN_RTNAME;
            strQualitycomplaintNWEN.toLowerCase();
            
           if((!email.subject.equalsIgnoreCase('Klacht kwaliteit product')) && (!strEmailBody.contains(strQualitycomplaintNWEN))){
            
            List<String> errors = new List<String>();
            Case currentCase = findReferencedCase(email);
            Boolean notifyCaseOwnerUserOnConsumerReply = true;
            
                if (currentCase == null)                                                    // No case is referenced in the subject or case not found 
                {
                    currentCase = createNewCase(email, errors);                             // Let's create a new Case
                notifyCaseOwnerUserOnConsumerReply = false;
            }
            System.debug('Current Case '+currentCase);
            //logic for auto response email
            if(currentCase!=null){
                //sendAutoResponse(currentCase, email);
          
          }
          if(currentCase==null){
              system.debug('errors '+errors);
          }
          
          //attachEmailToCase(email, currentCase);
            
                if (currentCase != null) 
                {
                    if (Test.isRunningTest() && (currentCase.subject == ECICEmail2CaseServiceTest.EMAIL_FAIL_SUBJECT))
                    {
                        throw new ECICEmail2CaseServiceException('Do exception test');
                    }
                    
                    if(currentCase.Country_Code__c == 'DE' && currentCase.status == 'Closed'){
                        currentCase.status = 'Reopened';
                        Database.update(currentCase);
                    }
                attachEmailToCase(email, currentCase);
                result.success = true;
            }
            
                if (! errors.isEmpty()) { notifySupportAboutUnhandledEmail(email, currentCase, errors); }
                else if (notifyCaseOwnerUserOnConsumerReply) { notifyCaseOwnerUser(currentCase); }                  //result.success = false;
            } 
        }
        catch (Exception ex) {
            String errorMessage = FAILED_TO_PROCESS_INBOUND + '\nError: ' + ex.getMessage() + '\nEmail: ' + email;
            System.debug(LoggingLevel.ERROR, errorMessage);
            throw new ECICEmail2CaseServiceException(errorMessage, ex);
        }
        
        return result;
    }
    // function used to send an auto response mail from salesforce to customer.
    private void sendAutoResponse(Case currentCase, Messaging.InboundEmail email){
        Case newcase=[Select id, caseNumber, contactId, accountId, country_code__c, origin from Case where id=: currentCase.id];
        String templateName = newCase.country_code__c + '_Email_to_Case_Auto_Response';
        //String templateName = 'ES_Email_to_Case_Auto_Response';
        EmailTemplate emailTemplate=[Select id, name, Body, subject from EmailTemplate where DeveloperName =: templateName limit 1];
        //system.debug('## emailTemplate.subject '+emailTemplate.subject);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddress = new String[] {email.fromAddress};
        String subject =  emailTemplate.subject.replaceAll('\\{!Case.CaseNumber\\}', ''+newCase.caseNumber);
        
        mail.setTemplateId(emailTemplate.id);
        mail.setReplyTo(email.toAddresses[0]);
        if(newCase.contactId != null){
            mail.setTargetObjectId(newCase.contactId);
        }
        else{
            Contact c = [Select name, id from Contact where email =: email.fromAddress limit 1];
            mail.setTargetObjectId(c.Id);
        }
        
        mail.setWhatId(newCase.id);
        
         mail.setSenderDisplayName('Coke Support Agent');
         
        //mail.setToAddresses(toAddress);
        //mail.setSubject(emailTemplate.subject);
        //mail.setSubject('case #'+newcase.caseNumber+' created: '+case.subject);
        //mail.setPlainTextBody(emailTemplate.body);
        //mail.setSubject(subject);
        //mail.setPlainTextBody('Dear '+currentCase.suppliedName+',\nYour. case #'+newcase.CaseNumber+': '+currentCase.subject+' has been created.\n\nThank you contacting us. We will get back to you very soon.');
        if(newCase.origin != 'External Relations' && newCase.origin!= 'Commercial Dept.'){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    
    private Case findReferencedCase(Messaging.InboundEmail email) 
    {
        Case result = null;
        
        String emailBody = String.isNotBlank(email.plainTextBody) ? email.plainTextBody : email.htmlBody;           // Parse email looking for a case thread ID
        
        if (emailBody != null) 
        {
            emailBody = emailBody.replaceAll('\r', '');                                                       // No multiline regex matching is supported at the time of writing this code -> replace line endings.
            emailBody = emailBody.replaceAll('\n', '');
            
            Matcher matcher = CASE_EMAIL_THREAD_ID_PATTERN.matcher(emailBody);
            if (matcher.matches()) 
            {
                String emailThreadId = matcher.group(1);
                ID caseId = Cases.getCaseIdFromEmailThreadId(emailThreadId);
                result = ECICCaseDao.findById(caseId);
            } 
        }
        
        if(result == null && email.subject != null){
            if( emailSubjectContainsFilterKeyword(email.subject) && !isFromWhitelistedDomain(email.FromAddress) ){
                return result;
            } else {                
                Pattern p = Pattern.compile('[0-9]{8}');
                Matcher m = p.matcher(email.subject);
                if(m.find()){
                    String caseNum = m.group();
                    List<Case> selectedCaseList = new list<Case>();
                    selectedCaseList = [SELECT id, Country_Code__c from Case WHERE caseNumber =: caseNum limit 1];
                    Case selectedCase = selectedCaseList.size() != 0 ? selectedCaseList[0] : null;
                    if(selectedCase != null){
                        if(selectedCase.Country_Code__c == 'PT'|| selectedCase.Country_Code__c == 'ES' || selectedCase.Country_Code__c == 'GB'
                           || selectedCase.Country_Code__c == 'BE'|| selectedCase.Country_Code__c == 'NL'|| selectedCase.Country_Code__c == 'LU'
                           || selectedCase.Country_Code__c == 'NO'  || selectedCase.Country_Code__c == 'SE'
                           || selectedCase.Country_Code__c == 'DE' || selectedCase.Country_Code__c == 'CO' || selectedCase.Country_Code__c == 'CR' 
                           || selectedCase.Country_Code__c == 'EC' || selectedCase.Country_Code__c == 'GT' || selectedCase.Country_Code__c == 'HN' 
                           || selectedCase.Country_Code__c == 'NI' || selectedCase.Country_Code__c == 'PA' || selectedCase.Country_Code__c == 'SV' 
                           || selectedCase.Country_Code__c == 'TT' || selectedCase.Country_Code__c == 'ZA'){
                            result = ECICCaseDao.findById(selectedCase.id);
                        }
                    }
                }
            }
            
        }
        
        return result;      
    }
    
    private Case createNewCase(Messaging.InboundEmail email, List<String> errors) 
    {
        Case result = null;
        EmailToCasePresets__c presets = 
            (!(Test.isRunningTest() && (email.toAddresses[0] == ECICEmail2CaseServiceTest.EMAIL_NO_PRESET_ADDRESS)))
                ? getCasePresetsByAddressee(email.toAddresses)
                : null;

        if (presets != null)                                                                        // If a preset is found then 'email.toAddresses' is supported
        {
            result = new Case(Status = 'New');
            String emailSubject = email.subject.trim();
            
            // added this condition to differentiate GB Web cases from all other Email Cases. -- Aditya Bansod(Capgemini)
            if(emailSubject.containsIgnoreCase('Contact from www.coca-cola.co.uk') || emailSubject.containsIgnoreCase('Contact from www.parklives.com') || emailSubject.containsIgnoreCase('Contact from www.relentlessenergy.com')){
                ECICEmail2CaseServiceUtility.parseEmailandSetCaseFields(result, email, presets, errors);
            }
            else if(emailSubject.equalsIgnoreCase('Coca-Cola Contact')){
                ECICEmail2CaseServiceUtility.parseEmailandSetCaseFieldsForBelgiumCases(result, email, presets, errors);
            }
            else if(emailSubject.containsIgnoreCase('Veel gestelde vragen - Nieuwe vraag')){
                ECICEmail2CaseServiceUtility.parseEmailandSetCaseFieldsForNehtherlandsCases(result, email, presets, errors);
            }
            else{
                setCaseFieldsFromEmail(result, email);
                setCaseFieldsFromPresets(result, presets, errors);
            }
            if (ECICCaseQualityComplaintRecordTypeHelper.isQualityComplaint(result.RecordTypeID)) { result.No_Quality_Status_Change__c  = true; }
            Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerAutoResponseEmail = true;
            database.insert(result,dlo);
            system.debug('---result------' +result);
            // NOTE: account and contact information set in the case trigger on before insert
            //insert result;                                                                          // Save new Case
        } 
        else { errors.add('No presets found for inbound email processing. Addressee: [' + ((email.toAddresses == null)? '<EMPTY>' :String.join(email.toAddresses, ',')) + ']'); }
        return result;
    }
    
    private EmailToCasePresets__c getCasePresetsByAddressee(String[] toAddresses) 
    {
        EmailToCasePresets__c result = null;
        
        Map<String, EmailToCasePresets__c> presets = EmailToCasePresets__c.getAll();
        for (EmailToCasePresets__c currentPresets : presets.values()) 
        {
            String[] acceptedEmails = currentPresets.Accepted_Emails__c.toLowerCase().split(ACCEPTED_EMAILS_SEPARATOR); // a simple string comparison could be enough though...
            for (String acceptedEmail : acceptedEmails) 
            {
                String trimmedAcceptedEmail = acceptedEmail.trim();
                if(toAddresses != null){
                    for (String email: toAddresses) 
                    {
                        String lowerCaseEmail = email.toLowerCase();
                        if (lowerCaseEmail == trimmedAcceptedEmail) 
                        {
                            EmailToCasePresets__c foundPreset = currentPresets;
                            if (foundPreset.isActive__c)  { result = foundPreset; break; }
                        }
                    }
                }
                if (result != null) { break; }
            }
            if (result != null) { break; }
        }
        return result;
    }
    
    private void setCaseFieldsFromEmail(Case currentCase, Messaging.InboundEmail email) {
        currentCase.Subject         = email.Subject;
        currentCase.SuppliedEmail   = email.fromAddress;
        currentCase.SuppliedName    = email.fromName;
        String caseDescription      = String.isNotBlank(email.plainTextBody) ? email.plainTextBody : stripHtmlText(email.htmlBody);
        
        if (caseDescription.length() > EMAIL_BODY_MAX_LENGTH) {
            caseDescription = caseDescription.substring(0, EMAIL_BODY_MAX_LENGTH);
        }
        
        currentCase.Description     = caseDescription;
    }
    
    private void setCaseFieldsFromPresets(Case currentCase, EmailToCasePresets__c presets, List<String> errors) {
        currentCase.Country_Code__c = presets.Country_Code__c;
        currentCase.Origin          = presets.Origin__c;
        currentCase.Priority        = presets.Priority__c;
        
        RecordType caseRecordType = ECICRecordTypeDao.findByDeveloperName(presets.RecordType_DeveloperName__c);
        if (caseRecordType != null) { currentCase.RecordTypeId = caseRecordType.id; } 
        else 
        {
            String errorMessage = 'No Case RecordType found in '+SERVICE_NAME+' Presets to name ['+presets.RecordType_DeveloperName__c+']';
            System.debug(LoggingLevel.WARN, errorMessage);
            errors.add(errorMessage);
        }

        Group caseQueue = ECICGroupDao.findQueueByDeveloperName(presets.Queue_DeveloperName__c);
        system.debug('Case Queue:' + caseQueue);
        if (caseQueue != null) { currentCase.ownerId = caseQueue.id; } 
        else 
        {
            String errorMessage = 'No Case queue found in '+SERVICE_NAME+' Presets to name ['+presets.Queue_DeveloperName__c+']';
            System.debug(LoggingLevel.WARN, errorMessage);
            errors.add(errorMessage);

            currentCase.ownerId = Userinfo.getUserId();                                             // Set the service executing user as Case owner
        }
        }

    @testVisible private void attachEmailToCase(Messaging.InboundEmail email, Case currentCase)     // process the email itself 
    {
        
        EmailMessage emailAsCaseAttachment = new EmailMessage();
        emailAsCaseAttachment.parentId      = currentCase.id;
        emailAsCaseAttachment.FromAddress   = email.fromAddress;
        emailAsCaseAttachment.ToAddress     = String.join(email.toAddresses, '\n');
        if (email.ccAddresses != null) { emailAsCaseAttachment.CcAddress     = String.join(email.ccAddresses, '\n'); }
        
        emailAsCaseAttachment.Headers = '';
        
        for (Messaging.InboundEmail.Header header : email.headers) 
        {
            if (header.name == 'Date' && (emailAsCaseAttachment.MessageDate == null)) 
            {
                emailAsCaseAttachment.MessageDate = parseEmailHeaderDateToUTC(header.value);
            }
            emailAsCaseAttachment.Headers += header.name + ': '+ header.value + '\n';
        }
        
        emailAsCaseAttachment.Subject   = email.subject;
        
        if (email.plainTextBody != null) {
            emailAsCaseAttachment.TextBody  = email.plainTextBody.length() > EMAIL_BODY_MAX_LENGTH ? email.plainTextBody.substring(0, EMAIL_BODY_MAX_LENGTH) : email.plainTextBody;
        }
        
        if (email.htmlBody != null) {
            emailAsCaseAttachment.HtmlBody  = email.htmlBody.length() > EMAIL_BODY_MAX_LENGTH ? email.htmlBody.substring(0, EMAIL_BODY_MAX_LENGTH) : email.htmlBody;
        }

        emailAsCaseAttachment.Incoming  = true;
        emailAsCaseAttachment.Status    = '0'; // set status = 'New'
        insert emailAsCaseAttachment;

        Attachment[] caseAttachmentArray = createCaseAttachmentArray(emailAsCaseAttachment.id, email);
        
        if (! caseAttachmentArray.isEmpty()) {
            //insert caseAttachmentArray;
            Database.SaveResult[] saveResults = Database.insert(caseAttachmentArray, false); // allow partial fails (most probably because of security settings: http://help.salesforce.com/HTViewHelpDoc?id=security_htmlattachments.htm&language=en_US)
             
            for (Database.SaveResult saveResult : saveResults) {
                if (! saveResult.isSuccess()) {
                    for (Database.Error error : saveResult.getErrors()) {
                        System.debug(LoggingLevel.WARN, '*** Failed to save attachment: ' + error.getMessage());
                    }
                }
            }
        }
    }

    @testVisible private static Attachment[] createCaseAttachmentArray( Id emailAsCaseAttachmentId, Messaging.InboundEmail email)
    {
        Attachment[] caseAttachmentArray = new Attachment[0];
        if (email.textAttachments != null) 
        {
            for (Messaging.InboundEmail.TextAttachment emailAttachment : email.textAttachments)         // process email text attachements
            {
                caseAttachmentArray.add(createCaseAttachment(emailAsCaseAttachmentId, emailAttachment));
            }
        }
        
        if (email.binaryAttachments != null) 
        {          
            for (Messaging.InboundEmail.BinaryAttachment emailAttachment  : email.binaryAttachments)    // process email binary attachements
            {
                caseAttachmentArray.add(createCaseAttachment(emailAsCaseAttachmentId, emailAttachment));
            }
        }
        return caseAttachmentArray;
    }
    
    @testVisible private static Attachment createCaseAttachment(Id emailAsCaseAttachmentId, String fileName, Blob bodyBlob, String contentType)
    {
                Attachment caseAttachment = new Attachment();
                       caseAttachment.parentId      = emailAsCaseAttachmentId;
                       caseAttachment.Name          = fileName;
                       caseAttachment.Body          = bodyBlob;
                       caseAttachment.ContentType   = contentType;
                return caseAttachment;      
    }

    @testVisible private static Attachment createCaseAttachment(Id emailAsCaseAttachmentId, Messaging.InboundEmail.TextAttachment emailAttachment)
    {
        return createCaseAttachment(emailAsCaseAttachmentId, emailAttachment.fileName, Blob.valueOf(emailAttachment.body), emailAttachment.mimeTypeSubType);
    }
    
    @testVisible private static Attachment createCaseAttachment(Id emailAsCaseAttachmentId, Messaging.InboundEmail.BinaryAttachment emailAttachment)
    {
        return createCaseAttachment(emailAsCaseAttachmentId,  emailAttachment.fileName,  emailAttachment.body, emailAttachment.mimeTypeSubType);
    }
    
    private void notifySupportAboutUnhandledEmail(Messaging.InboundEmail email, Case currentCase, List<String> errors) 
    {
        String addressee = General_Settings__c.getInstance().supportEmail__c;
        String subject = 'ERRORS on inbound email processing';
        String message = 'Case ID: ' + ((currentCase != null) ? (String)(currentCase.id) : 'NO CASE CREATED');
        message += '\n\n';
        message += 'The following error(s) occoured while processing an inbound email:\n\n';
        message += String.join(errors, '\n');
        message += '\n\nOriginal email:\n\n';
        
        for (Messaging.InboundEmail.Header header : email.headers) { message += header.name + ': ' + header.value + '\n'; }

        message += '\n\n';
        message += String.isNotBlank(email.plainTextBody) ? email.plainTextBody : email.htmlBody;
        
        sendNotificationMail(addressee, subject, message);
    }
    
    private void sendNotificationMail(String addressee, String subject, String messageBody) 
    {
        SEPEmailSendHelper.sendNotificationMail(addressee, '['+ SERVICE_NAME + '] '+ subject, messageBody);
    }
    
    @testVisible private Datetime parseEmailHeaderDateToUTC(String rfc2822Date) 
    {
        
    
        Datetime result = null;
        Matcher matcher = EMAIL_HEADER_DATE_PATTERN.matcher(rfc2822Date);
        if (matcher.matches() || (Test.isRunningTest() && (rfc2822Date == ECICEmail2CaseServiceTest.DATETIME_CANT_PARSE_STRING))) 
        {
            try 
            {
                Integer day             = Integer.valueOf(matcher.group(3));
                String monthName        = matcher.group(4);
                Integer month           = MONTH_NAMES_TO_NUMBERS_MAP.get(monthName);
                Integer year            = Integer.valueOf(matcher.group(5));
                Integer hour            = Integer.valueOf(matcher.group(6));
                Integer minute          = Integer.valueOf(matcher.group(7));
                Integer second          = Integer.valueOf(matcher.group(8));
                String timezoneOffset   = (String)matcher.group(9);
                Integer hourOffset      = Integer.valueOf(timezoneOffset.substring(1, 3));
                Integer minuteOffset    = Integer.valueOf(timezoneOffset.substring(3, 5));
                
                if (timezoneOffset.substring(0, 1) == '-') { 
                                        hourOffset *= -1; 
                                        minuteOffset *= -1;
                                    }
                
                result = Datetime.newInstanceGmt(year, month, day, hour, minute, second);
                result = result.addHours(-hourOffset);
                result = result.addMinutes(-minuteOffset);
                 
            } 
            catch (Exception ex) { result = null; System.debug(LoggingLevel.WARN, '----- Failed to parse email date: [' + rfc2822Date + ']. Exception: ' + ex); }
        }
        
        return result;
    }
    
    @testVisible 
    private void notifyCaseOwnerUser(Case currentCase)                             // CIC-622 Notifiy Case owner via Chatter on incoming email to an existing Case 
    {
        User caseOwnerUser = ECICUserDao.findById(currentCase.OwnerId);
        if (caseOwnerUser != null) 
        {
            String title = 'Case ' + currentCase.CaseNumber + ' received a consumer email reply';
            String caseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + currentCase.ID;
            FeedItem userFeedItem = new FeedItem(ParentId = currentCase.OwnerId, Type = 'LinkPost', LinkURL = caseUrl, Title = title);
            insert userFeedItem;
        }
    }
   
    @testVisible
    private String stripHtmlText(String htmlText) {
        String result = htmlText;
        
        if (result != null) {
            // try catch content between <body>...</body>
            Matcher matcher = EMAIL_BODY_PATTERN.matcher(result);
            
            if (matcher.matches()) {
                result = matcher.group(1);
            }
            
            // try keep formatting (String.stripHtmlTags() only respects linebreaks)
            result = result.replaceAll('(?iu)(&nbps;)+', '&nbps;').replaceAll('&nbsp;', ' ');
            result = result.replaceAll('(?iu)<br/?>', '\n');
            result = result.replaceAll('(?iu)</?p>', '\n');
            result = result.replaceAll('(?iu)</?div>', '\n');

            // cleanup
            result = result.replaceAll('</?[^>]+>', '');
            result = result.replaceAll('\n+', '\n');
            result = result.unescapeHtml4();
        }

        return result;   
    }
    
    @testVisible
    private Boolean isFromWhitelistedDomain(String fromAddress) {
        if(fromAddress == null) {
            return false;
        }
        
        String fromDomain = fromAddress.substringAfter('@');
        
        if(fromDomain == null) {
            return false;
        }
        
        List<Email_Whitelisted_Domains__c> whitelistedDomains = Email_Whitelisted_Domains__c.getall().values();
        
        for(Email_Whitelisted_Domains__c domain : whitelistedDomains) {
           if(fromDomain == domain.name) {
               return true;
           }
        }
        
        return false;
    }
    
    @testVisible
    private Boolean emailSubjectContainsFilterKeyword(String emailSubject) {
        List<Email_Subject_Filter__c> keyWords = Email_Subject_Filter__c.getall().values();
        for(Email_Subject_Filter__c keyword : keywords) {
            if(emailSubject.containsIgnoreCase(keyword.name)) {
                return true;
            }
        }
        
        return false;
    }
}