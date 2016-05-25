@isTest
private class ECICOpenAlertTriggerHandlerTest 
{
    private static final User   TEST_RUN_USER       = TEST_DummyUserFactory.createDefaultTestRunUser();

    private static void constructorTest(Boolean isTriggerExecuting) 
    {
        ECICOpenAlertTriggerHandler dummyHandler = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                dummyHandler = new ECICOpenAlertTriggerHandler(isTriggerExecuting);
            }
            Test.stopTest();
        } 
        
        System.assertEquals (isTriggerExecuting, dummyHandler.isTriggerExecuting);
    }

    private static testMethod void notExecutingConstructorTest() { constructorTest(false); } 
    private static testMethod void executingConstructorTest()    { constructorTest(false); } 
    
    // ------------------------------------------------------------------------------------------------------------------

    private static void isCaseFieldsChangedTest(Boolean isChangedTest)
    {
        Open_Alert__c dummyNewOpenAlert = TEST_DummyOpenAlertFactory.create(TEST_DummyInsertModeEnum.MOCK);
        Open_Alert__c dummyOldOpenAlert = dummyNewOpenAlert.clone(true, true, true, true);
        if (isChangedTest) { dummyNewOpenAlert.Category_Level3__c = 'Changed'; }
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = ECICOpenAlertTriggerHandler.isCaseFieldsChanged(dummyNewOpenAlert, dummyOldOpenAlert);
            }
            Test.stopTest();
        }
        
        System.assertEquals (isChangedTest, result);
    }

    private static testMethod void notChangedIsCaseFieldsChangedTest() { isCaseFieldsChangedTest(false); }
    private static testMethod void changedIsCaseFieldsChangedTest()    { isCaseFieldsChangedTest(true ); }
    
    // ----------------------------------------------------------------------------------------------
    
    private static void isCaseFieldsEmptyTest(Boolean hasEmptyTest)
    {
        Open_Alert__c dummyOpenAlert = TEST_DummyOpenAlertFactory.create(TEST_DummyInsertModeEnum.MOCK);
        fillOpenAlert(dummyOpenAlert);
        if (hasEmptyTest) { dummyOpenAlert.put(ECICCommonConstants.OPEN_ALERT_CASE_FIELDS[ECICCommonConstants.OPEN_ALERT_CASE_FIELDS.size()-1].fieldPath, null); }

        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = ECICOpenAlertTriggerHandler.isCaseFieldsEmpty(dummyOpenAlert);
            }
            Test.stopTest();
        }
        System.assertEquals (hasEmptyTest, result);
    }

    private static testMethod void notEmptyisCaseFieldsEmptyTest() { isCaseFieldsEmptyTest(false); }
    private static testMethod void emptyIsCaseFieldsEmptyTest()    { isCaseFieldsEmptyTest(true);  }
    
    // ----------------------------------------------------------------------------------------------
    
    private static void isCountryCodeChangedTest(Boolean isChangedTest)
    {
        Open_Alert__c dummyNewOpenAlert = TEST_DummyOpenAlertFactory.create(TEST_DummyInsertModeEnum.MOCK);
        
        Open_Alert__c dummyOldOpenAlert = dummyNewOpenAlert.clone(false);
                      dummyOldOpenAlert.Country_Code__c = (isChangedTest) ? 'C0' : dummyNewOpenAlert.Country_Code__c;
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = ECICOpenAlertTriggerHandler.isCountryCodeChanged(dummyNewOpenAlert, dummyOldOpenAlert);
            }
            Test.stopTest();
        }
        
        System.assertEquals (isChangedTest, result);
    }

    private static testMethod void notChangedIsCountryCodeChangedTest() { isCountryCodeChangedTest(false); }
    private static testMethod void changedIsCountryCodeChangedTest()    { isCountryCodeChangedTest(true); }
    
    // ----------------------------------------------------------------------------------------------
    
    private static void isEndDateChangedTest( Boolean isNewEndNull, Boolean isNewEndEqualToOldEnd, Boolean isNewEndLessThanStart )
    {
        Date          dummyOldStartDate = System.today().addDays(-10);
        Date          dummyOldEndDate   = System.today();
        TEST_DummyOpenAlertFactory.Config config = new TEST_DummyOpenAlertFactory.Config();
                                          config.startDate = dummyOldStartDate;
                                          config.endDate   = dummyOldEndDate;
        Open_Alert__c dummyOldOpenAlert = TEST_DummyOpenAlertFactory.create(config, TEST_DummyInsertModeEnum.MOCK);
        
        Integer       dummyDaysToAddToEnd   = (isNewEndEqualToOldEnd) ? 0 : ( (isNewEndLessThanStart) ? -20 : -1 );
        Open_Alert__c dummyNewOpenAlert = dummyOldOpenAlert.clone(false);
                      dummyNewOpenAlert.Start_Date__c = (isNewEndEqualToOldEnd && isNewEndLessThanStart) ? System.today().addDays(1) : dummyOldStartDate;
                      dummyNewOpenAlert.End_Date__c   = (isNewEndNull)                                   ? null                      : dummyOldEndDate.addDays(dummyDaysToAddToEnd);

        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = ECICOpenAlertTriggerHandler.isEndDateChanged(dummyNewOpenAlert, dummyOldOpenAlert);
            }
            Test.stopTest();
        }

        Boolean expectedResult = !isNewEndNull && !isNewEndLessThanStart && !isNewEndEqualToOldEnd;
        System.assertEquals (expectedResult, result);
        
        if (isNewEndLessThanStart)
        {
            System.assertEquals (Label.End_Date_cannot_be_before_Start_Date, TEST_MockHelper.getMockString(dummyNewOpenAlert, 'error'));
        }
    }

    private static testMethod void noneTrueIsEndDateChangedTest()               { isEndDateChangedTest(false, false, false); }  // If all are false, New End Date is GREATER than old end Date
    private static testMethod void errorIsEndDateChangedTest()                  { isEndDateChangedTest(false, false, true ); }  // If true, add error
    private static testMethod void noEndChangeIsEndDateChangedTest()            { isEndDateChangedTest(false, true,  false); }  // If all are false, New End Date is GREATER than old end Date
    private static testMethod void startChangeToErrorIsEndDateChangedTest()     { isEndDateChangedTest(false, true,  true ); }  // If true, add error
    private static testMethod void newIsNullIsEndDateChangedTest()              { isEndDateChangedTest(true,  false, false); }  // If all are false, New End Date is GREATER than old end Date
    private static testMethod void oldWasAlreadyNullEndDateChangedTest()        { isEndDateChangedTest(true,  true,  false); }  // If all are false, New End Date is GREATER than old end Date
    // Note: Start can not be less than End if End is null.
        
    // ----------------------------------------------------------------------------------------------
    
    private static void isNowActiveTest(Boolean isActive, Boolean isChanged, Boolean isOldActive)
    {
        Open_Alert__c dummyOldOpenAlert = TEST_DummyOpenAlertFactory.create(TEST_DummyInsertModeEnum.MOCK);
        TEST_MockHelper.setMockBoolean(dummyOldOpenAlert.id, ECICCommonConstants.FIELD_ACTIVE, isOldActive);

        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = ECICOpenAlertTriggerHandler.isNowActive(isActive, isChanged, dummyOldOpenAlert);                    
            }
            Test.stopTest();
        }
        
        Boolean expectedResult = (isActive && (isChanged || (isActive != isOldActive)));
        System.assertEquals (expectedResult, result);
    }

    private static testMethod void noneTrueIsNowActiveTest()              { isNowActiveTest(false, false, false); }
    private static testMethod void oldActiveIsNowActiveTest()             { isNowActiveTest(false, false, true ); }
    private static testMethod void IsChangedIsNowActiveTest()             { isNowActiveTest(false, true , false); }
    private static testMethod void IsChangedAndOldActiveIsNowActiveTest() { isNowActiveTest(false, true , true ); }
    private static testMethod void IsActiveIsNowActiveTest()              { isNowActiveTest(true , false, false); }
    private static testMethod void NotChangedIsNowActiveTest()            { isNowActiveTest(true , false, true ); }
    private static testMethod void NotOldActiveIsNowActiveTest()          { isNowActiveTest(true , true , false); }
    private static testMethod void allTrueIsNowActiveTest()               { isNowActiveTest(true , true , true ); }

    // ----------------------------------------------------------------------------------------------

    private static void openAlertWithAssignedCasesRequireChangesTest(Boolean hasStartDate, Boolean isStartDateChanged, Boolean isChanged, Boolean isOpenAlertCountZero)
    {
        Date startDate = System.today();
        TEST_DummyOpenAlertFactory.Config config = new TEST_DummyOpenAlertFactory.Config();
                                          config.startDate = (!hasStartDate && !isStartDateChanged) ? TEST_ConfigHelper.INTENTIONAL_NULL_FOR_DATE : startDate;
        Open_Alert__c dummyOldOpenAlert = TEST_DummyOpenAlertFactory.create(config, TEST_DummyInsertModeEnum.MOCK);
        
        Integer       dummyDaysToAdd    = (isStartDateChanged) ? 1 : 0;
        Open_Alert__c dummyNewOpenAlert = dummyOldOpenAlert.clone(false);
                      dummyNewOpenAlert.Start_Date__c = (hasStartDate) ? startDate.addDays(dummyDaysToAdd) : null;

        Integer openAlertCount       = (isOpenAlertCountZero) ? 0 : 1;

        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = ECICOpenAlertTriggerHandler.openAlertWithAssignedCasesRequireChanges(dummyNewOpenAlert, dummyOldOpenAlert, isChanged, openAlertCount);                    
            }
            Test.stopTest();
        }
        
        Boolean isSignificantChange = ((hasStartDate && isStartDateChanged) || isChanged);
        Boolean expectedResult      = isSignificantChange && isOpenAlertCountZero;
        System.assertEquals (expectedResult, result);

        if (isSignificantChange && !isOpenAlertCountZero)
        {
            String errorMessage = TEST_MockHelper.getMockString(dummyNewOpenAlert, 'error');
            System.assertEquals (Label.Open_Alert_has_assigned_cases, errorMessage);
        }
    }

    private static testMethod void hasStartDateOpenAlertWithAssignedCasesRequireChangesTest()                     { openAlertWithAssignedCasesRequireChangesTest(true , false, false, true ); }
    private static testMethod void hasStartChangedToNullOpenAlertWithAssignedCasesRequireChangesTest()            { openAlertWithAssignedCasesRequireChangesTest(false, true , false, true ); }
    private static testMethod void bothChangedButZeroCountOpenAlertWithAssignedCasesRequireChangesTest()          { openAlertWithAssignedCasesRequireChangesTest(true , true , true , true ); }
    private static testMethod void hasChangeOpenAlertWithAssignedCasesRequireChangesTest()                        { openAlertWithAssignedCasesRequireChangesTest(false, false, true , true ); }
    private static testMethod void hasChangedStartDateOpenAlertWithAssignedCasesRequireChangesTest()              { openAlertWithAssignedCasesRequireChangesTest(true , true , false, true ); }
    private static testMethod void hasNoneOpenAlertWithAssignedCasesRequireChangesTest()                          { openAlertWithAssignedCasesRequireChangesTest(false, false, false, true ); }

    private static testMethod void hasNonZeroCountOpenAlertWithAssignedCasesRequireChangesTest()                  { openAlertWithAssignedCasesRequireChangesTest(false, false, false, false); }
    private static testMethod void hasAllOpenAlertWithAssignedCasesRequireChangesTest()                           { openAlertWithAssignedCasesRequireChangesTest(true , true , true , false); }
    private static testMethod void missingStartDateOpenAlertWithAssignedCasesRequireChangesTest()                 { openAlertWithAssignedCasesRequireChangesTest(false, true , true , false); }
    private static testMethod void startDateChangedwithNonZeroCountOpenAlertWithAssignedCasesRequireChangesTest() { openAlertWithAssignedCasesRequireChangesTest(true , true , false, false); }
    private static testMethod void unchangedNullStartDateOpenAlertWithAssignedCasesRequireChangesTest()           { openAlertWithAssignedCasesRequireChangesTest(true , false, true , false); }
    
    // ----------------------------------------------------------------------------------------------
    
    private static void buildOpenAlertCaseToUpdateListTest(Boolean requiresEmail)
    {
        Open_Alert__c                          dummyOpenAlert   = TEST_DummyOpenAlertFactory.create(TEST_DummyInsertModeEnum.MOCK);
        ECICLinkCaseAndOpenAlertsConfigEntry   dummyConfigEntry = (requiresEmail) ? ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyConfigEntry(dummyOpenAlert, null) : null;
        if (dummyConfigEntry != null) { ECICOpenAlertTriggerHandler.openAlertConfigEntryList = new List<ECICLinkCaseAndOpenAlertsConfigEntry>{ dummyConfigEntry }; }
        
        Open_Alert_Case__c dummyOpenAlertCase = TEST_DummyOpenAlertCaseFactory.create(null, dummyOpenAlert.id, TEST_DummyInsertModeEnum.MOCK);
        ECICOpenAlertTriggerHandler.matchedOpenAlertCaseListMap = new Map<String, List<Open_Alert_Case__c>>{'openAlertLinkedCaseList' => new List<Open_Alert_Case__c>{ dummyOpenAlertCase }};
        
        List<Open_Alert_Case_Update_Holder__c> resultOpenAlertCaseToUpdateList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultOpenAlertCaseToUpdateList = ECICOpenAlertTriggerHandler.buildOpenAlertCaseToUpdateList();
            }
            Test.stopTest();
        }
        
        System.assertEquals (1, resultOpenAlertCaseToUpdateList.size());
        Open_Alert_Case_Update_Holder__c resultOpenAlertCaseToUpdate = resultOpenAlertCaseToUpdateList[0];
        System.assertEquals ('Upsert',                      resultOpenAlertCaseToUpdate.type__c);
        System.assertEquals (dummyOpenAlertCase.id,         resultOpenAlertCaseToUpdate.open_alert_case__c);
        System.assertEquals (dummyOpenAlertCase.name,       resultOpenAlertCaseToUpdate.open_alert_case_name__c);
        System.assertEquals (dummyOpenAlert.id,             resultOpenAlertCaseToUpdate.open_alert__c);
        System.assertEquals (dummyOpenAlertCase.case__c,    resultOpenAlertCaseToUpdate.case__c);
        System.assertEquals (requiresEmail,                 resultOpenAlertCaseToUpdate.requires_email__c);
    }

    private static testMethod void emailNotRequiredBuildOpenAlertCaseToUpdateListTest() { buildOpenAlertCaseToUpdateListTest(false); }
    private static testMethod void emailRequiredBuildOpenAlertCaseToUpdateListTest()    { buildOpenAlertCaseToUpdateListTest(true ); }
    
    // ----------------------------------------------------------------------------------------------

    private static testMethod void buildOpenAlertCaseToDeleteListTest()
    {
        Open_Alert_Case__c dummyOpenAlertCase = TEST_DummyOpenAlertCaseFactory.create(TEST_DummyInsertModeEnum.MOCK);
        ECICOpenAlertTriggerHandler.matchedOpenAlertCaseListMap = new Map<String, List<Open_Alert_Case__c>>{'toDeleteOpenAlertLinkedCaseList' => new List<Open_Alert_Case__c>{ dummyOpenAlertCase }};
        
        List<Open_Alert_Case_Update_Holder__c> resultOpenAlertCaseToUpdateList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultOpenAlertCaseToUpdateList = ECICOpenAlertTriggerHandler.buildOpenAlertCaseToDeleteList();
            }
            Test.stopTest();
        }
        
        System.assertEquals (1, resultOpenAlertCaseToUpdateList.size());
        Open_Alert_Case_Update_Holder__c resultOpenAlertCaseToUpdate = resultOpenAlertCaseToUpdateList[0];
        System.assertEquals ('Delete',                      resultOpenAlertCaseToUpdate.type__c);
        System.assertEquals (dummyOpenAlertCase.id,         resultOpenAlertCaseToUpdate.open_alert_case__c);
    }
    
    // ----------------------------------------------------------------------------------------------

    
    private static testMethod void insertOpenAlertCaseUpdaterHoldersTest()
    {
        List<Open_Alert_Case__c> dummyOpenAlertCaseList    = TEST_DummyOpenAlertCaseFactory.createList(2, TEST_DummyInsertModeEnum.REAL);
             Open_Alert_Case__c  dummyUpdateOpenAlertCase  = dummyOpenAlertCaseList[0];
             Open_Alert_Case__c  dummyDeleteOpenAlertCase  = dummyOpenAlertCaseList[1];

        ECICOpenAlertTriggerHandler.matchedOpenAlertCaseListMap = new Map<String, List<Open_Alert_Case__c>>
        {
               'openAlertLinkedCaseList'         => new List<Open_Alert_Case__c>{ dummyUpdateOpenAlertCase },
               'toDeleteOpenAlertLinkedCaseList' => new List<Open_Alert_Case__c>{ dummyDeleteOpenAlertCase }
        };

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICOpenAlertTriggerHandler.insertOpenAlertCaseUpdaterHolders();            
            }
            Test.stopTest();
        }
        
        Set<Id> openAlertCaseIdSet = new Set<Id>{dummyUpdateOpenAlertCase.id, dummyDeleteOpenAlertCase.id};
        List<Open_Alert_Case_Update_Holder__c> holderList = [SELECT id FROM Open_Alert_Case_Update_Holder__c WHERE Open_Alert_Case__c IN :openAlertCaseIdSet];
        System.assertEquals (2, holderList.size());
    }

    // ----------------------------------------------------------------------------------------------
    
    private static testMethod void updateOpenAlertCasesTest()
    {
        List<Open_Alert_Case__c> dummyOpenAlertCaseList    = TEST_DummyOpenAlertCaseFactory.createList(2, TEST_DummyInsertModeEnum.REAL);
             Open_Alert_Case__c  dummyUpdateOpenAlertCase  = dummyOpenAlertCaseList[0];
             Open_Alert_Case__c  dummyDeleteOpenAlertCase  = dummyOpenAlertCaseList[1];

        ECICOpenAlertTriggerHandler.matchedOpenAlertCaseListMap = new Map<String, List<Open_Alert_Case__c>>
        {
               'openAlertLinkedCaseList'         => new List<Open_Alert_Case__c>{ dummyUpdateOpenAlertCase },
               'toDeleteOpenAlertLinkedCaseList' => new List<Open_Alert_Case__c>{ dummyDeleteOpenAlertCase }
        };

        List<Open_Alert_Case_Update_Holder__c> resultHolderList  = null;
        List<CronTrigger>                      resultTriggerList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICOpenAlertTriggerHandler.updateOpenAlertCases();            

                Set<Id> openAlertCaseIdSet = new Set<Id>{dummyUpdateOpenAlertCase.id, dummyDeleteOpenAlertCase.id};
                resultHolderList  = [SELECT id FROM Open_Alert_Case_Update_Holder__c WHERE Open_Alert_Case__c IN :openAlertCaseIdSet];
                resultTriggerList = [SELECT id, cronExpression FROM CronTrigger WHERE cronExpression LIKE :('% ' + ECICOpenAlertCaseUpdateSchedulable.JOB_NAME)];
            }
            Test.stopTest();
        }
        
        System.assertEquals (2, resultHolderList.size());
        System.assertEquals (1, resultTriggerList.size());
    }
    
    // ----------------------------------------------------------------------------------------------
    
    private static testMethod void buildCountMapTest()
    {
        Open_Alert__c      dummyOpenAlert   = TEST_DummyOpenAlertFactory.create(TEST_DummyInsertModeEnum.REAL);
        Id                 dummyOpenAlertId = dummyOpenAlert.id;
        Open_Alert_Case__c dummyOpenAlertCase = TEST_DummyOpenAlertCaseFactory.create(null, dummyOpenAlertId, TEST_DummyInsertModeEnum.REAL);
        
        Map<Id, Integer> resultCountMap = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCountMap = ECICOpenAlertTriggerHandler.buildCountMap(new Set<Id>{ dummyOpenAlertId });                    
            }
            Test.stopTest();
        }
        
        System.assert (resultCountMap.containsKey(dummyOpenAlertId));
        System.assertEquals (1, resultCountMap.get(dummyOpenAlertId));
    }
    
    // ----------------------------------------------------------------------------------------------

    private static testMethod void buildOpenAlertConfigEntryTest()
    {
        Open_Alert__c            dummyOpenAlert    = TEST_DummyOpenAlertFactory.create(TEST_DummyInsertModeEnum.MOCK);

        Map<String, Set<String>>             resultConditionMap         = new Map<String, Set<String>>();
        ECICLinkCaseAndOpenAlertsConfigEntry resultOpenAlertConfigEntry = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultOpenAlertConfigEntry =  ECICOpenAlertTriggerHandler.buildOpenAlertConfigEntry(dummyOpenAlert, resultConditionMap);                    
            }
            Test.stopTest();
        }
        
        System.assertEquals (dummyOpenAlert.id,  resultOpenAlertConfigEntry.id);
        System.assert       (resultConditionMap.get('Case_Reason__c').contains('\'' + dummyOpenAlert.case_reason__c + '\''));
    }
    
    // ----------------------------------------------------------------------------------------------
    
    private static testMethod void buildOpenAlertConfigEntryListTest()
    {
        Open_Alert__c            dummyOpenAlert    = TEST_DummyOpenAlertFactory.create(TEST_DummyInsertModeEnum.MOCK);
        List<Open_Alert__c>      dummyQualifiedOpenAlertList = new List<Open_Alert__c>{ dummyOpenAlert }; 

        Map<String, Set<String>>                   resultConditionMap             = new Map<String, Set<String>>();
        List<ECICLinkCaseAndOpenAlertsConfigEntry> resultOpenAlertConfigEntryList = null; 
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultOpenAlertConfigEntryList = ECICOpenAlertTriggerHandler.buildOpenAlertConfigEntryList(dummyQualifiedOpenAlertList, resultConditionMap);
            }
            Test.stopTest();
        }

        System.assertEquals (1, resultOpenAlertConfigEntryList.size());
        System.assertEquals (dummyOpenAlert.id,  resultOpenAlertConfigEntryList[0].id);
        System.assert       (resultConditionMap.get('Case_Reason__c').contains('\'' + dummyOpenAlert.case_reason__c + '\''));
    }
    
    // ----------------------------------------------------------------------------------------------
    
    private static void filterActiveOpenAlertListTest(Boolean isActive)
    {
        Open_Alert__c dummyOpenAlert = TEST_DummyOpenAlertFactory.create(TEST_DummyInsertModeEnum.MOCK);
        TEST_MockHelper.setMockBoolean(dummyOpenAlert.id, ECICCommonConstants.FIELD_ACTIVE, isActive);
        
        List<Open_Alert__c> resultActiveOpenAlertList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultActiveOpenAlertList = ECICOpenAlertTriggerHandler.filterActiveOpenAlertList (new List<Open_Alert__c>{ dummyOpenAlert });                    
            }
            Test.stopTest();
        }
        
        System.assertEquals ((isActive) ? 1 : 0, resultActiveOpenAlertList.size());
        if (isActive) { System.assertEquals (dummyOpenAlert, resultActiveOpenAlertList[0]); }
    }

    private static testMethod void inActiveFilterActiveOpenAlertListTest() { filterActiveOpenAlertListTest(false); }
    private static testMethod void activeFilterActiveOpenAlertListTest()   { filterActiveOpenAlertListTest(true ); }
    
    // ----------------------------------------------------------------------------------------------
    
    private static void filterQualifiedOpenAlertListTest(Boolean isCountryCodeChanged, Boolean isActive, Boolean isReasonChanged, Boolean hasZeroCount, Boolean isEndDateChanged)
    {
        /* TODO: Finish setting up tests to use variables above (and more, if required). */
        TEST_DummyOpenAlertFactory.Config config = new TEST_DummyOpenAlertFactory.Config();
                                          config.countryCode = ECICCommonConstants.COUNTRY_CODE_DEFAULT;
        Open_Alert__c dummyOldOpenAlert    = TEST_DummyOpenAlertFactory.create(config, TEST_DummyInsertModeEnum.MOCK);
        
        Open_Alert__c dummyNewOpenAlert    = dummyOldOpenAlert.clone(false);
                      dummyNewOpenAlert.id              =                                 dummyOldOpenAlert.id;
                      dummyNewOpenAlert.Country_Code__c = (isCountryCodeChanged) ? 'C0' : dummyOldOpenAlert.Country_Code__c;
                      
                      
        TEST_MockHelper.setMockBoolean(dummyNewOpenAlert.id, ECICCommonConstants.FIELD_ACTIVE, isActive);
        
        List<Open_Alert__c> resultOpenAlertList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultOpenAlertList = ECICOpenAlertTriggerHandler.filterQualifiedOpenAlertList (new Map<Id, Open_Alert__c>{dummyNewOpenAlert.id=>dummyNewOpenAlert}, new Map<Id, Open_Alert__c>{dummyOldOpenAlert.id=>dummyOldOpenAlert});                    
            }
            Test.stopTest();
        }
        
        /** TODO: Finish creating assertions
        Boolean requiresChange = null; // TODO
        Boolean isNowActive    = null; // TODO
        Boolean resultExpected = (!requiresChange) && (isEndDateChanged || isNowActive);        
        System.assertEquals ((resultExpected) ? 1 : 0, resultOpenAlertList.size());
        if (resultExpected) { System.assertEquals (dummyNewOpenAlert, resultOpenAlertList[0]); }
        **/
    }

