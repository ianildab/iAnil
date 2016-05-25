@isTest
private class ECICPromotionTypeTriggerTest 
{
    private static final User TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();
    
    private static void triggerTest (Boolean isUpdateTest, Boolean skipTest)
    {
         TEST_DummyPromotionTypeFactory.Config config = new TEST_DummyPromotionTypeFactory.Config();
                                               config.ownerUserId = TEST_RUN_USER.id;
         Promotion_Type__c dummyPromotionType = TEST_DummyPromotionTypeFactory.create(config, (isUpdateTest ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE));

         SEPTriggerHandlerInvoker.skipObjectTriggerInvocation('Promotion_Type__c', skipTest);
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
            	if   (!isUpdateTest) { insert dummyPromotionType; }
            	else                 { update dummyPromotionType; }
            }
            Test.stopTest();
         } 
         
         Promotion_Type__c resultPromotionType = [SELECT owner_lookup__c, country_code__c FROM Promotion_Type__c WHERE id = :dummyPromotionType.id ];
         System.assertEquals(TEST_RUN_USER.id,              resultPromotionType.owner_lookup__c); 
         System.assertEquals(TEST_RUN_USER.country_code__c, resultPromotionType.country_code__c);
    }

    private static testMethod void doInsertTriggerTest()   { triggerTest (false, false); }
    private static testMethod void skipInsertTriggerTest() { triggerTest (false, true ); }
    private static testMethod void doUpdateTriggerTest()   { triggerTest (true , false); }
    private static testMethod void skipUpdateTriggerTest() { triggerTest (true , true ); }

}