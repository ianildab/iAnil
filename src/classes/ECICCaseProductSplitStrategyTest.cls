@isTest
private class ECICCaseProductSplitStrategyTest {
    private static final User                           TEST_RUN_USER   = ECICRunUserTestHelper.create();
    private static final ECICCaseProductSplitStrategy   TARGET_STRATEGY = new ECICCaseProductSplitStrategy();
    
    static void strategyTest(Boolean isInsertTest, Boolean isBeverageMatch, Boolean isPackageMatch) {
        Product__c  dummyProduct    = createDummyProduct(isBeverageMatch, isPackageMatch);
        Beverage__c dummyBeverage   = TEST_DummyBeverageFactory.create(TEST_DummyInsertModeEnum.MOCK);
        Package__c  dummyPackage    = TEST_DummyPackageFactory.create(TEST_DummyInsertModeEnum.MOCK);
        Case        dummyCase       = createDummyCase(dummyProduct.Id);
        Case        dummyOldCase    = (!isInsertTest) ? dummyCase.clone(true, true) : null;
        createGeneralSettings();
        
        ECICCaseTriggerProductCache.productByIdCache.put    (dummyProduct.Id, dummyProduct);
        ECICCaseTriggerBeverageCache.beverageByIdCache.put  (dummyBeverage.Id, dummyBeverage);
        ECICCaseTriggerPackageCache.packageByIdCache.put    (dummyPackage.Id, dummyPackage);
        Integer initialEmailCount = ECICCaseTriggerEmailMessageCache.emailMessagesToSendCache.size();
        
        System.assertEquals (dummyProduct.Id,   dummyCase.Product__c);
        System.assertEquals (null,              dummyCase.Beverage__c);
        System.assertEquals (null,              dummyCase.Package__c);
        System.assertEquals (0,                 initialEmailCount);
        
        Boolean strategyResult = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                if (isInsertTest) {
                    strategyResult = TARGET_STRATEGY.OnBeforeInsert(new List<Case>{ dummyCase });
                } else {
                    strategyResult = TARGET_STRATEGY.OnBeforeUpdate(new Map<ID, Case>{ dummyOldCase.Id  => dummyOldCase },
                                                                    new Map<ID, Case>{ dummyCase.Id     => dummyCase    });
                }
            }
            Test.stopTest();
        }
        
        ID expectedBeverage         = isBeverageMatch   ? dummyBeverage.Id : null;
        ID expectedPackage          = isPackageMatch    ? dummyPackage.Id  : null;
        Integer expectedEmailCount  = (!isBeverageMatch || !isPackageMatch) ? initialEmailCount + 1 : initialEmailCount;
        System.assertEquals (true,                  strategyResult);
        System.assertEquals (expectedBeverage,      dummyCase.Beverage__c);
        System.assertEquals (expectedPackage,       dummyCase.Package__c);
        System.assertEquals (dummyProduct.Id,       dummyCase.Product__c);
        System.assertEquals (expectedEmailCount,    ECICCaseTriggerEmailMessageCache.emailMessagesToSendCache.size());
    }
    
    static testMethod void onBeforeInsertBeverageMatchPackageMatchTest()        { strategyTest(true, true,  true);  }
    static testMethod void onBeforeInsertBeverageNotMatchPackageMatchTest()     { strategyTest(true, false, true);  }
    static testMethod void onBeforeInsertBeverageNotMatchPackageNotMatchTest()  { strategyTest(true, false, false); }
    
    static testMethod void onBeforeUpdateBeverageMatchPackageMatchTest()        { strategyTest(false, true,  true);  }
    static testMethod void onBeforeUpdateBeverageNotMatchPackageMatchTest()     { strategyTest(false, false, true);  }
    static testMethod void onBeforeUpdateBeverageNotMatchPackageNotMatchTest()  { strategyTest(false, false, false); }
    
    //-----------------------------------------------------------------------------------------------------------------------
    
    private static Case createDummyCase(Id  dummyProductId) {
        TEST_DummyCaseConfig    caseConfig                  = new TEST_DummyCaseConfig();
                                caseConfig.productId        = dummyProductId;
        
        return TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.MOCK);
    }
    
    private static Product__c createDummyProduct(Boolean isBeverageMatch, Boolean isPackageMatch) {
        TEST_DummyProductFactory.Config productConfig = new TEST_DummyProductFactory.Config();
                                        productConfig.productDescription    = isBeverageMatch   ?   ECICCommonConstants.PRODUCT_DESCRIPTION_DEFAULT     : 'dummyTestDescription';
                                        productConfig.packageType           = isPackageMatch    ?   ECICCommonConstants.PRODUCT_PACKAGE_TYPE_DEFAULT    : 'dummyTestPackageType';
                                        productConfig.packaging             = isPackageMatch    ?   ECICCommonConstants.PRODUCT_PACKAGING_DEFAULT       : 'dummyTestPackaging';
                                        productConfig.size                  = isPackageMatch    ?   ECICCommonConstants.PRODUCT_SIZE_DEFAULT            : 'dummyTestSize';
        return TEST_DummyProductFactory.create(productConfig, TEST_DummyInsertModeEnum.MOCK);
    }
    
    private static void createGeneralSettings() {
        TEST_DummyGeneralSettingsFactory.create(TEST_DummyInsertModeEnum.REAL);
    }
}