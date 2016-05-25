@isTest
private class ECICCaseTriggerHandlerTest 
{
    private static final User TEST_RUN_USER   = ECICRunUserTestHelper.create();

    private static void constructorTest(Boolean isExecutingTest)            
    { 
        ECICCaseTriggerHandler handler = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                handler = new ECICCaseTriggerHandler(isExecutingTest);
            }
            Test.stopTest();
        } 
        
        System.assertEquals (isExecutingTest, handler.isTriggerExecuting);
    }
    
    private static testMethod void isExecutingConstructorTest()  { constructorTest(true); }             
    private static testMethod void notExecutingConstructorTest() { constructorTest(false); }            

    //------------------------------------------------------------------------------------------------------------------------------------  

    private static void executeStrategyChainTest (SEPTriggerTypeEnum dummyTriggerType, Boolean passTestExpected)            
    {  
        ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
        Case_Trigger_Strategy_Configuration__c dummyStrategyConfig = TEST_DummyCaseTrigStrategyConfigFactory.create(dummyTriggerType, TEST_DummyInsertModeEnum.REAL);

        Boolean                insertNow = (SEPTriggerTypeEnum.BEFORE_INSERT != dummyTriggerType); 
        ECICCaseTriggerHandler handler   = new ECICCaseTriggerHandler(true);

        ECICCaseTestHelper.CaseConfig caseConfig = new ECICCaseTestHelper.CaseConfig();
                                      caseConfig.countryCode = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_COUNTRY;
                                      caseConfig.subject     = (passTestExpected) ? 'Pass Test' : ECICCaseTriggerHandlerTestStrategy.DO_FAIL_TEST;   
        Case          dummyCase = ECICCaseTestHelper.createDummyCase (caseConfig, insertNow);
        Id            dummyCaseId            = dummyCase.id;
        
        // Note: None of the current (2014 January 29) test strategy methods compare old verse new values, 
        //      nor will insert or update methods use the old values
        //      so it shouldn't matter that the old and new below will be identical
        List<Case>    dummyOldCaseList       = new List<Case>   {dummyCase};
        List<Case>    dummyNewCaseList       = new List<Case>   {dummyCase};
        Map<Id,Case>  dummyOldCaseByIdMap    = new Map<Id,Case> {dummyCase.id => dummyCase};
        Map<Id,Case>  dummyNewCaseByIdMap    = new Map<Id,Case> {dummyCase.id => dummyCase};

        Boolean passTestResult = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {


                passTestResult = handler.executeStrategyChain(dummyTriggerType, dummyNewCaseList, dummyOldCaseByIdMap, dummyNewCaseByIdMap); 
            }
            
         
        if ((new Set<SEPTriggerTypeEnum>{SEPTriggerTypeEnum.BEFORE_DELETE, SEPTriggerTypeEnum.AFTER_DELETE}).contains(dummyTriggerType))
        {
            ECICCaseTriggerHandlerTestStrategy.assertExecution(passTestExpected, passTestResult, dummyTriggerType, dummyCaseId);
        }
        else
        {
            ECICCaseTriggerHandlerTestStrategy.assertExecution(passTestExpected, passTestResult, dummyTriggerType, dummyCase);
        }
        
        Test.stopTest();
        }
    }

    private static testMethod void beforeInsertExecuteStrategyChainPassTest()   { executeStrategyChainTest(SEPTriggerTypeEnum.BEFORE_INSERT,  true);   }
    private static testMethod void beforeInsertExecuteStrategyChainFailTest()   { executeStrategyChainTest(SEPTriggerTypeEnum.BEFORE_INSERT,  false);  }            
    private static testMethod void afterInsertExecuteStrategyChainPassTest()    { executeStrategyChainTest(SEPTriggerTypeEnum.AFTER_INSERT,   true);   }            
    private static testMethod void afterInsertExecuteStrategyChainFailTest()    { executeStrategyChainTest(SEPTriggerTypeEnum.AFTER_INSERT,   false);  }            
    private static testMethod void beforeUpdateExecuteStrategyChainPassTest()   { executeStrategyChainTest(SEPTriggerTypeEnum.BEFORE_UPDATE,  true);   }            
    private static testMethod void beforeUpdateExecuteStrategyChainFailTest()   { executeStrategyChainTest(SEPTriggerTypeEnum.BEFORE_UPDATE,  false);  }            
    private static testMethod void afterUpdateExecuteStrategyChainPassTest()    { executeStrategyChainTest(SEPTriggerTypeEnum.AFTER_UPDATE,   true);   }            
    private static testMethod void afterUpdateExecuteStrategyChainFailTest()    { executeStrategyChainTest(SEPTriggerTypeEnum.AFTER_UPDATE,   false);  }            
    private static testMethod void beforeDeleteExecuteStrategyChainPassTest()   { executeStrategyChainTest(SEPTriggerTypeEnum.BEFORE_DELETE,  true);   }            
    private static testMethod void beforeDeleteExecuteStrategyChainFailTest()   { executeStrategyChainTest(SEPTriggerTypeEnum.BEFORE_DELETE,  false);  }            
    private static testMethod void afterDeleteExecuteStrategyChainPassTest()    { executeStrategyChainTest(SEPTriggerTypeEnum.AFTER_DELETE,   true);   }            
    private static testMethod void afterDeleteExecuteStrategyChainFailTest()    { executeStrategyChainTest(SEPTriggerTypeEnum.AFTER_DELETE,   false);  }            
    private static testMethod void afterUndeleteExecuteStrategyChainPassTest()  { executeStrategyChainTest(SEPTriggerTypeEnum.AFTER_UNDELETE, true);   }            
    private static testMethod void afterUndeleteExecuteStrategyChainFailTest()  { executeStrategyChainTest(SEPTriggerTypeEnum.AFTER_UNDELETE, false);  } 

    
    //------------------------------------------------------------------------------------------------------------------------------------  
    
    private static void otherCountryExecuteStrategyChainTest(SEPTriggerTypeEnum dummyTriggerType)   
    { 
        System.runAs(TEST_RUN_USER)
        {
           
        ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);

        Boolean                insertNow = (SEPTriggerTypeEnum.BEFORE_INSERT != dummyTriggerType); 
        ECICCaseTriggerHandler handler   = new ECICCaseTriggerHandler(true);

        TEST_UniqueHelper unique = new TEST_UniqueHelper(dummyTriggerType.name()); 
        ECICCaseTestHelper.CaseConfig caseConfig = new ECICCaseTestHelper.CaseConfig();
                                      caseConfig.subject       = 'Other Country Test';
                                      caseConfig.origin        = 'Web';
                                      caseConfig.suppliedEmail = unique.uniqueSpaceless+'@othercountry.example.com';
                                      // #Ecic template test
                                      caseConfig.recordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ECICCommonConstants.INQUIRY_IBERIA_RTNAME).getRecordTypeId();
        
        if (dummyTriggerType == SEPTriggerTypeEnum.BEFORE_UPDATE)
        {
                                      caseConfig.potentialRisk = 'High Risk';
                                      caseConfig.riskType      = 'Blackmail';   
        }
        
        Test.startTest();
              
        Case          dummyCase = ECICCaseTestHelper.createDummyCase (caseConfig, insertNow);
        List<Case>    dummyNewCaseList       = new List<Case>   {dummyCase};
        Map<Id,Case>  dummyOldCaseByIdMap    = new Map<Id,Case> {dummyCase.id => dummyCase};
        Map<Id,Case>  dummyNewCaseByIdMap    = new Map<Id,Case> {dummyCase.id => dummyCase};
        
        Test.stopTest();
        
        Boolean passTestResult = null;
        
            {
                passTestResult = handler.executeStrategyChain(dummyTriggerType, dummyNewCaseList, dummyOldCaseByIdMap, dummyNewCaseByIdMap); 
            }
            
        System.assert (passTestResult);
        
        // The following assertions rely on current (2014 January 27) default/legacy strategies which can be expected to execute for given triggerType.
        if      (dummyTriggerType == SEPTriggerTypeEnum.BEFORE_INSERT)  { assertCaseHasAccount(dummyCase); }
        else if (dummyTriggerType == SEPTriggerTypeEnum.AFTER_INSERT)   { assertCaseHasEmail(dummyCase); }
        else if (dummyTriggerType == SEPTriggerTypeEnum.BEFORE_UPDATE)  { assertCaseHasHighPriority(dummyCase);}
        
        /*
            FIXME: Currently we have no default/legacies strategies to test for other trigger types.
            
            Potential solution: Create additional stategies which will only execute if (Test.isRunningTest() == true)
             
            else if (dummyTriggerType == SEPTriggerTypeEnum.AFTER_UPDATE)   {}
            else if (dummyTriggerType == SEPTriggerTypeEnum.BEFORE_DELETE)  {}
            else if (dummyTriggerType == SEPTriggerTypeEnum.AFTER_DELETE)   {}
            else if (dummyTriggerType == SEPTriggerTypeEnum.AFTER_UNDELETE) {}
        */
        
        }
    }

    private static void assertCaseHasAccount (Case dummyCase)
    {
        System.assert (dummyCase.AccountId != null);
        System.assert (dummyCase.ContactId != null);
        
        String expectedEmail = dummyCase.SuppliedEmail.toLowerCase(); 
        
        Account resultAccount = [SELECT personEmail FROM Account WHERE id =: dummyCase.accountId LIMIT 1];
        System.assertEquals (expectedEmail, resultAccount.PersonEmail);

        Contact resultContact = [SELECT email FROM Contact WHERE id =: dummyCase.contactId LIMIT 1];
        System.assertEquals (expectedEmail, resultContact.email);
    }

    private static void assertCaseHasEmail (Case dummyCase)
    {
        EmailMessage resultEmailMessage = [ SELECT subject FROM EmailMessage WHERE parentId = :dummyCase.id LIMIT 1];
    //  System.assertEquals (dummyCase.subject, resultEmailMessage.subject);
    }

    private static void assertCaseHasHighPriority (Case dummyCase)
    {
        System.assertEquals (dummyCase.priority,  'High');
    }

    private static testMethod void beforeInsertOtherCountryExecuteStrategyChainTest()   {  otherCountryExecuteStrategyChainTest(SEPTriggerTypeEnum.BEFORE_INSERT);  }
    private static testMethod void afterInsertOtherCountryExecuteStrategyChainTest()    {  otherCountryExecuteStrategyChainTest(SEPTriggerTypeEnum.AFTER_INSERT);   }
    
