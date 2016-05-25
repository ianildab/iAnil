@isTest 
public class ECICCaseTriggerProductCacheTest {
    private static final User   TEST_RUN_USER           = ECICRunUserTestHelper.create();
    
    private static testMethod void getProductByIdMapTest() {
        Product__c  dummyProduct = TEST_DummyProductFactory.create(TEST_DummyInsertModeEnum.MOCK);
        
        ECICCaseTriggerProductCache.productByIdCache = new Map<Id, Product__c>{ dummyProduct.id => dummyProduct };
        
        Map<Id, Product__c> resultMap = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                resultMap = ECICCaseTriggerProductCache.getProductByIdMap();
            }
            Test.stopTest();
        }
        
        System.assert (resultMap.containsKey(dummyProduct.id));
        System.assertEquals (dummyProduct, resultMap.get(dummyProduct.id));
    }
    
    // --------------------------------------------------------------------------------------------------------------------------
    
    private static testMethod void populateProductCachesTest() {
        Product__c  dummyProduct = TEST_DummyProductFactory.create(TEST_DummyInsertModeEnum.REAL);
        
        TEST_DummyCaseConfig    caseConfig              = new TEST_DummyCaseConfig();
                                caseConfig.productId    = dummyProduct.Id;
        Case dummyCase = TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.NONE);
        List<Case> dummyCaseList = new List<Case>{ dummyCase };
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                ECICCaseTriggerProductCache.populate (dummyCaseList);
            }
            Test.stopTest();
        }
        
        assertProductCachesPopulated (dummyProduct);
    }
    
    // --------------------------------------------------------------------------------------------------------------------------
    
    private static testMethod void populateProductCacheFromBeverageAndPackageTest() {
        String productDescription   = 'Burn';
        String productSize          = '250-Ml';
        String productPackageType   = 'Alum Btl';
        String productPackaging     = 'Alum Btl Nr Cntr';
        
        TEST_DummyBeverageFactory.Config beverageConfig = new TEST_DummyBeverageFactory.Config();
                                         beverageConfig.productDescription = productDescription;
        Beverage__c dummyBeverage   = TEST_DummyBeverageFactory.create(beverageConfig, TEST_DummyInsertModeEnum.REAL);
        
        TEST_DummyPackageFactory.Config packageConfig = new TEST_DummyPackageFactory.Config();
                                        packageConfig.packaging = productPackageType;
                                        packageConfig.size      = productSize;
        Package__c  dummyPackage    = TEST_DummyPackageFactory.create(packageConfig, TEST_DummyInsertModeEnum.REAL);
        
        TEST_DummyProductFactory.Config productConfig = new TEST_DummyProductFactory.Config();
                                        productConfig.productDescription    = productDescription;
                                        productConfig.packageType           = productPackageType;
                                        productConfig.packaging             = productPackaging;
                                        productConfig.size                  = productSize;
        Product__c  dummyProduct    = TEST_DummyProductFactory.create(productConfig, TEST_DummyInsertModeEnum.REAL);
        
        TEST_DummyCaseConfig    caseConfig              = new TEST_DummyCaseConfig();
                                caseConfig.beverageId   = dummyBeverage.Id;
                                caseConfig.packageId    = dummyPackage.Id;
        Case dummyCase = TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.NONE);
        List<Case> dummyCaseList = new List<Case>{ dummyCase };
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                ECICCaseTriggerProductCache.populate (dummyCaseList);
            }
            Test.stopTest();
        }
        
        assertProductCachesPopulated(dummyProduct);
    }
    
    // --------------------------------------------------------------------------------------------------------------------------
    
    public static void assertProductCachesPopulated (Product__c  expectedProduct) {
            Map<Id, Product__c> resultMap = ECICCaseTriggerProductCache.productByIdCache;
            System.assert (resultMap.containsKey(expectedProduct.id));
        System.assertEquals (resultMap.get(expectedProduct.id).id, expectedProduct.id);
    } 


}