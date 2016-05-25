@isTest
public class ECICTrendHelperTest 
{
	public static final User TEST_RUN_USER	= ECICRunUserTestHelper.create();

	private static testMethod void createTrendTest() 					 
	{ 
		Date 	dummyBestBeforeEndDate	= System.today();
		Id	 	dummyProductionLineId	= 'a0H110000001Tz2';
		Id	 	dummyProductId			= 'a0I11000000Y56r';
		String	dummyCountryCode		= ECICCommonConstants.COUNTRY_CODE_DEFAULT;	
				
		Trend__c resultTrend = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				resultTrend = ECICTrendHelper.createTrend(dummyBestBeforeEndDate, dummyProductionLineId, dummyProductId, dummyCountryCode);
			}
			Test.stopTest();
		} 
		
		System.assertEquals(dummyBestBeforeEndDate, resultTrend.bbe_date__c);
		System.assertEquals(dummyProductionLineId,  resultTrend.production_line__c);
		System.assertEquals(dummyProductId,         resultTrend.product__c);
		System.assertEquals(dummyCountryCode,       resultTrend.country_code__c);
		System.assertEquals(0,				        resultTrend.caseCount__c);
	}
	
	// ----------------------------------------------------------------------------------------------------------------------
	
	private static testMethod void getTrendKeyTest() 				 	 
	{
		Date 	dummyBestBeforeEndDate	= System.today();
		Id	 	dummyProductionLineId	= 'a0H110000001Tz2';
		Id	 	dummyProductId			= 'a0I11000000Y56r';
		String	dummyCountryCode		= ECICCommonConstants.COUNTRY_CODE_DEFAULT;	

		String resultTrendKey = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				resultTrendKey = ECICTrendHelper.getTrendKey(dummyBestBeforeEndDate, dummyProductionLineId, dummyProductId, dummyCountryCode);
			}
			Test.stopTest();
		} 
		
		String expectedTrendKey =     dummyCountryCode 						 + '_' 
									+ String.valueOf(dummyBestBeforeEndDate) + '_' 
									+ ((String) (dummyProductionLineId)).substring(0,15)  + '_' 
									+ ((String) (dummyProductId)).substring(0,15); 
									
		System.assertEquals (expectedTrendKey, resultTrendKey);
	}

	
	// ----------------------------------------------------------------------------------------------------------------------

	private static void attachTrendToCaseTest(Integer dummyInitialCaseCount) 			 
	{
		Case 		dummyCase  = TEST_DummyInquiryCaseFactory.create(TEST_DummyInsertModeEnum.NONE); 
		Trend__c 	dummyTrend = createDummyTrend(dummyInitialCaseCount, TEST_DummyInsertModeEnum.MOCK);
		
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				ECICTrendHelper.attachTrendToCase(dummyCase, dummyTrend);
			}
			Test.stopTest();
		} 

		System.assertEquals (dummyInitialCaseCount + 1, dummyTrend.caseCount__c);
		assertTrendAssignedToCase(dummyTrend,             dummyCase);
		assertRiskAssignedToCase (dummyInitialCaseCount, dummyCase);
	}

	private static testMethod void zeroCaseAttachTrendToCaseTest()  { attachTrendToCaseTest(0); }
	private static testMethod void oneCaseAttachTrendToCaseTest()   { attachTrendToCaseTest(1); }
	private static testMethod void twoCaseAttachTrendToCaseTest()   { attachTrendToCaseTest(2); }
	private static testMethod void threeCaseAttachTrendToCaseTest() { attachTrendToCaseTest(3); }
	private static testMethod void fourCaseAttachTrendToCaseTest()  { attachTrendToCaseTest(4); }
	
	// ----------------------------------------------------------------------------------------------------------------------

	private static void attachTrendsToCasesTest(Integer numberOfCases, Integer numberOfTrends, Integer dummyInitialCaseCount )
	{
		List<Case> 	dummyCaseList  = TEST_DummyInquiryCaseFactory.createList(numberOfCases, new TEST_DummyCaseConfig(), TEST_DummyInsertModeEnum.NONE);
		List<Trend__c> 	dummyTrendList = createDummyTrendList (numberOfTrends, dummyInitialCaseCount, TEST_DummyInsertModeEnum.MOCK);
		
		Map<String, Trend__c> dummyTrendByCaseMap = new Map<String, Trend__c>();
		for (Integer i = 1; i <= numberOfCases; i++)
		{
			Integer caseIndex  = i - 1;
			Integer trendIndex = (numberOfCases > numberOfTrends) ? 0 : (i - 1);
			String caseIdentifier = ECICMapHelper.createMapIdentifier(dummyCaseList[caseIndex], true);
			dummyTrendByCaseMap.put(caseIdentifier, dummyTrendList[trendIndex]);
		}
		
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				ECICTrendHelper.attachTrendsToCases(dummyCaseList, dummyTrendByCaseMap);
			}
			Test.stopTest();
		} 

		for (Case dummyCase : dummyCaseList)
		{
			Boolean  attachmentExpected    = ( (dummyInitialCaseCount > 0) || (numberOfTrends < numberOfCases) );
            String   caseIdentifier        = ECICMapHelper.createMapIdentifier(dummyCase, true);
			Trend__c expectedAttachedTrend = (attachmentExpected)
												? dummyTrendByCaseMap.get(caseIdentifier)
												: null;
			if (attachmentExpected) 
			{ 
				System.assert (dummyCase != null);
				assertTrendAssignedToCase(expectedAttachedTrend, dummyCase); 
				assertRiskAssignedToCase (dummyInitialCaseCount, dummyCase);
			}
			else 					
			{ 
				System.assertEquals (null, dummyCase.trend__c); 			   
			}
		}
	}

    public static void assertTrendAssignedToCase(Trend__c dummyTrend, Case dummyCase)
    {
        System.assertEquals (dummyTrend.id,             dummyCase.trend__c);            
        System.assertEquals (dummyTrend,                dummyCase.trend__r);            
        System.assertEquals (dummyTrend.createdDate,    dummyCase.trend_mark__c);
    }
    
    public static void assertRiskAssignedToCase(Integer dummyInitialCaseCount, Case dummyCase)
    {
        if (dummyInitialCaseCount == 2)
        {           
            System.assertEquals (true,                  dummyCase.the3rdComplaint__c);
            System.assertEquals ('High',                dummyCase.priority);
            System.assertEquals ('3rd Complaint',       dummyCase.risk_type__c);
            System.assertEquals ('High Risk',           dummyCase.potential_risk__c);
		}
	}
	
	private static testMethod void oneEachAttachTrendsToCasesTest() 		 	{ attachTrendsToCasesTest(1, 1, 0); }
	private static testMethod void oneEachOneBeforeAttachTrendsToCasesTest() 	{ attachTrendsToCasesTest(1, 1, 1); }
	private static testMethod void twoEachAttachTrendsToCasesTest() 			{ attachTrendsToCasesTest(2, 2, 0); }
	private static testMethod void twoCasesForOneTrendAttachTrendsToCasesTest() { attachTrendsToCasesTest(2, 1, 0); }

	// ----------------------------------------------------------------------------------------------------------------------

	private static void groupObjectByTrendKeyTest(Boolean hasTrendKey, Boolean isKeyInMap) 		 
	{
		String dummyKey = 'Dummy_Trend_Key';
		
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.trendKey = (hasTrendKey) ? dummyKey : TEST_ConfigHelper.INTENTIONAL_NULL; 
        Case        dummyCase  = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE);
		
		Map<String, List<Case>> dummyGroupedSObjectListByTrendKeyMap = new Map<String, List<Case>>();
		if (isKeyInMap) { dummyGroupedSObjectListByTrendKeyMap.put(dummyKey, new List<Case>()); }
		
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				ECICTrendHelper.groupObjectByTrendKey(dummyCase, dummyGroupedSObjectListByTrendKeyMap);
			}
			Test.stopTest();
		}
		
		if (hasTrendKey)      { System.assertEquals (dummyCase, dummyGroupedSObjectListByTrendKeyMap.get(dummyKey)[0]);          }
		else if (isKeyInMap)  { System.assertEquals (0,         dummyGroupedSObjectListByTrendKeyMap.get(dummyKey).size());      }
		else                  
		{ 
			System.assert       (           dummyGroupedSObjectListByTrendKeyMap.isEmpty());                 
		}
	}

	private static testMethod void neitherHasKeyGroupObjectByTrendKeyTest()	{ groupObjectByTrendKeyTest(false, false); }
    private static testMethod void mapHasKeyGroupObjectByTrendKeyTest()     { groupObjectByTrendKeyTest(false, true);  }
    private static testMethod void trendHasKeyGroupObjectByTrendKeyTest()   { groupObjectByTrendKeyTest(true,  false); }
	private static testMethod void bothHaveKeyGroupObjectByTrendKeyTest()	{ groupObjectByTrendKeyTest(true,  true);  }
	
	// ----------------------------------------------------------------------------------------------------------------------

	private static void groupObjectsByTrendKeyTest(Boolean hasTrendKey, Boolean isKeyInMap) 		 
	{
		String dummyKey = 'Dummy_Trend_Key';

		TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
							 config.trendKey = (hasTrendKey) ? dummyKey : TEST_ConfigHelper.INTENTIONAL_NULL; 
		Case 		dummyCase  = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE);
		
		Map<String, List<Case>> dummyGroupedSObjectListByTrendKeyMap = new Map<String, List<Case>>();
		if (isKeyInMap) { dummyGroupedSObjectListByTrendKeyMap.put(dummyKey, new List<Case>()); }
		
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				ECICTrendHelper.groupObjectsByTrendKey(new List<Case>{ dummyCase }, dummyGroupedSObjectListByTrendKeyMap);
			}
			Test.stopTest();
		}
		
        if (hasTrendKey)      { System.assertEquals (dummyCase, dummyGroupedSObjectListByTrendKeyMap.get(dummyKey)[0]);          }
        else if (isKeyInMap)  { System.assertEquals (0,         dummyGroupedSObjectListByTrendKeyMap.get(dummyKey).size());      }
        else                           { System.assert       (           dummyGroupedSObjectListByTrendKeyMap.isEmpty());  }
	}

	private static testMethod void neitherHasKeyGroupObjectsByTrendKeyTest()	{ groupObjectsByTrendKeyTest(false, false); }
	private static testMethod void trendHasKeyGroupObjectsByTrendKeyTest()		{ groupObjectsByTrendKeyTest(true,  false); }
    private static testMethod void mapHasKeyGroupObjectsByTrendKeyTest()        { groupObjectsByTrendKeyTest(false, true);  }
	private static testMethod void bothHaveKeyGroupObjectsByTrendKeyTest()		{ groupObjectsByTrendKeyTest(true,  true);  }

	// ----------------------------------------------------------------------------------------------------------------------

    private static void buildGroupedCaseListsByTrendKeyMapTest()          
    {
        String dummyKey = 'Dummy_Trend_Key';

        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.trendKey = dummyKey; 
        Case                dummyCase  = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE);
        List<Case>          dummyCaseList = new List<Case>{ dummyCase };
        List<List<Case>>    dummyCaseListList = new List<List<Case>>{ dummyCaseList };
        
        Map<String, List<Case>>  resultGroupedCaseListsByTrendKeyMap = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultGroupedCaseListsByTrendKeyMap = ECICTrendHelper.buildGroupedCaseListsByTrendKeyMap(dummyCaseListList);
            }
            Test.stopTest();
        }
        
        System.assert (resultGroupedCaseListsByTrendKeyMap.containsKey (dummyKey));
        
        List<Case> resultCaseList = resultGroupedCaseListsByTrendKeyMap.get (dummyKey);
        System.assertEquals (1, resultCaseList.size());
        
        Case resultCase = resultCaseList[0];
        System.assertEquals (dummyCase, resultCase);          
    }

	// ----------------------------------------------------------------------------------------------------------------------

	private static testMethod void resetTrendAttributesTest()
	{
		TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
							 config.potentialRisk  		  = 'High Risk';
							 config.riskType	   		  = '3rd Complaint';
							 config.thirdComplaint 		  = true;
							 config.trendKey	   	      = 'Dummy_Trend_Key';
							 config.trendMark	   		  = System.today();
							 config.trendId		   		  = 'a0K110000008v95';
							 config.noQualityStatusChange = false; 
		Case 		dummyCase  = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE);

		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				ECICTrendHelper.resetTrendAttributes(dummyCase);
			}
			Test.stopTest();
		} 

		System.assertEquals('No Risk', dummyCase.potential_risk__c);
		System.assertEquals(null, 	   dummyCase.risk_type__c);
		System.assertEquals(false, 	   dummyCase.the3rdComplaint__c);
		System.assertEquals(null, 	   dummyCase.trend_key__c);
		System.assertEquals(null, 	   dummyCase.trend_mark__c);
		System.assertEquals(null, 	   dummyCase.trend__c);
		System.assertEquals(true, 	   dummyCase.no_quality_status_change__c);
	}

	// ----------------------------------------------------------------------------------------------------------------------

    private static void isTripletClearedTest(Boolean hasClearedBbeDate, Boolean hasClearedProductId, Boolean hasClearedProductionLineId, Boolean oldWasNull)
    {
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.productId        = (oldWasNull) ? null   : 'a0I11000000Y562';
                             config.productionLineId = (oldWasNull) ? null   : 'a0H110000001Tz2';
                             config.bbeDate          = (oldWasNull) ? null   : System.today();
        Case dummyOldCase  = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE);

        Case dummyNewCase  = dummyOldCase.clone(false);
        if (hasClearedProductId)        { dummyNewCase.product__c          =  null; }
        if (hasClearedProductionLineId) { dummyNewCase.production_line__c  =  null; }
        if (hasClearedBbeDate)          { dummyNewCase.bbe_date__c         =  null; }
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = ECICTrendHelper.isTripletCleared(dummyNewCase, dummyOldCase);
            }
            Test.stopTest();
        } 

        Boolean expectedResult = (oldWasNull)
                                    ? (false)
                                    : (hasClearedProductId || hasClearedProductionLineId || hasClearedBbeDate);
        System.assertEquals (expectedResult, result); 
    }

    private static testMethod void hasNothingClearedIsTripletClearedTest()                           { isTripletClearedTest(false, false, false, false);  }
    private static testMethod void hasProductionLineIdClearedIsTripletClearedTest()                  { isTripletClearedTest(false, false, true , false);  }
    private static testMethod void hasProductIdClearedIsTripletClearedTest()                         { isTripletClearedTest(false, true,  false, false);  }
    private static testMethod void hasIdsClearedIsTripletClearedTest()                               { isTripletClearedTest(false, true,  true , false);  }
    private static testMethod void hasBbeDateClearedIsTripletClearedTest()                           { isTripletClearedTest(true,  false, false, false);  }
    private static testMethod void hasBbeDateAndProductionLineIdClearedIsTripletClearedTest()        { isTripletClearedTest(true,  false, true , false);  }
    private static testMethod void hasBbeDateAndProductIdClearedIsTripletClearedTest()               { isTripletClearedTest(true,  true,  false, false);  }
    private static testMethod void hasAllClearedIsTripletClearedTest()                               { isTripletClearedTest(true,  true,  true , false);  }

    private static testMethod void wasNullHasNothingClearedIsTripletClearedTest()                    { isTripletClearedTest(false, false, false, true);   }
    private static testMethod void wasNullHasProductionLineIdClearedIsTripletClearedTest()           { isTripletClearedTest(false, false, true , true);   }
    private static testMethod void wasNullHasProductIdClearedIsTripletClearedTest()                  { isTripletClearedTest(false, true,  false, true);   }
    private static testMethod void wasNullHasIdsClearedIsTripletClearedTest()                        { isTripletClearedTest(false, true,  true , true);   }
    private static testMethod void wasNullHasBbeDateClearedIsTripletClearedTest()                    { isTripletClearedTest(true,  false, false, true);   }
    private static testMethod void wasNullHasBbeDateAndProductionLineIdClearedIsTripletClearedTest() { isTripletClearedTest(true,  false, true , true);   }
    private static testMethod void wasNullHasBbeDateAndProductIdClearedIsTripletClearedTest()        { isTripletClearedTest(true,  true,  false, true);   }
    private static testMethod void wasNullHasAllClearedIsTripletClearedTest()                        { isTripletClearedTest(true,  true,  true , true);   }

    // ----------------------------------------------------------------------------------------------------------------------

    private static void isTripletChangedTest(Boolean hasChangedBbeDate, Boolean hasChangedProductId, Boolean hasChangedProductionLineId)              
    {
        TEST_DummyCaseConfig dummyNewConfig = new TEST_DummyCaseConfig();
                             dummyNewConfig.bbeDate          = System.today();
                             dummyNewConfig.productId        = 'a0I11000000Y563';
                             dummyNewConfig.productionLineId = 'a0H110000001Tz2';
        Case dummyNewCase  = TEST_DummyInquiryCaseFactory.create(dummyNewConfig, TEST_DummyInsertModeEnum.NONE);

        Case dummyOldCase  = dummyNewCase.clone(false);
            if (hasChangedBbeDate)          { dummyOldCase.bbe_date__c        = system.today().addDays(-10);  }
            if (hasChangedProductId)        { dummyOldCase.product__c         = 'a0I11000000Y574';            }
            if (hasChangedProductionLineId) { dummyOldCase.production_line__c = 'a0H110000001Tz3';            }
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = ECICTrendHelper.isTripletChanged(dummyNewCase, dummyOldCase);
            }
            Test.stopTest();
        } 

        Boolean expectedResult = hasChangedBbeDate || hasChangedProductId || hasChangedProductionLineId;
        System.assertEquals (expectedResult, result); 
    }

    private static testMethod void hasNothingChangedIsTripletChangedTest()                    { isTripletChangedTest(false, false, false); }
    private static testMethod void hasProductionLineIdChangedIsTripletChangedTest()           { isTripletChangedTest(false, false, true ); }
    private static testMethod void hasProductIdChangedIsTripletChangedTest()                  { isTripletChangedTest(false, true,  false); }
    private static testMethod void hasIdsChangedIsTripletChangedTest()                        { isTripletChangedTest(false, true,  true ); }
    private static testMethod void hasBbeDateChangedIsTripletChangedTest()                    { isTripletChangedTest(true,  false, false); }
    private static testMethod void hasBbeDateAndProductionLineIdChangedIsTripletChangedTest() { isTripletChangedTest(true,  false, true ); }
    private static testMethod void hasBbeDateAndProductIdChangedIsTripletChangedTest()        { isTripletChangedTest(true,  true,  false); }
    private static testMethod void hasAllChangedIsTripletChangedTest()                        { isTripletChangedTest(true,  true,  true ); }

    // ----------------------------------------------------------------------------------------------------------------------

    private static void isTripletCompleteTest(Boolean hasBbeDate, Boolean hasProductId, Boolean hasProductionLineId)           
    {
        TEST_DummyCaseConfig dummyNewConfig = new TEST_DummyCaseConfig();
                             dummyNewConfig.bbeDate          = (hasBbeDate)             ? System.today()    : null;
                             dummyNewConfig.productId        = (hasProductId)           ? 'a0I11000000Y564' : null;
                             dummyNewConfig.productionLineId = (hasProductionLineId)    ? 'a0H110000001Tz2' : null;
        Case dummyNewCase  = TEST_DummyInquiryCaseFactory.create(dummyNewConfig, TEST_DummyInsertModeEnum.NONE);
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = ECICTrendHelper.isTripletComplete(dummyNewCase);
            }
            Test.stopTest();
        } 

        Boolean expectedResult = hasBbeDate && hasProductId && hasProductionLineId;
        System.assertEquals (expectedResult, result); 
    }

    private static testMethod void hasNothingIsTripletCompleteTest()                    { isTripletCompleteTest(false, false, false); }
    private static testMethod void hasProductionLineIdIsTripletCompleteTest()           { isTripletCompleteTest(false, false, true ); }
    private static testMethod void hasProductIdIsTripletCompleteTest()                  { isTripletCompleteTest(false, true,  false); }
    private static testMethod void hasIdsIsTripletCompleteTest()                        { isTripletCompleteTest(false, true,  true ); }
    private static testMethod void hasBbeDateIsTripletCompleteTest()                    { isTripletCompleteTest(true,  false, false); }
    private static testMethod void hasBbeDateAndProductionLineIdIsTripletCompleteTest() { isTripletCompleteTest(true,  false, true ); }
    private static testMethod void hasBbeDateAndProductIdIsTripletCompleteTest()        { isTripletCompleteTest(true,  true,  false); }
    private static testMethod void hasAllIsTripletCompleteTest()                        { isTripletCompleteTest(true,  true,  true ); }

	// ----------------------------------------------------------------------------------------------------------------------

	private static void isResetTrendAttributesRequiredTest(Boolean hasNewCaseTrendValue, Boolean hasOldCase, Boolean hasChangedTriplet) 
	{
        TEST_DummyCaseConfig dummyNewConfig = new TEST_DummyCaseConfig();
                             dummyNewConfig.trendId          = (hasNewCaseTrendValue) ? 'a0K110000008v95' : null;
                             dummyNewConfig.bbeDate          = System.today();
                             dummyNewConfig.productId        = 'a0I11000000Y565';
                             dummyNewConfig.productionLineId = 'a0H110000001Tz2';
        Case dummyNewCase  = TEST_DummyInquiryCaseFactory.create(dummyNewConfig, TEST_DummyInsertModeEnum.NONE);

        Case dummyOldCase  = null;
        if (hasOldCase)
        {
        	dummyOldCase   = dummyNewCase.clone(false);
        	if (hasChangedTriplet) { dummyOldCase.product__c = 'a0I11000000Y571'; }
        }

        Boolean result = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				result = ECICTrendHelper.isResetTrendAttributesRequired(dummyOldCase, dummyNewCase);
			}
			Test.stopTest();
		}
		
		Boolean expectedResult = hasOldCase && hasNewCaseTrendValue && hasChangedTriplet;
		System.assertEquals (expectedResult, result); 
	}

    private static testMethod void hasNothingIsResetTrendAttributesRequiredTest()             { isResetTrendAttributesRequiredTest(false, false, false); }
    private static testMethod void hasOldIsResetTrendAttributesRequiredTest()                 { isResetTrendAttributesRequiredTest(false, true,  false); }
    private static testMethod void hasChangedTripletIsResetTrendAttributesRequiredTest()      { isResetTrendAttributesRequiredTest(false, true,  true);  }

    private static testMethod void hasNewTrendValueIsResetTrendAttributesRequiredTest()       { isResetTrendAttributesRequiredTest(true, false, false);  }
    private static testMethod void hasNewTrendValueAndOldIsResetTrendAttributesRequiredTest() { isResetTrendAttributesRequiredTest(true, true,  false);  }
    private static testMethod void hasAllIsResetTrendAttributesRequiredTest()                 { isResetTrendAttributesRequiredTest(true, true,  true);   }

    // ----------------------------------------------------------------------------------------------------------------------

	private static void isNewTrendKeyRequiredTest(String recordTypeName, String newCaseStatus, Boolean hasNewCaseTrendValue, Boolean hasCompleteTriplet, Boolean hasOldCase, Boolean hasChangedTriplet) 		 	
    {
    	
    	Id dummyRecordTypeId = TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(recordTypeName);
    	
        TEST_DummyCaseConfig dummyNewConfig = new TEST_DummyCaseConfig();
                             dummyNewConfig.recordTypeId     = dummyRecordTypeId;
                             dummyNewConfig.status           = newCaseStatus;
                             dummyNewConfig.trendId          = (hasNewCaseTrendValue) ? 'a0K110000008v95' : null;
                             dummyNewConfig.bbeDate          = (hasCompleteTriplet)   ? System.today()    : null;
                             dummyNewConfig.productId        = 'a0I11000000Y561';
                             dummyNewConfig.productionLineId = 'a0H110000001Tz2';
                             

        Case dummyNewCase  = TEST_DummyInquiryCaseFactory.create(dummyNewConfig, TEST_DummyInsertModeEnum.NONE);

        Case dummyOldCase  = null;
        if (hasOldCase)
        {
            dummyOldCase = dummyNewCase.clone(false);
            if (hasChangedTriplet) { dummyOldCase.product__c = 'a0I11000000Y572'; }
        }
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = ECICTrendHelper.isNewTrendKeyRequired(dummyOldCase, dummyNewCase);
            }
            Test.stopTest();
        }
        
        Boolean expectedResult = (
                                        ECICCaseQualityComplaintRecordTypeHelper.QUALITY_COMPLAINT_ID_SET.contains(dummyRecordTypeId)
                                     && (! ( (new Set<String>{ECICCommonConstants.STATUS_NEW, ECICCommonConstants.STATUS_CANCELLED}) .contains(newCaseStatus) ) )
                                     && ((!hasNewCaseTrendValue ))
                                     && ((!hasOldCase)                                        || (hasChangedTriplet))
                                     && (hasCompleteTriplet)
                                  );
        System.assertEquals (expectedResult, result); 
    }

    // False Expected
    // # Ecic Template Test
    private static testMethod void newInquiryIsNewTrendKeyRequiredTest()                            { isNewTrendKeyRequiredTest(ECICCommonConstants.INQUIRY_IBERIA_DEVNAME,                       ECICCommonConstants.STATUS_NEW,         false, false, false, false); }            
    private static testMethod void newInquiryWithTrendIsNewTrendKeyRequiredTest()                   { isNewTrendKeyRequiredTest(ECICCommonConstants.INQUIRY_IBERIA_DEVNAME,                       ECICCommonConstants.STATUS_NEW,         true,  false, true,  true ); }             
    private static testMethod void openInquiryWithTrendIsNewTrendKeyRequiredTest()                  { isNewTrendKeyRequiredTest(ECICCommonConstants.INQUIRY_IBERIA_DEVNAME,                       ECICCommonConstants.STATUS_OPEN,        true,  false, true,  false); }
 //   private static testMethod void openJokeIsNewTrendKeyRequiredTest()                              { isNewTrendKeyRequiredTest('Joke_Useless',                  ECICCommonConstants.STATUS_OPEN,        false, false, true,  false); }
  //  private static testMethod void openJokeWithChangedTripletIsNewTrendKeyRequiredTest()            { isNewTrendKeyRequiredTest('Joke_Useless',                  ECICCommonConstants.STATUS_OPEN,        false, false, true,  true ); }             
    private static testMethod void openNonWithTripletIsNewTrendKeyRequiredTest()                    { isNewTrendKeyRequiredTest(ECICCommonConstants.NON_QUALITY_COMPLAINT_IBERIA_DEVNAME,         ECICCommonConstants.STATUS_OPEN,        false, true, true,   true ); }             
    private static testMethod void closedNonWithTrendIsNewTrendKeyRequiredTest()                    { isNewTrendKeyRequiredTest(ECICCommonConstants.NON_QUALITY_COMPLAINT_IBERIA_DEVNAME,         ECICCommonConstants.STATUS_CLOSED,      true,  false, true,  false); }
    private static testMethod void closedNonIsNewTrendKeyRequiredTest()                             { isNewTrendKeyRequiredTest(ECICCommonConstants.NON_QUALITY_COMPLAINT_IBERIA_DEVNAME,         ECICCommonConstants.STATUS_CLOSED,      false, false, false, false); }            
    private static testMethod void newNonWithTrendIsNewTrendKeyRequiredTest()                       { isNewTrendKeyRequiredTest(ECICCommonConstants.NON_QUALITY_COMPLAINT_IBERIA_DEVNAME,         ECICCommonConstants.STATUS_NEW,         true,  false, true,  true ); }             
    private static testMethod void closedNonWithTrendWithTripletIsNewTrendKeyRequiredTest()         { isNewTrendKeyRequiredTest(ECICCommonConstants.NON_QUALITY_COMPLAINT_IBERIA_DEVNAME,         ECICCommonConstants.STATUS_CLOSED,      true,  true, true,   false); }
    private static testMethod void closedQualityIsNewTrendKeyRequiredTest()                         { isNewTrendKeyRequiredTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,             ECICCommonConstants.STATUS_CLOSED,      false, false, true,  true ); }             
    private static testMethod void cancelledQualityWithTripletIsNewTrendKeyRequiredTest()           { isNewTrendKeyRequiredTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,             ECICCommonConstants.STATUS_CANCELLED,   false, true, false,  false); }            
    private static testMethod void openQualityWithTrendIsNewTrendKeyRequiredTest()                  { isNewTrendKeyRequiredTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,             ECICCommonConstants.STATUS_OPEN,        true,  false, false, false); }            
    private static testMethod void cancelledQualityWithTrendWithTripletIsNewTrendKeyRequiredTest()  { isNewTrendKeyRequiredTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,             ECICCommonConstants.STATUS_CANCELLED,   true,  true, true,   true ); }             
    private static testMethod void closedQualityWithTrendIsNewTrendKeyRequiredTest()                { isNewTrendKeyRequiredTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,             ECICCommonConstants.STATUS_CLOSED,      true,  false, false, false); }            
    private static testMethod void openQualityWithTrendWithTripletIsNewTrendKeyRequiredTest()       { isNewTrendKeyRequiredTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,             ECICCommonConstants.STATUS_OPEN,        true,  true, false,  false); }            
    private static testMethod void closedSimplifedWithTrendWithTripletIsNewTrendKeyRequiredTest()   { isNewTrendKeyRequiredTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  ECICCommonConstants.STATUS_CLOSED,      true,  true, false,  false); }            
    private static testMethod void newSimplifiedIsNewTrendKeyRequiredTest()                         { isNewTrendKeyRequiredTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  ECICCommonConstants.STATUS_NEW,         false, false, true,  false); }
    private static testMethod void openSimplifiedWithTripletIsNewTrendKeyRequiredTest()             { isNewTrendKeyRequiredTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  ECICCommonConstants.STATUS_OPEN,        false, true, false,  false); }            
    private static testMethod void cancelledQualityWithAllTrueIsNewTrendKeyRequiredTest()           { isNewTrendKeyRequiredTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  ECICCommonConstants.STATUS_CANCELLED,   true,  true, true,   true ); }             
    private static testMethod void closedSimplifiedWithTripletIsNewTrendKeyRequiredTest()           { isNewTrendKeyRequiredTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  ECICCommonConstants.STATUS_CLOSED,      false, true, true,   false); }
  //  private static testMethod void openThanksWithTrendWithTripletIsNewTrendKeyRequiredTest()        { isNewTrendKeyRequiredTest('Thanks',                        ECICCommonConstants.STATUS_OPEN,        true,  true, true,   false); }
  //  private static testMethod void cancelledThanksWithTripletIsNewTrendKeyRequiredTest()            { isNewTrendKeyRequiredTest('Thanks',                        ECICCommonConstants.STATUS_CANCELLED,   false, true, true,   false); }

    // False Expected
    private static testMethod void openQualityExpectedTrueIsNewTrendKeyRequiredTest()               { isNewTrendKeyRequiredTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,             ECICCommonConstants.STATUS_OPEN,         false, true, false, false); }            
    private static testMethod void closedQualityExpectedTrueIsNewTrendKeyRequiredTest()             { isNewTrendKeyRequiredTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,             ECICCommonConstants.STATUS_CLOSED,       false, true, true,  true);  }            
    private static testMethod void openSimplifiedExpectedTrueIsNewTrendKeyRequiredTest()            { isNewTrendKeyRequiredTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  ECICCommonConstants.STATUS_OPEN,         true,  true, false, false); }            
    private static testMethod void closedSimplifiedExpectedTrueIsNewTrendKeyRequiredTest()          { isNewTrendKeyRequiredTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  ECICCommonConstants.STATUS_CLOSED,      false, true, false,  false); }            

	// # end of ECIC----------------------------------------------------------------------------------------------------------------------
	
	private static Trend__c createDummyTrend(Integer dummyInitialCaseCount, TEST_DummyInsertModeEnum insertMode)
	{
		TEST_DummyTrendFactory.Config trendConfig = new TEST_DummyTrendFactory.Config();
									  trendConfig.caseCount   = dummyInitialCaseCount;
									  trendConfig.createdDate = System.today();
		return TEST_DummyTrendFactory.create(trendConfig, insertMode);
	}

    private static List<Trend__c> createDummyTrendList (Integer numberOfTrends, Integer dummyInitialCaseCount, TEST_DummyInsertModeEnum insertMode)
    {
        TEST_DummyTrendFactory.Config trendConfig = new TEST_DummyTrendFactory.Config();
                                      trendConfig.caseCount   = dummyInitialCaseCount;
                                      trendConfig.createdDate = System.today();
        return TEST_DummyTrendFactory.createList  (numberOfTrends, trendConfig, insertMode);
    }

    // ----------------------------------------------------------------------------------------------------------------------

    private static testMethod void unlinkTrendCasesTest()
    {
        Trend__c    dummyTrend = TEST_DummyTrendFactory.create(TEST_DummyInsertModeEnum.REAL);

        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.trendId = dummyTrend.id;
        Case        dummyCase  = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.REAL);

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICTrendHelper.unlinkTrendCases(new List<Id> { dummyCase.id });
            }
            Test.stopTest();
        } 
        
        Case resultCase = [SELECT id, trend__c, no_quality_status_change__c FROM Case WHERE id = :dummyCase.id LIMIT 1];
        System.assertEquals (null, resultCase.trend__c);
        System.assertEquals (true, resultCase.no_quality_status_change__c);
    }
}