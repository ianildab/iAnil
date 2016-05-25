@isTest
private class ECICCaseDispatherTest {
    public  static final User            TEST_RUN_USER                       = TEST_DummyUserFactory.createDefaultTestRunUser();
    public  static final Map<String,Id>  CASE_RECORD_TYPE_ID_BY_NAME_MAP     = SEPRecordTypesCache.GetRecordTypeIdsByDeveloperNameMap(Case.SObjectType);
    private static final String          DUMMY_COUNTRY_CODE                  = 'T0';
    private static final String          CASE_PARENT_ACC_ID_PARAM_KEY        = 'def_account_id';
    private static final String          CASE_PARENT_CONT_ID_PARAM_KEY       = 'def_contact_id';
    
    private static void newCaseTest(Boolean isRecordTypeAvailable, String recordTypeDevName) {
        if (isRecordTypeAvailable) { enableRecordTypeForTestUser (recordTypeDevName); }
        String          dummyReturnUrl  = 'http://return.example.com';
        PageReference   nextPage        = null;
        Boolean         exceptionCaught = false;
        
        System.runAs(TEST_RUN_USER) {
            // Set test page pssing initial parameters.
            PageReference        pageRef = Page.ECIC_CreateCase;
                                 pageRef.getParameters().put('RecordType',      CASE_RECORD_TYPE_ID_BY_NAME_MAP.get(recordTypeDevName));
                                 pageRef.getParameters().put('retURL',          dummyReturnUrl);
                                 pageRef.getParameters().put('save_new_url',    'http://save.example.com');
                                 pageRef.getParameters().put(CASE_PARENT_ACC_ID_PARAM_KEY, TEST_DummyRegionFactory.create(TEST_DummyInsertModeEnum.MOCK).Id);
                                 pageRef.getParameters().put(CASE_PARENT_CONT_ID_PARAM_KEY, TEST_DummyContactFactory.create(TEST_DummyInsertModeEnum.MOCK).Id);
                                 
            Test.setCurrentPage (pageRef);
            
            // Instantiate the standard Controller and Extension
            Case dummyNewCase = new Case();
            ApexPages.StandardController    standardController             = new ApexPages.StandardController(dummyNewCase);
            ECICCaseDispather               dispatherControllerExtension   = new ECICCaseDispather(standardController);
            
            Test.startTest();
            {
                try {
                    nextPage = dispatherControllerExtension.newCase();
                    if (!isRecordTypeAvailable) { throw new ExpectedExceptionNotCaughtException(); }
                } catch (Exception Ex) {
                    exceptionCaught = true;
                    System.assertEquals(Label.Case_NoEnabledCountries_Error, ApexPages.GetMessages().get(0).getSummary());
                }
            }
            Test.stopTest();
        }
        
        System.assertEquals (isRecordTypeAvailable, !exceptionCaught && nextPage.getUrl().contains( EncodingUtil.urlEncode(dummyReturnUrl,'UTF-8')));
    }
    /*#CICTemplateTest - Start*/
    private static testMethod void inquiryNotAvailableNewCaseTest()                 { newCaseTest(false,    ECICCommonConstants.INQUIRY_IBERIA_DEVNAME                        );  }
    //private static testMethod void jokeNotAvailableNewCaseTest()                    { newCaseTest(false,    'Joke_Useless'                  );  }
    private static testMethod void nonQComplaintNotAvailableNewCaseTest()           { newCaseTest(false,    ECICCommonConstants.NON_QUALITY_COMPLAINT_IBERIA_DEVNAME         );  }
    private static testMethod void qComplaintNotAvailableNewCaseTest()              { newCaseTest(false,    ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME             );  }
    //private static testMethod void simplifiedQComplaintNotAvailableNewCaseTest()    { newCaseTest(false,    'Simplified_Quality_Complaint'  );  }
    //private static testMethod void spamNotAvailableNewCaseTest()                    { newCaseTest(false,    'Spam'                          );  }
    //private static testMethod void thanksNotAvailableNewCaseTest()                  { newCaseTest(false,    'Thanks'                        );  }
    
    private static testMethod void inquiryAvailableNewCaseTest()                    { newCaseTest(true,     ECICCommonConstants.INQUIRY_IBERIA_DEVNAME                       );  }
    //private static testMethod void jokeAvailableNewCaseTest()                       { newCaseTest(true,     'Joke_Useless'                  );  }
    private static testMethod void nonQComplaintAvailableNewCaseTest()              { newCaseTest(true,     ECICCommonConstants.NON_QUALITY_COMPLAINT_IBERIA_DEVNAME         );  }
    private static testMethod void qComplaintAvailableNewCaseTest()                 { newCaseTest(true,     ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME             );  }
    //private static testMethod void simplifiedQComplaintAvailableNewCaseTest()       { newCaseTest(true,     'Simplified_Quality_Complaint'  );  }
    //private static testMethod void spamAvailableNewCaseTest()                       { newCaseTest(true,     'Spam'                          );  }
    //private static testMethod void thanksAvailableNewCaseTest()                     { newCaseTest(true,     'Thanks'                        );  }
    /*#CICTemplateTest - End*/
    //---------------------------------------------------------------------------------------------------------------------------------------
    
    private static testMethod void redirectToMainTest() {
        Case                            dummyNewCase                   = new Case();
        ApexPages.StandardController    standardController             = new ApexPages.StandardController(dummyNewCase);
        ECICCaseDispather               dispatherControllerExtension   = new ECICCaseDispather(standardController);
        PageReference                   pageRef                        = null;
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                 pageRef = dispatherControllerExtension.redirectToMain();
            }
            Test.stopTest();
        }
        
        String expectedResult = '/setup/ui/recordtypeselect.jsp';
        System.assertEquals (true, pageRef.getRedirect());
        System.assertEquals (true, pageRef.getUrl().startsWithIgnoreCase(expectedResult));
    }
    
    //---------------------------------------------------------------------------------------------------------------------------------------

    private static void enableRecordTypeForTestUser (String dummyRecordTypeName) {
        TEST_DummyCountrySpecificSettingsFactory.Config dummyConfig = new TEST_DummyCountrySpecificSettingsFactory.Config();
                                                        dummyConfig.countryCode               = DUMMY_COUNTRY_CODE;
                                                        dummyConfig.allowedCaseRecordTypes    = dummyRecordTypeName + ';';
        TEST_DummyCountrySpecificSettingsFactory.create(dummyConfig, true);
        
        User   dummyUser                        = TEST_RUN_USER;
               dummyUser.enabled_countries__c   = DUMMY_COUNTRY_CODE + ';';
        update dummyUser;
    }
    
    private class ExpectedExceptionNotCaughtException extends Exception {}
}