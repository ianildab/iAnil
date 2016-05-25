@isTest
private class ECICCompetitorProductTriggerHandlerTest 
{
    private static final User TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();
    
    private static void constructorTest(Boolean isTriggerExecuting) 
    {
        ECICCompetitorProductTriggerHandler dummyHandler = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                dummyHandler = new ECICCompetitorProductTriggerHandler(isTriggerExecuting);
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
         TEST_DummyCompetitorProductFactory.Config config = new TEST_DummyCompetitorProductFactory.Config();
                                               config.ownerUserId = TEST_RUN_USER.id; 
         Competitor_Product__c          dummyNewCompetitorProduct           = TEST_DummyCompetitorProductFactory.create(config, (isUpdateTest ? TEST_DummyInsertModeEnum.MOCK : TEST_DummyInsertModeEnum.NONE));
         List<Competitor_Product__c>    dummyNewCompetitorProductList       = new List<Competitor_Product__c>{ dummyNewCompetitorProduct };

         Competitor_Product__c          dummyOldCompetitorProduct           = null;
         Map<Id, Competitor_Product__c> dummyOldCompetitorProductByIdMap    = null;
         if (isUpdateTest)
         {
            dummyOldCompetitorProduct        = dummyNewCompetitorProduct.clone(false);
            dummyOldCompetitorProduct.id     = dummyNewCompetitorProduct.id;
            dummyOldCompetitorProductByIdMap = new Map<Id, Competitor_Product__c>{ dummyOldCompetitorProduct.id => dummyOldCompetitorProduct };               
         }

        ECICCompetitorProductTriggerHandler dummyHandler = (targetFunction != 'processBefore') ? new ECICCompetitorProductTriggerHandler(false) : null;
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                if      (targetFunction == 'processBefore' ) { ECICCompetitorProductTriggerHandler.processBefore(dummyNewCompetitorProductList); }
                else if (targetFunction == 'onBeforeInsert') { dummyHandler.onBeforeInsert(dummyNewCompetitorProductList);                                                 }
                else if (targetFunction == 'onBeforeUpdate') { dummyHandler.onBeforeUpdate(null, dummyNewCompetitorProductList, dummyOldCompetitorProductByIdMap, null);       }
            }
            Test.stopTest();
         } 
         
         System.assertEquals(TEST_RUN_USER.id,              dummyNewCompetitorProduct.owner_lookup__c); 
    }

    private static testMethod void insertProcessBeforeTest() { processBeforeTest(false, 'processBefore'); }
    private static testMethod void updateProcessBeforeTest() { processBeforeTest(true,  'processBefore'); }
    private static testMethod void onBeforeInsertTest()      { processBeforeTest(false, 'onBeforeInsert'); }
    private static testMethod void onBeforeUpdateTest()      { processBeforeTest(true,  'onBeforeUpdate'); }
    
}