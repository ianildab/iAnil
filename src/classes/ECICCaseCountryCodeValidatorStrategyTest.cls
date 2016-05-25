@isTest // commented this whole class since we are not using the related strategy.
public class ECICCaseCountryCodeValidatorStrategyTest {/* comment block 1 start
    public  static final User                       TEST_RUN_USER           = ECICRunUserTestHelper.create(); 
    private static ECICCaseCountryCodeValidatorStrategy targetStrategy      = new ECICCaseCountryCodeValidatorStrategy();
    public  static final String VALIDATION_STRATEGY_TEST                    = 'Case Country Code Validation Strategy Test'; 
    
    private static void strategyTest (Boolean isInsertTest, Boolean isUserCountryCodeValid, Boolean isCaseCountryCodeValid) {
        User   dummyUser = createDummyUser (isUserCountryCodeValid, true);
        Case   dummyCase = createDummyCase (isCaseCountryCodeValid, dummyUser, true);
        
        ECICCaseTriggerUserCache.populate (new List<Case>{dummyCase});
        Boolean strategyResult = null;
        System.runAs (dummyUser) {
            Test.startTest();
            {
                if (isInsertTest) {
                    strategyResult = targetStrategy.OnBeforeInsert(new List<Case>{ dummyCase } );
                } else {
                    strategyResult = targetStrategy.OnBeforeUpdate(new Map<ID, sObject>{ dummyCase.Id => dummyCase },
                                                                   new Map<ID, sObject>{ dummyCase.Id => dummyCase } );
                }
            }
            Test.stopTest();
        }
        
        Boolean expectedResult = null;
        if(isInsertTest) {
            expectedResult = (!isUserCountryCodeValid && isCaseCountryCodeValid) || (isUserCountryCodeValid && isCaseCountryCodeValid);
        } else {
            Set<String> enabledCountriesSet = getCurrentUsersEnabledCountries(dummyUser);
            expectedResult = !(!String.isBlank(dummyCase.Country_code__c) && !enabledCountriesSet.contains(dummyCase.Country_code__c));
        }
        
        System.assertEquals (expectedResult, strategyResult); 
    }
    
    private static testMethod void caseNotValidBeforeInsertTest()               { strategyTest(true, true,  false);   }
    private static testMethod void bothNotValidBeforeInsertTest()               { strategyTest(true, false, false);   }
    private static testMethod void userNotValidBeforeInsertTest()               { strategyTest(true, false, true);    }
    private static testMethod void bothValidBeforeInsertTest()                  { strategyTest(true, true,  true);    }
    
    private static testMethod void caseNotValidBeforeUpdateValidUpdateTest()    { strategyTest(false, true,  false);  }
    private static testMethod void bothNotValidBeforeUpdateTest()               { strategyTest(false, false, false);  }
    private static testMethod void userNotValidBeforeUpdateTest()               { strategyTest(false, false, true);   }
    private static testMethod void bothValidBeforeUpdateTest()                  { strategyTest(false, true,  true);   }
    
    
    private static void emptyEnabledCountriesTest(Boolean isInsertTest) {
        User   dummyUser = createDummyUser (true, false, true);
        Case   dummyCase = createDummyCase (true, dummyUser, true);
        
        ECICCaseTriggerUserCache.populate (new List<Case>{dummyCase});
        Boolean strategyResult = null;
        System.runAs (dummyUser) {
            if (isInsertTest) {
                strategyResult = targetStrategy.OnBeforeInsert(new List<Case>{ dummyCase } );
            } else {
                strategyResult = targetStrategy.OnBeforeUpdate(new Map<ID, sObject>{ dummyCase.Id => dummyCase },
                                                               new Map<ID, sObject>{ dummyCase.Id => dummyCase } );
            }
        }

        if (SEPProfileCache.isUserAdmin(dummyUser)) {
            System.assertEquals (true, strategyResult); 
        } else {
            System.assertEquals (false, strategyResult); 
        }
    }
    
    private static testMethod void emptyEnabledCountriesInsertTest()            { emptyEnabledCountriesTest(true);   }
    private static testMethod void emptyEnabledCountriesUpdateTest()            { emptyEnabledCountriesTest(false);  }
    
    //--------------------------------------------------------------------------------------------------------------------------------------
    
    private static User createDummyUser (Boolean isUserCountryCodeValid, Boolean isUserCountryCodeEnabled, Boolean insertNow) {
           User   dummyUser                         = ECICRunUserTestHelper.create(ECICCommonConstants.PROFILE_SYSTEM_ADMIN, false);
                  dummyUser.country_code__c         = (isUserCountryCodeValid) ? 'UK' : null; 
                  dummyUser.Enabled_Countries__c    = (isUserCountryCodeEnabled) ? 'UK;ES;' : null;
           if (insertNow) { System.runAs(TEST_RUN_USER) { insert dummyUser; } }
           return dummyUser;
    }
    
    private static User createDummyUser (Boolean isUserCountryCodeValid, Boolean insertNow) {
        return createDummyUser (isUserCountryCodeValid, true, insertNow);
    }
    
    private static Case createDummyCase(Boolean isCountryCodeValid, User ownerUser, Boolean isInsert) {
        TEST_DummyCaseConfig caseConfig                 = new TEST_DummyCaseConfig();
                             caseConfig.subject         = VALIDATION_STRATEGY_TEST; 
                             caseConfig.countryCode     = (isCountryCodeValid) ? 'ES' : TEST_ConfigHelper.INTENTIONAL_NULL;
                             caseConfig.ownerId         = ownerUser.Id;
        
        Case dummyCase              = TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, (isInsert) ? TEST_DummyInsertModeEnum.MOCK : TEST_DummyInsertModeEnum.NONE);
        return dummyCase;
    }
    
    private static Set<String> getCurrentUsersEnabledCountries(User currentUser) {
        Set<String> enabledCountryNameSet = new Set<String>();
        if (currentUser.Enabled_Countries__c != null) {
            enabledCountryNameSet.addAll(currentUser.Enabled_Countries__c.split(';'));
        }
        return enabledCountryNameSet;
    }
    comment block 1 end */
}