public class ECICCaseDispatherHelper {

/********************************** prepare static reference data *****************************************/
    private static Map<String, Set<Id>> COUNTRY_TO_RECORD_TYPE_ID_MAP;
    public static Map<String, Id> CASETYPENAME_TO_TYPEID;
        
    static { // Query and cache map Case Record Type Ids    
        List<RecordType> caseRecordTypeList = ECICCaseTriggerRegionCache.getRecordType(ECICCommonConstants.RECORDTYPE_BY_SOBJECT_TYPE,'Case').Values();
        //[SELECT DeveloperName, Id  FROM RecordType WHERE sObjectType='Case'  AND isActive = true];
        CASETYPENAME_TO_TYPEID = new Map<String, Id>{};
        for(RecordType currcasetype: caseRecordTypeList) { CASETYPENAME_TO_TYPEID.put(currcasetype.DeveloperName, currcasetype.Id); }
        
        List<Country_Specific_Settings__c> countrySpecificSettingList = [SELECT Name, Allowed_Case_RecordTypes__c  FROM Country_Specific_Settings__c];
        COUNTRY_TO_RECORD_TYPE_ID_MAP = new Map<String, Set<Id>>{};                                                                          
        for(Country_Specific_Settings__c currentCountry: countrySpecificSettingList) 
        {
            Set<Id> allowedRecordTypeIdSet = New Set<Id>{};
            String allowedCaseRecordTypes = currentCountry.Allowed_Case_RecordTypes__c;
            String[] allowedRecordTypeNameArray = String.isNotBlank(allowedCaseRecordTypes) ? allowedCaseRecordTypes.split(';',0) : null;
            if (allowedRecordTypeNameArray != null && !allowedRecordTypeNameArray.isEmpty())
            {
	            for(String currRecordTypeName : allowedRecordTypeNameArray)
    	        {
        	        allowedRecordTypeIdSet.add(CASETYPENAME_TO_TYPEID.get(currRecordTypeName.remove(';')));
           		}
            }    
            if(!allowedRecordTypeIdSet.isEmpty()) { COUNTRY_TO_RECORD_TYPE_ID_MAP.put(currentCountry.Name, allowedRecordTypeIdSet);  }    
        }                    
    } 

/******************************************* functional ***************************************************/
    public static String isRecordTypeAvailable(String userId, Id caseRecordTypeId){
        String result = '';
        List<String> country_codes = New List<String>{};
        User currUser = [SELECT Enabled_Countries__c  FROM User  WHERE Id=:UserInfo.getUserId() LIMIT 1][0];                         
        
        if(String.isBlank(currUser.Enabled_Countries__c)){ result = Label.Case_NoEnabledCountries_Error; }
        else{
            country_codes = currUser.Enabled_Countries__c.split(';',0);                                                                                                                               
            Set<Id> countryAvalForUserCaseTypesIdSet = New Set<Id>{};                                       
            for(String curr_country : country_codes)
            {
                if(COUNTRY_TO_RECORD_TYPE_ID_MAP.containsKey(curr_country))
                {
                    countryAvalForUserCaseTypesIdSet.addAll(COUNTRY_TO_RECORD_TYPE_ID_MAP.get(curr_country));    
                } 
            }
            if     (countryAvalForUserCaseTypesIdSet.isEmpty())					 { result = Label.Case_NoRecordType_Error; }
            else if(!countryAvalForUserCaseTypesIdSet.contains(caseRecordTypeId)){ result = Label.Case_RecordType_Error; }
        }   
        return result;
    }
}