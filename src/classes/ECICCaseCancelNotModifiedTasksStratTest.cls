@isTest
private class ECICCaseCancelNotModifiedTasksStratTest 
{
	public static  final User TEST_RUN_USER = ECICRunUserTestHelper.create();  

    private static ECICCaseCancelNotModifiedTasksStrategy dummyStrategy = new ECICCaseCancelNotModifiedTasksStrategy();

	private static void onBeforeUpdateTest(Boolean hasFieldChanged, Boolean hasBeenCanceled)
	{
		String dummyOldStatus = (hasBeenCanceled && !hasFieldChanged) ? ECICCommonConstants.STATUS_CANCELLED : ECICCommonConstants.STATUS_NEW;
									
		TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
							 config.status	= dummyOldStatus;
		Case dummyOldCase = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.MOCK);
		
		Case dummyNewCase = dummyOldCase.clone(false);
			 dummyNewCase.id	 = dummyOldCase.id;

		if (hasFieldChanged)
		{
			String dummyNewStatus = (hasBeenCanceled) ? ECICCommonConstants.STATUS_CANCELLED : ECICCommonConstants.STATUS_OPEN;
		     dummyNewCase.status = dummyNewStatus;
		}
		     
		Map<ID, sObject> dummyOldValuesMap = new Map<ID, sObject>{dummyOldCase.id => dummyOldCase}; 
		Map<ID, sObject> dummyNewValuesMap = new Map<ID, sObject>{dummyNewCase.id => dummyNewCase};
		

		TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
									 taskConfig.caseId = dummyOldCase.id; 
		Task dummyTask = TEST_DummyTaskFactory.create(taskConfig, TEST_DummyInsertModeEnum.MOCK);

		ECICCaseTriggerTaskCache.caseUnmodifiedTaskByTaskIdCache.put(dummyTask.id, dummyTask);
		
		Boolean result = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				result = dummyStrategy.onBeforeUpdate(dummyOldValuesMap, dummyNewValuesMap);
			}
			Test.stopTest();
		}		
		
		System.assert(result);		
		
		Boolean isTaskExpectedInDeleteSet = hasFieldChanged && hasBeenCanceled;
		Set<Task> resultDeleteTaskSet = ECICCaseTriggerTaskCache.tasksToDeleteCache;
		System.assertEquals(isTaskExpectedInDeleteSet, resultDeleteTaskSet.contains(dummyTask));
	}
	
	private static testMethod void fieldsChangedCanceledOnBeforeUpdateTest()    	{ onBeforeUpdateTest(true, true);   }
	private static testMethod void nofieldsChangedCanceledOnBeforeUpdateTest()    	{ onBeforeUpdateTest(false, true);  }
	private static testMethod void fieldsChangedNotCanceledOnBeforeUpdateTest()    	{ onBeforeUpdateTest(true, false);  }
	private static testMethod void nofieldsChangedNotCanceledOnBeforeUpdateTest()   { onBeforeUpdateTest(false, false); }
	
}