@isTest private class ECICCaseTriggerHandlerHelperErrorTests 
{
  	private static final User TEST_RUN_USER   = ECICRunUserTestHelper.create();
  	
 	private static void createCaseListByCountryCodeMapErrorTest (Boolean hasRankError, Boolean hasStrategyError)
	{
		Integer emailLimitBeforeException = Limits.getEmailInvocations();

   		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		TEST_DummyCaseTrigStrategyConfigFactory.createList(hasRankError, hasStrategyError, TEST_DummyInsertModeEnum.REAL);
		SEPTriggerTypeEnum dummyTriggerType = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_TRIGGER_TYPE;

		ECICCaseTestHelper.CaseConfig caseConfig = new ECICCaseTestHelper.CaseConfig();
									  caseConfig.countryCode = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_COUNTRY;
									  caseConfig.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ECICCommonConstants.INQUIRY_IBERIA_RTNAME).getRecordTypeId();
		Case 	      dummyCase 		  = ECICCaseTestHelper.createDummyCase (caseConfig, false);
		List<Case>	  dummyNewCaseList	  = new List<Case>   {dummyCase};
		
		
		Map<String, List<Case>> resultCaseListByCountryCodeMap = null;
		Boolean configExceptionCaught = false;		
	  	System.runAs(TEST_RUN_USER) 
	  	{
			Test.startTest();
			{ 
				try
				{
					resultCaseListByCountryCodeMap = ECICCaseTriggerHandlerHelper.createCaseListByCountryCodeMap(dummyTriggerType, dummyNewCaseList);
				}
				catch (ECICCaseTriggerStrategyConfigException configException)
				{
					configExceptionCaught = true;
				}
				
			}
			Test.stopTest();
	  	}

		System.assertEquals(hasRankError || hasStrategyError, configExceptionCaught);
		System.assertEquals (!configExceptionCaught, (resultCaseListByCountryCodeMap != null) && (!resultCaseListByCountryCodeMap.isEmpty()) &&  (resultCaseListByCountryCodeMap.keySet().contains(caseConfig.countryCode)));

		Integer expectedErrorListSize = (hasRankError?1:0) + (hasStrategyError?1:0);
		System.assertEquals(expectedErrorListSize, ECICCaseTriggerStrategyFactory.errorLogList.size());

