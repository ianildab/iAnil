@isTest
private class ECICCaseTriggerPackageCacheTest {
    private static final  User TEST_RUN_USER                     = ECICRunUserTestHelper.create();
    
    private static void packageCacheTest(Boolean isEmptyPackage, Boolean isEmptyProduct) {
        Package__c  dummyPackage    = !isEmptyPackage   ?   createDummyPackage()    : null;
        Product__c  dummyProduct    = !isEmptyProduct   ?   createDummyProduct()    : null;
        Case        dummyCase       = createDummyCase(dummyPackage, dummyProduct);
        if (isEmptyPackage && !isEmptyProduct) {
            createDummyPackage();
        }
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                ECICCaseTriggerPackageCache.populate(new List<Case> {dummyCase});
            }
            Test.stopTest();
        }
        
        Integer expectedCacheSize = (isEmptyPackage && isEmptyProduct) ? 0 : 1;
        system.assertEquals(expectedCacheSize, ECICCaseTriggerPackageCache.packageByIdCache.size());
    }
    
    static testmethod void emptyPackageEmptyProductTest()          { packageCacheTest(true, true);    }
    static testmethod void notEmptyPackageEmptyProductTest()       { packageCacheTest(false, true);   }
    static testmethod void notEmptyPackageNotEmptyProductTest()    { packageCacheTest(false, false);  }
    static testmethod void emptyPackageNotEmptyProductTest()       { packageCacheTest(true, false);   }
    
    //-------------------------------------------------------------------------------------------------------------
    
    private static Case createDummyCase(Package__c dummyPackage, Product__c  dummyProduct) {
        TEST_DummyCaseConfig    caseConfig                  = new TEST_DummyCaseConfig();
                                caseConfig.packageId        = dummyPackage != null  ? dummyPackage.Id   : null;
                                caseConfig.productId        = dummyProduct != null  ? dummyProduct.Id   : null;
        
        return TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.MOCK);
    }
    
    private static Product__c createDummyProduct() {
        Product__c returnProduct = TEST_DummyProductFactory.create(TEST_DummyInsertModeEnum.MOCK);
        ECICCaseTriggerProductCache.productByIdCache.put(returnProduct.Id, returnProduct);
        
        return returnProduct;
    }
    
    private static Package__c createDummyPackage() {
        return TEST_DummyPackageFactory.create(TEST_DummyInsertModeEnum.REAL);
    }
}