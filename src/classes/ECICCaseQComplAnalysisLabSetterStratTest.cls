@isTest
private class ECICCaseQComplAnalysisLabSetterStratTest {
    private static final User    TEST_RUN_USER                                       = ECICRunUserTestHelper.create();
    private static final String  TEST_DUMMY_COUNTRY_CODE                             = 'TT';
    private static final ECICCaseQComplAnalysisLabSetterStrategy LAB_SETTER_STRATEGY = new ECICCaseQComplAnalysisLabSetterStrategy();
    
    private static void executeStrategyTest(Boolean isInsertTest, Boolean hasCountryLab) {
        Account dummyPlantsLaboratoryAccount = null;
        if (hasCountryLab) {
            dummyPlantsLaboratoryAccount = createDummyPlantsLaboratory(true);
            createTestCustomSettings(dummyPlantsLaboratoryAccount.Id);
        }
        
        Case dummyCase = createTestCase();
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                if (isInsertTest) {
                    LAB_SETTER_STRATEGY.OnBeforeInsert(new List<sObject>{ dummyCase });
                } else {
                    LAB_SETTER_STRATEGY.OnBeforeUpdate(new Map<ID, sObject>{ dummyCase.Id => dummyCase },
                                                       new Map<ID, sObject>{ dummyCase.Id => dummyCase } );
                }
            }
            Test.stopTest();
        }
        
        Id expectedResult = (hasCountryLab) ? dummyPlantsLaboratoryAccount.id : null;
        System.assertEquals (expectedResult, dummyCase.Laboratory_of_Analysis__c);
    }
    
    private static testMethod void  insertWithoutLabExecuteStrategyTest()       { executeStrategyTest (true,    false); }
    private static testMethod void  insertWithLabExecuteStrategyTest()          { executeStrategyTest (true,    true);  }
    private static testMethod void  updateWithoutLabExecuteStrategyTest()       { executeStrategyTest (false,   false); }
    private static testMethod void  updateWithLabExecuteStrategyTest()          { executeStrategyTest (false,   true);  }
    
    //-------------------------------------------------------------------------------------------------------------------
    
    private static Account createDummyPlantsLaboratory(Boolean insertNow) {
        TEST_DummyAccountFactory.Config accountConfig = new TEST_DummyAccountFactory.Config();
                                        accountConfig.isPerson       = false;
                                        accountConfig.Name           = ECICCommonConstants.ACCOUNT_BUSINESS_NAME;
                                        accountConfig.isActive       = true;
        
        Account dummyPlantsLaboratoryAccount = TEST_DummyAccountFactory.create(accountConfig, TEST_DummyInsertModeEnum.MOCK);
        return dummyPlantsLaboratoryAccount;
    }
    
    private static void createTestCustomSettings(Id labId) {
        TEST_DummyCountrySpecificSettingsFactory.Config countrySettingsConfig = new TEST_DummyCountrySpecificSettingsFactory.Config();
                                        countrySettingsConfig.countryCode                   = TEST_DUMMY_COUNTRY_CODE;
                                        countrySettingsConfig.laboratoryOfAnalysisAccountId = labId;
        
        TEST_DummyCountrySpecificSettingsFactory.create(countrySettingsConfig, true);
    }
    
    private static Case createTestCase() {
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.countryCode             = TEST_DUMMY_COUNTRY_CODE;
                             caseConfig.noQualityStatusChange   = false;
                             caseConfig.sampleCollected         = true;
        
        Case dummyCase              = TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.MOCK);
        return dummyCase;
    }
    
}