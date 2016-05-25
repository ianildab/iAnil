// @see CIC-499, CIC-1112 
// @see https://developer.salesforce.com/forums/ForumsMain?id=906F000000090JcIAI 
global class ECICCaseExportQualityComplaintsSchedable implements Schedulable 
{
    public static Boolean isExecuting = false;
    
    @testVisible private class CSVCaseFieldLists{
        @testVisible private List<String> queryFieldList  = new List<String>();
        @testVisible private List<String> exportFieldList = new List<String>();
    }
    
    @testVisible private static final Boolean CASELEGACY3UPDATENEEDED = (!Test.isRunningTest())
                                                                ? General_Settings__c.getInstance().CSVExportUpdateLegacyInfo3__c
                                                                : FALSE;

    
    @testVisible private static final String              EXPORT_FOLDER_NAME = 'CIC_CRIS_exports';
    @testVisible private static final Id                  EXPORT_FOLDER_ID   = (!Test.isRunningTest())
                                                                                    ? [SELECT id FROM Folder WHERE DeveloperName = :EXPORT_FOLDER_NAME              LIMIT 1].id
                                                                                    : [SELECT id FROM Folder WHERE (type = 'Document' ) AND (accessType = 'Public') LIMIT 1].id;

    @testVisible private static final Set<String>         EXPORT_FIELD_KEYWORD           = new Set<String>{ 'EXPORT_CODE', 'EXPORT_MOTIF_MAPPING', 'EXPORT_RED_FLAG', 'EXPORT_SENSITIVE_FLAG', 'EXPORT_CONTACT_CITY' };
    @testVisible private static final Map<String, String> RECIPIENT_EMAIL_BY_COUNTRY_CODE = buildRecipientEmailByCountryCodeMap();
    @testVisible private static final CSVCaseFieldLists   CSV_CASE_FIELD_LISTS           = buildSortedCaseFieldLists();             // As not to overengineer this, this is NOT country-specific.

    @testVisible private static List<Document> documentToSaveList = new List<Document>();
    
    global void execute (Boolean updateCases) {
        sendQualityComplaintExportCSV(updateCases);
    }   
    
    global void execute (SchedulableContext schedulableContext){
        sendQualityComplaintExportCSV(CASELEGACY3UPDATENEEDED);
    }
    
    public static void sendQualityComplaintExportCSV(Boolean updateCases){
        if (!RECIPIENT_EMAIL_BY_COUNTRY_CODE.isEmpty()){ 
            Map<String, List<Case>> selectedCaseListByCountryCodeMap = ECICCaseDao.selectRecentQualityComplaintCaseListByCountryCodeMap(CSV_CASE_FIELD_LISTS.queryFieldList, RECIPIENT_EMAIL_BY_COUNTRY_CODE.keySet());
            List<Case> updateCaseList = setLegacyInfo3(selectedCaseListByCountryCodeMap);
            addEmptyCaseLists(selectedCaseListByCountryCodeMap);

            List<Messaging.SingleEmailMessage> emailMessageList = new List<Messaging.SingleEmailMessage>();
            for (String countryCode : selectedCaseListByCountryCodeMap.keySet()){
               emailMessageList.add(createEmail(RECIPIENT_EMAIL_BY_COUNTRY_CODE.get(countryCode), selectedCaseListByCountryCodeMap.get(countryCode))); 
            }

            if (!emailMessageList.isEmpty()) { 
                SEPEmailSendHelper.sendMails(emailMessageList); 
            }
            if (!documentToSaveList.isEmpty())  {
                insert documentToSaveList;
            }
            if (updateCases && !updateCaseList.isEmpty()){ 
                SEPTriggerHandlerInvoker.skipObjectTriggerInvocation('Case', true);
                update updateCaseList;
            }
        }
    }

    @testVisible private static List<Case> setLegacyInfo3(Map<String, List<Case>> selectedCaseListByCountryCodeMap){
        Datetime timestamp = System.now();
        List<Case> updateCaseList = new List<Case>();
        for (List<Case> caseList : selectedCaseListByCountryCodeMap.values()){
            for (Case currentCase : caseList){
                currentCase.Legacy_Info3__c =  formatDatetime (timestamp, 'dd/MM/yyyy HH:mm:ss');
                updateCaseList.add(currentCase);
            }
        }
        return updateCaseList;
    }

    @testVisible private static void addEmptyCaseLists(Map<String, List<Case>> selectedCaseListByCountryCodeMap){
        for (String countryCode : RECIPIENT_EMAIL_BY_COUNTRY_CODE.keySet()){
            if (!selectedCaseListByCountryCodeMap.containsKey(countryCode)) { 
                selectedCaseListByCountryCodeMap.put(countryCode, null); 
            }
        }
    }
    
    @testVisible private static Map<String, String> buildRecipientEmailByCountryCodeMap(){
        List<Country_Specific_Settings__c> countrySpecificSettingsList = Country_Specific_Settings__c.getAll().values();
        
        Map<String, String> recipientEmailByCountryCodeMap = new Map<String, String>();
        for  (Country_Specific_Settings__c countrySpecificSettings :  countrySpecificSettingsList){
            if (countrySpecificSettings.quality_complaint_export_recipients__c != null){
                recipientEmailByCountryCodeMap.put (countrySpecificSettings.name, countrySpecificSettings.quality_complaint_export_recipients__c);
            }
        }
        
        return recipientEmailByCountryCodeMap;
    }
    
    @testVisible private static CSVCaseFieldLists buildSortedCaseFieldLists(){
        Map<Integer, String> caseFieldByRankMap  = getCaseFieldByRankMap();
        
        List<Integer>        rankList            = (new List<Integer>(caseFieldByRankMap.keySet()));
                             rankList.sort();
        
        CSVCaseFieldLists csvCaseFieldLists = new CSVCaseFieldLists();
        List<String>         sortedCaseFieldList = new List<String>();
        for (Integer rank : rankList){ 
            String caseField = caseFieldByRankMap.get(rank);
            csvCaseFieldLists.exportFieldList.add(caseField); 
            
            if (!(EXPORT_FIELD_KEYWORD.contains(caseField))) {
                csvCaseFieldLists.queryFieldList.add(caseField);
            } 
        }
        return csvCaseFieldLists;
    }
    
    @testVisible private static Map<Integer, String> getCaseFieldByRankMap(){
        List<Quality_Complaint_Export_Configuration__c> qualityComplaintExportConfigList = Quality_Complaint_Export_Configuration__c.getAll().values();
        Map<Integer, String> caseFieldByRankMap = new Map<Integer, String>();
        for  (Quality_Complaint_Export_Configuration__c qualityComplaintExportConfig :  qualityComplaintExportConfigList){
            caseFieldByRankMap.put ((Integer) qualityComplaintExportConfig.export_field_rank__c , qualityComplaintExportConfig.sfdc_case_fieldpath__c );
        }
        return caseFieldByRankMap;
    }
    
    @testVisible private static Messaging.SingleEmailMessage createEmail(String recipientEmail, List<Case> countryCaseList){
        String csvName      = 'CaseList.csv';
        Blob   csvDataBlob  = createDataBlob(countryCaseList);
        
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
                                      csvAttachment.setFileName(csvName);
                                      csvAttachment.setBody(csvDataBlob);
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
    
    @testVisible private static Blob createDataBlob(List<Case> countryCaseList){
        String dataString = '';    // While previously inclined to initialize this to a header for the CSV, I was informed that no header is required/desired.
        if (countryCaseList != null && !countryCaseList.isEmpty()){
            for (Case countryCase : countryCaseList) {
                dataString += createRowString(countryCase); 
            }
        }
        else { 
            dataString += '\n';   // If the dataString is truly empty, it the blob will cause an error when attached to an email.
        }
        Blob csvBlob = Blob.valueOf(dataString);
        addDocumentToSave(csvBlob);                                            // Possibly not the "best" place for this, but the path of least resistence.
        
        return csvBlob; 
    }

    @testVisible private static void addDocumentToSave(Blob csvDataBlob){
        Document newDocument = new Document();
                 newDocument.name        = 'Export_' + ((Datetime) Date.today()).format('yyyy_MM_dd') + '.csv';
                 newDocument.folderId    = EXPORT_FOLDER_ID;                    // WARNING: Does NOT currently support different folders for different countries!!!
                 newDocument.body        = csvDataBlob;
                 newDocument.contentType = 'text/csv';
                 newDocument.type        = 'txt';
          documentToSaveList.add(newDocument);
    }
    
    @testVisible private static String createRowString (Case countryCase){
        String rowString = '';
        for (String csvFieldName : CSV_CASE_FIELD_LISTS.exportFieldList) {
            rowString += createRowElement(countryCase, csvFieldName);
        }

        rowString = rowString.replaceAll('[\\n\\r]+',' ');                      // Remove new line and carriage return;    ( add \\t if tabs need to be removed )

        return (removeFinalCharacter(rowString) + '\n'); // removeFinalCharacter removes the last comma
    }
    
    @testVisible private static String createRowElement(Case countryCase, String csvFieldName){
        String potentialElement = (EXPORT_FIELD_KEYWORD.contains(csvFieldName)) 
                            ? transform (countryCase, csvFieldName)
                               : transverse (countryCase, csvFieldName);

         return (!String.isBlank(potentialElement))
                    ? '"' + potentialElement + '";'
                    : ';';
       }

    @testVisible private static String transform (Case countryCase, String csvFieldName){
        if      (csvFieldName == 'EXPORT_CODE')            { 
            return getExportCode     (countryCase); }
        else if (csvFieldName == 'EXPORT_MOTIF_MAPPING')   { 
            return getMotifMapping   (countryCase); }
        else if (csvFieldName == 'EXPORT_RED_FLAG')        { 
            return getRedFlag        (countryCase); }
        else if (csvFieldName == 'EXPORT_SENSITIVE_FLAG')  { 
            return getSensitiveFlag  (countryCase); }
        else if (csvFieldName == 'EXPORT_CONTACT_CITY')    { 
            return getContactCity    (countryCase); }
        
        return null; // This should never happen!
    }
    
    @testVisible private static String getExportCode   (Case countryCase){ 
        if (countryCase.account == null) { 
            return null;
        }
         
        String  accountExternalId     = countryCase.account.account_ext_id__c;
        if (accountExternalId == null)   { 
            return countryCase.account.id;
        }

        String  usableExternalIdStart = (countryCase.Country_Code__c + 'CIC').toUpperCase();
        Boolean useExternalId         = ((accountExternalId).toUpperCase().startsWith(usableExternalIdStart));
        return  (useExternalId) 
                   ? accountExternalId.subString(6)
                   : countryCase.account.id;
    }
    
    @testVisible private static String getMotifMapping (Case countryCase){ 
        return countryCase.category_level3__c + '|' + countryCase.category_level4__c;
    }
    
    @testVisible private static String getRedFlag      (Case countryCase){ 
        return (countryCase.Potential_Risk__c == 'High Risk') ? '1' : '0'; 
    }
    
    @testVisible private static String getSensitiveFlag(Case countryCase){ 
        return (countryCase.Potential_Risk__c == 'Medium Risk') ? '1' : '0'; 
    }

    @testVisible private static String getContactCity(Case countryCase){
        if (countryCase.account.shipping_municipality__c != null) { 
            return countryCase.account.shipping_municipality__c; }
        else if (countryCase.region_of_purchase__r.name  != null) { 
            return countryCase.region_of_purchase__r.name;       }
        /* else */                                                  return null;                            
    } 

    @testVisible private static String transverse  (Case countryCase, String csvFieldName){
        SObject      currentSObject = countryCase;
        String       fieldPath      = csvFieldName;
        
        while (fieldPath.contains('.')){
            List<String> pathPartList   = fieldPath.split ('[.]', 2);
            String       sObjectName = pathPartList[0];
            
                         currentSObject = (SObject) currentSObject.getSobject(sObjectName);
                         if (currentSObject == null) { return null; } 
                         fieldPath      = pathPartList[1];

        }
        
        return (currentSObject.get(fieldPath) != null)
                ? (      
                        (fieldPath.toUpperCase().contains('DATE'))
                        ? formatDatetime(currentSObject, fieldPath)
                            : String.valueOf(currentSObject.get(fieldPath))
                  )
                : null;
    }
    
    // @see https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_methods_system_datetime.htm#apex_System_Datetime_format_3
    @testVisible private static String formatDatetime (SObject currentSObject, String fieldPath){
        String dateFormat = 'dd/MM/yyyy' + ((fieldPath == 'CREATEDDATE') ? ' HH:mm:ss' : '');
        return formatDatetime ( ((Datetime) (currentSObject.get(fieldPath))), dateFormat );
    }

    @testVisible private static String formatDatetime (Datetime timestamp, String dateFormat){
        return timestamp.format(dateFormat, 'Europe/Paris');
    }

    // IMPORTANT: This does NOT check if the last character is actually comma!
    @testVisible private static String removeFinalCharacter(String value){
        Integer valueLength = value.length();
        return value.subString (0, valueLength-1);          // SubString to delete extra comma; otherwise we need to check before adding.
    }
}