@isTest
private class ECICLinkCaseAndOpenAlertsHandlerTest 
{
    private static final User    TEST_RUN_USER  = ECICRunUserTestHelper.create();
    private static final String DUMMY_COUNTRY_CODE  = ECICCommonConstants.COUNTRY_CODE_DEFAULT;


    private static void addConditionTest(Boolean hasConditionMap, Boolean isFieldDate)              
    { 
        String                   dummyFieldName    = 'Dummy Field';
        Map<String, Set<String>> dummyConditionMap = new Map<String, Set<String>>();
        if (hasConditionMap) {   dummyConditionMap.put (dummyFieldName , new Set<String>()); }  
        Object                   dummyFieldValue   = (isFieldDate) 
                                                        ? ((Object) Date.today()) 
                                                        : ((Object) ('Dummy Value'));
        
        System.runAs(TEST_RUN_USER)
        {
            ECICLinkCaseAndOpenAlertsHandler.addCondition(dummyConditionMap, dummyFieldName, dummyFieldValue);
        }
        
        String expectedValue = (isFieldDate) 
                                    ?  ((Datetime) (Date.today())).format('yyyy-MM-dd') 
                                    :  ('\'Dummy Value\'') ;

        System.assert (dummyConditionMap.containsKey(dummyFieldName));
        System.assert (dummyConditionMap.get(dummyFieldName).contains(expectedValue));
    }
    
    private static testMethod void noMapStringAddConditionTest()    { addConditionTest (false, false); }
    private static testMethod void noMapDateAddConditionTest()      { addConditionTest (false, true);  }
    private static testMethod void hasMapStringAddConditionTest()   { addConditionTest (true,  false); }
    private static testMethod void hasMapDateAddConditionTest()     { addConditionTest (true,  true);  }
    
    // ----------------------------------------------------------------------------------------

    private static void sublistLinkedCasesAndOpenAlertsTest(String caseStatus)  
    { 
         TEST_DummyCaseConfig   caseConfig                  = new TEST_DummyCaseConfig();
                                caseConfig.status           = caseStatus;
                                caseConfig.categoryLevel3   = 'Dummy Value';
        
         Case dummyCase  = TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.MOCK);
         
         Map<String, Set<String>> dummyConditionMap = new Map<String, Set<String>>();
         
         Map<String, List<Object>> resultSubListMap = null;
         System.runAs(TEST_RUN_USER)
         {
            resultSubListMap = ECICLinkCaseAndOpenAlertsHandler.sublistLinkedCasesAndOpenAlerts(new List<Case>{dummyCase}, dummyConditionMap);
         }
         
        List<ECICLinkCaseAndOpenAlertsConfigEntry> resultCaseConfigEntryList = (List<ECICLinkCaseAndOpenAlertsConfigEntry>) resultSubListMap.get('caseConfigEntryList');
        List<Id>                                           resultCancelledIdList     = (List<Id>)                                           resultSubListMap.get('cancelledIdList');
        
