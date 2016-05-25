@isTest
private class SEPRecordTypesCacheTest 
{
  	private static final User TEST_RUN_USER 				= ECICRunUserTestHelper.create();
  	private static final User ES_INFOLINE_AGENT				= ECICRunUserTestHelper.create(ECICRunUserTestHelper.ES_INFOLINE_AGENT_PARAM); 
  	private static final User ES_INFOLINE_SUPREVISOR_PARAM	= ECICRunUserTestHelper.create(ECICRunUserTestHelper.ES_INFOLINE_SUPREVISOR_PARAM);
  	private static final User ES_BOTTLER					= ECICRunUserTestHelper.create(ECICRunUserTestHelper.ES_BOTTLER);
  	private static final User ES_KO_QUALITY_AGENT			= ECICRunUserTestHelper.create(ECICRunUserTestHelper.ES_KO_QUALITY_AGENT);
  	private static final User ES_KO_QUALITY_MANAGER			= ECICRunUserTestHelper.create(ECICRunUserTestHelper.ES_KO_QUALITY_MANAGER);
  	private static final User ES_EXTERNAL_RELATION			= ECICRunUserTestHelper.create(ECICRunUserTestHelper.ES_EXTERNAL_RELATIONS);
  // #Ecic Template Test 	
  	private static final Set<String> CASE_RECORD_TYPE_NAME_SET = new Set<String>{ 'Non-Quality Complaint Iberia',
'Inquiry Iberia',
'Compliment Iberia',
'Spam Iberia',
'Useless Iberia',
'Comment Iberia',
'Comment NWEN',
'Compliment NWEN',
'Inquiry NWEN',
'Non-Quality Complaint NWEN',
'Quality Complaint NWEN',
'Spam NWEN',
'Useless NWEN',
'Comment CSE',
'Compliment CSE',
'Inquiry CSE',
'Non-Quality Complaint CSE',
'Quality Complaint CSE',
'Spam CSE',
'Useless CSE',
'Comment Common',
'Compliment Common',
'Inquiry Common',
'Non-Quality Complaint Common',
'Quality Complaint Common',
'Spam Common',
'Useless Common',
'Comment Germany',
'Compliment Germany',
'Inquiry Germany',
'Non-Quality Complaint Germany',
'Quality Complaint Germany',
'Spam Germany',
'Useless Germany'
 };

// End Of Ecic 
	private static void getRecordTypesByIdMap(User dummyUser, Schema.SObjectType token, Set<String> expectedRecordTypeSet) 
	{
		Map<String, Boolean> foundRecordTypeMap = new Map<String, Boolean>();
		List<String> expectedRecordTypeList = new List<String>(expectedRecordTypeSet); 
		for (String  expectedRecordTypeName : expectedRecordTypeList) { foundRecordTypeMap.put (expectedRecordTypeName, false); }
		
		Map<Id,RecordType> resultRecordTypesByIdMap = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				resultRecordTypesByIdMap = SEPRecordTypesCache.GetRecordTypesByIdMap(token);
			}
			Test.stopTest();
		}

		for (Id key : resultRecordTypesByIdMap.keySet())
		{
			String resultName = resultRecordTypesByIdMap.get(key).Name;
			System.assert(expectedRecordTypeSet.contains(resultName));
			foundRecordTypeMap.put(resultName, true);
		}		 
		
		for (String expectedRecordTypeName : expectedRecordTypeList)
		{
			System.assert (foundRecordTypeMap.get(expectedRecordTypeName));
		}
	}

	private static void adminCaseGetRecordTypesByIdMap() 			{ getRecordTypesByIdMap(TEST_RUN_USER, 			  	 	Case.SObjectType, CASE_RECORD_TYPE_NAME_SET); }
	private static void infoAgentCaseGetRecordTypesByIdMap() 		{ getRecordTypesByIdMap(ES_INFOLINE_AGENT, 		   		Case.SObjectType, CASE_RECORD_TYPE_NAME_SET); }
	private static void infoSupreCaseGetRecordTypesByIdMap() 		{ getRecordTypesByIdMap(ES_INFOLINE_SUPREVISOR_PARAM, 	Case.SObjectType, CASE_RECORD_TYPE_NAME_SET); }
	private static void bottlerCaseGetRecordTypesByIdMap() 			{ getRecordTypesByIdMap(ES_BOTTLER, 				    Case.SObjectType, CASE_RECORD_TYPE_NAME_SET); }
	private static void qualAgentCaseGetRecordTypesByIdMap() 		{ getRecordTypesByIdMap(ES_KO_QUALITY_AGENT, 		    Case.SObjectType, CASE_RECORD_TYPE_NAME_SET); }
	private static void qualManagerCaseGetRecordTypesByIdMap() 		{ getRecordTypesByIdMap(ES_KO_QUALITY_MANAGER, 	   		Case.SObjectType, CASE_RECORD_TYPE_NAME_SET); }
	private static void extRelationadminCaseGetRecordTypesByIdMap() { getRecordTypesByIdMap(ES_EXTERNAL_RELATION, 		    Case.SObjectType, CASE_RECORD_TYPE_NAME_SET); }

	// TODO: 	private static testMethod void GetRecordTypeIdsByDeveloperNameMapTest() {} 

}