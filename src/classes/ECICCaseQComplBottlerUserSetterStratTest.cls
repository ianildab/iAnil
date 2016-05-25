@isTest
private class ECICCaseQComplBottlerUserSetterStratTest 
{
    private static final User                                    TEST_RUN_USER   = ECICRunUserTestHelper.create(); 
    private static final ECICCaseQComplBottlerUserSetterStrategy TARGET_STRATEGY = new ECICCaseQComplBottlerUserSetterStrategy();

    private static void buildQualityCasesForBottlerSpecificationListTest(String status)    
    {
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.status = status;
        Case       dummyCase     = TEST_DummyInquiryCaseFactory.create (config, TEST_DummyInsertModeEnum.NONE);                      
        List<Case> dummyCaseList = new List<Case>{ dummyCase };
        
        List<Case> resultQualityCasesForBottlerSpecificationList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultQualityCasesForBottlerSpecificationList = TARGET_STRATEGY.buildQualityCasesForBottlerSpecificationList(dummyCaseList);
            }
            Test.stopTest();
        }
        
        Set<String> unqualifiedStatusSet = new Set<String>{ ECICCommonConstants.STATUS_NEW, ECICCommonConstants.STATUS_CLOSED, ECICCommonConstants.STATUS_CANCELLED };
        Boolean     shouldBeAdded        = !unqualifiedStatusSet.contains(status);
        
        System.assertEquals((shouldBeAdded ? 1 : 0), resultQualityCasesForBottlerSpecificationList.size());
        if (shouldBeAdded) { System.assertEquals (dummyCase, resultQualityCasesForBottlerSpecificationList[0]); } 
    }    
    
    private static testMethod void newCaseBuildQualityCasesForBottlerSpecificationListTest()       { buildQualityCasesForBottlerSpecificationListTest(ECICCommonConstants.STATUS_NEW);       }    
    private static testMethod void closedCaseBuildQualityCasesForBottlerSpecificationListTest()    { buildQualityCasesForBottlerSpecificationListTest(ECICCommonConstants.STATUS_CLOSED);    }    
    private static testMethod void canceledCaseBuildQualityCasesForBottlerSpecificationListTest()  { buildQualityCasesForBottlerSpecificationListTest(ECICCommonConstants.STATUS_CANCELLED); }    
    private static testMethod void openCaseBuildQualityCasesForBottlerSpecificationListTest()      { buildQualityCasesForBottlerSpecificationListTest(ECICCommonConstants.STATUS_OPEN);      }    
    private static testMethod void escalatedCaseBuildQualityCasesForBottlerSpecificationListTest() { buildQualityCasesForBottlerSpecificationListTest(ECICCommonConstants.STATUS_ESCALATED); }    
    private static testMethod void resolvedCaseBuildQualityCasesForBottlerSpecificationListTest()  { buildQualityCasesForBottlerSpecificationListTest(ECICCommonConstants.STATUS_RESOLVED);  }    

    // --------------------------------------------------------------------------------------------------------------------------

    private static void buildBottlerRegionByIdMapTest(Boolean hasPlant)    
    {
        Region__c dummyRegionOfPurchase = createRegion();

        Plant__c  dummyPlant            = null;
        Region__c dummyPlantRegion      = null;
        if (hasPlant)
        {
            Map<String, SObject> dummyPlantSObjectMap = createDummyPlantSObjectMap();
            dummyPlant           = (Plant__c)  dummyPlantSObjectMap.get('plant');
            dummyPlantRegion     = (Region__c) dummyPlantSObjectMap.get('region');
        }
        
        Map<Id, Region__c> resultBottlerRegionByIdMap = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultBottlerRegionByIdMap = TARGET_STRATEGY.buildBottlerRegionByIdMap();
            }
            Test.stopTest();
        }
        
        System.assert(resultBottlerRegionByIdMap.containsKey(dummyRegionOfPurchase.id));
        System.assertEquals(dummyRegionOfPurchase, resultBottlerRegionByIdMap.get(dummyRegionOfPurchase.id));
        
        if (hasPlant)
        {
            System.assert(resultBottlerRegionByIdMap.containsKey(dummyPlant.id));
            System.assertEquals(dummyPlantRegion, resultBottlerRegionByIdMap.get(dummyPlant.id));
        }
    }    
    
    private static testMethod void withoutPlantBuildBottlerRegionByIdMapTest() { buildBottlerRegionByIdMapTest(false); }
    private static testMethod void withPlantBuildBottlerRegionByIdMapTest()    { buildBottlerRegionByIdMapTest(true);  }

    // --------------------------------------------------------------------------------------------------------------------------

    private static void fetchInactiveUsersTest(Boolean userIdNotNull, Boolean isUserActive)    
    {
        Id       dummyUserId                = createBottlerUser (isUserActive).id;
        List<Id> dummyRegionUserIdList      = userIdNotNull ? new List<Id>{ dummyUserId } : new List<Id>();  
        
        Set<ID>  resultInactiveUserIdSet = null; 
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultInactiveUserIdSet = TARGET_STRATEGY.fetchInactiveUsers(dummyRegionUserIdList); 
            }
            Test.stopTest();
        }
        
        System.assertEquals ( ((userIdNotNull) && (!isUserActive)), resultInactiveUserIdSet.contains(dummyUserId) );
    }    

    private static testMethod void notInRegionNotActiveFetchInactiveUsersTest() { fetchInactiveUsersTest(false, false); }
    private static testMethod void notInRegionActiveFetchInactiveUsersTest()    { fetchInactiveUsersTest(false, true);  }
    private static testMethod void inRegionNotActiveFetchInactiveUsersTest()    { fetchInactiveUsersTest(true,  false); }
    private static testMethod void inRegionActiveFetchInactiveUsersTest()       { fetchInactiveUsersTest(true,  true);  }

    // --------------------------------------------------------------------------------------------------------------------------

    private static void checkBottlerInRegionIdMapTest(
            Boolean invalidMapContainsRegion,  Boolean isQualityOwnerActiveUser, Boolean isQualityManagerActiveUser, Boolean isExternalRelationActiveUser
        )    
    {
        Region__c dummyRegion = createRegion (invalidMapContainsRegion, isQualityOwnerActiveUser, isQualityManagerActiveUser, isExternalRelationActiveUser);
        
        Boolean isCorrect = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                isCorrect = TARGET_STRATEGY.checkBottlerInRegionIdMap(dummyRegion);
            }
            Test.stopTest();
        }
        
        System.assertEquals (((!invalidMapContainsRegion) && (isQualityOwnerActiveUser && isQualityManagerActiveUser && isExternalRelationActiveUser)), isCorrect);
        System.assertEquals (!isCorrect, TARGET_STRATEGY.incorrectBottlerLookupIdSetByRegionIdMap.containsKey(dummyRegion.id));

        Set<Id> resultInvalidUserIdSet =  TARGET_STRATEGY.incorrectBottlerLookupIdSetByRegionIdMap.get(dummyRegion.id);
        if ((!invalidMapContainsRegion) && (resultInvalidUserIdSet != null))
        {
            System.assertEquals(!isQualityOwnerActiveUser,     resultInvalidUserIdSet.contains(dummyRegion.bottler_quality__c));
            System.assertEquals(!isQualityManagerActiveUser,   resultInvalidUserIdSet.contains(dummyRegion.bottler_quality_manager__c));
            System.assertEquals(!isExternalRelationActiveUser, resultInvalidUserIdSet.contains(dummyRegion.bottler_external_relations__c));
        }
    }    

    private static testMethod void noneActiveCheckBottlerInRegionIdMapTest()                    { checkBottlerInRegionIdMapTest( false,  false,  false,  false   ); }
    private static testMethod void externalActiveCheckBottlerInRegionIdMapTest()                { checkBottlerInRegionIdMapTest( false,  false,  false,  true    ); }
    private static testMethod void managerActiveCheckBottlerInRegionIdMapTest()                 { checkBottlerInRegionIdMapTest( false,  false,  true,   false   ); }
    private static testMethod void ownerActiveCheckBottlerInRegionIdMapTest()                   { checkBottlerInRegionIdMapTest( false,  true,   false,  false   ); }
    private static testMethod void allActiveCheckBottlerInRegionIdMapTest()                     { checkBottlerInRegionIdMapTest( false,  true,   true,   true    ); }
    private static testMethod void regionInInvalidMapNoneActiveCheckBottlerInRegionIdMapTest()  { checkBottlerInRegionIdMapTest( true,   false,  false,  false   ); }
    private static testMethod void regionInInvalidMapAllActiveCheckBottlerInRegionIdMapTest()   { checkBottlerInRegionIdMapTest( true,   true,   true,   true    ); }
        
    // --------------------------------------------------------------------------------------------------------------------------

    private static void setCaseFieldsTest(Boolean isRegionNull, Boolean isBottlerPrefix)    
    {
        Case        dummyCase        = TEST_DummyInquiryCaseFactory.create(TEST_DummyInsertModeEnum.NONE);
        Region__c   dummyRegion      = createRegion (false, true, true, true); 
        String      dummyFieldPrefix = (IsBottlerPrefix) ? 'Bottler' : 'Distributor';
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_STRATEGY.setCaseFields (dummyCase, dummyRegion, dummyFieldPrefix);
            }
            Test.stopTest();
        }
        
        System.assertEquals ((!isRegionNull) ? dummyRegion.Bottler_Quality__c            : null, dummyCase.get(dummyFieldPrefix + '_Quality' + (isBottlerPrefix?'_Owner':'')+'__c'));
        System.assertEquals ((!isRegionNull) ? dummyRegion.Bottler_Quality_Manager__c    : null, dummyCase.get(dummyFieldPrefix + '_Quality_Manager__c'));
        System.assertEquals ((!isRegionNull) ? dummyRegion.Bottler_External_Relations__c : null, dummyCase.get(dummyFieldPrefix + '_External_Relations__c'));
    }    
    
    private static void nullRegionDistributorSetCaseFieldsTest() { setCaseFieldsTest (false, false); }
    private static void nullRegionBottlerSetCaseFieldsTest()     { setCaseFieldsTest (false, true ); }
    private static void hasRegionDistributorSetCaseFieldsTest()  { setCaseFieldsTest (true,  false); }
    private static void hasRegionBottlerSetCaseFieldsTest()      { setCaseFieldsTest (true,  true ); }
        
    // --------------------------------------------------------------------------------------------------------------------------

    private static testMethod void specifyBottlers2Test()    
    {
        Region__c dummyRegionOfPurchase = createRegion();

        Map<String, SObject> dummyPlantSObjectMap = createDummyPlantSObjectMap();
        Plant__c  dummyPlant        = (Plant__c)  dummyPlantSObjectMap.get('plant');
        Region__c dummyPlantRegion  = (Region__c) dummyPlantSObjectMap.get('region');
        
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.plantId            = dummyPlant.id;
                             config.regionOfPurchaseId = dummyRegionOfPurchase.id; 
        Case  dummyCase = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE);
        
        ECICCaseQComplBottlerUserSetterStrategy targetStrategy = new ECICCaseQComplBottlerUserSetterStrategy();
                                                targetStrategy.bottlerRegionByIdMap = new Map<Id, Region__c>
                                                    {
                                                        dummyRegionOfPurchase.id => dummyRegionOfPurchase,
                                                        dummyPlant.id            => dummyPlantRegion
                                                    };
        System.runAs(TEST_RUN_USER)
            {
            Test.startTest();
            {
                targetStrategy.specifyBottlers (dummyCase);
        }
            Test.stopTest();
        }

        assertUserSet (dummyPlantRegion, dummyRegionOfPurchase, dummyCase, true, true);
    }    

    // --------------------------------------------------------------------------------------------------------------------------
        
    private static testMethod void processIncorrectBottlerLookupIdsTest()    
    {
        Id       dummyRegionId = 'a2C11000000Cjix';
        Id       dummyUserId   = '00520000001qmXm';
        TARGET_STRATEGY.incorrectBottlerLookupIdSetByRegionIdMap.put (dummyRegionId, new Set<Id>{ dummyUserId });
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_STRATEGY.processIncorrectBottlerLookupIds();
            }
            Test.stopTest();
        }
        
        assertEmailMessage (dummyRegionId, dummyUserId);
    }    
    
    // --------------------------------------------------------------------------------------------------------------------------
        
    private static void specifyBottlers1Test(Boolean bottlerMapNotEmpty, Boolean hasIncorrectLookups)    
    {
        Plant__c  dummyPlant            = null;
        Region__c dummyRegionOfPurchase = null;
        Region__c dummyPlantRegion      = null; 
        if (bottlerMapNotEmpty)
        {
            dummyRegionOfPurchase = createRegion(!hasIncorrectLookups);
    
            Map<String, SObject> dummyPlantSObjectMap = createDummyPlantSObjectMap();
                                 dummyPlant           = (Plant__c)  dummyPlantSObjectMap.get('plant');
                                 dummyPlantRegion     = (Region__c) dummyPlantSObjectMap.get('region');
        }
        
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.plantId            = bottlerMapNotEmpty ? dummyPlant.id             : 'a0G110000000atg';
                             config.regionOfPurchaseId = bottlerMapNotEmpty ? dummyRegionOfPurchase.id  : 'a2C11000000Cjix'; 
        Case  dummyCase = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE);
        
        ECICCaseQComplBottlerUserSetterStrategy targetStrategy = new ECICCaseQComplBottlerUserSetterStrategy();
        if (bottlerMapNotEmpty) 
        {
                                                targetStrategy.bottlerRegionByIdMap = new Map<Id, Region__c>
                                                    {
                                                        dummyRegionOfPurchase.id => dummyRegionOfPurchase,
                                                        dummyPlant.id            => dummyPlantRegion
                                                    };
        }
                                                            
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                targetStrategy.specifyBottlers (new List<Case>{ dummyCase });
            }
            Test.stopTest();
        }


        if (bottlerMapNotEmpty)  { assertUserSet (dummyPlantRegion, dummyRegionOfPurchase, dummyCase, (bottlerMapNotEmpty), (bottlerMapNotEmpty && !hasIncorrectLookups)); }
        if (hasIncorrectLookups) { assertEmailMessage (dummyRegionOfPurchase.id, dummyRegionOfPurchase.Bottler_Quality__c); }
    }    

    private static testMethod void noMapSpecifyBottlers1Test()          { specifyBottlers1Test (false, false);  }    
    private static testMethod void mapSpecifyBottlers1Test()            { specifyBottlers1Test (true,  false);  }    
    private static testMethod void mapWithErrorsSpecifyBottlers1Test()  { specifyBottlers1Test (true,  true);   }    

    // --------------------------------------------------------------------------------------------------------------------------

    private static void executeTest(Boolean needsUsersSet)    
    {
        Region__c dummyRegionOfPurchase = createRegion(true);

        Map<String, SObject> dummyPlantSObjectMap = createDummyPlantSObjectMap();
        Plant__c             dummyPlant           = (Plant__c)  dummyPlantSObjectMap.get('plant');
        Region__c            dummyPlantRegion     = (Region__c) dummyPlantSObjectMap.get('region');

        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.status             = needsUsersSet ? ECICCommonConstants.STATUS_OPEN : ECICCommonConstants.STATUS_CLOSED; 
                             config.plantId            = dummyPlant.id;
                             config.regionOfPurchaseId = dummyRegionOfPurchase.id; 
        Case  dummyCase = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE);
        
        ECICCaseQComplBottlerUserSetterStrategy targetStrategy = new ECICCaseQComplBottlerUserSetterStrategy();
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                targetStrategy.execute (new List<Case>{ dummyCase });
            }
            Test.stopTest();
        }

        assertUserSet (dummyPlantRegion, dummyRegionOfPurchase, dummyCase, needsUsersSet, needsUsersSet);
    }    

    private static testMethod void doesntNeedUsersExecuteTest()  { executeTest (false);  }    
    private static testMethod void needsUsersExecuteTest()       { executeTest (true);   }    

    // --------------------------------------------------------------------------------------------------------------------------

        
    private static void onBeforeMethodTest(Boolean isInsertTest, Boolean isQualityComplaint)    
    {
        Region__c dummyRegionOfPurchase = createRegion(true);

        Map<String, SObject> dummyPlantSObjectMap = createDummyPlantSObjectMap();
        Plant__c             dummyPlant           = (Plant__c)  dummyPlantSObjectMap.get('plant');
        Region__c            dummyPlantRegion     = (Region__c) dummyPlantSObjectMap.get('region');

        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             /*#CICTemplateTest*/
                             config.recordTypeId       = TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(isQualityComplaint ? ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME : ECICCommonConstants.INQUIRY_IBERIA_DEVNAME);
                             config.status             = ECICCommonConstants.STATUS_OPEN; 
                             config.plantId            = dummyPlant.id;
                             config.regionOfPurchaseId = dummyRegionOfPurchase.id; 
        Case  dummyCase = TEST_DummyInquiryCaseFactory.create(config, (isInsertTest) ? TEST_DummyInsertModeEnum.NONE : TEST_DummyInsertModeEnum.MOCK);
        
        ECICCaseQComplBottlerUserSetterStrategy targetStrategy = new ECICCaseQComplBottlerUserSetterStrategy();
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                if (isInsertTest) { targetStrategy.onBeforeInsert (      new List<Case>   { dummyCase                 }); }
                else              { targetStrategy.onBeforeUpdate (null, new Map<Id, Case>{ dummyCase.id => dummyCase }); } // Old values would be ignored.
            }
            Test.stopTest();
        }

        assertUserSet (dummyPlantRegion, dummyRegionOfPurchase, dummyCase, isQualityComplaint, isQualityComplaint);
    }    

    private static testMethod void inquiryInsertBeforeMethodTest()          { onBeforeMethodTest (true,  false);  }    
    private static testMethod void qualityInsertBeforeMethodTest()          { onBeforeMethodTest (true,  true );  }
    private static testMethod void inquiryUpdateBeforeMethodTest()          { onBeforeMethodTest (false, false);  }    
    private static testMethod void qualityUpdateBeforeMethodTest()          { onBeforeMethodTest (false, true );  }    

    // ---------------------------------------------------------------------------------------------------------------------------
        
    private static User createBottlerUser (Boolean isActive)
    {
        User dummyUser = new User();
        TEST_MockHelper.mockInsert(dummyUser);
        if (isActive) { ECICCaseTriggerUserCache.activeBottlerUserByIdCache.put(dummyUser.id, dummyUser); }
        return dummyUser;
    }
    
    private static Region__c createRegion (Boolean invalidMapContainsRegion,  Boolean isQualityOwnerActiveUser, Boolean isQualityManagerActiveUser, Boolean isExternalRelationActiveUser)
    {
        Id dummyQualityOwnerUserId      = createBottlerUser(isQualityOwnerActiveUser).id;
        Id dummyQualityManagerUserId    = createBottlerUser(isQualityManagerActiveUser).id;
        Id dummyExternalRelationsUserId = createBottlerUser(isExternalRelationActiveUser).id;
        
        TEST_DummyRegionFactory.Config config = new TEST_DummyRegionFactory.Config(); 
                                       config.qualityOwnerUserId        = dummyQualityOwnerUserId;
                                       config.qualityManagerUserId      = dummyQualityManagerUserId;
                                       config.externalRelationsUserId   = dummyExternalRelationsUserId;
        Region__c dummyRegion = TEST_DummyRegionFactory.create(config, TEST_DummyInsertModeEnum.MOCK);
        if (invalidMapContainsRegion) { TARGET_STRATEGY.incorrectBottlerLookupIdSetByRegionIdMap.put (dummyRegion.id, new Set<Id>()); }
        return dummyRegion;
    }

    private static Region__c createRegion(Boolean areUsersActive)
    {
        Region__c dummyRegion = createRegion (false, areUsersActive, areUsersActive, areUsersActive);
        ECICCaseTriggerRegionCache.regionByIdCache.put (dummyRegion.id, dummyRegion);
        return dummyRegion;
    }
    
    private static Region__c createRegion() { return createRegion(true); }
    
    private static Map<String, SObject> createDummyPlantSObjectMap()
    {
        Plant__c  dummyPlant       = TEST_DummyPlantFactory.create (TEST_DummyInsertModeEnum.MOCK);
        Region__c dummyPlantRegion = createRegion (false, true, true, true);
                  dummyPlant.Region__r = dummyPlantRegion;
        ECICCaseTriggerPlantCache.plantByIdCache.put (dummyPlant.id, dummyPlant);
        
        return new Map<String, SObject>
        {
            'plant'    => dummyPlant,
            'region'   => dummyPlantRegion
        };
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------
    
    private static void assertEmailMessage (Id dummyRegionId, Id dummyUserId)
    {
        List<Messaging.SingleEmailMessage> resultEmailMessageList = ECICCaseTriggerEmailMessageCache.emailMessagesToSendCache;
        System.assertEquals (1, resultEmailMessageList.size());
        
        Messaging.SingleEmailMessage resultEmailMessage = resultEmailMessageList[0];
        
        String         subject = resultEmailMessage.getSubject();
        System.assert (subject.contains(System.label.User_Lookup_Alert_Subject));

        String         body = resultEmailMessage.getPlainTextBody();
        System.assert (body.contains(System.label.region));
        System.assert (body.contains(dummyRegionId));
        System.assert (body.contains(System.label.users));
        System.assert (body.contains(dummyUserId));
    }

    private static void assertUserSet (Region__c dummyPlantRegion, Region__c dummyRegionOfPurchase, Case dummyCase, Boolean bottlersSet, Boolean distributorsSet)
    {
        System.assertEquals ((bottlersSet)     ? dummyPlantRegion.Bottler_Quality__c                 : null, dummyCase.Bottler_Quality_Owner__c);
        System.assertEquals ((bottlersSet)     ? dummyPlantRegion.Bottler_Quality_Manager__c         : null, dummyCase.Bottler_Quality_Manager__c);
        System.assertEquals ((bottlersSet)     ? dummyPlantRegion.Bottler_External_Relations__c      : null, dummyCase.Bottler_External_Relations__c);
        System.assertEquals ((distributorsSet) ? dummyRegionOfPurchase.Bottler_Quality__c            : null, dummyCase.Distributor_Quality__c);
        System.assertEquals ((distributorsSet) ? dummyRegionOfPurchase.Bottler_Quality_Manager__c    : null, dummyCase.Distributor_Quality_Manager__c);
        System.assertEquals ((distributorsSet) ? dummyRegionOfPurchase.Bottler_External_Relations__c : null, dummyCase.Distributor_External_Relations__c);
    }
}