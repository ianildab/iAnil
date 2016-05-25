@isTest
private class ECICClosedTrendDaoTest 
{
    private static final User    TEST_RUN_USER                        = TEST_DummyUserFactory.createDefaultTestRunUser();

    private static void selectDefinitionClosedTrendListTest(Boolean isDefinition, Boolean isActive)
    {
        Closed_Trend__c dummyClosedTrend = ECICClosedTrendsTrackerTestHelper.createClosedTrend(isDefinition, isActive, TEST_DummyInsertModeEnum.REAL);
        
        List<Closed_Trend__c> resultdefinitionClosedTrendList = null; 
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultdefinitionClosedTrendList = ECICClosedTrendDao.selectDefinitionClosedTrendList();
            }
            Test.stopTest();
        }
        
        Boolean definitionExpected = isDefinition && isActive;
        System.assertEquals (definitionExpected ? 1 : 0 , resultdefinitionClosedTrendList.size());
        if (definitionExpected)
        {
            Closed_Trend__c resultClosedTrend = resultdefinitionClosedTrendList[0];
            System.assertEquals (ECICClosedTrendsTrackerTestHelper.DUMMY_COUNTRY_CODE,    resultClosedTrend.country_code__c);
            System.assertEquals (ECICClosedTrendsTrackerTestHelper.DUMMY_ADDITIONAL_TO,   resultClosedTrend.additional_to__c);
            System.assertEquals (ECICClosedTrendsTrackerTestHelper.DUMMY_CASE_REASON,     resultClosedTrend.case_reason__c);
            System.assertEquals (ECICClosedTrendsTrackerTestHelper.DUMMY_PLANT_ID,        resultClosedTrend.plant__c);
            System.assertEquals (ECICClosedTrendsTrackerTestHelper.DUMMY_PERIOD,          resultClosedTrend.period__c);
            System.assertEquals (ECICClosedTrendsTrackerTestHelper.DUMMY_THRESHOLD,       resultClosedTrend.threshold__c);
        } 
    }

    private static testMethod void inactiveNondefinitionselectDefinitionClosedTrendListTest() { selectDefinitionClosedTrendListTest(false, false); }
    private static testMethod void activeNondefinitionselectDefinitionClosedTrendListTest()   { selectDefinitionClosedTrendListTest(false, true);  }
    private static testMethod void inactiveDefinitionselectDefinitionClosedTrendListTest()    { selectDefinitionClosedTrendListTest(true,  false); }
    private static testMethod void activeDefinitionselectDefinitionClosedTrendListTest()      { selectDefinitionClosedTrendListTest(true,  true);  }
}