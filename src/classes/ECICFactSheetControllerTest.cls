@isTest
private class ECICFactSheetControllerTest
{
    private static final User TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();
    private static final User DUMMY_AUTHOR  = [SELECT id, name FROM User WHERE id = :TEST_RUN_USER.id];

    private static testMethod void setParentCaseTest() 
    {
    	Case dummyCase = TEST_DummyInquiryCaseFactory.create(TEST_DummyInsertModeEnum.NONE);
    	
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICFactSheetController.setParentCase(dummyCase);
            }
            Test.stopTest();
        } 
        
        System.assertEquals (dummyCase, ECICFactSheetController.parentCase);
    }

    // -------------------------------------------------------------------------------------------

    private static void getQualityCommentsTest() 
    {
        String dummyKey    = 'key';
        String dummyComment = 'dummy';
        ECICFactSheetController.qualityCommentsMap.put (dummyKey, dummyComment);
        
        Map<String, String> resultCommentsMap = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCommentsMap = ECICFactSheetController.getQualityComments();
            }
            Test.stopTest();
        } 
        
        System.assert(resultCommentsMap.containsKey(dummyKey));
        System.assertEquals (dummyComment, resultCommentsMap.get(dummyKey));
    }

    // -------------------------------------------------------------------------------------------
    
    private static testMethod void getCaseCommentsTest() 
    {
    	String dummyKey    = 'key';
    	String dummyComment = 'dummy';
    	ECICFactSheetController.caseCommentsMap.put (dummyKey, dummyComment);
    	
    	Map<String, String> resultCommentsMap = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCommentsMap = ECICFactSheetController.getCaseComments();
            }
            Test.stopTest();
        } 
        
        System.assert(resultCommentsMap.containsKey(dummyKey));
        System.assertEquals (dummyComment, resultCommentsMap.get(dummyKey));
    }

    // -------------------------------------------------------------------------------------------
    
    private static testMethod void createCommentAuthorKeyListTest() 
    {
    	TEST_DummyCaseCommentFactory.Config config = new TEST_DummyCaseCommentFactory.Config();
                                            config.createdByUserId = DUMMY_AUTHOR.id;
    	                                    config.commentBody     = 'Dummy Comment';
                                            config.createdDate     = System.today().addDays(-1);
        CaseComment dummyCaseComment = TEST_DummyCaseCommentFactory.create (config, TEST_DummyInsertModeEnum.REAL);
        CaseComment insertedCaseComment = [SELECT createdBy.name, commentBody, createdDate FROM CaseComment WHERE id = :dummyCaseComment.id];
        
        List<SObject>       dummySObjectCommentList = new List<SObject>{  insertedCaseComment };
        Map<String, String> dummyCommentMap         = new Map<String, String>(); 
        String              dummyBodyFieldName      = 'commentBody';
        
        List<String> resultCommentAuthorKeyList = null;
        System.runAs(TEST_RUN_USER) 
        {
            Test.startTest();
    {
                resultCommentAuthorKeyList = ECICFactSheetController.createCommentAuthorKeyList(dummySObjectCommentList, dummyCommentMap, dummyBodyFieldName);
            }
            Test.stopTest();
        }
        
        String expectedResultKey =  getExpectedResultKey(config.createdDate, DUMMY_AUTHOR.name);
        assertCommentList (resultCommentAuthorKeyList, expectedResultKey);
        assertCommentMap  (dummyCommentMap, expectedResultKey, config.commentBody);
    }

    // -------------------------------------------------------------------------------------------
    
    private static testMethod void getcaseCommentsAuthorsTest() 
    {
        Case dummyCase   = TEST_DummyInquiryCaseFactory.create(TEST_DummyInsertModeEnum.REAL);
        
        TEST_DummyCaseCommentFactory.Config config = new TEST_DummyCaseCommentFactory.Config();
                                            config.parentCaseId    = dummyCase.id;
                                            config.createdByUserId = DUMMY_AUTHOR.id;
                                            config.commentBody     = 'Dummy Comment';
                                            config.createdDate     = System.today().addDays(-1);
        CaseComment dummyCaseComment = TEST_DummyCaseCommentFactory.create (config, TEST_DummyInsertModeEnum.REAL);
        
        ECICFactSheetController.parentCase = dummyCase;
        List<String> resultCommentAuthorKeyList = null;
        System.runAs(TEST_RUN_USER) 
        {
            Test.startTest();
            {
                resultCommentAuthorKeyList = ECICFactSheetController.getcaseCommentsAuthors();
            }
            Test.stopTest();
        }
        
        String expectedResultKey =  getExpectedResultKey(config.createdDate, DUMMY_AUTHOR.name);
        assertCommentList (resultCommentAuthorKeyList, expectedResultKey);
        assertCommentMap  (ECICFactSheetController.caseCommentsMap, expectedResultKey, config.commentBody);
    }

    // -------------------------------------------------------------------------------------------
    
    private static testMethod void getqualityAuthorsTest() 
    {
        Case dummyCase   = TEST_DummyInquiryCaseFactory.create(TEST_DummyInsertModeEnum.REAL);
        
        TEST_DummyQualityCommentFactory.Config  config = new TEST_DummyQualityCommentFactory.Config();
	                                            config.parentCaseId    = dummyCase.id;
	                                            config.createdByUserId = DUMMY_AUTHOR.id;
	                                            config.commentBody     = 'Dummy Comment';
	                                            config.createdDate     = System.today().addDays(-1);
        Quality_Comment__c dummyCaseComment = TEST_DummyQualityCommentFactory.create (config, TEST_DummyInsertModeEnum.REAL);
        
        ECICFactSheetController.parentCase = dummyCase;
        List<String> resultCommentAuthorKeyList = null;
        System.runAs(TEST_RUN_USER) 
        {
            Test.startTest();
            {
                resultCommentAuthorKeyList = ECICFactSheetController.getqualityAuthors();
            }
            Test.stopTest();
        }
        
        String expectedResultKey =  getExpectedResultKey(config.createdDate, DUMMY_AUTHOR.name);
        assertCommentList (resultCommentAuthorKeyList, expectedResultKey);
        assertCommentMap  (ECICFactSheetController.qualityCommentsMap, expectedResultKey, config.commentBody);
    }

    // -----------------------------------------------------------------------------------------------
    
    private static String getExpectedResultKey(Date createdDate, String authorName)
    {
        return ((Datetime) createdDate).format('yyyy-MM-dd HH:mm:ss z')  + ' ' + authorName;
    }

    private static void assertCommentList (List<String> resultCommentAuthorKeyList, String expectedResultKey)
    {
        System.assertEquals (1,                 resultCommentAuthorKeyList.size());
        System.assertEquals (expectedResultKey, resultCommentAuthorKeyList[0]);
    }
    
    private static void assertCommentMap(Map<String, String> resultCommentMap, String expectedResultKey, String expectedCommentBody)
    {
        System.assert       (resultCommentMap.containsKey(expectedResultKey));
        System.assertEquals (expectedCommentBody, resultCommentMap.get(expectedResultKey));
    }
        
 }