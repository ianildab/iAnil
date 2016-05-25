@isTest
private class ECICCaseQComplSampleCollValidatorStrTest {
    private static final User TEST_RUN_USER                                     = ECICRunUserTestHelper.create();
    private static final ECICCaseQComplSampleCollValidatorStrat TARGET_STRATEGY = new ECICCaseQComplSampleCollValidatorStrat();
    
    private static void testCaseQComplSampleCollValidatorStrat(String action, Boolean isNullFieldsTest) {
        List<Case> dummyCaseList = isNullFieldsTest ? prepareCaseListNullFields(action) : prepareTestCaseList(action);
        
        Boolean strategyResult = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                if (action == 'isInsert') {
                    strategyResult = TARGET_STRATEGY.OnBeforeInsert(dummyCaseList);
                } else {
                    strategyResult = TARGET_STRATEGY.OnBeforeUpdate(null, new Map<Id, Case>(dummyCaseList));
                }
            }
            Test.stopTest();
        }
        
        Boolean expectedResult = !isNullFieldsTest;
        System.assertEquals(expectedResult, strategyResult);
    }
    
    static testMethod void onBeforeUpdateTest()     { testCaseQComplSampleCollValidatorStrat('isInsert', false);    }
    static testMethod void onBeforeInsertTest()     { testCaseQComplSampleCollValidatorStrat('isUpdate', false);    }
    static testMethod void onBeforeInsertNullData() { testCaseQComplSampleCollValidatorStrat('isInsert', true);     }
    static testMethod void onBeforeUpdateNullData() { testCaseQComplSampleCollValidatorStrat('isUpdate', true);     }
    
    //--------------------------------------------------------------------------------------------------------------------------
    
    private static List<Case> prepareCaseListNullFields(String action) {
        TEST_DummyCaseConfig firstConfig = new TEST_DummyCaseConfig();
                             firstConfig.plantId          = TEST_ConfigHelper.INTENTIONAL_NULL;
                             firstConfig.bottlerAccountId = TEST_ConfigHelper.INTENTIONAL_NULL;
                             firstConfig.sampleCollected  = true;
                             firstConfig.productionCode   = TEST_ConfigHelper.INTENTIONAL_NULL;
                             firstConfig.status           = ECICCommonConstants.STATUS_OPEN;
        
        TEST_DummyCaseConfig secondConfig = new TEST_DummyCaseConfig();
                             secondConfig.plantId          = TEST_ConfigHelper.INTENTIONAL_NULL;
                             secondConfig.bottlerAccountId = TEST_ConfigHelper.INTENTIONAL_NULL;
                             secondConfig.sampleCollected  = true;
                             secondConfig.productionCode   = 'testCode';
                             secondConfig.status           = ECICCommonConstants.STATUS_OPEN;
        
        TEST_DummyInsertModeEnum insertionMode = (action == 'isInsert') ? TEST_DummyInsertModeEnum.NONE : TEST_DummyInsertModeEnum.MOCK;
        return TEST_DummyFastQualityComplaintCaseFactry.createList(new List<TEST_DummyCaseConfig> { firstConfig, secondConfig }, insertionMode);
    }
    
    private static List<Case> prepareTestCaseList(String action) {
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.plantId          = TEST_DummyQualityComplaintCaseFactory.DEFAULT_PLANT.id;
                             config.productionCode   = ECICCommonConstants.TEST_PRODUCTION_LINE_NAME;
                             config.productId        = TEST_DummyQualityComplaintCaseFactory.DEFAULT_PRODUCT.id;
                             config.productionLineId = TEST_DummyQualityComplaintCaseFactory.DEFAULT_PRODUCTION_LINE.id;
                             config.status           = ECICCommonConstants.STATUS_OPEN;
        
        TEST_DummyInsertModeEnum insertionMode = (action == 'isInsert') ? TEST_DummyInsertModeEnum.NONE : TEST_DummyInsertModeEnum.MOCK;
        return new List<Case>{ TEST_DummyFastQualityComplaintCaseFactry.create (config, insertionMode) };
    }
    
}