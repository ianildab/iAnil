@isTest 
private class ECICCasePreviousOwnerSetterStrategyTest 
{
    private static final User                              TEST_RUN_USER   = ECICRunUserTestHelper.create(); 
    private static final ECICCasePreviousOwnerSetterStrategy TARGET_STRATEGY = new ECICCasePreviousOwnerSetterStrategy();

	private static void onBeforeUpdateTest(Boolean hasNewOwner, Boolean hasUserAsOldOwner) 
	{
		 TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
		 					  config.ownerId = (hasUserAsOldOwner) ? TEST_RUN_USER.id : (Id) (ECICCaseHelper.GROUP_OBJECT_ID_PREFIX + '11000001FTZs');
		 Case dummyOldCase = TEST_DummyInquiryCaseFactory.create (config, TEST_DummyInsertModeEnum.MOCK);
		 
		 Case dummyNewCase = dummyOldCase.clone(false);
		      dummyNewCase.id = dummyOldCase.id;
		 if (hasNewOwner) { dummyNewCase.OwnerId = '00520000001qmX1'; }

		 Boolean result = null;
		 System.runAs(TEST_RUN_USER)
		 {
			Test.startTest();
			{
				 result = TARGET_STRATEGY.onBeforeUpdate (new Map<Id, Case>{ dummyOldCase.id => dummyOldCase }, new Map<Id, Case>{ dummyNewCase.id => dummyNewCase }); 
			}
			Test.stopTest();		 	
		 } 
		 
		 System.assert(result);
		 System.assertEquals(((hasNewOwner && hasUserAsOldOwner) ? TEST_RUN_USER.id : null), dummyNewCase.previous_owner__c);
	}

	private static testMethod void oldOwnerIsSameIsGroupOnBeforeUpdateTest() { onBeforeUpdateTest(false, false); }
	private static testMethod void oldOwnerIsSameIsUserOnBeforeUpdateTest()  { onBeforeUpdateTest(false, true ); }
	private static testMethod void oldOwnerIsDiffIsGroupOnBeforeUpdateTest() { onBeforeUpdateTest(true,  false); }
	private static testMethod void oldOwnerIsDiffIsUserOnBeforeUpdateTest()  { onBeforeUpdateTest(true,  true ); }
}