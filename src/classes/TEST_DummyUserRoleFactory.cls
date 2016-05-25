@isTest
public class TEST_DummyUserRoleFactory 
{
    public class Config
    {
        public String name         = null;
        public String devName      = null;
        
        public Config(){}
    }
    
    public static UserRole create (Config config, TEST_DummyInsertModeEnum insertMode)
    {
        Test_UniqueHelper unique = new Test_UniqueHelper('User Role'); 

        UserRole dummyUserRole = new UserRole ();
                          dummyUserRole.Name               = TEST_ConfigHelper.chooseValue(config.name,                unique.uniqueString);
                          dummyUserRole.DeveloperName      = TEST_ConfigHelper.chooseValue(config.devName,             unique.uniqueSpaceless);
        
        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyUserRole );                                               } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  { System.runAs(ECICRunUserTestHelper.SETUP_DATA_CREATION_USER) { insert    dummyUserRole;    } }
    
        return dummyUserRole;
    }
    
    public static UserRole create (TEST_DummyInsertModeEnum insertMode) { return create ( new Config(), insertMode );                        }
    public static UserRole create ()                                    { return create ( new Config(), TEST_DummyInsertModeEnum.NONE     ); }

}