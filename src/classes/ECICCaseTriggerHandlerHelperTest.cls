@isTest
private class ECICCaseTriggerHandlerHelperTest 
{
  	private static final User TEST_RUN_USER   = ECICRunUserTestHelper.create();

	private static void createCaseListByCountryCodeMapTest (Boolean hasCustomConfig)   											
	{
   		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		if (hasCustomConfig) { TEST_DummyCaseTrigStrategyConfigFactory.create(TEST_DummyInsertModeEnum.REAL); } 
		
		SEPTriggerTypeEnum 	dummyTriggerType = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_TRIGGER_TYPE;
		String 				dummyCountry 	 = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_COUNTRY;
		
		ECICCaseTestHelper.CaseConfig caseConfig = new ECICCaseTestHelper.CaseConfig();
		//#Ecic Template test
									  caseConfig.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ECICCommonConstants.INQUIRY_IBERIA_RTNAME).getRecordTypeId();
									  caseConfig.countryCode  = dummyCountry;
		Case 	   dummyCase 		= ECICCaseTestHelper.createDummyCase (caseConfig, false);
		List<Case> dummyCaseList	= new List<Case> { dummyCase };
		
  		Map<String, List<Case>> resultCaseListByCountryCodeMap = null; 
	  	System.runAs(TEST_RUN_USER) 
	  	{
			Test.startTest();
			{ 
				resultCaseListByCountryCodeMap = ECICCaseTriggerHandlerHelper.createCaseListByCountryCodeMap(dummyTriggerType, dummyCaseList);
			}
			Test.stopTest();
	  	}
	  	
	  	String expectedCountryCode = (hasCustomConfig) ? dummyCountry : 'OTHER';
	  	System.assertEquals (1, resultCaseListByCountryCodeMap.size());
	  	System.assert (resultCaseListByCountryCodeMap.keySet().contains (expectedCountryCode));
	  	
