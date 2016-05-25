@isTest
private class ECICOpenAlertNotificationCacheTest {
    private static final User    TEST_RUN_USER  = TEST_DummyUserFactory.createDefaultTestRunUser();
    
    private static testMethod void populateOpenAlertCacheTest() {
        Date          dummyEndDate     = System.today();
        Open_Alert__c dummyOpenAlert   = createOpenAlert(dummyEndDate, TEST_RUN_USER.id);
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                ECICOpenAlertNotificationCache.populate(new Set<Id>{TEST_RUN_USER.id});
            }
            Test.stopTest();
        }
        
        Map<Id, List<Open_Alert__c>> resultMap = ECICOpenAlertNotificationCache.getOpenAlertListByUserIdMap();
        System.assertEquals (1, resultMap.size());
        System.assertEquals (true, resultMap.containsKey(TEST_RUN_USER.id));
        System.assertEquals (dummyOpenAlert.Id, resultMap.get(TEST_RUN_USER.id).get(0).Id);
    }
    
    private static Open_Alert__c createOpenAlert(Date dummyEndDate, Id dummyOwnerUserId) {
         TEST_DummyOpenAlertFactory.Config config = new TEST_DummyOpenAlertFactory.Config();
                                           config.endDate     = dummyEndDate;
                                           config.ownerUserId = dummyOwnerUserId;
         return TEST_DummyOpenAlertFactory.create(config, TEST_DummyInsertModeEnum.REAL);
    }
}