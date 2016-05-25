@isTest
private class ECICRegionTriggerTest {
    /*
    private static final User       TEST_RUN_USER   =   ECICRunUserTestHelper.create();
    
    private static void regionTriggerTest(Boolean isSkipTriggerInvocation) {
        if (isSkipTriggerInvocation) { setupSkipTriggerSettings(); }
        Region__c dummyRegion = null;
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                dummyRegion = TEST_DummyRegionFactory.create(TEST_DummyInsertModeEnum.REAL);
            }
            Test.stopTest();
        }
        
        dummyRegion = [SELECT Id, Owner_Lookup__c, Country_Code__c FROM Region__c WHERE Id =: dummyRegion.Id];
        
        if (isSkipTriggerInvocation) {
            System.assertEquals(null, dummyRegion.Owner_Lookup__c);
            System.assertEquals(null, dummyRegion.Country_Code__c);
        } else {
            System.assertNotEquals(null, dummyRegion.Owner_Lookup__c);
            System.assertNotEquals(null, dummyRegion.Country_Code__c);
        }
    }
    
    private static testmethod void regionTriggerSkipTriggerInvocationTest()     { regionTriggerTest(true);  }
    private static testmethod void regionTriggerNotSkipTriggerInvocationTest()  { regionTriggerTest(false); }
    
    // -----------------------------------------------------------------------------------------------------------------
    
    private static void setupSkipTriggerSettings() {
        SEPTriggerHandlerInvoker.pretendTestNotRunning = true;
        System.assertEquals(false, SEPTriggerHandlerInvoker.skipTriggerInvocation());
        
        TEST_DummyGeneralSettingsFactory.Config generalSettingsConfig = new TEST_DummyGeneralSettingsFactory.Config();
                                                generalSettingsConfig.skipTriggers = true;
        TEST_DummyGeneralSettingsFactory.create(generalSettingsConfig, TEST_DummyInsertModeEnum.REAL);
        System.assertEquals(true, SEPTriggerHandlerInvoker.skipTriggerInvocation());
    }
    */
}