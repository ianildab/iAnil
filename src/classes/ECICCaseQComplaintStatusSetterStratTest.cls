@isTest
private class ECICCaseQComplaintStatusSetterStratTest 
{
    private static final User                                   TEST_RUN_USER   = ECICRunUserTestHelper.create(); 
    private static final ECICCaseQComplaintStatusSetterStrategy TARGET_STRATEGY = new ECICCaseQComplaintStatusSetterStrategy();
 
    private static void statusRequiresResetTest(Boolean isQualityComplaint, Boolean hasOldCase, Boolean oldReasonDifferent, String status, Boolean isQualityStatusNull)
    {
        Case          dummyNewCase                = createDummyNewCase(isQualityComplaint, status, isQualityStatusNull);
        Case          dummyOldCase        = null;
        Map<Id, Case> dummyOldCaseByIdMap = null; 
        if (hasOldCase)
        {
            dummyOldCase        = createDummyOldCase(dummyNewCase, oldReasonDifferent);
            dummyNewCase.id     = dummyOldCase.id;
            dummyOldCaseByIdMap = new Map<Id, Case>{dummyOldCase.id => dummyOldCase};
        }
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = TARGET_STRATEGY.statusRequiresReset(dummyNewCase, dummyOldCaseByIdMap);              
            }
            Test.stopTest();
        }
        
        Boolean expectedResult = (
                                        (isQualityComplaint)
                                     && (!hasOldCase || oldReasonDifferent)
                                     && (!(new Set<String>{ ECICCommonConstants.STATUS_CLOSED, ECICCommonConstants.STATUS_CANCELLED }).contains(status))
                                     && (isQualityStatusNull)
                                 );
        System.assertEquals (expectedResult, result);
    }

    private testMethod static void newNoOldStatusRequiresResetTest()                                              { statusRequiresResetTest(false, false, false, ECICCommonConstants.STATUS_NEW,       false ); }
    private testMethod static void resolvedQualityStatusNullStatusRequiresResetTest()                             { statusRequiresResetTest(false, true,  false, ECICCommonConstants.STATUS_RESOLVED,  true  ); }
    private testMethod static void openNewReasonQualityStatusNullStatusRequiresResetTest()                        { statusRequiresResetTest(false, true,  true,  ECICCommonConstants.STATUS_OPEN,      true  ); }
    private testMethod static void closedNoOldStatusRequiresResetTest()                                           { statusRequiresResetTest(false, false, false, ECICCommonConstants.STATUS_CLOSED,    false ); }
    private testMethod static void cancelledStatusRequiresResetTest()                                             { statusRequiresResetTest(false, true,  false, ECICCommonConstants.STATUS_CANCELLED, false ); }

    private testMethod static void isEscalatedQualityComplaintNoOldStatusRequiresResetTest()                      { statusRequiresResetTest(true,  false, false, ECICCommonConstants.STATUS_ESCALATED, false ); }
    private testMethod static void isClosedQualityComplaintStatusRequiresResetTest()                              { statusRequiresResetTest(true,  true,  false, ECICCommonConstants.STATUS_CLOSED,    false ); }
    private testMethod static void isResolvedQualityComplaintNewReasonStatusRequiresResetTest()                   { statusRequiresResetTest(true,  true,  true,  ECICCommonConstants.STATUS_RESOLVED,  false ); }
    private testMethod static void isCancelledQualityComplaintNewReasonQualityStatusNullStatusRequiresResetTest() { statusRequiresResetTest(true,  true,  true,  ECICCommonConstants.STATUS_CANCELLED, true  ); }

    // -------------------------------------------------------------------------------------------------------------------

    private static void setCaseQualityStatusToNewTest(Boolean requiresReset)
    {
        Case dummyNewCase = createDummyNewCase(requiresReset, ECICCommonConstants.STATUS_OPEN, true);
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_STRATEGY.setCaseQualityStatusToNew(new List<Case>{ dummyNewCase }, null); // Old Case Map is null for simplicity.  Only used in  statusRequiresReset() which is tested separately.             
            }
            Test.stopTest();
        }
        
        System.assertEquals ((requiresReset ? ECICCommonConstants.QUALITY_STATUS_NEW_COMPLAINT : null), dummyNewCase.quality_status__c);
    }

    private static testMethod void notRequiredSetCaseQualityStatusToNewTest() { setCaseQualityStatusToNewTest(false); }
    private static testMethod void requiredSetCaseQualityStatusToNewTest()    { setCaseQualityStatusToNewTest(true);  }

    // -------------------------------------------------------------------------------------------------------------------
    
    private static void onBeforeInsertTest(Boolean requiresReset)
    {
        Case dummyNewCase = createDummyNewCase(requiresReset, ECICCommonConstants.STATUS_OPEN, true);
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = TARGET_STRATEGY.onBeforeInsert(new List<Case>{ dummyNewCase });              
            }
            Test.stopTest();
        }
        
        System.assert (result);
        System.assertEquals ((requiresReset ? ECICCommonConstants.QUALITY_STATUS_NEW_COMPLAINT : null), dummyNewCase.quality_status__c);
    }

    private static testMethod void notRequiredOnBeforeInsertTest() { onBeforeInsertTest(false); }
    private static testMethod void requiredOnBeforeInsertTest()    { onBeforeInsertTest(true);  }

    // -------------------------------------------------------------------------------------------------------------------

    private static void onBeforeUpdateTest(Boolean requiresReset)
    {
        Case dummyNewCase = createDummyNewCase(requiresReset, ECICCommonConstants.STATUS_OPEN, true);
        Case dummyOldCase = createDummyOldCase(dummyNewCase, true);
             dummyNewCase.id = dummyOldCase.id;
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = TARGET_STRATEGY.onBeforeUpdate(new Map<Id, Case>{ dummyOldCase.id => dummyOldCase}, new Map<Id, Case>{ dummyNewCase.id => dummyNewCase});              
            }
            Test.stopTest();
        }
        
        System.assert (result);
        System.assertEquals ((requiresReset ? ECICCommonConstants.QUALITY_STATUS_NEW_COMPLAINT : null), dummyNewCase.quality_status__c);
    }

    private static testMethod void notRequiredOnBeforeUpdateTest() { onBeforeUpdateTest(false); }
    private static testMethod void requiredOnBeforeUpdateTest()    { onBeforeUpdateTest(true);  }

    // ---------------------------------------------------------------------------------------------------------------------------------------------

    private static Case createDummyNewCase(Boolean useQualityComplaint, String status, Boolean isQualityStatusNull)
    {   /*#CICTemplateTest*/
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.recordTypeId  = TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(useQualityComplaint ? ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME: ECICCommonConstants.INQUIRY_IBERIA_DEVNAME);
                             config.status        = status;
                             config.reason        = ECICCommonConstants.QUALITY_COMPLAINT_REASON_PRODUCTS;
                             config.qualityStatus = (isQualityStatusNull) ? null : ECICCommonConstants.STATUS_OPEN;
        return TEST_DummyGenericCaseFactory.create (config, TEST_DummyInsertModeEnum.NONE);
    }
    
    private static Case createDummyOldCase(Case dummyNewCase, Boolean changeReason)
    {
            Case dummyOldCase   = dummyNewCase.clone(false);
                 dummyOldCase.reason = (changeReason) ? ECICCommonConstants.QUALITY_COMPLAINT_REASON_PACKAGE : dummyNewCase.reason;
            TEST_MockHelper.mockInsert(dummyOldCase);
            return dummyOldCase;
    } 
   

}