@isTest
private class ECICCaseProcessingStrategyAbstractTest 
{
    private class TestStrategy extends ECICCaseProcessingStrategyAbstract {}

    private static final User         TEST_RUN_USER   = ECICRunUserTestHelper.create(); 
    private static final TestStrategy TARGET_STRATEGY = new TestStrategy();

    private static void filterCasesByRecordTypesTest(Boolean isInSet)        
    { 
        Id   dummyRecordTypeId = TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get('Inquiry_Iberia');
        Case dummyCase         = (isInSet) ? TEST_DummyInquiryCaseFactory.create(TEST_DummyInsertModeEnum.NONE) : TEST_DummyJokeUselessCaseFactory.create(TEST_DummyInsertModeEnum.NONE); 
        
        List<Case> resultCaseList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCaseList = TARGET_STRATEGY.filterCasesByRecordTypes(new List<Case> { dummyCase }, new Set<Id>{ dummyRecordTypeId });          
            } 
            Test.stopTest();
        }
        
        System.assertEquals ((isInSet) ? 1 : 0, resultCaseList.size());
        if (isInSet) { System.assertEquals (dummyCase, resultCaseList[0]); }
    }

    private static testmethod void notInSetFilterCasesByRecordTypesTest() { filterCasesByRecordTypesTest (false); }  
    private static testmethod void inSetFilterCasesByRecordTypesTest()    { filterCasesByRecordTypesTest (true); }
    
    // ------------------------------------------------------------------------------------------------
    
    private static void filterQualityComplaintCasesTest(String recordTypeName)       
    { 
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.recordTypeId = TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(recordTypeName);  
        Case dummyCase = TEST_DummyGenericCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE); 
        
        List<Case> resultCaseList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCaseList = TARGET_STRATEGY.filterQualityComplaintCases(new List<Case> { dummyCase });         
            } 
            Test.stopTest();
        }
        /*#CICTemplateTest*/
        //Boolean isInSet = (new Set<String>{'Quality_Complaint' ,  'Simplified_Quality_Complaint'}).contains(recordTypeName);
        Boolean isInSet = (new Set<String>{ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME}).contains(recordTypeName);
        System.assertEquals ((isInSet) ? 1 : 0, resultCaseList.size());
        if (isInSet) { System.assertEquals (dummyCase, resultCaseList[0]); }
    }
    /*#CICTemplateTest - Start*/
    private static testmethod void inquiryFilterQualityComplaintCasesTest()                     { filterQualityComplaintCasesTest (ECICCommonConstants.INQUIRY_IBERIA_DEVNAME);                      }    
    private static testmethod void nonqualityComplaintFilterQualityComplaintCasesTest()         { filterQualityComplaintCasesTest (ECICCommonConstants.NON_QUALITY_COMPLAINT_IBERIA_DEVNAME);        }
    private static testmethod void qualityComplaintFilterQualityComplaintCasesTest()            { filterQualityComplaintCasesTest (ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME);            }
    //private static testmethod void simplifiedQualityComplaintFilterQualityComplaintCasesTest()  { filterQualityComplaintCasesTest ('Simplified_Quality_Complaint'); }
    /*#CICTemplateTest - End*/
    // ------------------------------------------------------------------------------------------------
    
    private static void filterAllComplaintCasesTest(String recordTypeName)           
    { 
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.recordTypeId = TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(recordTypeName);  
        Case dummyCase = TEST_DummyGenericCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE); 
        
        List<Case> resultCaseList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCaseList = TARGET_STRATEGY.filterAllComplaintCases(new List<Case> { dummyCase });
            } 
            Test.stopTest();
        }
        /*#CICTemplateTest*/
        //Boolean isInSet = (new Set<String>{'Quality_Complaint', 'Simplified_Quality_Complaint', 'Non_quality_Complaint'}).contains(recordTypeName);
        Boolean isInSet = (new Set<String>{ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME, ECICCommonConstants.NON_QUALITY_COMPLAINT_IBERIA_DEVNAME}).contains(recordTypeName);
        System.assertEquals ((isInSet) ? 1 : 0, resultCaseList.size());
        if (isInSet) { System.assertEquals (dummyCase, resultCaseList[0]); }
    }
    /*#CICTemplateTest - Start*/
    private static testmethod void inquiryFilterAllComplaintCasesTest()                     { filterAllComplaintCasesTest (ECICCommonConstants.INQUIRY_IBERIA_DEVNAME);                      }    
    private static testmethod void nonqualityComplaintFilterAllComplaintCasesTest()         { filterAllComplaintCasesTest (ECICCommonConstants.NON_QUALITY_COMPLAINT_IBERIA_DEVNAME);        }
    private static testmethod void qualityComplaintFilterAllComplaintCasesTest()            { filterAllComplaintCasesTest (ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME);            }
    //private static testmethod void simplifiedQualityComplaintFilterAllComplaintCasesTest()  { filterAllComplaintCasesTest ('Simplified_Quality_Complaint'); }
    /*#CICTemplateTest - End*/
    // ------------------------------------------------------------------------------------------------
    
    private static void filterNewCasesByStatusChangedToTest(Boolean isNewStatusTarget, Boolean wasOldStatusAlreadyTarget)
    {        
        String targetStatus = ECICCommonConstants.STATUS_OPEN;
        String otherStatus  = ECICCommonConstants.STATUS_CLOSED;
        
        TEST_DummyCaseConfig newConfig = new TEST_DummyCaseConfig();
                             newConfig.status = (isNewStatusTarget) ? targetStatus : otherStatus;
        Case dummyNewCase = TEST_DummyGenericCaseFactory.create(newConfig, TEST_DummyInsertModeEnum.MOCK); 

        Case dummyOldCase = dummyNewCase.clone(false);
             dummyOldCase.id = dummyNewCase.id;
             dummyOldCase.status = (wasOldStatusAlreadyTarget) ? targetStatus : otherStatus;
        
        Set<ID> resultCaseIdSet = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCaseIdSet = TARGET_STRATEGY.filterNewCasesByStatusChangedTo(targetStatus, new List<Case>{ dummyOldCase }, new Map<Id, Case>{ dummyNewCase.id => dummyNewCase });          
            } 
            Test.stopTest();
        }
        
        System.assertEquals ((isNewStatusTarget && !wasOldStatusAlreadyTarget), (resultCaseIdSet.contains(dummyNewCase.id)));
    }

    private static testmethod void neitherTargetFilterNewCasesByStatusChangedToTest() { filterNewCasesByStatusChangedToTest (false, false); }    
    private static testmethod void oldIsTargetFilterNewCasesByStatusChangedToTest()   { filterNewCasesByStatusChangedToTest (false, true ); }    
    private static testmethod void newIsTargetFilterNewCasesByStatusChangedToTest()   { filterNewCasesByStatusChangedToTest (true , false); }    
    private static testmethod void bothAreTargetFilterNewCasesByStatusChangedToTest() { filterNewCasesByStatusChangedToTest (true , true ); }    

    // ------------------------------------------------------------------------------------------------

    private static void checkNumberOfIncompleteTasksTest(Decimal numberOfUncompletedTasks)       
    { 
        Case dummyCase = TEST_DummyInquiryCaseFactory.create (TEST_DummyInsertModeEnum.MOCK);

        Map<ID, Case>    dummyCasesByIdMap                      = new Map<ID, Case>    { dummyCase.id => dummyCase                };
        Map<ID, Decimal> dummyNumberOfUncompletedTasksByCaseIds = new Map<ID, Decimal> { dummyCase.id => numberOfUncompletedTasks };  
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = TARGET_STRATEGY.checkNumberOfIncompleteTasks(dummyNumberOfUncompletedTasksByCaseIds, dummyCasesByIdMap);       
            }
            Test.stopTest();
        } 
        
        System.assertEquals((numberOfUncompletedTasks == 0), result);

        String errorMessage = TEST_MockHelper.getMockString(dummyCase, 'error');
        System.assertEquals ((numberOfUncompletedTasks != 0), ((errorMessage != null) && (errorMessage.contains(System.Label.Complete_all_tasks))));
    }
    
    private static testmethod void zeroCheckNumberOfIncompleteTasksTest() { checkNumberOfIncompleteTasksTest(0); }
    private static testmethod void oneCheckNumberOfIncompleteTasksTest()  { checkNumberOfIncompleteTasksTest(1); }
}