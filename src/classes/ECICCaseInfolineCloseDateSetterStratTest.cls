@isTest
private class ECICCaseInfolineCloseDateSetterStratTest 
{
	private static final User TEST_RUN_USER = ECICRunUserTestHelper.create();
	
	private static final ECICCaseInfolineCloseDateSetterStrategy DUMMY_STRATEGY = new ECICCaseInfolineCloseDateSetterStrategy(); 
	
	private static void onBeforeInsertTest(Boolean isInfolineStatusClosed) 
	{ 
		TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
							 config.infolineStatus = (isInfolineStatusClosed) ? ECICCommonConstants.STATUS_CLOSED : ECICCommonConstants.STATUS_OPEN;
		Case dummyCase = TEST_DummyInquiryCaseFactory.create (config, TEST_DummyInsertModeEnum.NONE);
			
		Boolean result = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				result = DUMMY_STRATEGY.onBeforeInsert (new List<Case> { dummyCase });
			}
			Test.stopTest();
		} 
		
		System.assert(result); 
		System.assertEquals((isInfolineStatusClosed ? system.today() : null), (dummyCase.Infoline_Close_Date__c));
	}
	
	private static testMethod void isOpenOnBeforeInsertTest()   { onBeforeInsertTest (false); }
	private static testMethod void isClosedOnBeforeInsertTest() { onBeforeInsertTest (true);  }

	//----------------------------------------------------------------------------------------------------------------
	
	private static void onBeforeUpdateTest(Boolean isInfolineStatusClosed, Boolean isInfolineStatusChanged) 
	{ 
		TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
							 config.infolineStatus = (isInfolineStatusClosed) ? ECICCommonConstants.STATUS_CLOSED : ECICCommonConstants.STATUS_OPEN;
		Case dummyNewCase = TEST_DummyInquiryCaseFactory.create (config, TEST_DummyInsertModeEnum.NONE);

		Case dummyOldCase = dummyNewCase.clone(false);
			 dummyOldCase.Infoline_Status__c = (isInfolineStatusChanged) 
			 										? ( 
			 												(config.infolineStatus == ECICCommonConstants.STATUS_CLOSED) 
			 													? ECICCommonConstants.STATUS_OPEN 
			 													: ECICCommonConstants.STATUS_CLOSED
			 										  ) 
			 										: config.infolineStatus;
		
		Boolean result = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				result = DUMMY_STRATEGY.onBeforeUpdate (new Map<Id, Case> { dummyOldCase.id => dummyOldCase }, new Map<Id, Case> { dummyNewCase.id => dummyNewCase });
			}
			Test.stopTest();
		} 

		System.assert(result); 
		System.assertEquals(((isInfolineStatusClosed && isInfolineStatusChanged) ? system.today() : null), (dummyNewCase.Infoline_Close_Date__c));
	}

	private static testMethod void isOpenUnchangedOnBeforeUpdateTest()   { onBeforeUpdateTest (false, false); }
	private static testMethod void isOpenChangedOnBeforeUpdateTest()     { onBeforeUpdateTest (false, true);  }
	private static testMethod void isClosedUnchangedOnBeforeUpdateTest() { onBeforeUpdateTest (true,  false); }
	private static testMethod void isClosedChangedOnBeforeUpdateTest()   { onBeforeUpdateTest (true,  true);  }
}