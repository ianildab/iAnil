@isTest
private class ECICCaseTriggerPlantCacheTest {
    private static final User     TEST_RUN_USER = ECICRunUserTestHelper.create();
    
    private static testMethod void getPlantIdMapTest() {
        Plant__c dummyPlant = TEST_DummyPlantFactory.create(TEST_DummyInsertModeEnum.MOCK);
        ECICCaseTriggerPlantCache.plantByIdCache.put (dummyPlant.id, dummyPlant);
        
        Map<Id, Plant__c> resultPlantByIdMap = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                resultPlantByIdMap = ECICCaseTriggerPlantCache.getPlantIdMap(); 
            }
            Test.stopTest();
        }
        
        System.assert(resultPlantByIdMap.containsKey(dummyPlant.id));
        System.assertEquals (dummyPlant, resultPlantByIdMap.get(dummyPlant.id)); 
    }
    
    private static testMethod void populateTest() {
        Plant__c dummyPlant = TEST_DummyPlantFactory.create(TEST_DummyInsertModeEnum.REAL);
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                ECICCaseTriggerPlantCache.populate(); 
            }
            Test.stopTest();
        }
         
        assertContains(ECICCaseTriggerPlantCache.plantByIdCache, dummyPlant);
    }
    
    private static void assertContains (Map<Id, Plant__c> resultPlantByIdMap, Plant__c dummyPlant) {
        System.assert(resultPlantByIdMap.containsKey(dummyPlant.id));
        System.assertEquals (dummyPlant.bottler__c, resultPlantByIdMap.get(dummyPlant.id).bottler__c); 
    }
}