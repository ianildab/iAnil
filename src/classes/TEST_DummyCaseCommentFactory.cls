@isTest 
public class TEST_DummyCaseCommentFactory 
{
    private static final User TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();

    private static Id defaultParentCase = null;
    
    public class Config
    {
        public Id     parentCaseId    = null;
        public Id     createdByUserId = null;
        public String commentBody     = null;
        public Date   createdDate     = null;
        
        public Config() {}  
    }
    
    public static CaseComment create (Config config, TEST_DummyInsertModeEnum insertMode)
    {
        // If config values for templateId and/or whatId don't have values, try getting values from their aliases.
            if (config.parentCaseId == null)   { config.parentCaseId    = getParentCaseId(insertMode);   }
    
        TEST_UniqueHelper unique = new TEST_UniqueHelper('Dummy Comment');
        
        CaseComment dummyComment = new CaseComment();
                    dummyComment.ParentId       = config.parentCaseId;
                    dummyComment.createdById    = TEST_ConfigHelper.chooseValue(config.createdByUserId,    (Id) TEST_RUN_USER.id);
                    dummyComment.commentBody    = TEST_ConfigHelper.chooseValue(config.commentBody,        unique.uniqueString + ' comment body');
                    dummyComment.createdDate    = TEST_ConfigHelper.chooseValue(config.createdDate,        System.today());

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  (        dummyComment );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  { System.runAs(TEST_RUN_USER) { insert dummyComment;  } }

                         return dummyComment;
    }
    
    public static CaseComment create (TEST_DummyInsertModeEnum insertMode) { return create (new Config(), insertMode);                    }
    public static CaseComment create ()                                    { return create (new Config(), TEST_DummyInsertModeEnum.NONE); }
    
    // ----------------------------------------------------------------------------------------------------------
    
    private static Id getParentCaseId (TEST_DummyInsertModeEnum insertMode)
    {
    	if      (defaultParentCase != null)                    { return defaultParentCase; }
    	else if (insertMode != TEST_DummyInsertModeEnum.REAL ) { return '50011000001FTZs'; }
    	
    	Case dummyCase = TEST_DummyInquiryCaseFactory.create (TEST_DummyInsertModeEnum.REAL);
    	defaultParentCase = dummyCase.id;
    	return defaultParentCase;
    }

}