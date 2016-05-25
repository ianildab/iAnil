@isTest
private class SEPScheduleHelperTest 
{
    private static final User   TEST_RUN_USER               = TEST_DummyUserFactory.createDefaultTestRunUser();

    private static testMethod void convertDateTimeToCronExpressionTest()
    {
        Datetime dummyDatetime = System.now(); 
        
        String result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = SEPScheduleHelper.convertDateTimeToCronExpression(dummyDatetime);
            }
            Test.stopTest();
        }
        
        Integer expectedYear      = dummyDatetime.year(); 
        Integer expectedMonth     = dummyDatetime.month(); 
        Integer expectedDay       = dummyDatetime.day(); 
        Integer expectedHour      = dummyDatetime.hour(); 
        Integer expectedMinute    = dummyDatetime.minute(); 
        Integer expectedSecond    = dummyDatetime.second();
        String  expectedString    = expectedSecond + ' ' + expectedMinute + ' ' + expectedHour + ' ' + expectedDay + ' ' + expectedMonth + ' ? ' + expectedYear;
        
        System.assertEquals(expectedString, result); 
    }

    // ---------------------------------------------------------------------------------------------------------------
    
    private static testMethod void getNowStringTest()
    {
        String result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = SEPScheduleHelper.getNowString();
            }
            Test.stopTest();
        }
        
        Datetime expectedDatetime = System.now(); 
        Integer  expectedYear      = expectedDatetime.year(); 
        Integer  expectedMonth     = expectedDatetime.month(); 
        Integer  expectedDay       = expectedDatetime.day(); 
        String   expectedString    = expectedDay + ' ' + expectedMonth + ' ? ' + expectedYear;
        
        System.assert(result.contains(expectedString)); 
    }

    // ---------------------------------------------------------------------------------------------------------------
    
    private static void isScheduledJobTest(Boolean isScheduled)
    {
    	String dummyJobName = 'DummySchedulable';
    	if (isScheduled) 
    	{ 
    		TEST_DummySchedulable dummySchedulable = new TEST_DummySchedulable();
    		System.Schedule ( dummyJobName,  '0 0 0 15 3 ? 2022 ' + dummyJobName,  dummySchedulable ); 
    	}
    	
    	Boolean result = null; 
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = SEPScheduleHelper.isScheduledJob(dummyJobName);
            }
            Test.stopTest();
        }
        
        System.assertEquals(isScheduled, result);
    }

    private static testMethod void notScheduledJobTest() { isScheduledJobTest(false); }
    private static testMethod void isScheduledJobTest()  { isScheduledJobTest(true);  }

    // ---------------------------------------------------------------------------------------------------------------
    
    private static void scheduleJobTest(Boolean isAlreadyScheduled)
    {
        String dummyJobName = 'DummySchedulable';
        if (isAlreadyScheduled) 
        { 
            TEST_DummySchedulable dummySchedulable = new TEST_DummySchedulable();
            System.Schedule ( dummyJobName,  '0 0 0 15 3 ? 2022 ' + dummyJobName,  dummySchedulable ); 
        }

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                SEPScheduleHelper.scheduleJob(dummyJobName, new TEST_DummySchedulable());
            }
            Test.stopTest();
        }
        
        List<CronTrigger> resultTriggerList = [SELECT id, cronExpression FROM CronTrigger WHERE cronExpression LIKE :('% ' + dummyJobName)];
        System.assertEquals(1, resultTriggerList.size());
        System.assertEquals(isAlreadyScheduled, resultTriggerList[0].cronExpression == ('0 0 0 15 3 ? 2022 ' + dummyJobName));
    }

    private static testMethod void notExistingScheduleJobTest() { scheduleJobTest(false); }
    private static testMethod void existingScheduleJobTest()    { scheduleJobTest(true);  }

    // ---------------------------------------------------------------------------------------------------------------

    private static testMethod void deleteJobTest()
    {
        String                dummyJobName     = 'DummySchedulable';
        TEST_DummySchedulable dummySchedulable = new TEST_DummySchedulable();
        System.Schedule ( dummyJobName,  '0 0 0 15 3 ? 2022 ' + dummyJobName,  dummySchedulable ); 

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                SEPScheduleHelper.deleteJob(dummyJobName);
            }
            Test.stopTest();
        }
        
        List<CronTrigger> resultTriggerList = [SELECT id FROM CronTrigger WHERE cronExpression LIKE :('% ' + dummyJobName) LIMIT 1];
        System.assertEquals(0, resultTriggerList.size());
    }

}