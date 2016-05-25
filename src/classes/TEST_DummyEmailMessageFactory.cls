@isTest
public class TEST_DummyEmailMessageFactory 
{
    public class Config
    {
        public  Boolean incoming        = null;
        public  Id      parentId        = null;
        public  String  fromAddress     = null;
        public  String  subject         = null;
        public  String  description     = null;
        public  Date    messageDate     = null;
        public  String  status          = null;
        
        public Config() {}
    }
    
    public static EmailMessage create (Config config, TEST_DummyInsertModeEnum insertMode)
    {
        TEST_UniqueHelper unique = new TEST_UniqueHelper('Dummy Email Message');
        
        EmailMessage    dummyEmailMessage = new EmailMessage();
                        dummyEmailMessage.Incoming      = TEST_ConfigHelper.chooseValue(config.incoming,    true);
                        dummyEmailMessage.parentId      = TEST_ConfigHelper.chooseValue(config.parentId,    (Id) null);
                        dummyEmailMessage.FromAddress   = TEST_ConfigHelper.chooseValue(config.fromAddress, unique.uniqueSpaceless+'@emailmessage.example.com');
                        dummyEmailMessage.Subject       = TEST_ConfigHelper.chooseValue(config.subject,     unique.uniqueString+' Subject');
                        dummyEmailMessage.TextBody      = TEST_ConfigHelper.chooseValue(config.description, unique.uniqueString+' Description');
                        dummyEmailMessage.MessageDate   = TEST_ConfigHelper.chooseValue(config.messageDate, System.now());
                        dummyEmailMessage.Status        = TEST_ConfigHelper.chooseValue(config.status,      '0');           // default sets status = 'New'
        
        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyEmailMessage );  }
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyEmailMessage;    }
        
        return dummyEmailMessage;
    }
    
    public static EmailMessage create ()                                    { return create (new Config(), TEST_DummyInsertModeEnum.NONE);      }
    public static EmailMessage create (TEST_DummyInsertModeEnum insertMode) { return create (new Config(), insertMode );                        }
    
    // -----------------------------------------------------------------------------------------------------------------
    
    // @depreciated : Use create (Config config, TEST_DummyInsertModeEnum insertMode)
    public static EmailMessage create (Config config, Boolean insertNow)    { return create (config, convert(insertNow)); }
    
    // @depreciated : Use create (TEST_DummyInsertModeEnum insertMode)
    public static EmailMessage create (Boolean insertNow)                   { return create (new Config(), convert(insertNow));  }
    
    private static TEST_DummyInsertModeEnum convert (Boolean insertNow){
        return (insertNow) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE;
    }
	
}