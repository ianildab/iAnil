@isTest
private class ECICCaseValidateProdlineStrategyTest 
{
    private static final User                             TEST_RUN_USER   = ECICRunUserTestHelper.create(); 
    private static final ECICCaseValidateProdlineStrategy TARGET_STRATEGY = new ECICCaseValidateProdlineStrategy();
    
    private static final ID                               DEFAULT_DUMMY_PLANT_ID           = 'a0G110000000at1';
    private static final ID                               DEFAULT_DUMMY_PRODUCTION_LINE_ID = 'a0H110000001Tz1';
    
    private static void isExecutionRequired2Test(Boolean hasOld, Boolean hasChangedPlant, Boolean hasChangedProductionLine)
    {
        Case dummyQualityComplaintCase = createNewCase();
        Case dummyOldCase              = (hasOld) ? createOldCase(dummyQualityComplaintCase, hasChangedPlant, hasChangedProductionLine) : null;
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = TARGET_STRATEGY.isExecutionRequired(dummyOldCase, dummyQualityComplaintCase);
            }
            Test.stopTest();
        } 
        
        Boolean expectedResult = (!hasOld) || (hasChangedProductionLine || hasChangedPlant);
        System.assertEquals (expectedResult, result);
    }

    private static testMethod void noOldIsExecutionRequired2Test()                { isExecutionRequired2Test (    false,  false,  false   ); }
    private static testMethod void hasOldIsExecutionRequired2Test()               { isExecutionRequired2Test (    true,   false,  false   ); }
    private static testMethod void hasNewPlantIsExecutionRequired2Test()          { isExecutionRequired2Test (    true,   true,   false   ); }
    private static testMethod void hasNewProductionLineIsExecutionRequired2Test() { isExecutionRequired2Test (    true,   false,  true    ); }
    private static testMethod void hasBothChangesIsExecutionRequired2Test()       { isExecutionRequired2Test (    true,   true,   true    ); }

    // -----------------------------------------------------------------------------------------------------------------------------

    private static void isExecutionRequired1Test(Boolean hasOld, Boolean hasChangedPlant, Boolean hasChangedProductionLine)
    {
        Case          dummyQualityComplaintCase = createNewCase();
        Case          dummyOldCase              = (hasOld) ? createOldCase(dummyQualityComplaintCase, hasChangedPlant, hasChangedProductionLine) : null;
        
        Map<Id, Case> dummyOldCaseByIdMap       = null;
        if (hasOld) 
        { 
        	dummyQualityComplaintCase.id = dummyOldCase.id;
        	dummyOldCaseByIdMap          = new Map<Id, Case> { dummyOldCase.id => dummyOldCase }; 
        }
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = TARGET_STRATEGY.isExecutionRequired(dummyOldCaseByIdMap, new List<Case>{ dummyQualityComplaintCase } );
            }
            Test.stopTest();
        } 
        
        Boolean expectedResult = (!hasOld) || (hasChangedProductionLine || hasChangedPlant);
        System.assertEquals (expectedResult, result);
    }

    private static testMethod void noOldisExecutionRequired1Test()                { isExecutionRequired1Test (    false,  false,  false   ); }
    private static testMethod void hasOldisExecutionRequired1Test()               { isExecutionRequired1Test (    true,   false,  false   ); }
    private static testMethod void hasNewPlantIsExecutionRequired1Test()          { isExecutionRequired1Test (    true,   true,   false   ); }
    private static testMethod void hasNewProductionLineIsExecutionRequired1Test() { isExecutionRequired1Test (    true,   false,  true    ); }
    private static testMethod void hasBothChangesisExecutionRequired1Test()       { isExecutionRequired1Test (    true,   true,   true    ); }

    // -----------------------------------------------------------------------------------------------------------------------------

    private static void doExecution2Test(Boolean hasPlant, Boolean hasProductionLine, Boolean isPlantInCache, Boolean isProductionLineInSet)
    {
        Case dummyQualityComplaintCase = createNewCase(hasPlant, hasProductionLine);
        populateProductionLineCache (isPlantInCache, isProductionLineInSet);
        
        ECICCaseValidateProdlineStrategy targetStrategy = new ECICCaseValidateProdlineStrategy();
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = targetStrategy.doExecution(dummyQualityComplaintCase);
            }
            Test.stopTest();
        } 
        
        Boolean expectedResult = ( ((!hasPlant) || (!hasProductionLine)) || (isPlantInCache && isProductionLineInSet) );
        System.assertEquals (expectedResult, result);
        assertError(dummyQualityComplaintCase, hasPlant, hasProductionLine, isPlantInCache, isProductionLineInSet);
    }
    
    private static testMethod void hasNothingDoExecution2Test()                {   doExecution2Test(    false,    false,    false,    false    ); }
    // FIXME (See CIC-1544): private static testMethod void hasProductionLineDoExecution2Test()         {   doExecution2Test(    false,    true,     false,    false    ); }
    private static testMethod void hasPlantDoExecution2Test()                  {   doExecution2Test(    true,     false,    false,    false    ); }
    private static testMethod void hasPlantInCacheDoExecution2Test()           {   doExecution2Test(    true,     false,    true,     false    ); }
    private static testMethod void hasBothDoExecution2Test()                   {   doExecution2Test(    true,     true,     false,    false    ); }
    private static testMethod void hasBothWithPlantInCacheDoExecution2Test()   {   doExecution2Test(    true,     true,     true,     false    ); }
    private static testMethod void hasBothInCacheDoExecution2Test()            {   doExecution2Test(    true,     true,     true,     true     ); }

    // -----------------------------------------------------------------------------------------------------------------------------

    private static void doExecution1Test(Boolean hasPlant, Boolean hasProductionLine, Boolean isPlantInCache, Boolean isProductionLineInSet)
    {
        Case dummyQualityComplaintCase = createNewCase(hasPlant, hasProductionLine);
        populateProductionLineCache (isPlantInCache, isProductionLineInSet);
        
        ECICCaseValidateProdlineStrategy targetStrategy = new ECICCaseValidateProdlineStrategy();
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = targetStrategy.doExecution(new List<Case> {dummyQualityComplaintCase});
            }
            Test.stopTest();
        } 
        
        Boolean expectedResult = ( ((!hasPlant) || (!hasProductionLine)) || (isPlantInCache && isProductionLineInSet) );
        System.assertEquals (expectedResult, result);
        assertError(dummyQualityComplaintCase, hasPlant, hasProductionLine, isPlantInCache, isProductionLineInSet);
    }
    
    private static testMethod void hasNothingdoExecution1Test()                {   doExecution1Test(    false,    false,    false,    false    ); }
    // FIXME (See CIC-1544): private static testMethod void hasProductionLinedoExecution1Test()         {   doExecution1Test(    false,    true,     false,    false    ); }
    private static testMethod void hasPlantdoExecution1Test()                  {   doExecution1Test(    true,     false,    false,    false    ); }
    private static testMethod void hasPlantInCachedoExecution1Test()           {   doExecution1Test(    true,     false,    true,     false    ); }
    private static testMethod void hasBothdoExecution1Test()                   {   doExecution1Test(    true,     true,     false,    false    ); }
    private static testMethod void hasBothWithPlantInCachedoExecution1Test()   {   doExecution1Test(    true,     true,     true,     false    ); }
    private static testMethod void hasBothInCachedoExecution1Test()            {   doExecution1Test(    true,     true,     true,     true     ); }

    // -----------------------------------------------------------------------------------------------------------------------------

    private static void checkAndExecuteTest(Boolean isQualityCase)
    {
        Case dummyCase = createNewCase(isQualityCase);
        populateProductionLineCache (true, true);

        ECICCaseValidateProdlineStrategy targetStrategy = new ECICCaseValidateProdlineStrategy();
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = targetStrategy.checkAndExecute(null, new List<Case>{ dummyCase }); // We don't worry about old Cases here because it is only used to determine isExecutionRequired, which is already tested above.
            }
            Test.stopTest();
        } 

        System.assert (result);
    }

    private static testMethod void isQualityCheckAndExecuteTest()  { checkAndExecuteTest (false); }
    private static testMethod void notQualityCheckAndExecuteTest() { checkAndExecuteTest (true);  }


    // -----------------------------------------------------------------------------------------------------------------------------
    
    private static void onBeforeMethodTest(Boolean isInsertTest)
    {
        Case dummyNewCase = createNewCase();
        Case dummyOldCase = (!isInsertTest) ? createOldCase(dummyNewCase, true, true) : null;

        populateProductionLineCache (true, true);

        ECICCaseValidateProdlineStrategy targetStrategy = new ECICCaseValidateProdlineStrategy();
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = (isInsertTest)
                            ? targetStrategy.onBeforeInsert (new List<Case>{ dummyNewCase })
                            : targetStrategy.onBeforeUpdate (new Map<Id, Case> { dummyOldCase.id => dummyOldCase}, new Map<Id, Case> { dummyNewCase.id => dummyNewCase});
            }
            Test.stopTest();
        } 

        System.assert (result);
    }

    private static testMethod void insertOnBeforeMethodTest() { onBeforeMethodTest (true);  }
    private static testMethod void updateOnBeforeMethodTest() { onBeforeMethodTest (false); }

    // -----------------------------------------------------------------------------------------------------------------------------

    private static Case createNewCase(Boolean isQualityCase, Boolean hasPlant, Boolean hasProductionLine)
    {
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
        //# EciC Template test 
                             config.recordTypeId     = TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(isQualityCase ? ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME  : ECICCommonConstants.INQUIRY_IBERIA_DEVNAME );
                             config.plantId          = (hasPlant)          ? DEFAULT_DUMMY_PLANT_ID           : null;
                             config.productionLineId = (hasProductionLine) ? DEFAULT_DUMMY_PRODUCTION_LINE_ID : null;
        return TEST_DummyGenericCaseFactory.create (config, TEST_DummyInsertModeEnum.NONE);
    }

    private static Case createNewCase(Boolean hasPlant, Boolean hasProductionLine)  { return createNewCase (true,           hasPlant,   hasProductionLine   );  }
    private static Case createNewCase(Boolean isQualityCase)                        { return createNewCase (isQualityCase,  true,       true                );  }
    private static Case createNewCase()                                             { return createNewCase (true,           true,       true                );  }
    
    private static Case createOldCase(Case dummyNewCase, Boolean hasChangedPlant, Boolean hasChangedProductionLine)
    {
        Case   dummyOldCase = dummyNewCase.clone(false);
               dummyOldCase.plant__c           = (hasChangedPlant)          ?  'a0G110000000at2' : DEFAULT_DUMMY_PLANT_ID; 
               dummyOldCase.production_line__c = (hasChangedProductionLine) ?  'a0H110000001Tz2' : DEFAULT_DUMMY_PRODUCTION_LINE_ID;

        TEST_MockHelper.mockInsert(dummyOldCase);

        return dummyOldCase;
    }

    // -----------------------------------------------------------------------------------------------------------------------------
    
    private static void populateProductionLineCache (Boolean isPlantInCache, Boolean isProductionLineInSet)
    {
        if (isPlantInCache)
        {
            Set<Id> productionLineIdSet = (isProductionLineInSet) ? new Set<Id> { DEFAULT_DUMMY_PRODUCTION_LINE_ID } : new Set<Id>();
            ECICCaseTriggerProductionLineCache.productionLineIdSetByPlantIdCache.put (DEFAULT_DUMMY_PLANT_ID, productionLineIdSet);
        }
    }

    // -----------------------------------------------------------------------------------------------------------------------------

    private static void assertError(Case dummyQualityComplaintCase, Boolean hasPlant, Boolean hasProductionLine, Boolean isPlantInCache, Boolean isProductionLineInSet)
    {
        Boolean expectedError =  (
                                        ((hasPlant) && (hasProductionLine)) 
                                     && (!isPlantInCache || !isProductionLineInSet)
                                 );

        String errorMessage = TEST_MockHelper.getMockString(dummyQualityComplaintCase, 'error');
        System.assertEquals (expectedError, ((errorMessage != null) && (errorMessage.contains(System.Label.ProdLineDependsOnPlant))));
    }
    

}