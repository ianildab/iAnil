@isTest
private class ECICCaseCountryCodeSetterStrategyTest 
{
	private static final User TEST_RUN_USER = ECICRunUserTestHelper.create();
	
	private static final ECICCaseCountryCodeSetterStrategy DUMMY_STRATEGY = new ECICCaseCountryCodeSetterStrategy(); 
	
	private static void getUserCountryCodeTest(Boolean hasUser, Boolean userHasCountryCode) 
	{ 
		String dummyCountryCode = (userHasCountryCode) ? 'D2'          : null; 
		User   dummyUser        = (hasUser)            ? TEST_RUN_USER : null;
		if (dummyUser != null) {  dummyUser.country_code__c = dummyCountryCode; } 
		
		String resultUserCountryCode = null; 
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				resultUserCountryCode = DUMMY_STRATEGY.getUserCountryCode(dummyUser); 
			}
			Test.stopTest();
		}
		
		String expectedResult = (hasUser && userHasCountryCode) ? dummyCountryCode : null;		
		System.assertEquals (expectedResult, resultUserCountryCode);
	}

	private static testMethod void withoutUserGetUserCountryCodeTest()         { getUserCountryCodeTest (false, false); }
	private static testMethod void withoutCountryCodeGetUserCountryCodeTest()  { getUserCountryCodeTest (true,  false); }
	private static testMethod void userWithCountryCodeGetUserCountryCodeTest() { getUserCountryCodeTest (true,  true);  }

	// ---------------------------------------------------------------------------------------------------------------------------------
	
	private static void executeTest(Boolean hasCountryCode, Boolean hasUserAsOwner, Boolean hasOldCase, Boolean hasNewOwner) 
	{
		String 		  dummyUserCountryCode 	= (hasUserAsOwner) ? 'U2'							  : null; 
		User   		  dummyUser 			= (hasUserAsOwner) ? createUser(dummyUserCountryCode) : null;
			   
		String 		  dummyCaseCountryCode	= (hasCountryCode) ? 'C2' : TEST_ConfigHelper.INTENTIONAL_NULL; 
		Case		  dummyNewCase 		  	= createNewCase (dummyUser, dummyCaseCountryCode);
		List<Case> 	  dummyNewCaseList    	= new List<Case>{ dummyNewCase };
		
		Case 		  dummyOldCase		    = null;
		Map<Id, Case> dummyOldCaseByIdMap   = null; 
		if (hasOldCase)
		{
			dummyOldCase		= createOldCase(dummyNewCase, hasNewOwner);
			dummyNewCase.id 	= dummyOldCase.id; 
			dummyOldCaseByIdMap = new Map<Id, Case>{ dummyOldCase.id => dummyOldCase };
		}
		
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				DUMMY_STRATEGY.execute (dummyOldCaseByIdMap, dummyNewCaseList);
			}
			Test.stopTest();
		}
		
		// Note: This test deliberately does not test the test-conditions required to return "DM".
		// 		 If that is no longer covered by other tests, it can most likely be deleted.
		
		String expectedCountryCode =  ( (!hasCountryCode) && hasUserAsOwner )
										? dummyUserCountryCode
										: dummyCaseCountryCode;
										
		System.assertEquals (expectedCountryCode, dummyNewCase.country_code__c);
	}
