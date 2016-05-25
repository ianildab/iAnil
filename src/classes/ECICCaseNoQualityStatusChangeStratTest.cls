@isTest
private class ECICCaseNoQualityStatusChangeStratTest 
{   /*#CICTemplateTest*/
    private static final Map<String,User> USER_BY_PROFILE_MAP = ECICRunUserTestHelper.createMap(new List<String>{
                                                                                                                    ECICCommonConstants.PROFILE_SYSTEM_ADMIN, 
                                                                                                                    ECICCommonConstants.PROFILE_ECIC_IBERIA_COCA_COLA_QUALITY,     // Disallowed profile 
                                                                                                                    ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT,        // Allowed profile
                                                                                                                    ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_SUPERVISOR ,   // Allowed profile
                                                                                                                    ECICCommonConstants.PROFILE_ECIC_IBERIA_EXTERNAL_RELATIONS     // Allowed profile
                                                                                                                });
    /*#CICTemplateTest*/
    private static final Set<String>          ALLOWED_PROFILE_SET = new Set<String>
    {
            ECICCommonConstants.PROFILE_SYSTEM_ADMIN, 
            ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT, 
            ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_SUPERVISOR, 
            ECICCommonConstants.PROFILE_ECIC_IBERIA_EXTERNAL_RELATIONS
    };
    
    private static final Set<String> NON_MUTABLE_STATUS_SET    = new Set<String>{ECICCommonConstants.STATUS_NEW, ECICCommonConstants.STATUS_CANCELLED, ECICCommonConstants.STATUS_CLOSED};
    private static final Account     POINT_OF_SALE_KEY_ACCOUNT = TEST_DummyAccountFactory.createPointOfSaleKey(true);
    private static final User        TEST_RUN_USER             = USER_BY_PROFILE_MAP.get(ECICCommonConstants.PROFILE_SYSTEM_ADMIN);
    
    static
    {
        for (String profileName : USER_BY_PROFILE_MAP.keySet())
        {
            TEST_DummyProfileMappingFactory.setMockProfileId (USER_BY_PROFILE_MAP.get(profileName).LastName, profileName); 
        }
    }

    private static void constructorTest(String profileName)             
    { 
        User testRunUser = USER_BY_PROFILE_MAP.get(profileName);

        ECICCaseNoQualityStatusChangeStrategy resultStrategy = null;
        System.runAs(testRunUser)
        {
            Test.startTest();
            {
                resultStrategy = new ECICCaseNoQualityStatusChangeStrategy();
            }
            Test.stopTest();
        }
        
        System.assertEquals (!ALLOWED_PROFILE_SET.contains(profileName), resultStrategy.isUserInDisallowedProfile);
    }
    /*#CICTemplateTest - Start*/
    private static testMethod void systemAdminConstructorTest()        { constructorTest(ECICCommonConstants.PROFILE_SYSTEM_ADMIN);             }
    private static testMethod void kOQualityConstructorTest()          { constructorTest(ECICCommonConstants.PROFILE_ECIC_IBERIA_COCA_COLA_QUALITY);   }
    private static testMethod void infolineAgentConstructorTest()      { constructorTest(ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT);      }
    private static testMethod void infolineSupervisorConstructorTest() { constructorTest(ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_SUPERVISOR); }
    private static testMethod void externalRelationConstructorTest()   { constructorTest(ECICCommonConstants.PROFILE_ECIC_IBERIA_EXTERNAL_RELATIONS);  }
    /*#CICTemplateTest - End*/
    // ---------------------------------------------------------------------------------------------------------------------------

