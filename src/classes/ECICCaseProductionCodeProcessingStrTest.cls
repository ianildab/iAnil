@isTest
private class ECICCaseProductionCodeProcessingStrTest {
    private static final User                                       TEST_RUN_USER   = ECICRunUserTestHelper.create();
    private static final ECICCaseProductionCodeProcessingStrategy   TARGET_STRATEGY = new ECICCaseProductionCodeProcessingStrategy();
    
    private static void strategyTest(Boolean isInsertTest) {
        Plant__c            dummyPlant          = TEST_DummyPlantFactory.create(TEST_DummyInsertModeEnum.MOCK);
        Production_Line__c  dummyProductionLine = createDummyProductionLine(dummyPlant.Id);
        Product__c          dummyProduct        = TEST_DummyProductFactory.create(TEST_DummyInsertModeEnum.MOCK);
        Case                dummyCase           = createDummyCase(dummyPlant.Id, dummyProductionLine.Id, dummyProduct.Id);
        Case                dummyNewCase        = null;
        
        if (!isInsertTest) {
            dummyNewCase = dummyCase.clone(true, true);
            dummyNewCase.Production_Code__c = 'F89';
        }
        
        System.assertEquals     (true, ECICCaseQualityComplaintRecordTypeHelper.isQualityComplaint(dummyCase.RecordTypeID));
        System.assertNotEquals  (null, dummyCase.Production_Code__c  );
        System.assertNotEquals  (null, dummyCase.Product__c          );
        System.assertNotEquals  (null, dummyCase.BBE_Date__c         );
        System.assertEquals     (null, dummyCase.Production_Date__c  );
        
        ECICCaseTriggerProductionLineCache.productionLineByPlantCodeCache.put(dummyProductionLine.Name.toLowerCase(), new List<Production_Line__c>{dummyProductionLine});
        ECICCaseTriggerProductCache.productByIdCache.put(dummyProduct.Id, dummyProduct);
        
        System.assertEquals(1,      ECICCaseTriggerProductCache.getProductByIdMap().size());
        System.assertEquals(true,   ECICCaseTriggerProductCache.getProductByIdMap().containsKey(dummyCase.Product__c));
        
        Boolean strategyResult = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                if (isInsertTest) {
                    strategyResult = TARGET_STRATEGY.OnBeforeInsert(new List<Case>{ dummyCase });
                } else {
                    strategyResult = TARGET_STRATEGY.OnBeforeUpdate(new Map<ID, Case>{ dummyCase.Id     => dummyCase    },
                                                                    new Map<ID, Case>{ dummyNewCase.Id  => dummyNewCase });
                }
            }
            Test.stopTest();
        }
        
        Case testCase = (isInsertTest) ? dummyCase : dummyNewCase;
        System.assertEquals (true,                                      strategyResult);
        System.assertEquals (dummyProductionLine.Id,                    testCase.Production_Line__c );
        System.assertEquals (dummyProductionLine.Plant__r.Id,           testCase.Plant__c           );
        System.assertEquals (dummyProductionLine.Plant__r.Bottler__c,   testCase.Bottler__c         );
        
    }
    
    static testMethod void onBeforeInsertTest() { strategyTest(true);   }
    static testMethod void onBeforeUpdateTest() { strategyTest(false);  }
    
    //----------------------------------------------------------------------------------------------------------------------
    
    private static Account createDummyAccount(Id dummyBottlerRegionId) {
        TEST_DummyAccountFactory.Config accountConfig           = new TEST_DummyAccountFactory.config();
                                        accountConfig.isPerson  = false;
                                        accountConfig.regionId  = dummyBottlerRegionId;
        
        return TEST_DummyAccountFactory.create(accountConfig, TEST_DummyInsertModeEnum.MOCK);
    }
    
    private static Production_Line__c createDummyProductionLine(Id dummyPlantId) {
        TEST_DummyProductionLineFactory.Config prodLineConfig           = new TEST_DummyProductionLineFactory.Config();
                                               prodLineConfig.name      = ECICCommonConstants.TEST_PRODUCTION_LINE_NAME;
                                               prodLineConfig.plantId   = dummyPlantId;
        
        return TEST_DummyProductionLineFactory.create(prodLineConfig, TEST_DummyInsertModeEnum.MOCK);
    }
    
    private static Case createDummyCase(Id dummyPlantId, Id dummyProductionLineId, Id dummyProductId) {
        TEST_DummyCaseConfig    caseConfig                  = new TEST_DummyCaseConfig();
                                caseConfig.plantId          = dummyPlantId;
                                caseConfig.productionLineId = dummyProductionLineId;
                                caseConfig.productId        = dummyProductId;
                                caseConfig.productionCode   = ECICCommonConstants.TEST_PRODUCTION_LINE_NAME;
                                caseConfig.status           = ECICCommonConstants.STATUS_OPEN;
        
        return TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.MOCK);
    }
    
    // Below methods are for Germany Quality comaplaint Test
    
        private static void strategyTestGermany(Boolean isInsertTest) {
        Plant__c            dummyPlant          = TEST_DummyPlantFactory.create(TEST_DummyInsertModeEnum.MOCK);
        Production_Line__c  dummyProductionLine = createDummyProductionLine(dummyPlant.Id);
      
        Case                dummyCase           = createDummyCase(dummyPlant.Id, dummyProductionLine.Id, null);
        Case                dummyNewCase        = null;
        
        
        if (!isInsertTest) {
            dummyNewCase = dummyCase.clone(true, true);
            dummyNewCase.Production_Code__c = 'F89';
        }
        
        System.assertEquals     (true, ECICCaseQualityComplaintRecordTypeHelper.isQualityComplaint(dummyCase.RecordTypeID));
        System.assertNotEquals  (null, dummyCase.Production_Code__c  );
        
       
        ECICCaseTriggerProductionLineCache.productionLineByPlantCodeCache.put(dummyProductionLine.Name.toLowerCase(), new List<Production_Line__c>{dummyProductionLine});
      
        Boolean strategyResult = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                if (isInsertTest) {
                    strategyResult = TARGET_STRATEGY.OnBeforeInsert(new List<Case>{ dummyCase });
                } else {
                    strategyResult = TARGET_STRATEGY.OnBeforeUpdate(new Map<ID, Case>{ dummyCase.Id     => dummyCase    },
                                                                    new Map<ID, Case>{ dummyNewCase.Id  => dummyNewCase });
                }
            }
            Test.stopTest();
        }
        
        Case testCase = (isInsertTest) ? dummyCase : dummyNewCase;
        System.assertEquals (true,                                      strategyResult);
        System.assertEquals (dummyProductionLine.Plant__r.Bottler__c,   testCase.Bottler__c         );
        System.assertEquals (dummyProductionLine.Plant__r.Id,           testCase.Plant__c           );
       
        
    }
    
    
       private static Case createDummyCaseGermany(Id dummyPlantId, Id dummyProductionLineId, Id dummyProductId) {
         Id getGermanyRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ECICCommonConstants.QUALITY_COMPLAINT_GERMANY).getRecordTypeId();
       
        TEST_DummyCaseConfig    caseConfig                  = new TEST_DummyCaseConfig();
                                caseConfig.plantId          = dummyPlantId;
                                caseConfig.productionLineId = dummyProductionLineId;
                                caseConfig.productionCode   = ECICCommonConstants.TEST_PRODUCTION_LINE_NAME;
                                caseConfig.status           = ECICCommonConstants.STATUS_OPEN;
                                caseConfig.RecordTypeId     = getGermanyRecordTypeId;
         return TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.MOCK);
       
    }
    
    
    static testMethod void onBeforeInsertTestGermany() { strategyTestGermany(true);   }
    static testMethod void onBeforeUpdateTestGermany() { strategyTestGermany(false);  }
    
}