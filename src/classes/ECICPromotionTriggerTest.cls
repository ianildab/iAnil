@isTest
private class ECICPromotionTriggerTest 
{
    private static final User TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();
    private static final String COUNTRY_CODE_DEFAULT = ECICCommonConstants.COUNTRY_CODE_DEFAULT;
    
    private static void triggerTest (Boolean isUpdateTest, Boolean skipTest)
    {
        Id            dummyOwnerId               = TEST_RUN_USER.id;
        Promotion__c  dummyPromotion             = createPromotion (isUpdateTest, dummyOwnerId, false);
        List<Promotion__c> dummyPromotionList    = new List<Promotion__c>{ dummyPromotion };

         SEPTriggerHandlerInvoker.skipObjectTriggerInvocation('Promotion__c', skipTest);
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                if   (!isUpdateTest) { insert dummyPromotion; }
                else                 { update dummyPromotion; }
            }
            Test.stopTest();
         } 
         
        Promotion__c resultPromotion = [SELECT owner_lookup__c, country_code__c FROM Promotion__c WHERE id = :dummyPromotion.id ];
        System.assertEquals (TEST_RUN_USER.country_code__c, resultPromotion.country_code__c);                                            
        System.assertEquals (TEST_RUN_USER.id,              resultPromotion.owner_lookup__c);                                            
    }

    private static testMethod void doInsertTriggerTest()   { triggerTest (false, false); }
    private static testMethod void skipInsertTriggerTest() { triggerTest (false, true ); }
    private static testMethod void doUpdateTriggerTest()   { triggerTest (true , false); }
    private static testMethod void skipUpdateTriggerTest() { triggerTest (true , true ); }

    // ------------------------------------------------------------------------------------------------------------------

    private static Promotion__c createPromotion (Boolean isUpdateTest, Id dummyOwnerId, Boolean hasCountryCode)
    {
        TEST_DummyPromotionFactory.Config config = new TEST_DummyPromotionFactory.Config();
                                          config.ownerId       = dummyOwnerId;
                                          config.countryCode   = (hasCountryCode) ? COUNTRY_CODE_DEFAULT : '';
        return TEST_DummyPromotionFactory.create(config, isUpdateTest ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE);
    }

}