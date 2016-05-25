@isTest
public class TEST_DummyOpenAlertCaseUpdateHoldrFactry 
{
    private static final User TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();

    public class Config
    {
            public String           openAlertCaseName       = null;
            public String           type                    = null;
            public Id               openAlertCaseId         = null;
            public Id               caseId                  = null;
            public Id               openAlertId             = null;
            public Boolean          requiresEmail           = null;
            
            public Config(){}
            public Config(Id caseId, Id OpenAlertId){ this.caseId = caseId; this.OpenAlertId = OpenAlertId;}
    }
    
    public static Open_Alert_Case_Update_Holder__c create (Config config, TEST_DummyInsertModeEnum insertMode)
    {
        if (config.caseId == null)      { config.caseId      = TEST_DummyGenericCaseFactory.getDefaultCaseId(insertMode);    } 
        if (config.openAlertId == null) { config.openAlertId = TEST_DummyOpenAlertFactory.getDefaultOpenAlertId(insertMode); } 
        
        TEST_UniqueHelper uniqueHelper = new TEST_UniqueHelper('Open Alert Case Update Holder'); 
        
        Open_Alert_Case_Update_Holder__c  dummyHolder = new Open_Alert_Case_Update_Holder__c();
  			                              dummyHolder.open_alert_case_name__c   = TEST_ConfigHelper.chooseValue(config.openAlertCaseName,    null);
			                              dummyHolder.type__c                   = TEST_ConfigHelper.chooseValue(config.type,                 null);
			                              dummyHolder.open_alert_case__c        = TEST_ConfigHelper.chooseValue(config.openAlertCaseId,      (id) null);
			                              dummyHolder.case__c                   = TEST_ConfigHelper.chooseValue(config.caseId,               (id) null);
			                              dummyHolder.open_alert__c             = TEST_ConfigHelper.chooseValue(config.openAlertId,          (id) null);
			                              dummyHolder.requires_email__c         = TEST_ConfigHelper.chooseValue(config.requiresEmail,        false);
                            
        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyHolder );    }
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyHolder;      }
        
        return dummyHolder;
    }

    public static Open_Alert_Case_Update_Holder__c create (TEST_DummyInsertModeEnum insertMode) { return create ( new Config(), insertMode );                     }
    public static Open_Alert_Case_Update_Holder__c create ()                                    { return create ( new Config(), TEST_DummyInsertModeEnum.NONE     ); }
    
    public static Open_Alert_Case_Update_Holder__c create (Id caseId, Id OpenAlertId, TEST_DummyInsertModeEnum insertMode) { return create(new Config(caseId, OpenAlertId), insertMode); }

    // --------------------------------------------------------------------------------------------------------------------------------------
    
    public static List<Open_Alert_Case_Update_Holder__c> createList(Integer quantity, Config config, TEST_DummyInsertModeEnum insertMode)
    { 
        List<Open_Alert_Case_Update_Holder__c> dummyHolderList = new List<Open_Alert_Case_Update_Holder__c>();
        for (Integer i=1; i<=quantity; i++) { dummyHolderList.add(create (config, TEST_DummyInsertModeEnum.NONE)); }

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyHolderList );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyHolderList;    }
        return dummyHolderList; 
    }
    
    public static List<Open_Alert_Case_Update_Holder__c> createList(Integer quantity, TEST_DummyInsertModeEnum insertMode)  { return createList(quantity, new Config(), insertMode);                        }
    public static List<Open_Alert_Case_Update_Holder__c> createList(Integer quantity                                     )  { return createList(quantity, new Config(), TEST_DummyInsertModeEnum.NONE );    }
}