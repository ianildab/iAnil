@isTest
private class ECICRegionTriggerHandlerTest {
    private static final User                       TEST_RUN_USER           = ECICRunUserTestHelper.create();
    private static final ECICRegionTriggerHandler   REGION_TRIGGER_HANDLER  = new ECICRegionTriggerHandler(false);
    
    private static void beforeInsertUpdateTest(Boolean isInsertTest) {
        Region__c   dummyRegion         = TEST_DummyRegionFactory.create(TEST_DummyInsertModeEnum.MOCK);
                    dummyRegion.OwnerId = TEST_RUN_USER.Id;
        Region__c   oldDummyRegion  = (isInsertTest) ? null : cloneRegion(dummyRegion);
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                if (isInsertTest) {
                    REGION_TRIGGER_HANDLER.OnBeforeInsert(new List<Region__c>{ dummyRegion });
                } else {
                    REGION_TRIGGER_HANDLER.OnBeforeUpdate(  null, 
                                                            new List<Region__c>     { dummyRegion },
                                                            new Map<ID, Region__c>  { oldDummyRegion.Id => oldDummyRegion },
                                                            null    );
                }
            }
            Test.stopTest();
        }
        
        system.assertEquals(TEST_RUN_USER.Id,               dummyRegion.Owner_Lookup__c);
        system.assertEquals(TEST_RUN_USER.Country_Code__c,  dummyRegion.Country_Code__c);
    }
    
    private static testMethod void OnBeforeInsertTest() { beforeInsertUpdateTest(true);     }
    private static testMethod void OnBeforeUpdateTest() { beforeInsertUpdateTest(false);    }
    
    //------------------------------------------------------------------------------------------------------------
    
    private static testMethod void afterUpdateTest() {
        Region__c   dummyRegion         = TEST_DummyRegionFactory.create(TEST_DummyInsertModeEnum.MOCK);
                    dummyRegion.OwnerId = TEST_RUN_USER.Id;
        Region__c   oldDummyRegion      = cloneRegion(dummyRegion);
        
        changeRegionBottlerFields(dummyRegion);
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                REGION_TRIGGER_HANDLER.OnAfterUpdate(   null, 
                                                        new List<Region__c>     { dummyRegion },
                                                        new Map<ID, Region__c>  { oldDummyRegion.Id => oldDummyRegion },
                                                        null    );
            }
            Test.stopTest();
        }
    }
    
    //------------------------------------------------------------------------------------------------------------
    
    private static Region__c cloneRegion(Region__c dummyRegion) {
        return dummyRegion.clone(true, true);
    }
    
    //------------------------------------------------------------------------------------------------------------
    
    private static void filterActiveBottlerUsersInRegionsTest(Boolean isActiveUserTest) {
        TEST_DummyUserFactory.Config    userConfig                              = new TEST_DummyUserFactory.Config(TEST_DummyUserFactory.ES_KO_QUALITY_MANAGER);
                                        userConfig.isActive                     = isActiveUserTest;
        User        dummyUser       = TEST_DummyUserFactory.create(userConfig, TEST_DummyInsertModeEnum.REAL);
        
        TEST_DummyRegionFactory.Config  regionConfig                            = new TEST_DummyRegionFactory.Config();
                                        regionConfig.qualityManagerUserId       = dummyUser.Id;
                                        regionConfig.externalRelationsUserId    = dummyUser.Id;
                                        regionConfig.qualityOwnerUserId         = dummyUser.Id;
        Region__c   dummyRegion     = TEST_DummyRegionFactory.create(regionConfig, TEST_DummyInsertModeEnum.MOCK);
        
        Set<ID> resultIdSet = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                resultIdSet = REGION_TRIGGER_HANDLER.filterActiveBottlerUsersInRegions(new List<Region__c> {dummyRegion});
            }
            Test.stopTest();
        }
        
        Integer expectedSetSize = isActiveUserTest ? 1 : 0;
        Boolean expectedContent = isActiveUserTest;
        
        System.assertEquals(expectedSetSize, resultIdSet.size());
        System.assertEquals(expectedContent, resultIdSet.contains(dummyUser.Id));
    }
    
    private static testMethod void filterActiveBottlerUsersInRegionsTest()      { filterActiveBottlerUsersInRegionsTest(true);  }
    private static testMethod void filterNotActiveBottlerUsersInRegionsTest()   { filterActiveBottlerUsersInRegionsTest(false); }
    
    //------------------------------------------------------------------------------------------------------------
    
    private static void filterBottlerUpdatedRegionsTest(Boolean isUpdatedFieldsTest) {
        Region__c   dummyRegion     = TEST_DummyRegionFactory.create(TEST_DummyInsertModeEnum.MOCK);
        Region__c   oldDummyRegion  = cloneRegion(dummyRegion);
        
        if (isUpdatedFieldsTest) {
            changeRegionBottlerFields(dummyRegion);
        }
        
        Map<ID, Region__c> resultMap = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                resultMap = REGION_TRIGGER_HANDLER.filterBottlerUpdatedRegions(new List<Region__c>      {dummyRegion},
                                                                               new Map<ID, Region__c>   {oldDummyRegion.Id => oldDummyRegion});
            }
            Test.stopTest();
        }
        
        Integer expectedMapSize = isUpdatedFieldsTest ? 1 : 0;
        Boolean expectedContent = isUpdatedFieldsTest;
        
        System.assertEquals(expectedMapSize,    resultMap.size());
        System.assertEquals(expectedContent,    resultMap.containsKey(dummyRegion.Id));
    }
    
    private static testMethod void filterBottlerUpdatedRegionsTest()      { filterActiveBottlerUsersInRegionsTest(true);  }
    private static testMethod void filterBottlerNotUpdatedRegionsTest()   { filterActiveBottlerUsersInRegionsTest(false); }
    
    private static void changeRegionBottlerFields(Region__c dummyRegion) {
        User    dummyUser       = TEST_DummyUserFactory.create(TEST_DummyInsertModeEnum.MOCK);
        for (String bottlerField : ECICCommonConstants.BOTTLER_FIELDS) {
            dummyRegion.put(bottlerField, dummyUser.Id);
        }
    }
    
    //------------------------------------------------------------------------------------------------------------
    
    private static void updateCaseBottlersAndDistributorsByRegionTest(Boolean isPlantNullTest, Boolean isRegionNullTest) {
        User                dummyPlantRegionUser    = null;
        User                dummyRegionUser         = null;
        Region__c           dummyPlantRegion        = null;
        Region__c           dummyRegionOfPurchase   = null;
        Plant__c            dummyPlant              = null;
        Map<ID, Region__c>  regionsMap              = new Map<ID, Region__c>();
        
        if(!isPlantNullTest) {
            dummyPlantRegionUser    = TEST_DummyUserFactory.create(TEST_DummyInsertModeEnum.REAL);
            dummyPlantRegion        = createDummyRegion(dummyPlantRegionUser.Id);
            regionsMap.put(dummyPlantRegion.Id, dummyPlantRegion);
            
            TEST_DummyPlantFactory.Config   plantConfig                             = new TEST_DummyPlantFactory.Config();
                                            plantConfig.regionId                    = dummyPlantRegion.Id;
            dummyPlant              = TEST_DummyPlantFactory.create(plantConfig, TEST_DummyInsertModeEnum.REAL);
        }
        
        if(!isRegionNullTest) {
            dummyRegionUser         = TEST_DummyUserFactory.create(TEST_DummyInsertModeEnum.REAL);
            dummyRegionOfPurchase   = createDummyRegion(dummyRegionUser.Id);
            regionsMap.put(dummyRegionOfPurchase.Id, dummyRegionOfPurchase);
        }
        
        TEST_DummyCaseConfig            caseConfig                              = new TEST_DummyCaseConfig();
                                        caseConfig.productionCode               = (isPlantNullTest)     ? TEST_ConfigHelper.INTENTIONAL_NULL : dummyPlant.Name;
                                        caseConfig.plantId                      = (isPlantNullTest)     ? TEST_ConfigHelper.INTENTIONAL_NULL : dummyPlant.Id;
                                        caseConfig.regionOfPurchaseId           = (isRegionNullTest)    ? null : dummyRegionOfPurchase.Id;
                                        caseConfig.status                       = (isPlantNullTest)     ? ECICCommonConstants.STATUS_NEW : ECICCommonConstants.STATUS_OPEN;
        Case dummyCase                  = TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.REAL);
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                ECICRegionTriggerHandler.updateCaseBottlersAndDistributorsByRegion(regionsMap);
            }
            Test.stopTest();
        }
        
        dummyCase = [SELECT id, region_of_purchase__c, plant__r.region__c,  
                        Bottler_External_Relations__c, Bottler_Quality_Manager__c, Bottler_Quality_Owner__c,
                        Distributor_External_Relations__c, Distributor_Quality__c, Distributor_Quality_Manager__c,
                        No_Quality_Status_Change__c,
                        RecordTypeId
                    FROM Case WHERE Id =:dummyCase.Id];
        
        //System.assertEquals(true, dummyCase.No_Quality_Status_Change__c);
        Id expectedPlantUserId  = isPlantNullTest   ? null : dummyPlantRegionUser.Id;
        Id expectedRegionUserId = isRegionNullTest  ? null : dummyRegionUser.Id;
        
        for (String regionUserField : ECICCommonConstants.REGION_USER_FIELDS) {
            ID expectedUserId = regionUserField.startsWith('Distributor') ? expectedRegionUserId : expectedPlantUserId;
            if(isPlantNullTest && !isRegionNullTest) { expectedUserId = null;}
            System.assertEquals(expectedUserId, (ID) dummyCase.get(regionUserField));
        }
    }
    
    private static testMethod void updateCaseBottlersAndDistributorsEmptyPlantEmptyRegion()         { updateCaseBottlersAndDistributorsByRegionTest(true, true);  }
    private static testMethod void updateCaseBottlersAndDistributorsEmptyPlantNotEmptyRegion()      { updateCaseBottlersAndDistributorsByRegionTest(true, false); }
    /*
    private static testMethod void updateCaseBottlersAndDistributorsNotEmptyPlantEmptyRegion()      { updateCaseBottlersAndDistributorsByRegionTest(false, true); }
    private static testMethod void updateCaseBottlersAndDistributorsNotEmptyPlantNotEmptyRegion()   { updateCaseBottlersAndDistributorsByRegionTest(false, false); }*/
    
    private static Region__c createDummyRegion(Id userId) {
        TEST_DummyRegionFactory.Config  regionConfig                            = new TEST_DummyRegionFactory.Config();
                                        regionConfig.qualityManagerUserId       = userId;
                                        regionConfig.externalRelationsUserId    = userId;
                                        regionConfig.qualityOwnerUserId         = userId;
        return TEST_DummyRegionFactory.create(regionConfig, TEST_DummyInsertModeEnum.REAL);
    }
    
}