//executeTest(Boolean hasCountryCode, Boolean hasUserAsOwner, Boolean hasOldCase, Boolean hasNewOwner)
	//private static testMethod void hasNothingExecuteTest() 								{ executeTest( false,	false,	false,	false );	}
	//private static testMethod void hasOldCaseExecuteTest() 								{ executeTest( false,	false,	true,	false );	}
	//private static testMethod void hasNewOwnerExecuteTest() 							{ executeTest( false,	false,	true,	true  );	}

	private static testMethod void hasUserAsOwnerExecuteTest() 							{ executeTest( false,	true,	false,	false );	}
	private static testMethod void hasUserAsOwnerHasOldCaseExecuteTest() 				{ executeTest( false,	true,	true,	false );	}
	private static testMethod void hasUserAsOwnerHasNewOwnerExecuteTest() 				{ executeTest( false,	true,	true,	true  );	}
	
	private static testMethod void hasCountryCodeExecuteTest() 							{ executeTest( true,	false,	false,	false );	}
	private static testMethod void hasCountryCodeHasOldCaseExecuteTest() 				{ executeTest( true,	false,	true,	false );	}
	private static testMethod void hasCountryCodeHasNewOwnerExecuteTest() 				{ executeTest( true,	false,	true,	true  );	}

	private static testMethod void hasCountryCodeHasUserAsOwnerExecuteTest() 			{ executeTest( true,	true,	false,	false );	}
	private static testMethod void hasCountryCodeHasUserAsOwnerHasOldCaseExecuteTest()  { executeTest( true,	true,	true,	false );	}
	private static testMethod void hasCountryCodeHasUserAsOwnerHasNewOwnerExecuteTest() { executeTest( true,	true,	true,	true  );	}

	// ---------------------------------------------------------------------------------------------------------------------------------
	
	private static testMethod void onBeforeInsertTest() 
	{ 
		String 		  dummyUserCountryCode 	= 'U2'; 
		User   		  dummyUser 			= createUser(dummyUserCountryCode);
		Case		  dummyNewCase 		  	= createNewCase (dummyUser, TEST_ConfigHelper.INTENTIONAL_NULL);
		
		Boolean result = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				result = DUMMY_STRATEGY.onBeforeInsert (new List<Case>{ dummyNewCase });
			}
			Test.stopTest();
		}
		
		System.assert(result);
		System.assertEquals (dummyUserCountryCode, dummyNewCase.country_code__c);
	}
	
	private static testMethod void onBeforeInsertFailTest()
	{
		Boolean result = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				result = DUMMY_STRATEGY.onBeforeInsert (null);
			}
			Test.stopTest();
		}
		
		System.assert(!result);
	} 
	
	// ---------------------------------------------------------------------------------------------------------------------------------
	
	private static testMethod void onBeforeUpdateTest() 
	{ 
		String 		  dummyUserCountryCode 	= 'U2'; 
		User   		  dummyUser 			= createUser(dummyUserCountryCode);
			   
		Case		  dummyNewCase 		  	= createNewCase (dummyUser, TEST_ConfigHelper.INTENTIONAL_NULL);
		Case 		  dummyOldCase		    = createOldCase(dummyNewCase, true);
					  dummyNewCase.id 		= dummyOldCase.id; 
		
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				DUMMY_STRATEGY.onBeforeUpdate (new Map<Id, Case>{ dummyOldCase.id => dummyOldCase }, new Map<Id, Case>{ dummyNewCase.id => dummyNewCase });
			}
			Test.stopTest();
		}
		
		System.assertEquals (dummyUserCountryCode, dummyNewCase.country_code__c);
	}

	private static testMethod void onBeforeUpdateFailTest()
	{
		Boolean result = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				result = DUMMY_STRATEGY.onBeforeUpdate (null, null);
			}
			Test.stopTest();
		}
		
		System.assert(!result);
	} 

	// ---------------------------------------------------------------------------------------------------------------------------------

	private static User createUser(String countryCode)
	{
		User dummyUser = TEST_RUN_USER;
			 dummyUser.Country_Code__c = countryCode;
		ECICCaseTriggerUserCache.userByIdCache.put (dummyUser.id, dummyUser);
		return dummyUser;				   
	}	
	
	private static Case createNewCase (User dummyUser, String countryCode)
	{
		TEST_DummyCaseConfig caseConfig   = new TEST_DummyCaseConfig();
							 caseConfig.countryCode = countryCode;
							 caseConfig.ownerId     = (dummyUser != null) ? (dummyUser.Id) : (ECICCaseHelper.GROUP_OBJECT_ID_PREFIX + '11000001FTZs'); 
		return TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.NONE);
	}

	private static Case createOldCase (Case dummyNewCase, Boolean hasNewOwner)
	{
		Case dummyOldCase = dummyNewCase.clone(false);
		if (hasNewOwner) { dummyOldCase.OwnerId = ECICRunUserTestHelper.SETUP_DATA_CREATION_USER.id; }
		TEST_MockHelper.mockInsert(dummyOldCase);
		return dummyOldCase;
	}
	
	
}