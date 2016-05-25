@isTest
private class ECICTrendTrackerTest 
{
	public static final User		TEST_RUN_USER			= ECICRunUserTestHelper.create();
	
	private static final String             DUMMY_COUNTRY_CODE    = ECICCommonConstants.COUNTRY_CODE_DEFAULT;

    private static final Production_Line__c DUMMY_PRODUCTION_LINE = TEST_DummyProductionLineFactory.create(TEST_DummyInsertModeEnum.REAL);
      
    private static final List<Product__c>   DUMMY_PRODUCT_LIST    = TEST_DummyProductFactory.createList(2, new TEST_DummyProductFactory.Config(), TEST_DummyInsertModeEnum.REAL); 
    private static final Product__c         DUMMY_PRODUCT         = DUMMY_PRODUCT_LIST[0]; 
    private static final Product__c         DUMMY_OTHER_PRODUCT   = DUMMY_PRODUCT_LIST[1]; 

    private static testMethod void selectTrendListTest()
    {
    	Date                dummyFirstDate        = System.today(); 
        String              dummyFirstTrendKey    = getTrendKey(dummyFirstDate);

        Date                dummySecondDate       = System.today().addDays(-10); 
        String              dummySecondTrendKey   = getTrendKey(dummySecondDate);

        Integer             dummyCaseCount          = 30;       // Expected status => 'Verified'
        Integer             dummyClosedCaseCount    = 0;                                   
                                              
        TEST_DummyTrendFactory.Config firstConfig  = createDummyTrendConfig (dummyFirstDate,  dummyCaseCount, dummyClosedCaseCount);
        TEST_DummyTrendFactory.Config secondConfig = createDummyTrendConfig (dummySecondDate, dummyCaseCount, dummyClosedCaseCount);
        List<Trend__c> dummyTrendList = TEST_DummyTrendFactory.createList(new List<TEST_DummyTrendFactory.Config>{ firstConfig, secondConfig}, TEST_DummyInsertModeEnum.REAL);
        
        List<Trend__c> resultUnresolvedTrendList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultUnresolvedTrendList = ECICTrendTracker.selectTrendList(new Set<String>{ dummyFirstTrendKey, dummySecondTrendKey });
            }
            Test.stopTest();
        } 
        
        System.assertEquals (2,                    resultUnresolvedTrendList.size());
        System.assertEquals (dummySecondDate, resultUnresolvedTrendList[0].createdDate);   // Second dummy date is 10 days earlier than first dummy date.
        System.assertEquals (dummyFirstDate,  resultUnresolvedTrendList[1].createdDate);
    }
   
    // ------------------------------------------------------------------------------------------------------------------------

    private static testMethod void selectOtherTrendCaseListTest()
    {
        String dummyTrendKey    = getTrendKey(System.today());
    	
    	TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
    	                     config.trendKey = dummyTrendKey;
    	                     config.status   = ECICCommonConstants.STATUS_OPEN;
    	                     config.trendId  = TEST_ConfigHelper.INTENTIONAL_NULL;
        List<Case> dummyCaseList = TEST_DummyInquiryCaseFactory.createList(2, config, TEST_DummyInsertModeEnum.REAL);
        Case       dummyTriggerCase = dummyCaseList[0];   // Should NOT be selected.
        Case       dummyOtherCase   = dummyCaseList[1];   // Should BE selected.
        
        List<Case> resultOtherTrendCaseList = null; 
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultOtherTrendCaseList = ECICTrendTracker.selectOtherTrendCaseList (new Set<Id>{ dummyTriggerCase.id }, new Set<String>  { dummyTrendKey });
            }
            Test.stopTest();
        } 
        
        System.assertEquals (1,                 resultOtherTrendCaseList.size());
        System.assertEquals (dummyOtherCase.id, resultOtherTrendCaseList[0].id);
    }

    // ------------------------------------------------------------------------------------------------------------------------


    private static testMethod void updateOtherTrendCaseListTest()
    {
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.noQualityStatusChange = false;
        Case dummyCase = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.REAL);

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICTrendTracker.updateOtherTrendCaseList(new List<Case>{ dummyCase });
            }
            Test.stopTest();
        }
        
        Case resultCase = [SELECT No_Quality_Status_Change__c FROM Case WHERE id = :dummyCase.id LIMIT 1 ];
        System.assert (true, resultCase.No_Quality_Status_Change__c); 
    }

    // ------------------------------------------------------------------------------------------------------------------------

    private static void processUnresolvedTrendsTest(Boolean hasOtherCase)
    {
        Date                dummyDate        = System.today(); 
        String              dummyTrendKey    = getTrendKey(dummyDate);

        TEST_DummyTrendFactory.Config trendConfig  = createDummyTrendConfig (dummyDate,  30, 0);
        Trend__c dummyTrend = TEST_DummyTrendFactory.create(trendConfig, TEST_DummyInsertModeEnum.REAL);
        
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.trendKey = dummyTrendKey;
                             caseConfig.status   = ECICCommonConstants.STATUS_OPEN;
                             caseConfig.trendId  = TEST_ConfigHelper.INTENTIONAL_NULL;
                             caseConfig.noQualityStatusChange = false;
        List<Case> dummyCaseList = TEST_DummyInquiryCaseFactory.createList((hasOtherCase ? 2 : 1), caseConfig, TEST_DummyInsertModeEnum.REAL);
        Case       dummyTriggerCase = dummyCaseList[0];                            
        Case       dummyOtherCase   = (hasOtherCase) ? dummyCaseList[1] : null;   

        System.runAs(TEST_RUN_USER)
            {
            Test.startTest();
            {
                ECICTrendTracker.processUnresolvedTrends(new Set<String>{ dummyTrendKey } , new List<Case> { dummyTriggerCase }, new Map<ID, Case>{ dummyTriggerCase.id => dummyTriggerCase });
        } 
            Test.stopTest();
    }

        System.assertEquals (dummyTrend.id,             dummyTriggerCase.trend__c);            
        System.assertEquals (dummyTrend.createdDate,    dummyTriggerCase.trend_mark__c);
        System.assert (!dummyTriggerCase.No_Quality_Status_Change__c);
        
        if (hasOtherCase)
        {        
            Case resultOtherCase = [SELECT No_Quality_Status_Change__c, trend__c, trend_mark__c FROM Case WHERE id = :dummyOtherCase.id ];
       	    System.assert       (resultOtherCase.No_Quality_Status_Change__c);
            System.assertEquals (dummyTrend.id,             resultOtherCase.trend__c);            
            System.assertEquals (dummyTrend.createdDate,    resultOtherCase.trend_mark__c);
        } 
    }

    private static testMethod void withoutOtherCaseProcessUnresolvedTrendsTest() { processUnresolvedTrendsTest(false); }
    private static testMethod void withOtherCaseProcessUnresolvedTrendsTest()    { processUnresolvedTrendsTest(true);  }

    // ------------------------------------------------------------------------------------------------------------------------

    private static void onBeforeTest(Boolean hasOldCase, Boolean isResetRequired, Boolean isNewTrendRequired)
    {
        Trend__c        dummyTrend          = null;                             
        String          dummyTrendKey       = null;                             

            TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                                 caseConfig.status           = ECICCommonConstants.STATUS_OPEN;
                                 caseConfig.bbeDate          = System.today();
                                 caseConfig.productId        = DUMMY_PRODUCT.id;        
                                 caseConfig.productionLineId = DUMMY_PRODUCTION_LINE.id;

        Case            dummyOldCase        = null;
        List<Case>      dummyOldCaseList    = null;   
        Map<Id, Case>   dummyOldCaseByIdMap = null;
        if (hasOldCase)
        {
	        if (isResetRequired)
	        {
	            dummyTrend = TEST_DummyTrendFactory.create(TEST_DummyInsertModeEnum.REAL);                           // Reset requires old Trend Id
	            dummyTrendKey  = getTrendKey(System.today());
	            
	                             caseConfig.trendId          = dummyTrend.id;
	                             caseConfig.trendKey         = dummyTrendKey;
	        }
	    	
	        dummyOldCase        = TEST_DummyQualityComplaintCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.REAL);
            dummyOldCaseList    = new List<Case>    {   dummyOldCase    };   
            dummyOldCaseByIdMap = new Map<Id, Case> {   dummyOldCase.id =>  dummyOldCase    };
        }
    
        Case            dummyNewCase                       = (dummyOldCase != null) ? dummyOldCase.clone(false) : TEST_DummyQualityComplaintCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.NONE);
                        dummyNewCase.id                    = (dummyOldCase != null) ? dummyOldCase.id           : null;
    	                dummyNewCase.Product__c            = (isResetRequired || isNewTrendRequired)    ? DUMMY_OTHER_PRODUCT.id    : DUMMY_PRODUCT.id;    // Changing value should cause reset.
    	                dummyNewCase.Production_Line__c    = (isNewTrendRequired)   ? DUMMY_PRODUCTION_LINE.id  : null;                // New trend not required if triplet not complete.

        List<Case>      dummyNewCaseList    = new List<Case>    {   dummyNewCase    };  
        Map<Id, Case>   dummyNewCaseByIdMap = new Map<Id, Case> {   dummyNewCase.id =>  dummyNewCase    };
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICTrendTracker.onBefore(dummyNewCaseList, dummyOldCaseList, dummyNewCaseByIdMap, dummyOldCaseByIdMap); 
            }
            Test.stopTest();
        } 
        
        if (isResetRequired)
        {
	        System.assertEquals('No Risk', dummyNewCase.potential_risk__c);
	        System.assert      ((null == dummyNewCase.risk_type__c) || ('' == dummyNewCase.risk_type__c));
	        System.assertEquals(false,     dummyNewCase.the3rdComplaint__c);
	        if (!isNewTrendRequired)                                                       // if new Trends are required, these values may/will be changed again by the time of assertion
	        {
                System.assertEquals(null,      dummyNewCase.trend_key__c);
		        System.assertEquals(null,      dummyNewCase.trend_mark__c);
		        System.assertEquals(null,      dummyNewCase.trend__c);
		        System.assertEquals(true,      dummyNewCase.no_quality_status_change__c);
	        }
        }
        if (isNewTrendRequired)
        {
            System.assert (dummyNewCase.trend_key__c   != null);
            // Can't assert new trend attached without creating more Cases with the same trend key; attachment should have been proven by other tests.
            
            if (hasOldCase)
            {
                System.assert (dummyNewCase.trend_key__c   != dummyTrendKey);
                if (isResetRequired) { System.assert (dummyNewCase.trend__c       != dummyTrend.id); }
            }
        }
        // nothing to check for when neither reset nor new trends are required.
    }

    private static testMethod void hasOldCaseResetRequiredOnBeforeTest()               { onBeforeTest(   true,   true,   false ); }
    private static testMethod void hasOldCaseResetRequiredNewKeyRequiredOnBeforeTest() { onBeforeTest(   true,   true,   true  ); }
    private static testMethod void hasNothingOnBeforeTest()                            { onBeforeTest(   false,  false,  false); }
    private static testMethod void newKeyRequiredOnBeforeTest()                        { onBeforeTest(   false,  false,  true );  }
    private static testMethod void hasOldCaseOnBeforeTest()                            { onBeforeTest(   true,   false,  false ); }
    private static testMethod void hasOldCaseNewKeyRequiredOnBeforeTest()              { onBeforeTest(   true,   false,  true  ); }

    // ------------------------------------------------------------------------------------------------------------------------

    private static testMethod void recountTrendsTest()
    {
        TEST_DummyTrendFactory.Config trendConfig = new TEST_DummyTrendFactory.Config();
                                      trendConfig.caseCount       = 30;
                                      trendConfig.closedCaseCount = 30;
        Trend__c dummyTrend = TEST_DummyTrendFactory.create(TEST_DummyInsertModeEnum.REAL);
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICTrendTracker.recountTrends (new Set<Id>{ dummyTrend.id });
    }
            Test.stopTest();
        }
        
        Trend__c resultTrend = [SELECT id, caseCount__c, closedCaseCount__c FROM Trend__c WHERE id = :dummyTrend.id LIMIT 1];
        System.assertEquals (0, resultTrend.caseCount__c);
        System.assertEquals (0, resultTrend.closedCaseCount__c);
    }

    // ------------------------------------------------------------------------------------------------------------------------

    private static void onAfterTest(Boolean hasNewCaseTrend, Boolean hasOldCase, Boolean hasOldCaseTrend)
    {
    	Integer dummyInitialOpenCaseCount   = 30;
    	Integer dummyInitialClosedCaseCount = 40;
    	
        TEST_DummyTrendFactory.Config trendConfig = new TEST_DummyTrendFactory.Config();
                                      trendConfig.caseCount       = dummyInitialOpenCaseCount;
                                      trendConfig.closedCaseCount = dummyInitialClosedCaseCount;
        Trend__c dummyTrend = TEST_DummyTrendFactory.create(trendConfig, TEST_DummyInsertModeEnum.REAL);


        TEST_DummyCaseConfig dummyNewConfig = new TEST_DummyCaseConfig();
                             dummyNewConfig.status          = ECICCommonConstants.STATUS_CLOSED;
                             dummyNewConfig.infolineStatus  = ECICCommonConstants.STATUS_CLOSED;
                             dummyNewConfig.qualityStatus   = ECICCommonConstants.STATUS_CLOSED;
                             dummyNewConfig.channelOfAnswer = 'Phone';
                             dummyNewConfig.trendId         = (hasNewCaseTrend) ? dummyTrend.id : null;
        Case dummyNewCase  = TEST_DummyFastQualityComplaintCaseFactry.create(dummyNewConfig, TEST_DummyInsertModeEnum.REAL);

        Case dummyOldCase  = null;
        List<Case>      dummyOldCaseList    = null;   
        Map<Id, Case>   dummyOldCaseByIdMap = null;
        if (hasOldCase)
        {
            dummyOldCase            = dummyNewCase.clone(false);
            dummyOldCase.id         = dummyNewCase.id;
            dummyNewConfig.status   = ECICCommonConstants.STATUS_OPEN;
            dummyOldCase.Trend__c   = (hasOldCaseTrend) ? dummyTrend.id : null;
        
            dummyOldCaseList    = new List<Case>    {   dummyOldCase    };   
            dummyOldCaseByIdMap = new Map<Id, Case> {   dummyOldCase.id =>  dummyOldCase    };
        }

        List<Case>      dummyNewCaseList    = new List<Case>    {   dummyNewCase    };  
        Map<Id, Case>   dummyNewCaseByIdMap = new Map<Id, Case> {   dummyNewCase.id =>  dummyNewCase    };
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICTrendTracker.onAfter(dummyNewCaseList, dummyOldCaseList, dummyNewCaseByIdMap, dummyOldCaseByIdMap); 
            }
            Test.stopTest();
        } 

        Trend__c resultTrend = [SELECT id, caseCount__c, closedCaseCount__c FROM Trend__c WHERE id = :dummyTrend.id LIMIT 1];
        Integer expectedOpenCaseCount = (hasNewCaseTrend)
                                        ?   1
                                        : ((hasOldCaseTrend) ? 0 : dummyInitialOpenCaseCount);
        System.assertEquals (expectedOpenCaseCount, resultTrend.caseCount__c      );

        Integer expectedClosedCaseCount = (hasNewCaseTrend)
                                        ?   1
                                        : ((hasOldCaseTrend) ? 0 : dummyInitialClosedCaseCount);
        System.assertEquals (expectedClosedCaseCount, resultTrend.closedCaseCount__c);
    }
    
    private static testMethod void hasNewCaseTrendOnAfterTest()                    { onAfterTest( true,   false,  false   ); }
    private static testMethod void hasNewCaseTrendHasOldCaseOnAfterTest()          { onAfterTest( true,   true,   false   ); }
    private static testMethod void hasNewCaseTrendHasOldCaseWithTrendOnAfterTest() { onAfterTest( true,   true,   true    ); }
    
    private static testMethod void hasNothingOnAfterTest()                         { onAfterTest( false,  false,  false   ); }
    private static testMethod void hasOldCaseOnAfterTest()                         { onAfterTest( false,  true,   false   ); }
    private static testMethod void hasOldCaseWithTrendOnAfterTest()                { onAfterTest( false,  true,   true    ); }
    
    // ------------------------------------------------------------------------------------------------------------------------

    private static String getTrendKey(Date dummyDate)
    {
           return DUMMY_COUNTRY_CODE                         + '_' 
                                    + String.valueOf(dummyDate) + '_' 
                                    + ((String) (DUMMY_PRODUCTION_LINE.id)).substring(0,15)  + '_' 
                                    + ((String) (DUMMY_PRODUCT.id)).substring(0,15); 
    }
    
    private static TEST_DummyTrendFactory.Config createDummyTrendConfig (Date dummyDate, Integer dummyCaseCount, Integer dummyClosedCaseCount)
    {
        TEST_DummyTrendFactory.Config config = new TEST_DummyTrendFactory.Config();
                                      config.countryCode        = DUMMY_COUNTRY_CODE;       // Trend Key Values
                                      config.bbeDate            = dummyDate;
                                      config.productId          = DUMMY_PRODUCT.id;
                                      config.productionLineId   = DUMMY_PRODUCTION_LINE.id;
                                         
                                      config.caseCount          = dummyCaseCount;           // Status Values
                                      config.closedCaseCount    = dummyClosedCaseCount;
                                      
                                      config.createdDate        = dummyDate;                // Used to Order SOQL Result
                               return config;
    }
}