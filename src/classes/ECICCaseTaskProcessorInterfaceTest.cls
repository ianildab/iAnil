@isTest
private class ECICCaseTaskProcessorInterfaceTest 
{
    private static User     TEST_RUN_USER       = TEST_DummyUserFactory.createDefaultTestRunUser();
    private static String   PROCESSED_SUBJECT   = 'Processed';
    
    private class TestProcessor implements ECICCaseTaskProcessorInterface
    {
    	public void process(Task task) { task.subject = PROCESSED_SUBJECT; }
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
}