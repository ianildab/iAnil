@isTest
private class ECICCaseQComplBottlerNameSetterStratTest 
{
    private static final User                                    TEST_RUN_USER   = ECICRunUserTestHelper.create(); 
    private static final ECICCaseQComplBottlerNameSetterStrategy TARGET_STRATEGY = new ECICCaseQComplBottlerNameSetterStrategy();
    
    private static void needsNameChangeTest(Boolean isIdFieldPopulated, Boolean isNameFieldPopulated, Boolean hasOld, Boolean isIdFieldChanged)                 
    { 
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.bottlerAccountId = (isIdFieldPopulated)     ? '00111000004gFL4'     : TEST_ConfigHelper.INTENTIONAL_NULL;
                             config.bottlerName      = (isNameFieldPopulated)   ? 'Dummy Bottler Name'  : TEST_ConfigHelper.INTENTIONAL_NULL;
        Case   dummyNewCase      = TEST_DummyInquiryCaseFactory.create (config, TEST_DummyInsertModeEnum.NONE);
        
        Case   dummyOldCase      = null;
        if (hasOld)
        {
            dummyOldCase = dummyNewCase.clone(false);
            dummyOldCase.Bottler__c = (isIdFieldChanged) ? '00111000004gFL5' : config.bottlerAccountId;
            TEST_MockHelper.mockInsert(dummyOldCase);
            dummyNewCase.id = dummyOldCase.id;
        }
         
        String dummyIdField      = 'bottler__c';
        String dummyNameField    = 'bottler_name__c';
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = ECICCaseQComplBottlerNameSetterStrategy.needsNameChange (dummyNewCase, dummyOldCase, dummyIdField, dummyNameField);
            }
            Test.stopTest();
        }
        
        Boolean expectedResult =    (isIdFieldPopulated) 
                                &&  (
                                            (!isNameFieldPopulated)
                                        ||  ( (hasOld) && (isIdFieldChanged) ) 
                                    );
        System.assertEquals (expectedResult, result);
    }

    private static testMethod void hasNothingNeedsNameChangeTest()          { needsNameChangeTest( false,   false,  false,  false  );  }
    private static testMethod void hasOldNeedsNameChangeTest()              { needsNameChangeTest( false,   false,  true,   false  );  }
    private static testMethod void hasNameNeedsNameChangeTest()             { needsNameChangeTest( false,   true,   false,  false  );  }
    private static testMethod void hasIdNeedsNameChangeTest()               { needsNameChangeTest( true,    false,  false,  false  );  }
    private static testMethod void hasChangedIdFieldNeedsNameChangeTest()   { needsNameChangeTest( true,    false,  true,   true   );  }
    private static testMethod void hasIdAndNameNeedsNameChangeTest()        { needsNameChangeTest( true,    true,   false,  false  );  }
    private static testMethod void hasUnchangedIdFieldNeedsNameChangeTest() { needsNameChangeTest( true,    true,   true,   false  );  }
    private static testMethod void hasAllNeedsNameChangeTest()              { needsNameChangeTest( true,    true,   true,   true   );  }

    // --------------------------------------------------------------------------------------------------------------------------------
    
    private static void selectOldCaseTest(Boolean hasOldCase)                   
    { 
        Id   dummyCurrentCaseId = '50011000001FTZs';
        
        Case dummyOldCase       = TEST_DummyInquiryCaseFactory.create (TEST_DummyInsertModeEnum.NONE);
             dummyOldCase.id    = (hasOldCase) ? dummyCurrentCaseId : '50011000001FTZ1';
             
        Map<Id, Case> dummyOldCaseByIdMap = new Map<Id, Case> { dummyOldCase.id => dummyOldCase };

        Case resultCase = null;        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCase = ECICCaseQComplBottlerNameSetterStrategy.selectOldCase(dummyOldCaseByIdMap, dummyCurrentCaseId);
            }
            Test.stopTest();
        }
        
        System.assertEquals (((hasOldCase) ? dummyOldCase : null), resultCase);
    }

    private static testMethod void noOldCaseSelectOldCaseTest()  { selectOldCaseTest(false); }                   
    private static testMethod void hasOldCaseSelectOldCaseTest() { selectOldCaseTest(false); }                   

    // --------------------------------------------------------------------------------------------------------------------------------
    
    private static void setBottlerNamesTest(Boolean isBottlerInCache)                 
    { 
        Account   dummyBottlerAccount = createDummyBottlerAccount(isBottlerInCache);
    
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.bottlerAccountId = dummyBottlerAccount.id;
        Case dummyCase = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE);
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICCaseQComplBottlerNameSetterStrategy.setBottlerNames(new List<Case>{ dummyCase } );
            }
            Test.stopTest();
        }
        
        System.assertEquals(((isBottlerInCache) ? dummyBottlerAccount.name.toUpperCase() : null), dummyCase.bottler_name__c);
    }
    
    private static testMethod void bottlerNotInCacheSetBottlerNamesTest() { setBottlerNamesTest(false); }
    private static testMethod void bottlerInCacheSetBottlerNamesTest()    { setBottlerNamesTest(true);  }

    // --------------------------------------------------------------------------------------------------------------------------------
    
    private static void setRegionBottlerNamesTest(Boolean isRegionInCache)                 
    { 
        Account   dummyBottlerAccount = TEST_DummyAccountFactory.create(TEST_DummyInsertModeEnum.MOCK);
        Region__c dummyRegionOfPurchase = createDummyBottlerRegion (dummyBottlerAccount, isRegionInCache);
    
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.regionOfPurchaseId = dummyRegionOfPurchase.id;
        Case dummyCase = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE);
    
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICCaseQComplBottlerNameSetterStrategy.setRegionBottlerNames(new List<Case>{ dummyCase } );
            }
            Test.stopTest();
        }
        
        System.assertEquals(((isRegionInCache) ? dummyBottlerAccount.name.toUpperCase() : null), dummyCase.region_bottler_name__c);
    }

    private static testMethod void bottlerNotInCacheSetRegionBottlerNamesTest() { setRegionBottlerNamesTest(false); }
    private static testMethod void bottlerInCacheSetRegionBottlerNamesTest()    { setRegionBottlerNamesTest(true);  }

    // --------------------------------------------------------------------------------------------------------------------------------
    
    private static void buildCaseChangeListTest(Boolean caseNeedsChange)             
    { 
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.bottlerAccountId = '00111000004gFL4';
                             config.bottlerName      = 'Dummy Bottler Name';
        Case       dummyNewCase      = TEST_DummyInquiryCaseFactory.create (config, TEST_DummyInsertModeEnum.NONE);
        List<Case> dummyNewCasesList = new List<Case>{ dummyNewCase };
        
        Case   dummyOldCase      = dummyNewCase.clone(false);
               dummyOldCase.Bottler__c = (caseNeedsChange) ? '00111000004gFL5' : config.bottlerAccountId;
        TEST_MockHelper.mockInsert(dummyOldCase);
        Map<ID, Case> dummyOldCaseByIdMap   = new Map<ID, Case>{ dummyOldCase.id => dummyOldCase };
         
               dummyNewCase.id = dummyOldCase.id;
         
        String dummyIdField      = 'bottler__c';
        String dummyNameField    = 'bottler_name__c';

        List<Case> resultCaseList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCaseList = ECICCaseQComplBottlerNameSetterStrategy.buildCaseChangeList(dummyOldCaseByIdMap, dummyNewCasesList, dummyIdField, dummyNameField);
            }
            Test.stopTest();
        }
        
        System.assertEquals ((caseNeedsChange ? 1 : 0), resultCaseList.size());
        if (caseNeedsChange) { System.assertEquals (dummyNewCase, resultCaseList[0]); }
    }

    private static testMethod void noChangeBuildCaseChangeListTest() { buildCaseChangeListTest (false); }             
    private static testMethod void needsChangeBuildCaseChangeListTest() { buildCaseChangeListTest (true);  }             

    // --------------------------------------------------------------------------------------------------------------------------------
    
    private static void executeTest(Boolean requiresBottlerNameChange, Boolean requiresRegionBottlerNameChange)         
    { 
        Account   dummyBottlerAccount = createDummyBottlerAccount(true); 
        
        Account   dummyRegionBottlerAccount = TEST_DummyAccountFactory.create(TEST_DummyInsertModeEnum.MOCK);
        Region__c dummyRegionOfPurchase     = createDummyBottlerRegion (dummyRegionBottlerAccount, true);  
        
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.bottlerAccountId    = dummyBottlerAccount.id;
                             config.bottlerName         = 'Dummy Bottler Name';
                             config.regionOfPurchaseId  = dummyRegionOfPurchase.id;
                             config.regionBottlerName   = 'Dummy Region Bottler Name';
        Case       dummyNewCase      = TEST_DummyInquiryCaseFactory.create (config, TEST_DummyInsertModeEnum.NONE);
        List<Case> dummyNewCasesList = new List<Case>{ dummyNewCase };
        
        Case   dummyOldCase      = dummyNewCase.clone(false);
               dummyOldCase.Bottler__c            = (requiresBottlerNameChange)       ? '00111000004gFL5' : config.bottlerAccountId;
               dummyOldCase.Region_of_Purchase__c = (requiresRegionBottlerNameChange) ? 'a2C11000000Cjix' : config.regionOfPurchaseId;
        TEST_MockHelper.mockInsert(dummyOldCase);
         
               dummyNewCase.id = dummyOldCase.id;
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_STRATEGY.execute(new Map<ID, Case>{ dummyOldCase.id => dummyOldCase }, new List<Case> { dummyNewCase });   
            }
            Test.stopTest();
        }

        System.assertEquals(((requiresBottlerNameChange)       ? dummyBottlerAccount.name.toUpperCase()       : config.bottlerName      ), dummyNewCase.bottler_name__c       );
        System.assertEquals(((requiresRegionBottlerNameChange) ? dummyRegionBottlerAccount.name.toUpperCase() : config.regionBottlerName), dummyNewCase.region_bottler_name__c);
        
    }

    private static testMethod void changeNeitherExecuteTest()           { executeTest( false,  false ); }         
    private static testMethod void changeBottlerNameExecuteTest()       { executeTest( false,  true  ); }
    private static testMethod void changeRegionBottlerNameExecuteTest() { executeTest( true,   false ); }         
    private static testMethod void changeBothExecuteTest()              { executeTest( true,   true  ); }         


    // --------------------------------------------------------------------------------------------------------------------------------
    
    private static void onBeforeInsertTest(Boolean isQualityCase)         
    { 
        Account   dummyBottlerAccount = createDummyBottlerAccount(true); 
        
        Account   dummyRegionBottlerAccount = TEST_DummyAccountFactory.create(TEST_DummyInsertModeEnum.MOCK);
        Region__c dummyRegionOfPurchase     = createDummyBottlerRegion (dummyRegionBottlerAccount, true);  
        
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             /*#CICTemplateTest*/
                             config.recordTypeId        = TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(isQualityCase ? ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME :  ECICCommonConstants.INQUIRY_IBERIA_DEVNAME);
                             config.bottlerAccountId    = dummyBottlerAccount.id;
                             config.regionOfPurchaseId  = dummyRegionOfPurchase.id;
        Case       dummyNewCase      = TEST_DummyInquiryCaseFactory.create (config, TEST_DummyInsertModeEnum.NONE);
        List<Case> dummyNewCasesList = new List<Case>{ dummyNewCase };
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_STRATEGY.onBeforeInsert(new List<Case> { dummyNewCase });   
            }
            Test.stopTest();
        }

        System.assertEquals(((isQualityCase) ? dummyBottlerAccount.name.toUpperCase()       : null ), dummyNewCase.bottler_name__c       );
        System.assertEquals(((isQualityCase) ? dummyRegionBottlerAccount.name.toUpperCase() : null ), dummyNewCase.region_bottler_name__c);
    }

    private static testMethod void inquiryCaseOnBeforeInsertTest() { onBeforeInsertTest(false); }         
    private static testMethod void qualityCaseOnBeforeInsertTest() { onBeforeInsertTest(true);  }         

    // --------------------------------------------------------------------------------------------------------------------------------
    
    private static void onBeforeUpdateTest(Boolean isQualityCase)         
    { 
        Account   dummyBottlerAccount = createDummyBottlerAccount(true); 
        
        Account   dummyRegionBottlerAccount = TEST_DummyAccountFactory.create(TEST_DummyInsertModeEnum.MOCK);
        Region__c dummyRegionOfPurchase     = createDummyBottlerRegion (dummyRegionBottlerAccount, true);  
        
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             /*#CICTemplateTest*/
                             config.recordTypeId        = TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(isQualityCase ? ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME :  ECICCommonConstants.INQUIRY_IBERIA_DEVNAME);
                             config.bottlerAccountId    = dummyBottlerAccount.id;
                             config.regionOfPurchaseId  = dummyRegionOfPurchase.id;
        Case       dummyNewCase      = TEST_DummyInquiryCaseFactory.create (config, TEST_DummyInsertModeEnum.NONE);
        List<Case> dummyNewCasesList = new List<Case>{ dummyNewCase };
        
        Case   dummyOldCase      = dummyNewCase.clone(false);
               dummyOldCase.Bottler__c            = '00111000004gFL5';
               dummyOldCase.Region_of_Purchase__c = 'a2C11000000Cjix';
        TEST_MockHelper.mockInsert(dummyOldCase);
         
               dummyNewCase.id = dummyOldCase.id;
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_STRATEGY.onBeforeUpdate(new Map<ID, Case>{ dummyOldCase.id => dummyOldCase }, new Map<ID, Case>{ dummyNewCase.id => dummyNewCase });   
            }
            Test.stopTest();
        }

        System.assertEquals(((isQualityCase) ? dummyBottlerAccount.name.toUpperCase()       : null ), dummyNewCase.bottler_name__c       );
        System.assertEquals(((isQualityCase) ? dummyRegionBottlerAccount.name.toUpperCase() : null ), dummyNewCase.region_bottler_name__c);
    }

    private static testMethod void inquiryCaseOnBeforeUpdateTest() { onBeforeUpdateTest(false); }         
    private static testMethod void qualityCaseOnBeforeUpdateTest() { onBeforeUpdateTest(true);  }         

    // --------------------------------------------------------------------------------------------------------------------------------
    
    private static Account createDummyBottlerAccount(Boolean addToCache)
    {
        Account   dummyBottlerAccount = TEST_DummyAccountFactory.create(TEST_DummyInsertModeEnum.MOCK);
        if (addToCache) { ECICCaseTriggerAccountCache.bottlerAccountByIdCache.put (dummyBottlerAccount.id, dummyBottlerAccount); }
        return dummyBottlerAccount;
    }

    private static Region__c createDummyBottlerRegion (Account dummyBottlerAccount, Boolean addToCache)
    {
        Region__c dummyRegionOfPurchase = TEST_DummyRegionFactory.create(TEST_DummyInsertModeEnum.MOCK);
                  dummyRegionOfPurchase.bottler__r = dummyBottlerAccount;
        if (addToCache) { ECICCaseTriggerRegionCache.regionByIdCache.put (dummyRegionOfPurchase.id, dummyRegionOfPurchase); }
        return dummyRegionOfPurchase;
    }



}