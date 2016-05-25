@isTest
private class ECICCaseTriggerBeverageCacheTest {
    private static final  User TEST_RUN_USER                     = ECICRunUserTestHelper.create();
    
    private static void beverageCacheTest(Boolean isEmptyBeverage, Boolean isEmptyProduct) {
        Beverage__c dummyBeverage   = !isEmptyBeverage  ?   createDummyBeverage()   : null;
        Product__c  dummyProduct    = !isEmptyProduct   ?   createDummyProduct()    : null;
        Case        dummyCase       = createDummyCase(dummyBeverage, dummyProduct);
        if (isEmptyBeverage && !isEmptyProduct) {
            createDummyBeverage();
        }
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                ECICCaseTriggerBeverageCache.populate(new List<Case> {dummyCase});
            }
            Test.stopTest();
        }
        
        Integer expectedCacheSize = (isEmptyBeverage && isEmptyProduct) ? 0 : 1;
        system.assertEquals(expectedCacheSize, ECICCaseTriggerBeverageCache.beverageByIdCache.size());
    }
    
    static testmethod void emptyBeverageEmptyProductTest()          { beverageCacheTest(true, true);    }
    static testmethod void notEmptyBeverageEmptyProductTest()       { beverageCacheTest(false, true);   }
    static testmethod void notEmptyBeverageNotEmptyProductTest()    { beverageCacheTest(false, false);  }
    static testmethod void emptyBeverageNotEmptyProductTest()       { beverageCacheTest(true, false);   }
    
    //-------------------------------------------------------------------------------------------------------------
    
    private static Case createDummyCase(Beverage__c dummyBeverage, Product__c  dummyProduct) {
        TEST_DummyCaseConfig    caseConfig                  = new TEST_DummyCaseConfig();
                                caseConfig.beverageId       = dummyBeverage != null  ? dummyBeverage.Id  : null;
                                caseConfig.productId        = dummyProduct != null   ? dummyProduct.Id   : null;
        
        return TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.MOCK);
    }
    
    private static Product__c createDummyProduct() {
        Product__c returnProduct = TEST_DummyProductFactory.create(TEST_DummyInsertModeEnum.MOCK);
        ECICCaseTriggerProductCache.productByIdCache.put(returnProduct.Id, returnProduct);
        
        return returnProduct;
    }
    
    private static Beverage__c createDummyBeverage() {
        return TEST_DummyBeverageFactory.create(TEST_DummyInsertModeEnum.REAL);
    }
}