@isTest
private class SEPErrorHelperTest 
{
    private static final User   TEST_RUN_USER       = TEST_DummyUserFactory.createDefaultTestRunUser();

    private static void addErrorTest(Boolean doAddToLog)
    {
    	Case    dummyCurrentSObject    = TEST_DummyInquiryCaseFactory.create();
    	String  dummyMessage           = 'Test Message';

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                SEPErrorHelper.addError(dummyCurrentSObject, dummyMessage, doAddToLog);
            }
            Test.stopTest();
        }

        // Note: Can't assert addition to debug log.
        System.assertEquals (dummyMessage, TEST_MockHelper.getMockString(dummyCurrentSObject, 'error'));
    }

    private static testMethod void dontLogAddErrorTest() { addErrorTest(false); }
    private static testMethod void logAddErrorTest()     { addErrorTest(true);  }

    // ---------------------------------------------------------------------------------------

    private static void logErrors1Test(Boolean isSaveSuccess)
    {
        String  dummyObjectName        = 'Account';
        String  dummyMessage           = 'Test Message';
        
        Account dummyAccount           = (isSaveSuccess) ? TEST_DummyAccountFactory.create(TEST_DummyInsertModeEnum.NONE) : new Account();
        List<Database.SaveResult> dummySaveResultList = DataBase.insert(new List<Account>{ dummyAccount }, false);

        LoggingLevel        dummyLoggingLevel = LoggingLevel.WARN;

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                SEPErrorHelper.logErrors(dummyObjectName, dummyMessage, dummySaveResultList);
                SEPErrorHelper.logErrors(dummyObjectName, dummyMessage, dummySaveResultList, dummyLoggingLevel);
            }
            Test.stopTest();
        }
        
        // Note: Can't assert addition to debug log.
    }

    private static testMethod void failLogErrors1Test()     { logErrors1Test(false); }
    private static testMethod void successLlogErrors1Test() { logErrors1Test(true);  }
    
}