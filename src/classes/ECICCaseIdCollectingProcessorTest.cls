@isTest
private class ECICCaseIdCollectingProcessorTest 
{
    private static User TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();

    private static testMethod void processTest()
    {
        Id dummyId = '50011000001FTZs';
        
        TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
                                     taskConfig.whatId = dummyId;
        Task dummyTask = TEST_DummyTaskFactory.create(taskConfig, TEST_DummyInsertModeEnum.NONE);

        ECICCaseIdCollectingProcessor dummyProcessor = new ECICCaseIdCollectingProcessor();
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                dummyProcessor.process(dummyTask);
            }
            Test.stopTest();
        }
        
        System.assert (dummyProcessor.caseIdSet.contains(dummyId));
    }

    // --------------------------------------------------------------------------------------------------

    private static testMethod void buildCaseIdSetTest()
    {
        Id dummyId = '50011000001FTZs';
        
        TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
                                     taskConfig.whatId = dummyId;
        Task dummyNewTask = TEST_DummyTaskFactory.create(taskConfig, TEST_DummyInsertModeEnum.NONE);

        Set<Id> resultIdSet = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultIdSet =  ECICCaseIdCollectingProcessor.buildCaseIdSet(new Task[]{ dummyNewTask }, null); // As we've already tested ECICCaseTaskProcessorAbstract.iterateOnCaseTasks(), we should be able to disregard the potential impact of oldTasks here.
            }
            Test.stopTest();
        }
        
        System.assert (resultIdSet.contains(dummyId));
    }


}