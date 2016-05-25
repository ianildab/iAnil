@isTest
private class ECICCaseMulSetterStrategyTest 
{
	private static final User TEST_RUN_USER = ECICRunUserTestHelper.create();
	
	private static final ECICCaseMulSetterStrategy DUMMY_STRATEGY = new ECICCaseMulSetterStrategy();
	
	private static final Map<String, Id> DUMMY_ID_BY_ROLENAME_MAP = new Map<String, Id>
	{ 	
		'consumerComplaintManager' 	=> '00520000001qmX1',
		'qualityAdminAssistant' 	=> '00520000001qmX2',
		'qualityCaseOwner' 			=> '00520000001qmX3',
		'qualityManager' 			=> '00520000001qmX4',
		'serviceManager' 			=> '00520000001qmX5'
	};
	
	private static void hasCountryCodeChangedTest(Boolean hasOldCase, Boolean hasNewCountryCode) 			
	{
		TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
							 config.countryCode = 'N0';
		Case dummyNewCase = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE);
		 
		Map<Id, Case> dummyOldCaseByIdMap = null;  
		if (hasOldCase)
		{
			Case dummyOldCase = dummyNewCase.clone(false);
			if (hasNewCountryCode) { dummyOldCase.Country_Code__c = 'O0'; }
			TEST_MockHelper.mockInsert(dummyOldCase);
			
			dummyOldCaseByIdMap = new Map<Id, Case>{ dummyOldCase.id => dummyOldCase };
			dummyNewCase.id = dummyOldCase.id;
		}

