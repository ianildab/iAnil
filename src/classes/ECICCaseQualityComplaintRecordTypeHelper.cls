global class ECICCaseQualityComplaintRecordTypeHelper 
{ 
    private static final Map<Id,RecordType> CASE_RECORD_TYPES_BY_ID_MAP   = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);
    public  static final Set<String>        QUALITY_COMPLAINT_NAME_SET    = new Set<String>{'Quality Complaint'}; 
    
    public  static final Set<Id>            QUALITY_COMPLAINT_ID_SET      = buildQualityComplaintIdSet();
    public  static final String             QUALITY_COMPLAINT_SOQL_ID_SET = buildQualityComplaintSoqlIdSet();
    public  static final Id                 DEFAULT_QUALITY_COMPLAINT_ID  = SEPRecordTypesCache.GetRecordTypeIdsByDeveloperNameMap(Case.SObjectType).get('Quality_Complaint');
    @testVisible
    private static       String             errMessage                    = null;
    
    private static Set<Id> buildQualityComplaintIdSet()
    {
        Set<Id> qualityComplaintIdSet = new Set<Id>();
        for (Id key : CASE_RECORD_TYPES_BY_ID_MAP.keySet())
        {
            String recordTypeName = CASE_RECORD_TYPES_BY_ID_MAP.get(key).Name;
            if (recordTypeName.startsWith(ECICCommonConstants.QUALITY_COMPLAINT))
            {
                qualityComplaintIdSet.add (key);
            }
        }
        return qualityComplaintIdSet;
    }
    
     public static Set<Id> buildNonQualityComplaintIdSet()
    {
        Set<Id> nonQualityComplaintIdSet = new Set<Id>();
        for (Id key : CASE_RECORD_TYPES_BY_ID_MAP.keySet())
        {
            String recordTypeName = CASE_RECORD_TYPES_BY_ID_MAP.get(key).Name;
            if (recordTypeName.startsWith(ECICCommonConstants.NON_QUALITY_COMPLAINT)){
                nonQualityComplaintIdSet.add (key);
            }
        }
        return nonQualityComplaintIdSet;
    }
    
    private static String buildQualityComplaintSoqlIdSet()
    {
        String   qualityComplaintSoqlIdSet = '(';
        List<Id> qualityComplaintList = new List<Id>(QUALITY_COMPLAINT_ID_SET);
        for (Integer i=1; i <= qualityComplaintList.size(); i++)
        {
                qualityComplaintSoqlIdSet += '\'' + qualityComplaintList[(i-1)] + '\'' + ((i != qualityComplaintList.size())?',':'') ;  
        }
               qualityComplaintSoqlIdSet += ')';
        return qualityComplaintSoqlIdSet;
    }

    webService static String getCountrySpecificRecordTypeId (String countryCode)
    {
        return (
                (Country_Specific_Settings__c.getValues(countryCode) != null)
                && (Country_Specific_Settings__c.getValues(countryCode).quality_complaint_record_type_id__c != null)
               )
                ? Country_Specific_Settings__c.getValues(countryCode).quality_complaint_record_type_id__c
                : 'COUNTRY_QUALITY_COMPLAINT_NOT_SET';
    }

    public static Id getCountrySpecificRecordTypeId (Case currentCase)
    {
        Id returnId = currentCase.recordTypeId;
        if (isQualityComplaint (CASE_RECORD_TYPES_BY_ID_MAP.get(currentCase.recordTypeId)))
        {
            try { returnId = (ID) getCountrySpecificRecordTypeId (currentCase.country_code__c); } 
            catch(Exception e) {
                currentCase.addError('Could not reassign Quality Complaint RecordType for country code ' + currentCase.country_code__c + '.');
                if (Test.isRunningTest()) { errMessage = 'Could not reassign Quality Complaint RecordType for country code ' + currentCase.country_code__c + '.'; }
            }
        }
        return returnId;
    }
    
    public static Boolean isQualityComplaint (String recordTypeName) { return recordTypeName.startsWith(ECICCommonConstants.QUALITY_COMPLAINT); }
    public static Boolean isQualityComplaint (RecordType recordType) { return isQualityComplaint (recordType.Name); }
    public static Boolean isQualityComplaint (Id recordTypeId)       { return isQualityComplaint (CASE_RECORD_TYPES_BY_ID_MAP.get(recordTypeId)); }
}