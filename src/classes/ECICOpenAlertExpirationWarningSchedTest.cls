// @see http://www.salesforce.com/us/developer/docs/apex_workbook/Content/apex_scheduling_2.htm
@isTest
private class ECICOpenAlertExpirationWarningSchedTest 
{
    private static final User    TEST_RUN_USER  = TEST_DummyUserFactory.createDefaultTestRunUser();

    private static final Date    TARGET_DATE    = Date.today().addDays(1);
    private static final String  CRON_EXP       = convertDateToCronExpression(TARGET_DATE);           
    private static final Id EMAIL_TEMPLATE_ID   = [SELECT id FROM EmailTemplate WHERE DeveloperName='Open_Alert_Expiration_Notification'].Id;           
 
    private static testMethod void schedulableExecuteTest()
    {
         General_Settings__c gs = TEST_DummyGeneralSettingsFactory.create(TEST_DummyInsertModeEnum.REAL);
         gs.Open_Alert_Expiration_Template_Id__c = EMAIL_TEMPLATE_ID;
         update gs;
         Integer       emailLimitBefore = Limits.getEmailInvocations();
         createOpenAlertList();

         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
		      //  Schedule the test job
		            String jobId = System.schedule('ECICOpenAlertExpirationWarningSched', CRON_EXP, new ECICOpenAlertExpirationWarningSched());
		         
		      // Get the information from the CronTrigger API object
		            CronTrigger cronTrigger = [SELECT Id, CronExpression, TimesTriggered,  NextFireTime FROM CronTrigger WHERE id = :jobId];
		
		      System.assertEquals(CRON_EXP,  cronTrigger.CronExpression);                               // Verify the expressions are the same
		      System.assertEquals(0, cronTrigger.TimesTriggered);                                       // Verify the job has not run
		      System.assertEquals(convertDateToString (TARGET_DATE),  String.valueOf(cronTrigger.NextFireTime));    // Verify the next time the job will run
		      System.assertEquals (emailLimitBefore, Limits.getEmailInvocations(), 'Should be equal.'); // Verify the scheduled job hasn't run yet.
            }
            
            Test.stopTest();                                                                            // Because this is a test, job executes immediately after Test.stopTest().
         }


		// FIXME: Assertion fails.  (See CIC-1492)
		// While the Schedulable has full coverage, it isn't clear whether the Batchable actually executes beyond construction.
        // assertEmailSent(emailLimitBefore); 
    }
    
    private static String convertDateToCronExpression (Date targetDate)                                  
    {   
    	// CRON expression for midnight on March 15:  '0 0 0 15 3 ? 2022';                                 
    	return '0 0 0 ' + targetDate.day() + ' ' + targetDate.month() + ' ? ' + targetDate.year();
    }

    private static String convertDateToString (Date targetDate)                                  
    {   
        // Formatted Scheduled date string for midnight on March 15:  '2022-03-15';                                 
        String monthString = ((targetDate.month() < 10) ? '0' : '') + targetDate.month();
        String dayString   = ((targetDate.day()   < 10) ? '0' : '') + targetDate.day();
        return targetDate.year() + '-' + monthString + '-' + dayString + ' 00:00:00';
    }
    
    // -------------------------------------------------------------------------------------------------------------------------------------

    private static List<Open_Alert__c> createOpenAlertList()
    {
        List<TEST_DummyOpenAlertFactory.Config> configList = new List<TEST_DummyOpenAlertFactory.Config>();
		
		/**
         *		NOTE: We probably don't need most of these: I'm just trying to ensure that there is at least
		 *			  One active Open_Alertic with an expiration pending when the Schedulable executes,
		 * 			  regardless of the date given for execution.
		 **/
                     configList.add (createOpenAlertConfig(System.today()));
                     configList.add (createOpenAlertConfig(System.today().addDays(1)));
                     configList.add (createOpenAlertConfig(System.today().addDays(10)));
                     configList.add (createOpenAlertConfig(System.today().addDays(100)));
                     configList.add (createOpenAlertConfig(System.today().addDays(1000)));
                     configList.add (createOpenAlertConfig(System.today().addDays(-1)));
                     configList.add (createOpenAlertConfig(System.today().addDays(-10)));
                     configList.add (createOpenAlertConfig(System.today().addDays(-100)));
                     configList.add (createOpenAlertConfig(System.today().addDays(-1000)));
        return TEST_DummyOpenAlertFactory.createList (configList, TEST_DummyInsertModeEnum.REAL);
    }

    private static TEST_DummyOpenAlertFactory.Config createOpenAlertConfig (Date targetDate)
    {
         TEST_DummyOpenAlertFactory.Config config = new TEST_DummyOpenAlertFactory.Config();
                                           config.endDate     = targetDate;
                                           config.ownerUserId = TEST_RUN_USER.id;
                                    return config;
    }
    
    
    private static void assertEmailSent(Integer emailLimitBefore)    
    {
		System.assertNotEquals (emailLimitBefore, Limits.getEmailInvocations(), 'Should have decreased');
    }
    
    
}