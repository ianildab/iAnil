@isTest
private class ECICLinkCaseAndOpenAlertsMatchableTest 
{
    private static final User    TEST_RUN_USER  = ECICRunUserTestHelper.create();

    private static void matchableIsMatchedTest(Integer targetlistLength, Integer querylistLength, Set<Integer> matchPlaceSet, Set<Integer> queryNullPlaceSet)
    { 
        List<String> dummyTargetArgList = ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyArgList(targetlistLength, matchPlaceSet, null,        true);
        List<String> dummyQueryArgList  = ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyArgList(querylistLength,  matchPlaceSet, queryNullPlaceSet, false);

        ECICLinkCaseAndOpenAlertsMatchable dummyMatchable = ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyMatchable(dummyTargetArgList);

        Boolean result = null;      
        System.runAs(TEST_RUN_USER)
        {
            result = dummyMatchable.matchTo (dummyQueryArgList);
        } 
        
        Boolean expectedResult = ( (querylistLength > 0) && ECICLinkCaseAndOpenAlertsHandlerTestHelp.areAllMatchOrNull(targetlistLength, querylistLength, matchPlaceSet, queryNullPlaceSet));
        System.assertEquals (expectedResult, result); 
    }

    private static testMethod void nullArgMatchableIsMatchedTest()                           { matchableIsMatchedTest(1,    -1,     null,                   null);                   }
    private static testMethod void emptyArgMatchableIsMatchedTest()                          { matchableIsMatchedTest(1,    0,      null,                   null);                   }
    private static testMethod void oneArgMatchMatchableIsMatchedTest()                       { matchableIsMatchedTest(1,    1,      new Set<Integer>{1},    null);                   }
    private static testMethod void oneArgNullArgMatchableIsMatchedTest()                     { matchableIsMatchedTest(1,    1,      null,                   new Set<Integer>{1});    }

    private static testMethod void twoFirstMatchArgMatchMatchableIsMatchedTest()             { matchableIsMatchedTest(2,    2,      new Set<Integer>{1},    null);                   }
    private static testMethod void twoSecondMatchArgMatchMatchableIsMatchedTest()            { matchableIsMatchedTest(2,    2,      new Set<Integer>{2},    null);                   }
    private static testMethod void twoFirstNullArgMatchMatchableIsMatchedTest()              { matchableIsMatchedTest(2,    2,      null,                   new Set<Integer>{1});    }
    private static testMethod void twoSecondNullArgNullArgMatchableIsMatchedTest()           { matchableIsMatchedTest(2,    2,      null,                   new Set<Integer>{2});    }
    private static testMethod void twoBothMatchArgMatchMatchableIsMatchedTest()              { matchableIsMatchedTest(2,    2,      new Set<Integer>{1,2},  null);                   }
    private static testMethod void twoFirstMatchSecondNullArgMatchMatchableIsMatchedTest()   { matchableIsMatchedTest(2,    2,      new Set<Integer>{1},    new Set<Integer>{2});    }
    private static testMethod void twoSecondMatchFirstNullArgNullArgMatchableIsMatchedTest() { matchableIsMatchedTest(2,    2,      new Set<Integer>{2},    new Set<Integer>{1});    }
    private static testMethod void twoBothNullArgNullArgMatchableIsMatchedTest()             { matchableIsMatchedTest(2,    2,      null,                   new Set<Integer>{1, 2}); }

