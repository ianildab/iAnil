@isTest
private class ECICCaseTaskProcessorAbstractTest 
{
    private static User     TEST_RUN_USER       = TEST_DummyUserFactory.createDefaultTestRunUser();
    private static String   PROCESSED_SUBJECT   = 'Processed';
    
    private class TestProcessor extends ECICCaseTaskProcessorAbstract
    {
        public override void process(Task task) { task.subject = PROCESSED_SUBJECT; }
    }
    
    private static testMethod void processTest()               
    {
        Task          dummyTask     = TEST_DummyTaskFactory.create(TEST_DummyInsertModeEnum.NONE);
        TestProcessor testProcessor = new TestProcessor();
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
               testProcessor.process(dummyTask);
            }
            Test.stopTest();
        }
        
        System.assertEquals (PROCESSED_SUBJECT, dummyTask.subject);
    }

    // ------------------------------------------------------------------------------------------------------------
    
    private static void process2Test(Boolean hasOldTask, Boolean hasNewOwner, Boolean isNewlyReopened)               
    { 
    	TEST_DummyTaskFactory.Config newTaskConfig = new TEST_DummyTaskFactory.Config();
    	                             newTaskConfig.ownerId = TEST_RUN_USER.id;
    	                             newTaskConfig.status  = ECICCommonConstants.STATUS_OPEN;
        Task          dummyNewTask     = TEST_DummyTaskFactory.create(newTaskConfig, TEST_DummyInsertModeEnum.NONE);
        
        Task          dummyOldTask     = null;
        if (hasOldTask)
        {
            dummyOldTask = dummyNewTask.clone(false);
            dummyOldTask.OwnerId = (hasNewOwner)        ? '00520000001qmXm'                 : newTaskConfig.ownerId;
            dummyOldTask.Status  = (isNewlyReopened)    ? ECICCommonConstants.STATUS_CLOSED : newTaskConfig.status;
            
            TEST_MockHelper.mockInsert(dummyOldTask);
            dummyNewTask.id = dummyOldTask.id;

            // Workaround because "isClosed" requires inserting and querying data.
            // NOTE: This is oversimplified because it doesn't actually consider whether isClosed should change, just status change.
            TEST_MockHelper.setMockBoolean(dummyNewTask.id, 'isClosedChanged', dummyNewTask.status != dummyOldTask.status); 
        }

        TestProcessor testProcessor = new TestProcessor();
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
               testProcessor.process(dummyNewTask, dummyOldTask);
            }
            Test.stopTest();
        }

        Boolean expectedProcess = !hasOldTask || hasNewOwner || isNewlyReopened;
        System.assertEquals (expectedProcess, (PROCESSED_SUBJECT == dummyNewTask.subject));
    }

    private static testMethod void isNewlyReopenedProcess2Test()  { process2Test(true , false, true ); }               
    private static testMethod void hasNothingProcess2Test()     { process2Test(false, false, false); }               
    private static testMethod void hasOldprocess2Test()         { process2Test(true , false, false); }               
    private static testMethod void hasNewOwnerprocess2Test()    { process2Test(true , true , false); }               
    private static testMethod void hasAllprocess2Test()         { process2Test(true , true , true ); }               

    // ------------------------------------------------------------------------------------------------------------
    
    private static void isCaseRelatedTaskTest(Boolean hasWhatId, Boolean isCaseWhatId)               
    { 
        TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
                                     taskConfig.whatId = (hasWhatId)
                                                            ? ((isCaseWhatId) ? '50011000001FTZs' : '00520000001qmXm')
                                                            : null;
        Task          dummyTask     = TEST_DummyTaskFactory.create(taskConfig, TEST_DummyInsertModeEnum.NONE);

        TestProcessor testProcessor = new TestProcessor();
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
               result = testProcessor.isCaseRelatedTask(dummyTask);
            }
            Test.stopTest();
        }
        
        System.assertEquals (hasWhatId && isCaseWhatId, result); 
    }

    private static testMethod void noWhatIdIsCaseRelatedTaskTest() { isCaseRelatedTaskTest(false, false); }               
    private static testMethod void userIdIsCaseRelatedTaskTest()   { isCaseRelatedTaskTest(true , false); }               
    private static testMethod void caseIdIsCaseRelatedTaskTest()   { isCaseRelatedTaskTest(true , true ); }               

    // ------------------------------------------------------------------------------------------------------------

    private static void iterateOnCaseTasksTest(Boolean isRelated, Boolean hasOldTask)               
    { 
        TEST_DummyTaskFactory.Config newTaskConfig = new TEST_DummyTaskFactory.Config();
                                     newTaskConfig.ownerId = TEST_RUN_USER.id;
                                     newTaskConfig.status  = ECICCommonConstants.STATUS_OPEN;
                                     newTaskConfig.whatId  = (isRelated) ? '50011000001FTZs' : '00520000001qmXm';
        Task dummyNewTask = TEST_DummyTaskFactory.create(newTaskConfig, TEST_DummyInsertModeEnum.NONE);
        
        Map<Id, Task> dummyOldTaskByIdMap = null;
        if (hasOldTask)
        {
            Task dummyOldTask = dummyNewTask.clone(false);
            TEST_MockHelper.mockInsert(dummyOldTask);
            dummyNewTask.id = dummyOldTask.id;
            dummyOldTaskByIdMap = new Map<Id, Task>{ dummyOldTask.id => dummyOldTask};
        }

        TestProcessor testProcessor = new TestProcessor();
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
               testProcessor.iterateOnCaseTasks(new List<Task>{ dummyNewTask }, dummyOldTaskByIdMap);
            }
            Test.stopTest();
        }

        Boolean expectedProcess = isRelated && !hasOldTask;
        System.assertEquals (expectedProcess, (PROCESSED_SUBJECT == dummyNewTask.subject));
    }

    private static testMethod void unrelatedIterateOnCaseTasksTest()        { iterateOnCaseTasksTest(false, false); }               
    private static testMethod void unrelatedWithOldIterateOnCaseTasksTest() { iterateOnCaseTasksTest(false, true ); }               
    private static testMethod void relatedIterateOnCaseTasksTest()          { iterateOnCaseTasksTest(true , false); }               
    private static testMethod void relatedWithOldIterateOnCaseTasksTest()   { iterateOnCaseTasksTest(true , true ); }               
}