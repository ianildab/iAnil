@isTest
private class ECICCaseQualityCloseDateSetterStratTest 
{
    private static final User                                     TEST_RUN_USER   = ECICRunUserTestHelper.create(); 
    private static final ECICCaseQualityCloseDateSetterStrategy TARGET_STRATEGY = new ECICCaseQualityCloseDateSetterStrategy();
    
    private static void executeTest(Boolean isQualityClosed, Boolean hasOldCase, Boolean hasDifferentQualityStatus)
    {
        Case          dummyNewCase        = createNewCase(isQualityClosed);
        List<Case>    dummyNewCaseList    = new List<Case> { dummyNewCase };
        
        Case          dummyOldCase        = null;
        Map<Id, Case> dummyOldCaseByIdMap = null; 
        if (hasOldCase)
        {
            dummyOldCase        = createOldCase (dummyNewCase, hasDifferentQualityStatus);
            dummyNewCase.id     = dummyOldCase.id;
            dummyOldCaseByIdMap = new Map<Id, Case>{ dummyOldCase.id => dummyOldCase }; 
        }
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            { 
                TARGET_STRATEGY.execute (dummyNewCaseList, dummyOldCaseByIdMap);
            } 
            Test.stopTest(); 
        }
        
        Boolean isCloseDateSet = isQualityClosed && (!hasOldCase || hasDifferentQualityStatus);
        System.assertEquals((isCloseDateSet) ? System.today() : null, dummyNewCase.Quality_Close_Date__c);
    }
    
    private static testMethod void insertOpenExecuteTest()                   { executeTest( false,   false,    false  ); }
    private static testMethod void updateOpenExecuteTest()                   { executeTest( false,   true,     false  ); }
    private static testMethod void updateOpenDifQualityStatusExecuteTest()   { executeTest( false,   true,     true   ); }
    private static testMethod void insertClosedQualityExecuteTest()          { executeTest( true,    false,    false  ); }
    private static testMethod void updateClosedExecuteTest()                 { executeTest( true,    true,     false  ); }
    private static testMethod void updateClosedDifQualityStatusExecuteTest() { executeTest( true,    true,     true   ); }
    
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
        System.assertEquals(System.today(), dummyNewCase.Quality_Close_Date__c);
    }
    
    private static testMethod void insertOnBeforeMethodTest() { onBeforeMethodTest (false); }
    private static testMethod void updateOnBeforeMethodTest() { onBeforeMethodTest (true);  }
    
    // -----------------------------------------------------------------------------------------------------------------------------
    
    private static Case createNewCase(Boolean isQualityClosed)
    {
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.qualityStatus = (isQualityClosed) ? ECICCommonConstants.STATUS_CLOSED : ECICCommonConstants.STATUS_OPEN; 
        return TEST_DummyGenericCaseFactory.create (config, TEST_DummyInsertModeEnum.NONE);                                
    }
    
    private static Case createOldCase (Case dummyNewCase, Boolean hasDifferentQualityStatus)
    {
        Case dummyOldCase = dummyNewCase.clone(false);
             dummyOldCase.quality_status__c  = (hasDifferentQualityStatus) ? ECICCommonConstants.STATUS_NEW : dummyNewCase.quality_status__c;
        TEST_MockHelper.mockInsert(dummyOldCase);
        return dummyOldCase;
    }
    
    

}