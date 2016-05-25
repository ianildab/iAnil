@isTest
private class ECICCaseTrendCleanupStrategyTest 
{
    private static final User                         TEST_RUN_USER   = ECICRunUserTestHelper.create(); 
    private static final ECICCaseTrendCleanupStrategy TARGET_STRATEGY = new ECICCaseTrendCleanupStrategy();

    private static void onBeforeUpdateTest (Boolean hasNewCanceledCase)
    {
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.status  = (hasNewCanceledCase) ? ECICCommonConstants.STATUS_CANCELLED : ECICCommonConstants.STATUS_OPEN;
                             caseConfig.trendId = 'a0K110000008v95'; 
        Case dummyNewCase = TEST_DummyInquiryCaseFactory.create (caseConfig, TEST_DummyInsertModeEnum.MOCK);
        
        Case dummyOldCase = dummyNewCase.clone(false);
             dummyOldCase.id       = dummyNewCase.id;
             dummyOldCase.status   = ECICCommonConstants.STATUS_OPEN; // We shouldn't need to test making this STATUS_CANCELLED because filterNewCasesByStatusChangedTo() has already been tested.

        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
               result = TARGET_STRATEGY.onBeforeUpdate (new Map <Id, Case>{ dummyOldCase.id => dummyOldCase }, new Map <Id, Case>{ dummyNewCase.id => dummyNewCase });
            }
            Test.stopTest();
        }
        
        System.assert (result);
        System.assertEquals (hasNewCanceledCase, dummyNewCase.trend__c == null);  
    }
    
    private static testMethod void openOnBeforeUpdateTest()     { onBeforeUpdateTest (false); }
    private static testMethod void canceledOnBeforeUpdateTest() { onBeforeUpdateTest (true);  }
    
}