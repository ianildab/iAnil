@isTest
private class ECICCaseInfolineStatusSetterStrategyTest 
{
    private static final Map<String,User> USER_BY_PROFILE_MAP = ECICRunUserTestHelper.createMap(new List<String>{
                                                                                                                    ECICCommonConstants.PROFILE_SYSTEM_ADMIN, 
                                                                                                                    ECICCommonConstants.PROFILE_ECIC_IBERIA_COCA_COLA_QUALITY, 
                                                                                                                    ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT
                                                                                                                }); //#CICTemplateTest
                                                                                                                
    private static final User             TEST_RUN_USER       = USER_BY_PROFILE_MAP.get(ECICCommonConstants.PROFILE_SYSTEM_ADMIN);
    
    private static final ECICCaseInfolineStatusSetterStrategy DUMMY_STRATEGY = new ECICCaseInfolineStatusSetterStrategy(); 

    private static void setInfolineStatusTest(Boolean ownerHasKOQualityProfile, Boolean originIsCommercial, Boolean infolineStatusIsNull) 
    {
         User dummyOwnerUser = (ownerHasKOQualityProfile)
                                ? USER_BY_PROFILE_MAP.get(ECICCommonConstants.PROFILE_ECIC_IBERIA_COCA_COLA_QUALITY)
                                : USER_BY_PROFILE_MAP.get(ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT);
         DUMMY_STRATEGY.userByIdMap = new Map<Id, User>{ dummyOwnerUser.id => dummyOwnerUser };       //#CICTemplateTest                      
         
         Case dummyCase = createCase(
                                        ((originIsCommercial)   ? 'Commercial Dept.' : 'Phone'),
                                        ((infolineStatusIsNull) ? TEST_ConfigHelper.INTENTIONAL_NULL : ECICCommonConstants.STATUS_NEW),
                                        dummyOwnerUser.id
                                    );
         
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                DUMMY_STRATEGY.setInfolineStatus(dummyCase);
            }
            Test.stopTest();
         }
         
         String expectedStatus =  (originIsCommercial && ownerHasKOQualityProfile)
                                        ? null
                                        : (  infolineStatusIsNull ? ECICCommonConstants.STATUS_OPEN : ECICCommonConstants.STATUS_NEW );
                                          
         System.assertEquals (expectedStatus, dummyCase.Infoline_Status__c);
    }
    
    private static testMethod void nothingTrueSetInfolineStatusTest()                                                    { setInfolineStatusTest(false, false, false); }
    private static testMethod void infolineStatusIsNullSetInfolineStatusTest()                                           { setInfolineStatusTest(false, false, true);  }
    private static testMethod void originIsCommercialSetInfolineStatusTest()                                             { setInfolineStatusTest(false, true,  false); }
    private static testMethod void originIsCommercialInfolineStatusIsNullSetInfolineStatusTest()                         { setInfolineStatusTest(false, true,  true);  }
    private static testMethod void ownerHasKOQualityProfileSetInfolineStatusTest()                                       { setInfolineStatusTest(true,  false, false); }
    private static testMethod void ownerHasKOQualityProfileInfolineStatusIsNullSetInfolineStatusTest()                   { setInfolineStatusTest(true,  false, true);  }
    private static testMethod void ownerHasKOQualityProfileOriginIsCommercialSetInfolineStatusTest()                     { setInfolineStatusTest(true,  true,  false); }
    private static testMethod void ownerHasKOQualityProfileOriginIsCommercialInfolineStatusIsNullSetInfolineStatusTest() { setInfolineStatusTest(true,  true,  true);  }

    // ------------------------------------------------------------------------------------------------------


    private static void executeTest(Boolean userInCache, Boolean ownerIsUser, Boolean ownerUserInCache) 
    {
         if (userInCache) { ECICCaseTriggerUserCache.userByIdCache.put (TEST_RUN_USER.id, TEST_RUN_USER); }
         
         Id   dummyOwnerId   = (Id) (ECICCaseHelper.GROUP_OBJECT_ID_PREFIX + '11000001FTZs');   // Will be overwritten if ownerIsUser.
         
         User dummyOwnerUser = null;
         if (ownerIsUser)
         {
            dummyOwnerUser = USER_BY_PROFILE_MAP.get(ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT); //#CICTemplateTest
            dummyOwnerId   = dummyOwnerUser.id;
            if (userInCache && ownerUserInCache) { ECICCaseTriggerUserCache.userByIdCache.put (dummyOwnerUser.id, dummyOwnerUser); }
         }
        
         Case dummyCase = createCase('Phone', TEST_ConfigHelper.INTENTIONAL_NULL, dummyOwnerId);
         
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                DUMMY_STRATEGY.execute(new List<Case>{ dummyCase });
            }
            Test.stopTest();
         }
         
         String expectedStatus =  (ownerIsUser && ownerUserInCache) ? ECICCommonConstants.STATUS_OPEN : null;
         System.assertEquals (expectedStatus, dummyCase.Infoline_Status__c);
    }
    
    private static testMethod void noUserExecuteTest()                          { executeTest(false, false, false); }
    private static testMethod void ownerIsUserExecuteTest()                     { executeTest(false, true,  false); }
    private static testMethod void userInCacheGroupOwnerExecuteTest()           { executeTest(true,  false, false); }
    private static testMethod void userInCacheOwnerIsDifferentUserExecuteTest() { executeTest(true,  true,  false); }
    private static testMethod void ownerIsAUserInCacheExecuteTest()             { executeTest(true,  true,  true);  }

    // ------------------------------------------------------------------------------------------------------

    private static testMethod void onBeforeInsertTest() 
    {
         User dummyOwnerUser = USER_BY_PROFILE_MAP.get(ECICCommonConstants.PROFILE_ECIC_IBERIA_COCA_COLA_QUALITY); //#CICTemplateTest
         ECICCaseTriggerUserCache.userByIdCache.put (dummyOwnerUser.id, dummyOwnerUser); 
        
         Case dummyCase = createCase('Web', TEST_ConfigHelper.INTENTIONAL_NULL, dummyOwnerUser.id);

         Boolean result = null;      
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                result = DUMMY_STRATEGY.onBeforeInsert(new List<Case>{ dummyCase });
            }
            Test.stopTest();
         }
         
         System.assertEquals (ECICCommonConstants.STATUS_OPEN, dummyCase.Infoline_Status__c);
    }

    // ------------------------------------------------------------------------------------------------------

    private static testMethod void onBeforeUpdateTest() 
    {
         User dummyOwnerUser = USER_BY_PROFILE_MAP.get(ECICCommonConstants.PROFILE_SYSTEM_ADMIN);
         ECICCaseTriggerUserCache.userByIdCache.put (dummyOwnerUser.id, dummyOwnerUser); 
        
         Case dummyNewCase = createCase('Email', TEST_ConfigHelper.INTENTIONAL_NULL, dummyOwnerUser.id);
         TEST_MockHelper.mockInsert(dummyNewCase);

         Boolean result = null;      
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                result = DUMMY_STRATEGY.onBeforeUpdate(null, new Map<Id, Case>{ dummyNewCase.id => dummyNewCase }); // Old Case Map is ignored.
            }
            Test.stopTest();
         }
         
         System.assertEquals (ECICCommonConstants.STATUS_OPEN, dummyNewCase.Infoline_Status__c);
    }

    // ------------------------------------------------------------------------------------------------------

    private static Case createCase(String origin, String infolineStatus, Id ownerId)
    {
         TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                              config.origin         = origin;
                              config.infolineStatus = infolineStatus;
                              config.ownerUserId    = ownerId;
         return TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE);
    }

}