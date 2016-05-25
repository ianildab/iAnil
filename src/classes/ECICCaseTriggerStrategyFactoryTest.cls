@isTest 
private class ECICCaseTriggerStrategyFactoryTest 
{
  	private static final User TEST_RUN_USER   = ECICRunUserTestHelper.create();

	private static void getStrategyListTest(SEPTriggerTypeEnum dummyTypeEnum)   											
	{
		TEST_DummyCaseTrigStrategyConfigFactory.create(dummyTypeEnum, TEST_DummyInsertModeEnum.REAL);
		 
		List<SEPTriggerHandlerStrategy> resultStrategyList = null;
	  	System.runAs(TEST_RUN_USER) 
	  	{
			Test.startTest();
			{ 
				resultStrategyList = ECICCaseTriggerStrategyFactory.getStrategyList(dummyTypeEnum, TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_COUNTRY);
			}
			Test.stopTest();
	  	}
	  	
		System.assertEquals (1, 			resultStrategyList.size());
		System.assertEquals (TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_STRATEGY_NAME, getClassName(resultStrategyList[0]));
	}

	private static testMethod void beforeInsertGetStrategyListTest() 	{ getStrategyListTest (SEPTriggerTypeEnum.BEFORE_INSERT); 	}
	private static testMethod void afterInsertGetStrategyListTest() 	{ getStrategyListTest (SEPTriggerTypeEnum.AFTER_INSERT); 	}
	private static testMethod void beforeUpdateGetStrategyListTest() 	{ getStrategyListTest (SEPTriggerTypeEnum.BEFORE_UPDATE); 	}
	private static testMethod void afterUpdateGetStrategyListTest() 	{ getStrategyListTest (SEPTriggerTypeEnum.AFTER_UPDATE); 	}
	private static testMethod void beforeDeleteGetStrategyListTest() 	{ getStrategyListTest (SEPTriggerTypeEnum.BEFORE_DELETE); 	}
	private static testMethod void afterDeleteGetStrategyListTest() 	{ getStrategyListTest (SEPTriggerTypeEnum.AFTER_DELETE); 	}
	private static testMethod void afterUndeleteGetStrategyListTest() 	{ getStrategyListTest (SEPTriggerTypeEnum.AFTER_UNDELETE); 	}
	
	//-----------------------------------------------------------------------------------------------------------------------------------

	private static void getCountryCodeTriggerSetTest(SEPTriggerTypeEnum dummyTypeEnum) 											
	{
		TEST_DummyCaseTrigStrategyConfigFactory.create(dummyTypeEnum, TEST_DummyInsertModeEnum.REAL);
		 
		Set<String> resultCountryCodeTriggerSet = null;
	  	System.runAs(TEST_RUN_USER) 
	  	{
			Test.startTest();
			{ 
				resultCountryCodeTriggerSet = ECICCaseTriggerStrategyFactory.getCountryCodeTriggerSet();
	}
			Test.stopTest();
	  	}
		System.assertEquals (1, resultCountryCodeTriggerSet.size());
		System.assert (resultCountryCodeTriggerSet.contains(TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_COUNTRY + dummyTypeEnum.name()));
	}

	private static testMethod void beforeInsertGetCountryCodeTriggerSetTest() 	{ getCountryCodeTriggerSetTest (SEPTriggerTypeEnum.BEFORE_INSERT); 	}
	private static testMethod void afterInsertGetCountryCodeTriggerSetTest() 	{ getCountryCodeTriggerSetTest (SEPTriggerTypeEnum.AFTER_INSERT); 	}
	private static testMethod void beforeUpdateGetCountryCodeTriggerSetTest() 	{ getCountryCodeTriggerSetTest (SEPTriggerTypeEnum.BEFORE_UPDATE); 	}
	private static testMethod void afterUpdateGetCountryCodeTriggerSetTest() 	{ getCountryCodeTriggerSetTest (SEPTriggerTypeEnum.AFTER_UPDATE); 	}
	private static testMethod void beforeDeleteGetCountryCodeTriggerSetTest() 	{ getCountryCodeTriggerSetTest (SEPTriggerTypeEnum.BEFORE_DELETE); 	}
	private static testMethod void afterDeleteGetCountryCodeTriggerSetTest() 	{ getCountryCodeTriggerSetTest (SEPTriggerTypeEnum.AFTER_DELETE); 	}
	private static testMethod void afterUndeleteGetCountryCodeTriggerSetTest() 	{ getCountryCodeTriggerSetTest (SEPTriggerTypeEnum.AFTER_UNDELETE); }

