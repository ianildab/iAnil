@isTest
private class ECICTaskToCaseIdMappingProcessorTest 
{
	private static User TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();

    private static testMethod void processTest()
    {
    	Id dummyId = '50011000001FTZs';
    	
    	TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
    	                             taskConfig.whatId = dummyId;
        Task dummyTask = TEST_DummyTaskFactory.create(taskConfig, TEST_DummyInsertModeEnum.NONE);

    	ECICTaskToCaseIdMappingProcessor dummyProcessor = new ECICTaskToCaseIdMappingProcessor();
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                dummyProcessor.process(dummyTask);
            }
            Test.stopTest();
        }
        
        System.assert (dummyProcessor.taskByCaseIdMap.containsKey(dummyTask));
        System.assertEquals (dummyId, dummyProcessor.taskByCaseIdMap.get(dummyTask));
    }

    // --------------------------------------------------------------------------------------------------
    
    private static void buildNonClosedTaskListTest(Boolean hasTaskCase, Boolean isCaseOpen)
    {
        
        Id            dummyCaseId      = null;
        Map<Id, Case> dummyCaseByIdMap = new Map<Id, Case>();
    	if (hasTaskCase)
    	{
    		TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
    		                     caseConfig.status = (isCaseOpen) ? ECICCommonConstants.STATUS_OPEN : ECICCommonConstants.STATUS_CLOSED;
        	Case dummyCase        = TEST_DummyInquiryCaseFactory.create (caseConfig, TEST_DummyInsertModeEnum.MOCK);
          	     dummyCaseId      = dummyCase.id;
                 dummyCaseByIdMap.put (dummyCase.id, dummyCase);
    	}
    	else {   dummyCaseId = '50011000001FTZs'; } 

        TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
                                     taskConfig.whatId = dummyCaseId;
        Task dummyTask = TEST_DummyTaskFactory.create(taskConfig, TEST_DummyInsertModeEnum.NONE);

        ECICTaskToCaseIdMappingProcessor dummyProcessor = new ECICTaskToCaseIdMappingProcessor();
                                         dummyProcessor.taskByCaseIdMap = new Map<Task, Id>{ dummyTask => dummyCaseId };
        
        List<Task> resultNonClosedTaskList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultNonClosedTaskList = dummyProcessor.buildNonClosedTaskList(dummyCaseByIdMap);
            }
            Test.stopTest();
        }
        
        Boolean expectedSuccess = hasTaskCase && isCaseOpen;
        if (expectedSuccess)
        {
        	System.assertEquals (1, resultNonClosedTaskList.size());
        	System.assertEquals (dummyTask, resultNonClosedTaskList[0]);
        }
        else 
        {
            String expectedError = (hasTaskCase)
                                        ? ECICTaskToCaseIdMappingProcessor.CASE_CLOSED_ERROR_MESSAGE
                                        : ECICTaskToCaseIdMappingProcessor.CASE_MISSING_ERROR_MESSAGE;

            String errorMessage = TEST_MockHelper.getMockString(dummyTask, 'error');
            
            System.assertEquals (expectedError, errorMessage);
        }
    }

    private static testMethod void noCaseBuildNonClosedTaskListTest()        { buildNonClosedTaskListTest(false, false); }
    private static testMethod void hasClosedCaseBuildNonClosedTaskListTest() { buildNonClosedTaskListTest(true , false); }
    private static testMethod void hasOpenCasebuildNonClosedTaskListTest()   { buildNonClosedTaskListTest(true , true ); }

    // --------------------------------------------------------------------------------------------------

    private static void filterNonClosedCaseTasksTest(Boolean hasTask)
    {
    	Task dummyNewTask = null;
    	if (hasTask)
    	{
	        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
	                             caseConfig.status = ECICCommonConstants.STATUS_OPEN;
	        Case dummyCase = TEST_DummyInquiryCaseFactory.create (TEST_DummyInsertModeEnum.REAL);
	
	        TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
	                                     taskConfig.whatId = dummyCase.id;
	        dummyNewTask = TEST_DummyTaskFactory.create(taskConfig, TEST_DummyInsertModeEnum.NONE);
    	}

        Task[]        dummyNewTaskArray   = new Task[] { dummyNewTask };
        Map<Id, Task> dummyOldTaskByIdMap = null; // As we've already tested ECICCaseTaskProcessorAbstract.iterateOnCaseTasks(), we should be able to disregard the potential impact of oldTasks here.
        
        Task[] resultNonClosedCaseTaskArray = null;
        System.runAs(TEST_RUN_USER)
        {
        	Test.startTest();
        	{
                resultNonClosedCaseTaskArray = ECICTaskToCaseIdMappingProcessor.filterNonClosedCaseTasks(dummyNewTaskArray, dummyOldTaskByIdMap);
        	}
        	Test.stopTest();
        }
        
        System.assertEquals ((hasTask) ? 1 : 0, resultNonClosedCaseTaskArray.size());
        if (hasTask) { System.assertEquals (dummyNewTask, resultNonClosedCaseTaskArray[0]); }
    }

    // SUCCESS: private static testMethod void noTaskFilterNonClosedCaseTasksTest()  { filterNonClosedCaseTasksTest(false); }
    private static testMethod void hasTaskFilterNonClosedCaseTasksTest() { filterNonClosedCaseTasksTest(true);  }

}