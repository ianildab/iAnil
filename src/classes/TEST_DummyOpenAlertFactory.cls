@isTest
public class TEST_DummyOpenAlertFactory 
{
    public static Id defaultOpenAlertId = null;
    
    public class Config
    {
            public String  name         = null;
            public String  countryCode  = null;
            public String  countryCodeString  = null;
            public String  caseReason   = null;
            public String  categoryLevel3   = null;
            public String  categoryLevel4       = null;
            public String  recipients           = null;
            public String  additionalTo         = null;
            public String  processType          = null;
            public String  productionCode       = null;
            
            public Date    startDate        = null;
            public Date    bbeDate              = null;
            public Date    endDate          = null;
            
            public Id      ownerId              = null;
            public Id      ownerUserId          = null;
            public Id      plantId              = null;
            public Id      productId            = null;
            public Id      regionOfPurchaseId   = null;
            
            public Integer threshold            = null;
            
            public Boolean isActive             = true; // if FALSE, will assign value to endDate 
            
            public Config(){}
    }
    
    public static Open_Alert__c create (Config config, TEST_DummyInsertModeEnum insertMode)
    {
        if (!config.isActive) { config.endDate = System.today().addDays(-1); }
        
        TEST_UniqueHelper uniqueHelper = new TEST_UniqueHelper('Open Alert'); 
        
        Open_Alert__c dummyOpenAlert = new Open_Alert__c();
                      dummyOpenAlert.Name             = TEST_ConfigHelper.chooseValue(config.name,          uniqueHelper.uniqueString);
                      dummyOpenAlert.case_reason__c   = TEST_ConfigHelper.chooseValue(config.caseReason,    'Product Quality');
                      dummyOpenAlert.country_code__c  = TEST_ConfigHelper.chooseValue(config.countryCode,   ECICCommonConstants.COUNTRY_CODE_SPAIN);
                      dummyOpenAlert.country_code_string__c  = TEST_ConfigHelper.chooseValue(config.countryCodeString,  ECICCommonConstants.COUNTRY_CODE_SPAIN);
                      dummyOpenAlert.Category_Level3__c      = TEST_ConfigHelper.chooseValue(config.categoryLevel3,     null);
                      dummyOpenAlert.Category_Level4__c      = TEST_ConfigHelper.chooseValue(config.categoryLevel4,     null);
                      dummyOpenAlert.Recipients__c           = TEST_ConfigHelper.chooseValue(config.recipients,         null);
                      dummyOpenAlert.Additional_To__c        = TEST_ConfigHelper.chooseValue(config.additionalTo,       null);
                      dummyOpenAlert.Process_Type__c         = TEST_ConfigHelper.chooseValue(config.processType,        null);
                      dummyOpenAlert.Production_Code__c      = TEST_ConfigHelper.chooseValue(config.productionCode,     null);
                      dummyOpenAlert.Start_Date__c      = TEST_ConfigHelper.chooseValue(config.startDate,       null);
                      dummyOpenAlert.BBE_Date__c             = TEST_ConfigHelper.chooseValue(config.bbeDate,            null);
                      dummyOpenAlert.End_Date__c        = TEST_ConfigHelper.chooseValue(config.endDate,         null);
                      dummyOpenAlert.threshold__c            = TEST_ConfigHelper.chooseValue(config.threshold,          null); 
                      dummyOpenAlert.Plant__c                = TEST_ConfigHelper.chooseValue(config.plantId,            (Id) null);
                      dummyOpenAlert.Product__c              = TEST_ConfigHelper.chooseValue(config.productId,          (Id) null);
                      dummyOpenAlert.Region_of_Purchase__c   = TEST_ConfigHelper.chooseValue(config.regionOfPurchaseId, (Id) null);

                      if (config.ownerId == null) { config.ownerId = config.ownerUserId;     } // If ownerId has no value, will overwrite with value from ownerUserId (which might still be blank).
                      if (config.ownerId != null) { dummyOpenAlert.ownerId = config.ownerId; } // Only give ownerId a value if it is not null; otherwise allow to default.

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyOpenAlert );    } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyOpenAlert;    }

                 return dummyOpenAlert;
    }

    public static Open_Alert__c create (TEST_DummyInsertModeEnum insertMode) { return create ( new Config(), insertMode );                     }
    public static Open_Alert__c create ()                                    { return create ( new Config(), TEST_DummyInsertModeEnum.NONE     ); }
    
    // --------------------------------------------------------------------------------------------------------------------------------------
    
    public static List<Open_Alert__c> createList(List<Config> configList, TEST_DummyInsertModeEnum insertMode)
    { 
        List<Open_Alert__c> dummyOpenAlertList = new List<Open_Alert__c>();
        for (Config config : configList) { dummyOpenAlertList.add(create (config, TEST_DummyInsertModeEnum.NONE)); }

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyOpenAlertList );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyOpenAlertList;    }
        return dummyOpenAlertList; 
    }
    
    public static List<Open_Alert__c> createList(Integer quantity, Config config, TEST_DummyInsertModeEnum insertMode)
    { 
        List<Config> configList = new List<Config>();
        for (Integer i=1; i<=quantity; i++) { configList.add(config); }
        return createList (configList, insertMode);
    }
    
    public static List<Open_Alert__c> createList(Integer quantity, TEST_DummyInsertModeEnum insertMode)  { return createList(quantity, new Config(), insertMode);                        }
    public static List<Open_Alert__c> createList(Integer quantity                                     )  { return createList(quantity, new Config(), TEST_DummyInsertModeEnum.NONE );    }

    //--------------------------------------------------------------------------------------------------

    // @depreciated : Use create (Config config, TEST_DummyInsertModeEnum insertMode)
    public static Open_Alert__c createDummy (Config config, Boolean insertNow)    { return create (config,     convert(insertNow));            }

    // @depreciated : Use create (TEST_DummyInsertModeEnum insertMode)
    public static Open_Alert__c createDummy (Boolean insertNow)                   { return create (new Config(), convert(insertNow));            }

    // @depreciated : Use createList(Integer quantity, Config config, TEST_DummyInsertModeEnum insertMode)
    public static List<Open_Alert__c> createDummyList(Integer quantity, Config config, Boolean insertNow) { return createList (quantity, config, convert(insertNow)); }

    // @depreciated : Use createList(Integer quantity, TEST_DummyInsertModeEnum insertMode)
    public static List<Open_Alert__c> createDummyList(Integer quantity, Boolean insertNow)                { return createList(quantity, new Config(), convert(insertNow)); }

    // @depreciated : Use createList(Integer quantity)
    public static List<Open_Alert__c> createDummyList(Integer quantity                   )                { return createList(quantity, new Config(), TEST_DummyInsertModeEnum.NONE);    }

    private static TEST_DummyInsertModeEnum convert (Boolean insertNow)
    {
        return (insertNow) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE;
    }

    // --------------------------------------------------------------------------------------------------------------------------------------

    public static Id getDefaultOpenAlertId (TEST_DummyInsertModeEnum insertMode)
    {
        if      (defaultOpenAlertId != null)                  { return defaultOpenAlertId; }
        else if (!((new Set<TEST_DummyInsertModeEnum>{ TEST_DummyInsertModeEnum.REAL, TEST_DummyInsertModeEnum.DML_LATER})).contains(insertMode))
        {
            return 'a0D110000003C4X';
        }

        Open_Alert__c dummyOpenAlert = TEST_DummyOpenAlertFactory.create(TEST_DummyInsertModeEnum.REAL);
                      defaultOpenAlertId = dummyOpenAlert.id;
              return  defaultOpenAlertId;
    }


}