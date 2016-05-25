@isTest
private class ECICAccountDaoTest 
{
    private static final User   TEST_RUN_USER       = TEST_DummyUserFactory.createDefaultTestRunUser();
    private static final String DUMMY_EXTERNAL_ID   = 'X123456';
    
    private static void findByIds2Test(Boolean isAccountInIdSet, Boolean hasFieldToQuery, Boolean hasWhereCondition)
    {
         Account  dummyAccount              = createDummyAccount(); 
    	 Set<Id>  dummyIdSet                = (isAccountInIdSet)  ? new Set<Id>{ dummyAccount.id }    : new Set<Id>();   
    	 String[] dummyFieldsToQueryArray   = (hasFieldToQuery)   ? new String[] {'country_code__c'}  : null; 
      	 String[] dummyWhereConditionsArray = (hasWhereCondition) ? new String[] {'Active__c = true'} : null;
    	 
         Map<Id, Account> resultAccountByIdMap = null; 
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                resultAccountByIdMap = ECICAccountDao.findByIds(dummyIdSet, dummyFieldsToQueryArray, dummyWhereConditionsArray); 
            }
            Test.stopTest();
         }
     
         assertAccountByIdMap(dummyAccount.Id, isAccountInIdSet, hasFieldToQuery, hasWhereCondition, resultAccountByIdMap);    
    }

    private static testMethod void hasNoneFindByIds2Test()              { findByIds2Test(false, false, false); }
    private static testMethod void hasWhereConditionFindByIds2Test()    { findByIds2Test(false, false, true ); }
    private static testMethod void hasFieldToQueryFindByIds2Test()      { findByIds2Test(false, true , false); }
    private static testMethod void notInSetFindByIds2Test()             { findByIds2Test(false, true , true ); }
    private static testMethod void inSetFindByIds2Test()                { findByIds2Test(true , false, false); }
    private static testMethod void noFieldToQueryFindByIds2Test()       { findByIds2Test(true , false, true ); }
    private static testMethod void noWhereConditionFindByIds2Test()     { findByIds2Test(true , true , false); }
    private static testMethod void hasAllFindByIds2Test()               { findByIds2Test(true , true , true ); }


    // --------------------------------------------------------------------------------------------
    
    private static void findByIdsTest(Boolean combinedAccountsToCloneTest)
    {
         Account  dummyAccount              = createDummyAccount(); 
         Set<Id>  dummyIdSet                = new Set<Id>{ dummyAccount.id };   
         
         Map<Id, Account> resultAccountByIdMap = null; 
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                resultAccountByIdMap = (!combinedAccountsToCloneTest)
                                            ? ECICAccountDao.findByIds(dummyIdSet)
                                            : ECICAccountDao.findCombinedAccountsByIdsToClone(dummyIdSet); 
            }
            Test.stopTest();
         }
         
         assertAccountByIdMap(dummyAccount.Id, true, true, false, resultAccountByIdMap);  
         assertFieldValue(dummyAccount.Id, DUMMY_EXTERNAL_ID, 'Account_Ext_Id__c', combinedAccountsToCloneTest, resultAccountByIdMap);  
    }

    private static testMethod void simpleFindByIdsTest()                  { findByIdsTest(false); }
    private static testMethod void combinedAccountstoCloneFindByIdsTest() { findByIdsTest(true);  }
    
    // --------------------------------------------------------------------------------------------

    private static void findAccountsByIdsToCloneTest(Boolean isPersonAccount)
    {
         Account  dummyAccount              = createDummyAccount(isPersonAccount); 
         Set<Id>  dummyIdSet                = new Set<Id>{ dummyAccount.id };   

         Map<Id, Account> resultAccountByIdMap = null; 
         System.runAs(TEST_RUN_USER)
         {
            Test.startTest();
            {
                resultAccountByIdMap = (isPersonAccount)
                                            ? ECICAccountDao.findPersonAccountsByIdsToClone(dummyIdSet)
                                            : ECICAccountDao.findBusinessAccountsByIdsToClone(dummyIdSet); 
            }
            Test.stopTest();
         } 
         
         assertAccountByIdMap(dummyAccount.Id, true, true, false, resultAccountByIdMap); 
    }

    private static testMethod void personFindAccountsByIdsToCloneTest()   { FindAccountsByIdsToCloneTest(true ); }
    private static testMethod void businessFindAccountsByIdsToCloneTest() { FindAccountsByIdsToCloneTest(false); }
    
    // --------------------------------------------------------------------------------------------

    private static void cloneTest(Boolean isPersonAccount)
    {
         Account dummyAccount  = createDummyAccount(isPersonAccount); 

         Account resultAccount = null; 
         System.runAs(TEST_RUN_USER)
         {
         	Test.startTest();
         	{
         		resultAccount = ECICAccountDao.clone(dummyAccount);
         	}
         	Test.stopTest();
         } 
         /* 
            NOTE No assertion confirm:  if (originalAccount.get(fieldToClone) != null)
            1. It is an uphill battle to create a record without nulls (which will quickly become obsolete)
            2. It is impossible to distinquish between a cloned null and an uncloned field.
         */
         
         System.assertEquals (null,                         resultAccount.id);
         System.assertEquals (dummyAccount.country_code__c, resultAccount.country_code__c);
         System.assertEquals (dummyAccount.active__c,       resultAccount.active__c);

         assertFieldValues(dummyAccount, (isPersonAccount) ? ECICAccountDao.PERSON_ACCOUNT_FIELDS_TO_CLONE : ECICAccountDao.BUSINESS_ACCOUNT_FIELDS_TO_CLONE, resultAccount);
    }

    private static testMethod void businessCloneTest() { cloneTest(false); }
    private static testMethod void personCloneTest() { cloneTest(true); }
    
    // --------------------------------------------------------------------------------------------

    private static Account createDummyAccount(Boolean isPersonAccount, Boolean requiresReal)
    {
         TEST_DummyAccountFactory.Config config = new TEST_DummyAccountFactory.Config();
                                         config.externalId  = DUMMY_EXTERNAL_ID;
                                         config.countryCode = ECICCommonConstants.COUNTRY_CODE_DEFAULT;
                                         config.isPerson    = isPersonAccount;
                                         config.isActive    = false;
         return TEST_DummyAccountFactory.create (config, (requiresReal) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.MOCK); 
    }

    private static Account createDummyAccount(Boolean isPersonAccount) { return createDummyAccount(isPersonAccount, true); }
    private static Account createDummyAccount()                        { return createDummyAccount(false, true); }

    // --------------------------------------------------------------------------------------------

    private static void assertAccountByIdMap(Id dummyAccountId, Boolean isAccountInIdSet, Boolean hasFieldToQuery, Boolean hasEliminatingWhereCondition, Map<Id, Account> resultAccountByIdMap)
    {
         if (!isAccountInIdSet) { System.assert (resultAccountByIdMap.isEmpty()); }
         else
         {
            System.assertEquals ((hasEliminatingWhereCondition) ? 0 : 1, resultAccountByIdMap.size());
            if (!resultAccountByIdMap.isEmpty())
            {
                System.assert (resultAccountByIdMap.containsKey(dummyAccountId));
                assertFieldValue(dummyAccountId, ECICCommonConstants.COUNTRY_CODE_DEFAULT, 'country_code__c', !hasFieldToQuery, resultAccountByIdMap);
            }
         }
    }
    
    private static void assertFieldValues(Account dummyAccount, List<String> fieldToAssertList, Account resultAccount)
    {
         for (String accountField : fieldToAssertList)
         {
         	 String dummyAccountField = null;
             try 
             { 
             	dummyAccountField = (String) dummyAccount.get(accountField);
             	assertFieldValue(dummyAccountField, accountField, false, resultAccount); 
             }
             catch (System.TypeException ex){}  // It is too complicated to check ALL the data, so we'll ignore fields which are not String.
         }
    }
    
    private static void assertFieldValue(Id dummyAccountId, String expectedValue, String fieldName, Boolean errorExpected, Map<Id, Account> resultAccountByIdMap)
    {
        Account resultAccount = resultAccountByIdMap.get(dummyAccountId);
        assertFieldValue(expectedValue, fieldName, errorExpected, resultAccount);
    }

    private static void assertFieldValue(String expectedValue, String fieldName, Boolean errorExpected, Account resultAccount)
    {
        Boolean errorCaught = false;
        try { System.assertEquals (expectedValue, (String) resultAccount.get(fieldName)); }
        catch (System.SObjectException ex) { errorCaught = true; }
        System.assertEquals (errorExpected, errorCaught);
    }


}