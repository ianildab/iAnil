@isTest
private class ECICCompetitorProductTriggerTest 
{
    private static final User TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();
    
    private static void triggerTest (Boolean isUpdateTest, Boolean skipTest)
    {
         TEST_DummyCompetitorProductFactory.Config config = new TEST_DummyCompetitorProductFactory.Config();
                                               config.ownerUserId = TEST_RUN_USER.id;
         Competitor_Product__c dummyCompetitorProduct = TEST_DummyCompetitorProductFactory.create(config, (isUpdateTest ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE));

         SEPTriggerHandlerInvoker.skipObjectTriggerInvocation('Competitor_Product__c', skipTest);
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                if   (!isUpdateTest) { insert dummyCompetitorProduct; }
                else                 { update dummyCompetitorProduct; }
            }
            Test.stopTest();
         } 
         
         Competitor_Product__c resultCompetitorProduct = [SELECT owner_lookup__c, country_code__c FROM Competitor_Product__c WHERE id = :dummyCompetitorProduct.id ];
         System.assertEquals(TEST_RUN_USER.id,              resultCompetitorProduct.owner_lookup__c); 
    }

    private static testMethod void doInsertTriggerTest()   { triggerTest (false, false); }
    private static testMethod void skipInsertTriggerTest() { triggerTest (false, true ); }
    private static testMethod void doUpdateTriggerTest()   { triggerTest (true , false); }
    private static testMethod void skipUpdateTriggerTest() { triggerTest (true , true ); }

}