    private static void confirmNoQualityStatusChangeTest(String recordType, String status, Boolean noQualityStatusChange, Boolean hasOld, Boolean hasQualityStatusChange)           
    { 
        ECICCaseNoQualityStatusChangeStrategy dummyStrategy = new ECICCaseNoQualityStatusChangeStrategy();

        Case dummyNewCase = createNewCase (recordType, status, noQualityStatusChange);
        Case dummyOldCase = (hasOld) ? (createOldCase (dummyNewCase, hasQualityStatusChange)) : (null);
        if (dummyOldCase != null) { dummyNewCase.id = dummyOldCase.id; }

        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = dummyStrategy.confirmNoQualityStatusChange (dummyNewCase, dummyOldCase);
            }
            Test.stopTest();
        }
        /*#CICTemplateTest*/
        Boolean expectedResult = (
                                        (recordType == ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME)
                                    && (!NON_MUTABLE_STATUS_SET.contains(status))
                                    && (!noQualityStatusChange)
                                    && (!hasOld || !hasQualityStatusChange)
                                );
        System.assertEquals (expectedResult, result);
    }
    /*#CICTemplateTest - Start*/
    // Expected FALSE
    private static testMethod void newInquiryconfirmNoQualityStatusChangeTest()                             { confirmNoQualityStatusChangeTest(ECICCommonConstants.INQUIRY_IBERIA_DEVNAME,                       ECICCommonConstants.STATUS_NEW,       false, false, false); }
    //private static testMethod void openJokeconfirmNoQualityStatusChangeTest()                               { confirmNoQualityStatusChangeTest('Joke_Useless',                  ECICCommonConstants.STATUS_OPEN,      false, false, false); }
    //private static testMethod void closedSameStausJokeconfirmNoQualityStatusChangeTest()                    { confirmNoQualityStatusChangeTest('Joke_Useless',                  ECICCommonConstants.STATUS_CLOSED,    false, true,  true ); }
    private static testMethod void openNonQComplaintCheckedconfirmNoQualityStatusChangeTest()               { confirmNoQualityStatusChangeTest(ECICCommonConstants.NON_QUALITY_COMPLAINT_IBERIA_DEVNAME,         ECICCommonConstants.STATUS_OPEN,      true,  false, false); }
    private static testMethod void openSameStatusNQComplaintconfirmNoQualityStatusChangeTest()              { confirmNoQualityStatusChangeTest(ECICCommonConstants.NON_QUALITY_COMPLAINT_IBERIA_DEVNAME,         ECICCommonConstants.STATUS_OPEN,      false, true,  true ); }
    private static testMethod void cancelledOldQComplaintconfirmNoQualityStatusChangeTest()                 { confirmNoQualityStatusChangeTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,             ECICCommonConstants.STATUS_CANCELLED, false, true,  false); }
    private static testMethod void cancelledCheckedSameStatusSQComplaintconfirmNoQualityStatusChangeTest()  { confirmNoQualityStatusChangeTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,             ECICCommonConstants.STATUS_CANCELLED, true,  true,  true ); }
    private static testMethod void closedQComplaintCheckedconfirmNoQualityStatusChangeTest()                { confirmNoQualityStatusChangeTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,             ECICCommonConstants.STATUS_CLOSED,    true,  false, false); }
    private static testMethod void newOldCheckedQComplaintconfirmNoQualityStatusChangeTest()                { confirmNoQualityStatusChangeTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,             ECICCommonConstants.STATUS_NEW,       true,  true,  false); }
    private static testMethod void openQComplaintCheckedconfirmNoQualityStatusChangeTest()                  { confirmNoQualityStatusChangeTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,             ECICCommonConstants.STATUS_OPEN,      true,  false, false); }
    private static testMethod void openOldCheckedQComplaintconfirmNoQualityStatusChangeTest()               { confirmNoQualityStatusChangeTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,             ECICCommonConstants.STATUS_OPEN,      true,  true,  false); }
    private static testMethod void openCheckedSameStatusQComplaintconfirmNoQualityStatusChangeTest()        { confirmNoQualityStatusChangeTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,             ECICCommonConstants.STATUS_OPEN,      true,  true,  true ); }
    private static testMethod void openOldQComplaintconfirmNoQualityStatusChangeTest()                      { confirmNoQualityStatusChangeTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,             ECICCommonConstants.STATUS_OPEN,      false, true,  false); }
    //private static testMethod void openOldSQComplaintconfirmNoQualityStatusChangeTest()                     { confirmNoQualityStatusChangeTest('Simplified_Quality_Complaint',  ECICCommonConstants.STATUS_OPEN,      false, true,  false); }
    //private static testMethod void openCheckedSameStatusSQComplaintconfirmNoQualityStatusChangeTest()       { confirmNoQualityStatusChangeTest('Simplified_Quality_Complaint',  ECICCommonConstants.STATUS_OPEN,      true,  true,  true ); }
    //private static testMethod void openOldCheckedThanksconfirmNoQualityStatusChangeTest()                   { confirmNoQualityStatusChangeTest('Thanks',                        ECICCommonConstants.STATUS_OPEN,      true,  true,  false); }

    // Expected TRUE
    private static testMethod void openQComplaintconfirmNoQualityStatusChangeTest()                         { confirmNoQualityStatusChangeTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,             ECICCommonConstants.STATUS_OPEN,      false, false, false); }
    private static testMethod void openSameStatusQComplaintconfirmNoQualityStatusChangeTest()               { confirmNoQualityStatusChangeTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,             ECICCommonConstants.STATUS_OPEN,      false, true,  true ); }
    /*#CICTemplateTest - End*/
    // ---------------------------------------------------------------------------------------------------------------------------

    private static void executeTest(Boolean userAllowed, Boolean changeConfirmed, Boolean hasOldCase)           
    {   /*#CICTemplateTest*/
        String        profileName           = (userAllowed) ? ECICCommonConstants.PROFILE_SYSTEM_ADMIN : ECICCommonConstants.PROFILE_ECIC_IBERIA_COCA_COLA_QUALITY;
        User          testRunUser           = USER_BY_PROFILE_MAP.get(profileName);
        
        Boolean       hasNoQualityStatusChange = !changeConfirmed;
        /*#CICTemplateTest*/
        Case          dummyNewCase          = createNewCase (ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME, ECICCommonConstants.STATUS_OPEN, hasNoQualityStatusChange);
        List<Case>    dummyNewCaseList      = new List<Case> { dummyNewCase };

        Case          dummyOldCase          = (hasOldCase) ? (createOldCase (dummyNewCase, false)) : (null);
        Map<Id, Case> dummyOldCaseByIdMap   = null;
        if (dummyOldCase != null) 
        { 
                      dummyNewCase.id       = dummyOldCase.id; 
                      dummyOldCaseByIdMap   = new Map<Id, Case>{ dummyOldCase.id => dummyOldCase }; 
        }
        
        System.runAs(testRunUser)
        {
            Test.startTest();
            {
                (new ECICCaseNoQualityStatusChangeStrategy()).execute(dummyOldCaseByIdMap, dummyNewCaseList);
            }
            Test.stopTest();
        }
        
        if (hasNoQualityStatusChange) { System.assert (!dummyNewCase.no_quality_status_change__c); }

        String errorMessage = TEST_MockHelper.getMockString(dummyNewCase, 'error');
        System.assertEquals ((!userAllowed && changeConfirmed), ((errorMessage != null) && (errorMessage.contains(System.Label.NoQualityStatusChange))));
    }

    private static testMethod void disallowedUserExecuteTest()                      { executeTest(  false,  false,  false   ); }
    private static testMethod void disallowedUserHasOldExecuteTest()                { executeTest(  false,  false,  true    ); }
    private static testMethod void disallowedUserChangeConfirmedExecuteTest()       { executeTest(  false,  true,   false   ); }
    private static testMethod void disallowedUserChangeConfirmedHasOldExecuteTest() { executeTest(  false,  true,   true    ); }
    private static testMethod void allowedUserExecuteTest()                         { executeTest(  true,   false,  false   ); }
    private static testMethod void allowedUserHasOldExecuteTest()                   { executeTest(  true,   false,  true    ); }
    private static testMethod void allowedUserChangeConfirmedExecuteTest()          { executeTest(  true,   true,   false   ); }
    private static testMethod void allowedUserChangeConfirmedHasOldExecuteTest()    { executeTest(  true,   true,   true    ); }

    // ---------------------------------------------------------------------------------------------------------------------------

    private static testMethod void OnBeforeInsertTest()             
    {   /*#CICTemplateTest*/
        Case dummyNewCase = createNewCase (ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME, ECICCommonConstants.STATUS_OPEN, false);
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = (new ECICCaseNoQualityStatusChangeStrategy()).onBeforeInsert(new List<Case> { dummyNewCase });
            }
            Test.stopTest();
        }
        
        System.assert (result);
        System.assert (!dummyNewCase.no_quality_status_change__c); 
        System.assert ((TEST_MockHelper.getMockString(dummyNewCase, 'error')) == null);
    }

    // ---------------------------------------------------------------------------------------------------------------------------

    private static testMethod void OnBeforeUpdateTest()             
    {   /*#CICTemplateTest*/
        Case dummyNewCase = createNewCase (ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME, ECICCommonConstants.STATUS_OPEN, false);
        Case dummyOldCase = createOldCase (dummyNewCase, false);
             dummyNewCase.id = dummyOldCase.id; 
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = (new ECICCaseNoQualityStatusChangeStrategy()).onBeforeUpdate(new Map<Id, Case>{ dummyOldCase.id => dummyOldCase }, new Map<Id, Case>{ dummyNewCase.id => dummyNewCase });
            }
            Test.stopTest();
        }
        
        System.assert (result);
        System.assert (!dummyNewCase.no_quality_status_change__c); 
        System.assert ((TEST_MockHelper.getMockString(dummyNewCase, 'error')) == null);
    }

    // ---------------------------------------------------------------------------------------------------------------------------

    private static Case createNewCase (String recordType, String status, Boolean noQualityStatusChange)
    {
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.recordTypeId            = TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(recordType);
                             config.status                  = status;
                             config.qualityStatus           = ECICCommonConstants.STATUS_OPEN;
                             config.noQualityStatusChange   = noQualityStatusChange;
        return TEST_DummyGenericCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE);
    }
    
    private static Case createOldCase (Case dummyNewCase, Boolean hasQualityStatusChange)
    {
        Case dummyOldCase = dummyNewCase.clone(false);
        if (hasQualityStatusChange) { dummyOldCase.Quality_Status__c = ECICCommonConstants.STATUS_ESCALATED; } 
        return dummyOldCase;
    }
}