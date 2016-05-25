@isTest private class ECICTrendRiskUpdateSchedulableTest 
{
    private static final User   TEST_RUN_USER               = TEST_DummyUserFactory.createDefaultTestRunUser();

    private static testMethod void scheduleBatchJob()
    {
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICTrendRiskUpdateSchedulable.scheduleJob();
                
                // This must be checked before Test.stopTest() because the job will delete itself when it executes.
                List<CronTrigger> resultTriggerList = [SELECT id, cronExpression FROM CronTrigger WHERE cronExpression LIKE :('% ' + ECICTrendRiskUpdateSchedulable.JOB_NAME)];
                System.assertEquals(1, resultTriggerList.size());
            }
            Test.stopTest();    // This will execute the job.
        } 

        // SFDC does not seem to execute Batchable in Schedulable tests (any more?), so we can't assert Batchable has executed.

        // Assert the job has deleted itself.
        List<CronTrigger> resultTriggerList = [SELECT id FROM CronTrigger WHERE cronExpression LIKE :('% ' + ECICTrendRiskUpdateSchedulable.JOB_NAME) LIMIT 1];
        System.assertEquals(0, resultTriggerList.size());
    }  
}