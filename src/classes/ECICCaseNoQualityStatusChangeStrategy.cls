/*
* #RecordType
*/

public class ECICCaseNoQualityStatusChangeStrategy extends ECICCaseProcessingStrategyAbstract 
{
    private static final Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);
    
    private static final Set<Id> ALLOWED_PROFILE_SET = new SET<Id>
    {       //#Profile- added for newly created profile- Balmukund
        selectProfileId (ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT),
        selectProfileId (ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_SUPERVISOR),
        selectProfileId (ECICCommonConstants.PROFILE_ECIC_NWEN_INFOLINE_AGENT),
        selectProfileId (ECICCommonConstants.PROFILE_ECIC_NWEN_INFOLINE_SUPERVISOR),
        selectProfileId (ECICCommonConstants.PROFILE_ECIC_GERMANY_INFOLINE_AGENT),
        selectProfileId (ECICCommonConstants.PROFILE_ECIC_GERMANY_INFOLINE_SUPERVISOR),
        selectProfileId (ECICCommonConstants.PROFILE_ECIC_IBERIA_EXTERNAL_RELATIONS),
        selectProfileId (ECICCommonConstants.PROFILE_ECIC_CSE_AGENT),
        selectProfileId (ECICCommonConstants.PROFILE_ECIC_CSE_SUPERVISOR),
        selectProfileId (ECICCommonConstants.PROFILE_SYSTEM_ADMIN)
    };

    @testVisible private Boolean isUserInDisallowedProfile;
    
    public ECICCaseNoQualityStatusChangeStrategy() 
    {
        Id userProfileId = (!Test.isRunningTest())
                                ? UserInfo.getProfileId()
                                : (Id) TEST_MockHelper.getMockString(UserInfo.getLastName(), 'profileId'); 
        
        isUserInDisallowedProfile = !(ALLOWED_PROFILE_SET.contains(userProfileId));
    }

    private static Id selectProfileId (String profileName)
    {
        return (!Test.isRunningTest()) 
                        ? Profiles_Mapping__c.getValues(profileName).Id__c      
                        : TEST_DummyProfileMappingFactory.MOCK_PROFILE_ID_BY_PROFILE_UNTRANSLATED_NAME_MAP.get(profileName);
    }

    public override boolean OnBeforeInsert(List<sObject> newValues) {
        execute(null, (List<Case>)newValues);
        return true;
    }

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) 
    {
        execute((Map<ID, Case>)oldValuesMap, (List<Case>)newValuesMap.values());
        return true;
    }
    
    @testVisible private void execute(Map<ID, Case> oldCasesMap, Case[] newCasesList) 
    
    {
        
        for (Case newCase : newCasesList) 
        {
            
            boolean toConfirmNQStatusChange = confirmNoQualityStatusChange (newCase,  ((oldCasesMap != null) ? (oldCasesMap.get(newCase.id)) : (null))); 

            if (toConfirmNQStatusChange && isUserInDisallowedProfile) 
            {
                SEPErrorHelper.addError(newCase, System.Label.NoQualityStatusChange, false);
            }
            
            // reset No QS Change flag for quality cases
            if (
                    ( ECICCaseQualityComplaintRecordTypeHelper.isQualityComplaint(newCase.RecordTypeID) )
                 && ( newCase.No_Quality_Status_Change__c) 
               )
            {
                newCase.No_Quality_Status_Change__c = false;
            }
        }
    }

    @testVisible private Boolean confirmNoQualityStatusChange (Case newCase, Case oldCase)
    {
            Set<String> nonMutableStatusSet = new Set<String>{ECICCommonConstants.STATUS_NEW, ECICCommonConstants.STATUS_CANCELLED, ECICCommonConstants.STATUS_CLOSED};
            //#RecordType
            String developerName = RECORD_TYPES_BY_ID_MAP.get(newCase.RecordTypeID).DeveloperName;
           
            return (    
                        //#RecordType
                        developerName.StartsWith(ECICCommonConstants.QUALITY_COMPLAINT_DEVNAME)
                        //(newCase.RecordTypeID == ECICCommonConstants.CASE_QUILITY_COMPLAINT_RT_ID)    // No Quality Status Change checkbox is verified only on (standard) Quality Complaint Cases
                    && ( !(nonMutableStatusSet.contains(newCase.status)) )                          // AND Status is NOT New, Cancelled, or Closed
                    && ( ! newCase.No_Quality_Status_Change__c )                                    // AND Not checked as containing a quality status change
                    && (
                            (oldCase == null)                                                       // AND This is an insert...
                            || (newCase.quality_status__c == oldCase.quality_status__c)             //      OR Quality status has NOT changed. 
                       )
                    ); 
    }

}