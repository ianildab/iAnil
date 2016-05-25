@isTest
private class ECICCaseHighPriorityIfHighRiskStratTest {
    public static  final User TEST_RUN_USER                             = ECICRunUserTestHelper.create();
    private static ECICCaseHighPriorityIfHighRiskStrategy dummyStrategy = new ECICCaseHighPriorityIfHighRiskStrategy();
    
    private static void triggerTest(Boolean isInsertTest, String riskValue) {
        Case dummyCase          = createDummyCase(riskValue);
        Boolean strategyResult  = null;
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                if (isInsertTest) {
                    strategyResult = dummyStrategy.OnBeforeInsert(new List<Case> { dummyCase });
                } else {
                    strategyResult = dummyStrategy.OnBeforeUpdate(new Map<ID, sObject>{ dummyCase.Id => dummyCase },
                                                                  new Map<ID, sObject>{ dummyCase.Id => dummyCase });
                }
            }
            Test.stopTest();
        }
        
        String expextedValue = (riskValue=='High Risk') ? 'High' : 'Medium';
        System.assertEquals (expextedValue, dummyCase.priority);
        System.assertEquals (true,          strategyResult);
    }
    
    private static testMethod void noRiskInsertTest()       { triggerTest (true, 'No Risk');        }
    private static testMethod void mediumRiskInsertTest()   { triggerTest (true, 'Medium Risk');    }
    private static testMethod void highRiskInsertTest()     { triggerTest (true, 'High Risk');      }
    
    private static testMethod void noRiskUpdateTest()       { triggerTest (false, 'No Risk');       }
    private static testMethod void mediumRiskUpdateTest()   { triggerTest (false, 'Medium Risk');   }
    private static testMethod void highRiskUpdateTest()     { triggerTest (false, 'High Risk');     }
    
    // -----------------------------------------------------------------------------------------------------------------------
    
    private static Case createDummyCase(String riskValue) {
        TEST_DummyCaseConfig caseConfig                 = new TEST_DummyCaseConfig();
                             caseConfig.potentialRisk   = riskValue;
                             caseConfig.riskType        = (riskValue != 'No Risk') ? 'Other' : '';
                             caseConfig.priority        = 'Medium';
        
        Case dummyCase              = TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.NONE);
        return dummyCase;
    }

}