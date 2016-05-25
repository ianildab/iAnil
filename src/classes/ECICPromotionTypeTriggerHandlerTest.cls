@isTest
private class ECICPromotionTypeTriggerHandlerTest 
{
    private static final User TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();
    
    private static void constructorTest(Boolean isTriggerExecuting) 
    {
        ECICPromotionTypeTriggerHandler dummyHandler = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                dummyHandler = new ECICPromotionTypeTriggerHandler(isTriggerExecuting);
            }
            Test.stopTest();
        } 
        
        System.assertEquals (isTriggerExecuting, dummyHandler.isTriggerExecuting);
    }

    private static testMethod void notExecutingConstructorTest() { constructorTest(false); } 
    private static testMethod void executingConstructorTest()    { constructorTest(false); } 
    
    // ------------------------------------------------------------------------------------------------------------------
    
    private static void processBeforeTest(Boolean isUpdateTest, String targetFunction)
    {
    	 TEST_DummyPromotionTypeFactory.Config config = new TEST_DummyPromotionTypeFactory.Config();
    	                                       config.ownerUserId = TEST_RUN_USER.id;
         Promotion_Type__c          dummyNewPromotionType           = TEST_DummyPromotionTypeFactory.create(config, (isUpdateTest ? TEST_DummyInsertModeEnum.MOCK : TEST_DummyInsertModeEnum.NONE));
         List<Promotion_Type__c>    dummyNewPromotionTypeList       = new List<Promotion_Type__c>{ dummyNewPromotionType };

         Promotion_Type__c          dummyOldPromotionType           = null;
         Map<Id, Promotion_Type__c> dummyOldPromotionTypeByIdMap    = null;
         if (isUpdateTest)
         {
            dummyOldPromotionType        = dummyNewPromotionType.clone(false);
            dummyOldPromotionType.id     = dummyNewPromotionType.id;
            dummyOldPromotionTypeByIdMap = new Map<Id, Promotion_Type__c>{ dummyOldPromotionType.id => dummyOldPromotionType };           	  
         }

        ECICPromotionTypeTriggerHandler dummyHandler = (targetFunction != 'processBefore') ? new ECICPromotionTypeTriggerHandler(false) : null;
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                if      (targetFunction == 'processBefore' ) { ECICPromotionTypeTriggerHandler.processBefore(dummyNewPromotionTypeList, dummyOldPromotionTypeByIdMap); }
                else if (targetFunction == 'onBeforeInsert') { dummyHandler.onBeforeInsert(dummyNewPromotionTypeList);                                                 }
                else if (targetFunction == 'onBeforeUpdate') { dummyHandler.onBeforeUpdate(null, dummyNewPromotionTypeList, dummyOldPromotionTypeByIdMap, null);       }
            }
            Test.stopTest();
         } 
         
         System.assertEquals(TEST_RUN_USER.id,              dummyNewPromotionType.owner_lookup__c); 
         System.assertEquals(TEST_RUN_USER.country_code__c, dummyNewPromotionType.country_code__c);
    }

    private static testMethod void insertProcessBeforeTest() { processBeforeTest(false, 'processBefore'); }
    private static testMethod void updateProcessBeforeTest() { processBeforeTest(true,  'processBefore'); }
    private static testMethod void onBeforeInsertTest()      { processBeforeTest(false, 'onBeforeInsert'); }
    private static testMethod void onBeforeUpdateTest()      { processBeforeTest(true,  'onBeforeUpdate'); }
    
}