/*This class is used for updating country code and record types of the cases which are created from Sysomos. 
 *Created by : Balmukund
 *Crated on : 04/11/2014
*/


public class CICCaseRecordTypeAssignementForSysmos {
	
	private static final Map<String,Id>     RECORD_TYPES_ID_NAME_MAP = SEPRecordTypesCache.getRecordTypeIdsByNameMap(Case.SObjectType);
	private static Country_Specific_Settings__c countrySpecificSettings;
	public static void addCountryCodeAndRecordType(List<Case> newValues){
		Case caseObjNew = newValues.get(0);
		
		
		if(caseObjNew.SysomosHB__Web_Url__c != null){
		
			String countryCode = getCountryCode(caseObjNew.Subject);
			countrySpecificSettings = Country_Specific_Settings__c.getValues(countryCode);
			if(countrySpecificSettings == null)
			return;
			Id recordTypeId = getRecordTypeFromType(caseObjNew.Type,countryCode,caseObjNew);
			//caseObjNew.Test_Log__c = caseObjNew.Type+'****';
			caseObjNew.RecordTypeId = recordTypeId;
			
			caseObjNew.Country_Code__c = countryCode;
			if(countrySpecificSettings.Case_Queue_Id__c != null)
			caseObjNew.OwnerId = countrySpecificSettings.Case_Queue_Id__c;
		}
		
	}
	
	//Getting record type ids from type of created cases
	private static Id getRecordTypeFromType(String caseType,String countryCode,case caseObjNew){
		
		//Country_Specific_Settings__c countrySpecificSettings = Country_Specific_Settings__c.getValues(countryCode);
		String BU = countrySpecificSettings.Business_Unit__c;		
		String recordTypeName = caseType+' '+BU;
		//caseObjNew.Test_Log__c += recordTypeName;
		Id recordTypeId = RECORD_TYPES_ID_NAME_MAP.get(recordTypeName);
		//caseObjNew.Test_Log__c += RECORD_TYPES_ID_NAME_MAP;
		return recordTypeId;
	}
	
	private static String getCountryCode(String subject){
		
		String countryCode = subject.substring(0, 2);
		return countryCode.trim();
		
		
	}

}