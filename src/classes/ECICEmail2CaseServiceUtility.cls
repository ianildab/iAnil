public with sharing class ECICEmail2CaseServiceUtility{

    private static final String SERVICE_NAME = 'Email-to-Case';

     //Function created for setting GB web case's fields. Aditya Bansod(Capgemini)
    public static void parseEmailandSetCaseFields(Case currentCase, Messaging.InboundEmail email,  EmailToCasePresets__c presets,List<String> errors){
            
             List <GB_Web_Cases_XML_to_SFDC_Mapping__c> fieldValues = GB_Web_Cases_XML_to_SFDC_Mapping__c.getAll().values();
            String gender = null;
            String title = null;
            String agerange = null;
            
            email.plainTextBody = String.isNotBlank(email.plainTextBody) ? email.plainTextBody : email.htmlBody;
            
            //String xmlPart = email.plainTextBody.substringBetween('<site>','</message>')!=null ? email.plaintextBody.substringBetween('<site>','</message>') : '';
            
            //String xml = '<startXML><site>'+xmlPart+'</message></startXML>';
            try{
                //Not parsing the Xml because of the improper Xml format from Lotus inbox.
                //Dom.Document doc = new Dom.Document();
                //doc.load(xml);
                //Dom.XMLNode parse = doc.getRootElement();
                
                String phoneNumber = email.plainTextBody.substringBetween('<phone>','</phone>') != null ? email.plainTextBody.substringBetween('<phone>','</phone>') : '';
                phoneNumber = phoneNumber.deleteWhitespace();
                phoneNumber = phoneNumber.replaceAll('-', '');
                
                currentCase.SuppliedFirstName__c            = email.plainTextBody.substringBetween('<firstname>','</firstname>') != null ? email.plainTextBody.substringBetween('<firstname>','</firstname>') : '';
                currentCase.SuppliedLastName__c             = email.plainTextBody.substringBetween('<name>','</name>') != null ? email.plainTextBody.substringBetween('<name>','</name>') : '';
                currentCase.suppliedName                    = currentCase.SuppliedFirstName__c + ' ' + currentCase.SuppliedLastName__c;
                currentCase.SuppliedMailing_Streetname1__c  = email.plainTextBody.substringBetween('<address1>','</address1>') != null ? email.plainTextBody.substringBetween('<address1>','</address1>') : '';
                currentCase.SuppliedMailing_Streetname2__c  = email.plainTextBody.substringBetween('<address2>','</address2>') != null ? email.plainTextBody.substringBetween('<address2>','</address2>') : '';
                currentCase.SuppliedMailingCity__c          = email.plainTextBody.substringBetween('<city>','</city>') != null ? email.plainTextBody.substringBetween('<city>','</city>') : '';
                currentCase.SuppliedMailingZip__c           = email.plainTextBody.substringBetween('<postcode>','</postcode>') != null ? email.plainTextBody.substringBetween('<postcode>','</postcode>') : '';
                currentCase.suppliedPhone                   = phoneNumber;
                currentCase.suppliedEmail                   = email.plainTextBody.substringBetween('<email>','</email') != null ? email.plainTextBody.substringBetween('<email>','</email') : '';
                String optin                                = email.plainTextBody.substringBetween('<optin>','</optin>') != null ? email.plainTextBody.substringBetween('<optin>','</optin>') : '';
                currentCase.SuppliedOptin__c                = optin.equalsIgnoreCase('Y') ? '1' : '0';
                currentCase.description                     = email.plainTextBody.substringBetween('<message>','</message>') != null ? email.plainTextBody.substringBetween('<message>','</message>') : '';
                
                //fields to be added from GB Web Cases XML to SFDC Mapping custom settings.
                gender                                      = email.plainTextBody.substringBetween('<gender>','</gender>') != null ? email.plainTextBody.substringBetween('<gender>','</gender>') : '';
                title                                       = email.plainTextBody.substringBetween('<title>','</title>') != null ? email.plainTextBody.substringBetween('<title>','</title>') : '';
                agerange                                    = email.plainTextBody.substringBetween('<agerange>','</agerange>') != null ? email.plainTextBody.substringBetween('<agerange>','</agerange>') : '';
                
                
                }
                catch(Exception ex){
                    errors.add(ex.getMessage());
                }
                
                Boolean genderFound = false;
                Boolean titlefound = false;
                Boolean agerangeFound = false;
            for(GB_Web_Cases_XML_to_SFDC_Mapping__c fv : fieldValues ){
                
                    if(fv.Field_Name__c.equalsIgnoreCase('gender') && fv.Web_Form_Value__c.equalsIgnoreCase(gender) && !genderFound ){
                        currentCase.Supplied_Gender__c = fv.Salesforce_Field_Value__c;
                        genderFound = true;
                    }
                    if(fv.Field_Name__c.equalsIgnoreCase('title') && fv.Web_Form_Value__c.equalsIgnoreCase(title) && !titlefound ){
                        currentCase.Supplied_Title__c = fv.Salesforce_Field_Value__c;
                        titleFound = true;
                    }
                    if(fv.Field_Name__c.equalsIgnoreCase('agerange') && fv.Web_Form_Value__c.equalsIgnoreCase(agerange) && !agerangeFound ){
                        currentCase.Supplied_Age_Range__c = fv.Salesforce_Field_Value__c;
                        agerangeFound = true;
                    }
                    if(genderFound && titleFound && agerangeFound )
                    break;
                } 
                
            currentCase.Subject         = email.Subject;
            currentCase.Origin          = 'Web';
            currentCase.Country_Code__c = presets.Country_Code__c;
            currentCase.Priority        = presets.Priority__c;
            RecordType caseRecordType   = ECICRecordTypeDao.findByDeveloperName(presets.RecordType_DeveloperName__c);
                if (caseRecordType != null) { currentCase.RecordTypeId = caseRecordType.id; } 
                else 
                {
                    String errorMessage = 'No Case RecordType found in '+SERVICE_NAME+' Presets to name ['+presets.RecordType_DeveloperName__c+']';
                    System.debug(LoggingLevel.WARN, errorMessage);
                    errors.add(errorMessage);
                }
                
                Group caseQueue = ECICGroupDao.findQueueByDeveloperName(presets.Queue_DeveloperName__c);
                
                if (caseQueue != null) { currentCase.ownerId = caseQueue.id; } 
                else 
                {
                    String errorMessage = 'No Case queue found in '+SERVICE_NAME+' Presets to name ['+presets.Queue_DeveloperName__c+']';
                    System.debug(LoggingLevel.WARN, errorMessage);
                    errors.add(errorMessage);
        
                    currentCase.ownerId = Userinfo.getUserId();                                             // Set the service executing user as Case owner
                }
                
                
            
    }
    
    public static void parseEmailandSetCaseFieldsForBelgiumCases(Case currentCase, Messaging.InboundEmail email,  EmailToCasePresets__c presets,List<String> errors){
        
        try{
                email.plainTextBody = String.isNotBlank(email.plainTextBody) ? email.plainTextBody : email.htmlBody;
                
                String phoneNumber = email.plainTextBody.substringBetween('<phone>','</phone>') != null ? email.plainTextBody.substringBetween('<phone>','</phone>') : '';
                phoneNumber = formatPhone(phoneNumber);
                
                String fax = email.plainTextBody.substringBetween('<fax>','</fax>') != null ? email.plainTextBody.substringBetween('<fax>','</fax>') : '';
                fax = formatPhone(fax);
                
                String mobile = email.plainTextBody.substringBetween('<gsm>','</gsm>') != null ? email.plainTextBody.substringBetween('<gsm>','</gsm>') : '';
                mobile = formatPhone(mobile);
                
                String countryCode = email.plainTextBody.substringBetween('<country>','</country>') != null ? email.plainTextBody.substringBetween('<country>','</country>') : '';
                countryCode = countryCode.toLowerCase();
                
                currentCase.SuppliedFirstName__c            = email.plainTextBody.substringBetween('<firstname>','</firstname>') != null ? email.plainTextBody.substringBetween('<firstname>','</firstname>') : '';
                currentCase.SuppliedLastName__c             = email.plainTextBody.substringBetween('<name>','</name>') != null ? email.plainTextBody.substringBetween('<name>','</name>') : '';
                currentCase.suppliedName                    = currentCase.SuppliedFirstName__c + ' ' + currentCase.SuppliedLastName__c;
                currentCase.SuppliedMailing_Streetname1__c  = email.plainTextBody.substringBetween('<address>','</address>') != null ? email.plainTextBody.substringBetween('<address>','</address>') : '';
                currentCase.SuppliedMailingCity__c          = email.plainTextBody.substringBetween('<city>','</city>') != null ? email.plainTextBody.substringBetween('<city>','</city>') : '';
                currentCase.SuppliedMailingZip__c           = email.plainTextBody.substringBetween('<zip>','</zip>') != null ? email.plainTextBody.substringBetween('<zip>','</zip>') : '';
                currentCase.suppliedPhone                   = phoneNumber;
                currentCase.SuppliedMobile__c               = mobile;
                currentCase.supplied_Fax__c                 = fax;
                currentCase.suppliedEmail                   = email.plainTextBody.substringBetween('<email>','</email') != null ? email.plainTextBody.substringBetween('<email>','</email') : '';
                currentCase.description                     = email.plainTextBody.substringBetween('<message>','</message>') != null ? email.plainTextBody.substringBetween('<message>','</message>') : '';
                currentCase.subject                         = email.plainTextBody.substringBetween('<subject>','</subject>') != null ? email.plainTextBody.substringBetween('<subject>','</subject>') : '';
                String preferredLanguage                    = email.plainTextBody.substringBetween('<lang>','</lang>') != null ? email.plainTextBody.substringBetween('<lang>','</lang>') : '';
                currentCase.supplied_Preferred_Language__c  = preferredLanguage == 'NL' ? 'Dutch' : preferredLanguage == 'FR' ? 'French' : preferredLanguage == 'EN' ? 'English' : '';
                currentCase.Supplied_Birthdate__c           = email.plainTextBody.substringBetween('<birthday>','</birthday>') != null ? email.plainTextBody.substringBetween('<birthday>','</birthday>') : '';
                currentCase.Country_Code__c                 = countryCode.equalsIgnoreCase('Belgique') || countryCode.equalsIgnoreCase('België') ? 'BE' : countryCode.equalsIgnoreCase('Luxembourg') || countryCode.equalsIgnoreCase('Luxemburg') ? 'LU' : 'BE';
                currentCase.Supplied_Account_Type__c        = email.plainTextBody.substringBetween('<type>','</type>') != null ? email.plainTextBody.substringBetween('<type>','</type>') : '';
                }
                catch(Exception ex){
                    errors.add(ex.getMessage());
                }
                
            
            currentCase.Origin          = 'Web';
            //currentCase.Country_Code__c = presets.Country_Code__c;
            currentCase.Priority        = presets.Priority__c;
            RecordType caseRecordType   = ECICRecordTypeDao.findByDeveloperName(presets.RecordType_DeveloperName__c);
                if (caseRecordType != null) { currentCase.RecordTypeId = caseRecordType.id; } 
                else 
                {
                    String errorMessage = 'No Case RecordType found in '+SERVICE_NAME+' Presets to name ['+presets.RecordType_DeveloperName__c+']';
                    System.debug(LoggingLevel.WARN, errorMessage);
                    errors.add(errorMessage);
                }
                
                Group caseQueue = ECICGroupDao.findQueueByDeveloperName(presets.Queue_DeveloperName__c);
                
                if (caseQueue != null) { currentCase.ownerId = caseQueue.id; } 
                else 
                {
                    String errorMessage = 'No Case queue found in '+SERVICE_NAME+' Presets to name ['+presets.Queue_DeveloperName__c+']';
                    System.debug(LoggingLevel.WARN, errorMessage);
                    errors.add(errorMessage);
        
                    currentCase.ownerId = Userinfo.getUserId();                                             // Set the service executing user as Case owner
                }
    
    }
    
    public static void parseEmailandSetCaseFieldsForNehtherlandsCases(Case currentCase, Messaging.InboundEmail email,  EmailToCasePresets__c presets,List<String> errors){
        
        List <Belux_Web_Cases_XML_to_SFDC_Mapping__c> fieldValues = Belux_Web_Cases_XML_to_SFDC_Mapping__c.getAll().values();
        String accountType = null;
        String title = null;
        String reason = null;
        
        
        try{
                email.plainTextBody = String.isNotBlank(email.plainTextBody) ? email.plainTextBody : email.htmlBody;
                
                String phoneNumber = email.plainTextBody.substringBetween('<phone>','</phone>') != null ? email.plainTextBody.substringBetween('<phone>','</phone>') : '';
                phoneNumber = formatPhone(phoneNumber);
                
                String fax = email.plainTextBody.substringBetween('<fax>','</fax>') != null ? email.plainTextBody.substringBetween('<fax>','</fax>') : '';
                fax = formatPhone(fax);
                
                String mobile = email.plainTextBody.substringBetween('<gsm>','</gsm>') != null ? email.plainTextBody.substringBetween('<gsm>','</gsm>') : '';
                mobile = formatPhone(mobile);
                
                currentCase.SuppliedFirstName__c            = email.plainTextBody.substringBetween('<firstname>','</firstname>') != null ? email.plainTextBody.substringBetween('<firstname>','</firstname>') : '' + ' ' +
                                                              email.plainTextBody.substringBetween('<middlename>','</middlename>') != null ? email.plainTextBody.substringBetween('<middlename>','</middlename>') : '';
                currentCase.SuppliedLastName__c             = email.plainTextBody.substringBetween('<name>','</name>') != null ? email.plainTextBody.substringBetween('<name>','</name>') : '';
                currentCase.suppliedName                    = currentCase.SuppliedFirstName__c + ' ' + currentCase.SuppliedLastName__c;
                currentCase.SuppliedMailing_Streetname1__c  = email.plainTextBody.substringBetween('<address>','</address>') != null ? email.plainTextBody.substringBetween('<address>','</address>') : '';
                currentCase.SuppliedMailingCity__c          = email.plainTextBody.substringBetween('<city>','</city>') != null ? email.plainTextBody.substringBetween('<city>','</city>') : '';
                currentCase.SuppliedMailingZip__c           = email.plainTextBody.substringBetween('<zip>','</zip>') != null ? email.plainTextBody.substringBetween('<zip>','</zip>') : '';
                currentCase.suppliedPhone                   = phoneNumber;
                currentCase.SuppliedMobile__c               = mobile;
                currentCase.supplied_Fax__c                 = fax;
                currentCase.suppliedEmail                   = email.plainTextBody.substringBetween('<email>','</email') != null ? email.plainTextBody.substringBetween('<email>','</email') : '';
                currentCase.description                     = email.plainTextBody.substringBetween('<message>','</message>') != null ? email.plainTextBody.substringBetween('<message>','</message>') : '';
                String preferredLanguage                    = email.plainTextBody.substringBetween('<lang>','</lang>') != null ? email.plainTextBody.substringBetween('<lang>','</lang>') : '';
                currentCase.supplied_Preferred_Language__c  = preferredLanguage == 'NL' ? 'Dutch' : preferredLanguage == 'FR' ? 'French' : preferredLanguage == 'EN' ? 'English' : '';
                currentCase.Supplied_Birthdate__c           = email.plainTextBody.substringBetween('<birthday>','</birthday>') != null ? email.plainTextBody.substringBetween('<birthday>','</birthday>') : '';
                
                
                //fields to be added from Belux Web Cases XML to SFDC Mapping custom settings.
                accountType                                 = email.plainTextBody.substringBetween('<type>','</type>') != null ? email.plainTextBody.substringBetween('<type>','</type>') : '';
                title                                       = email.plainTextBody.substringBetween('<title>','</title>') != null ? email.plainTextBody.substringBetween('<title>','</title>') : '';
                reason                                      = email.plainTextBody.substringBetween('<contactreason>','</contactreason>') != null ? email.plainTextBody.substringBetween('<contactreason>','</contactreason>') : '';
                
                }
                catch(Exception ex){
                    errors.add(ex.getMessage());
                }
                
            Boolean typeFound = false;
            Boolean titlefound = false;
            Boolean reasonFound = false;
                
            for(Belux_Web_Cases_XML_to_SFDC_Mapping__c fv : fieldValues ){
                
                    if(fv.Field_Name__c.equalsIgnoreCase('type') && fv.Web_Form_Value__c.equalsIgnoreCase(accountType) && !typeFound ){
                        currentCase.Supplied_Account_Type__c = fv.Salesforce_Field_Value__c;
                        typeFound = true;
                    }
                    if(fv.Field_Name__c.equalsIgnoreCase('title') && fv.Web_Form_Value__c.equalsIgnoreCase(title) && !titlefound ){
                        currentCase.Supplied_Title__c = fv.Salesforce_Field_Value__c;
                        titleFound = true;
                    }
                    if(fv.Field_Name__c.equalsIgnoreCase('reason') && fv.Web_Form_Value__c.equalsIgnoreCase(reason) && !reasonFound ){
                        currentCase.reason = fv.Salesforce_Field_Value__c;
                        reasonFound = true;
                    }
                    if(typeFound && titleFound && reasonFound )
                    break;
                }
                
            
            currentCase.subject = currentCase.reason != null ? currentCase.reason : email.subject;
            currentCase.Origin          = 'Web';
            currentCase.Country_Code__c = presets.Country_Code__c;
            currentCase.Priority        = presets.Priority__c;
            RecordType caseRecordType   = ECICRecordTypeDao.findByDeveloperName(presets.RecordType_DeveloperName__c);
                if (caseRecordType != null) { currentCase.RecordTypeId = caseRecordType.id; } 
                else 
                {
                    String errorMessage = 'No Case RecordType found in '+SERVICE_NAME+' Presets to name ['+presets.RecordType_DeveloperName__c+']';
                    System.debug(LoggingLevel.WARN, errorMessage);
                    errors.add(errorMessage);
                }
                
                Group caseQueue = ECICGroupDao.findQueueByDeveloperName(presets.Queue_DeveloperName__c);
                
                if (caseQueue != null) { currentCase.ownerId = caseQueue.id; } 
                else 
                {
                    String errorMessage = 'No Case queue found in '+SERVICE_NAME+' Presets to name ['+presets.Queue_DeveloperName__c+']';
                    System.debug(LoggingLevel.WARN, errorMessage);
                    errors.add(errorMessage);
        
                    currentCase.ownerId = Userinfo.getUserId();                                             // Set the service executing user as Case owner
                }
    
    }
    
    private static String formatPhone(String phone){
        String phoneNumber = phone.deleteWhitespace();
        phoneNumber = phoneNumber.replaceAll('-', '');
        return phoneNumber;
    }
    
    public static Boolean filterSpamEmails(Messaging.InboundEmail email, Boolean filterOnBasisOfBody){
        Boolean ignoreEmail = false;
        if(filterOnBasisOfBody){
            email.htmlBody= email.htmlBody!= null ? email.htmlBody: ''; // Added in case the email HTML Body is null.
            String emailBody = String.isNotBlank(email.plainTextBody) ? email.plainTextBody : email.htmlBody;
                     
            String actualEmail = emailBody.substringBetween('<email>','</email') != null ? emailBody.substringBetween('<email>','</email') : '';
            //String compareEmail = 'sample@email.tst';
            List <GB_Spam_Emails__c> fieldValues = GB_Spam_Emails__c.getAll().values();
            for(GB_Spam_Emails__c emails : fieldValues ){
                if(emails.name.equalsIgnoreCase(actualEmail)){
                    ignoreEmail = true;
                    break;
                    
                }
            }
            //}
            return ignoreEmail;
            
            
        }
        else{
            String fromEmail = email.fromAddress;
            List <Spam_Emails_List__c> spamEmails = Spam_Emails_List__c.getAll().values();
            for(Spam_Emails_List__c se : spamEmails){
                if(se.Email_Address__c.equalsIgnoreCase(fromEmail)){
                    ignoreEmail = true;
                    break;
                }
            }
            
            return ignoreEmail;
        }
            
    }
}