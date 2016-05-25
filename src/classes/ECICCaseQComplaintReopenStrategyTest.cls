@isTest
private class ECICCaseQComplaintReopenStrategyTest 
{
    private static final User                             TEST_RUN_USER   = ECICRunUserTestHelper.create(); 
    private static final ECICCaseQComplaintReopenStrategy TARGET_STRATEGY = new ECICCaseQComplaintReopenStrategy();

    private static void canRenewTest(Boolean newHasActionPlan, Boolean newIsClosed, Boolean oldIsClosed)
    {
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig ();
                             config.actionPlanId = (newHasActionPlan) ? 'a2111000000984i'                 : TEST_ConfigHelper.INTENTIONAL_NULL;
                             config.status       = (newIsClosed)      ? ECICCommonConstants.STATUS_CLOSED : ECICCommonConstants.STATUS_OPEN; 
        Case dummyNewCase = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.MOCK);
        
        Case dummyOldCase = dummyNewCase.clone(false);
             dummyOldCase.id     = dummyNewCase.id;
             dummyOldCase.Status = (oldIsClosed) ? ECICCommonConstants.STATUS_CLOSED : ECICCommonConstants.STATUS_OPEN; 

        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = TARGET_STRATEGY.canRenew(dummyNewCase, dummyOldCase);
            }
            Test.stopTest();
        } 
        
        Boolean expectedResult = (!newHasActionPlan) && (!newIsClosed) && (oldIsClosed);
        System.assertEquals (expectedResult, result);
    }

    private static testMethod void noPlanOpenNewOpenOldCanRenewTest()       { canRenewTest(false,   false,  false); }
    private static testMethod void noPlanOpenNewClosedOldCanRenewTest()     { canRenewTest(false,   false,  true);  }
    private static testMethod void noPlanClosedNewOpenOldCanRenewTest()     { canRenewTest(false,   true,   false); }
    private static testMethod void noPlanClosedNewClosedOldCanRenewTest()   { canRenewTest(false,   true,   true);  }
    private static testMethod void hasPlanOpenNewOpenOldCanRenewTest()      { canRenewTest(true,    false,  false); }
    private static testMethod void hasPlanOpenNewClosedOldCanRenewTest()    { canRenewTest(true,    false,  true);  }
    private static testMethod void hasPlanClosedNewOpenOldCanRenewTest()    { canRenewTest(true,    true,   false); }
    private static testMethod void hasPlanClosedNewClosedOldCanRenewTest()  { canRenewTest(true,    true,   true);  }
    
    // -------------------------------------------------------------------------------------------------------------------------    
    
    private static void OnBeforeUpdateTest(Boolean isQualityComplaint) 
    {
        String dummyProcessType = 'Dummy Process Type';
        
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig ();
                             /*#CICTemplateTest*/
                             config.recordTypeId = TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(isQualityComplaint ? ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME : ECICCommonConstants.INQUIRY_IBERIA_DEVNAME);
                             config.actionPlanId = TEST_ConfigHelper.INTENTIONAL_NULL;
                             config.status       = ECICCommonConstants.STATUS_OPEN;
                             config.processType  = dummyProcessType;
        Case dummyNewCase = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.MOCK);
        
        Case dummyOldCase = dummyNewCase.clone(false);
             dummyOldCase.id     = dummyNewCase.id;
             dummyOldCase.status = ECICCommonConstants.STATUS_CLOSED; 

        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = TARGET_STRATEGY.onBeforeUpdate(new Map<Id, Case>{ dummyOldCase.id => dummyOldCase }, new Map<Id, Case>{ dummyNewCase.id => dummyNewCase });
            }
            Test.stopTest();
        } 

        System.assertEquals (true,                                                                                    result);
        System.assertEquals ((isQualityComplaint) ? ECICCommonConstants.STATUS_NEW : ECICCommonConstants.STATUS_OPEN, dummyNewCase.status);
        System.assertEquals ((isQualityComplaint) ? 'Other'                        : dummyProcessType,                dummyNewCase.process_type__c);
    }
    
    private static testMethod void inquiryOnBeforeUpdateTest()     { onBeforeUpdateTest(false); } 
    private static testMethod void qualityCaseOnBeforeUpdateTest() { onBeforeUpdateTest(true);  } 
}