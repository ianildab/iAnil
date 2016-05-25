@isTest
private class ECICCaseTasksOnCloseValidationStratTest 
{
    private static final User                                    TEST_RUN_USER   = ECICRunUserTestHelper.create(); 
    private static final ECICCaseTasksOnCloseValidationStrategy TARGET_STRATEGY = new ECICCaseTasksOnCloseValidationStrategy();

    private static void onBeforeUpdateTest (Boolean hasNewClosedCase, Boolean hasOpenTasks)
    {
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.status = (hasNewClosedCase) ? ECICCommonConstants.STATUS_CLOSED : ECICCommonConstants.STATUS_OPEN;
        Case dummyNewCase = TEST_DummyInquiryCaseFactory.create (caseConfig, TEST_DummyInsertModeEnum.MOCK);
        
        Case dummyOldCase = dummyNewCase.clone(false);
             dummyOldCase.id       = dummyNewCase.id;
             dummyOldCase.status   = ECICCommonConstants.STATUS_OPEN; // We shouldn't need to test making this STATUS_CLOSED because filterNewCasesByStatusChangedTo() has already been tested.
             
        if (hasOpenTasks)
        {
           TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
                                        taskConfig.caseId = dummyNewCase.id;
           Task dummyTask = TEST_DummyTaskFactory.create (taskConfig, TEST_DummyInsertModeEnum.MOCK);
           ECICCaseTriggerTaskCache.caseTaskByTaskIdCache.put (dummyTask.id, dummyTask);
        }
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
               result = TARGET_STRATEGY.onBeforeUpdate (new Map <Id, Case>{ dummyOldCase.id => dummyOldCase }, new Map <Id, Case>{ dummyNewCase.id => dummyNewCase });
            }
            Test.stopTest();
        }
        
        System.assertEquals ((hasNewClosedCase && hasOpenTasks), !result);  
        if (hasNewClosedCase && hasOpenTasks)
        {
            String errorMessage = TEST_MockHelper.getMockString(dummyNewCase, 'error');
            System.assert (errorMessage != null);
            System.assert (errorMessage.contains(System.Label.Complete_all_tasks));
        }
    }
    
    private static testMethod void openWithoutTasksOnBeforeTest()      { onBeforeUpdateTest(false, false); }
    private static testMethod void openWithTasksOnBeforeTest()         { onBeforeUpdateTest(false, true ); }
    private static testMethod void closedWithoutTasksOnBeforeTest()    { onBeforeUpdateTest(true,  false); }
    private static testMethod void closedWithTasksOnBeforeTest()       { onBeforeUpdateTest(true,  true ); }
}