@isTest 
private class ECICTrendMapTest 
{
    private static final User TEST_RUN_USER = ECICRunUserTestHelper.create();

    private static void selectResultTrendTest(Boolean isTrendMarkNull, Boolean isAnyTrendCreationDateGreater)   
    { 
    	Date    dummyCaseTrendMark        = System.today();
    	Integer dummyDifferenceForGreater = 20;
    	
    	TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
    	                     caseConfig.trendMark = (isTrendMarkNull) ? TEST_ConfigHelper.INTENTIONAL_NULL_FOR_DATE : dummyCaseTrendMark;
    	Case     dummyCase     = TEST_DummyInquiryCaseFactory.create (caseConfig, TEST_DummyInsertModeEnum.NONE);
    	
    	List<TEST_DummyTrendFactory.Config> trendConfigList = new List<TEST_DummyTrendFactory.Config> 
    	{
    		new TEST_DummyTrendFactory.Config(dummyCaseTrendMark.addDays(-10)),
    		new TEST_DummyTrendFactory.Config(dummyCaseTrendMark.addDays(isAnyTrendCreationDateGreater ? dummyDifferenceForGreater : -20))
    	};
    	List<Trend__c> dummyTrendList = TEST_DummyTrendFactory.createList (trendConfigList, TEST_DummyInsertModeEnum.NONE);
    	
        Trend__c resultTrend       = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                 resultTrend = getDummyTrendMap().selectResultTrend(dummyCase, dummyTrendList);
            }
            Test.stopTest();
        }
        
        Map<Datetime,Trend__c> trendByCreatedDateMap = new Map<Datetime,Trend__c>
        {
            dummyTrendList[0].CreatedDate => dummyTrendList[0],
            dummyTrendList[1].CreatedDate => dummyTrendList[1]
        };
        
        Trend__c expectedTrend = (isTrendMarkNull)
                                    ? dummyTrendList[0]
                                    : (
                                        (isAnyTrendCreationDateGreater) 
                                            ? trendByCreatedDateMap.get(dummyCaseTrendMark.addDays(dummyDifferenceForGreater)) 
                                            : null
                                      );

        //System.assertEquals(expectedTrend, resultTrend);                                      
    }

    private static testMethod void notNullNoGreaterSelectResultTrendTest()  { selectResultTrendTest(false, false); }   
    private static testMethod void notNullHasGreaterSelectResultTrendTest() { selectResultTrendTest(false, true ); }   
    private static testMethod void nullNoGreaterSelectResultTrendTest()     { selectResultTrendTest(true,  false); }   
    private static testMethod void nullHasGreaterSelectResultTrendTest()    { selectResultTrendTest(true,  true ); }

    // ------------------------------------------------------------------------------------------------

    private static void buildTrendByCaseStringIdentifierMapTest(Boolean isCaseIncludedInTrendList)   
    { 
        Date    dummyCaseTrendMark        = System.today();
    	
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.trendMark = dummyCaseTrendMark;
        Case           dummyCase      = TEST_DummyInquiryCaseFactory.create (caseConfig, TEST_DummyInsertModeEnum.NONE);
        List<Case>     dummyCaseList  = new List<Case> { dummyCase }; 

        List<TEST_DummyTrendFactory.Config> trendConfigList = new List<TEST_DummyTrendFactory.Config> 
        {
            new TEST_DummyTrendFactory.Config(dummyCaseTrendMark.addDays(isCaseIncludedInTrendList ? 20 : -20))
        };
        List<Trend__c> dummyTrendList = TEST_DummyTrendFactory.createList (trendConfigList, TEST_DummyInsertModeEnum.NONE);
        
        Map<String, Trend__c> resultTrendByCaseStringIdentifierMap = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                 resultTrendByCaseStringIdentifierMap = getDummyTrendMap().buildTrendByCaseStringIdentifierMap(dummyCaseList, dummyTrendList);
            }
            Test.stopTest();
        }
        
        if (isCaseIncludedInTrendList)
        {
            String caseIdentifier = ECICMapHelper.createMapIdentifier(dummyCase, true);
            System.assert(resultTrendByCaseStringIdentifierMap.containsKey(caseIdentifier));
            System.assertEquals(dummyTrendList[0], resultTrendByCaseStringIdentifierMap.get(caseIdentifier));
        }        
        else
        {
        	System.assert(resultTrendByCaseStringIdentifierMap.isEmpty());
        }
        
    }

    private static testMethod void excludedBuildTrendByCaseStringIdentifierMapTest()    { buildtrendByCaseStringIdentifierMapTest(false); }   
    private static testMethod void includedBuildTrendByCaseStringIdentifierMapTest()    { buildtrendByCaseStringIdentifierMapTest(true ); }

    // ------------------------------------------------------------------------------------------------

    private static testMethod void mapCaseListToTrendKeyTest()   
    { 
        String dummyCountryCode       = ECICCommonConstants.COUNTRY_CODE_DEFAULT;      // index 0
    	Date   dummyBestBeforeEndDate = System.today();                                // index 1
        Id     dummyProductionLineId  = 'a0H110000001Tz2';                             // index 2
        Id     dummyProductId         = 'a0I11000000Y56r';                             // index 3
        String dummyKey               = dummyCountryCode + '_' + dummyBestBeforeEndDate + '_' +  dummyProductionLineId  + '_' +   dummyProductId;

        Case       dummyCase     = TEST_DummyInquiryCaseFactory.create(TEST_DummyInsertModeEnum.NONE);
        List<Case> dummyCaseList = new List<Case>{ dummyCase };
         
         
        ECICTrendMap dummyTrendMap = getDummyTrendMap();
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                 dummyTrendMap.mapCaseListToTrendKey(dummyKey, dummyCaseList);
            }
            Test.stopTest();
        }
        
        Map<String, Trend__c>   resultNewTrendByKeyMap                    = dummyTrendMap.newTrendByKeyMap; 
        Map<String, List<Case>> resultCasesWithNewTrendsListByTrendKeyMap = dummyTrendMap.casesWithNewTrendsListByTrendKeyMap;
        
        System.assertEquals (dummyCaseList, resultCasesWithNewTrendsListByTrendKeyMap.get(dummyKey));
        
        System.assert(resultNewTrendByKeyMap.containsKey(dummyKey));
        Trend__c resultTrend = resultNewTrendByKeyMap.get(dummyKey);
        System.assertEquals (dummyBestBeforeEndDate, resultTrend.bbe_date__c);
        System.assertEquals (dummyProductionLineId,  resultTrend.production_line__c);
        System.assertEquals (dummyProductId,         resultTrend.product__c);
    }

    // ------------------------------------------------------------------------------------------------
    
    private static void singleCaseConstructorTest(Boolean hasTrendListMapKey, Boolean willTrendByCaseMapNotBeEmpty) 
    { 
    	Date   dummyCaseTrendMark        = willTrendByCaseMapNotBeEmpty ? TEST_ConfigHelper.INTENTIONAL_NULL_FOR_DATE : System.today().addDays(20);
    	
        String dummyCountryCode       = ECICCommonConstants.COUNTRY_CODE_DEFAULT;      // index 0
        Date   dummyBestBeforeEndDate = System.today();                                // index 1
        Id     dummyProductionLineId  = 'a0H110000001Tz2';                             // index 2
        Id     dummyProductId         = 'a0I11000000Y56r';                             // index 3
        String dummyKey               = dummyCountryCode + '_' + dummyBestBeforeEndDate + '_' +  dummyProductionLineId  + '_' +   dummyProductId;
        
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.bbeDate             = dummyBestBeforeEndDate;
                             caseConfig.productionLineId    = dummyProductionLineId;
                             caseConfig.productId           = dummyProductId;
                             caseConfig.trendMark = dummyCaseTrendMark;
        Case           dummyCase      = TEST_DummyInquiryCaseFactory.create (caseConfig, TEST_DummyInsertModeEnum.NONE);
        List<Case>     dummyCaseList  = new List<Case>{ dummyCase }; 
        
        TEST_DummyTrendFactory.Config trendConfig = new TEST_DummyTrendFactory.Config();
                                      trendConfig.caseCount   = 4;
                                      trendConfig.createdDate = System.today();
        Trend__c       dummyTrend     = TEST_DummyTrendFactory.create (trendConfig, TEST_DummyInsertModeEnum.MOCK);
        List<Trend__c> dummyTrendList = new List<Trend__c>{ dummyTrend };

        Map<String, List<Case>>     dummyGroupedCaseListByTrendKeyMap = new Map<String, List<Case>>     { dummyKey                                        =>  dummyCaseList };
        Map<String, List<Trend__c>> dummyTrendListByKeyMap            = new Map<String, List<Trend__c>> { (hasTrendListMapKey) ? dummyKey : 'Red Herring' => dummyTrendList };
        
        ECICTrendMap trendMap = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                 trendMap = new ECICTrendMap(dummyGroupedCaseListByTrendKeyMap, dummyTrendListByKeyMap);
            }
            Test.stopTest();
        }        
        
        if (hasTrendListMapKey && willTrendByCaseMapNotBeEmpty) 
        { 
        	System.assertEquals(5, dummyTrend.CaseCount__c);
            System.assert (dummyCase != null);
            ECICTrendHelperTest.assertTrendAssignedToCase (dummyTrend, dummyCase);  
        } 
        else                    
        { 
            System.assertEquals (null, dummyCase.trend__c);                
        }
    }

    private static testMethod void hasTrendListMapKeySingleCaseConstructorTest()            { singleCaseConstructorTest(true,  false); }
    private static testMethod void hasNothingSingleCaseConstructorTest()                    { singleCaseConstructorTest(false, false); }
    private static testMethod void willTrendByCaseMapNotBeEmptySingleCaseConstructorTest()  { singleCaseConstructorTest(false, true);  }
    private static testMethod void hasAllSingleCaseConstructorTest()                        { singleCaseConstructorTest(true,  true);  }

    // ------------------------------------------------------------------------------------------------
    
    private static testMethod void multipleCaseWithMissingKeyConstructorTest() 
    { 
        Date   dummyCaseTrendMark        = TEST_ConfigHelper.INTENTIONAL_NULL_FOR_DATE;
        
        String dummyCountryCode       = ECICCommonConstants.COUNTRY_CODE_DEFAULT;      // index 0
        Date   dummyBestBeforeEndDate = System.today();                                // index 1
        Id     dummyProductionLineId  = 'a0H110000001Tz2';                             // index 2
        Id     dummyProductId         = 'a0I11000000Y56r';                             // index 3
        String dummyKey               = dummyCountryCode + '_' + dummyBestBeforeEndDate + '_' +  dummyProductionLineId  + '_' +   dummyProductId;
        
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.bbeDate             = dummyBestBeforeEndDate;
                             caseConfig.productionLineId    = dummyProductionLineId;
                             caseConfig.productId           = dummyProductId;
                             caseConfig.trendMark = dummyCaseTrendMark;
        List<Case>     dummyCaseList  = TEST_DummyInquiryCaseFactory.createList (2, caseConfig, TEST_DummyInsertModeEnum.NONE);

        Map<String, List<Case>>     dummyGroupedCaseListByTrendKeyMap = new Map<String, List<Case>>     { dummyKey => dummyCaseList  };
        Map<String, List<Trend__c>> dummyTrendListByKeyMap            = new Map<String, List<Trend__c>>();
        
        ECICTrendMap trendMap = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                 trendMap = new ECICTrendMap(dummyGroupedCaseListByTrendKeyMap, dummyTrendListByKeyMap);
            }
            Test.stopTest();
        }        
        
        System.assertEquals (dummyCaseList, trendMap.casesWithNewTrendsListByTrendKeyMap.get(dummyKey));
        
        System.assert(trendMap.newTrendByKeyMap.containsKey(dummyKey));
        Trend__c resultTrend = trendMap.newTrendByKeyMap.get(dummyKey);
        System.assertEquals (dummyBestBeforeEndDate, resultTrend.bbe_date__c);
        System.assertEquals (dummyProductionLineId,  resultTrend.production_line__c);
        System.assertEquals (dummyProductId,         resultTrend.product__c);
    }
    
    // ------------------------------------------------------------------------------------------------

    private static testMethod void upsertTrendsTest() 
    {
        Date   dummyCaseTrendMark        = TEST_ConfigHelper.INTENTIONAL_NULL_FOR_DATE;
        
        String dummyCountryCode       = ECICCommonConstants.COUNTRY_CODE_DEFAULT;                                   // index 0
        Date   dummyBestBeforeEndDate = System.today();                                                             // index 1
        Id     dummyProductionLineId  = TEST_DummyProductionLineFactory.create(TEST_DummyInsertModeEnum.REAL).id;   // index 2
        Id     dummyProductId         = TEST_DummyProductFactory.create(TEST_DummyInsertModeEnum.REAL).id;          // index 3 
        String dummyKey               = dummyCountryCode + '_' + dummyBestBeforeEndDate + '_' +  dummyProductionLineId  + '_' +   dummyProductId;
        
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.bbeDate             = dummyBestBeforeEndDate;
                             caseConfig.productionLineId    = dummyProductionLineId;
                             caseConfig.productId           = dummyProductId;
                             caseConfig.trendMark = dummyCaseTrendMark;
        List<Case>     dummyCaseList  = TEST_DummyInquiryCaseFactory.createList (2, caseConfig, TEST_DummyInsertModeEnum.REAL);

        Map<String, List<Case>>     dummyGroupedCaseListByTrendKeyMap = new Map<String, List<Case>>     { dummyKey => dummyCaseList  };
        Map<String, List<Trend__c>> dummyTrendListByKeyMap            = new Map<String, List<Trend__c>>();
        
        ECICTrendMap trendMap = new ECICTrendMap(dummyGroupedCaseListByTrendKeyMap, dummyTrendListByKeyMap);
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                 trendMap.upsertTrends();
            }
            Test.stopTest();
        }
        
        List<Trend__c> resultTrendList = [
                                            SELECT id 
                                            FROM Trend__C 
                                            WHERE   (bbe_date__c        = :dummyBestBeforeEndDate)
                                                AND (production_line__c = :dummyProductionLineId)
                                                AND (product__c         = :dummyProductId)
                                         ];
                                         
        System.assertEquals(1, resultTrendList.size());
    }
    
    // ------------------------------------------------------------------------------------------------

    private static testMethod void attachTrendToCasesToCasesTest()
    { 
        Date   dummyCaseTrendMark     = System.today().addDays(20);

        String dummyCountryCode       = ECICCommonConstants.COUNTRY_CODE_DEFAULT;      // index 0
        Date   dummyBestBeforeEndDate = System.today();                                // index 1
        Id     dummyProductionLineId  = 'a0H110000001Tz2';                             // index 2
        Id     dummyProductId         = 'a0I11000000Y56r';                             // index 3
        String dummyKey               = dummyCountryCode + '_' + dummyBestBeforeEndDate + '_' +  dummyProductionLineId  + '_' +   dummyProductId;
        
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.bbeDate             = dummyBestBeforeEndDate;
                             caseConfig.productionLineId    = dummyProductionLineId;
                             caseConfig.productId           = dummyProductId;
                             caseConfig.trendMark = dummyCaseTrendMark;
        Case           dummyCase      = TEST_DummyInquiryCaseFactory.create (caseConfig, TEST_DummyInsertModeEnum.NONE);
        List<Case>     dummyCaseList  = new List<Case>{ dummyCase }; 
        
        TEST_DummyTrendFactory.Config trendConfig = new TEST_DummyTrendFactory.Config();
                                      trendConfig.caseCount   = 4;
                                      trendConfig.createdDate = System.today();
        Trend__c       dummyTrend     = TEST_DummyTrendFactory.create (trendConfig, TEST_DummyInsertModeEnum.MOCK);
        List<Trend__c> dummyTrendList = new List<Trend__c>{ dummyTrend };

        Map<String, List<Case>>     dummyGroupedCaseListByTrendKeyMap = new Map<String, List<Case>>     { dummyKey => dummyCaseList  };
        Map<String, List<Trend__c>> dummyTrendListByKeyMap            = new Map<String, List<Trend__c>> { dummyKey => dummyTrendList };
        
        ECICTrendMap trendMap = new ECICTrendMap(dummyGroupedCaseListByTrendKeyMap, dummyTrendListByKeyMap);
                     trendMap.casesWithNewTrendsListByTrendKeyMap.put (dummyKey, dummyCaseList);
                     trendMap.newTrendByKeyMap.put                    (dummyKey, dummyTrend);
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                 trendMap.attachTrendToCasesToCases();
            }
            Test.stopTest();
        }        

        System.assertEquals(5, dummyTrend.CaseCount__c);
        System.assert (dummyCase != null);
        ECICTrendHelperTest.assertTrendAssignedToCase (dummyTrend, dummyCase);  
    }

    // ------------------------------------------------------------------------------------------------------------
    
    private static ECICTrendMap getDummyTrendMap()
    {
        return (new ECICTrendMap(new Map<String, List<Case>>(), new Map<String, List<Trend__c>>()));
    }
}