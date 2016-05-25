@isTest
private class ECICCaseAccountAndContactSetterStratTest {
    private class DummyException extends Exception {}
    
    private static final User TEST_RUN_USER = ECICRunUserTestHelper.create();
    private static ECICCaseAccountAndContactSetterStrategy dummyStrategy = new ECICCaseAccountAndContactSetterStrategy();
    
    // On Before Tests----------------------------------------------------------------------------------------------------------------------------
    
    public static testMethod void OnBeforeInsertTest() {
        Boolean isSet = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                isSet = dummyStrategy.OnBeforeInsert(new List<Case>());	
            }
            Test.stopTest();
        }
        System.assert(isSet);
    }
    
    // Insert (Email and Web) Strategy Tests -----------------------------------------------------------------------------------------------------------------------------
    
    public static void setAccountAndContactOnEmailAndWebCasesTest2(String origin, Boolean hasSuppliedEmail, Boolean throwsExceptionTest) {
        setupGeneralSettings();
        Integer emailMessageListSizeBefore = ECICCaseTriggerEmailMessageCache.emailMessagesToSendCache.size();
        Region__c           dummyBottlerRegion  = TEST_DummyRegionFactory.create ('Bottler', ECICCommonConstants.COUNTRY_CODE_DEFAULT, true); 
        Account             dummyBottlerAccount = TEST_DummyAccountFactory.createBottler(dummyBottlerRegion, true);
        Plant__c            dummyPlant          = TEST_DummyPlantFactory.create(dummyBottlerAccount.id, dummyBottlerRegion.id, true);
        Production_Line__c  dummyProductionLine = TEST_DummyProductionLineFactory.create(dummyPlant.id, true);
        
        TEST_UniqueHelper uniqueHelper = new TEST_UniqueHelper('Dummy Supplied Email'); 
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.suppliedEmail   = (hasSuppliedEmail) ? (uniqueHelper.uniqueSpaceless + '@supplied.example.com') : null;
                             caseConfig.origin          = origin;
                             caseConfig.subject         = (throwsExceptionTest) ? 'Throws Exception Test' : null;
        
        Case dummyCase              = TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.NONE);
        List<Case> dummyNewCaseList = new List<Case>{ dummyCase };
        Boolean caughtException     = false;
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                try {
                    dummyStrategy.setAccountAndContactOnEmailAndWebCases(dummyNewCaseList);
                } catch (Exception e) {
                    caughtException = true;
                } 
            }
            Test.stopTest();
        }
        
        Integer emailMessageListSizeAfter = ECICCaseTriggerEmailMessageCache.emailMessagesToSendCache.size();
        System.assert (!caughtException);  // if Exception is caught, Exception has not been handled (as it should have been). 
        if ((!caughtException) && (new Set<String>{'email','web'}).contains(origin) && ((origin != 'email') || (hasSuppliedEmail))) { assertCase ( dummyNewCaseList); }
        if (throwsExceptionTest) {
            System.assertEquals (false, caughtException);
            System.assertNotEquals (emailMessageListSizeBefore, emailMessageListSizeAfter);
        }
    }
    
    public static testMethod void emailSuppliedSetAccountAndContactOnEmailAndWebCasesTest()   { setAccountAndContactOnEmailAndWebCasesTest2('Email', true,     false); }
    public static testMethod void emailunSuppliedSetAccountAndContactOnEmailAndWebCasesTest() { setAccountAndContactOnEmailAndWebCasesTest2('Email', false,    false); }
    public static testMethod void emailExceptionSetAccountAndContactOnEmailAndWebCasesTest()  { setAccountAndContactOnEmailAndWebCasesTest2('Email', true,     true);  }
    public static testMethod void webSetAccountAndContactOnEmailAndWebCasesTest()             { setAccountAndContactOnEmailAndWebCasesTest2('Web',   false,    false); }
    public static testMethod void webExceptionSetAccountAndContactOnEmailAndWebCasesTest()    { setAccountAndContactOnEmailAndWebCasesTest2('Web',   false,    true);  }
    public static testMethod void otherSetAccountAndContactOnEmailAndWebCasesTest()           { setAccountAndContactOnEmailAndWebCasesTest2('other', false,    false); }
    //--------------------------------------------------------------------------------------------------------------------------------------------------
    
    public static testMethod void notifySupportAboutCaseProcessingErrorTest() {
        setupGeneralSettings();
        Integer emailMessageListSizeBefore = ECICCaseTriggerEmailMessageCache.emailMessagesToSendCache.size();
        
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.subject         = 'Throws Exception Test';
        
        Case dummyCase              = TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.NONE);
        List<Case> dummyCaseList    = new List<Case>{ dummyCase };
        
        System.runAs(TEST_RUN_USER)  {
            Test.startTest();
            {
                dummyStrategy.notifySupportAboutCaseProcessingError(new DummyException(), dummyCaseList);
            }
            Test.stopTest();
        }
        
        Integer emailMessageListSizeAfter = ECICCaseTriggerEmailMessageCache.emailMessagesToSendCache.size();
        System.assertNotEquals (emailMessageListSizeBefore, emailMessageListSizeAfter, 'Should have increased');
    }
    
// Helper Methods --------------------------------------------------------------------------------------------------------------------------------------------------
    
    private static void setupGeneralSettings () {
        General_Settings__c generalSettings = new General_Settings__c();
        generalSettings.supportEmail__c     = 'testSupportEmail@test.com';
        insert generalSettings;
    }
    
    private static void assertCase (List<Case> dummyResultList) {
        for (Case dummyResult : dummyResultList) {
            System.assert (dummyResult.accountId != null);
            System.assert (dummyResult.contactId != null);
        }
    }

}