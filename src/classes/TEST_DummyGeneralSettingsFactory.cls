@isTest
public class TEST_DummyGeneralSettingsFactory 
{
  	private static final User 	TEST_RUN_USER 		       = ECICRunUserTestHelper.create();
	
	public class Config
	{
		public String     supportEmail 	      = null;
		public Id         automatedCaseUserId = null;
		public Id         openAlertTemplateId = null;
		public Boolean skipTriggers		   = null;
		
		public Config() {}
	}
	
	public static General_Settings__c create (Config config, TEST_DummyInsertModeEnum insertMode)
	{
		General_Settings__c dummySettings = new General_Settings__c();
							dummySettings.supportEmail__c 			= TEST_ConfigHelper.chooseValue(config.supportEmail,   		  'cic.dev.notification@settings.example.com');
							dummySettings.automated_case_user_id__c = TEST_ConfigHelper.chooseValue(config.automatedCaseUserId,   (Id) UserInfo.getUserId());
                            dummySettings.open_alert_template_id__c = TEST_ConfigHelper.chooseValue(config.openAlertTemplateId,   (Id) null);
                            dummySettings.skipTriggers__c           = TEST_ConfigHelper.chooseValue(config.skipTriggers,          false);
		
        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  (        dummySettings );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  { System.runAs(TEST_RUN_USER) { insert dummySettings;  } }

        return dummySettings;
    }

    public static General_Settings__c create (TEST_DummyInsertModeEnum insertMode) { return create (new Config(), insertMode);                    }
    public static General_Settings__c create ()                                    { return create (new Config(), TEST_DummyInsertModeEnum.NONE); }
    
    // @depreciated : Use create (Config config, TEST_DummyInsertModeEnum insertMode)
    public static General_Settings__c create (Config config, Boolean insertNow)    { return create (config,       convert(insertNow));            }

    // @depreciated : Use create (TEST_DummyInsertModeEnum insertMode)
    public static General_Settings__c create (Boolean insertNow)                   { return create (new Config(), convert(insertNow));            }

    private static TEST_DummyInsertModeEnum convert (Boolean insertNow)
    {
        return (insertNow) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE;
    }
}