    private static testMethod void threeTargetfirstMatchArgMatchMatchableIsMatchedTest()                { matchableIsMatchedTest(3,     2,      new Set<Integer>{1},    null);                   }
    private static testMethod void threeTargetSecondMatchArgMatchMatchableIsMatchedTest()               { matchableIsMatchedTest(3,     2,      new Set<Integer>{2},    null);                   }
    private static testMethod void threeTargetFirstNullArgMatchMatchableIsMatchedTest()                 { matchableIsMatchedTest(3,     2,      null,                   new Set<Integer>{1});    }
    private static testMethod void threeTargetSecondNullArgNullArgMatchableIsMatchedTest()              { matchableIsMatchedTest(3,     2,      null,                   new Set<Integer>{2});    }
    private static testMethod void threeTargetBothMatchArgMatchMatchableIsMatchedTest()                 { matchableIsMatchedTest(3,     2,      new Set<Integer>{1,2},  null);                   }
    private static testMethod void threeTargetFirstMatchSecondNullArgMatchMatchableIsMatchedTest()      { matchableIsMatchedTest(3,     2,      new Set<Integer>{1},    new Set<Integer>{2});    }
    private static testMethod void threeTargetSecondMatchFirstNullArgNullArgMatchableIsMatchedTest()    { matchableIsMatchedTest(3,     2,      new Set<Integer>{2},    new Set<Integer>{1});    }
    private static testMethod void threeTargetBothNullArgNullArgMatchableIsMatchedTest()                { matchableIsMatchedTest(3,     2,      null,                   new Set<Integer>{1, 2}); }

    private static testMethod void threeQueryfirstMatchArgMatchMatchableIsMatchedTest()                 { matchableIsMatchedTest(2,     3,      new Set<Integer>{1},    null);                   }
    private static testMethod void threeQuerySecondMatchArgMatchMatchableIsMatchedTest()                { matchableIsMatchedTest(2,     3,      new Set<Integer>{2},    null);                   }
    private static testMethod void threeQueryFirstNullArgMatchMatchableIsMatchedTest()                  { matchableIsMatchedTest(2,     3,      null,                   new Set<Integer>{1});    }
    private static testMethod void threeQuerySecondNullArgNullArgMatchableIsMatchedTest()               { matchableIsMatchedTest(2,     3,      null,                   new Set<Integer>{2});    }
    private static testMethod void threeQueryBothMatchArgMatchMatchableIsMatchedTest()                  { matchableIsMatchedTest(2,     3,      new Set<Integer>{1,2},  null);                   }
    private static testMethod void threeQueryFirstMatchSecondNullArgMatchMatchableIsMatchedTest()       { matchableIsMatchedTest(2,     3,      new Set<Integer>{1},    new Set<Integer>{2});    }
    private static testMethod void threeQuerySecondMatchFirstNullArgNullArgMatchableIsMatchedTest()     { matchableIsMatchedTest(2,     3,      new Set<Integer>{2},    new Set<Integer>{1});    }
    private static testMethod void threeQueryBothNullArgNullArgMatchableIsMatchedTest()                 { matchableIsMatchedTest(2,     3,      null,                   new Set<Integer>{1, 2}); }

    // ----------------------------------------------------------------------------------------
	