		Boolean result = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
		 		result = DUMMY_STRATEGY.hasCountryCodeChanged(dummyNewCase, dummyOldCaseByIdMap);
		 	}
		 	Test.stopTest();
		} 
		
		Boolean expectedResult = (!hasOldCase) || (hasOldCase && hasNewCountryCode);
		System.assertEquals(expectedResult, result);
		 
	}

	private static testMethod void noOldCaseHasCountryCodeChangedTest()  			{ hasCountryCodeChangedTest (false, false);  } 
	private static testMethod void hasOldCaseHasCountryCodeChangedTest() 			{ hasCountryCodeChangedTest (true,  false);  } 
	private static testMethod void hasNewCountryCodeHasCountryCodeChangedTest() 	{ hasCountryCodeChangedTest (true,  true);   } 
	
	// --------------------------------------------------------------------------------------------------------------------

	private static void hasEmptyLookupUserFieldTest( Boolean hasConsumerComplaintManager, Boolean hasServiceManager, Boolean hasQualityAdminAssistant, Boolean hasQualityCaseOwner,  Boolean hasQualityManager)
	{ 
		Case dummyCase = TEST_DummyInquiryCaseFactory.create(TEST_DummyInsertModeEnum.NONE);
			 dummyCase.Consumer_Complaint_Manager__c	= (hasConsumerComplaintManager) ? TEST_RUN_USER.id : null;
			 dummyCase.Quality_Admin_Assistant__c		= (hasQualityAdminAssistant)    ? TEST_RUN_USER.id : null;
			 dummyCase.Quality_Case_Owner__c			= (hasQualityCaseOwner) 	 	? TEST_RUN_USER.id : null;
			 dummyCase.Quality_Manager__c 				= (hasQualityManager) 		    ? TEST_RUN_USER.id : null;
			 dummyCase.Service_Manager__c 				= (hasServiceManager) 		    ? TEST_RUN_USER.id : null;

		Boolean result = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
		 		result = DUMMY_STRATEGY.hasEmptyLookupUserField(dummyCase);
		 	}
		 	Test.stopTest();
		}
		
		Boolean expectedResult =  !(hasConsumerComplaintManager && hasServiceManager && hasQualityAdminAssistant && hasQualityCaseOwner && hasQualityManager);
		System.assertEquals (expectedResult, result);
	} 
	
	private static testMethod void hasNoEmptyLookupUserFieldTest() 							{ hasEmptyLookupUserFieldTest( false, false, false, false, false ); } 
	private static testMethod void hasEmptyServiceManagerIdLookupUserFieldTest() 			{ hasEmptyLookupUserFieldTest( false, false, false, false, true  ); } 
	private static testMethod void hasEmptyQualityManagerIdLookupUserFieldTest() 			{ hasEmptyLookupUserFieldTest( false, false, false, true , false ); } 
	private static testMethod void hasEmptyQualityCaseOwnerIdLookupUserFieldTest() 			{ hasEmptyLookupUserFieldTest( false, false, true , false, false ); } 
	private static testMethod void hasEmptyQualityAdminAssistantIdLookupUserFieldTest() 	{ hasEmptyLookupUserFieldTest( false, true , false, false, false ); } 
	private static testMethod void hasEmptyConsumerComplaintManagerIdLookupUserFieldTest() 	{ hasEmptyLookupUserFieldTest( true , false, false, false, false ); } 
	private static testMethod void hasAllEmptyLookupUserFieldTest() 						{ hasEmptyLookupUserFieldTest( true , true , true , true , true  ); } 

	// --------------------------------------------------------------------------------------------------------------------
	 
	private static void buildRequiresExecutionCaseListTest(Boolean hasNewCountryCode, Boolean hasEmptyLookupUserField) 
	{ 
		TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
							 config.countryCode = 'N0';
		Case dummyNewCase = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE);
			 dummyNewCase.Consumer_Complaint_Manager__c	= (!hasEmptyLookupUserField) ? TEST_RUN_USER.id : null;
			 dummyNewCase.Quality_Admin_Assistant__c	=							   TEST_RUN_USER.id;
			 dummyNewCase.Quality_Case_Owner__c			=							   TEST_RUN_USER.id;
			 dummyNewCase.Quality_Manager__c 			=							   TEST_RUN_USER.id;
			 dummyNewCase.Service_Manager__c 			=							   TEST_RUN_USER.id;
		 
		Case dummyOldCase = dummyNewCase.clone(false);
		if (hasNewCountryCode) { dummyOldCase.Country_Code__c = 'O0'; }
		TEST_MockHelper.mockInsert(dummyOldCase);
		dummyNewCase.id = dummyOldCase.id;
		
		List<Case> resultCaseList = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
		 		resultCaseList = DUMMY_STRATEGY.buildRequiresExecutionCaseList(new Map<Id, Case>{ dummyOldCase.id => dummyOldCase }, new List<Case>{ dummyNewCase });
		 	}
		 	Test.stopTest();
		}

		Boolean executionRequired = (hasNewCountryCode || hasEmptyLookupUserField); 
		System.assertEquals (executionRequired ? 1 : 0, resultCaseList.size());
		if (executionRequired) { System.assertEquals (dummyNewCase, resultCaseList[0]); }
	}
	
	private static testMethod void hasNothingBuildRequiresExecutionCaseListTest() 				{ buildRequiresExecutionCaseListTest( false, false ); } 
	private static testMethod void hasEmptyLookupUserFieldBuildRequiresExecutionCaseListTest() 	{ buildRequiresExecutionCaseListTest( false, true  ); } 
	private static testMethod void hasNewCountryCodeBuildRequiresExecutionCaseListTest() 		{ buildRequiresExecutionCaseListTest( true,  false ); } 
	private static testMethod void hasBothBuildRequiresExecutionCaseListTest() 					{ buildRequiresExecutionCaseListTest( true,  true  ); } 

	// --------------------------------------------------------------------------------------------------------------------

	private static void getUserForMappedFieldTest(Boolean roleNameIsMapped, Boolean userIsMapped) 			
	{ 
		String 				   dummyMappedUserField = 'Consumer_Complaint_Manager__c';
		String				   dummyRoleName		= 'ES_Consumer_Quality_Complaints_Manager';
		
		TEST_DummyUserLookupMappingFactory.Config config = new TEST_DummyUserLookupMappingFactory.Config();
										    	  config.consumerComplaintManager = (roleNameIsMapped) ? dummyRoleName : TEST_ConfigHelper.INTENTIONAL_NULL;
		User_Lookup_Mapping__c dummyMapping	= TEST_DummyUserLookupMappingFactory.create(config, TEST_DummyInsertModeEnum.NONE); 

		User dummyUser = TEST_RUN_USER;
		if (userIsMapped) { ECICCaseTriggerUserCache.activeUserIdByUserRoleDeveloperNameCache.put (dummyRoleName, dummyUser.id); }

		Id resultId = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
		 		resultId = DUMMY_STRATEGY.getUserForMappedField(dummyMappedUserField, dummyMapping);
		 	}
		 	Test.stopTest();
		}
		
		Id expectedId = (roleNameIsMapped && userIsMapped) ? dummyUser.id : null;
		System.assertEquals (expectedId, resultId);
	} 

	private static testMethod void nothingMappedGetUserForMappedFieldTest() 	{ getUserForMappedFieldTest( false, false ); } 
	private static testMethod void userMappedGetUserForMappedFieldTest() 		{ getUserForMappedFieldTest( false, true  ); } 
	private static testMethod void roleNameMappedGetUserForMappedFieldTest() 	{ getUserForMappedFieldTest( true,  false ); } 
	private static testMethod void bothMappedGetUserForMappedFieldTest() 		{ getUserForMappedFieldTest( true,  true  ); } 

	// --------------------------------------------------------------------------------------------------------------------
	
	private static void doExecutionForCaseTest(Boolean countryHasMapping) 			
	{
		String dummyCountryCode = 'C0';
		
		if (countryHasMapping)
		{
			createUserLookUpMapping (dummyCountryCode);
			populateUserCache(); 								// Not needed for map, but not needed if there is no map.
		}
		
		TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
							 config.countryCode = dummyCountryCode;
		Case dummyCase = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE);
		
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
		 		DUMMY_STRATEGY.doExecution(dummyCase);
		 	}
		 	Test.stopTest();
		}

		assertExecution(countryHasMapping, dummyCase);	
	}
	
	private static testMethod void unmappedCountryDoExecutionForCaseTest() 		{ doExecutionForCaseTest(false); } 
	private static testMethod void mappedCountryDoExecutionForCaseTest() 		{ doExecutionForCaseTest(true);  } 

	// --------------------------------------------------------------------------------------------------------------------
	
	private static void doExecutionForCaseListTest(Boolean countryHasMapping) 			
	{
		String dummyCountryCode = 'L0';
		
		if (countryHasMapping)
		{
			createUserLookUpMapping (dummyCountryCode);
			populateUserCache(); 								// Not needed for map, but not needed if there is no map.
		}
		
		TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
							 config.countryCode = dummyCountryCode;
		Case dummyCase = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE);
		
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
		 		DUMMY_STRATEGY.doExecution(new List<Case>{dummyCase});
		 	}
		 	Test.stopTest();
		}

		assertExecution(countryHasMapping, dummyCase);	
	}
	
	private static testMethod void unmappedCountryDoExecutionForCaseListTest() 		{ doExecutionForCaseListTest(false); } 
	private static testMethod void mappedCountryDoExecutionForCaseListTest() 		{ doExecutionForCaseListTest(true);  } 

	// --------------------------------------------------------------------------------------------------------------------

	private static testMethod void onBeforeInsertTest() 				
	{
		String dummyCountryCode = 'I0';
		
		createUserLookUpMapping (dummyCountryCode);
		populateUserCache();
		
		TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
							 config.countryCode = dummyCountryCode;
		Case dummyCase = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE);
		
		Boolean result = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
		 		result = DUMMY_STRATEGY.onBeforeInsert(new List<Case>{dummyCase});
		 	}
		 	Test.stopTest();
		}

		System.assert(result);
		assertExecution(true, dummyCase);	
	}

	// --------------------------------------------------------------------------------------------------------------------

	private static void onBeforeUpdateTest(Boolean requiresUpdate) 				
	{
		String dummyCountryCode = 'U0';
		
		createUserLookUpMapping (dummyCountryCode);
		populateUserCache();
		
		TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
							 config.countryCode = dummyCountryCode;
		Case dummyNewCase = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE);
			 dummyNewCase.Consumer_Complaint_Manager__c	= TEST_RUN_USER.id;
			 dummyNewCase.Quality_Admin_Assistant__c	= TEST_RUN_USER.id;
			 dummyNewCase.Quality_Case_Owner__c			= TEST_RUN_USER.id;
			 dummyNewCase.Quality_Manager__c 			= TEST_RUN_USER.id;
			 dummyNewCase.Service_Manager__c 			= TEST_RUN_USER.id;
		 
		Case dummyOldCase = dummyNewCase.clone(false);
		if (requiresUpdate) { dummyOldCase.Country_Code__c = 'O0'; }
		TEST_MockHelper.mockInsert(dummyOldCase);
		dummyNewCase.id = dummyOldCase.id;
		
		Boolean result = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
		 		result = DUMMY_STRATEGY.onBeforeUpdate(new Map<Id, Case>{ dummyOldCase.id => dummyOldCase }, new Map<Id, Case>{ dummyNewCase.id => dummyNewCase });
		 	}
		 	Test.stopTest();
		}

		System.assert(result);
		assertExecution(requiresUpdate, TEST_RUN_USER.id, dummyNewCase);	
	}

	private static testMethod void notRequiredOnBeforeUpdateTest() { onBeforeUpdateTest(false); } 				
	private static testMethod void requiredOnnBeforeUpdateTest()   { onBeforeUpdateTest(true);  } 				

	
	// --------------------------------------------------------------------------------------------------------------------
	
	private static void createUserLookUpMapping (String dummyCountryCode)
	{
		TEST_DummyUserLookupMappingFactory.Config config = new TEST_DummyUserLookupMappingFactory.Config(dummyCountryCode);
										    	  config.consumerComplaintManager = 'ES_Consumer_Quality_Complaints_Manager';
				            					  config.qualityAssistantManager  = 'ES_Quality_Administrative_Assistant';
				            					  config.qualityCaseOwner		  =	'ES_Quality_Agent';
				            					  config.qualityManager			  =	'ES_Quality_Manager';
				            					  config.serviceManager			  =	'PT_Infoline_Supervisor';
		TEST_DummyUserLookupMappingFactory.create(config, TEST_DummyInsertModeEnum.REAL); 
	}
	
	private static void populateUserCache()
	{
		ECICCaseTriggerUserCache.activeUserIdByUserRoleDeveloperNameCache.put ('ES_Consumer_Quality_Complaints_Manager', DUMMY_ID_BY_ROLENAME_MAP.get('consumerComplaintManager'));
		ECICCaseTriggerUserCache.activeUserIdByUserRoleDeveloperNameCache.put ('ES_Quality_Administrative_Assistant', 	 DUMMY_ID_BY_ROLENAME_MAP.get('qualityAdminAssistant'));
		ECICCaseTriggerUserCache.activeUserIdByUserRoleDeveloperNameCache.put ('ES_Quality_Agent', 						 DUMMY_ID_BY_ROLENAME_MAP.get('qualityCaseOwner'));
		ECICCaseTriggerUserCache.activeUserIdByUserRoleDeveloperNameCache.put ('ES_Quality_Manager',					 DUMMY_ID_BY_ROLENAME_MAP.get('qualityManager'));
		ECICCaseTriggerUserCache.activeUserIdByUserRoleDeveloperNameCache.put ('PT_Infoline_Supervisor', 				 DUMMY_ID_BY_ROLENAME_MAP.get('serviceManager'));
	}

	// --------------------------------------------------------------------------------------------------------------------

	private static void assertExecution(Boolean countryHasMapping, Id expectedAlternativeId, Case resultCase)
	{
		System.assertEquals ((countryHasMapping ? DUMMY_ID_BY_ROLENAME_MAP.get('consumerComplaintManager') : expectedAlternativeId), resultCase.Consumer_Complaint_Manager__c);
		System.assertEquals ((countryHasMapping ? DUMMY_ID_BY_ROLENAME_MAP.get('qualityAdminAssistant')    : expectedAlternativeId), resultCase.Quality_Admin_Assistant__c);
		System.assertEquals ((countryHasMapping ? DUMMY_ID_BY_ROLENAME_MAP.get('qualityCaseOwner') 		   : expectedAlternativeId), resultCase.Quality_Case_Owner__c);
		System.assertEquals ((countryHasMapping ? DUMMY_ID_BY_ROLENAME_MAP.get('qualityManager') 		   : expectedAlternativeId), resultCase.Quality_Manager__c);
		System.assertEquals ((countryHasMapping ? DUMMY_ID_BY_ROLENAME_MAP.get('serviceManager') 		   : expectedAlternativeId), resultCase.Service_Manager__c);
	}

	private static void assertExecution(Boolean countryHasMapping, Case resultCase)
	{
		assertExecution(countryHasMapping, null, resultCase);	
	}	

}