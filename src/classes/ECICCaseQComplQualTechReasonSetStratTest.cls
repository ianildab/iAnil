@isTest
private class ECICCaseQComplQualTechReasonSetStratTest 
{
    private static final User                                     TEST_RUN_USER   = ECICRunUserTestHelper.create(); 
    private static final ECICCaseQComplQualTechReasonsSetterStrat TARGET_STRATEGY = new ECICCaseQComplQualTechReasonsSetterStrat();
    
    private static void executeTest(Boolean isQualityComplaint, Boolean hasOldCase, Boolean hasDifferentCategoryLevel4)
    {
        Case          dummyNewCase        = createNewCase(isQualityComplaint);
        List<Case>    dummyNewCaseList    = new List<Case> { dummyNewCase };
        
        Case          dummyOldCase        = null;
        Map<Id, Case> dummyOldCaseByIdMap = null; 
        if (hasOldCase)
        {
            dummyOldCase        = createOldCase (dummyNewCase, hasDifferentCategoryLevel4);
            dummyNewCase.id     = dummyOldCase.id;
            dummyOldCaseByIdMap = new Map<Id, Case>{ dummyOldCase.id => dummyOldCase }; 
        }
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            { 
                TARGET_STRATEGY.execute (dummyOldCaseByIdMap, dummyNewCaseList);
            } 
            Test.stopTest(); 
        }
        
        Boolean techReasonSet = isQualityComplaint && (!hasOldCase || hasDifferentCategoryLevel4);
        System.assertEquals((techReasonSet) ? dummyNewCase.Category_Level4__c : null, dummyNewCase.Quality_Technical_Reason__c);
    }
    
    private static testMethod void newInquiryExecuteTest()                  { executeTest( false,   false,    false  ); }
    private static testMethod void updatedInquiryExecuteTest()              { executeTest( false,   true,     false  ); }
    private static testMethod void UpdatedInquiryWithNewCat4ExecuteTest()   { executeTest( false,   true,     true   ); }
    private static testMethod void newQualityExecuteTest()                  { executeTest( true,    false,    false  ); }
    private static testMethod void updatedQualityExecuteTest()              { executeTest( true,    true,     false  ); }
    private static testMethod void updatedQualityWithNewCat4ExecuteTest()   { executeTest( true,    true,     true   ); }
    
    // ------------------------------------------------------------------------------------------------------------------------
    
    private static void onBeforeMethodTest(Boolean isInsertTest)
    {
        Case dummyNewCase        = createNewCase(true);

        Case dummyOldCase = null;
        if (!isInsertTest)  // if Update Test
        {
            dummyOldCase    = createOldCase (dummyNewCase, true);
            dummyNewCase.id = dummyOldCase.id;
        }
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            { 
                result = (isInsertTest)
                            ? TARGET_STRATEGY.onBeforeInsert (                                                      new List<Case>   { dummyNewCase }                   )
                            : TARGET_STRATEGY.onBeforeUpdate (new Map<Id, Case>{ dummyOldCase.id => dummyOldCase }, new Map<Id, Case>{ dummyNewCase.id => dummyNewCase }); 
            } 
            Test.stopTest(); 
        }
        
        System.assert(result);
        System.assertEquals(dummyNewCase.Category_Level4__c, dummyNewCase.Quality_Technical_Reason__c);
    }
    
    private static testMethod void insertOnBeforeMethodTest() { onBeforeMethodTest (false); }
    private static testMethod void updateOnBeforeMethodTest() { onBeforeMethodTest (true);  }
    
    // -----------------------------------------------------------------------------------------------------------------------------
    
    private static Case createNewCase(Boolean isQualityComplaint)
    {
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             /*#CICTemplateTest*/
                             config.recordTypeId   = TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(isQualityComplaint ? ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME : ECICCommonConstants.INQUIRY_IBERIA_DEVNAME);
                             config.categoryLevel4 = ECICCommonConstants.CASE_CATEGORY_LEVEL_4_PACKAGE_QUALITY_FILL_LEVEL;
        return TEST_DummyGenericCaseFactory.create (config, TEST_DummyInsertModeEnum.NONE);                                
    }
    
    private static Case createOldCase (Case dummyNewCase, Boolean hasDifferentCategoryLevel4)
    {
        Case dummyOldCase = dummyNewCase.clone(false);
             dummyOldCase.Category_Level4__c = (hasDifferentCategoryLevel4) ? ECICCommonConstants.CASE_CATEGORY_LEVEL_4_PACKAGE_QUALITY_LABEL : dummyNewCase.Category_Level4__c;
        TEST_MockHelper.mockInsert(dummyOldCase);
        return dummyOldCase;
    }
    
    
}