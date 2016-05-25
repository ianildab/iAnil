global class ECICCaseQComplaintsExportSchedule {
/*
    //implements Schedulable
    @testVisible private static final String CSV_EXPORT_PAGE_URL = (!Test.isRunningTest())
                                                                        ? General_Settings__c.getInstance().CSVExportPage__c
                                                                        : 'https://salesforce.example.com/csv_export.page';
    
    @testVisible private static final ECICCaseQComplaintsExportHelper.CSVCaseFieldLists CSV_CASE_FIELD_LISTS = ECICCaseQComplaintsExportHelper.buildSortedCaseFieldLists(); // As not to overengineer this, this is NOT country-specific.
    @testVisible private static final String EXPORT_FOLDER_NAME = 'CIC_CRIS_exports';
    @testVisible private static final Id     EXPORT_FOLDER_ID   = (!Test.isRunningTest())
                                                                        ? [SELECT id FROM Folder WHERE DeveloperName = :EXPORT_FOLDER_NAME              LIMIT 1].id
                                                                        : [SELECT id FROM Folder WHERE (type = 'Document' ) AND (accessType = 'Public') LIMIT 1].id;
    
    @testVisible private static List<Document> documentToSaveList = new List<Document>();
    
    @testVisible private static final Boolean CASELEGACY3UPDATENEEDED = (!Test.isRunningTest())
                                                                        ? General_Settings__c.getInstance().CSVExportUpdateLegacyInfo3__c
                                                                        : FALSE;
    
    global void execute (Boolean updateCases) {
        futureCreateAndSendCsvExport(updateCases);
    }
    
    global void execute (SchedulableContext schedulableContext) {
        futureCreateAndSendCsvExport(CASELEGACY3UPDATENEEDED);
    }
    
    @future(callout=true) 
    @testVisible private static void futureCreateAndSendCsvExport(Boolean updateCases) 
    {
        createAndSendCsvExport(updateCases);
    }
    
    @testVisible private static void createAndSendCsvExport(Boolean updateCases) 
    {
        Map<String, String> recipientEmailByCountryCode = buildRecipientEmailByCountryCodeMap();

        if (! recipientEmailByCountryCode.isEmpty()) {
            Map<String, List<Case>> selectedCaseListByCountryCodeMap = ECICCaseDao.selectRecentQualityComplaintCaseListByCountryCodeMap(CSV_CASE_FIELD_LISTS.queryFieldList, recipientEmailByCountryCode.keySet());

            if (! selectedCaseListByCountryCodeMap.isEmpty()) {
                addEmptyCaseLists(recipientEmailByCountryCode.keySet(), selectedCaseListByCountryCodeMap);
                
                // Convert cases to json+csv via VF page call
                Map<String, Blob> csvCasesByCountryCodeMap = convertCasestoCsv(selectedCaseListByCountryCodeMap);
                
                if (csvCasesByCountryCodeMap != null && ! csvCasesByCountryCodeMap.isEmpty()) {

                    // Send each export to the corresponding email address.            
                    List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
                    for (String countryCode : csvCasesByCountryCodeMap.keySet()) {
                        emailMessageList.add(createEmail(recipientEmailByCountryCode.get(countryCode), csvCasesByCountryCodeMap.get(countryCode))); 
                    }
                    
                    if (!emailMessageList.isEmpty()) {
                        SEPEmailSendHelper.sendMails(emailMessageList);
                    }
                    
                    // Save CSV documents
                    if (!documentToSaveList.isEmpty()) {
                        insert documentToSaveList;
                    }
                    
                    // update Cases with the export date            
                    if (updateCases) { // case updated requested
                        List<Case> updateCaseList = setLegacyInfo3(selectedCaseListByCountryCodeMap);
                        
                        SEPTriggerHandlerInvoker.skipObjectTriggerInvocation('Case', true);
                        update updateCaseList;                          
                    }
                } else {
                    System.debug(LoggingLevel.WARN, 'Quality Complaints export creation seem failed, no/empty response received');
                }
            } else {
                System.debug(LoggingLevel.INFO, 'No Quality Complaints records to export');
            }
        } else {
            System.debug(LoggingLevel.WARN, 'No receipient is configured for Quality Complaints export');
        }
    }
    
    @testVisible private static Map<String, String> buildRecipientEmailByCountryCodeMap() {
        Map<String, String> recipientEmailByCountryCodeMap = new Map<String, String>();
        List<Country_Specific_Settings__c> countrySpecificSettingsList = Country_Specific_Settings__c.getAll().values(); 
        
        for  (Country_Specific_Settings__c countrySpecificSettings :  countrySpecificSettingsList) {
            if (String.isNotBlank(countrySpecificSettings.quality_complaint_export_recipients__c)) {
                recipientEmailByCountryCodeMap.put(countrySpecificSettings.name, countrySpecificSettings.quality_complaint_export_recipients__c);
            }
        }
        
        return recipientEmailByCountryCodeMap;
    }
    
    @testVisible private static void addEmptyCaseLists(Set<String> countryCodes, Map<String, List<Case>> selectedCaseListByCountryCodeMap)
    {
        for (String countryCode : countryCodes) {
            if (!selectedCaseListByCountryCodeMap.containsKey(countryCode)) {
                selectedCaseListByCountryCodeMap.put(countryCode, null);
            }
        }
    }
    
    @testVisible private static Messaging.SingleEmailMessage createEmail(String recipientEmail, Blob countryCasesCsv) {
        String csvName      = 'CaseList.csv';
        //addDocumentToSave(countryCasesCsv);
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
                                      csvAttachment.setFileName(csvName);
                                      csvAttachment.setBody(countryCasesCsv);
                                      csvAttachment.setContentType('text/csv');
                                      
        String[] toAddresses = recipientEmail.split(';');
        String   subject     ='Quality Complaint Export CSV';
        Messaging.SingleEmailMessage emailMessage =new Messaging.SingleEmailMessage();
                                     emailMessage.setSubject(subject);
                                     emailMessage.setToAddresses( toAddresses );
                                     emailMessage.setPlainTextBody(subject);
                                     emailMessage.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
        
        return emailMessage;
    } 

    @testVisible private static void addDocumentToSave(Blob csvDataBlob) {
        Document newDocument = new Document();
                 newDocument.name        = 'Export_' + ((Datetime) Date.today()).format('yyyy_MM_dd') + '.csv';
                 newDocument.folderId    = EXPORT_FOLDER_ID;                    // WARNING: Does NOT currently support different folders for different countries!!!
                 newDocument.body        = csvDataBlob;
                 newDocument.contentType = 'text/csv';
                 newDocument.type        = 'txt';
        
        documentToSaveList.add(newDocument);
    }

    @testVisible private static Map<String, Blob> convertCasestoCsv(Map<String, List<Case>> caseListByCountryCodeMap) {
        Map<String, Blob> result = new Map<String, Blob>();
        for ( String country : caseListByCountryCodeMap.keySet() ) {
            String jsonCaseList = JSON.serialize(caseListByCountryCodeMap.get(country));
            Blob caseCsv = getPageContent(jsonCaseList);
            if (caseCsv != null && caseCsv.size() > 0) {
                result.put(country, caseCsv);
            } else {
                System.debug(LoggingLevel.WARN, 'Empty answer received.');
            }
        }     
        return result;
    }
    
    @testVisible private static Blob getPageContent(String postContent) {
        System.debug(LoggingLevel.DEBUG, '---- ECICCaseQComplaintsExportSchedule.gePageContent(): postContent = '+postContent);
        
        Blob result = null;
        
        HttpRequest httpRequest = createRequest(postContent);
        
        Http http = new Http();
        HttpResponse httpResponse = http.send(httpRequest);
        
        boolean redirect = false;
        
        if(httpResponse.getStatusCode() >=300 && httpResponse.getStatusCode() <= 307 && httpResponse.getStatusCode() != 306) {
            do {
                redirect = false; // reset the value each time
                
                String location = httpResponse.getHeader('Location'); // get location of the redirect
                
                if(location != null) {
                    httpRequest = createRequest(postContent);
                    String cookie = httpResponse.getHeader('Cookie');
                    
                    if (String.isNotBlank(cookie)) {
                        httpRequest.setHeader('Cookie', httpResponse.getHeader('Cookie'));
                    }
                    
                    httpResponse = http.send(httpRequest);
                    
                    if(httpResponse.getStatusCode() != 500) { // 500 = fail
                        if(httpResponse.getStatusCode() >=300 
                           && httpResponse.getStatusCode() <= 307 
                           && httpResponse.getStatusCode() != 306) {
                               
                               redirect= true;
                           }
                    }
                }
                
            } while (redirect && Limits.getCallouts() != Limits.getLimitCallouts());
        }
        
        //result = httpResponse.getBodyAsBlob();        
        if ( httpResponse.getStatusCode() == 200 ) {
            result = httpResponse.getBodyAsBlob();
        } else {
            System.debug(LoggingLevel.ERROR,  'ECICCaseQComplaintsExportSchedule.gePageContent() returned with error code: ' + httpResponse.getStatusCode() + '\n BODY: \n' + httpResponse.getBody());
            //mailTosupport( httpResponse.getStatusCode(), httpResponse.getBodyAsBlob());
        }
        
        return result;
    }
    
    @testVisible private static HttpRequest createRequest(String postContent) {
        //String body = ECICCaseToJsonCsvController.CASES_MAP_PARAM_NAME+'='+EncodingUtil.urlEncode(postContent, 'UTF-8'); // ISO-8859-1, UTF-8 ???
        String body = ECICCaseToJsonCsvController.CASES_PARAM_NAME+'='+EncodingUtil.urlEncode(EncodingUtil.base64Encode(Blob.valueOf(postContent)), 'UTF-8');
//SFDC  
        //String body = ECICCaseToJsonCsvController.CASES_PARAM_NAME+'='+EncodingUtil.base64Encode(Blob.valueOf(postContent));
        //String body = ECICCaseToJsonCsvController.CASES_MAP_PARAM_NAME+'='+postContent;
        //Blob body = Blob.valueOf(postContent);
        
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(CSV_EXPORT_PAGE_URL); 
        httpRequest.setMethod('POST');
        System.debug(LoggingLevel.DEBUG, '---- ECICCaseQComplaintsExportSchedule.gePageContent(): body = '+String.valueOf(body));
        
//SFDC
        httpRequest.setHeader('Accept', 'text/csv; charset=ISO-8859-1; q=1,text/plain; charset=ISO-8859-1; q=0.8');
//SFDC
        httpRequest.setHeader('Accept-Charset', 'ISO-8859-1');
        httpRequest.setBody(body);
        return httpRequest;   
    }
    
    
    @testVisible private static List<Case> setLegacyInfo3(Map<String, List<Case>> selectedCaseListByCountryCodeMap)
    {
        Datetime timestamp = System.now();
        List<Case> updateCaseList = new List<Case>();
        for (List<Case> caseList : selectedCaseListByCountryCodeMap.values())
        {
            for (Case currentCase : caseList)
            {
                currentCase.Legacy_Info3__c =  ECICCaseQComplaintsExportHelper.formatDatetime(timestamp, 'dd/MM/yyyy HH:mm:ss');
                updateCaseList.add(currentCase);
            }
        }
        System.debug(LoggingLevel.DEBUG, '---- ECICCaseQComplaintsExportSchedule.setLegacyInfo3(): update = '+updateCaseList);
        return updateCaseList;
    }

*/    
}