/** FINISH CREATING TESTS    
    private static testMethod void hasNoneFilterQualifiedOpenAlertListTest()                    { filterQualifiedOpenAlertListTest(false, false, false, false, false); } 
    private static testMethod void isEndDateChangedFilterQualifiedOpenAlertListTest()           { filterQualifiedOpenAlertListTest(false, false, false, false, true ); } 
    private static testMethod void requiresChangeFilterQualifiedOpenAlertListTest()             { filterQualifiedOpenAlertListTest(false, false, false, true , false); } 
    private static testMethod void isChangedFilterQualifiedOpenAlertListTest()                  { filterQualifiedOpenAlertListTest(false, false, true , false, false); } 
    private static testMethod void isActiveFilterQualifiedOpenAlertListTest()                   { filterQualifiedOpenAlertListTest(false, true , false, false, false); } 
    private static testMethod void allButIsCountryCodeChangedFilterQualifiedOpenAlertListTest() { filterQualifiedOpenAlertListTest(false, true , true , true , true ); } 
    private static testMethod void isCountryCodeChangedFilterQualifiedOpenAlertListTest()       { filterQualifiedOpenAlertListTest(true , false, false, false, false); }
    private static testMethod void allButIsActiveFilterQualifiedOpenAlertListTest()             { filterQualifiedOpenAlertListTest(true , false, true , true , true ); } 
    private static testMethod void allButIsChangedFilterQualifiedOpenAlertListTest()            { filterQualifiedOpenAlertListTest(true , true , false, true , true ); } 
    private static testMethod void allButRequiresChangeFilterQualifiedOpenAlertListTest()       { filterQualifiedOpenAlertListTest(true , true , true , false, true ); } 
    private static testMethod void allButIsEndDateChangedFilterQualifiedOpenAlertListTest()     { filterQualifiedOpenAlertListTest(true , true , true , true , false); } 
    private static testMethod void hasAllFilterQualifiedOpenAlertListTest()                     { filterQualifiedOpenAlertListTest(true , true , true , true , true ); } 
**/         
    
    // ----------------------------------------------------------------------------------------------
    
    private static testMethod void getCasesTest()
    {
        /* TODO */
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                /* TODO */                    
            }
            Test.stopTest();
        }
        /* TODO */
    }
    
    // ----------------------------------------------------------------------------------------------
    
    private static testMethod void OnBeforeInsertTest()
    {
        /* TODO */
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                /* TODO */                    
            }
            Test.stopTest();
        }
        /* TODO */
    }
    
    // ----------------------------------------------------------------------------------------------
    
    private static testMethod void OnAfterInsertTest()
    {
        /* TODO */
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                /* TODO */                    
            }
            Test.stopTest();
        }
        /* TODO */
    }
    
    // ----------------------------------------------------------------------------------------------
    
    private static testMethod void OnBeforeUpdateTest()
    {
        /* TODO */
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                /* TODO */                    
            }
            Test.stopTest();
        }
        /* TODO */
    }
    
    // ----------------------------------------------------------------------------------------------

    private static void fillOpenAlert(Open_Alert__c dummyOpenAlert)
    {
        for (Schema.FieldSetMember fieldSetMember : ECICCommonConstants.OPEN_ALERT_CASE_FIELDS)
        {
            try                                 { dummyOpenAlert.put(fieldSetMember.fieldPath, 'Something');           }
            catch (System.Sobjectexception ex)  { dummyOpenAlert.put(fieldSetMember.fieldPath, (Date) System.today()); }  
        }
    }
    
    
}