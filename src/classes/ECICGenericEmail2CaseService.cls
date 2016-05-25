/* This class is used for Generic Web to case form,functionally a Web-to-Case process, though technically it works as a Email-to-case process*/

global class ECICGenericEmail2CaseService Implements Messaging.InboundEmailHandler{

    private static final Pattern CASE_EMAIL_THREAD_ID_PATTERN = Pattern.compile('.*ref:([a-zA-Z_0-9\\.]+):ref.*'); // \w does not seem to work o.O
    private static final Pattern EMAIL_HEADER_DATE_PATTERN = Pattern.compile('.*((Mon|Tue|Wed|Thu|Fri|Sat|Sun),\\s+)(\\d\\d?)\\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\\s+(\\d\\d\\d\\d)\\s+(\\d\\d):(\\d\\d):(\\d\\d)\\s*([+-]\\d\\d\\d\\d)?.*'); // http://tools.ietf.org/html/rfc2822#page-14
    private static final Pattern EMAIL_BODY_PATTERN = Pattern.compile('(?iu).*<body>(.*)?</body>.*');
    private static final String ACCEPTED_EMAILS_SEPARATOR = ';';
    private static final String SERVICE_NAME = 'Email-to-Case';
    private static final Integer EMAIL_BODY_MAX_LENGTH = 32000; // same for Case.Description; size of SFDC Textarea data type
    private static final Map<String, Integer> MONTH_NAMES_TO_NUMBERS_MAP = new Map<String, Integer>{'Jan'=>1,'Feb'=>2,'Mar'=>3,'Apr'=>4,'May'=>5,'Jun'=>6,'Jul'=>7,'Aug'=>8,'Sep'=>9,'Oct'=>10,'Nov'=>11,'Dec'=>12};

    global messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope){
            
             List<String> errors = new List<String>();
            
            Messaging.InboundEmailResult result = new messaging.InboundEmailResult();
            String emailtext = String.isNotBlank(email.plainTextBody) ? email.plainTextBody : '';
  
            system.debug('email Text'+emailtext);
            
            // To load the email content in DOM format and parse it to get email contents
            if(emailtext!='')
            {
            DOM.document docname = new DOM.Document();
            try{
            docname.load(emailtext);
            DOM.XMLNode rootper = docname.getRootElement();
            system.debug(rootper+'root');
            
            //Create case instance and attach the email values to Case Fields
            Case freshCase = new Case(status = 'New');
            
            freshCase.Origin= 'Web'; //Added by Roshan
            
            /*default values for these fields*/
            
            freshCase.Potential_Risk__c='No Risk';
            freshCase.Sub_Channel__c = 'Q&A Portal';
          
            
            freshCase.Subject= rootper.getChildElement('emailSubject',null).getText();
            freshCase.SuppliedLastName__c  = rootper.getChildElement('lastName',null).getText();
            freshCase.SuppliedFirstName__c = rootper.getChildElement('firstName',null).getText();
            freshCase.suppliedName  = rootper.getChildElement('firstName',null).getText() + ' ' + freshCase.SuppliedLastName__c;
            freshCase.SuppliedEmail = rootper.getChildElement('email',null).getText();
            freshCase.SuppliedMailingCity__c = rootper.getChildElement('city',null).getText();
            freshCase.Country_Code__c = rootper.getChildElement('countryCode',null).getText();
            freshCase.suppliedPhone = rootper.getChildElement('phoneNumber',null).getText();
            freshcase.Description = rootper.getChildElement('question',null).getText();
            system.debug('purposelist'+rootper.getChildElement('purposeList',null).getText()+'category list'+rootper.getChildElement('categoryList',null).getText());
            freshcase.Subject = rootper.getChildElement('categoryList',null).getText() + ' '+ rootper.getChildElement('purposeList',null).getText();
            //system.debug('day------------------'+rootper.getChildElement('year',null).getText() + '-' + rootper.getChildElement('month',null).getText() + '-' + rootper.getChildElement('day',null).getText());
            //freshcase.Supplied_Birthdate__c = rootper.getChildElement('year',null).getText() + '-' + rootper.getChildElement('month',null).getText() + '-' + rootper.getChildElement('day',null).getText();
            
            string birthdate = rootper.getChildElement('birthDate',null).getText();
            List<string> stringDate = birthdate.split('/');
            freshcase.Supplied_Birthdate__c = stringdate[2] + '-' + stringdate[1] + '-' + stringdate[0];
            
            String XMLCountry = rootper.getChildElement('country',null).getText().toLowerCase();
            XMLCountry = XMLCountry.containsIgnoreCase('> Otro pais <') ? 'Costa Rica' : XMLCountry;
            
            //no mapping for following fields
            //    string child1 = rootper.getChildElement('country',null).getText();            
            //  string child1 = rootper.getChildElement('siteName',null).getText();
            //   string child1 = rootper.getChildElement('visitDate',null).getText();
           
            EmailToCasePresets__c presetsInst = null;
            //to get values from Email to Case Presets for Record type and Owner assignment
            if(freshCase.Country_Code__c == 'GB'){
                presetsInst = EmailToCasePresets__c.getValues('GB.Inquiry.Email');
            }
            else if(freshCase.Country_Code__c == 'FR'){
                  presetsInst = EmailToCasePresets__c.getValues('FR.Inquiry.Email');}
            else if(freshCase.Country_Code__c == 'NO'){
                        presetsInst = EmailToCasePresets__c.getValues('NO.Inquiry.Email');}
            else if(freshCase.Country_Code__c == 'SE'){
                presetsInst = EmailToCasePresets__c.getValues('SE.Inquiry.Email');
            }
            else if(freshCase.Country_Code__c == 'BE'){
                presetsInst = EmailToCasePresets__c.getValues('BE.Inquiry.Email');
            }
            else if(freshCase.Country_Code__c == 'NL'){
                presetsInst = EmailToCasePresets__c.getValues('NL.Inquiry.Email');
            }
            else if(freshCase.Country_Code__c == 'LU'){
                presetsInst = EmailToCasePresets__c.getValues('LU.Inquiry.Email');
            }
            
            Map<String, EmailToCasePresets__c> presets = EmailToCasePresets__c.getAll();
            for (String currentPreset : presets.keySet()) 
            {
                if(!String.isBlank(XMLCountry) && currentPreset.containsIgnoreCase(XMLCountry)){
                    if(presets.get(currentPreset).isActive__c){
                        presetsInst = presets.get(currentPreset);
                        break;
                    }
                }
             }
            
            if(presetsInst != null){
            
            freshCase.Country_Code__c = presetsInst.Country_Code__c;
           
            RecordType caseRecordType   = ECICRecordTypeDao.findByDeveloperName(presetsInst.RecordType_DeveloperName__c);
                if (caseRecordType != null) { 
                
                    freshcase.RecordTypeId = caseRecordType.id;
                }
                 
                else 
                {
                    String errorMessage = 'No Case RecordType found in '+SERVICE_NAME+' Presets to name ['+presetsInst.RecordType_DeveloperName__c+']';
                    System.debug(LoggingLevel.WARN, errorMessage);
                    //errors.add(errorMessage);
                }
                
                Group caseQueue = ECICGroupDao.findQueueByDeveloperName(presetsInst.Queue_DeveloperName__c);
                
                if (caseQueue != null) {
                
                    freshcase.ownerId = caseQueue.id;
                }
                 
                else 
                {
                    String errorMessage = 'No Case queue found in '+SERVICE_NAME+' Presets to name ['+presetsInst.Queue_DeveloperName__c+']';
                    System.debug(LoggingLevel.WARN, errorMessage);
                    //errors.add(errorMessage);
        
                    freshcase.ownerId = Userinfo.getUserId();                                             // Set the service executing user as Case owner
                }
           
            
            system.debug('freshCase'+freshCase);
            
            // to Insert the case in the system
            Database.DMLOptions dlo = new Database.DMLOptions();
            dlo.EmailHeader.triggerAutoResponseEmail = true;
            Database.SaveResult srList = Database.insert(freshCase,dlo);
            //Database.SaveResult srList = Database.insert(freshCase, false); 
            // for (Database.SaveResult sr : srList) 
            {
                if (srList.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted account. Account ID: ' + srList.getId());
                    
                    attachEmailToCase(email, freshCase);
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : srList .getErrors()) 
                    {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
           
          //  system.debug(child1+'child1');
        }    
        }
        else{
            errors.add('No presets found for inbound email processing. Addressee: [' + ((email.toAddresses == null)? '<EMPTY>' :String.join(email.toAddresses, ',')) + ']');
            if (! errors.isEmpty()) { notifySupportAboutUnhandledEmail(email, freshCase, errors); }
        }

        return result;
    }
        Catch(Exception e)
                   {
                       sendmail(e.getMessage());
                       return result;
                   }
    }
            else{
                //result.success=false;
                
                sendmail(result.message+'no description');
                return result;
                }   
    }
    public void sendmail(string error){
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    string toAddress = General_Settings__c.getInstance().supportEmail__c;
    String[] toAddresses = new String[] {toAddress}; 
    mail.setToAddresses(toAddresses);
 //   mail.setReplyTo('noreply@salesforce.com'); // this we can set 
    mail.setSenderDisplayName('Web Error');
    mail.setSubject('Error in Web form case creation');
    mail.setUseSignature(false);
    mail.setPlainTextBody('Error: ' + error);
    mail.setHtmlBody('error:<b> ' + error);

// Send the email you have created.
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    
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
    }