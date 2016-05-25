@isTest
private class ECICCaseCloseCancelValidationStratTest {
    private static final User                                   TEST_RUN_USER   = ECICRunUserTestHelper.create();
    private static final User                                   TEST_USER_AGENT = ECICRunUserTestHelper.create(ECICRunUserTestHelper.ES_INFOLINE_AGENT_PARAM);
    
    private static void strategyTest (Boolean isAdminCurrentUser) {
        prepareCustomSettings();
        
        User currentUser = isAdminCurrentUser ? TEST_RUN_USER : TEST_USER_AGENT;
        Case dummyCase = createClosedCase();
        Case newDummyCase = dummyCase.clone(true, true);
        newDummyCase.Risk_Type__c = 'Blackmail';
        
        Map<ID, Case> oldValuesMap = new Map<ID, Case> {dummyCase.Id => dummyCase};
        Map<ID, Case> newValuesMap = new Map<ID, Case> {newDummyCase.Id => newDummyCase};
        
        ECICCaseCloseCancelValidationStrategy  strategy = new ECICCaseCloseCancelValidationStrategy();
        Boolean result = false;
        System.runAs(currentUser) {
            Test.startTest();
            {
                result = strategy.OnBeforeUpdate(oldValuesMap, newValuesMap);
            }
            Test.stopTest();
        }
        
        Boolean expectedErrorValue = !isAdminCurrentUser;
        System.assertEquals(expectedErrorValue, ECICCaseCloseCancelValidationStrategy.isError);
        System.assertEquals(true, result);
    }
    
    private static testMethod void  currentUserAdminTest()       { strategyTest(true);   }
    private static testMethod void  currentUserNotAdminTest()    { strategyTest(false);  }
    
    private static void prepareCustomSettings() {
        insert new Case_Fields_Blacklist__c(Name = 'Risk_Type__c', API_field_name__c = 'Risk_Type__c', Field_Label__c = 'Risk Type');
    }
    
    private static Case createClosedCase() {
        TEST_DummyCaseConfig    caseConfig                  = new TEST_DummyCaseConfig();
                                caseConfig.status           = ECICCommonConstants.STATUS_CLOSED;
                                caseConfig.channelOfAnswer  = 'Phone';
                                caseConfig.qualityStatus    = 'Closed';
                                caseConfig.infolineStatus   = 'Closed';
        Case dummyCase = TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.REAL);
        return [SELECT Id, Status, isClosed, Risk_Type__c FROM Case WHERE Id =: dummyCase.Id];
    }
    
}