    private static void matchCreationDateTest(Integer creationPosition, Integer startPosition, Integer endPosition)
    {
        Date dummyCreationDate =                        ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyDate(creationPosition);
        Date dummyStartDate    = (startPosition != 0) ? ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyDate(startPosition)         : null;
        Date dummyEndDate      = (endPosition != 0)   ? ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyDate(endPosition)       : null;
         
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            result = ECICLinkCaseAndOpenAlertsMatchable.matchCreationDate(dummyCreationDate, dummyStartDate, dummyEndDate);
        } 
        Boolean expectedResult =    ((startPosition == 0)                && (endPosition == 0))
                                 || ((startPosition == 0)                && (creationPosition <= endPosition))
                                 || ((startPosition <= creationPosition) && (endPosition == 0))
                                 || ((startPosition <= creationPosition) && (creationPosition <= endPosition));
        System.assertEquals (expectedResult, result); 
    }

    private static testMethod void justCreationDateMatchCreationDateTest()          { matchCreationDateTest(1, 0, 0); }
    private static testMethod void creationEndNoStartMatchCreationDateTest()        { matchCreationDateTest(1, 0, 1); }
    private static testMethod void creationFirstNoStartMatchCreationDateTest()      { matchCreationDateTest(1, 0, 2); }
    private static testMethod void creationStartNoEndMatchCreationDateTest()        { matchCreationDateTest(1, 1, 0); }
    private static testMethod void allMatchCreationDateTest()                       { matchCreationDateTest(1, 1, 1); }
    private static testMethod void creationStartMatchCreationDateTest()             { matchCreationDateTest(1, 1, 2); }
    private static testMethod void creationFirstNoEndMatchCreationDateTest()        { matchCreationDateTest(1, 2, 0); }
    private static testMethod void creationFirstMatchCreationDateTest()             { matchCreationDateTest(1, 2, 3); }
    private static testMethod void creationLastNoStartMatchCreationDateTest()       { matchCreationDateTest(2, 0, 1); }
    private static testMethod void creationLastNoEndStartMatchCreationDateTest()    { matchCreationDateTest(2, 1, 0); }
    private static testMethod void creationEndMatchCreationDateTest()               { matchCreationDateTest(2, 1, 2); }
    private static testMethod void creationBetweenMatchCreationDateTest()           { matchCreationDateTest(2, 1, 3); }
    private static testMethod void creationLastMatchCreationDateTest()              { matchCreationDateTest(3, 1, 2); }

    // ----------------------------------------------------------------------------------------

    private static void matchOpenAlertsAndCasesTest(Boolean hasMatchedCountry, Boolean hasMatchingArgList, Boolean hasMatchingCreateDate, Boolean hasLinkMapping)
    {
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.createdDate   = ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyDate(2);
                             caseConfig.countryCode   = 'ES';
        
        Case dummyCase                  = TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.MOCK);
        List<String>  dummyCaseArgList  = ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyArgList(1, new Set<Integer> {1}, null, false);
        List<ECICLinkCaseAndOpenAlertsConfigEntry> dummyCaseConfigEntryList      = new List<ECICLinkCaseAndOpenAlertsConfigEntry>{ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyConfigEntry(dummyCase,      dummyCaseArgList     ) };
        
        TEST_DummyOpenAlertFactory.Config openAlertConfig = new TEST_DummyOpenAlertFactory.Config();
                                          openAlertConfig.countryCodeString = (hasMatchedCountry) ? 'ES' : 'PT';
                                          openAlertConfig.startDate   = ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyDate(1);
                                          openAlertConfig.endDate     = ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyDate(hasMatchingCreateDate?3:1);
        Open_Alert__c dummyOpenAlert        = TEST_DummyOpenAlertFactory.create(openAlertConfig, TEST_DummyInsertModeEnum.MOCK); 
        List<String>  dummyOpenAlertArgList = ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyArgList(1, (hasMatchingArgList) ? (new Set<Integer> {1, 0}) : null, null, false);
        List<ECICLinkCaseAndOpenAlertsConfigEntry> dummyOpenAlertConfigEntryList = new List<ECICLinkCaseAndOpenAlertsConfigEntry>{ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyConfigEntry(dummyOpenAlert, dummyOpenAlertArgList) };

        Open_Alert_Case__c dummyOpenAlertCase       = null;
        Map<String, ID>  dummyOpenAlertCaseLinksMap = new Map<String, ID>();
        if (hasLinkMapping)
        {
             TEST_DummyOpenAlertCaseFactory.Config config = new TEST_DummyOpenAlertCaseFactory.Config(dummyCase.id, dummyOpenAlert.id);
             dummyOpenAlertCase = TEST_DummyOpenAlertCaseFactory.create (config, TEST_DummyInsertModeEnum.MOCK);
             dummyOpenAlertCaseLinksMap.put (dummyCase.id + '_' + dummyOpenAlert.id , dummyOpenAlertCase.id);
        }
        
        Map<String, List<Open_Alert_Case__c>>  resultMatchListMap = null;
        System.runAs(TEST_RUN_USER)
        {
            resultMatchListMap = ECICLinkCaseAndOpenAlertsMatchable.matchOpenAlertsAndCases(dummyCaseConfigEntryList, dummyOpenAlertConfigEntryList, dummyOpenAlertCaseLinksMap);
        }
        
        Boolean hasMatchingDummyData = hasMatchingArgList && hasMatchingCreateDate;
        
        if      (!hasMatchedCountry)                        { assertMatchOpenAlertAndCasesSublistSizes (0, 0, resultMatchListMap); }
        else if (hasMatchingDummyData && !hasLinkMapping)   
        { 
            assertMatchOpenAlertAndCasesSublistSizes (1, 0, resultMatchListMap);
            System.assertEquals (dummyCase.id, resultMatchListMap.get('openAlertLinkedCaseList')[0].case__c); 
            System.assertEquals (dummyOpenAlert.id, resultMatchListMap.get('openAlertLinkedCaseList')[0].open_alert__c); 
        }
        else if (!hasMatchingDummyData && hasLinkMapping)   
        { 
            assertMatchOpenAlertAndCasesSublistSizes (0, 1, resultMatchListMap); 
            System.assertEquals (dummyOpenAlertCase.id, resultMatchListMap.get('toDeleteOpenAlertLinkedCaseList')[0].id); 
        }
    }

    private static testMethod void countryAndMappingMatchOpenAlertsAndCasesTest()       { matchOpenAlertsAndCasesTest(true,     false,  false,  true);  }
    private static testMethod void notArgListMatchOpenAlertsAndCasesTest()              { matchOpenAlertsAndCasesTest(true,     false,  true,   true);  }
    private static testMethod void notCreationDateMatchOpenAlertsAndCasesTest()         { matchOpenAlertsAndCasesTest(true,     true,   false,  true);  }
    private static testMethod void notMappingMatchOpenAlertsAndCasesTest()              { matchOpenAlertsAndCasesTest(true,     true,   true,   false); }

    private static testMethod void allFalseMatchOpenAlertsAndCasesTest()                { matchOpenAlertsAndCasesTest(false,    false,  false,  false); }
    private static testMethod void onlyMappingMatchOpenAlertsAndCasesTest()             { matchOpenAlertsAndCasesTest(false,    false,  false,  true);  }
    private static testMethod void onlyCreationDateMatchOpenAlertsAndCasesTest()        { matchOpenAlertsAndCasesTest(false,    false,  true,   false); }
    private static testMethod void creationDateAndMappingMatchOpenAlertsAndCasesTest()  { matchOpenAlertsAndCasesTest(false,    false,  true,   true);  }
    private static testMethod void onlyArgListMatchOpenAlertsAndCasesTest()             { matchOpenAlertsAndCasesTest(false,    true,   false,  false); }
    private static testMethod void argListAndMappingMatchOpenAlertsAndCasesTest()       { matchOpenAlertsAndCasesTest(false,    true,   false,  true);  }
    private static testMethod void argListAndCreationDateMatchOpenAlertsAndCasesTest()  { matchOpenAlertsAndCasesTest(false,    true,   true,   false); }
    private static testMethod void mismatchedCountryMatchOpenAlertsAndCasesTest()       { matchOpenAlertsAndCasesTest(false,    true,   true,   true);  }

    private static testMethod void onlyCountryMatchOpenAlertsAndCasesTest()             { matchOpenAlertsAndCasesTest(true,     false,  false,  false); }
    private static testMethod void countryAndCreationDateMatchOpenAlertsAndCasesTest()  { matchOpenAlertsAndCasesTest(true,     false,  true,   false); }
    private static testMethod void countryAndArgListMatchOpenAlertsAndCasesTest()       { matchOpenAlertsAndCasesTest(true,     true,   false,  false); }
    private static testMethod void allTrueMatchOpenAlertsAndCasesTest()                 { matchOpenAlertsAndCasesTest(true,     true,   true,   true);  }

    // ----------------------------------------------------------------------------------------

    private static void assertMatchOpenAlertAndCasesSublistSizes (Integer expectedOpenAlerts, Integer expectedDeltions, Map<String, List<Open_Alert_Case__c>>  resultMatchListMap )
    {
            System.assertEquals (expectedOpenAlerts, resultMatchListMap.get('openAlertLinkedCaseList').size());
            System.assertEquals (expectedDeltions,   resultMatchListMap.get('toDeleteOpenAlertLinkedCaseList').size());
    }

}