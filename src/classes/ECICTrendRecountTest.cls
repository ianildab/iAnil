@isTest
private class ECICTrendRecountTest 
{
    private static final User TEST_RUN_USER = ECICRunUserTestHelper.create();

    private static testMethod void selectTrendsTest() 
    {
    	 Trend__c dummyTrend = TEST_DummyTrendFactory.create(TEST_DummyInsertModeEnum.REAL);

         TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                              caseConfig.status          = ECICCommonConstants.STATUS_OPEN;
                              caseConfig.trendId = dummyTrend.id;
         Case dummyCase = TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.REAL);
    	
         ECICTrendRecount dummyTrendRecount = getDummyTrendRecount();
                          dummyTrendRecount.trendIdSet = new Set<Id>{ dummyTrend.id };
                            
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                dummyTrendRecount.selectTrends();
            }
            Test.stopTest();
         } 
         
         System.assert       (dummyTrendRecount.closeUpdateTrendByIdMap.containsKey(dummyTrend.id));
         System.assertEquals (1, dummyTrendRecount.closeUpdateTrendByIdMap.get(dummyTrend.id).cases__r.size());
         System.assertEquals (dummyCase.id, dummyTrendRecount.closeUpdateTrendByIdMap.get(dummyTrend.id).cases__r[0].id);
    }

    // ----------------------------------------------------------------------------------------------------------------------

    private static void filterTrendCaseListMapsByClosedStatusTest(Boolean isOpened) 
    {
         Trend__c dummyTrend = TEST_DummyTrendFactory.create(TEST_DummyInsertModeEnum.REAL);

         TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                              caseConfig.status          = (isOpened) ? ECICCommonConstants.STATUS_OPEN : ECICCommonConstants.STATUS_CLOSED;
                              caseConfig.channelOfAnswer = 'Phone';
                              caseConfig.trendId = dummyTrend.id;
         Case dummyCase = TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.REAL);
         
         ECICTrendRecount dummyTrendRecount = getDummyTrendRecount();
                          dummyTrendRecount.closeUpdateTrendByIdMap = new Map<Id, Trend__c>([
										                                                        SELECT id, (SELECT id, isClosed, status FROM Cases__r) 
										                                                        FROM Trend__c 
										                                                        WHERE id = :dummyTrend.id
										                                                    ]);

         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                dummyTrendRecount.filterTrendCaseListMapsByClosedStatus();
            }
            Test.stopTest();
         } 
         
         assertCaseFilteredIntoMap    (dummyTrendRecount.caseByTrendIdMap, dummyTrend.id, dummyCase); 

         if (isOpened) { assertCaseNotFilteredIntoMap (dummyTrendRecount.closedCaseByTrendIdMap, dummyTrend.id);            }
         else          { assertCaseFilteredIntoMap    (dummyTrendRecount.closedCaseByTrendIdMap, dummyTrend.id, dummyCase); }             
    }

    private static void assertCaseFilteredIntoMap (Map<Id, List<Case>> targetCaseListByTrendIdMap, Id trendId, Case dummyCase)
    {
        System.assert(targetCaseListByTrendIdMap.containsKey(trendId));
        System.assertEquals (1, targetCaseListByTrendIdMap.get(trendId).size());
        System.assertEquals (dummyCase.id, targetCaseListByTrendIdMap.get(trendId)[0].id);
    }

    private static void assertCaseNotFilteredIntoMap (Map<Id, List<Case>> targetCaseListByTrendIdMap, Id trendId)
    {
        System.assert(targetCaseListByTrendIdMap.containsKey(trendId));
        System.assertEquals (0, targetCaseListByTrendIdMap.get(trendId).size());
    }
    
    private static testMethod void closedFilterTrendCaseListMapsByClosedStatusTest() { filterTrendCaseListMapsByClosedStatusTest(false); }
    private static testMethod void openFilterTrendCaseListMapsByClosedStatusTest()   { filterTrendCaseListMapsByClosedStatusTest(true);  }
    
    // ----------------------------------------------------------------------------------------------------------------------
    
    private static void doRecountTest(Boolean hasOpenCase, Boolean hasClosedCase) 
    {
    	 TEST_DummyTrendFactory.Config trendConfig = new TEST_DummyTrendFactory.Config();
    	                               trendConfig.caseCount = 0;
         Trend__c dummyTrend = TEST_DummyTrendFactory.create(trendConfig, TEST_DummyInsertModeEnum.MOCK);

         Case      dummyCase = TEST_DummyInquiryCaseFactory.create (TEST_DummyInsertModeEnum.MOCK);

         List<Case>           dummyCaseList     = new List<Case>();
         if (hasOpenCase)   { dummyCaseList.add(dummyCase);         } 
         	
         List<Case>           dummyClosedCaseList   = new List<Case>(); 
         if (hasClosedCase) 
         { 
            dummyCaseList.add(dummyCase); 
            dummyClosedCaseList.add(dummyCase); 
         } 
         
         ECICTrendRecount dummyTrendRecount = getDummyTrendRecount();
                          dummyTrendRecount.closeUpdateTrendByIdMap = new Map<Id, Trend__c>  { dummyTrend.id => dummyTrend          };
                          dummyTrendRecount.caseByTrendIdMap        = new Map<Id, List<Case>>{ dummyTrend.id => dummyCaseList       };
                          dummyTrendRecount.closedCaseByTrendIdMap  = new Map<Id, List<Case>>{ dummyTrend.id => dummyClosedCaseList };
                          
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                dummyTrendRecount.doRecount();
            }
            Test.stopTest();
         } 

        Integer expectedCase        = ((hasOpenCase)   ? 1 : 0) + ((hasClosedCase) ? 1 : 0);
      	System.assertEquals (expectedCase,       dummyTrend.caseCount__c);

        Integer expectedClosedCase  = ((hasClosedCase) ? 1 : 0);
       	System.assertEquals (expectedClosedCase, dummyTrend.closedCaseCount__c);
    }
    
    private static testMethod void hasNeitherDoRecountTest() { doRecountTest(false, false); }
    private static testMethod void hasClosedDoRecountTest()  { doRecountTest(false, true);  }
    private static testMethod void hasOpenDoRecountTest()    { doRecountTest(true,  false); }
    private static testMethod void hasbothDoRecountTest()    { doRecountTest(true,  true);  }

    // ----------------------------------------------------------------------------------------------------------------------

    private static testMethod void constructorTest() 
    {
         Trend__c dummyTrend = TEST_DummyTrendFactory.create(TEST_DummyInsertModeEnum.REAL);

         TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                              caseConfig.status          = ECICCommonConstants.STATUS_OPEN;
                              caseConfig.trendId = dummyTrend.id;
         Case dummyCase = TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.REAL);
         
         ECICTrendRecount dummyTrendRecount = null;
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                dummyTrendRecount = new ECICTrendRecount(new Set<Id>{ dummyTrend.id }); 
            }
            Test.stopTest();
         } 
         
         List<Trend__c> trendsToUpdateList = dummyTrendRecount.trendsToUpdateList;
         System.assertEquals (1, trendsToUpdateList.size());
         
         Trend__c resultTrend = trendsToUpdateList[0];
         System.assertEquals (dummyTrend.id, resultTrend.id); 
         System.assertEquals (1,             resultTrend.caseCount__c); 
         System.assertEquals (0,             resultTrend.closedCaseCount__c); 
    }

    // ----------------------------------------------------------------------------------------------------------------------
    
    private static void updateTrendsTest(Boolean hasTrends) 
    {
         Integer dummyInitialCaseCount = 1;
         Integer dummyFinalCaseCount   = 30;
         ECICTrendRecount dummyTrendRecount = getDummyTrendRecount();

    	 Trend__c dummyTrend = null;
         if (hasTrends)
         {
             TEST_DummyTrendFactory.Config trendConfig = new TEST_DummyTrendFactory.Config();
                                           trendConfig.caseCount = dummyInitialCaseCount;
             dummyTrend = TEST_DummyTrendFactory.create(trendConfig, TEST_DummyInsertModeEnum.REAL);
         	 dummyTrend.caseCount__c = dummyFinalCaseCount;
         	 
             dummyTrendRecount.trendsToUpdateList.add(dummyTrend);
         }
    	
         System.runAs(TEST_RUN_USER)
         {
         	Test.startTest();
         	{
         		dummyTrendRecount.updateTrends();
         	}
         	Test.stopTest();
         }
         
         if (hasTrends)
         {
            Trend__c resultTrend = [SELECT id, caseCount__c FROM Trend__c WHERE id = :dummyTrend.id LIMIT 1];
            System.assertEquals (dummyFinalCaseCount, resultTrend.caseCount__c);
         }
         // else there is nothing to test for. 
    }

    private static testMethod void hasTrendsUpdateTrendsTest() { updateTrendsTest(true);  }
    private static testMethod void noTrendsUpdateTrendsTest()  { updateTrendsTest(false); }
    
    // ------------------------------------------------------------------------------------
    
    private static ECICTrendRecount getDummyTrendRecount()
    {
    	return new ECICTrendRecount(new Set<Id>());
    }
}