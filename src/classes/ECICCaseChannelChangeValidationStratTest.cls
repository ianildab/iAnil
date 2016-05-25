@isTest
public class ECICCaseChannelChangeValidationStratTest 
{
	public static  final User TEST_RUN_USER = ECICRunUserTestHelper.create();  
	
	private static ECICCaseChannelChangeValidationStrategy dummyStrategy = new ECICCaseChannelChangeValidationStrategy();
	private static Set<String> disallowedStatusSet = new Set<String>{ECICCommonConstants.STATUS_NEW, ECICCommonConstants.STATUS_CANCELLED};

	private static void executeTest(Boolean isOwnerGroup, String status) 
	{ 
		Case dummyCase = createDummyCase(isOwnerGroup, status);
		
		Boolean result = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				result = dummyStrategy.execute(new List<Case>{ dummyCase });
			}
			Test.stopTest();
		} 
		
		assertResult (isOwnerGroup, status, dummyCase, result);
	}

	private static testMethod void isGroupNewStatusExecuteTest() 		{ executeTest (true,  ECICCommonConstants.STATUS_NEW); 		 } 
	private static testMethod void isGroupOpenStatusExecuteTest() 		{ executeTest (true,  ECICCommonConstants.STATUS_OPEN); 	 }
	private static testMethod void isGroupCancelledStatusExecuteTest() 	{ executeTest (true,  ECICCommonConstants.STATUS_CANCELLED); }
	private static testMethod void notGroupNewStatusExecuteTest() 		{ executeTest (false, ECICCommonConstants.STATUS_NEW); 		 }
	private static testMethod void notGroupOpenStatusExecuteTest() 		{ executeTest (false, ECICCommonConstants.STATUS_OPEN); 	 }
	private static testMethod void notGroupCancelledStatusExecuteTest()	{ executeTest (false, ECICCommonConstants.STATUS_CANCELLED); }

	// -------------------------------------------------------------------------------------------------------------
	
	private static void onBeforeInsertTest(Boolean isOwnerGroup, String status) 
	{ 
		Case dummyCase = createDummyCase(isOwnerGroup, status);
		
		Boolean result = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				result = dummyStrategy.onBeforeInsert(new List<Case>{ dummyCase });
			}
			Test.stopTest();
		} 
		
		assertResult (isOwnerGroup, status, dummyCase, result);
	}

	private static testMethod void isGroupNewStatusOnBeforeInsertTest() 		{ onBeforeInsertTest (true,  ECICCommonConstants.STATUS_NEW); 		} 
	private static testMethod void isGroupOpenStatusOnBeforeInsertTest() 		{ onBeforeInsertTest (true,  ECICCommonConstants.STATUS_OPEN); 	 	}
	private static testMethod void isGroupCancelledStatusOnBeforeInsertTest() 	{ onBeforeInsertTest (true,  ECICCommonConstants.STATUS_CANCELLED); }
	private static testMethod void notGroupNewStatusOnBeforeInsertTest() 		{ onBeforeInsertTest (false, ECICCommonConstants.STATUS_NEW); 		}
	private static testMethod void notGroupOpenStatusOnBeforeInsertTest() 		{ onBeforeInsertTest (false, ECICCommonConstants.STATUS_OPEN); 	 	}
	private static testMethod void notGroupCancelledStatusOnBeforeInsertTest()	{ onBeforeInsertTest (false, ECICCommonConstants.STATUS_CANCELLED); }

	// -------------------------------------------------------------------------------------------------------------

	private static void onBeforeUpdateTest(Boolean isOwnerGroup, String status) 
	{ 
		Case dummyCase = createDummyCase(isOwnerGroup, status);
		TEST_MockHelper.mockInsert(dummyCase);
		Map<Id, Case> dummyOldCaseByIdMap = null; // Any values ignored.
		Map<Id, Case> dummyNewCaseByIdMap = new Map<Id, Case>(new List<Case>{ dummyCase });
		
		Boolean result = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				result = dummyStrategy.onBeforeUpdate(dummyOldCaseByIdMap, dummyNewCaseByIdMap);
			}
			Test.stopTest();
		} 
		
		assertResult (isOwnerGroup, status, dummyCase, result);
	}

	private static testMethod void isGroupNewStatusOnBeforeUpdateTest() 		{ onBeforeUpdateTest (true,  ECICCommonConstants.STATUS_NEW); 		} 
	private static testMethod void isGroupOpenStatusOnBeforeUpdateTest() 		{ onBeforeUpdateTest (true,  ECICCommonConstants.STATUS_OPEN); 	 	}
	private static testMethod void isGroupCancelledStatusOnBeforeUpdateTest() 	{ onBeforeUpdateTest (true,  ECICCommonConstants.STATUS_CANCELLED); }
	private static testMethod void notGroupNewStatusOnBeforeUpdateTest() 		{ onBeforeUpdateTest (false, ECICCommonConstants.STATUS_NEW); 		}
	private static testMethod void notGroupOpenStatusOnBeforeUpdateTest() 		{ onBeforeUpdateTest (false, ECICCommonConstants.STATUS_OPEN); 	 	}
	private static testMethod void notGroupCancelledStatusOnBeforeUpdateTest()	{ onBeforeUpdateTest (false, ECICCommonConstants.STATUS_CANCELLED); }

	// -------------------------------------------------------------------------------------------------------------

	private static Case createDummyCase (Boolean isOwnerGroup, String status)
	{
		TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
							 config.ownerId = (isOwnerGroup) 
							 					? (Id) (ECICCaseHelper.GROUP_OBJECT_ID_PREFIX + '11000001FTZs') 
							 					: TEST_RUN_USER.id;
							 config.status  = status;
		return TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE);
	}

	private static void assertResult (Boolean isOwnerGroup, String status, Case dummyCase, Boolean actualResult)
	{
		Boolean expectedResult = !(
										    (isOwnerGroup)
										&& !(disallowedStatusSet.contains(status))
								  );
		System.assertEquals(expectedResult, actualResult);
		
		if (!expectedResult && disallowedStatusSet.contains(status))
		{
			Boolean errorCaught = false;
			try { insert dummyCase; }
			catch (Exception e)
			{
				errorCaught = true;
				System.assert(e.getMessage().contains(Label.ownerIsQueueError));				
			}
			System.assert (errorCaught);
		}
	}

}