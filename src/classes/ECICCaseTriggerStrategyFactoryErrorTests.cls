@isTest
private class ECICCaseTriggerStrategyFactoryErrorTests 
{
  	private static final User TEST_RUN_USER   = ECICRunUserTestHelper.create();

	private static testMethod void addErrorTest()   											
	{
		String dummyErrorMessage = 'Dummy Error Message';
		
	  	System.runAs(TEST_RUN_USER) 
	  	{
			Test.startTest();
			{ 
				ECICCaseTriggerStrategyFactory.addError (dummyErrorMessage);
			}
			Test.stopTest();
	  	}
		
		System.assert(new Set<String>(ECICCaseTriggerStrategyFactory.errorLogList).contains(dummyErrorMessage));
		// Unfortunately, SFDC provides no functionality for checking the log has been updated.
	}
	
	// -----------------------------------------------------------------------------

	private static void mapStrategyConfigurationByRankTest(Boolean hasErrorTest)   											
	{
		Case_Trigger_Strategy_Configuration__c 	dummyConfig		 	 = TEST_DummyCaseTrigStrategyConfigFactory.create(TEST_DummyInsertModeEnum.NONE);
		String									dummyCountryCode 	 = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_COUNTRY;
		String									dummyTriggerTypeName = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_TRIGGER_TYPE.name();
		String									dummyKey			 = dummyCountryCode + dummyTriggerTypeName;
		
		Map<Integer, Case_Trigger_Strategy_Configuration__c> dummyConfigByRankMap = new Map<Integer, Case_Trigger_Strategy_Configuration__c>
		{
			((Integer) dummyConfig.Rank__c + ((hasErrorTest) ? 0 : 1)) => dummyConfig
		};

		Map<String, Map<Integer, Case_Trigger_Strategy_Configuration__c>> dummyStrategyConfigurationByRankByCountryTriggerTypeMap = new Map<String, Map<Integer, Case_Trigger_Strategy_Configuration__c>>
		{
			dummyKey	=> dummyConfigByRankMap
		};
		
	  	System.runAs(TEST_RUN_USER) 
	  	{
			Test.startTest();
			{ 
				ECICCaseTriggerStrategyFactory.mapStrategyConfigurationByRank (dummyStrategyConfigurationByRankByCountryTriggerTypeMap, dummyConfig, dummyKey, dummyCountryCode, dummyTriggerTypeName);
			}
			Test.stopTest();
	  	}
	  	
	  	List<String> resultErrorList = ECICCaseTriggerStrategyFactory.errorLogList;
		System.assertEquals(((hasErrorTest) ? 1 : 0), resultErrorList.size());
		if (hasErrorTest) { System.assert(resultErrorList[0].contains('has multiple instances of rank')); }
	}
	
	private static testMethod void mapStrategyConfigurationByRankWithGoodRankTest() { mapStrategyConfigurationByRankTest(false); }
	private static testMethod void mapStrategyConfigurationByRankWithBadRankTest()  { mapStrategyConfigurationByRankTest(true);  }

	// -----------------------------------------------------------------------------

	private static void convertStrategyTest(Boolean hasErrorTest)   											
	{
		TEST_DummyCaseTrigStrategyConfigFactory.Config config = new TEST_DummyCaseTrigStrategyConfigFactory.Config();
		if (hasErrorTest) { config.strategyApexClassName = 'VeryNaughtyNonExistantStrategy'; }
		Case_Trigger_Strategy_Configuration__c 	dummyConfig	 = TEST_DummyCaseTrigStrategyConfigFactory.create(config, TEST_DummyInsertModeEnum.NONE);
		
		String									dummyKey 	 = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_COUNTRY + TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_TRIGGER_TYPE.name();
		Integer									dummyRank	 = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_RANK;

		Map<Integer, Case_Trigger_Strategy_Configuration__c> dummyConfigByRank = new Map<Integer, Case_Trigger_Strategy_Configuration__c>
		{
			dummyRank => dummyConfig
		};
		
		
	  	System.runAs(TEST_RUN_USER) 
	  	{
			Test.startTest();
			{ 
				ECICCaseTriggerStrategyFactory.convertStrategy(dummyConfigByRank, dummyKey, dummyRank); 
			}
			Test.stopTest();
	  	}

	  	List<String> resultErrorList = ECICCaseTriggerStrategyFactory.errorLogList;
		System.assertEquals(((hasErrorTest) ? 1 : 0), resultErrorList.size());
		if (hasErrorTest) { System.assert(resultErrorList[0].contains('contains invalid strategy name')); }
	}

	private static testMethod void convertStrategyGoodClassNameTest() { convertStrategyTest(false); }
	private static testMethod void convertStrategyBadClassName()  	  { convertStrategyTest(true);  }

	// -----------------------------------------------------------------------------

	private static void staticConstructionTest (Boolean hasRankError, Boolean hasStrategyError)
	{
   		TEST_DummyGeneralSettingsFactory.create(true);
		TEST_DummyCaseTrigStrategyConfigFactory.createList(hasRankError, hasStrategyError, TEST_DummyInsertModeEnum.REAL);
		Integer emailLimitBeforeException = Limits.getEmailInvocations();

		Boolean errorCaught = false;
	  	System.runAs(TEST_RUN_USER) 
	  	{
			Test.startTest();
			{ 
				try
				{
					ECICCaseTriggerStrategyFactory.getCountryCodeSet(); // arbitrary method to trigger static construction for class.
				}
				catch (ECICCaseTriggerStrategyConfigException configException)
				{
					errorCaught = true;
				}
			}
	  	}		

		System.assertEquals(hasRankError || hasStrategyError, errorCaught);
		if (errorCaught) { System.assertEquals(1, Limits.getEmailInvocations() - emailLimitBeforeException); }

		Integer expectedErrorListSize = (hasRankError?1:0) + (hasStrategyError?1:0);
		System.assertEquals(expectedErrorListSize, ECICCaseTriggerStrategyFactory.errorLogList.size());
	}

	private static testMethod void noErrorStaticConstructionTest() 		{ staticConstructionTest(false, false); }
	private static testMethod void badStrategyStaticConstructionTest() 	{ staticConstructionTest(false, true);  }
	private static testMethod void badRankStaticConstructionTest() 		{ staticConstructionTest(true,  false); }
	private static testMethod void twoErrorstaticConstructionTest() 	{ staticConstructionTest(true,  true);  }


}