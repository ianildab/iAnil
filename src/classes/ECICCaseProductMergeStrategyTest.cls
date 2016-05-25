@isTest
private class ECICCaseProductMergeStrategyTest {
    private static final User                           TEST_RUN_USER   = ECICRunUserTestHelper.create();
    private static final ECICCaseProductMergeStrategy   TARGET_STRATEGY = new ECICCaseProductMergeStrategy();
    
    static void strategyTest(Boolean isInsertTest, Boolean isCountryCodeMatch, Boolean isProductMatch) {
        Product__c  dummyProduct    = createDummyProduct(isProductMatch);
        Beverage__c dummyBeverage   = TEST_DummyBeverageFactory.create(TEST_DummyInsertModeEnum.MOCK);
        Package__c  dummyPackage    = TEST_DummyPackageFactory.create(TEST_DummyInsertModeEnum.MOCK);
        Case        dummyCase       = createDummyCase(dummyPackage.Id, dummyBeverage.Id);
        Case        dummyOldCase    = (!isInsertTest) ? dummyCase.clone(true, true) : null;
        
        if (!isCountryCodeMatch) {
            dummyBeverage.Country_Code__c   = 'X0';
            dummyPackage.Country_Code__c    = 'T0';
        }
        
        ECICCaseTriggerProductCache.productByIdCache.put    (dummyProduct.Id, dummyProduct);
        ECICCaseTriggerBeverageCache.beverageByIdCache.put  (dummyBeverage.Id, dummyBeverage);
        ECICCaseTriggerPackageCache.packageByIdCache.put    (dummyPackage.Id, dummyPackage);
        System.assertEquals (null,                    dummyCase.Product__c );
        
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
        
        Boolean isErrTest           = !isCountryCodeMatch || !isProductMatch;
        String expectedErrMessage   = (!isCountryCodeMatch) ? Label.Case_beverage_and_package_CC_dont_match
                                                            : (!isProductMatch) ? Label.Case_product_not_found
                                                            : null;
        Id expectedProductId        = isErrTest ? null : dummyProduct.Id;
        System.assertEquals (true,                  strategyResult);
        System.assertEquals (isErrTest,             ECICCaseProductMergeStrategy.isError);
        System.assertEquals (expectedErrMessage,    ECICCaseProductMergeStrategy.errMessage);
        System.assertEquals (expectedProductId,     dummyCase.Product__c );
    }
    
    static testMethod void onBeforeInsertCCMatchProductMatchTest()          { strategyTest(true,  true,   true);    }
    static testMethod void onBeforeInsertCCMatchProductNotMatchTest()       { strategyTest(true,  true,   false);   }
    static testMethod void onBeforeInsertCCNotMatchProductMatchTest()       { strategyTest(true,  false,  true);    }
    static testMethod void onBeforeInsertCCNotMatchProductNotMatchTest()    { strategyTest(true,  false,  false);   }
    
    static testMethod void onBeforeUpdateCCMatchProductMatchTest()          { strategyTest(false, true,   true);    }
    static testMethod void onBeforeUpdateCCMatchProductNotMatchTest()       { strategyTest(false, true,   false);   }
    static testMethod void onBeforeUpdateCCNotMatchProductMatchTest()       { strategyTest(false, false,  true);    }
    static testMethod void onBeforeUpdateCCNotMatchProductNotMatchTest()    { strategyTest(false, false,  false);   }
    
    //-----------------------------------------------------------------------------------------------------------------------
    
    private static Case createDummyCase(Id dummyPackageId, Id dummyBeverageId) {
        TEST_DummyCaseConfig    caseConfig                  = new TEST_DummyCaseConfig();
                                caseConfig.packageId        = dummyPackageId;
                                caseConfig.beverageId       = dummyBeverageId;
        
        return TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.MOCK);
    }
    
    private static Product__c createDummyProduct(Boolean isProductMatch) {
        TEST_DummyProductFactory.Config productConfig = new TEST_DummyProductFactory.Config();
                                        productConfig.productDescription    = isProductMatch    ?   ECICCommonConstants.PRODUCT_DESCRIPTION_DEFAULT     : 'dummyTestDescription';
                                        productConfig.packageType           = isProductMatch    ?   ECICCommonConstants.PRODUCT_PACKAGE_TYPE_DEFAULT    : 'dummyTestPackageType';
                                        productConfig.packaging             = isProductMatch    ?   ECICCommonConstants.PRODUCT_PACKAGING_DEFAULT       : 'dummyTestPackaging';
                                        productConfig.size                  = isProductMatch    ?   ECICCommonConstants.PRODUCT_SIZE_DEFAULT            : 'dummyTestSize';
        return TEST_DummyProductFactory.create(productConfig, TEST_DummyInsertModeEnum.MOCK);
    }
}