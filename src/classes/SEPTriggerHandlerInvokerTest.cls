@isTest
private class SEPTriggerHandlerInvokerTest 
{
  	private static final User TEST_RUN_USER = ECICRunUserTestHelper.create();
  	
  	private static void skipTriggerInvocationTest(Boolean hasGeneralSettingTest)
  	{
		SEPTriggerHandlerInvoker.pretendTestNotRunning = true;

  		General_Settings__c generalSettings = new General_Settings__c();
  						   generalSettings.skipTriggers__c = (hasGeneralSettingTest) ? true : null;
  						   
       	if (hasGeneralSettingTest) { insert generalSettings; }
       	else 					   { SEPTriggerHandlerInvoker.pretendSkipTriggersNull = true; }
	
		Boolean result = null;
  		System.runAs(TEST_RUN_USER)
  		{
  			Test.startTest();
  			{
  			result = SEPTriggerHandlerInvoker.skipTriggerInvocation();
  		}
  			Test.stopTest();
  		}
  		
  		System.assertEquals(hasGeneralSettingTest, result); 
  	}

	private static testMethod void hasGeneralSettingSkipTriggerInvocationTest() { skipTriggerInvocationTest(true);  }
	private static testMethod void noGeneralSettingSkipTriggerInvocationTest()  { skipTriggerInvocationTest(false); }

	//---------------------------------------------------------------------------------------
	
  	private static void skipObjectTriggerInvocationTest (Boolean skipTestValue)
  	{
		SEPTriggerHandlerInvoker.pretendSObjectNotNull = true;
		
  		System.runAs(TEST_RUN_USER)
  		{
  			Test.startTest();
  			{
	  			SEPTriggerHandlerInvoker.skipObjectTriggerInvocation(SEPTriggerHandlerInvoker.DUMMY_SOBJECT_NAME, skipTestValue);
  			}
  			Test.stopTest();
  		}
  		
  		System.assertEquals(skipTestValue, SEPTriggerHandlerInvoker.SKIP_OBJECT_TRIGGER_MAP.get(SEPTriggerHandlerInvoker.DUMMY_SOBJECT_NAME)); 
  	}

	private static testMethod void  trueSkipObjectTriggerInvocationTest()  { skipObjectTriggerInvocationTest(true);  }
	private static testMethod void  falseSkipObjectTriggerInvocationTest() { skipObjectTriggerInvocationTest(false); }

	//---------------------------------------------------------------------------------------
	
  	private static void skipObjectTriggerTest ( Boolean skipTestValue,   			Boolean pretendSObjectNotNull, 
  												Boolean pretendTriggerNewNotNull,   Boolean pretendTriggerOldNotNull )
  	{
		SEPTriggerHandlerInvoker.pretendSObjectNotNull    = pretendSObjectNotNull;
		SEPTriggerHandlerInvoker.pretendTriggerNewNotNull = pretendTriggerNewNotNull; 
		SEPTriggerHandlerInvoker.pretendTriggerOldNotNull = pretendTriggerOldNotNull;
		
		SEPTriggerHandlerInvoker.SKIP_OBJECT_TRIGGER_MAP.put(SEPTriggerHandlerInvoker.DUMMY_SOBJECT_NAME, skipTestValue);

		Boolean result = null;
  		System.runAs(TEST_RUN_USER)
  		{
  			Test.startTest();
  			{
	  			result = SEPTriggerHandlerInvoker.skipObjectTrigger();
  			}
  			Test.stopTest(); 
  		}
  		
  		Boolean expectedResult = skipTestValue && (pretendTriggerNewNotNull || pretendTriggerOldNotNull);
  		System.assertEquals(expectedResult, result); 
  	}

