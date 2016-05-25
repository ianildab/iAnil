public /* with sharing */ class ECICCaseToJsonCsvController {
    /*
    public static final String CASES_PARAM_NAME = 'cases';
    
    private static final String SFDC_CALLOUT_AGENT = 'SFDC-Callout';
    private static final Set<String> EXPORT_FIELD_KEYWORD = new Set<String>{ 'EXPORT_CODE', 'EXPORT_MOTIF_MAPPING', 'EXPORT_RED_FLAG', 'EXPORT_SENSITIVE_FLAG', 'EXPORT_CONTACT_CITY' };
    private static final ECICCaseQComplaintsExportHelper.CSVCaseFieldLists CSV_CASE_FIELD_LISTS = ECICCaseQComplaintsExportHelper.buildSortedCaseFieldLists(); // As not to overengineer this, this is NOT country-specific.
    public Case testCase {get;set;}    
    private String csvExport;
     
    public ECICCaseToJsonCsvController() {
        debugHeaders();
        
        if (verifyClientAccess()) {
            createCsvExport();
        }
    }
    
    public String getCsvExport() {
        return csvExport;
    }
    
    private void debugHeaders() {
        for (String key : ApexPages.currentPage().getHeaders().keySet()) {
            System.debug(LoggingLevel.DEBUG, '---- '+key+': '+ApexPages.currentPage().getHeaders().get(key));
        }        
    }
    
    private Boolean verifyClientAccess() {
        // Access is only allowed from SFDC
        String userAgent = ApexPages.currentPage().getHeaders().get('User-Agent');
        Boolean result = false;
        if(!Test.isRunningTest()){
            if(userAgent != null && userAgent.contains(SFDC_CALLOUT_AGENT)) 
            {
                result = true;
            }
            else
            {
                result = false;
            }
        } 
        else
        {
            result = true;   
        }
        return result;
    }
    
    private void createCsvExport() {
        List<Case> cases;
        if(!Test.isRunningTest()){
            cases = deserializeCases();
        }
        else
        {
            cases = new List<Case>{testCase};
        }
        
        if (cases != null && ! cases.isEmpty()) {
            csvExport = createCsv(cases);
            System.debug(LoggingLevel.DEBUG, 'ECICCaseToJsonCsvController.createCsvExport() csvExport: ' + csvExport);
        } else {    
            System.debug(LoggingLevel.WARN, 'ECICCaseToJsonCsvController.createCsvExport() Deserialized list is NULL or empty');
        }
    }
    
    private List<Case> deserializeCases() {
        List<Case> result = null;
        String jsonCases = ApexPages.currentPage().getParameters().get(CASES_PARAM_NAME);
        jsonCases = EncodingUtil.base64Decode(jsonCases).toString();
        System.debug(LoggingLevel.DEBUG, '----- ECICCaseToJsonCsvController.deserializeCases(): json = '+jsonCases);        

        if (String.isNotBlank(jsonCases)) {
            try {
                result = (List<Case>) JSON.deserialize(jsonCases, List<Case>.class);
            } catch (Exception ex) {
                System.debug(LoggingLevel.WARN, 'Exception occured during JSON deserialization. Error message: '+ex.getMessage() + '\nJSON: '+jsonCases);
                result = null;
            }            
        } else {
            System.debug(LoggingLevel.WARN, 'POST parameter '+CASES_PARAM_NAME+' is empty.');
        }
        
        return result;
    }
    
    private String createCsv(List<Case> countryCaseList) {
        String result = '';    // While previously inclined to initialize this to a header for the CSV, I was informed that no header is required/desired.
        if (countryCaseList != null && !countryCaseList.isEmpty()) {
            for (Case countryCase : countryCaseList) {
                result += createCsvRow(countryCase); 
            }
        }
        
        return result; 
    }
    
    private String createCsvRow(Case countryCase) {
        String rowString = '';

        for (String csvFieldName : CSV_CASE_FIELD_LISTS.exportFieldList) {
            rowString += createRowElement(countryCase, csvFieldName); 
        }
        
        rowString = rowString.replaceAll('[\\n\\r]+',' ');                      // Remove new line and carriage return;    ( add \\t if tabs need to be removed )
        
        return (rowString.length() > 0 ? rowString.substring(1) : '') + '\n';
    }
    
    @testVisible private String createRowElement(Case countryCase, String csvFieldName) {
        String potentialElement = (EXPORT_FIELD_KEYWORD.contains(csvFieldName)) 
            ? transform (countryCase, csvFieldName)
            : transverse (countryCase, csvFieldName);
        
        return (!String.isBlank(potentialElement))
            ? ';"' + potentialElement + '"'
            : ';';
    }
    
    @testVisible private String transform (Case countryCase, String csvFieldName)
    {
        if      (csvFieldName == 'EXPORT_CODE')            { return getExportCode     (countryCase); }
        else if (csvFieldName == 'EXPORT_MOTIF_MAPPING')   { return getMotifMapping   (countryCase); }
        else if (csvFieldName == 'EXPORT_RED_FLAG')        { return getRedFlag        (countryCase); }
        else if (csvFieldName == 'EXPORT_SENSITIVE_FLAG')  { return getSensitiveFlag  (countryCase); }
        else if (csvFieldName == 'EXPORT_CONTACT_CITY')    { return getContactCity    (countryCase); }
        
        return null; // This should never happen!
    }
    
    @testVisible private String getExportCode   (Case countryCase) 
    { 
        if (countryCase.account == null) { return null; }
        
        String  accountExternalId     = countryCase.account.account_ext_id__c;
        if (accountExternalId == null)   { return countryCase.account.id; }
        
        String  usableExternalIdStart = (countryCase.Country_Code__c + 'CIC').toUpperCase();
        Boolean useExternalId         = ((accountExternalId).toUpperCase().startsWith(usableExternalIdStart));
        return  (useExternalId) 
            ? accountExternalId.subString(6)
            : countryCase.account.id;
    }
    
    @testVisible private String getMotifMapping (Case countryCase) 
    { 
        return countryCase.category_level3__c + '|' + countryCase.category_level4__c;
    }
    
    @testVisible private String getRedFlag      (Case countryCase) 
    { 
        return (countryCase.Potential_Risk__c == 'High Risk') ? '1' : '0'; 
    }
    
    @testVisible private String getSensitiveFlag(Case countryCase) 
    { 
        return (countryCase.Potential_Risk__c == 'Medium Risk') ? '1' : '0'; 
    }
    
    @testVisible private String getContactCity(Case countryCase)
    {
        if (countryCase.account.shipping_municipality__c != null) { return countryCase.account.shipping_municipality__c; }
        else if (countryCase.region_of_purchase__r.name  != null) { return countryCase.region_of_purchase__r.name;       }
                                                 return null;                            
    } 
    
    @testVisible private String transverse  (Case countryCase, String csvFieldName)
    {
        SObject      currentSObject = countryCase;
        String       fieldPath      = csvFieldName;
        
        while (fieldPath.contains('.'))
        {
            List<String> pathPartList   = fieldPath.split ('[.]', 2);
            String       sObjectName = pathPartList[0];
            
            currentSObject = (SObject) currentSObject.getSobject(sObjectName);
            if (currentSObject == null) { return null; } 
            fieldPath      = pathPartList[1];
            
        }
        
        return (currentSObject.get(fieldPath) != null)
            ? (      
                (fieldPath.toUpperCase().contains('DATE'))
                ? ECICCaseQComplaintsExportHelper.formatDatetime(currentSObject, fieldPath)
                : String.valueOf(currentSObject.get(fieldPath))
            )
            : null;
    }
    */
}