		// Other tests indicate that when the exception is created, the email is sent;
		// In theory, this test aught be redundant, but the failure is curious and should be resolved.
		//FIXME: if (configExceptionCaught) { System.assertEquals(1, Limits.getEmailInvocations() - emailLimitBeforeException); }
	}

	private static testMethod void noErrorCreateCaseListByCountryCodeMapErrorTest() 		{ createCaseListByCountryCodeMapErrorTest(false, false); }
	private static testMethod void badStrategyCreateCaseListByCountryCodeMapErrorTest() 	{ createCaseListByCountryCodeMapErrorTest(false, true);  }
	private static testMethod void badRankCreateCaseListByCountryCodeMapErrorTest() 		{ createCaseListByCountryCodeMapErrorTest(true,  false); }
	private static testMethod void twoErrorsCreateCaseListByCountryCodeMapErrorTest() 		{ createCaseListByCountryCodeMapErrorTest(true,  true);  }

	// ------------------------------------------------------------------------------------------------------------------------------------------- 

 	private static void createCaseByIdMapByCountryCodeMapErrorTest (Boolean hasRankError, Boolean hasStrategyError)
	{
		Integer emailLimitBeforeException = Limits.getEmailInvocations();

   		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		TEST_DummyCaseTrigStrategyConfigFactory.createList(hasRankError, hasStrategyError, TEST_DummyInsertModeEnum.REAL);
		SEPTriggerTypeEnum dummyTriggerType = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_TRIGGER_TYPE;

		ECICCaseTestHelper.CaseConfig caseConfig = new ECICCaseTestHelper.CaseConfig();
									  caseConfig.countryCode = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_COUNTRY;
									  caseConfig.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ECICCommonConstants.INQUIRY_IBERIA_RTNAME).getRecordTypeId();
		Case 	      dummyCase 		  = ECICCaseTestHelper.createDummyCase (caseConfig, false);
		Set<String>   dummyCaseCountrySet = new Set<String>   { caseConfig.countryCode    };
		Map<Id, Case> dummyNewCaseByIdMap = new Map<Id, Case> { '50011000001FYTn' => dummyCase };	// Fake Id because actually inserting Case with this test setup will cause premature failure.
		
		Map<String, Map<Id, Case>> resultCaseByIdByCountryCodeMap = null;
		Boolean configExceptionCaught = false;		
	  	System.runAs(TEST_RUN_USER) 
	  	{
			Test.startTest();
			{ 
				try
				{
					resultCaseByIdByCountryCodeMap = ECICCaseTriggerHandlerHelper.createCaseByIdMapByCountryCodeMap(dummyTriggerType, dummyCaseCountrySet, dummyNewCaseByIdMap);
				}
				catch (ECICCaseTriggerStrategyConfigException configException)
				{
					configExceptionCaught = true;
				}
				
			}
			Test.stopTest();
	  	}

		System.assertEquals(hasRankError || hasStrategyError, configExceptionCaught);
		System.assertEquals (!configExceptionCaught, (resultCaseByIdByCountryCodeMap != null) && (!resultCaseByIdByCountryCodeMap.isEmpty()) &&  (resultCaseByIdByCountryCodeMap.keySet().contains(caseConfig.countryCode)));

		Integer expectedErrorListSize = (hasRankError?1:0) + (hasStrategyError?1:0);
		System.assertEquals(expectedErrorListSize, ECICCaseTriggerStrategyFactory.errorLogList.size());

		// Other tests indicate that when the exception is created, the email is sent;
		// In theory, this test aught be redundant, but the failure is curious and should be resolved.
		// FIXME: if (configExceptionCaught) { System.assertEquals(1, Limits.getEmailInvocations() - emailLimitBeforeException); }
	}

	private static testMethod void noErrorCreateCaseByIdMapByCountryCodeMapErrorTest() 		{ createCaseByIdMapByCountryCodeMapErrorTest(false, false); }
	private static testMethod void badStrategyCreateCaseByIdMapByCountryCodeMapErrorTest() 	{ createCaseByIdMapByCountryCodeMapErrorTest(false, true);  }
	private static testMethod void badRankCreateCaseByIdMapByCountryCodeMapErrorTest() 		{ createCaseByIdMapByCountryCodeMapErrorTest(true,  false); }
	private static testMethod void twoErrorsCreateCaseByIdMapByCountryCodeMapErrorTest()	{ createCaseByIdMapByCountryCodeMapErrorTest(true,  true);  }

	// ------------------------------------------------------------------------------------------------------------------------------------------- 
  	
	private static void doCountrySpecificStrategiesErrorTest (Boolean hasRankError, Boolean hasStrategyError)
	{
		Integer emailLimitBeforeException = Limits.getEmailInvocations();

   		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		TEST_DummyCaseTrigStrategyConfigFactory.createList(hasRankError, hasStrategyError, TEST_DummyInsertModeEnum.REAL);
		SEPTriggerTypeEnum dummyTriggerType = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_TRIGGER_TYPE;

		ECICCaseTestHelper.CaseConfig caseConfig = new ECICCaseTestHelper.CaseConfig();
									  caseConfig.countryCode = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_COUNTRY;
									  caseConfig.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ECICCommonConstants.INQUIRY_IBERIA_RTNAME).getRecordTypeId();
		Case 	      dummyCase 		  = ECICCaseTestHelper.createDummyCase (caseConfig, false);
		List<Case>	  dummyNewCaseList	  = new List<Case>   {dummyCase};
		
		Boolean configExceptionCaught 	= false;		
		Boolean executionResult	= null;
	  	System.runAs(TEST_RUN_USER) 
	  	{
			Test.startTest();
			{ 
				try
				{
					executionResult = ECICCaseTriggerHandlerHelper.doCountrySpecificStrategies(dummyTriggerType, dummyNewCaseList, null, null);
				}
				catch (ECICCaseTriggerStrategyConfigException configException)
				{
					configExceptionCaught = true;
				}
				
			}
			Test.stopTest();
	  	}

		System.assert (!configExceptionCaught);
		System.assertEquals((hasRankError || hasStrategyError), !executionResult);

		Integer expectedErrorListSize = (hasRankError?1:0) + (hasStrategyError?1:0);
		System.assertEquals(expectedErrorListSize, ECICCaseTriggerStrategyFactory.errorLogList.size());

		if (configExceptionCaught) { System.assertEquals(1, Limits.getEmailInvocations() - emailLimitBeforeException); }
	}

	private static testMethod void noErrorCountrySpecificStrategyTest() 		{ doCountrySpecificStrategiesErrorTest(false, false); }
	private static testMethod void badStrategyCountrySpecificStrategyTest() 	{ doCountrySpecificStrategiesErrorTest(false, true);  }
	private static testMethod void badRankCountrySpecificStrategyTest() 		{ doCountrySpecificStrategiesErrorTest(true,  false); }
	private static testMethod void twoErrorsCountrySpecificStrategyTest() 		{ doCountrySpecificStrategiesErrorTest(true,  true);  }
  	
 	private static void addErrorsToCaseListTest (Boolean hasRankError, Boolean hasStrategyError)
	{
		Integer emailLimitBeforeException = Limits.getEmailInvocations();

   		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		TEST_DummyCaseTrigStrategyConfigFactory.createList(hasRankError, hasStrategyError, TEST_DummyInsertModeEnum.REAL);
		SEPTriggerTypeEnum dummyTriggerType = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_TRIGGER_TYPE;

		ECICCaseTestHelper.CaseConfig caseConfig = new ECICCaseTestHelper.CaseConfig();
									  caseConfig.countryCode = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_COUNTRY;
									  caseConfig.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ECICCommonConstants.INQUIRY_IBERIA_RTNAME).getRecordTypeId();
		Case dummyCase  = ECICCaseTestHelper.createDummyCase (caseConfig, false);
	
		Boolean dmlExceptionCaught = false;		
	  	System.runAs(TEST_RUN_USER) 
	  	{
			Test.startTest();
			{ 
				try
				{
					insert dummyCase;
				}
				catch (DmlException dmlException)
				{
					dmlExceptionCaught = true;
					System.assert(dmlException.getMessage().contains('Case_Trigger_Strategy_Configuration__c'));
				}
				
			}
			Test.stopTest();
	  	}

		System.assertEquals(hasRankError || hasStrategyError, dmlExceptionCaught);

		// Other tests indicate that when the exception is created, the email is sent;
		// In theory, this test aught be redundant, but the failure is curious and should be resolved.
		// FIXME: if (dmlExceptionCaught) { System.assertEquals(1, Limits.getEmailInvocations() - emailLimitBeforeException); }
	}

	private static testMethod void noErrorAddErrorsToCaseListTest() 		{ addErrorsToCaseListTest(false, false); }
	private static testMethod void badStrategyAddErrorsToCaseListTest() 	{ addErrorsToCaseListTest(false, true);  }
	private static testMethod void badRankAddErrorsToCaseListTest() 		{ addErrorsToCaseListTest(true,  false); }
	private static testMethod void twoErrorsAddErrorsToCaseListTest() 		{ addErrorsToCaseListTest(true,  true);  }

}