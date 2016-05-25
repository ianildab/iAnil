@isTest
private class ECICCaseStatusValidationStrategyTest {
    private static final User                               TEST_RUN_USER           = ECICRunUserTestHelper.create();
    private static final ECICCaseStatusValidationStrategy   STRATEGY                = new ECICCaseStatusValidationStrategy();
    
    static {
        ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
    }
    
    private static void onBeforeSingleUpdateTest(Boolean isOldCaseClosed, Boolean isNewStatusOpen, Boolean hasActionPlan) {
        Case dummyOldCase = createOldDummyCase (isOldCaseClosed);
        Case dummyNewCase = createNewDummyCase (dummyOldCase, isNewStatusOpen, hasActionPlan);
        
        Map<Id, Case> dummyOldCaseMap = new Map<Id, Case>(new List<Case>{ dummyOldCase });
        Map<Id, Case> dummyNewCaseMap = new Map<Id, Case>(new List<Case>{ dummyNewCase });
        
        Boolean result = null; 
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                result = STRATEGY.onBeforeUpdate(dummyOldCaseMap, dummyNewCaseMap);
            }
            Test.stopTest();
        }
        
        System.assertEquals( !(isOldCaseClosed && isNewStatusOpen && !hasActionPlan), result);
    }
    
    
    private static testMethod void allFalseOnBeforeSingleUpdateTest()                   { onBeforeSingleUpdateTest( false,  false,  false   ); }
    private static testMethod void hasActionPlanElseFalseOnBeforeSingleUpdateTest()     { onBeforeSingleUpdateTest( false,  false,  true    ); }
    private static testMethod void newOpenElseFalseOnBeforeSingleUpdateTest()           { onBeforeSingleUpdateTest( false,  true,   false   ); }
    private static testMethod void newOpenWithActionPlanOnBeforeSingleUpdateTest()      { onBeforeSingleUpdateTest( false,  true,   true    ); }
    private static testMethod void oldClosedElseFalseOnBeforeSingleUpdateTest()         { onBeforeSingleUpdateTest( true,   false,  false   ); }
    private static testMethod void oldClosedWithActionPlanOnBeforeSingleUpdateTest()    { onBeforeSingleUpdateTest( true,   false,  true    ); }
    private static testMethod void oldClosedNewOpenOnBeforeSingleUpdateTest()           { onBeforeSingleUpdateTest( true,   true,   false   ); }
    private static testMethod void allTrueOnBeforeSingleUpdateTest()                    { onBeforeSingleUpdateTest( true,   true,   true    ); }
    
    // -----------------------------------------------------------------------------------------------------------------------------
    
    private static void onBeforeMultipleUpdateTest (Boolean isFirstOldCaseClosed,  Boolean isFirstNewStatusOpen,  Boolean isFirstActionPlanNull,
                                                    Boolean isSecondOldCaseClosed, Boolean isSecondNewStatusOpen, Boolean isSecondActionPlanNull) {
        Case dummyOldCase1 = createOldDummyCase (isFirstOldCaseClosed);
        Case dummyOldCase2 = createOldDummyCase (isSecondOldCaseClosed);
        Case dummyNewCase1 = createNewDummyCase (dummyOldCase1, isFirstNewStatusOpen, isFirstActionPlanNull);
        Case dummyNewCase2 = createNewDummyCase (dummyOldCase2, isSecondNewStatusOpen, isSecondActionPlanNull);
        
        Map<Id, Case> dummyOldCaseMap = new Map<Id, Case>(new List<Case>{ dummyOldCase1, dummyOldCase2 });
        Map<Id, Case> dummyNewCaseMap = new Map<Id, Case>(new List<Case>{ dummyNewCase1, dummyNewCase2 });
        
        Boolean result = null; 
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                result = STRATEGY.onBeforeUpdate(dummyOldCaseMap, dummyNewCaseMap);
            }
            Test.stopTest();
        }
        
        System.assertEquals(true, result);
    }
    
    
    private static testMethod void atLeastOneTrueBatchModeTest() { onBeforeMultipleUpdateTest( true,   true,   false,
                                                                                               false,  true,   true   ); }
    // -----------------------------------------------------------------------------------------------------------------------------
    
    private static Case createOldDummyCase (Boolean isOldCaseClosed) {
        Case dummyOldCase = null;
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.status                  = (isOldCaseClosed) ? 'Closed' : 'Open';
                             config.skipStrategies          = true;
        
        if (isOldCaseClosed) {
            config.infolineStatus          = 'Closed';
            config.qualityStatus           = 'Closed';
            config.channelOfAnswer         = 'Phone';
            dummyOldCase = TEST_DummyQualityComplaintCaseFactory.create(config, TEST_DummyInsertModeEnum.REAL);
            dummyOldCase = [SELECT id, isClosed FROM Case WHERE id = :dummyOldCase.id];
        } else {
            dummyOldCase = TEST_DummyQualityComplaintCaseFactory.create(config, TEST_DummyInsertModeEnum.MOCK);
        }
        
        return dummyOldCase;
    }
        
    private static Case createNewDummyCase (Case dummyOldCase, Boolean isNewStatusOpen, Boolean hasActionPlan) {
        Case dummyNewCase                   = dummyOldCase.clone(false);
             dummyNewCase.id                = dummyOldCase.id;
             dummyNewCase.status            = (isNewStatusOpen) ? 'Open' : 'New';
             dummyNewCase.Action_Plan__c    = (hasActionPlan) ? ECICActionPlanTestHelper.createEmptyDummyActionPlan(true).id : null;
        
        return dummyNewCase;
    }
}