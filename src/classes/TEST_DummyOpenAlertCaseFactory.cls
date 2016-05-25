@isTest
public class TEST_DummyOpenAlertCaseFactory 
{
    public class Config
    {
            public String           name            = null;
            public Id               caseId          = null;
            public Id               openAlertId     = null;
            
            public Case             dummyCase       = null;
            public Open_Alert__c    dummyOpenAlert  = null;
            
            public Config(){}
            public Config(Id caseId, Id OpenAlertId){ this.caseId = caseId; this.OpenAlertId = OpenAlertId;}

            public Config(Case dummyCase, Open_Alert__c dummyOpenAlert)
            { 
            	this.dummyCase      = dummyCase;
            	this.caseId         = (dummyCase.id != null) ? dummyCase.id : TEST_ConfigHelper.INTENTIONAL_NULL; 

            	this.dummyOpenAlert = dummyOpenAlert;
                this.OpenAlertId    = (dummyOpenAlert.id != null) ? dummyOpenAlert.id : TEST_ConfigHelper.INTENTIONAL_NULL; 
            }

    }
    
    public static Open_Alert_Case__c create (Config config, TEST_DummyInsertModeEnum insertMode)
    {
        if (config.caseId == null)      { config.caseId      = TEST_DummyGenericCaseFactory.getDefaultCaseId(insertMode);    } 
        if (config.openAlertId == null) { config.openAlertId = TEST_DummyOpenAlertFactory.getDefaultOpenAlertId(insertMode); } 
    	
        TEST_UniqueHelper uniqueHelper = new TEST_UniqueHelper('Open Alert Case'); 
        
        Open_Alert_Case__c  dummyOpenAlertCase                  = new Open_Alert_Case__c();
                            dummyOpenAlertCase.Name             = TEST_ConfigHelper.chooseValue(config.name,                uniqueHelper.uniqueString);
                            dummyOpenAlertCase.Case__c          = config.caseId;
                            dummyOpenAlertCase.Open_Alert__c    = config.openAlertId;
                            
                            dummyOpenAlertCase.case__r            = (Case)          TEST_ConfigHelper.chooseValue((SObject) config.dummyCase,       null);
                            dummyOpenAlertCase.open_alert__r      = (Open_Alert__c) TEST_ConfigHelper.chooseValue((SObject) config.dummyOpenAlert,  null);
                            
        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyOpenAlertCase );    }
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyOpenAlertCase;      }
        
        return dummyOpenAlertCase;
    }

    public static Open_Alert_Case__c create (TEST_DummyInsertModeEnum insertMode) { return create ( new Config(), insertMode );                     }
    public static Open_Alert_Case__c create ()                                    { return create ( new Config(), TEST_DummyInsertModeEnum.NONE     ); }
    
    public static Open_Alert_Case__c create (Id caseId, Id OpenAlertId, TEST_DummyInsertModeEnum insertMode) { return create(new Config(caseId, OpenAlertId), insertMode); }

    public static Open_Alert_Case__c create (Case dummyCase, Open_Alert__c dummyOpenAlert, TEST_DummyInsertModeEnum insertMode) 
    { 
        Config config = new Config(dummyCase.id, dummyOpenAlert.id);
               config.dummyCase      = dummyCase;
               config.dummyOpenAlert = dummyOpenAlert;
        return create(config, insertMode); 
    }
    
    // --------------------------------------------------------------------------------------------------------------------------------------
    
    public static List<Open_Alert_Case__c> createList(Integer quantity, Config config, TEST_DummyInsertModeEnum insertMode)
    { 
        List<Open_Alert_Case__c> dummyOpenAlertCaseList = new List<Open_Alert_Case__c>();
        
        TEST_DummyInsertModeEnum itemInsertMode = (insertMode == TEST_DummyInsertModeEnum.REAL)
                                                    ? TEST_DummyInsertModeEnum.DML_LATER
                                                    : TEST_DummyInsertModeEnum.NONE;

        for (Integer i=1; i<=quantity; i++) { dummyOpenAlertCaseList.add(create (config, itemInsertMode)); }

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyOpenAlertCaseList );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyOpenAlertCaseList;    }
        return dummyOpenAlertCaseList; 
    }
    
    public static List<Open_Alert_Case__c> createList(Integer quantity, TEST_DummyInsertModeEnum insertMode)  { return createList(quantity, new Config(), insertMode);                        }
    public static List<Open_Alert_Case__c> createList(Integer quantity                                     )  { return createList(quantity, new Config(), TEST_DummyInsertModeEnum.NONE );    }
    
    // --------------------------------------------------------------------------------------------------------------------------------------
    
    // @deprecated : Use create (TEST_DummyInsertModeEnum insertMode)
    public static Open_Alert_Case__c createDummy(Boolean insertNow) { return create (new Config(), convert(insertNow)); }
    
    // @deprecated : Use create ()
    public static Open_Alert_Case__c createDummy()                  { return create(new Config(), convert(false));      }
    
    // @deprecated : Use createDummy(Id caseId, Id OpenAlertId, TEST_DummyInsertModeEnum insertMode)
    public static Open_Alert_Case__c createDummy(Id caseId, Id OpenAlertId, Boolean insertNow) { return create(caseId, OpenAlertId, convert(insertNow)); }
    
    // @deprecated : Use create (Case dummyCase, Open_Alert__c dummyOpenAlert, TEST_DummyInsertModeEnum insertMode)
    public static Open_Alert_Case__c createDummy(Case dummyCase, Open_Alert__c dummyOpenAlert, Boolean insertNow) { return create(dummyCase, dummyOpenAlert, convert(insertNow)); }
    
    private static TEST_DummyInsertModeEnum convert (Boolean insertNow)
    {
        return (insertNow) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE;
    }
}