	  	List<Case> resultCaseList = resultCaseListByCountryCodeMap.get(expectedCountryCode);
	  	System.assertEquals (dummyCase, resultCaseList[0]);
	}

	private static testMethod void hasCustomCountryCreateCaseListByCountryCodeMapTest() { createCaseListByCountryCodeMapTest(true);  }
	private static testMethod void otherCountyCreateCaseListByCountryCodeMapTest() 		{ createCaseListByCountryCodeMapTest(false); }

	//------------------------------------------------------------------------------------------------------------
	
	private static void createCaseByIdMapByCountryCodeMapTest (Boolean hasCustomConfig)   											
	{
   		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		if (hasCustomConfig) { TEST_DummyCaseTrigStrategyConfigFactory.create(TEST_DummyInsertModeEnum.REAL); } 
		
		SEPTriggerTypeEnum 	dummyTriggerType = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_TRIGGER_TYPE;
		String 				dummyCountry 	 = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_COUNTRY;
		
		ECICCaseTestHelper.CaseConfig caseConfig = new ECICCaseTestHelper.CaseConfig();
				//#Ecic Template test
									  caseConfig.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ECICCommonConstants.INQUIRY_IBERIA_RTNAME).getRecordTypeId();
									  caseConfig.countryCode  = (hasCustomConfig) ? dummyCountry : 'OT';
		Case 	      dummyCase 		 = ECICCaseTestHelper.createDummyCase (caseConfig, true);
		Map<Id, Case> dummyCaseByIdMap   = new Map<Id, Case> { dummyCase.id => dummyCase };  
		Set<String>   dummyCaseCountySet = new Set<String>{ (hasCustomConfig) ? dummyCountry : 'OTHER' };
		
		Map<String, Map<Id, Case>> resultCaseByIdMapByCountryCodeMap = null;
	  	System.runAs(TEST_RUN_USER) 
	  	{
			Test.startTest();
			{ 
				resultCaseByIdMapByCountryCodeMap = ECICCaseTriggerHandlerHelper.createCaseByIdMapByCountryCodeMap(dummyTriggerType, dummyCaseCountySet, dummyCaseByIdMap);
			}
			Test.stopTest();
	  	}

	  	String expectedCountryCode = (hasCustomConfig) ? dummyCountry : 'OTHER';
	  	System.assertEquals (1, resultCaseByIdMapByCountryCodeMap.size());	
	  	System.assert (resultCaseByIdMapByCountryCodeMap.keySet().contains (expectedCountryCode));
	  	
	  	Map<Id, Case> resultCaseByIdMap = resultCaseByIdMapByCountryCodeMap.get(expectedCountryCode);
	  	System.assertEquals (1, resultCaseByIdMap.size());
	  	System.assert (resultCaseByIdMap.keySet().contains (dummyCase.id));
	  	System.assertEquals (dummyCase, resultCaseByIdMap.get(dummyCase.id));
	}

	private static testMethod void hasCustomCountryCreateCaseByIdMapByCountryCodeMapTest()  { createCaseByIdMapByCountryCodeMapTest(true);  }
	private static testMethod void otherCountyCreateCaseByIdMapByCountryCodeMapTest() 		{ createCaseByIdMapByCountryCodeMapTest(false); }

	//------------------------------------------------------------------------------------------------------------

	private static void doMandatoryStrategiesTest (SEPTriggerTypeEnum dummyTriggerType)   											
	{
   		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		TEST_DummyInsertModeEnum 	  insertMode = (dummyTriggerType != SEPTriggerTypeEnum.BEFORE_INSERT)
													? TEST_DummyInsertModeEnum.MOCK
													: TEST_DummyInsertModeEnum.NONE;
		
		TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
									  caseConfig.subject      = 'Mandatory Stategy Test';
							 caseConfig.skipStrategies = false;
							 caseConfig.ownerUserId	   = TEST_RUN_USER.id;

		Case 	      dummyCase 		  = TEST_DummyInquiryCaseFactory.create (caseConfig, insertMode);
					  dummyCase.country_code__c = null;		// This needs to be set after creation to clear it, so we can prove the mandatory Strategies are working.

		List<Case>	  dummyNewCaseList	  = new List<Case>   {dummyCase};
		Map<Id,Case>  dummyNewCaseByIdMap = new Map<Id,Case> {dummyCase.id => dummyCase};
		Map<Id,Case>  dummyOldCaseByIdMap = new Map<Id,Case> {dummyCase.id => dummyCase};
		
		ECICCaseTriggerUserCache.populate (dummyNewCaseList);	
		
		Boolean result = null;
	  	System.runAs(TEST_RUN_USER) 
	  	{
			Test.startTest();
			{ 
				result = ECICCaseTriggerHandlerHelper.doMandatoryStrategies(dummyTriggerType, dummyNewCaseList, dummyOldCaseByIdMap, dummyNewCaseByIdMap);
			}
			Test.stopTest();
	  	}
	  	
	  	System.assert (result);
        System.assertEquals (
        						(new Set<SEPTriggerTypeEnum>{SEPTriggerTypeEnum.BEFORE_INSERT, SEPTriggerTypeEnum.BEFORE_UPDATE}).contains(dummyTriggerType),
        						(dummyCase.Country_Code__c != null)
        					);
	}

	private static testMethod void beforeInsertDoMandatoryStrategies()  { doMandatoryStrategiesTest(SEPTriggerTypeEnum.BEFORE_INSERT);  }
	private static testMethod void beforeUpdateDoMandatoryStrategies()  { doMandatoryStrategiesTest(SEPTriggerTypeEnum.BEFORE_UPDATE);  }
	private static testMethod void afterInsertDoMandatoryStrategies()   { doMandatoryStrategiesTest(SEPTriggerTypeEnum.AFTER_INSERT);   }
	private static testMethod void afterUpdateDoMandatoryStrategies()   { doMandatoryStrategiesTest(SEPTriggerTypeEnum.AFTER_UPDATE);   }
	private static testMethod void beforeDeleteDoMandatoryStrategies()  { doMandatoryStrategiesTest(SEPTriggerTypeEnum.BEFORE_DELETE);  }
	private static testMethod void afterDeleteDoMandatoryStrategies()   { doMandatoryStrategiesTest(SEPTriggerTypeEnum.AFTER_DELETE);   }
	private static testMethod void afterUndeleteDoMandatoryStrategies() { doMandatoryStrategiesTest(SEPTriggerTypeEnum.AFTER_UNDELETE); }

	private static testMethod void doMandatoryStrategiesFailureTest ()   											
	{
   		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);

		Case dummyCase = TEST_DummyInquiryCaseFactory.create();
		TEST_MockHelper.setMockBoolean(dummyCase, 'skipStrategies', 				  false);
		TEST_MockHelper.setMockBoolean(dummyCase, 'doMandatoryStrategiesFailureTest', true);
		
		Boolean result = null;
	  	System.runAs(TEST_RUN_USER) 
	  	{
			Test.startTest();
			{ 
				result = ECICCaseTriggerHandlerHelper.doMandatoryStrategies(SEPTriggerTypeEnum.BEFORE_INSERT, new List<Case>{ dummyCase }, null, null);
			}
			Test.stopTest();
	  	}
	  	
	  	System.assert (!result);
	}

	private static void processStrategyChainTest (SEPTriggerTypeEnum dummyTriggerType, Boolean passTestExpected)   											
	{
		Boolean insertNow = (dummyTriggerType != SEPTriggerTypeEnum.BEFORE_INSERT);
   		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);

		ECICCaseTestHelper.CaseConfig caseConfig = new ECICCaseTestHelper.CaseConfig();
									  caseConfig.subject  = (passTestExpected) ? 'Pass Test' : ECICCaseTriggerHandlerTestStrategy.DO_FAIL_TEST;	 
		Case 	      dummyCase = ECICCaseTestHelper.createDummyCase (caseConfig, insertNow);
		Id			  dummyCaseId			 = dummyCase.id;
		
		List<Case>	  dummyNewCaseList	  = new List<Case>   {dummyCase};
		Map<Id,Case>  dummyOldCaseByIdMap = new Map<Id,Case> {dummyCase.id => dummyCase};
		Map<Id,Case>  dummyNewCaseByIdMap = new Map<Id,Case> {dummyCase.id => dummyCase};

		List<SEPTriggerHandlerStrategy> dummyStrategyChainList = new List<SEPTriggerHandlerStrategy>{ new ECICCaseTriggerHandlerTestStrategy() }; 
		Boolean passTestResult = null;
	  	System.runAs(TEST_RUN_USER) 
	  	{
			Test.startTest();
			{ 
				passTestResult = ECICCaseTriggerHandlerHelper.processStrategyChain (dummyTriggerType, dummyStrategyChainList,  dummyNewCaseList, dummyOldCaseByIdMap, dummyNewCaseByIdMap);
			}
			Test.stopTest();
	  	}

		if ((new Set<SEPTriggerTypeEnum>{SEPTriggerTypeEnum.BEFORE_DELETE, SEPTriggerTypeEnum.AFTER_DELETE}).contains(dummyTriggerType))
		{
			ECICCaseTriggerHandlerTestStrategy.assertExecution(passTestExpected, passTestResult, dummyTriggerType, dummyCaseId);
		}
		else
		{
			ECICCaseTriggerHandlerTestStrategy.assertExecution(passTestExpected, passTestResult, dummyTriggerType, dummyCase);
		}
		
	}

	private static testMethod void beforeInsertProcessStrategyChainPassTest() 	{ processStrategyChainTest (SEPTriggerTypeEnum.BEFORE_INSERT, 	true);  }
	private static testMethod void afterInsertProcessStrategyChainPassTest() 	{ processStrategyChainTest (SEPTriggerTypeEnum.AFTER_INSERT, 	true);  }
	private static testMethod void beforeUpdateProcessStrategyChainPassTest() 	{ processStrategyChainTest (SEPTriggerTypeEnum.BEFORE_UPDATE, 	true);  }
	private static testMethod void afterUpdateProcessStrategyChainPassTest() 	{ processStrategyChainTest (SEPTriggerTypeEnum.AFTER_UPDATE, 	true);  }
	private static testMethod void beforeDeleteProcessStrategyChainPassTest() 	{ processStrategyChainTest (SEPTriggerTypeEnum.BEFORE_DELETE, 	true);  }
	private static testMethod void afterDeleteProcessStrategyChainPassTest() 	{ processStrategyChainTest (SEPTriggerTypeEnum.AFTER_DELETE, 	true);  }
	private static testMethod void afterUndeleteProcessStrategyChainPassTest() 	{ processStrategyChainTest (SEPTriggerTypeEnum.AFTER_UNDELETE, 	true);  }

	private static testMethod void beforeInsertProcessStrategyChainFailTest() 	{ processStrategyChainTest (SEPTriggerTypeEnum.BEFORE_INSERT, 	false);  }
	private static testMethod void afterInsertProcessStrategyChainFailTest() 	{ processStrategyChainTest (SEPTriggerTypeEnum.AFTER_INSERT, 	false);  }
	private static testMethod void beforeUpdateProcessStrategyChainFailTest() 	{ processStrategyChainTest (SEPTriggerTypeEnum.BEFORE_UPDATE, 	false);  }
	private static testMethod void afterUpdateProcessStrategyChainFailTest() 	{ processStrategyChainTest (SEPTriggerTypeEnum.AFTER_UPDATE, 	false);  }
	private static testMethod void beforeDeleteProcessStrategyChainFailTest() 	{ processStrategyChainTest (SEPTriggerTypeEnum.BEFORE_DELETE, 	false);  }
	private static testMethod void afterDeleteProcessStrategyChainFailTest() 	{ processStrategyChainTest (SEPTriggerTypeEnum.AFTER_DELETE, 	false);  }
	private static testMethod void afterUndeleteProcessStrategyChainFailTest() 	{ processStrategyChainTest (SEPTriggerTypeEnum.AFTER_UNDELETE, 	false);  }
}