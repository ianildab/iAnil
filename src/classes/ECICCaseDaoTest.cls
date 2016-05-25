@isTest
private class ECICCaseDaoTest 
{
    private static final User                   TEST_RUN_USER    = TEST_DummyUserFactory.createDefaultTestRunUser();
    private static final Map<String, Region__c> DUMMY_REGION_MAP = TEST_DummyRegionFactory.createDefaultRegionMap();

    private static  void getFirstResultTest(Boolean hasCase, Boolean isNull)
    {
        Case       dummyCase     = null;
        List<Case> dummyCaseList = (!isNull) ? new List<Case>() : null;
        if (hasCase && !isNull)
        {
            dummyCaseList.addAll(TEST_DummyInquiryCaseFactory.createList (2, new TEST_DummyCaseConfig(), TEST_DummyInsertModeEnum.NONE));
            dummyCase     = dummyCaseList[0];           
        }

        SObject resultSObject = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultSObject = ECICCaseDao.getFirstResult (dummyCaseList);
            }
            Test.stopTest();
        } 
        
        Case resultCase = (Case) resultSObject;
        System.assertEquals (dummyCase, resultCase);
    }
    
    private static testMethod void hasCaseGetFirstResultTest() { getFirstResultTest(true,  false);  }
    private static testMethod void isNullGetFirstResultTest()  { getFirstResultTest(false, true);   }
    private static testMethod void isEmptyGetFirstResultTest() { getFirstResultTest(false, false);  }
    
    // -----------------------------------------------------------------------------------------------------
    
    private static testMethod void findByIdTest()
    {
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.ownerUserId = TEST_RUN_USER.id;
        Case dummyCase = TEST_DummyInquiryCaseFactory.create (config, TEST_DummyInsertModeEnum.REAL);
        
        Case resultCase = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCase = ECICCaseDao.findById (dummyCase.id);
            }
            Test.stopTest();
        } 
        
        System.assertEquals (dummyCase.id,         resultCase.id);
        System.assertEquals (TEST_RUN_USER.id,     resultCase.ownerId);
        // Note: we can't assert caseNumber without a second SOQL because it isn't writable. 
        
    }
    
    // -----------------------------------------------------------------------------------------------------
    
    private static testMethod void findByIdsTest()
    {
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.status                        = ECICCommonConstants.STATUS_OPEN;
                             config.nextOpenTaskResponsibleUserId = TEST_RUN_USER.id;
                             /*#CICTemplateTest*/
                             config.productionCode                = 'mv1111';
        Case dummyCase = TEST_DummyInquiryCaseFactory.create (config, TEST_DummyInsertModeEnum.REAL);
        
        Map<Id, Case> resultCaseByIdMap = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCaseByIdMap = ECICCaseDao.findByIds (new List<Id>{dummyCase.id});
            }
            Test.stopTest();
        } 
        
        System.assert (resultCaseByIdMap.containsKey(dummyCase.id));
        
        Case resultCase = resultCaseByIdMap.get(dummyCase.id);
        System.assertEquals (dummyCase.id,                                                                  resultCase.id);
        /*#CICTemplateTest*/
        System.assertEquals (TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(ECICCommonConstants.INQUIRY_IBERIA_DEVNAME),  resultCase.recordTypeId);
        System.assertEquals (TEST_RUN_USER.id,                                                              resultCase.Next_Open_Task_Reponsible_Lookup__c);
        System.assertEquals (ECICCommonConstants.STATUS_OPEN,                                               resultCase.status);
        System.assert                                                                                     (!resultCase.isClosed);
    }
    
    // -----------------------------------------------------------------------------------------------------

    private static testMethod void buildConditionListTest()
    {
        Id          dummyId1             = '00520000001qmX1';
        Id          dummyId2             = '00520000001qmX2';
        Set<Id>     dummyIdSet           = new Set<Id>     { dummyId1, dummyId2 };
        
        String      dummyUserField       = 'Quality_Case_Owner__c';
        String      dummyRegionUserField = 'Bottler_External_Relations__c';
        Set<String> dummyFieldSet        = new Set<String> { dummyUserField , dummyRegionUserField };
        
        List<String> resultConditionList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultConditionList = ECICCaseDao.buildConditionList(dummyIdSet, dummyFieldSet);
            }
            Test.stopTest();
        } 
        
        System.assertEquals (2, resultConditionList.size());
        
        Map<String,Boolean> conditionContainedByFieldMap = new Map<String,Boolean> { dummyUserField => false, dummyRegionUserField => false };
         
        for (String resultCondition : resultConditionList)
        {
            System.assert (resultCondition.contains(dummyId1));
            System.assert (resultCondition.contains(dummyId2));
            
            Boolean isRegionUserFieldCondition = resultCondition.contains(dummyRegionUserField);
            String conditionField = (isRegionUserFieldCondition) ?        dummyRegionUserField : dummyUserField;
            System.assert (resultCondition.contains(          conditionField + ' IN'     ));            
            System.assert (resultCondition.contains( ' OR ' + conditionField + ' = null' ));
            conditionContainedByFieldMap.put(                 conditionField, true);            
        }
        
        for (Boolean conditionContained : conditionContainedByFieldMap.values()) { System.assert (conditionContained); }
    }
    
    // -----------------------------------------------------------------------------------------------------
    
    private static void findNotClosedByRegionAndMappedUserFieldsTest(Boolean isCaseOpen)
    {
        User           dummyUser       = TEST_RUN_USER;
        Action_Plan__c dummyActionPlan = TEST_DummyActionPlanFactory.create(TEST_DummyInsertModeEnum.REAL);
        
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();

        // NOTE: The below selection of fields is only a representative sample, skipping the non-writable (formula) fields and those which we haven't commonly used.
        
        // FROM SELECT_CASE
                             config.countryCode                       = ECICCommonConstants.COUNTRY_CODE_DEFAULT;
                             config.actionPlanId                      = dummyActionPlan.id;
                             config.ownerUserId                       = TEST_RUN_USER.id;

        // FROM CASE_FIELDS
                             config.status                            = (isCaseOpen) ? ECICCommonConstants.STATUS_OPEN : ECICCommonConstants.STATUS_CLOSED;
                             config.qualityStatus                     = ECICCommonConstants.STATUS_OPEN;
                             config.origin                            = 'Email';
                             config.potentialRisk                     = 'High Risk';
                             config.riskType                          = 'Blackmail';
                             config.imcrIssue                         = true;
                             config.sampleCollected                   = true;
                             /*#CICTemplateTest*/
                             config.productionCode                    = 'mv1111';

        // FROM USER_FIELDS
                             config.qualityAdminAssistantUserId       = dummyUser.id;
                             config.qualityCaseOwnerUserId            = dummyUser.id;
                             config.qualityManagerUserId              = dummyUser.id;
                             config.serviceManagerUserId              = dummyUser.id;
                             
        // FROM REGION_USER_FIELDS
                             config.bottlerExternalRelationsUserId    = dummyUser.id;
                             config.bottlerQualityManagerUserId       = dummyUser.id;
                             config.bottlerQualityOwnerUserId         = dummyUser.id;
                             config.distributorEternalRelationsUserId = dummyUser.id;
                             config.distributorQualityManagerUserId   = dummyUser.id;
                             config.distributorQualityUserId          = dummyUser.id;


        Case dummyCase = TEST_DummyInquiryCaseFactory.create (config, TEST_DummyInsertModeEnum.REAL);
        
        List<Case> resultCaseList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCaseList = ECICCaseDao.findNotClosedByRegionAndMappedUserFields (new Set<Id>{ dummyUser.id });
            }
            Test.stopTest();
        } 
        
        System.assertEquals (isCaseOpen ? 1 : 0, resultCaseList.size());
        if (isCaseOpen)
        {
            Case resultCase = resultCaseList[0];

            // FROM target method
            /*#CICTemplateTest*/
                System.assertEquals (TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(ECICCommonConstants.INQUIRY_IBERIA_DEVNAME),  resultCase.recordTypeId);
    
            // FROM SELECT_CASE
                System.assertEquals (ECICCommonConstants.COUNTRY_CODE_DEFAULT,                                      resultCase.country_code__c);
                System.assertEquals (dummyActionPlan.id,                                                            resultCase.action_plan__c);
                System.assertEquals (TEST_RUN_USER.id,                                                              resultCase.ownerId);

            // FROM CASE_FIELDS (Generally Used Fields)
                System.assertEquals (config.imcrIssue,                                                              resultCase.IMCR_Issue__c);
                System.assertEquals (config.origin,                                                                 resultCase.Origin);
                System.assertEquals (config.potentialRisk,                                                          resultCase.Potential_Risk__c);
                System.assertEquals (config.qualityStatus,                                                          resultCase.Quality_Status__c);
                System.assertEquals (config.riskType,                                                               resultCase.Risk_Type__c);
                System.assertEquals (config.sampleCollected,                                                        resultCase.Sample_Collected__c);
                System.assertEquals (config.status,                                                                 resultCase.Status);

            // FROM CASE_FIELDS (Formula Fields)
                System.assertEquals (null,                                                                          resultCase.Can_Process__c);
                System.assertEquals (null,                                                                          resultCase.Compensation_Product__c);
                System.assertEquals (null,                                                                          resultCase.Customer_Complaint__c);
                System.assertEquals (null,                                                                          resultCase.External_Collector__c);
                System.assertEquals (null,                                                                          resultCase.Has_ShippingAddress__c);
                System.assertEquals (null,                                                                          resultCase.Insurance__c);
                System.assertEquals (null,                                                                          resultCase.Product_Package__c);

            // FROM CASE_FIELDS (Other Fields)
                System.assertEquals (null,                                                                          resultCase.Damage_Caused__c);
                System.assertEquals (null,                                                                          resultCase.Gift_Compensation__c);
                System.assertEquals (null,                                                                          resultCase.Sample_Collector__c);
                System.assertEquals (null,                                                                          resultCase.Type_of_Gift__c);

            // FROM USER_FIELDS
                System.assertEquals (null,                                                                          resultCase.Consumer_Complaint_Manager__c);
                System.assertEquals (dummyUser.id,                                                                  resultCase.Quality_Admin_Assistant__c);
                System.assertEquals (dummyUser.id,                                                                  resultCase.Quality_Case_Owner__c);
                System.assertEquals (dummyUser.id,                                                                  resultCase.Quality_Manager__c);
                System.assertEquals (dummyUser.id,                                                                  resultCase.Service_Manager__c);
               
            // FROM REGION_USER_FIELDS
                System.assertEquals (dummyUser.id,                                                                  resultCase.Bottler_External_Relations__c);
                System.assertEquals (dummyUser.id,                                                                  resultCase.Bottler_Quality_Manager__c);
                System.assertEquals (dummyUser.id,                                                                  resultCase.Bottler_Quality_Owner__c);
                System.assertEquals (dummyUser.id,                                                                  resultCase.Distributor_External_Relations__c);
                System.assertEquals (dummyUser.id,                                                                  resultCase.Distributor_Quality__c);
                System.assertEquals (dummyUser.id,                                                                  resultCase.Distributor_Quality_Manager__c);
        }
    }
    
    private static void closedCaseFindNotClosedByRegionAndMappedUserFieldsTest() { findNotClosedByRegionAndMappedUserFieldsTest(false); }
    private static void openCaseFindNotClosedByRegionAndMappedUserFieldsTest()   { findNotClosedByRegionAndMappedUserFieldsTest(true);  }
    
    // -----------------------------------------------------------------------------------------------------
    
    private static void findNotClosedByRegionOrPlantRegionTest(Boolean isCaseOpen, Boolean hasRegionOfPurchase, Boolean hasRegionOfBottler)
    {
        Set<Id> dummyRegionIdSet = new Set<Id>();
        Id      dummyPurchaseRegionId = getRegionId(hasRegionOfPurchase, 'Distributor', dummyRegionIdSet);
        Id      dummyBottlerRegionId  = getRegionId(hasRegionOfBottler,  'Bottler',     dummyRegionIdSet);
    
        Id       dummyPlantId          = (hasRegionOfBottler) ? TEST_DummyPlantFactory.create (null, dummyBottlerRegionId, TEST_DummyInsertModeEnum.REAL).id : null;
        Id       dummyUserId           = TEST_RUN_USER.id;

        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.status                            = (isCaseOpen) ? ECICCommonConstants.STATUS_OPEN : ECICCommonConstants.STATUS_CLOSED; 
                             config.channelOfAnswer                   = ECICCommonConstants.CASE_CHANNEL_OF_ANSWER; 
                             config.regionOfPurchaseId               = dummyPurchaseRegionId;
                             config.plantId                           = dummyPlantId;
                             config.bottlerExternalRelationsUserId    = dummyUserId;
                             config.bottlerQualityManagerUserId       = dummyUserId;
                             config.bottlerQualityOwnerUserId         = dummyUserId;
                             config.distributorEternalRelationsUserId = dummyUserId;
                             config.distributorQualityManagerUserId   = dummyUserId;
                             config.distributorQualityUserId          = dummyUserId;
                             config.noQualityStatusChange             = true;
                             /*#CICTemplateTest*/
                             config.productionCode                    = 'mv1111';
                             
        Case dummyCase = TEST_DummyInquiryCaseFactory.create (config, TEST_DummyInsertModeEnum.REAL);
        
        List<Case> resultCaseList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCaseList = ECICCaseDao.findNotClosedByRegionOrPlantRegion (dummyRegionIdSet);
            }
            Test.stopTest();
        }
        
        Boolean caseExpected = isCaseOpen && (hasRegionOfPurchase || hasRegionOfBottler);
        System.assertEquals (caseExpected ? 1 : 0, resultCaseList.size());
        if (caseExpected)
        {
            Case resultCase = resultCaseList[0];
            /*#CICTemplateTest*/
            System.assertEquals (TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(ECICCommonConstants.INQUIRY_IBERIA_DEVNAME),  resultCase.recordTypeId);
            
            if (hasRegionOfPurchase) { System.assertEquals ( dummyPurchaseRegionId, resultCase.region_of_purchase__c               ); }     
            if (hasRegionOfBottler)  { System.assertEquals ( dummyBottlerRegionId,  resultCase.plant__r.region__c                  ); }     
                                       System.assertEquals ( dummyUserId,           resultCase.Bottler_External_Relations__c       );
                                       System.assertEquals ( dummyUserId,           resultCase.Bottler_Quality_Manager__c          );
                                       System.assertEquals ( dummyUserId,           resultCase.Bottler_Quality_Owner__c            );
                                       System.assertEquals ( dummyUserId,           resultCase.Distributor_External_Relations__c   );
                                       System.assertEquals ( dummyUserId,           resultCase.Distributor_Quality__c              );
                                       System.assertEquals ( dummyUserId,           resultCase.Distributor_Quality_Manager__c      );
                                       System.assertEquals ( true,                  resultCase.no_quality_status_change__c         );
        }
    }
    
    private static testMethod void closedHasNeitherFindNotClosedByRegionOrPlantRegionTest()     { findNotClosedByRegionOrPlantRegionTest (false, false, false); }
    private static testMethod void closedHasBottlerFindNotClosedByRegionOrPlantRegionTest()     { findNotClosedByRegionOrPlantRegionTest (false, false, true ); }
    private static testMethod void closedHasDistributorFindNotClosedByRegionOrPlantRegionTest() { findNotClosedByRegionOrPlantRegionTest (false, true , false); }
    private static testMethod void closedHasBothFindNotClosedByRegionOrPlantRegionTest()        { findNotClosedByRegionOrPlantRegionTest (false, true , true ); }
    private static testMethod void openHasNeitherFindNotClosedByRegionOrPlantRegionTest()       { findNotClosedByRegionOrPlantRegionTest (true , false, false); }
    private static testMethod void openHasBottlerFindNotClosedByRegionOrPlantRegionTest()       { findNotClosedByRegionOrPlantRegionTest (true , false, true ); }
    private static testMethod void openHasDistributorFindNotClosedByRegionOrPlantRegionTest()   { findNotClosedByRegionOrPlantRegionTest (true , true , false); }
    private static testMethod void openHasBothFindNotClosedByRegionOrPlantRegionTest()          { findNotClosedByRegionOrPlantRegionTest (true , true , true ); }
    
    // -----------------------------------------------------------------------------------------------------
    
    private static Id getRegionId(Boolean hasRegion, String regionType, Set<Id> dummyRegionIdSet)
    {
        Id dummyRegionId = null;
        if (hasRegion) 
        { 
            dummyRegionId = DUMMY_REGION_MAP.get(regionType).id; 
            dummyRegionIdSet.add(dummyRegionId); 
        }
        return dummyRegionId; 
    }
    
    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    private static void buildWhereConditionListTest(Boolean hasReason, Boolean hasPlantId, Boolean hasProductType, Boolean hasProductDescription)
    {
        Closed_Trend__c dummyDefinitionClosedTrend = ECICClosedTrendsTrackerTestHelper.createClosedTrend(true, true, hasReason, hasPlantId, hasProductType, hasProductDescription, TEST_DummyInsertModeEnum.NONE);
        
        List<String> resultWhereConditionList = null; 
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultWhereConditionList = ECICCaseDao.buildWhereConditionList(dummyDefinitionClosedTrend);
            }
            Test.stopTest();
        }

        Integer expectedSize =    ECICClosedTrendsTrackerTestHelper.totalTrue(new List<Boolean>{ hasReason, hasPlantId, hasProductType, hasProductDescription});
        System.assertEquals (expectedSize, resultWhereConditionList.size());
        
        ECICClosedTrendsTrackerTestHelper.assertCondition (resultWhereConditionList, hasReason,             'case_reason__c',         ECICClosedTrendsTrackerTestHelper.DUMMY_CASE_REASON);
        ECICClosedTrendsTrackerTestHelper.assertCondition (resultWhereConditionList, hasPlantId,            'plant__c',               ECICClosedTrendsTrackerTestHelper.DUMMY_PLANT_ID);
        ECICClosedTrendsTrackerTestHelper.assertCondition (resultWhereConditionList, hasProductType,        'type__c',                ECICClosedTrendsTrackerTestHelper.DUMMY_PRODUCT_TYPE);
        ECICClosedTrendsTrackerTestHelper.assertCondition (resultWhereConditionList, hasProductDescription, 'product_description__c', ECICClosedTrendsTrackerTestHelper.DUMMY_PRODUCT_DESCRIPTION);
    }

    private static testMethod void hasAllBuildWhereConditionListTest()                          { buildWhereConditionListTest( true ,  true ,  true ,  true    ); }
    private static testMethod void hasAllButReasonBuildWhereConditionListTest()                 { buildWhereConditionListTest( false,  true ,  true ,  true    ); }
    private static testMethod void hasAllButPlantIdBuildWhereConditionListTest()                { buildWhereConditionListTest( true ,  false,  true ,  true    ); }
    private static testMethod void hasAllButProductTypeBuildWhereConditionListTest()            { buildWhereConditionListTest( true ,  true ,  false,  true    ); }
    private static testMethod void hasAllButProductDescriptionBuildWhereConditionListTest()     { buildWhereConditionListTest( true ,  true ,  true ,  false   ); }
    private static testMethod void hasNoneBuildWhereConditionListTest()                         { buildWhereConditionListTest( false,  false,  false,  false   ); }
    private static testMethod void hadPlantIdAndProductDescriptionBuildWhereConditionListTest() { buildWhereConditionListTest( false,  true ,  false,  true    ); }
    private static testMethod void hadPlantIdAndProductTypeBuildWhereConditionListTest()        { buildWhereConditionListTest( false,  true ,  true ,  false   ); }
    private static testMethod void hasPlantIdBuildWhereConditionListTest()                      { buildWhereConditionListTest( false,  true ,  false,  false   ); }
    private static testMethod void hasProductDescriptionBuildWhereConditionListTest()           { buildWhereConditionListTest( false,  false,  false,  true    ); }
    private static testMethod void hasProductFieldsBuildWhereConditionListTest()                { buildWhereConditionListTest( false,  false,  true ,  true    ); }
    private static testMethod void hasProductTypeBuildWhereConditionListTest()                  { buildWhereConditionListTest( false,  false,  true ,  false   ); }
    private static testMethod void hasReasonAndPlantIdBuildWhereConditionListTest()             { buildWhereConditionListTest( true ,  true ,  false,  false   ); }
    private static testMethod void hasReasonAndProductDescriptionBuildWhereConditionListTest()  { buildWhereConditionListTest( true ,  false,  false,  true    ); }
    private static testMethod void hasReasonAndProductTypeBuildWhereConditionListTest()         { buildWhereConditionListTest( true ,  false,  true ,  false   ); }
    private static testMethod void hasReasonBuildWhereConditionListTest()                       { buildWhereConditionListTest( true ,  false,  false,  false   ); }

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    private static testMethod void buildCriteriaListTest()
    {
        Closed_Trend__c dummyDefinitionClosedTrend = ECICClosedTrendsTrackerTestHelper.createClosedTrend(true, true, true, true, false, false, TEST_DummyInsertModeEnum.NONE);
        
        List<String> resultCriteriaList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCriteriaList = ECICCaseDao.buildCriteriaList(new List<Closed_trend__c> { dummyDefinitionClosedTrend });
            }
            Test.stopTest();
        }
        
        System.assertEquals (1, resultCriteriaList.size());
        System.assertEquals (ECICClosedTrendsTrackerTestHelper.buildCriteria (ECICClosedTrendsTrackerTestHelper.DUMMY_CASE_REASON, ECICClosedTrendsTrackerTestHelper.DUMMY_PLANT_ID) , resultCriteriaList[0]);
    }

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    private static testMethod void selectCaseList2Test()
    {
        String firstClosedTrendReason   = ECICClosedTrendsTrackerTestHelper.DUMMY_CASE_REASON;
        String firstClosedTrendPlantId  = ECICClosedTrendsTrackerTestHelper.DUMMY_PLANT_ID;
        String secondClosedTrendReason  = ECICCOMMONCONSTANTS.QUALITY_COMPLAINT_REASON_PRODUCTS;
        String secondClosedTrendPlantId = TEST_DummyPlantFactory.create(TEST_DummyInsertModeEnum.REAL).id;

        // Creates 24 (4 x 6) Cases; only 2 should be selected; others ensure the conditional is not allowing false postives.                                  
        Map<Id, Case> dummyCaseByIdMap = ECICClosedTrendsTrackerTestHelper.createCaseMap(  firstClosedTrendReason,  firstClosedTrendPlantId, secondClosedTrendReason, secondClosedTrendPlantId );    

        List<String> dummyCriteriaList = new List<String>
        { 
            ECICClosedTrendsTrackerTestHelper.buildCriteria (firstClosedTrendReason,  firstClosedTrendPlantId),
            ECICClosedTrendsTrackerTestHelper.buildCriteria (secondClosedTrendReason, secondClosedTrendPlantId)
        };

        List<Case> resultCaseList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCaseList = ECICCaseDao.selectCaseList(dummyCriteriaList);
            }
            Test.stopTest();
        }
        
        System.assertEquals (2, resultCaseList.size());
        
        Map<Integer, Boolean> isCaseFoundMap = new Map<Integer, Boolean>();
        for (Case resultCase : resultCaseList)
        {
            if      ((resultCase.reason == firstClosedTrendReason)  && (resultCase.plant__c == firstClosedTrendPlantId))  { isCaseFoundMap.put (1, true); }
            else if ((resultCase.reason == secondClosedTrendReason) && (resultCase.plant__c == secondClosedTrendPlantId)) { isCaseFoundMap.put (2, true); }
            else    { System.assert (false, 'Unexpected Case');  }
            
            Case expectedCase = dummyCaseByIdMap.get(resultCase.id);
            System.assertEquals (expectedCase.country_code__c,         resultCase.country_code__c);
            System.assertEquals (expectedCase.product__c,              resultCase.product__c);
        }
        System.assert (isCaseFoundMap.get(1));
        System.assert (isCaseFoundMap.get(2));
    }

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    private static testMethod void selectCaseList1Test()
    {

        Closed_Trend__c dummyDefinitionClosedTrend = ECICClosedTrendsTrackerTestHelper.createClosedTrend(true, true, true, true, false, false, TEST_DummyInsertModeEnum.NONE);

        TEST_DummyCaseConfig caseConfig = ECICClosedTrendsTrackerTestHelper.createCaseConfig(ECICClosedTrendsTrackerTestHelper.DUMMY_CASE_REASON,  ECICClosedTrendsTrackerTestHelper.DUMMY_PLANT_ID, ECICCommonConstants.STATUS_OPEN, true);
        caseConfig.productionCode = 'mv1111'; //#CICTemplateTest
        caseConfig.productId = TEST_DummyProductFactory.getDefaultProductId(TEST_DummyInsertModeEnum.REAL);//#CICTemplateTest
        caseConfig.productionLineId = TEST_DummyProductionLineFactory.create(TEST_DummyInsertModeEnum.REAL).id;//#CICTemplateTest
        caseConfig.bottlerAccountId = TEST_DummyAccountFactory.getDefaultBottlerAccountId(TEST_DummyInsertModeEnum.REAL);//#CICTemplateTest
        caseConfig.regionOfPurchaseId = TEST_DummyRegionFactory.getDefaultRegionId(TEST_DummyInsertModeEnum.REAL);//#CICTemplateTest
        Case dummyCase = TEST_DummyGenericCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.REAL);    

        List<Case> resultCaseList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCaseList = ECICCaseDao.selectCaseList(new List<Closed_trend__c> { dummyDefinitionClosedTrend });
            }
            Test.stopTest();
        }

        System.assertEquals (1, resultCaseList.size());
        Case resultCase = resultCaseList[0];
        System.assertEquals (ECICClosedTrendsTrackerTestHelper.DUMMY_CASE_REASON,                    resultCase.reason);
        System.assertEquals (ECICClosedTrendsTrackerTestHelper.DUMMY_PLANT_ID,                       resultCase.plant__c);
        System.assertEquals (dummyCase.country_code__c,            resultCase.country_code__c);
        System.assertEquals (dummyCase.product__c,                 resultCase.product__c);
    }

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    private static void selectRecentQualityComplaintCaseListTest(Boolean isQualityCase, Boolean hasMatchingCountryCode, String caseStatus)
    {
        String dummyTargetCountryCode = 'FR';
        String dummyCaseCountryCode   = (hasMatchingCountryCode) ? dummyTargetCountryCode : 'BG';
        
        TEST_DummyAccountFactory.Config accountConfig = new TEST_DummyAccountFactory.Config();
                                        accountConfig.name         = 'Dummy Account';
                                        accountConfig.tradeChannel = 'Airlines';
        Account dummyAccount = TEST_DummyAccountFactory.create(accountConfig, TEST_DummyInsertModeEnum.REAL);
        
        TEST_DummyBeverageFactory.Config beverageConfig = new TEST_DummyBeverageFactory.Config();
                                         beverageConfig.name       = 'Dummy Beverage';
                                         beverageConfig.brand      = 'ECICCommonConstants.BEVERAGE_BRAND_DEFAULT';
                                         beverageConfig.countryCode = dummyCaseCountryCode;
        Beverage__c dummyBeverage = TEST_DummyBeverageFactory.create(beverageConfig, TEST_DummyInsertModeEnum.REAL);

        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             /*#CICTemplateTest*/
                             caseConfig.recordTypeId   = (isQualityCase)        ? TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME) : TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(ECICCommonConstants.INQUIRY_IBERIA_DEVNAME);
                             caseConfig.countryCode    = dummyCaseCountryCode;
                             caseConfig.createdDate    = System.today();
                             caseConfig.reason         = ECICCommonConstants.INQUIRY_REASON;
                             caseConfig.categoryLevel3 = ECICCommonConstants.CASE_CATEGORY_LEVEL_3_PACKAGE_QUALITY_FILL_LEVEL;
                             caseConfig.accountId      = dummyAccount.id;
                             caseConfig.beverageId     = dummyBeverage.id;
                             caseConfig.status         = caseStatus;
                             caseConfig.productionCode = 'mv1111'; //#CICTemplateTest
                             caseConfig.productId = TEST_DummyProductFactory.getDefaultProductId(TEST_DummyInsertModeEnum.REAL);//#CICTemplateTest
                             caseConfig.productionLineId = TEST_DummyProductionLineFactory.create(TEST_DummyInsertModeEnum.REAL).id;//#CICTemplateTest
                             caseConfig.bottlerAccountId = TEST_DummyAccountFactory.getDefaultBottlerAccountId(TEST_DummyInsertModeEnum.REAL);//#CICTemplateTest
                             caseConfig.regionOfPurchaseId = TEST_DummyRegionFactory.getDefaultRegionId(TEST_DummyInsertModeEnum.REAL);//#CICTemplateTest
        Case         dummyCase         = TEST_DummyGenericCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.REAL);    
        
        List<String> caseFieldNameList = new List<String> 
        { 
               'reason', 'category_level3__c', 'accountId', 'beverage__c',         // Case fields
               'account.name', 'account.trade_channel__c',                         // Account fields (related to SFDC native SObject)
               'beverage__r.name', 'beverage__r.brand__c'                          // Brand fields   (related to custom SObject)
        };
        Set<String>  countryCodeSet    = new Set<String>{ dummyTargetCountryCode };

        List<Case> resultCaseList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCaseList = ECICCaseDao.selectRecentQualityComplaintCaseList(caseFieldNameList, countryCodeSet);
            }
            Test.stopTest();
        }
        
        Boolean caseExpected = isQualityCase && hasMatchingCountryCode && (!(ECICCaseDao.UNEXPORTED_STATUS_SET).contains(caseStatus));
        System.assertEquals ((caseExpected) ? 1 : 0, resultCaseList.size());
        
        if (caseExpected)
        {
            Case resultCase = resultCaseList[0];
            System.assertEquals (caseConfig.reason,          resultCase.reason);                        // Direct, native
        System.assertEquals (caseConfig.categoryLevel3.toLowerCase(),  resultCase.category_level3__c.toLowerCase());            // Direct, custom
            System.assertEquals (dummyTargetCountryCode,     resultCase.country_code__c);               // Field not specified in List parameter, but required
            System.assertEquals (caseConfig.accountId,       resultCase.accountId);                     // Direct, native Id
            System.assertEquals (caseConfig.beverageId,      resultCase.beverage__c);                   // Direct, custom Id
            System.assertEquals (accountConfig.name,         resultCase.account.name);                  // Indirect, native SObject, native field
            System.assertEquals (accountConfig.tradeChannel, resultCase.account.trade_channel__c);      // Indirect, native SObject, custom field
            System.assertEquals (beverageConfig.name,        resultCase.beverage__r.name);              // Indirect, native SObject, native field
            System.assertEquals (beverageConfig.brand,       resultCase.beverage__r.brand__c);          // Indirect, custom SObject, custom field
        }
    }

    private static testMethod void noQualificationCaseSelectRecentQualityComplaintCaseList()        { selectRecentQualityComplaintCaseListTest(false, false, ECICCommonConstants.STATUS_NEW); }
    private static testMethod void recentCaseSelectRecentQualityComplaintCaseList()                 { selectRecentQualityComplaintCaseListTest(false, false, ECICCommonConstants.STATUS_OPEN ); }
    private static testMethod void matchedCountryCaseSelectRecentQualityComplaintCaseList()         { selectRecentQualityComplaintCaseListTest(false, true , ECICCommonConstants.STATUS_CANCELLED); }
    private static testMethod void recentMatchedCountryCaseSelectRecentQualityComplaintCaseList()   { selectRecentQualityComplaintCaseListTest(false, true , ECICCommonConstants.STATUS_ESCALATED ); }

    private static testMethod void qualityComplaintCaseSelectRecentQualityComplaintCaseList()       { selectRecentQualityComplaintCaseListTest(true , false, ECICCommonConstants.STATUS_CANCELLED); }
    private static testMethod void wrongCountryCaseSelectRecentQualityComplaintCaseList()           { selectRecentQualityComplaintCaseListTest(true , false, ECICCommonConstants.STATUS_RESOLVED); }
    private static testMethod void notRecentCaseSelectRecentQualityComplaintCaseList()              { selectRecentQualityComplaintCaseListTest(true , true , ECICCommonConstants.STATUS_NEW); }
    private static testMethod void totallyQualifiedCaseSelectRecentQualityComplaintCaseList()       { selectRecentQualityComplaintCaseListTest(true , true , ECICCommonConstants.STATUS_OPEN ); }

    // TODO: Add tests for excluding cases with Case.legacy_info3__c value

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    private static testMethod void selectRecentQualityComplaintCaseListByCountryCodeMapTest()
{
        String dummyTargetCountryCode = 'FR';
        
        TEST_DummyAccountFactory.Config accountConfig = new TEST_DummyAccountFactory.Config();
                                        accountConfig.name         = 'Dummy Account';
                                        accountConfig.tradeChannel = 'Airlines';
        Account dummyAccount = TEST_DummyAccountFactory.create(accountConfig, TEST_DummyInsertModeEnum.REAL);
        
        TEST_DummyBeverageFactory.Config beverageConfig = new TEST_DummyBeverageFactory.Config();
                                         beverageConfig.name       = 'Dummy Beverage';
                                         beverageConfig.brand      = 'ECICCommonConstants.BEVERAGE_BRAND_DEFAULT';
                                         beverageConfig.countryCode = dummyTargetCountryCode;
        Beverage__c dummyBeverage = TEST_DummyBeverageFactory.create(beverageConfig, TEST_DummyInsertModeEnum.REAL);

        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             /*#CICTemplateTest*/
                             caseConfig.recordTypeId   = TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME);
                             caseConfig.countryCode    = dummyTargetCountryCode;
                             caseConfig.createdDate    = System.today().addDays(-2);
                             caseConfig.reason         = ECICCommonConstants.INQUIRY_REASON;
                             caseConfig.categoryLevel3 = ECICCommonConstants.CASE_CATEGORY_LEVEL_3_PACKAGE_QUALITY_FILL_LEVEL;
                             caseConfig.accountId      = dummyAccount.id;
                             caseConfig.beverageId     = dummyBeverage.id;
                             caseConfig.status         = ECICCommonConstants.STATUS_OPEN;
                             caseConfig.productionCode = 'mv1111'; //#CICTemplateTest
                             caseConfig.productId = TEST_DummyProductFactory.getDefaultProductId(TEST_DummyInsertModeEnum.REAL);//#CICTemplateTest
                             caseConfig.productionLineId = TEST_DummyProductionLineFactory.create(TEST_DummyInsertModeEnum.REAL).id;//#CICTemplateTest
                             caseConfig.bottlerAccountId = TEST_DummyAccountFactory.getDefaultBottlerAccountId(TEST_DummyInsertModeEnum.REAL);//#CICTemplateTest
                             caseConfig.regionOfPurchaseId = TEST_DummyRegionFactory.getDefaultRegionId(TEST_DummyInsertModeEnum.REAL);//#CICTemplateTest
        Case         dummyCase         = TEST_DummyGenericCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.REAL);    
        
        List<String> caseFieldNameList = new List<String> 
        { 
               'reason', 'category_level3__c', 'accountId', 'beverage__c',         // Case fields
               'account.name', 'account.trade_channel__c',                         // Account fields (related to SFDC native SObject)
               'beverage__r.name', 'beverage__r.brand__c'                          // Brand fields   (related to custom SObject)
        };
        Set<String>  countryCodeSet    = new Set<String>{ dummyTargetCountryCode };

        Map<String, List<Case>> resultCaseByCountryCodeMap = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCaseByCountryCodeMap = ECICCaseDao.selectRecentQualityComplaintCaseListByCountryCodeMap(caseFieldNameList, countryCodeSet);
            }
            Test.stopTest();
        }
        
        System.assertEquals (1, resultCaseByCountryCodeMap.get(dummyTargetCountryCode).size());
        Case resultCase = resultCaseByCountryCodeMap.get(dummyTargetCountryCode)[0];
        System.assertEquals (caseConfig.reason,          resultCase.reason);                        // Direct, native
        System.assertEquals (caseConfig.categoryLevel3.toLowerCase(),  resultCase.category_level3__c.toLowerCase());            // Direct, custom
        System.assertEquals (dummyTargetCountryCode,     resultCase.country_code__c);               // Field not specified in List parameter, but required
        System.assertEquals (caseConfig.accountId,       resultCase.accountId);                     // Direct, native Id
        System.assertEquals (caseConfig.beverageId,      resultCase.beverage__c);                   // Direct, custom Id
        System.assertEquals (accountConfig.name,         resultCase.account.name);                  // Indirect, native SObject, native field
        System.assertEquals (accountConfig.tradeChannel, resultCase.account.trade_channel__c);      // Indirect, native SObject, custom field
        System.assertEquals (beverageConfig.name,        resultCase.beverage__r.name);              // Indirect, native SObject, native field
        System.assertEquals (beverageConfig.brand,       resultCase.beverage__r.brand__c);          // Indirect, custom SObject, custom field
    }    

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    private static testMethod void findNotClosedByRegionAndMappedUserFieldsTest()
    {
        Set<Id> dummyUserIdSet = new Set<Id>{ TEST_RUN_USER.id };
        
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.bottlerExternalRelationsUserId = TEST_RUN_USER.id;
        Case dummyCase = TEST_DummyInquiryCaseFactory.create (caseConfig, TEST_DummyInsertModeEnum.REAL);
        
        List<Case> resultCaseList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCaseList = ECICCaseDao.findNotClosedByRegionAndMappedUserFields(dummyUserIdSet);
            }
            Test.stopTest();
        } 
        
        System.assertEquals (1, resultCaseList.size());
        System.assertEquals (dummyCase.id, resultCaseList[0].id);
    }
}