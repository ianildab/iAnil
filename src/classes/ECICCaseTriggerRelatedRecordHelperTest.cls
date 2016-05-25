@isTest    
private class ECICCaseTriggerRelatedRecordHelperTest   
{
    private static final User   TEST_RUN_USER           = ECICRunUserTestHelper.create();

    private static void requiresStrategyTest(Boolean isStrategyRequired)
    {
        System.runAs(TEST_RUN_USER) { TEST_DummyProfileMappingFactory.createDefaultList(TEST_DummyInsertModeEnum.REAL); }

        String 				dummyCountryCode    = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_COUNTRY;
        String              dummyStrategyName   = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_STRATEGY_NAME;
        SEPTriggerTypeEnum  dummyTriggerType    = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_TRIGGER_TYPE;
        if (isStrategyRequired) { TEST_DummyCaseTrigStrategyConfigFactory.create(dummyCountryCode, dummyStrategyName, dummyTriggerType, TEST_DummyInsertModeEnum.REAL); }
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = ECICCaseTriggerRelatedRecordHelper.requiresStrategy(dummyStrategyName, dummyTriggerType, new Set<String>{ dummyCountryCode });
            }
            Test.stopTest();
        }
        
        System.assertEquals (isStrategyRequired, result);
    }

    private static testMethod void doesRequiresStrategyTest()   { requiresStrategyTest (true); }
	private static testMethod void doesntRequiresStrategyTest() { requiresStrategyTest (false); }
    
    // --------------------------------------------------------------------------------------------------------------------------

    private static void populateTest(String dummyStrategyName)
    {
        ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
        
        String dummyCountryCode                 = 'UK';
        SEPTriggerTypeEnum  dummyTriggerType    = SEPTriggerTypeEnum.BEFORE_INSERT;
        TEST_DummyCaseTrigStrategyConfigFactory.create(dummyCountryCode, dummyStrategyName, dummyTriggerType, TEST_DummyInsertModeEnum.REAL);
        
        Plant__c            dummyPlant          = ECICTestHelper.plant;
        Production_Line__c  dummyProductionLine = ECICTestHelper.productionLine;
        Product__c          dummyProduct        = ECICTestHelper.getProduct();
        
        ECICCaseTestHelper.CaseConfig caseConfig = new ECICCaseTestHelper.CaseConfig();
                                      caseConfig.countryCode = dummyCountryCode;
                                      caseConfig.plantId     = dummyPlant.Id;
                                      caseConfig.productId	 = dummyProduct.id;
        List<Case> dummyCaseList = new List<Case>{ ECICCaseTestHelper.createDummyCase(caseConfig, false) };
        
        Set<String> dummyCountryCodeSet = new Set<String> { dummyCountryCode }; 
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICCaseTriggerRelatedRecordHelper.populateCaches(dummyTriggerType, dummyCaseList, dummyCountryCodeSet, null);
            }
            Test.stopTest();
        } 

        if (dummyStrategyName == 'ECICCaseValidateProdlineStrategy')     { ECICCaseTriggerProductionLineCacheTest.assertProductionLineIdSetByPlantIdCachePopulated (dummyPlant.id, dummyProductionLine.id); }
        if (dummyStrategyName == 'ECICCaseCopyProductDetailsStrategy')   { ECICCaseTriggerProductCacheTest.assertProductCachesPopulated (dummyProduct); }
        
    }

    private static testMethod void caseValidateProdlineStrategyPopulateTest()   { populateTest('ECICCaseValidateProdlineStrategy');   }
    private static testMethod void caseCopyProductDetailsStrategyPopulateTest() { populateTest('ECICCaseCopyProductDetailsStrategy'); }

}