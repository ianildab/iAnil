@isTest 
public class TEST_DummyEmailTemplateFactory 
{
    private static final User SETUP_DATA_CREATION_USER = TEST_DummyUserFactory.create();
    
    private static Id dummyFolderId = null;
    
    public class Config
    {
        public String   name            = null;
        public String   developerName   = null;
        public String   subject         = null;
        public String   body            = null;
        public String   templateType    = null;
        public String   templateStyle   = null;
        public Id       folderId        = null;
        public Boolean  isActive        = null;
        
        public Config() {}  
    }
    
    public static EmailTemplate create (Config config, TEST_DummyInsertModeEnum insertMode)
    {
    	if (config.folderId == null) { config.folderId = getFolderId(insertMode); }
    	
        TEST_UniqueHelper unique = new TEST_UniqueHelper('Dummy Email Template');
        
        EmailTemplate dummyEmailTemplate = new EmailTemplate();
                      dummyEmailTemplate.name          = TEST_ConfigHelper.chooseValue(config.name,             unique.uniqueString); 
                      dummyEmailTemplate.developerName = TEST_ConfigHelper.chooseValue(config.developerName,    unique.uniqueSpaceless); 
                      dummyEmailTemplate.subject       = TEST_ConfigHelper.chooseValue(config.subject,          unique.uniqueString + ' Subject'); 
                      dummyEmailTemplate.body          = TEST_ConfigHelper.chooseValue(config.body,             unique.uniqueString + ' Body'); 
                      dummyEmailTemplate.templateType  = TEST_ConfigHelper.chooseValue(config.templateType,     'text'); 
                      dummyEmailTemplate.templateStyle = TEST_ConfigHelper.chooseValue(config.templateStyle,    'none'); 
                      dummyEmailTemplate.isActive      = TEST_ConfigHelper.chooseValue(config.isActive,    true); 
                      dummyEmailTemplate.folderId      = config.folderId; 

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  (        dummyEmailTemplate );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  { System.runAs(SETUP_DATA_CREATION_USER) { insert dummyEmailTemplate;  } }

        return dummyEmailTemplate;
    }
    
    public static EmailTemplate create (TEST_DummyInsertModeEnum insertMode) { return create (new Config(), insertMode);                    }
    public static EmailTemplate create ()                                    { return create (new Config(), TEST_DummyInsertModeEnum.NONE); }
   
    // --------------------------------------------------------------------------------------------------------------------------------
    
    private static Id getFolderId(TEST_DummyInsertModeEnum insertMode)
    {
    	if (dummyFolderId != null) { return dummyFolderId; }
    	else if (insertMode    != TEST_DummyInsertModeEnum.REAL) { return '00l20000001RZYM'; }
    	
    	// NOTE: SFDC does not allow DML on folder, so we can't create a dummy. :-(
    	Folder selectedFolder = [ SELECT id  FROM Folder  WHERE  (type       = 'Email' ) AND (accessType = 'Public') LIMIT 1 ];   
    	       dummyFolderId = selectedFolder.id;
    	return dummyFolderId;
    }
}