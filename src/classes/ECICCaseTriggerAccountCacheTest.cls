@isTest
private class ECICCaseTriggerAccountCacheTest {
    private static final User 	TEST_RUN_USER = ECICRunUserTestHelper.create();
    
    private static void cacheMapAccountTest(Boolean isBottlerAccountTest) {
        Account dummyAccount = TEST_DummyAccountFactory.create(TEST_DummyInsertModeEnum.MOCK);
        Map<Id, Account> targetCacheMap = (isBottlerAccountTest) 
                                                ? ECICCaseTriggerAccountCache.bottlerAccountByIdCache
                                                : ECICCaseTriggerAccountCache.regionAccountByIdCache;
        targetCacheMap.put(dummyAccount.Id, dummyAccount);
        
        Map<Id, Account> resultAccountByIdMap = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                resultAccountByIdMap = (isBottlerAccountTest) 
                                            ? ECICCaseTriggerAccountCache.getBottlerAccountByByIdMap()
                                            : ECICCaseTriggerAccountCache.getRegionAccountByIdMap();
            }
            Test.stopTest();
        }
        
        System.assert(resultAccountByIdMap.containsKey(dummyAccount.Id));
        System.assertEquals (dummyAccount, resultAccountByIdMap.get(dummyAccount.Id));
    }
    
    private static testMethod void getRegionAccountByIdMapTest()    { cacheMapAccountTest(true);    }
    private static testMethod void getBottlerAccountByByIdMapTest() { cacheMapAccountTest(false);   }
    
    // ------------------------------------------------------------------------------------------------
    
    private static void selectRegionAccountIdSetTest(Boolean hasOldCaseByIdMap) {
        Account dummyNewPointOfSaleKeyAccount  = TEST_DummyAccountFactory.createPointOfSaleKey(TEST_DummyInsertModeEnum.MOCK);
        Account dummyNewPointOfSaleAccount     = TEST_DummyAccountFactory.createPointOfSale (dummyNewPointOfSaleKeyAccount.Id, TEST_DummyInsertModeEnum.MOCK);
        Account dummyOldPointOfSaleKeyAccount  = TEST_DummyAccountFactory.createPointOfSaleKey(TEST_DummyInsertModeEnum.MOCK);
        Account dummyOldPointOfSaleAccount     = TEST_DummyAccountFactory.createPointOfSale (dummyOldPointOfSaleKeyAccount.Id, TEST_DummyInsertModeEnum.MOCK);
        
        TEST_DummyCaseConfig    caseConfig = new TEST_DummyCaseConfig();
                                caseConfig.pointOfSaleAccountId     = dummyNewPointOfSaleAccount.Id;
                                caseConfig.pointOfSaleKeyAccountId  = dummyNewPointOfSaleKeyAccount.Id;
        Case newDummyCase = TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.NONE);
        List<Case> dummyNewCaseList = new List<Case> { newDummyCase };
        
        Map<Id,Case> dummyOldCaseByIdMap = null;
        if (hasOldCaseByIdMap) {
            Case oldDummyCase = newDummyCase.clone(true, true);
                 oldDummyCase.Point_of_Sale__c   = dummyOldPointOfSaleAccount.Id;
                 oldDummyCase.PoS_Key_Account__c = dummyOldPointOfSaleKeyAccount.Id;
                 dummyOldCaseByIdMap = new Map<Id,Case>{newDummyCase.id  =>  oldDummyCase};
        }
        
        Set<Id> resultCaseRegionAccountIdSet = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                resultCaseRegionAccountIdSet =  ECICCaseTriggerAccountCache.selectRegionAccountIdSet(dummyNewCaseList, dummyOldCaseByIdMap);
            }
            Test.stopTest();
        }
        
        System.assert(resultCaseRegionAccountIdSet.contains(dummyNewPointOfSaleAccount.Id));
        System.assert(resultCaseRegionAccountIdSet.contains(dummyNewPointOfSaleKeyAccount.Id));
        if (hasOldCaseByIdMap) {
            System.assert(!resultCaseRegionAccountIdSet.contains(dummyOldPointOfSaleAccount.Id));
            System.assert(resultCaseRegionAccountIdSet.contains(dummyOldPointOfSaleKeyAccount.Id));
        }
    }
    
    private static testMethod void withoutOldGetCaseRegionAccountIdSetTest() { selectRegionAccountIdSetTest(false); }
    private static testMethod void withOldGetCaseRegionAccountIdSetTest()    { selectRegionAccountIdSetTest(true);  }
    
    // ------------------------------------------------------------------------------------------------
    
    private static testMethod void selectBottlerAccountIdSetTest() {
        Region__c testDummyRegion = TEST_DummyRegionFactory.create(TEST_DummyInsertModeEnum.MOCK);
        
        Account dummyCaseBottlerAccount   = TEST_DummyAccountFactory.createBottler(testDummyRegion, TEST_DummyInsertModeEnum.MOCK);
        Account dummyRegionBottlerAccount = TEST_DummyAccountFactory.createBottler(testDummyRegion, TEST_DummyInsertModeEnum.MOCK);
        Account dummyPlantBottlerAccount  = TEST_DummyAccountFactory.createBottler(testDummyRegion, TEST_DummyInsertModeEnum.MOCK);
        
        TEST_DummyCaseConfig    caseConfig = new TEST_DummyCaseConfig();
                                caseConfig.bottlerAccountId     = dummyCaseBottlerAccount.Id;
        Case dummyCase = TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.NONE);
        List<Case> dummyNewCaseList  = new List<Case> { dummyCase };
        
        TEST_DummyRegionFactory.Config regionConfig = new TEST_DummyRegionFactory.Config();
                                       regionConfig.bottlerId = dummyRegionBottlerAccount.Id;
        Region__c dummyRegion = TEST_DummyRegionFactory.create(regionConfig, TEST_DummyInsertModeEnum.MOCK);
        ECICCaseTriggerRegionCache.regionByIdCache.put (dummyRegion.id, dummyRegion);
        
        Plant__c dummyPlant = TEST_DummyPlantFactory.create(dummyPlantBottlerAccount.Id, dummyRegion.id, TEST_DummyInsertModeEnum.MOCK);
        ECICCaseTriggerPlantCache.plantByIdCache.put (dummyPlant.id, dummyPlant);
        
        Set<Id> resultBottlerIdSet = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                resultBottlerIdSet = ECICCaseTriggerAccountCache.selectBottlerAccountIdSet(dummyNewCaseList);
            }
            Test.stopTest();
        }
        
        System.assert(resultBottlerIdSet.contains(dummyCaseBottlerAccount.Id));
        System.assert(resultBottlerIdSet.contains(dummyRegionBottlerAccount.Id));
        System.assert(resultBottlerIdSet.contains(dummyPlantBottlerAccount.Id));
    }
    
    // ------------------------------------------------------------------------------------------------
    
    private static testMethod void populateTest() {
        Region__c testDummyRegion = TEST_DummyRegionFactory.create(TEST_DummyInsertModeEnum.MOCK);
        Account dummyNewBottlerAccount        = TEST_DummyAccountFactory.createBottler(testDummyRegion, TEST_DummyInsertModeEnum.MOCK);
        Account dummyNewPointOfSaleKeyAccount = TEST_DummyAccountFactory.createPointOfSaleKey(TEST_DummyInsertModeEnum.MOCK);
        Account dummyNewPointOfSaleAccount    = TEST_DummyAccountFactory.createPointOfSale (dummyNewPointOfSaleKeyAccount.Id, TEST_DummyInsertModeEnum.MOCK);
        
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.bottlerAccountId         = dummyNewBottlerAccount.Id;
                             caseConfig.pointOfSaleAccountId     = dummyNewPointOfSaleAccount.Id;
                             caseConfig.pointOfSaleKeyAccountId  = dummyNewPointOfSaleKeyAccount.Id;
        Case newDummyCase = TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.NONE);
        List<Case> dummyNewCaseList = new List<Case> { newDummyCase };
        
        ECICCaseTriggerAccountCache.regionAccountByIdCache.put(dummyNewPointOfSaleKeyAccount.Id, dummyNewPointOfSaleKeyAccount);
        ECICCaseTriggerAccountCache.regionAccountByIdCache.put(dummyNewPointOfSaleAccount.Id, dummyNewPointOfSaleAccount);
        ECICCaseTriggerAccountCache.bottlerAccountByIdCache.put(dummyNewBottlerAccount.Id, dummyNewBottlerAccount);
        
        Map<Id,Case> dummyOldCaseByIdMap = new Map<Id,Case>{newDummyCase.id  =>  newDummyCase};
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                ECICCaseTriggerAccountCache.populate(dummyNewCaseList, dummyOldCaseByIdMap);
            }
            Test.stopTest();
        }
        
        Map<Id, Account> resultRegionAccountByIdMap = ECICCaseTriggerAccountCache.regionAccountByIdCache;
        assertMapContains(resultRegionAccountByIdMap, dummyNewPointOfSaleAccount,       true);
        assertMapContains(resultRegionAccountByIdMap, dummyNewPointOfSaleKeyAccount,    true);
        
        Map<Id, Account> resultBottlerAccountByIdMap = ECICCaseTriggerAccountCache.bottlerAccountByIdCache;
        assertMapContains(resultBottlerAccountByIdMap, dummyNewBottlerAccount,          false);
    }
    
    private static void assertMapContains (Map<Id, Account> resultAccountByIdMap, Account dummyAccount, Boolean doNameCheck) {
        System.assert (resultAccountByIdMap.containsKey(dummyAccount.id));
        Account resultAccount = resultAccountByIdMap.get(dummyAccount.id);
        System.assertEquals( dummyAccount.name,        resultAccount.name         );
        System.assertEquals( dummyAccount.Region__c,   resultAccount.Region__c    );
        if (doNameCheck) { System.assertEquals( dummyAccount.Parent.Name, resultAccount.Parent.Name  ); }
    }
}