        if (new Set<String>{ ECICCommonConstants.STATUS_NEW, ECICCommonConstants.STATUS_CLOSED }.contains(caseStatus))
        {
            System.assert (dummyConditionMap.isEmpty());
            System.assert (resultCaseConfigEntryList.size() == 0);
            System.assert (resultCancelledIdList.size()     == 0);
        }
        else if (caseStatus == ECICCommonConstants.STATUS_CANCELLED)
        {
            System.assert (dummyConditionMap.isEmpty());
            System.assert (resultCaseConfigEntryList.size() == 0);
            Set<Id>        resultCancelledIdSet = new Set<Id>();
                           resultCancelledIdSet.addAll(resultCancelledIdList);
            System.assert (resultCancelledIdSet.contains(dummyCase.id));
        }
        else
        {
            System.assert (dummyConditionMap.get('Category_Level3__c').contains('\'Dummy Value\''));
            System.assert (resultCaseConfigEntryList.size() == 1);
            ECICLinkCaseAndOpenAlertsConfigEntry resultCaseConfigEntry = resultCaseConfigEntryList[0];
            System.assertEquals (dummyCase.id, resultCaseConfigEntry.id); 
            System.assertEquals (dummyCase, resultCaseConfigEntry.obj);
            Set<String>    resultArgSet = new Set<String> ();
                           resultArgSet.addAll(resultCaseConfigEntry.args);
            System.assert (resultArgSet.contains('Dummy Value')); 
            System.assert       (resultCancelledIdList.size()     == 0);
        }
        
    }

    private static testMethod void newCaseSublistLinkedCasesAndOpenAlertsTest()         { sublistLinkedCasesAndOpenAlertsTest (ECICCommonConstants.STATUS_NEW);         }
    private static testMethod void closedCaseSublistLinkedCasesAndOpenAlertsTest()      { sublistLinkedCasesAndOpenAlertsTest (ECICCommonConstants.STATUS_CLOSED);      }
    private static testMethod void cancelledCaseSublistLinkedCasesAndOpenAlertsTest()   { sublistLinkedCasesAndOpenAlertsTest (ECICCommonConstants.STATUS_CANCELLED);   }
    private static testMethod void openCaseSublistLinkedCasesAndOpenAlertsTest()        { sublistLinkedCasesAndOpenAlertsTest (ECICCommonConstants.STATUS_OPEN);        }

    // ----------------------------------------------------------------------------------------

    private static testMethod void queryOpenAlertListTest()                 
    { 
        Map<String, Set<String>> dummyConditionMap = new Map<String, Set<String>>{'Category_Level3__c' => new Set<String>{'\'Dummy Value\''}};
        
        TEST_DummyOpenAlertFactory.Config   config                  = new TEST_DummyOpenAlertFactory.Config();
                                            config.categoryLevel3   = 'Dummy Value';
        Open_Alert__c dummyOpenAlert = TEST_DummyOpenAlertFactory.create (config, TEST_DummyInsertModeEnum.REAL);
        
        List<Open_Alert__c> resultOpenAlertList = null;
        System.runAs(TEST_RUN_USER)
        {
            resultOpenAlertList = ECICLinkCaseAndOpenAlertsHandler.queryOpenAlertList(dummyConditionMap);
        } 
        
        System.assert(resultOpenAlertList.size() == 1);
        Open_Alert__c resultOpenAlert = resultOpenAlertList[0];
        System.assertEquals (dummyOpenAlert.id, resultOpenAlert.id);
    }

    // ----------------------------------------------------------------------------------------

    private static testMethod void deleteOpenAlertCasesTest()               
    {
        Case dummyCase = TEST_DummyFastQualityComplaintCaseFactry.create(TEST_DummyInsertModeEnum.REAL);
        Set<Id> dummyCaseIdSet = new Set<Id>{dummyCase.id};
        
        Test.startTest();
        List<Open_Alert__c> dummyOpenAlertList = TEST_DummyOpenAlertFactory.createList(2, TEST_DummyInsertModeEnum.REAL);
        
        Open_Alert_Case__c dummyOpenAlertCase0 = TEST_DummyOpenAlertCaseFactory.create(new TEST_DummyOpenAlertCaseFactory.Config(dummyCase.id, dummyOpenAlertList[0].id), TEST_DummyInsertModeEnum.NONE);
        Open_Alert_Case__c dummyOpenAlertCase1 = TEST_DummyOpenAlertCaseFactory.create(new TEST_DummyOpenAlertCaseFactory.Config(dummyCase.id, dummyOpenAlertList[1].id), TEST_DummyInsertModeEnum.NONE);
        insert (new List<Open_Alert_Case__c>{ dummyOpenAlertCase0, dummyOpenAlertCase1});
        
        System.runAs(TEST_RUN_USER)
        {
            ECICLinkCaseAndOpenAlertsHandler.deleteOpenAlertCases(dummyCaseIdSet, new List<Open_Alert__c>{dummyOpenAlertList[0]});
        } 
        
        
        List<Open_Alert_Case__c> resultOpenAlertCaseList = [SELECT id, case__c, open_alert__c FROM Open_Alert_Case__c WHERE case__c = :dummyCase.id];
        System.assert(resultOpenAlertCaseList.size() == 1);
        System.assertEquals (dummyOpenAlertList[0].id, resultOpenAlertCaseList[0].open_alert__c);
        System.assertEquals (dummyCase.id,             resultOpenAlertCaseList[0].case__c);
        Test.stopTest();
    }


    // ----------------------------------------------------------------------------------------


}