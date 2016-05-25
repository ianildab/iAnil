@isTest
private class ECICClosedTrendHelperTest 
{
    private static final User    TEST_RUN_USER                        = TEST_DummyUserFactory.createDefaultTestRunUser();

    private static void isEqualOrFirstValueIsNullTest(Boolean hasFirstValue, Boolean hasEqualValue)
    {
        String targetValue      = 'dummy';
        String dummyFirstValue  = (hasFirstValue) ? ((hasEqualValue) ? targetValue : 'other') : null; 
        String dummySecondValue = targetValue;

        Boolean result = null;   
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = ECICClosedTrendHelper.isEqualOrFirstValueIsNull (dummyFirstValue, dummySecondValue);
            }
            Test.stopTest();
        }
        
        Boolean expectedValue = (!hasFirstValue) || (hasEqualValue);
        System.assertEquals (expectedValue, result);
    }

    private static testMethod void noFirstValueIsEqualOrFirstValueIsNullTest()        { isEqualOrFirstValueIsNullTest (false, false); }
    private static testMethod void differentFirstValueIsEqualOrFirstValueIsNullTest() { isEqualOrFirstValueIsNullTest (true , false); } 
    private static testMethod void matchingFirstValueIsEqualOrFirstValueIsNullTest()  { isEqualOrFirstValueIsNullTest (true , true ); }

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    private static void isMatchedTest(Boolean hasMatchingCountry, Boolean hasMatchingPlant, Boolean hasMatchingReason, Boolean hasMatchingProductType, Boolean hasMatchingProductDescription)
    {
        Case dummyCase = ECICClosedTrendsTrackerTestHelper.createCase();

        Closed_Trend__c dummyClosedTrend = createClosedTrend(
                        ((hasMatchingReason)             ? ECICClosedTrendsTrackerTestHelper.DUMMY_CASE_REASON         : ECICCommonConstants.QUALITY_COMPLAINT_REASON_PRODUCTS),                                                                                 
                        ((hasMatchingPlant)              ? ECICClosedTrendsTrackerTestHelper.DUMMY_PLANT_ID            : 'a0G110000000ao1'),
                        ((hasMatchingProductType)        ? ECICClosedTrendsTrackerTestHelper.DUMMY_PRODUCT_TYPE        : 'Water'),
                        ((hasMatchingProductDescription) ? ECICClosedTrendsTrackerTestHelper.DUMMY_PRODUCT_DESCRIPTION : 'Zico Natural - KO'),
                        ((hasMatchingCountry)            ? ECICClosedTrendsTrackerTestHelper.DUMMY_COUNTRY_CODE+';'    : 'Z0;')
               ); 
                                            
        Boolean result = null;    
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = ECICClosedTrendHelper.isMatched (dummyCase, dummyClosedTrend);
            }
            Test.stopTest();
        }
        
        Boolean expectedValue = hasMatchingCountry && hasMatchingPlant && hasMatchingReason && hasMatchingProductType && hasMatchingProductDescription;
        System.assertEquals (expectedValue, result);
    }

    private static testMethod void noMatchesIsMatchedTest()                     { isMatchedTest(   false,   false,   false,   false,   false     ); }
    private static testMethod void hasMatchingProductDescriptionIsMatchedTest() { isMatchedTest(   false,   false,   false,   false,   true      ); }
    private static testMethod void hasMatchingProductTypeIsMatchedTest()        { isMatchedTest(   false,   false,   false,   true ,   false     ); }
    private static testMethod void hasMatchingReasonIsMatchedTest()             { isMatchedTest(   false,   false,   true ,   false,   false     ); }
    private static testMethod void hasMatchingPlantIsMatchedTest()              { isMatchedTest(   false,   true ,   false,   false,   false     ); }
    private static testMethod void hasMatchingCountryIsMatchedTest()            { isMatchedTest(   true ,   false,   false,   false,   false     ); }
    private static testMethod void noMatchingProductDescriptionIsMatchedTest()  { isMatchedTest(   true ,   true ,   true ,   true ,   false     ); }
    private static testMethod void noMatchingProductTypeIsMatchedTest()         { isMatchedTest(   true ,   true ,   true ,   false,   true      ); }
    private static testMethod void noMatchingReasonIsMatchedTest()              { isMatchedTest(   true ,   true ,   false,   true ,   true      ); }
    private static testMethod void noMatchingPlantIsMatchedTest()               { isMatchedTest(   true ,   false,   true ,   true ,   true      ); }
    private static testMethod void noMatchingCountryIsMatchedTest()             { isMatchedTest(   false,   true ,   true ,   true ,   true      ); }
    private static testMethod void allMatchesIsMatchedTest()                    { isMatchedTest(   true ,   true ,   true ,   true ,   true      ); }

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    private static void isCaseBetweenClosedTrendDates(Boolean isCaseAfterFromDate, Boolean isCaseBeforeToDate)
    {
        Datetime       toDatetime = System.today().addDays(1);

        Integer        period     = TEST_DummyClosedTrendFactory.DEFAULT_PERIOD;
        TEST_DummyClosedTrendFactory.Config closedTrendConfig = new TEST_DummyClosedTrendFactory.Config();
                                            closedTrendConfig.period = period;
        Closed_Trend__c dummyClosedTrend = TEST_DummyClosedTrendFactory.create (closedTrendConfig, TEST_DummyInsertModeEnum.NONE);
        
        Integer  caseCreatedDateModifier = (!isCaseBeforeToDate) ? period + 1 : ( (isCaseAfterFromDate) ? -1 : 0 );
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.createdDate = ECICClosedTrendsTrackerTestHelper.convertToDate (toDatetime.addDays(caseCreatedDateModifier));  
        Case dummyCurrentCase = TEST_DummyInquiryCaseFactory.create (caseConfig, TEST_DummyInsertModeEnum.NONE);

        Boolean result = null;   
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = ECICClosedTrendHelper.isCaseBetweenClosedTrendDates (dummyCurrentCase, dummyClosedTrend, toDatetime);
            }
            Test.stopTest();
        }
        
        System.assertEquals ((isCaseAfterFromDate && isCaseBeforeToDate), result);
    }

    private static testMethod void beforeFromIsCaseBetweenClosedTrendDates() { isCaseBetweenClosedTrendDates(false, true ); }
    private static testMethod void afterToIsCaseBetweenClosedTrendDates()    { isCaseBetweenClosedTrendDates(true , false); }
    private static testMethod void betweenIsCaseBetweenClosedTrendDates()    { isCaseBetweenClosedTrendDates(true , true ); }

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    private static testMethod void createClosedTrendCaseTest()
    {
        Case            dummyCase           = TEST_DummyInquiryCaseFactory.create(TEST_DummyInsertModeEnum.MOCK);
        Closed_Trend__c dummyClosedTrend    = TEST_DummyClosedTrendFactory.create(TEST_DummyInsertModeEnum.MOCK);
        
        Closed_Trend_Case__c resultClosedTrendCase = null; 
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultClosedTrendCase = ECICClosedTrendHelper.createClosedTrendCase(dummyCase, dummyClosedTrend);
            }
            Test.stopTest();
        }
        
        assertClosedTrendCase (dummyCase, dummyClosedTrend, resultClosedTrendCase);
    }

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------


    private static testMethod void createClosedTrendCaseListTest()
    {
        Case            dummyCase           = TEST_DummyInquiryCaseFactory.create(TEST_DummyInsertModeEnum.MOCK);
        Closed_Trend__c dummyClosedTrend    = TEST_DummyClosedTrendFactory.create(TEST_DummyInsertModeEnum.MOCK);
        
        List<Closed_Trend_Case__c> resultClosedTrendCaseList = null; 
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultClosedTrendCaseList = ECICClosedTrendHelper.createClosedTrendCaseList(new List<Case> { dummyCase }, dummyClosedTrend);
            }
            Test.stopTest();
        }
        
        System.assertEquals (1, resultClosedTrendCaseList.size());
        Closed_Trend_Case__c resultClosedTrendCase = resultClosedTrendCaseList[0];
        assertClosedTrendCase (dummyCase, dummyClosedTrend, resultClosedTrendCase);
    }

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------


    private static testMethod void createClosedTrendCloneTest()
    {
        Closed_Trend__c dummyClosedTrend    = TEST_DummyClosedTrendFactory.create(TEST_DummyInsertModeEnum.MOCK);
        String          dummyAnalyzedPeriod = 'Dummy Analyzed Period';
        
        Closed_Trend__c resultClosedTrend = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultClosedTrend = ECICClosedTrendHelper.createClosedTrendClone(dummyClosedTrend, dummyAnalyzedPeriod);
            }
            Test.stopTest();
        }
        
        ECICClosedTrendsTrackerTestHelper.assertClosedTrendClone(dummyClosedTrend, resultClosedTrend, dummyAnalyzedPeriod);
    }


    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    public static Closed_Trend__c createClosedTrend(String reason, Id plantId, String productType, String productDescription, String countryCodeString)
    {
        TEST_DummyClosedTrendFactory.Config config = new TEST_DummyClosedTrendFactory.Config();
                                            config.recordTypeId       = ECICClosedTrendHelper.CLOSED_TREND_DEFINITION_RT_ID;
                                            config.caseReason         = reason;
                                            config.plantId            = plantId;
                                            config.productType        = productType;
                                            config.productDescription = productDescription;
                                            config.countryCodeString  = countryCodeString;
        return TEST_DummyClosedTrendFactory.create(config, TEST_DummyInsertModeEnum.NONE);
    }
   
    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    private static void assertClosedTrendCase (Case dummyCase, Closed_Trend__c dummyClosedTrend, Closed_Trend_Case__c resultClosedTrendCase)
    {
        System.assertEquals (dummyCase.id,                                            resultClosedTrendCase.case__c);
        System.assertEquals (dummyCase,                                               resultClosedTrendCase.case__r);
        System.assertEquals (dummyClosedTrend.id,                                     resultClosedTrendCase.closed_trend__c);
        System.assertEquals (dummyClosedTrend.name + ' / ' + dummyCase.caseNumber,    resultClosedTrendCase.name);
    }

}