	//-----------------------------------------------------------------------------------------------------------------------------------

	private static void getCountryCodeSetTest(SEPTriggerTypeEnum dummyTypeEnum)   											
	{
		TEST_DummyCaseTrigStrategyConfigFactory.create(dummyTypeEnum, TEST_DummyInsertModeEnum.REAL);
		 
		Set<String> resultCountryCodeSet = null;
	  	System.runAs(TEST_RUN_USER) 
	  	{
			Test.startTest();
			{ 
				resultCountryCodeSet = ECICCaseTriggerStrategyFactory.getCountryCodeSet(dummyTypeEnum); 
			}
			Test.stopTest();
	  	}
		System.assertEquals (1, resultCountryCodeSet.size());
		System.assert (resultCountryCodeSet.contains(TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_COUNTRY));
	}

	private static testMethod void beforeInsertGetCountryCodeSetTest() 	{ getCountryCodeSetTest (SEPTriggerTypeEnum.BEFORE_INSERT); 	}
	private static testMethod void afterInsertGetCountryCodeSetTest() 	{ getCountryCodeSetTest (SEPTriggerTypeEnum.AFTER_INSERT); 	}
	private static testMethod void beforeUpdateGetCountryCodeSetTest() 	{ getCountryCodeSetTest (SEPTriggerTypeEnum.BEFORE_UPDATE); 	}
	private static testMethod void afterUpdateGetCountryCodeSetTest() 	{ getCountryCodeSetTest (SEPTriggerTypeEnum.AFTER_UPDATE); 	}
	private static testMethod void beforeDeleteGetCountryCodeSetTest() 	{ getCountryCodeSetTest (SEPTriggerTypeEnum.BEFORE_DELETE); 	}
	private static testMethod void afterDeleteGetCountryCodeSetTest() 	{ getCountryCodeSetTest (SEPTriggerTypeEnum.AFTER_DELETE); 	}
	private static testMethod void afterUndeleteGetCountryCodeSetTest()	{ getCountryCodeSetTest (SEPTriggerTypeEnum.AFTER_UNDELETE); 	}

	//-----------------------------------------------------------------------------------------------------------------------------------

	private static void hasStrategyChainTest(SEPTriggerTypeEnum dummyTypeEnum, Boolean hasTest)   											
	{
		if (hasTest) { TEST_DummyCaseTrigStrategyConfigFactory.create(dummyTypeEnum, TEST_DummyInsertModeEnum.REAL); }
		 
		Boolean result = null;
	  	System.runAs(TEST_RUN_USER) 
			{ 
			Test.startTest();
			{ 
				result = ECICCaseTriggerStrategyFactory.hasStrategyChain(dummyTypeEnum, TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_COUNTRY);
	  	}
			Test.stopTest();
	}
		System.assertEquals (hasTest, result);
}

