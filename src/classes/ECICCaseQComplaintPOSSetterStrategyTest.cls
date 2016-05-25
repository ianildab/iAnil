@isTest
private class ECICCaseQComplaintPOSSetterStrategyTest 
{
    private static final User                                TEST_RUN_USER   = ECICRunUserTestHelper.create(); 
    private static final ECICCaseQComplaintPOSSetterStrategy TARGET_STRATEGY = new ECICCaseQComplaintPOSSetterStrategy();

    private static void getRegionAccountTest(Boolean isNotNullCase, Boolean caseHasPosKeyAccount, Boolean regionMapHasPosKeyAccount)                       
    {
         Account dummyPointOfSaleKeyAccount = TEST_DummyAccountFactory.createPointOfSaleKey(TEST_DummyInsertModeEnum.MOCK);

         if (regionMapHasPosKeyAccount) { TARGET_STRATEGY.regionAccountByIdMap.put (dummyPointOfSaleKeyAccount.id, dummyPointOfSaleKeyAccount); }
         
         TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                              config.pointOfSaleKeyAccountId     = (caseHasPosKeyAccount) ? dummyPointOfSaleKeyAccount.id : TEST_ConfigHelper.INTENTIONAL_NULL;
         Case dummyCase = isNotNullCase
                            ? TEST_DummyFastQualityComplaintCaseFactry.create (config, TEST_DummyInsertModeEnum.NONE)
                            : null; 
         
         Account resultRegionAccount = null;
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                 resultRegionAccount = TARGET_STRATEGY.getRegionAccount(dummyCase);
            } 
            Test.stopTest();
         } 
         
         Boolean accountExpected = isNotNullCase && caseHasPosKeyAccount && regionMapHasPosKeyAccount;
         System.assertEquals (accountExpected, dummyPointOfSaleKeyAccount == resultRegionAccount);
    }

    private static testMethod void hasNothingGetRegionAccountTest()                    { getRegionAccountTest ( false,   false,  false   ); }
    private static testMethod void regionMapHasPosKeyAccountGetRegionAccountTest()     { getRegionAccountTest ( false,   false,  true    ); }
    private static testMethod void hasCaseGetRegionAccountTest()                       { getRegionAccountTest ( true,    false,  false   ); }
    private static testMethod void hasCaseMissingPosKeyGetRegionAccountTest()          { getRegionAccountTest ( true,    false,  true    ); }
    private static testMethod void hasCaseWithPosKeyGetRegionAccountTest()             { getRegionAccountTest ( true,    true,   false   ); }
    private static testMethod void hasCaseWithPosKeyInRegionMapGetRegionAccountTest()  { getRegionAccountTest ( true,    true,   true    ); }

    // --------------------------------------------------------------------------------------------------
    
    private static void hasNewPointOfSaleDataTest (
                Boolean hasPosKeyAccount,  Boolean hasOldCase, 
                Boolean oldCaseHasDifferentPosKeyAccount, Boolean oldCaseHasDifferentPosAccount, Boolean oldCaseHasDifferentPlaceOfPurchase 
        )                       
    {
     
         TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                              config.pointOfSaleKeyAccountId = (hasPosKeyAccount) ? '00111000004gFL4'  : TEST_ConfigHelper.INTENTIONAL_NULL;
                              config.pointOfSaleAccountId    = '00111000004gFL5';
                              config.placeOfPurchase         = 'Dummy Place';
         Case dummyNewCase = TEST_DummyFastQualityComplaintCaseFactry.create (config, TEST_DummyInsertModeEnum.NONE);
     
         Case dummyOldCase = null;
         if (hasOldCase)
         {
            dummyOldCase = dummyNewCase.clone(false);
            dummyOldCase.poS_key_account__c   = (oldCaseHasDifferentPosKeyAccount)    ? '00111000004gFM4' : config.pointOfSaleKeyAccountId; 
            dummyOldCase.point_Of_sale__c     = (oldCaseHasDifferentPosAccount)       ? '00111000004gFM5' : config.pointOfSaleAccountId; 
            dummyOldCase.place_of_purchase__c = (oldCaseHasDifferentPlaceOfPurchase)  ? 'Other Place'     : config.placeOfPurchase; 
         }
         
         Boolean result = null;
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                 result = TARGET_STRATEGY.hasNewPointOfSaleData(dummyNewCase, dummyOldCase);
            } 
            Test.stopTest();
         }
         
         Boolean expectedResult =  (!hasPosKeyAccount) || (!hasOldCase) || (oldCaseHasDifferentPosKeyAccount) || (oldCaseHasDifferentPosAccount) || (oldCaseHasDifferentPlaceOfPurchase);
         System.assertEquals(expectedResult, result);

    }
    
    private static testMethod void hasNothingHasNewPointOfSaleDataTest()                            { hasNewPointOfSaleDataTest( false,  false,  false,  false,  false   ); }
    private static testMethod void hasOldCaseHasNewPointOfSaleDataTest()                            { hasNewPointOfSaleDataTest( false,  true,   false,  false,  false   ); }
    private static testMethod void hasPosKeyHasNewPointOfSaleDataTest()                             { hasNewPointOfSaleDataTest( true,   false,  false,  false,  false   ); }
    private static testMethod void hasPosKeyAndOldCaseHasNewPointOfSaleDataTest()                   { hasNewPointOfSaleDataTest( true,   true,   false,  false,  false   ); }

    private static testMethod void hasOldCaseAndDifferentPlaceHasNewPointOfSaleDataTest()           { hasNewPointOfSaleDataTest( false,  true,   false,  false,  true    ); }
    private static testMethod void hasPosKeyAndOldCaseAndDifferentPlaceHasNewPointOfSaleDataTest()  { hasNewPointOfSaleDataTest( true,   true,   false,  false,  true    ); }
    
    private static testMethod void hasOldCaseAndDifferentPosHasNewPointOfSaleDataTest()             { hasNewPointOfSaleDataTest( false,  true,   false,  true,  false    ); }
    private static testMethod void hasPosKeyAndOldCaseAndDifferentPosHasNewPointOfSaleDataTest()    { hasNewPointOfSaleDataTest( true,   true,   false,  true,  false    ); }
    
    private static testMethod void hasOldCaseAndDifferentPosKeyHasNewPointOfSaleDataTest()          { hasNewPointOfSaleDataTest( false,  true,   true,  false,  false    ); }
    private static testMethod void hasPosKeyAndOldCaseAndDifferentPosKetHasNewPointOfSaleDataTest() { hasNewPointOfSaleDataTest( true,   true,   true,  false,  false    ); }

    // ---------------------------------------------------------------------------------------------------------------------------------------
    
    private static void updatePointOfSaleDataTest(Boolean isNotNullAccount)                       
    {
         Case       dummyCase       = TEST_DummyFastQualityComplaintCaseFactry.create (TEST_DummyInsertModeEnum.NONE);

         TEST_DummyAccountFactory.Config accountConfig = null;
         Account    dummyKeyAccount                    = null;
         Account    dummyAccount                       = null;
         if (isNotNullAccount)
         {
             dummyKeyAccount = TEST_DummyAccountFactory.createPointOfSaleKey(TEST_DummyInsertModeEnum.MOCK);

             accountConfig = new TEST_DummyAccountFactory.Config();
             accountConfig.regionId      = 'a2C11000000Cjix';
             accountConfig.parentId      = dummyKeyAccount.id;
             accountConfig.isPointOfSale = true;
             dummyAccount = isNotNullAccount ? TEST_DummyAccountFactory.create(accountConfig, TEST_DummyInsertModeEnum.MOCK) : null;
             dummyAccount.parent = dummyKeyAccount;
         }
         
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                 TARGET_STRATEGY.updatePointOfSaleData (dummyCase, dummyAccount);
            } 
            Test.stopTest();
         } 
         
         System.assertEquals ((isNotNullAccount) ? accountConfig.regionId : dummyCase.region_of_purchase__c, dummyCase.region_of_purchase__c);
         System.assertEquals ((isNotNullAccount) ? accountConfig.parentId : dummyCase.poS_key_account__c,    dummyCase.poS_key_account__c);
         System.assertEquals ((isNotNullAccount) ? dummyKeyAccount        : dummyCase.poS_key_account__r,    dummyCase.poS_key_account__r);
    }

    private static testMethod void noAccountUpdatePointOfSaleDataTest()  { updatePointOfSaleDataTest(false); }
    private static testMethod void hasAccountUpdatePointOfSaleDataTest() { updatePointOfSaleDataTest(true);  }

    // ---------------------------------------------------------------------------------------------------------------------------------------

    private static void requiresPosKeyAccountNameUpdateTest(Boolean hasNewPosKeyAccount, Boolean hasOldPosKeyAccount, Boolean oldPosKeyAccountIsDifferent, Boolean hasOldPosKeyAccountName)                       
    {
         TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                              config.pointOfSaleKeyAccountId = (hasNewPosKeyAccount) ? '00111000004gFL4'  : TEST_ConfigHelper.INTENTIONAL_NULL;
         Case dummyNewCase = TEST_DummyFastQualityComplaintCaseFactry.create (config, TEST_DummyInsertModeEnum.NONE);
     
         Case dummyOldCase = dummyNewCase.clone(false);
              dummyOldCase.poS_key_account__c = (hasOldPosKeyAccount) 
                                                    ? ((oldPosKeyAccountIsDifferent) ? '00111000004gFL5' : dummyNewCase.poS_key_account__c) 
                                                    : null;

         String dummyOldPosKeyAccountName = (hasOldPosKeyAccountName) ? 'Dummy Old Account Name' : null;

         Boolean result = null;
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                 result = TARGET_STRATEGY.requiresPosKeyAccountNameUpdate (dummyNewCase, dummyOldCase, dummyOldPosKeyAccountName);
            } 
            Test.stopTest();
         } 
         
         Boolean expectedResult = (hasOldPosKeyAccountName) && (hasNewPosKeyAccount) && (hasOldPosKeyAccount) && (oldPosKeyAccountIsDifferent);
         System.assertEquals (expectedResult, result);
    }
    
    private static testMethod void hasNothingRequiresPosKeyAccountNameUpdateTest()                      { requiresPosKeyAccountNameUpdateTest (  false,  false,  false, false   );  } // If both old and new account are null, they can not be different
    
    private static testMethod void hasOldPosKeyAccountRequiresPosKeyAccountNameUpdateTest()             { requiresPosKeyAccountNameUpdateTest (  false,  true,   true,  false   );  } // If either old or new account are not null, they can not be the same.
    private static testMethod void hasNewPosKeyAccountRequiresPosKeyAccountNameUpdateTest()             { requiresPosKeyAccountNameUpdateTest (  true,   false,  true,  false   );  } // If either old or new account are not null, they can not be the same.
    private static testMethod void hasSamePosKeyAccountRequiresPosKeyAccountNameUpdateTest()            { requiresPosKeyAccountNameUpdateTest (  true,   true,   false, false   );  } 
    private static testMethod void hasDifferentPosKeyAccountRequiresPosKeyAccountNameUpdateTest()       { requiresPosKeyAccountNameUpdateTest (  true,   true,   true,  false   );  } 

    private static testMethod void hasOldPosKeyAccountNammeRequiresPosKeyAccountNameUpdateTest()        { requiresPosKeyAccountNameUpdateTest (  false,  false,  false, true    );  } 
    private static testMethod void hasOldPosKeyAccountAndOldNameRequiresPosKeyAccountNameUpdateTest()   { requiresPosKeyAccountNameUpdateTest (  false,  true,   true,  true    );  } 
    private static testMethod void hasNewPosKeyAccountAndOldNameRequiresPosKeyAccountNameUpdateTest()   { requiresPosKeyAccountNameUpdateTest (  true,   false,  true,  true    );  } 
    private static testMethod void hasSamePosKeyAccountAndOldNAmeRequiresPosKeyAccountNameUpdateTest()  { requiresPosKeyAccountNameUpdateTest (  true,   true,   false, true    );  } 

    private static testMethod void hasDifferentAccountsWithOldNameRequiresPosKeyAccountNameUpdateTest() { requiresPosKeyAccountNameUpdateTest (  true,   true,   true,  true    );  }

    // ---------------------------------------------------------------------------------------------------------------------------------------

    private static void resetPlaceOfPurchaseTest(Boolean requiresPosKeyAccountNameUpdate, Boolean newPlaceOfPurchaseContainsOldKeyAccountName)                       
    {
         String dummyNewPosKeyAccountName = 'Dummy New Account Name'; 
         String dummyOldPosKeyAccountName = (requiresPosKeyAccountNameUpdate) ? 'Dummy Old Account Name' : null;
         
         String newCurrentPlaceOfPurchase = (newPlaceOfPurchaseContainsOldKeyAccountName) 
                                                ? ('Dummy Place contains ' + dummyOldPosKeyAccountName)
                                                : 'Dummy Place with a completely different name';

         TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                              config.pointOfSaleKeyAccountId = '00111000004gFL4';
                              config.placeOfPurchase         = newCurrentPlaceOfPurchase;
         Case dummyNewCase = TEST_DummyFastQualityComplaintCaseFactry.create (config, TEST_DummyInsertModeEnum.NONE);
     
         Case dummyOldCase = dummyNewCase.clone(false);
              dummyOldCase.poS_key_account__c = '00111000004gFL5';  

         String resultPlaceOfPurchase = null;
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                resultPlaceOfPurchase = TARGET_STRATEGY.resetPlaceOfPurchase(dummyNewCase, dummyOldCase, dummyNewPosKeyAccountName, dummyOldPosKeyAccountName);
            } 
            Test.stopTest();
         } 
         
         String expectedPlaceOfPurchase = (requiresPosKeyAccountNameUpdate)
                                    ? (
                                        (newPlaceOfPurchaseContainsOldKeyAccountName)
                                            ? ( newCurrentPlaceOfPurchase.replaceFirst(dummyOldPosKeyAccountName, dummyNewPosKeyAccountName)) 
                                            : ( newCurrentPlaceOfPurchase                                                                   )      // Keeps OLD value.
                                      )
                                    : (dummyNewPosKeyAccountName  + ' ' + newCurrentPlaceOfPurchase);
         System.assertEquals (expectedPlaceOfPurchase, resultPlaceOfPurchase);
    }
    
    private static testMethod void notRequiredNotContainingResetPlaceOfPurchaseTest()   { resetPlaceOfPurchaseTest(  false,  false   ); }
    private static testMethod void requiredNotContainingResetPlaceOfPurchaseTest()      { resetPlaceOfPurchaseTest(  true,   false   ); }
    private static testMethod void requiredContainingResetPlaceOfPurchaseTest()         { resetPlaceOfPurchaseTest(  true,   true    ); }

    // ---------------------------------------------------------------------------------------------------------------------------------------

    private static void updatePointOfSaleKeyDataTest(Boolean hasNewAccount, Boolean newCaseHasPlaceOfPurchase, Boolean hasOldAccount, Boolean newCaseHasOldPosKeyAccount)                       
    {
         Account    dummyNewAccount = (hasNewAccount) ? TEST_DummyAccountFactory.createPointOfSaleKey(TEST_DummyInsertModeEnum.MOCK) : null;
         Account    dummyOldAccount = (hasOldAccount) ? TEST_DummyAccountFactory.createPointOfSaleKey(TEST_DummyInsertModeEnum.MOCK) : null;

         TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                              config.pointOfSaleKeyAccountId = (hasNewAccount) ? dummyNewAccount.id : null;
                              config.placeOfPurchase         = (newCaseHasPlaceOfPurchase) ? 'Dummy Place of Purchase' : null ;
         Case dummyNewCase = TEST_DummyFastQualityComplaintCaseFactry.create (config, TEST_DummyInsertModeEnum.NONE);
         if (hasOldAccount && newCaseHasOldPosKeyAccount) { dummyNewCase.pos_key_account__r = dummyOldAccount; }

         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                 TARGET_STRATEGY.updatePointOfSaleKeyData (dummyNewCase, null, dummyNewAccount, dummyOldAccount);       // Using "null" for the old Case makes it easier to predict the result of resetPlaceOfPurchase() which is tested independantly earlier in this class.
            } 
            Test.stopTest();
         } 
         
         if (hasNewAccount)
         {
             Account expectedPosKeyAccount = (newCaseHasOldPosKeyAccount) ? dummyOldAccount : dummyNewAccount;
             System.assertEquals (expectedPosKeyAccount, dummyNewCase.pos_key_account__r);
             
             String expectedPlaceOfPurchase = (newCaseHasPlaceOfPurchase)
                                                    ? (expectedPosKeyAccount.name  + ' ' + config.placeOfPurchase)
                                                    : expectedPosKeyAccount.name;
                                                    
             System.assertEquals (expectedPlaceOfPurchase, dummyNewCase.place_of_purchase__c);
                                                    
         }
         // else there is nothing to test for.                                           
    }

    private testMethod static void hasNothingUpdatePointOfSaleKeyDataTest()                                    { updatePointOfSaleKeyDataTest(  false,  false, false,  false ); }
    // Other tests for hasNewAccount = false are (or should be) redundant, all with no results to test for.
    
    private testMethod static void hasNewAccountUpdatePointOfSaleKeyDataTest()                                 { updatePointOfSaleKeyDataTest(  true,  false,  false,  false ); }
    private testMethod static void hasNewAndOldAccountUpdatePointOfSaleKeyDataTest()                           { updatePointOfSaleKeyDataTest(  true,  false,  true,   false ); }
    private testMethod static void newCaseHasOldPosKeyAccountUpdatePointOfSaleKeyDataTest()                    { updatePointOfSaleKeyDataTest(  true,  false,  true,   true  ); }
    
    private testMethod static void hasPlaceOfPurchaseUpdatePointOfSaleKeyDataTest()                            { updatePointOfSaleKeyDataTest(  true,  true,   false,  false ); }
    private testMethod static void hasPlaceOfPurchaseAndOldAccountUpdatePointOfSaleKeyDataTest()               { updatePointOfSaleKeyDataTest(  true,  true,   true,   false ); }
    private testMethod static void hasPlaceOfPurchaseAndCaseHasOldPosKeyAccountUpdatePointOfSaleKeyDataTest()  { updatePointOfSaleKeyDataTest(  true,  true,   true,   true  ); }

    // ---------------------------------------------------------------------------------------------------------------------------------------
    
    private static void setPOSDataTest(Boolean hasNewPointOfSaleData, Boolean hasNewPosKeyAccount, Boolean hasNewPointOfSaleAccount)                       
    {
        Account dummyNewPointOfSaleKeyAccount = (hasNewPointOfSaleData && hasNewPosKeyAccount)      ? createAndMapPosKeyAccount()                                                 : null;
        
        Id      dummyPosRegionId              = 'a2C11000000Cjix'; 
        Account dummyPosPointOfSaleKeyAccount = (hasNewPointOfSaleData && hasNewPointOfSaleAccount) ? createAndMapPosKeyAccount()                                                 : null;
        Account dummyPointOfSaleAccount       = (hasNewPointOfSaleData && hasNewPointOfSaleAccount) ? createAndMapPosAccount (dummyPosPointOfSaleKeyAccount.id, dummyPosRegionId) : null;

         TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                              caseConfig.pointOfSaleKeyAccountId = (hasNewPointOfSaleData && hasNewPosKeyAccount)      ? dummyNewPointOfSaleKeyAccount.id : TEST_ConfigHelper.INTENTIONAL_NULL;
                              caseConfig.pointOfSaleAccountId    = (hasNewPointOfSaleData && hasNewPointOfSaleAccount) ? dummyPointOfSaleAccount.id       : TEST_ConfigHelper.INTENTIONAL_NULL;
                              caseConfig.placeOfPurchase         = TEST_ConfigHelper.INTENTIONAL_NULL;
         Case dummyNewCase = TEST_DummyFastQualityComplaintCaseFactry.create (caseConfig, TEST_DummyInsertModeEnum.NONE);

         Case dummyOldCase = dummyNewCase.clone(false);
              dummyOldCase.poS_key_account__c   = dummyNewCase.poS_key_account__c; 
              dummyOldCase.point_Of_sale__c     = dummyNewCase.point_Of_sale__c; 
              dummyOldCase.place_of_purchase__c = (hasNewPointOfSaleData) ? 'Other Place' : dummyNewCase.Place_of_Purchase__c; 
         
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                 TARGET_STRATEGY.setPOSData(dummyNewCase, dummyOldCase);  
            } 
            Test.stopTest();
         }
        
         if (hasNewPointOfSaleData)
         {
             if (hasNewPointOfSaleAccount)
             {
                System.assertEquals (dummyPosRegionId,           dummyNewCase.region_of_purchase__c);
             }

             Account expectedPOSKeyAccount = (hasNewPointOfSaleAccount) 
                          ? dummyPosPointOfSaleKeyAccount 
                          : ((hasNewPosKeyAccount) ? dummyNewPointOfSaleKeyAccount : null);
                          
             System.assertEquals    (  expectedPOSKeyAccount,                                                                            dummyNewCase.pos_key_account__r);
             System.assertEquals    (((expectedPOSKeyAccount != null) ? expectedPOSKeyAccount.id   : null),                              dummyNewCase.poS_key_account__c);
             
             String expectedPlaceOfPurchase = (expectedPOSKeyAccount != null) ? expectedPOSKeyAccount.name : null; 
             System.assertEquals    (expectedPlaceOfPurchase, dummyNewCase.place_of_purchase__c);
         }
         // else there is nothing to check for.         
    }
    
    private static testMethod void hasNothingSetPOSDataTest()                { setPOSDataTest(false, false, false); }
    // Other tests for hasNewPointOfSaleData are redundant and equally untestable.

    private static testMethod void hasNewPointOfSaleDataSetPOSDataTest()     { setPOSDataTest(true,  false, false); }
    private static testMethod void hasPOSDataTest()                          { setPOSDataTest(true,  false, true);  }
    private static testMethod void hasKeySetPOSDataTest()                    { setPOSDataTest(true,  true,  false); }
    private static testMethod void hasBothSetPOSDataTest()                   { setPOSDataTest(true,  true,  true);  }

    // ---------------------------------------------------------------------------------------------------------------------------------------

    private static void executeTest(Boolean hasOldCase)                       
    {
        Id      dummyPosRegionId              = 'a2C11000000Cjix'; 
        Account dummyPosPointOfSaleKeyAccount = createAndMapPosKeyAccount();
        Account dummyPointOfSaleAccount       = createAndMapPosAccount (dummyPosPointOfSaleKeyAccount.id, dummyPosRegionId);

         TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                              caseConfig.pointOfSaleKeyAccountId = TEST_ConfigHelper.INTENTIONAL_NULL;
                              caseConfig.pointOfSaleAccountId    = dummyPointOfSaleAccount.id;
                              caseConfig.placeOfPurchase         = TEST_ConfigHelper.INTENTIONAL_NULL;
         Case dummyNewCase = TEST_DummyFastQualityComplaintCaseFactry.create (caseConfig, TEST_DummyInsertModeEnum.NONE);

         Case          dummyOldCase        = null;
         Map<Id, Case> dummyOldCaseByIdMap = null; 
         if (hasOldCase)
         {
              dummyOldCase = dummyNewCase.clone(false);
              TEST_MockHelper.mockInsert(dummyOldCase);
              dummyOldCase.point_Of_sale__c     = dummyNewCase.point_Of_sale__c; 
              dummyOldCase.place_of_purchase__c = 'Other Place' ;

              dummyOldCaseByIdMap = new Map<Id, Case>{ dummyOldCase.id => dummyOldCase }; 

              dummyNewCase.id = dummyOldCase.id;
         }      
         
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                 TARGET_STRATEGY.execute(dummyOldCaseByIdMap, new List<Case> { dummyNewCase });
            } 
            Test.stopTest();
         } 
         
         System.assertEquals (dummyPosRegionId,           dummyNewCase.region_of_purchase__c);
         
         System.assertEquals    (dummyPosPointOfSaleKeyAccount,       dummyNewCase.pos_key_account__r);
         System.assertEquals    (dummyPosPointOfSaleKeyAccount.id,    dummyNewCase.poS_key_account__c);
         System.assertEquals    (dummyPosPointOfSaleKeyAccount.name , dummyNewCase.place_of_purchase__c);
    }
    
    private static testMethod void withoutOldCaseExecuteTest() { executeTest(false); }
    private static testMethod void withOldCaseExecuteTest()    { executeTest(true);  }

    // ---------------------------------------------------------------------------------------------------------------------------------------
    
    private static void onBeforeMethodTest(Boolean isInsertTest, Boolean isQualityCase)                       
    {
        Id      dummyPosRegionId              = 'a2C11000000Cjix'; 
        Account dummyPosPointOfSaleKeyAccount = createAndMapPosKeyAccount();
        Account dummyPointOfSaleAccount       = createAndMapPosAccount (dummyPosPointOfSaleKeyAccount.id, dummyPosRegionId);

         TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                              /*#CICTemplateTest   */
                              caseConfig.recordTypeId            = TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(isQualityCase ? ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME : ECICCommonConstants.INQUIRY_IBERIA_DEVNAME);
                              caseConfig.pointOfSaleKeyAccountId = TEST_ConfigHelper.INTENTIONAL_NULL;
                              caseConfig.pointOfSaleAccountId    = dummyPointOfSaleAccount.id;
                              caseConfig.placeOfPurchase         = TEST_ConfigHelper.INTENTIONAL_NULL;
         Case dummyNewCase = TEST_DummyGenericCaseFactory.create (caseConfig, TEST_DummyInsertModeEnum.NONE);

         Case          dummyOldCase        = null;
         if (!isInsertTest) // if update test
         {
              dummyOldCase = dummyNewCase.clone(false);
              TEST_MockHelper.mockInsert(dummyOldCase);
              dummyOldCase.place_of_purchase__c = 'Other Place' ;

              dummyNewCase.id = dummyOldCase.id;
         }      

         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                 if (isInsertTest) { TARGET_STRATEGY.OnBeforeInsert (new List<Case> { dummyNewCase }); }
                 else              { TARGET_STRATEGY.OnBeforeUpdate (new Map<Id, Case>{ dummyOldCase.id => dummyOldCase }, new Map<Id, Case>{ dummyNewCase.id => dummyNewCase }); }
            } 
            Test.stopTest();
         } 
         
         System.assertEquals ((isQualityCase) ? dummyPosRegionId                    : null, dummyNewCase.region_of_purchase__c);
         System.assertEquals ((isQualityCase) ? dummyPosPointOfSaleKeyAccount       : null, dummyNewCase.pos_key_account__r  );
         System.assertEquals ((isQualityCase) ? dummyPosPointOfSaleKeyAccount.id    : null, dummyNewCase.poS_key_account__c  );
         System.assertEquals ((isQualityCase) ? dummyPosPointOfSaleKeyAccount.name  : null, dummyNewCase.place_of_purchase__c);
    }

    private static void inquiryCaseOnBeforeUpdateMethodTest()          { onBeforeMethodTest ( false, false ); }
    private static void qualityComplaintCaseOnBeforeUpdateMethodTest() { onBeforeMethodTest ( false, true  ); }
    private static void inquiryCaseOnBeforeInsertMethodTest()          { onBeforeMethodTest ( true,  false ); }
    private static void qualityComplaintCaseOnBeforeInsertMethodTest() { onBeforeMethodTest ( true,  true  ); }
    
    // ---------------------------------------------------------------------------------------------------------------------------------------

    private static Account createAndMapPosKeyAccount ()
    {
        Account dummyNewPointOfSaleKeyAccount = TEST_DummyAccountFactory.createPointOfSaleKey(TEST_DummyInsertModeEnum.MOCK);
        TARGET_STRATEGY.regionAccountByIdMap.put (dummyNewPointOfSaleKeyAccount.id, dummyNewPointOfSaleKeyAccount);
        return dummyNewPointOfSaleKeyAccount;
    }

    private static Account createAndMapPosAccount (Id dummyPosKeyAccountId, Id dummyPosRegionId)
    {
            TEST_DummyAccountFactory.Config posAccountConfig = new TEST_DummyAccountFactory.Config();
                                            posAccountConfig.parentId      = dummyPosKeyAccountId;
                                            posAccountConfig.regionId      = dummyPosRegionId;
                                            posAccountConfig.isPointOfSale = true;
            Account dummyPointOfSaleAccount = TEST_DummyAccountFactory.create(posAccountConfig, TEST_DummyInsertModeEnum.MOCK);
            TARGET_STRATEGY.regionAccountByIdMap.put (dummyPointOfSaleAccount.id, dummyPointOfSaleAccount);    
            return dummyPointOfSaleAccount;
    }


}