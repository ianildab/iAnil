@isTest
private class ECICCaseQualityStatusClosingStrategyTest 
{
    private static final User                                 TEST_RUN_USER   = ECICRunUserTestHelper.create(); 
    private static final ECICCaseQualityStatusClosingStrategy TARGET_STRATEGY = new ECICCaseQualityStatusClosingStrategy();

    private static void setQualityStatusClosedTest(Boolean isQualityCase, Boolean isClosed, Boolean hasActionPlan)
    {
        Case dummyCase = createCase (isQualityCase, isClosed, hasActionPlan);
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_STRATEGY.setQualityStatusClosed(new List<Case> { dummyCase});
            }
            Test.stopTest();
        }
        
        Boolean expectQualityClosed = isQualityCase && isClosed && !hasActionPlan;
        if (expectQualityClosed) { System.assertEquals (ECICCommonConstants.STATUS_CLOSED, dummyCase.quality_status__c); }
    }
    
    private static testMethod void hasNothingSetQualityStatusClosedTest()                   { setQualityStatusClosedTest (  false,  false,  false   ); }
    private static testMethod void hasActionPlanSetQualityStatusClosedTest()                { setQualityStatusClosedTest (  false,  false,  true    ); }
    private static testMethod void isClosedSetQualityStatusClosedTest()                     { setQualityStatusClosedTest (  false,  true,   false   ); }
    private static testMethod void isClosedWithActionPlanSetQualityStatusClosedTest()       { setQualityStatusClosedTest (  false,  true,   true    ); }
    private static testMethod void qualityCaseSetQualityStatusClosedTest()                  { setQualityStatusClosedTest (  true,   false,  false   ); }
    private static testMethod void qualityCaseWithActionPlanSetQualityStatusClosedTest()    { setQualityStatusClosedTest (  true,   false,  true    ); }
    private static testMethod void closedQualityCaseSetQualityStatusClosedTest()            { setQualityStatusClosedTest (  true,   true,   false   ); }
    private static testMethod void closedQualityWithActionPlanSetQualityStatusClosedTest()  { setQualityStatusClosedTest (  true,   true,   true    ); }

    // --------------------------------------------------------------------------------------------------------------------
        
    private static void onBeforeMethodTest(Boolean isInsertTest)
    {
        Case dummyNewCase = createCase (true, true, false);
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            { 
                result = (isInsertTest)
                            ? TARGET_STRATEGY.onBeforeInsert (      new List<Case>   { dummyNewCase }                   )
                            : TARGET_STRATEGY.onBeforeUpdate (null, new Map<Id, Case>{ dummyNewCase.id => dummyNewCase }); // Old values are ignored.
            } 
            Test.stopTest(); 
        }
        
        System.assert(result);
        System.assertEquals (ECICCommonConstants.STATUS_CLOSED, dummyNewCase.quality_status__c);
    }
    
    private static testMethod void insertOnBeforeMethodTest() { onBeforeMethodTest (false); }
    private static testMethod void updateOnBeforeMethodTest() { onBeforeMethodTest (true);  }

    // --------------------------------------------------------------------------------------------------------------------
        
    private static Case createCase (Boolean isQualityCase, Boolean isClosed, Boolean hasActionPlan)
    {
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             /*#CICTemplateTest*/
                             config.recordTypeId   = TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(isQualityCase ? ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME : ECICCommonConstants.INQUIRY_IBERIA_DEVNAME);
                             config.status         = (isClosed)         ? ECICCommonConstants.STATUS_CLOSED : ECICCommonConstants.STATUS_OPEN;
                             config.actionPlanId   = (hasActionPlan)    ? 'a2111000000984i' : null;
        return TEST_DummyGenericCaseFactory.create (config, TEST_DummyInsertModeEnum.NONE);                                
    }

}