	private static testMethod void beforeInsertHasStrategyChainTest() 		{ hasStrategyChainTest (SEPTriggerTypeEnum.BEFORE_INSERT,	true); 	}
	private static testMethod void afterInsertHasStrategyChainTest() 		{ hasStrategyChainTest (SEPTriggerTypeEnum.AFTER_INSERT,	true); 	}
	private static testMethod void beforeUpdateHasStrategyChainTest() 		{ hasStrategyChainTest (SEPTriggerTypeEnum.BEFORE_UPDATE,	true); 	}
	private static testMethod void afterUpdateHasStrategyChainTest() 		{ hasStrategyChainTest (SEPTriggerTypeEnum.AFTER_UPDATE,	true); 	}
	private static testMethod void beforeDeleteHasStrategyChainTest() 		{ hasStrategyChainTest (SEPTriggerTypeEnum.BEFORE_DELETE,	true); 	}
	private static testMethod void afterDeleteHasStrategyChainTest() 		{ hasStrategyChainTest (SEPTriggerTypeEnum.AFTER_DELETE,	true); 	}
	private static testMethod void afterUndeleteHasStrategyChainTest()		{ hasStrategyChainTest (SEPTriggerTypeEnum.AFTER_UNDELETE,	true); 	}

	private static testMethod void beforeInsertHasNoStrategyChainTest() 	{ hasStrategyChainTest (SEPTriggerTypeEnum.BEFORE_INSERT,	false); }
	private static testMethod void afterInsertHasNoStrategyChainTest() 		{ hasStrategyChainTest (SEPTriggerTypeEnum.AFTER_INSERT,	false); }
	private static testMethod void beforeUpdateHasNoStrategyChainTest() 	{ hasStrategyChainTest (SEPTriggerTypeEnum.BEFORE_UPDATE,	false); }
	private static testMethod void afterUpdateHasNoStrategyChainTest() 		{ hasStrategyChainTest (SEPTriggerTypeEnum.AFTER_UPDATE,	false); }
	private static testMethod void beforeDeleteHasNoStrategyChainTest() 	{ hasStrategyChainTest (SEPTriggerTypeEnum.BEFORE_DELETE,	false); }
	private static testMethod void afterDeleteHasNoStrategyChainTest() 		{ hasStrategyChainTest (SEPTriggerTypeEnum.AFTER_DELETE,	false); }
	private static testMethod void afterUndeleteHasNoStrategyChainTest()	{ hasStrategyChainTest (SEPTriggerTypeEnum.AFTER_UNDELETE,	false); }

	//-----------------------------------------------------------------------------------------------------------------------------------

	private static void createCaseTriggerStrategyMapTest(SEPTriggerTypeEnum dummyTypeEnum)   											
	{
		TEST_DummyCaseTrigStrategyConfigFactory.create(dummyTypeEnum, TEST_DummyInsertModeEnum.REAL);
		 
		Map<String, List<SEPTriggerHandlerStrategy>> resultCaseTriggerStrategyMap = null;
	  	System.runAs(TEST_RUN_USER) 
	  	{
			Test.startTest();
			{ 
				resultCaseTriggerStrategyMap = ECICCaseTriggerStrategyFactory.createCaseTriggerStrategyMap ();
			}
			Test.stopTest();
	  	}
	  	
		System.assertEquals (1, resultCaseTriggerStrategyMap.size());
		
		String expectedKey = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_COUNTRY + dummyTypeEnum.name();
		System.assert (resultCaseTriggerStrategyMap.keySet().contains(expectedKey));
		
		List<SEPTriggerHandlerStrategy> resultStrategyList = resultCaseTriggerStrategyMap.get(expectedKey);
		System.assertEquals (1, resultStrategyList.size());
		System.assertEquals (TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_STRATEGY_NAME, getClassName(resultStrategyList[0]));
	}

