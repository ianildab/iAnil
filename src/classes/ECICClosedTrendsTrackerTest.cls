@isTest    
private class ECICClosedTrendsTrackerTest 
{
    private static final User    TEST_RUN_USER                        = TEST_DummyUserFactory.createDefaultTestRunUser();

    private static final ECICClosedTrendsTracker    TARGET_TRACKER = new ECICClosedTrendsTracker();

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    private static void buildCaseListByClosedTrendMapTest3(Boolean isDataMatched, Boolean isBetween)
    {
        Datetime       toDatetime = System.today();
        Integer         period           = TEST_DummyClosedTrendFactory.DEFAULT_PERIOD;
        Closed_Trend__c dummyClosedTrend = ECICClosedTrendsTrackerTestHelper.createClosedTrend(period);
        Case            dummyCurrentCase = ECICClosedTrendsTrackerTestHelper.createCase(isDataMatched, isBetween, toDatetime, period);

        TARGET_TRACKER.toDatetime = toDatetime;
        Map<Closed_Trend__c, List<Case>> resultCaseListByClosedTrendMap = null; 
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCaseListByClosedTrendMap = TARGET_TRACKER.buildCaseListByClosedTrendMap(dummyClosedTrend, dummyCurrentCase);
            }
            Test.stopTest();
        }
        
        Boolean mappingExpected = isDataMatched && isBetween;
        System.assertEquals (mappingExpected, resultCaseListByClosedTrendMap.containsKey(dummyClosedTrend));
        
        if (mappingExpected)
        {
        	System.assertEquals (dummyCurrentCase, resultCaseListByClosedTrendMap.get(dummyClosedTrend)[0]);
        } 
    }

    private static testMethod void bothConditionsMetBuildCaseListByClosedTrendMapTest3() { buildCaseListByClosedTrendMapTest3(true , true ); }
    private static testMethod void noConditionsMetBuildCaseListByClosedTrendMapTest3()   { buildCaseListByClosedTrendMapTest3(false, false); }
    private static testMethod void isBetweenBuildCaseListByClosedTrendMapTest3()         { buildCaseListByClosedTrendMapTest3(false, true ); }
    private static testMethod void isMatchedBuildCaseListByClosedTrendMapTest3()         { buildCaseListByClosedTrendMapTest3(true , false); }

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    private static testMethod void buildCaseListByClosedTrendMapTest2()
    {
        Datetime        toDatetime       = System.today();
        Integer         period           = TEST_DummyClosedTrendFactory.DEFAULT_PERIOD;
        Closed_Trend__c dummyClosedTrend = ECICClosedTrendsTrackerTestHelper.createClosedTrend(period);
        Case            dummyCurrentCase = ECICClosedTrendsTrackerTestHelper.createCase(true, true, toDatetime, period);
         
        TARGET_TRACKER.toDatetime = toDatetime; 
        Map<Closed_Trend__c, List<Case>> resultCaseListByClosedTrendMap = null; 
        System.runAs(TEST_RUN_USER)
            {
            Test.startTest();
            {
                resultCaseListByClosedTrendMap = TARGET_TRACKER.buildCaseListByClosedTrendMap(new List<Closed_Trend__c>{ dummyClosedTrend }, dummyCurrentCase);
        }
            Test.stopTest();
        }

        System.assert (resultCaseListByClosedTrendMap.containsKey(dummyClosedTrend));
        System.assertEquals (dummyCurrentCase, resultCaseListByClosedTrendMap.get(dummyClosedTrend)[0]);
    }

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    private static testMethod void buildCaseListByClosedTrendMapTest1()
    {
        Datetime        toDatetime       = System.today();
        Integer         period           = TEST_DummyClosedTrendFactory.DEFAULT_PERIOD;
        Closed_Trend__c dummyClosedTrend = ECICClosedTrendsTrackerTestHelper.createClosedTrend(period);
        Case            dummyCurrentCase = ECICClosedTrendsTrackerTestHelper.createCase(true, true, toDatetime, period);
        
        TARGET_TRACKER.toDatetime = toDatetime; 
        Map<Closed_Trend__c, List<Case>> resultCaseListByClosedTrendMap = null; 
        System.runAs(TEST_RUN_USER)
            {
            Test.startTest();
            {
                resultCaseListByClosedTrendMap = TARGET_TRACKER.buildCaseListByClosedTrendMap(new List<Closed_Trend__c>{ dummyClosedTrend }, new List<Case>{ dummyCurrentCase });
            }
            Test.stopTest();
        }

        System.assert (resultCaseListByClosedTrendMap.containsKey(dummyClosedTrend));
        System.assertEquals (dummyCurrentCase, resultCaseListByClosedTrendMap.get(dummyClosedTrend)[0]);
    }

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    private static testMethod void mapNewCollectionClosedTrendClonesTest()
    { 
        Integer         period           = TEST_DummyClosedTrendFactory.DEFAULT_PERIOD;
        Closed_Trend__c dummyClosedTrend = ECICClosedTrendsTrackerTestHelper.createClosedTrend(period, TEST_DummyInsertModeEnum.MOCK);
        
        Map<Id, Closed_Trend__c> dummyNewCollectionClosedTrendByParentDefinitationClosedTrendIdMap = new Map<Id, Closed_Trend__c>();
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_TRACKER.mapNewCollectionClosedTrendClones(dummyClosedTrend, dummyNewCollectionClosedTrendByParentDefinitationClosedTrendIdMap);
    }
            Test.stopTest();
        }

        ECICClosedTrendsTrackerTestHelper.assertCollectionClosedTrendByDefinitionClosedTrendIdMap (dummyClosedTrend, period, dummyNewCollectionClosedTrendByParentDefinitationClosedTrendIdMap);
    }

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    private static void buildNewCollectionClosedTrendByParentDefinitationClosedTrendIdMapTest(Boolean meetsThreshold)
            {
        Integer period    = TEST_DummyClosedTrendFactory.DEFAULT_PERIOD;
        
        TEST_DummyClosedTrendFactory.Config closedTrendConfig = new TEST_DummyClosedTrendFactory.Config();
                                            closedTrendConfig.threshold = (meetsThreshold) ? 1 : 2;
                                            closedTrendConfig.period    = period;
        Closed_Trend__c dummyClosedTrend = TEST_DummyClosedTrendFactory.create(closedTrendConfig, TEST_DummyInsertModeEnum.MOCK);                             

        Case    dummyCase = TEST_DummyInquiryCaseFactory.create(TEST_DummyInsertModeEnum.MOCK);
        Map<Closed_Trend__c, List<Case>> dummyCaseListByClosedTrendMap = new Map<Closed_Trend__c, List<Case>> { dummyClosedTrend => new List<Case>{ dummyCase } };
        
        Map<Id, Closed_Trend__c> resultNewCollectionClosedTrendByParentDefinitationClosedTrendIdMap = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultNewCollectionClosedTrendByParentDefinitationClosedTrendIdMap = TARGET_TRACKER.buildNewCollectionClosedTrendByParentDefinitationClosedTrendIdMap(dummyCaseListByClosedTrendMap); 
            }
            Test.stopTest();
        }
        
        if (meetsThreshold)
        {
            ECICClosedTrendsTrackerTestHelper.assertCollectionClosedTrendByDefinitionClosedTrendIdMap (dummyClosedTrend, period, resultNewCollectionClosedTrendByParentDefinitationClosedTrendIdMap);
        }
        else
        {
        	System.assert (!dummyCaseListByClosedTrendMap.containsKey(dummyClosedTrend));
        }
    }

    private static testMethod void doesntMeetThresholdBuildNewCollectionClosedTrendByParentDefinitationClosedTrendIdMapTest() { buildNewCollectionClosedTrendByParentDefinitationClosedTrendIdMapTest(false); }
    private static testMethod void meetsThresholdBuildNewCollectionClosedTrendByParentDefinitationClosedTrendIdMapTest()      { buildNewCollectionClosedTrendByParentDefinitationClosedTrendIdMapTest(true);  }

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    private static testMethod void insertClosedTrendCaseListAndNotifyTest()
    {
    	TEST_DummyGeneralSettingsFactory.create(TEST_DummyInsertModeEnum.REAL);
    	
    	Map<String, Closed_Trend__c> closedTrendPairMap = ECICClosedTrendsTrackerTestHelper.createClosedTrendPairMap(); 
    	Closed_Trend__c dummyDefinitionClosedTrend = closedTrendPairMap.get('definition');
        Closed_Trend__c dummyCollectionClosedTrend = closedTrendPairMap.get('collection');                             
        Case    dummyCase = TEST_DummyInquiryCaseFactory.create(TEST_DummyInsertModeEnum.REAL);

         Map<Closed_Trend__c, List<Case>> dummyCaseListByClosedTrendMap = new Map<Closed_Trend__c, List<Case>> { dummyDefinitionClosedTrend => new List<Case> { dummyCase } } ;
         
         Map<Id, Closed_Trend__c> dummyNewCollectedClosedTrendByParentDefinitationClosedTrendIdMap  = new Map<Id, Closed_Trend__c>  { dummyDefinitionClosedTrend.id => dummyCollectionClosedTrend };
         
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_TRACKER.insertClosedTrendCaseListAndNotify(dummyCaseListByClosedTrendMap, dummyNewCollectedClosedTrendByParentDefinitationClosedTrendIdMap);
            }
            Test.stopTest();
        }
        
        List<Closed_Trend_Case__c> resultClosedTrendCaseList = [ SELECT id FROM Closed_Trend_Case__c WHERE (case__c = :dummyCase.id) AND (closed_trend__c = :dummyCollectionClosedTrend.id) ];
        System.assertEquals (1, resultClosedTrendCaseList.size());
			                                           
        // TODO: assert SEPEmailSendHelper.sendMails(); ... not sure if the overhead to add this assertion is worth it.
    }

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    private static void findClosedTrends2Test(Boolean hasDefinitionList)
    {
        Datetime dummyToDateTime = System.today().addDays(1);
        Map<String, SObject> closedTrendCasePair = ECICClosedTrendsTrackerTestHelper.createClosedTrendCasePair(dummyToDateTime, hasDefinitionList);
        Closed_Trend__c dummyDefinitionClosedTrend = (Closed_Trend__c) closedTrendCasePair.get('closedTrend');
        Case            dummyCase                  = (Case)            closedTrendCasePair.get('case');

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_TRACKER.findClosedTrends(dummyToDateTime); 
            }
            Test.stopTest();
        }

        List<Closed_Trend_Case__c> resultClosedTrendCaseList = [ SELECT id FROM Closed_Trend_Case__c WHERE (case__c = :dummyCase.id) AND (closed_trend__c != :dummyDefinitionClosedTrend.id) ];
        System.assertEquals (hasDefinitionList ? 1 : 0, resultClosedTrendCaseList.size());
    }

    private static testMethod void hasDefinitionFindClosedTrends2Test() { findClosedTrends2Test(true);  }
    private static testMethod void noDefinitionFindClosedTrends2Test()  { findClosedTrends2Test(false); }

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    private static testMethod void findClosedTrends1Test()
    {
        Datetime dummyToDateTime = System.today();
        Map<String, SObject> closedTrendCasePair = ECICClosedTrendsTrackerTestHelper.createClosedTrendCasePair(dummyToDateTime, true);
        Closed_Trend__c dummyDefinitionClosedTrend = (Closed_Trend__c) closedTrendCasePair.get('closedTrend');
        Case            dummyCase                  = (Case)            closedTrendCasePair.get('case');

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_TRACKER.findClosedTrends(); 
            }
            Test.stopTest();
        }

        List<Closed_Trend_Case__c> resultClosedTrendCaseList = [ SELECT id FROM Closed_Trend_Case__c WHERE (case__c = :dummyCase.id) AND (closed_trend__c != :dummyDefinitionClosedTrend.id) ];
        System.assertEquals (1, resultClosedTrendCaseList.size());
    }

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    // @see http://www.salesforce.com/us/developer/docs/apex_workbook/Content/apex_scheduling_2.htm
    private static testMethod void executeTest()
    {
        Datetime dummyToDateTime = System.today();
        Datetime cronDateTime    = dummyToDateTime.addDays(1);
        String   cronExpression  = TEST_ScheduleHelper.convertDateTimeToCronExpression(cronDateTime); 
        
        Map<String, SObject> closedTrendCasePair = ECICClosedTrendsTrackerTestHelper.createClosedTrendCasePair(dummyToDateTime, true);
        Closed_Trend__c dummyDefinitionClosedTrend = (Closed_Trend__c) closedTrendCasePair.get('closedTrend');
        Case            dummyCase                  = (Case)            closedTrendCasePair.get('case');

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
            	String jobId = System.schedule('ScheduleApexClassTest', cronExpression, new ECICClosedTrendsTracker());  // Schedule the test job
            }
            Test.stopTest();    // Because this is a test, job *should* execute immediately after Test.stopTest().
        }

        List<Closed_Trend_Case__c> resultClosedTrendCaseList = [ SELECT id FROM Closed_Trend_Case__c WHERE (case__c = :dummyCase.id) AND (closed_trend__c != :dummyDefinitionClosedTrend.id) ];
        System.assertEquals (1, resultClosedTrendCaseList.size());
    }
}