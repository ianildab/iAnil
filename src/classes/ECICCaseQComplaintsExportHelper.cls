public class ECICCaseQComplaintsExportHelper {
    
    @testVisible private static final Set<String> EXPORT_FIELD_KEYWORD = new Set<String>{ 'EXPORT_CODE', 'EXPORT_MOTIF_MAPPING', 'EXPORT_RED_FLAG', 'EXPORT_SENSITIVE_FLAG', 'EXPORT_CONTACT_CITY' };
        
   	@testVisible public class CSVCaseFieldLists
    {
        @testVisible public List<String> queryFieldList  = new List<String>();
        @testVisible public List<String> exportFieldList = new List<String>();
    }
    
    @testVisible public static CSVCaseFieldLists buildSortedCaseFieldLists()
    {
        Map<Integer, String> caseFieldByRankMap  = getCaseFieldByRankMap();
        
        List<Integer>        rankList            = (new List<Integer>(caseFieldByRankMap.keySet()));
        rankList.sort();
        
        CSVCaseFieldLists csvCaseFieldLists = new CSVCaseFieldLists();
        List<String>         sortedCaseFieldList = new List<String>();
        for (Integer rank : rankList) 
        { 
            String caseField = caseFieldByRankMap.get(rank);
            csvCaseFieldLists.exportFieldList.add(caseField); 
            
            if (!(EXPORT_FIELD_KEYWORD.contains(caseField))) { csvCaseFieldLists.queryFieldList.add(caseField); } 
        }
        return csvCaseFieldLists;
    }
    
    @testVisible private static Map<Integer, String> getCaseFieldByRankMap()
    {
        List<Quality_Complaint_Export_Configuration__c> qualityComplaintExportConfigList = Quality_Complaint_Export_Configuration__c.getAll().values();
        Map<Integer, String> caseFieldByRankMap = new Map<Integer, String>();
        for  (Quality_Complaint_Export_Configuration__c qualityComplaintExportConfig :  qualityComplaintExportConfigList)
        {
            caseFieldByRankMap.put ((Integer) qualityComplaintExportConfig.export_field_rank__c , qualityComplaintExportConfig.sfdc_case_fieldpath__c );
        }
        return caseFieldByRankMap;
    }
    
    // @see https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_methods_system_datetime.htm#apex_System_Datetime_format_3
    public static String formatDatetime (SObject currentSObject, String fieldPath)
    {
        String dateFormat = 'dd/MM/yyyy' + ((fieldPath == 'CREATEDDATE') ? ' HH:mm:ss' : '');
        return formatDatetime ( ((Datetime) (currentSObject.get(fieldPath))), dateFormat );
    }
    
    public static String formatDatetime (Datetime timestamp, String dateFormat)
    {
        return timestamp.format(dateFormat, 'Europe/Paris');
    }
}