	private static testMethod void beforeInsertCreateCaseTriggerStrategyMapTest() 	{ createCaseTriggerStrategyMapTest (SEPTriggerTypeEnum.BEFORE_INSERT); 	}
	private static testMethod void afterInsertCreateCaseTriggerStrategyMapTest() 	{ createCaseTriggerStrategyMapTest (SEPTriggerTypeEnum.AFTER_INSERT); 	}
	private static testMethod void beforeUpdateCreateCaseTriggerStrategyMapTest() 	{ createCaseTriggerStrategyMapTest (SEPTriggerTypeEnum.BEFORE_UPDATE); 	}
	private static testMethod void afterUpdateCreateCaseTriggerStrategyMapTest() 	{ createCaseTriggerStrategyMapTest (SEPTriggerTypeEnum.AFTER_UPDATE); 	}
	private static testMethod void beforeDeleteCreateCaseTriggerStrategyMapTest() 	{ createCaseTriggerStrategyMapTest (SEPTriggerTypeEnum.BEFORE_DELETE); 	}
	private static testMethod void afterDeleteCreateCaseTriggerStrategyMapTest() 	{ createCaseTriggerStrategyMapTest (SEPTriggerTypeEnum.AFTER_DELETE); 	}
	private static testMethod void afterUndeleteCreateCaseTriggerStrategyMapTest() 	{ createCaseTriggerStrategyMapTest (SEPTriggerTypeEnum.AFTER_UNDELETE); }

	//-----------------------------------------------------------------------------------------------------------------------------------

	private static void createStrategyConfigurationByRankByCountryTriggerTypeMapTest(SEPTriggerTypeEnum dummyTypeEnum)   											
	{
		Case_Trigger_Strategy_Configuration__c 			dummyConfiguration 		= TEST_DummyCaseTrigStrategyConfigFactory.create(dummyTypeEnum, TEST_DummyInsertModeEnum.NONE);
		List<Case_Trigger_Strategy_Configuration__c> 	dummyConfigurationList 	= new List<Case_Trigger_Strategy_Configuration__c> { dummyConfiguration };
		 
		Map<String, Map<Integer, Case_Trigger_Strategy_Configuration__c>> resultStrategyConfigurationByRankByCountryTriggerTypeMap = null;
	  	System.runAs(TEST_RUN_USER) 
	  	{
			Test.startTest();
			{ 
				resultStrategyConfigurationByRankByCountryTriggerTypeMap = ECICCaseTriggerStrategyFactory.createStrategyConfigurationByRankByCountryTriggerTypeMap (dummyConfigurationList);
			}
			Test.stopTest();
	  	}
	  	
		System.assertEquals (1, resultStrategyConfigurationByRankByCountryTriggerTypeMap.size());
		
		String expectedKey = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_COUNTRY + dummyTypeEnum.name();
		System.assert (resultStrategyConfigurationByRankByCountryTriggerTypeMap.keySet().contains(expectedKey));
		
		Map<Integer, Case_Trigger_Strategy_Configuration__c> resultStrategyConfigurationByRank = resultStrategyConfigurationByRankByCountryTriggerTypeMap.get(expectedKey);
		System.assertEquals (1, resultStrategyConfigurationByRank.size());
		System.assert (resultStrategyConfigurationByRank.keySet().contains(TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_RANK));
		System.assertEquals (TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_STRATEGY_NAME, resultStrategyConfigurationByRank.get(TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_RANK).Strategy_Apex_Class_Name__c);
	}

	private static testMethod void beforeInsertCreateStrategyConfigurationByRankByCountryTriggerTypeMapTest() 	{ createStrategyConfigurationByRankByCountryTriggerTypeMapTest (SEPTriggerTypeEnum.BEFORE_INSERT); 	}
	private static testMethod void afterInsertCreateStrategyConfigurationByRankByCountryTriggerTypeMapTest() 	{ createStrategyConfigurationByRankByCountryTriggerTypeMapTest (SEPTriggerTypeEnum.AFTER_INSERT); 	}
	private static testMethod void beforeUpdateCreateStrategyConfigurationByRankByCountryTriggerTypeMapTest() 	{ createStrategyConfigurationByRankByCountryTriggerTypeMapTest (SEPTriggerTypeEnum.BEFORE_UPDATE); 	}
	private static testMethod void afterUpdateCreateStrategyConfigurationByRankByCountryTriggerTypeMapTest() 	{ createStrategyConfigurationByRankByCountryTriggerTypeMapTest (SEPTriggerTypeEnum.AFTER_UPDATE); 	}
	private static testMethod void beforeDeleteCreateStrategyConfigurationByRankByCountryTriggerTypeMapTest() 	{ createStrategyConfigurationByRankByCountryTriggerTypeMapTest (SEPTriggerTypeEnum.BEFORE_DELETE); 	}
	private static testMethod void afterDeleteCreateStrategyConfigurationByRankByCountryTriggerTypeMapTest() 	{ createStrategyConfigurationByRankByCountryTriggerTypeMapTest (SEPTriggerTypeEnum.AFTER_DELETE); 	}
	private static testMethod void afterUndeleteCreateStrategyConfigurationByRankByCountryTriggerTypeMapTest() 	{ createStrategyConfigurationByRankByCountryTriggerTypeMapTest (SEPTriggerTypeEnum.AFTER_UNDELETE); }

