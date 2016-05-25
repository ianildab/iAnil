@isTest
public class ECICCaseTriggerProductionLineCacheTest {
    private static final User   TEST_RUN_USER           = ECICRunUserTestHelper.create();
    
    private static testMethod void getProductionLineIdSetByPlantIdMapTest() {
        Plant__c dummyPlant = TEST_DummyPlantFactory.create(TEST_DummyInsertModeEnum.MOCK);
        
        TEST_DummyProductionLineFactory.Config  prodLineConfig = new TEST_DummyProductionLineFactory.Config();
                                                prodLineConfig.plantId = dummyPlant.Id;
        Production_Line__c dummyProdLine = TEST_DummyProductionLineFactory.create(prodLineConfig, TEST_DummyInsertModeEnum.MOCK);
        
        ECICCaseTriggerProductionLineCache.productionLineIdSetByPlantIdCache = new Map<Id, Set<Id>>{ dummyPlant.Id => new Set<Id>{ dummyProdLine.Id } };
        
        Map<Id, Set<Id>> resultMap = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                resultMap = ECICCaseTriggerProductionLineCache.getProductionLineIdSetByPlantIdMap();
            }
            Test.stopTest();
        }
        
        assertProductionLineIdSetByPlantIdCachePopulated (dummyPlant.Id, dummyProdLine.Id);
        System.assert (resultMap.containsKey(dummyPlant.Id));
        System.assertEquals (dummyProdLine.Id, (new List<Id>(resultMap.get(dummyPlant.Id))[0]));
    }
    
    // --------------------------------------------------------------------------------------------------------------------------
    
    private static testMethod void populateProductionLineCachesTest() {
        Plant__c dummyPlant = TEST_DummyPlantFactory.create(TEST_DummyInsertModeEnum.REAL);
        
        TEST_DummyProductionLineFactory.Config  prodLineConfig = new TEST_DummyProductionLineFactory.Config();
                                                prodLineConfig.name     = ECICCommonConstants.TEST_PRODUCTION_LINE_NAME;
                                                prodLineConfig.plantId  = dummyPlant.Id;
        Production_Line__c dummyProductionLine = TEST_DummyProductionLineFactory.create(prodLineConfig, TEST_DummyInsertModeEnum.REAL);
        
        TEST_DummyCaseConfig    caseConfig                  = new TEST_DummyCaseConfig();
                                caseConfig.productionLineId = dummyProductionLine.Id;
                                caseConfig.plantId          = dummyPlant.Id;
                                caseConfig.productionCode   = dummyProductionLine.Production_Line_Name__c;
        Case dummyCase = TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.NONE);
        String productionCode = dummyCase.Production_Code__c;
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                ECICCaseTriggerProductionLineCache.populate (new List<Case>{ dummyCase });
            }
            Test.stopTest();
        }
        
        assertProductionLineIdSetByPlantIdCachePopulated (dummyPlant.id, dummyProductionLine.id);
        System.assertEquals (1, ECICCaseTriggerProductionLineCache.getProductionLineByPlantCodeMap().size());
        System.assertEquals (ECICCommonConstants.TEST_PRODUCTION_LINE_NAME, productionCode);
        System.assertEquals (true, ECICCaseTriggerProductionLineCache.getProductionLineByPlantCodeMap().containsKey(productionCode.toLowerCase()));
    }
    
    public static void assertProductionLineIdSetByPlantIdCachePopulated (Id expectedPlantId, Id expectedProductionLineId) {
        Map<Id, Set<Id>> resultMap = ECICCaseTriggerProductionLineCache.productionLineIdSetByPlantIdCache;
        System.assert (resultMap.containsKey(expectedPlantId));
        System.assert (resultMap.get(expectedPlantId).contains(expectedProductionLineId));
    }
    
}