@isTest
private class ECICCaseOwnerLookupSetterStrategyTest 
{
    private static final User                              TEST_RUN_USER   = ECICRunUserTestHelper.create(); 
    private static final ECICCaseOwnerLookupSetterStrategy TARGET_STRATEGY = new ECICCaseOwnerLookupSetterStrategy();
    
	private static void executeTest(Boolean isOwnerUser) 
	{
		 TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
		 					  config.ownerId = (isOwnerUser) ? TEST_RUN_USER.id :  (Id) (ECICCaseHelper.GROUP_OBJECT_ID_PREFIX + '11000001FTZs');
		 Case dummyCase = TEST_DummyInquiryCaseFactory.create (config, TEST_DummyInsertModeEnum.NONE); 

		 System.runAs(TEST_RUN_USER)
		 {
			Test.startTest();
			{
				 TARGET_STRATEGY.execute(new List<Case>{ dummyCase }); 
			}
			Test.stopTest();		 	
		 } 
		 
		 System.assertEquals(((isOwnerUser) ? TEST_RUN_USER.id : null), dummyCase.Owner_Lookup__c);
	}

	private static testMethod void ownerIsUserExecuteTest()  { executeTest (false); }
	private static testMethod void ownerIsGroupExecuteTest() { executeTest (true);  }
	
	//-----------------------------------------------------------------------------------------------------------------------
	
	private static testMethod void onBeforeInsertTest() 
	{
		 TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
		 					  config.ownerId = TEST_RUN_USER.id;
		 Case dummyCase = TEST_DummyInquiryCaseFactory.create (config, TEST_DummyInsertModeEnum.NONE); 

		 Boolean result = null;
		 System.runAs(TEST_RUN_USER)
		 {
			Test.startTest();
			{
				 result =  TARGET_STRATEGY.onBeforeInsert(new List<Case>{ dummyCase }); 
			}
			Test.stopTest();		 	
		 } 
		 
		 System.assert(result);
		 System.assertEquals(TEST_RUN_USER.id, dummyCase.Owner_Lookup__c);
	}

	private static testMethod void onBeforeUpdateTest() 
	{
		 TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
		 					  config.ownerId = (Id) (ECICCaseHelper.GROUP_OBJECT_ID_PREFIX + '11000001FTZs');
		 Case dummyCase = TEST_DummyInquiryCaseFactory.create (config, TEST_DummyInsertModeEnum.MOCK); 

		 Boolean result = null;
		 System.runAs(TEST_RUN_USER)
		 {
			Test.startTest();
			{
				 result = TARGET_STRATEGY.onBeforeUpdate (null, new Map<Id, Case>{ dummyCase.id => dummyCase });  // Old Cases, when present, are ignored. 
			}
			Test.stopTest();		 	
		 } 
		 
		 System.assert(result);
		 System.assertEquals(null, dummyCase.Owner_Lookup__c);
	}

}