	private static testMethod void dontSkipObjectTriggerTest() 										{ skipObjectTriggerTest (false,	false, 	false, 	false); }
	private static testMethod void dontSkipPretendOldTriggerObjectTriggerTest() 					{ skipObjectTriggerTest (false,	false, 	false, 	true);  }
	private static testMethod void dontSkipPretendNewTriggerObjectTriggerTest() 					{ skipObjectTriggerTest (false,	false, 	true, 	false); }
	private static testMethod void dontSkipPretendBothTriggersObjectTriggerTest() 					{ skipObjectTriggerTest (false,	false, 	true, 	true);  }
	private static testMethod void dontSkipPretendHasSObjectObjectTriggerTest() 					{ skipObjectTriggerTest (false,	true, 	false, 	false); }
	private static testMethod void dontSkipPretendHasSObjectPretendOldTriggerObjectTriggerTest() 	{ skipObjectTriggerTest (false,	true, 	false, 	true);  }
	private static testMethod void dontSkipPretendHasSObjectPretendNewTriggerObjectTriggerTest() 	{ skipObjectTriggerTest (false,	true, 	true, 	false); }
	private static testMethod void dontSkipPretendHasSObjectPretendBothTriggersObjectTriggerTest() 	{ skipObjectTriggerTest (false,	true, 	true, 	true);  }

	private static testMethod void skipObjectTriggerTest() 											{ skipObjectTriggerTest (true, 	false, 	false, 	false); }
	private static testMethod void skipPretendHasSObjectObjectTriggerTest() 						{ skipObjectTriggerTest (true, 	true, 	false, 	false); }
	private static testMethod void skipPretendOldTriggerObjectTriggerTest() 						{ skipObjectTriggerTest (true, 	false, 	false, 	true);  }
	private static testMethod void skipPretendNewTriggerObjectTriggerTest() 						{ skipObjectTriggerTest (true, 	false, 	true, 	false); }
	private static testMethod void skipPretendBothTriggersObjectTriggerTest() 						{ skipObjectTriggerTest (true, 	false, 	true, 	true);  }
	private static testMethod void skipPretendHasSObjectPretendOldTriggerObjectTriggerTest() 		{ skipObjectTriggerTest (true, 	true, 	false, 	true);  }
	private static testMethod void skipPretendHasSObjectPretendNewTriggerObjectTriggerTest() 		{ skipObjectTriggerTest (true, 	true, 	true, 	false); }
	private static testMethod void skipPretendHasSObjectPretendBothTriggerObjectTriggerTest()	 	{ skipObjectTriggerTest (true, 	true, 	true, 	true);  }

	//----------------------------------------------------------------------------------------------------------------------------------------
	
	private static void invokeTest(String testType, Boolean pretendBefore)
	{
		SEPTriggerHandlerInvoker.realTrigger	 = false;
		SEPTriggerHandlerInvoker.pretendBefore   = pretendBefore;
		SEPTriggerHandlerInvoker.pretendAfter    = !pretendBefore;
		SEPTriggerHandlerInvoker.pretendInsert   = (testType == 'Insert');
		SEPTriggerHandlerInvoker.pretendUpdate   = (testType == 'Update');
		SEPTriggerHandlerInvoker.pretendDelete   = (testType == 'Delete');
		SEPTriggerHandlerInvoker.pretendUndelete = (testType == 'Undelete');
		
		SEPTriggerHandlerAbstractTest.DummyTriggerHandler handler = new SEPTriggerHandlerAbstractTest.DummyTriggerHandler(false);

  		System.runAs(TEST_RUN_USER)
  		{
  			Test.startTest();
  			{
	  			SEPTriggerHandlerInvoker.invoke (handler);
  			}
  			Test.stopTest(); 
  		}
		
	}
	
	private static testMethod void beforeInsertInvokeTest()  { invokeTest('Insert',   true);  }
	private static testMethod void beforeUpdateInvokeTest()  { invokeTest('Update',   true);  }
	private static testMethod void beforeDeleteInvokeTest()  { invokeTest('Delete',   true);  }
	private static testMethod void afterDeleteInvokeTest()   { invokeTest('Delete',   false); }
	private static testMethod void afterUndeleteInvokeTest() { invokeTest('Undelete', false); }
	private static testMethod void afterInsertInvokeTest()   { invokeTest('Insert',   false); }
	private static testMethod void afterUpdateInvokeTest()   { invokeTest('Update',   false); }

}