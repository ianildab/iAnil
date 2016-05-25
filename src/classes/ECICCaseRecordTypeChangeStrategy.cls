public class ECICCaseRecordTypeChangeStrategy extends ECICCaseProcessingStrategyAbstract //commenting this whole class since we are not using this strategy.
{   /*comment block 1 start
    private static final Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP                = SEPRecordTypesCache.getRecordTypesByIdMap(Case.SObjectType);
    private static final Map<String,Id>     RECORD_TYPES_ID_BY_DEVELOPER_NAME_MAP = SEPRecordTypesCache.getRecordTypeIdsByDeveloperNameMap(Case.SObjectType);
    private static final Map<String,Id>     RECORD_TYPES_ID_BY_NAME_MAP           = SEPRecordTypesCache.getRecordTypeIdsByNameMap(Case.SObjectType);
    
    private static Map<String, Schema.RecordTypeInfo> caseRecordTypeInfoByNameMap              = null;
    private static Map<String, String>                caseRecordTypeDeveloperNameByCaseTypeMap = null;

    public override boolean OnBeforeInsert(List<sObject> newSObjectList)
    {
        Boolean isCurrentUserAdmin = SEPProfileCache.isUserAdmin();
        
        for (Case newCase : (List<Case>) newSObjectList)
        {
            if (newCase.type != null 
                && (newCase.recordTypeId == null 
                    || !isCurrentUserAdmin)) {
                
                newCase.recordTypeId = newCase.type == 'Quality Complaint'
                                        ? ECICCaseQualityComplaintRecordTypeHelper.getCountrySpecificRecordTypeId(newCase.Country_code__c)
                                        : getCaseRecordTypeIdFromCaseType(newCase.type);
            }

            try { 
                    newCase.Record_Type_Name__c = RECORD_TYPES_BY_ID_MAP.get(
                                                                newCase.recordTypeId
                                                            ).Name; 
                }
            catch (NullPointerException ex)     // These should NEVER happen!
            {
                if      (RECORD_TYPES_BY_ID_MAP                                 == null) { addError (newCase,'Null Pointer Exception : Record Type Map is missing.');       }
                else if (RECORD_TYPES_BY_ID_MAP.get(newCase.recordTypeId)       == null) { addError (newCase,'Null Pointer Exception : Record Type is missing. RecordTypeId = '+newCase.recordTypeId);           }
                else if (newCase.recordTypeId                                   == null) { addError (newCase,'Null Pointer Exception : Record Type Id now is missing.');    }
                else if (RECORD_TYPES_BY_ID_MAP.get(newCase.recordTypeId).Name  == null) { addError (newCase,'Null Pointer Exception : Record Type Name is missing. RecordTypeId = '+newCase.recordTypeId);      }
            }
            catch (Exception ex)                                                         { addError (newCase, 'Unknown Error: Can not set Record Type Name.');              }
        }
        return true;    
    }

    private static void addError (Case newCase, String message)
    {
        System.debug (LoggingLevel.ERROR, '!!!!!!!!!! ' + message);
        System.debug (LoggingLevel.ERROR, '!!!!!!!!!! RECORD_TYPES_BY_ID_MAP : ' + RECORD_TYPES_BY_ID_MAP);
        System.debug (LoggingLevel.ERROR, '!!!!!!!!!! newCase : ' + newCase); 
        if ((newCase != null) && (newCase.type == null))
        {
            System.debug (LoggingLevel.ERROR, '!!!!!!!!!! newCase.type == null ');
        }
        else
        {
            System.debug (LoggingLevel.ERROR, '!!!!!!!!!! newCase.type : ' + newCase.type);
            System.debug (LoggingLevel.ERROR, '!!!!!!!!!! Schema.SObjectType.Case.RecordTypeInfosByName.get(newCase.type) : ' + Schema.SObjectType.Case.RecordTypeInfosByName.get(newCase.type));
        }
        newCase.addError (message);
    }

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        Map<ID, Case> oldCasesMap = (Map<ID, Case>)oldValuesMap;
        Map<ID, Case> newCasesMap = (Map<ID, Case>)newValuesMap;

        for (Case newCase : newCasesMap.values()) 
        {
            Case oldCase = oldCasesMap.get(newCase.id);

            if (newCase.RecordTypeId != oldCase.RecordTypeId) 
            { 
                newCase.recordTypeId        = ECICCaseQualityComplaintRecordTypeHelper.getCountrySpecificRecordTypeId (newCase);
                newCase.Record_Type_Name__c = RECORD_TYPES_BY_ID_MAP.get(newCase.recordTypeId).Name; 
            } 

            // Check if record type is not a quality complaint anymore
            if ( ECICCaseQualityComplaintRecordTypeHelper.isQualityComplaint(oldCase.RecordTypeID) && !ECICCaseQualityComplaintRecordTypeHelper.isQualityComplaint(newCase.RecordTypeID)) 
             {
                clearCaseQualityFields(newCase);
             }
        }
        
        return true;
    }

//----------------------------------------------------------------------------------------------------------------

    @testVisible private static Id getCaseRecordTypeIdFromCaseType(String newCaseType)
    {
        Id targetRecordTypeId = RECORD_TYPES_ID_BY_NAME_MAP.get(newCaseType);           // This is kept for backwards compatibility with old tests and not to require custom settings in all sandboxes.
        if (targetRecordTypeId != null) { return targetRecordTypeId; }
        return RECORD_TYPES_ID_BY_DEVELOPER_NAME_MAP.get(getDeveloperName(newCaseType));
    }

    @testVisible private static Schema.RecordTypeInfo getRecordTypeInfo(String newCaseType)
    {
        if (caseRecordTypeInfoByNameMap == null)
        {
            caseRecordTypeInfoByNameMap = new Map<String, Schema.RecordTypeInfo>();
            for (Schema.RecordTypeInfo recordTypeInfo : Schema.SObjectType.Case.getRecordTypeInfos())
            {
                caseRecordTypeInfoByNameMap.put (recordTypeInfo.getName(), recordTypeInfo);
            }
        }
        return caseRecordTypeInfoByNameMap.get(newCaseType);
    }

    @testVisible private static String getDeveloperName(String newCaseType)
    {
        if (caseRecordTypeDeveloperNameByCaseTypeMap == null)
        {
            caseRecordTypeDeveloperNameByCaseTypeMap = new Map<String, String>();
            List<Case_Type_To_Record_Type_Dictionary__c> dictionaryList = Case_Type_To_Record_Type_Dictionary__c.getAll().values(); 
            for (Case_Type_To_Record_Type_Dictionary__c dictionaryEntry : dictionaryList)
            {
                caseRecordTypeDeveloperNameByCaseTypeMap.put (dictionaryEntry.case_type__c, dictionaryEntry.case_record_type_developer_name__c);
            }
        }
        return caseRecordTypeDeveloperNameByCaseTypeMap.get(newCaseType);
    }

    //----------------------------------------------------------------------------------------------------------------

    @testVisible private void clearCaseQualityFields(Case c) {
        //clear product info
        c.bbe_date__c = null;
        c.production_code__c = null;
        c.production_line__c = null;
        c.plant__c = null;
        c.bottler__c = null;
        c.Production_date__c = null;
        
        //clear Consumer Sample Information
        c.Content_Available__c = false;
        c.Sample_Collected__c = false;
        c.Sample_Collector__c = null;
        c.Package_Available__c = false;
        c.Package_Closed__c = false;
        c.Damage__c = false;
        c.Date_of_Purchase__c = null;
        c.Point_Of_Sale__c = null;
        c.Place_of_Purchase__c = null;
        c.PoS_Key_Account__c = null;
        c.Region_of_Purchase__c = null;
        c.Sample_Comments__c = null;
        c.No_of_Packages__c = null;
        c.Sample_Collection_Date__c = null;
        c.Sample_Arrival_Date__c = null;
        
        //ECIC-2237--26/06/2012 -------------------------->>
        c.Bottler_External_Relations__c  = null;
        c.Bottler_Quality_Owner__c = null;
        c.Distributor_Quality_Manager__c = null;
        c.Distributor_Quality__c = null;
        c.Distributor_External_Relations__c = null;
        //<<------------------------------------------------
        c.bottler_name__c = null;
        c.region_bottler_name__c = null;
        //Quality Information
        c.Quality_Case_Owner__c = null;
        c.Bottler_Quality_Manager__c = null;
        c.Quality_Status__c = null;
        c.Package_Supplier__c = null;
        c.Closure_Supplier__c = null;
        c.Trend__c = null;
        c.Communicate_to_Infoline__c = false;
        c.Technical_Notes__c = null;
        c.No_Quality_Status_Change__c = false;
        c.Package_Batch__c = null;
        c.Closure_Batch__c = null;
        
        //clear Quality Report 
        c.Date_of_the_report__c = null;
        c.Comments_of_analyst_lab_manager__c = null;
        c.Quality_Technical_Reason__c = null;
        c.Root_Cause_Identification__c = null;
        c.Cause_of_Complaint__c = null;
        c.Process_Type__c = null;
        c.Food_Safety_toxicological__c = false;
        c.Food_Safety_Toxicological_txt__c = null;
        c.Comments_of_analyst_labmgr_full__c = null;
        
        //clear Consumer Sample Analysis
        c.Laboratory_of_Analysis__c = null;
        c.Lab_Reception_Date__c = null;
        c.No_of_Open_Samples__c = null;
        c.No_of_Closed_Samples__c = null;
        c.Retention_Sample__c = false;
        c.Retention_Sample_Txt__c = null;
        c.Shipment_Time__c = null;
        c.Appearance_of_Package__c = false;
        c.Appearance_of_Package_Txt__c = null;
        c.Appearance_of_Product__c = false;
        c.Appearance_of_Product_Txt__c = null;
        c.Sensory_Evaluation__c = false;
        c.Sensory_Evaluation_Txt__c = null;
        c.Chemical_Analysis__c = false;
        c.Chemical_Analysis_Txt__c = null;
        c.Physical_Analysis__c = false;
        c.Physical_Analysis_Txt__c = null;
        c.Microbiological_Analysis__c = false;
        c.Microbiological_Analysis_Txt__c = null;
        c.Health_Risk__c = false;
        c.Health_Risk_Txt__c = null;
        
        //clear hidden fields
        c.Action_Plan__c = null;
        c.Quality_Case_Owner__c = null;
        c.Quality_Admin_Assistant__c = null;
        c.Consumer_Complaint_Manager__c = null;
        
        c.trend_mark__c = null;
    } comment block 1 end */
}