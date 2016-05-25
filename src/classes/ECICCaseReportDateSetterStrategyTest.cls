@isTest
private class ECICCaseReportDateSetterStrategyTest 
{
    private static final User                             TEST_RUN_USER   = ECICRunUserTestHelper.create(); 
    private static final ECICCaseReportDateSetterStrategy TARGET_STRATEGY = new ECICCaseReportDateSetterStrategy();
    
    private static void onBeforeUpdateTest (Boolean oldStatusQualityPending, Boolean newStatusChanged)
    {
    	TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
    	                     config.status = (oldStatusQualityPending) ? ECICCommonConstants.QUALITY_STATUS_PENDING_ON_QUALITY : ECICCommonConstants.STATUS_OPEN;
    	Case dummyOldCase = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.MOCK);
    	
    	Case dummyNewCase = dummyOldCase.clone(false);
    	     dummyNewCase.id       = dummyOldCase.id;
    	     dummyNewCase.status   = (newStatusChanged) ? ECICCommonConstants.STATUS_CLOSED : dummyOldCase.status;

        Boolean result = null;    	                     
        System.runAs(TEST_RUN_USER)
        {
        	Test.startTest();
        	{
                result = TARGET_STRATEGY.onBeforeUpdate(new Map<Id, Case>{ dummyOldCase.id => dummyOldCase }, new Map<Id, Case>{ dummyNewCase.id => dummyNewCase });		
        	}
        	Test.stopTest();
        }
        
        Boolean expectedDateSet = oldStatusQualityPending && newStatusChanged;
        System.assertEquals((expectedDateSet)? System.today() : null, dummyNewCase.date_of_the_report__c);
    }

    private static testMethod void hasNeitherOnBeforeUpdateTest()               { onBeforeUpdateTest (  false,  false  ); }
    private static testMethod void newStatusChangedOnBeforeUpdateTest()         { onBeforeUpdateTest (  false,  true   ); }
    private static testMethod void oldStatusQualityPendingOnBeforeUpdateTest()  { onBeforeUpdateTest (  true,   false  ); }
    private static testMethod void hasBothOnBeforeUpdateTest()                  { onBeforeUpdateTest (  true,   true   ); }
}