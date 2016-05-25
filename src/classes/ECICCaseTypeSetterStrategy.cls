public class ECICCaseTypeSetterStrategy extends ECICCaseProcessingStrategyAbstract 
{
    private static final Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);
    
    
    public override boolean OnBeforeInsert(List<sObject> newSObjectList) 
    {
        for (Case newCase : (List<Case>) newSObjectList) { newCase.type = getType(newCase.RecordTypeID); }
        return true;
    }

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) 
    {
        Map<ID, Case> newCasesMap = (Map<ID, Case>)newValuesMap;
        for (Case newCase : newCasesMap.values()) { newCase.type = getType(newCase.RecordTypeID); }
        return true;
    }
    
    @testVisible private static String getType (Id recordTypeId) 
    {
        //RecordType recordType = RECORD_TYPES_BY_ID_MAP.get(recordTypeId);
        //#RecordType
        String developerName = RECORD_TYPES_BY_ID_MAP.get(recordTypeId).DeveloperName;
        String caseType = '';
        
        if (developerName != null){
        
            if(developerName.StartsWith(ECICCommonConstants.INQUIRY_DEVNAME))
                caseType = ECICCommonConstants.INQUIRY_CASETYPE;
            else if(developerName.StartsWith(ECICCommonConstants.QUALITY_COMPLAINT_DEVNAME))
                caseType = ECICCommonConstants.QUALITY_COMPLAINT_CASETYPE;
            else if(developerName.StartsWith(ECICCommonConstants.USELESS_DEVNAME))
                caseType = ECICCommonConstants.USELESS_CASETYPE;
            else if(developerName.StartsWith(ECICCommonConstants.NONQUALITY_COMPLAINT_DEVNAME))
                caseType = ECICCommonConstants.NONQUALITY_COMPLAINT_CASETYPE;
            else if(developerName.StartsWith(ECICCommonConstants.COMMENT_DEVNAME))
                caseType = ECICCommonConstants.COMMENT_CASETYPE;
            else if(developerName.StartsWith(ECICCommonConstants.COMPLIMENT_DEVNAME))
                caseType = ECICCommonConstants.COMPLIMENT_CASETYPE;
            else if(developerName.StartsWith(ECICCommonConstants.SPAM_DEVNAME))
                caseType = ECICCommonConstants.SPAM_CASETYPE;
            
        }
        
        /*String recordTypeName = (recordType != null)
                                   ? recordType.Name
                                   : 'Inquiry'; ECICCaseTypeSetterStrategy
        
        return (recordTypeName == 'Simplified Quality Complaint')
                    ?   'Quality Complaint'
                    :   recordTypeName;  */
                    system.debug('caseType======='+caseType);
                    
        return caseType;
    }
}