@isTest
public class ECICCaseBeveragePkgCountryValidStrTest {
    private static final User                           TEST_RUN_USER   = ECICRunUserTestHelper.create();
    private static final ECICCaseBeveragePackageCountryValidStr   TARGET_STRATEGY = new ECICCaseBeveragePackageCountryValidStr();
    
    static void strategyTest(Boolean isCountryCodeMatch) {
        Beverage__c dummyBeverage   = TEST_DummyBeverageFactory.create(TEST_DummyInsertModeEnum.MOCK);
        Package__c  dummyPackage    = TEST_DummyPackageFactory.create(TEST_DummyInsertModeEnum.MOCK);
        Case        dummyCase       = createDummyCase(dummyPackage.Id, dummyBeverage.Id);
        
        if (!isCountryCodeMatch) {
            dummyBeverage.Country_Code__c   = 'X0';
            dummyPackage.Country_Code__c    = 'T0';
        }
        
        ECICCaseTriggerBeverageCache.beverageByIdCache.put  (dummyBeverage.Id, dummyBeverage);
        ECICCaseTriggerPackageCache.packageByIdCache.put    (dummyPackage.Id, dummyPackage);
        
        Boolean strategyResult = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                strategyResult = TARGET_STRATEGY.OnBeforeInsert(new List<Case>{ dummyCase });
            }
            Test.stopTest();
        }
        
        System.assertEquals (true,                  strategyResult);
        
        if (!isCountryCodeMatch) {
            String expectedErrMessage   =  Label.Case_beverage_and_package_CC_dont_match;
            System.assertEquals (true,                  ECICCaseBeveragePackageCountryValidStr.isError);
            System.assertEquals (expectedErrMessage,    ECICCaseBeveragePackageCountryValidStr.errMessage);
        }
    }
    
    static testMethod void onBeforeInsertCCMatchTest()          { strategyTest(true);    }
    static testMethod void onBeforeInsertCCNotMatchTest()       { strategyTest(false);   }
    
    //-----------------------------------------------------------------------------------------------------------------------
    
    private static Case createDummyCase(Id dummyPackageId, Id dummyBeverageId) {
        TEST_DummyCaseConfig    caseConfig                  = new TEST_DummyCaseConfig();
                                caseConfig.packageId        = dummyPackageId;
                                caseConfig.beverageId       = dummyBeverageId;
        
        return TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.MOCK);
    }
    
}