	//-----------------------------------------------------------------------------------------------------------------------------------

	private static void convertConfigMapToStrategyListMapTest(Integer configurationListSize)   											
	{
		List<Case_Trigger_Strategy_Configuration__c> 		 dummyConfigurationList 		  = TEST_DummyCaseTrigStrategyConfigFactory.createList(configurationListSize, TEST_DummyInsertModeEnum.NONE);
		Map<Integer, Case_Trigger_Strategy_Configuration__c> dummyStrategyConfigurationByRank = new Map<Integer, Case_Trigger_Strategy_Configuration__c>();
		for (Case_Trigger_Strategy_Configuration__c  dummyConfiguration : dummyConfigurationList)
		{
			dummyStrategyConfigurationByRank.put ((Integer) dummyConfiguration.rank__c, dummyConfiguration);				
		}
		
		String dummyCountryTriggerMapKey = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_COUNTRY + TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_TRIGGER_TYPE.name(); 
		Map<String, Map<Integer, Case_Trigger_Strategy_Configuration__c>> dummyStrategyConfigurationByRankByCountryTriggerTypeMap  = new Map<String, Map<Integer, Case_Trigger_Strategy_Configuration__c>>
		{
			dummyCountryTriggerMapKey => dummyStrategyConfigurationByRank
		};
		 
		Map<String, List<SEPTriggerHandlerStrategy>> resultStrategyListMap = null;
	  	System.runAs(TEST_RUN_USER) 
	  	{
			Test.startTest();
			{ 
				resultStrategyListMap = ECICCaseTriggerStrategyFactory.convertConfigMapToStrategyListMap (dummyStrategyConfigurationByRankByCountryTriggerTypeMap);
			}
			Test.stopTest();
	  	}
		
		System.assertEquals (1, resultStrategyListMap.size());
		System.assert (resultStrategyListMap.keySet().contains(dummyCountryTriggerMapKey));
		
		List<SEPTriggerHandlerStrategy> resultStrategyList = resultStrategyListMap.get(dummyCountryTriggerMapKey);
		System.assertEquals (configurationListSize, resultStrategyList.size());
		assertOrder (resultStrategyList);
	}

	private static testMethod void convertOneConfigMapToStrategyListMapTest() 	{ convertConfigMapToStrategyListMapTest (1); 	}
	private static testMethod void convertTwoConfigMapToStrategyListMapTest() 	{ convertConfigMapToStrategyListMapTest (2); 	}
	private static testMethod void convertTenConfigMapToStrategyListMapTest() 	{ convertConfigMapToStrategyListMapTest (10); 	}

	//-----------------------------------------------------------------------------------------------------------------------------------

	private static String getClassName (SEPTriggerHandlerStrategy strategyClass)
	{
		return String.valueOf(strategyClass).split(':')[0];
	}

	//-----------------------------------------------------------------------------------------------------------------------------------
	
	private static void assertOrder (List<SEPTriggerHandlerStrategy> resultStrategyList)
	{
		Integer i=0;
		for (SEPTriggerHandlerStrategy resultStrategy : resultStrategyList)
		{
			System.assertEquals (TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_STRATEGY_CHAIN[i], getClassName(resultStrategy));
			i++;
		}
	}
}