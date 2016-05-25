@isTest
private class ECICCaseTriggerRegionCacheTest {
    private static final User 	TEST_RUN_USER = ECICRunUserTestHelper.create();
    
    private static testMethod void getRegionByIdMapTest() {
        Region__c dummyRegion = TEST_DummyRegionFactory.create(TEST_DummyInsertModeEnum.MOCK);
        ECICCaseTriggerRegionCache.regionByIdCache.put (dummyRegion.id, dummyRegion);
        
        Map<Id, Region__c> resultRegionByIdMap = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                resultRegionByIdMap = ECICCaseTriggerRegionCache.getRegionByIdMap(); 
            }
            Test.stopTest();
        }
        
        System.assert(resultRegionByIdMap.containsKey(dummyRegion.id));
        System.assertEquals (dummyRegion, resultRegionByIdMap.get(dummyRegion.id)); 
    }
    
    private static testMethod void populateTest() {
        Region__c       dummyRegion1 = TEST_DummyRegionFactory.create(TEST_DummyInsertModeEnum.REAL);
        Region__c       dummyRegion2 = TEST_DummyRegionFactory.create(TEST_DummyInsertModeEnum.REAL);
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                ECICCaseTriggerRegionCache.populate();
            }
            Test.stopTest();
        }
        
        Map<Id, Region__c> resultRegionByIdCache = ECICCaseTriggerRegionCache.regionByIdCache;
        assertContains (resultRegionByIdCache, dummyRegion1);
        assertContains (resultRegionByIdCache, dummyRegion2);
    }
    
    private static void assertContains (Map<Id, Region__c> resultRegionByIdMap, Region__c targetRegion) {
        System.assert (resultRegionByIdMap.containsKey(targetRegion.id));
        System.assertEquals (targetRegion.bottler__c, resultRegionByIdMap.get(targetRegion.id).bottler__c);
    }
    
}