/** FIXME (see CIC-1279):

Test Failures:
   [deploy] 2.  ECICCaseTriggerHandlerTest.beforeUpdateOtherCountryExecuteStrategyChainTest -- System.NullPointerException: Attempt to de-reference a null object
   [deploy]     Stack trace: Class.ECICCaseTriggerAccountCache.selectBottlerAccountIdSet: line 64, column 1
   [deploy]     Class.ECICCaseTriggerAccountCache.populate: line 12, column 1
   [deploy]     Class.ECICCaseTriggerRelatedRecordHelper.populateCaches: line 55, column 1
   [deploy]     Class.ECICCaseTriggerHandlerHelper.doCountrySpecificStrategies: line 57, column 1
   [deploy]     Class.ECICCaseTriggerHandler.executeStrategyChain: line 82, column 1
   [deploy]     Class.ECICCaseTriggerHandlerTest.otherCountryExecuteStrategyChainTest: line 118, column 1
   [deploy]     Class.ECICCaseTriggerHandlerTest.beforeUpdateOtherCountryExecuteStrategyChainTest: line 168, column 1

    private static testMethod void beforeUpdateOtherCountryExecuteStrategyChainTest()   { otherCountryExecuteStrategyChainTest(SEPTriggerTypeEnum.BEFORE_UPDATE);  }            
**/

    private static testMethod void afterUpdateOtherCountryExecuteStrategyChainTest()    {  otherCountryExecuteStrategyChainTest(SEPTriggerTypeEnum.AFTER_UPDATE);     }            
    private static testMethod void beforeDeleteOtherCountryExecuteStrategyChainTest()   {  otherCountryExecuteStrategyChainTest(SEPTriggerTypeEnum.BEFORE_DELETE);   }            
    private static testMethod void afterDeleteOtherCountryExecuteStrategyChainTest()    {  otherCountryExecuteStrategyChainTest(SEPTriggerTypeEnum.AFTER_DELETE);     }            
    private static testMethod void afterUndeleteOtherCountryExecuteStrategyChainTest()  {  otherCountryExecuteStrategyChainTest(SEPTriggerTypeEnum.AFTER_UNDELETE);  }            
    
    //------------------------------------------------------------------------------------------------------------------------------------  

    private static void onTriggerTypeMethodTest (SEPTriggerTypeEnum dummyTriggerType, Boolean isMethodTest)             
    { 
        Boolean isTriggerTest = !isMethodTest;
        Boolean insertNow =    (SEPTriggerTypeEnum.BEFORE_INSERT != dummyTriggerType)
                            && (
                                        (SEPTriggerTypeEnum.AFTER_INSERT  != dummyTriggerType)
                                    ||  ((SEPTriggerTypeEnum.AFTER_INSERT  == dummyTriggerType) && isMethodTest)
                               ); 

        ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
        Case_Trigger_Strategy_Configuration__c dummyStrategyConfig = TEST_DummyCaseTrigStrategyConfigFactory.create(dummyTriggerType, TEST_DummyInsertModeEnum.REAL);
        ECICCaseTriggerHandler handler   = new ECICCaseTriggerHandler(true);

        ECICCaseTestHelper.CaseConfig caseConfig = new ECICCaseTestHelper.CaseConfig();
                                      caseConfig.countryCode = TEST_DummyCaseTrigStrategyConfigFactory.DEFAULT_COUNTRY;
        Case          dummyCase = ECICCaseTestHelper.createDummyCase (caseConfig, insertNow);
        Id            dummyCaseId            = dummyCase.id;
        List<Case>    dummyOldCaseList       = new List<Case>   {dummyCase};
        List<Case>    dummyNewCaseList       = new List<Case>   {dummyCase};
        Map<Id,Case>  dummyOldCaseByIdMap    = new Map<Id,Case> {dummyCase.id => dummyCase};
        Map<Id,Case>  dummyNewCaseByIdMap    = new Map<Id,Case> {dummyCase.id => dummyCase};
        if ((isTriggerTest) && (SEPTriggerTypeEnum.AFTER_UNDELETE == dummyTriggerType)) { delete dummyCase; }

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                if (isMethodTest)
                {
                    if (SEPTriggerTypeEnum.BEFORE_INSERT  == dummyTriggerType) { handler.OnBeforeInsert  (dummyNewCaseList); } 
                    if (SEPTriggerTypeEnum.AFTER_INSERT   == dummyTriggerType) { handler.OnAfterInsert   (dummyNewCaseList, dummyNewCaseByIdMap); } 
                    if (SEPTriggerTypeEnum.BEFORE_UPDATE  == dummyTriggerType) { handler.OnBeforeUpdate  (dummyOldCaseList, dummyNewCaseList,  dummyOldCaseByIdMap, dummyNewCaseByIdMap); } 
                    if (SEPTriggerTypeEnum.AFTER_UPDATE   == dummyTriggerType) { handler.OnAfterUpdate   (dummyOldCaseList, dummyNewCaseList,  dummyOldCaseByIdMap, dummyNewCaseByIdMap); } 
                    if (SEPTriggerTypeEnum.BEFORE_DELETE  == dummyTriggerType) { handler.OnBeforeDelete  (dummyOldCaseList, dummyOldCaseByIdMap); } 
                    if (SEPTriggerTypeEnum.AFTER_DELETE   == dummyTriggerType) { handler.OnAfterDelete   (dummyOldCaseList, dummyOldCaseByIdMap); } 
                    if (SEPTriggerTypeEnum.AFTER_UNDELETE == dummyTriggerType) { handler.OnAfterUndelete (dummyNewCaseList, dummyNewCaseByIdMap); }
                }
                else // if Trigger Test
                {
                    if (SEPTriggerTypeEnum.BEFORE_INSERT == dummyTriggerType)  { insert dummyCase;   } 
                    if (SEPTriggerTypeEnum.AFTER_INSERT == dummyTriggerType)   { insert dummyCase;   } 
                    if (SEPTriggerTypeEnum.BEFORE_UPDATE == dummyTriggerType)  { update dummyCase;   } 
                    if (SEPTriggerTypeEnum.AFTER_UPDATE == dummyTriggerType)   { update dummyCase;   } 
                    if (SEPTriggerTypeEnum.BEFORE_DELETE  == dummyTriggerType) { delete dummyCase;   } 
                    if (SEPTriggerTypeEnum.AFTER_DELETE   == dummyTriggerType) { delete dummyCase;   } 
                    if (SEPTriggerTypeEnum.AFTER_UNDELETE == dummyTriggerType) { undelete dummyCase; }
                } 
            }
            

        if (isMethodTest)
        {
            ECICCaseTriggerHandlerTestStrategy.assertExecution(true, true, dummyTriggerType, dummyCase);
        }
        else // if Trigger Test
        {
            List<Case> resultCaseList = [SELECT id, subject FROM Case WHERE id = :dummyCase.id LIMIT 1];
            if ((new Set<SEPTriggerTypeEnum>{SEPTriggerTypeEnum.BEFORE_DELETE, SEPTriggerTypeEnum.AFTER_DELETE}).contains(dummyTriggerType))
            {
                System.assertEquals (0, resultCaseList.size());

                
                ECICCaseTriggerHandlerTestStrategy.assertExecution(true, true, dummyTriggerType, dummyCaseId); 
            }
            else
            {
                System.assertEquals (1, resultCaseList.size());
                ECICCaseTriggerHandlerTestStrategy.assertExecution(true, true, dummyTriggerType, resultCaseList[0]);
            }

        }
        Test.stopTest();
        }
    }



    private static testMethod void beforeInsertOnTriggerTypeMethodTest()   {  onTriggerTypeMethodTest(SEPTriggerTypeEnum.BEFORE_INSERT,  true);  }
    private static testMethod void afterInsertOnTriggerTypeMethodTest()    {  onTriggerTypeMethodTest(SEPTriggerTypeEnum.AFTER_INSERT,   true);  }           
    private static testMethod void beforeUpdateOnTriggerTypeMethodTest()   {  onTriggerTypeMethodTest(SEPTriggerTypeEnum.BEFORE_UPDATE,  true);  }           
    private static testMethod void afterUpdateOnTriggerTypeMethodTest()    {  onTriggerTypeMethodTest(SEPTriggerTypeEnum.AFTER_UPDATE,   true);  }           
    private static testMethod void beforeDeleteOnTriggerTypeMethodTest()   {  onTriggerTypeMethodTest(SEPTriggerTypeEnum.BEFORE_DELETE,  true);  }           
    private static testMethod void afterDeleteOnTriggerTypeMethodTest()    {  onTriggerTypeMethodTest(SEPTriggerTypeEnum.AFTER_DELETE,   true);  }           
    private static testMethod void afterUndeleteOnTriggerTypeMethodTest()  {  onTriggerTypeMethodTest(SEPTriggerTypeEnum.AFTER_UNDELETE, true);  }           

    private static testMethod void OnBeforeInsertTriggerTest()             {  onTriggerTypeMethodTest(SEPTriggerTypeEnum.BEFORE_INSERT,  false);   }
    private static testMethod void OnAfterInsertTriggerTest()              {  onTriggerTypeMethodTest(SEPTriggerTypeEnum.AFTER_INSERT,   false);   }             
    private static testMethod void OnBeforeUpdateTriggerTest()             {  onTriggerTypeMethodTest(SEPTriggerTypeEnum.BEFORE_UPDATE,  false);   }             
    private static testMethod void OnAfterUpdateTriggerTest()              {  onTriggerTypeMethodTest(SEPTriggerTypeEnum.AFTER_UPDATE,   false);   }             
    private static testMethod void OnBeforeDeleteTriggerTest()             {  onTriggerTypeMethodTest(SEPTriggerTypeEnum.BEFORE_DELETE,  false);   }             
    private static testMethod void OnAfterDeleteTriggerTest()              {  onTriggerTypeMethodTest(SEPTriggerTypeEnum.AFTER_DELETE,   false);   }             
    private static testMethod void OnAfterUnDeleteTriggerTest()            {  onTriggerTypeMethodTest(SEPTriggerTypeEnum.AFTER_UNDELETE, false);   }             

}