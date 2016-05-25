@isTest
public class TEST_DummyPlantFactory  
{ 
    private static Id defaultPlantId = null;
	
    public class Config
    {
        public String name              = null;
        public Id     bottlerAccountId  = null;
        public Id     regionId          = null; 
        
        public Config(){}
        
        public Config(Id accountId, Id regionId)
        {
        	this.bottlerAccountId = accountId;
        	this.regionId 		  = regionId;
        }
    }
    
    public static Plant__c create (Config config, TEST_DummyInsertModeEnum insertMode)
    { 
        Test_UniqueHelper unique = new Test_UniqueHelper('Plant');
        
		if (config.regionId == null)         { config.regionId         = TEST_DummyRegionFactory.getDefaultBottlerRegionId(insertMode);   }
        if (config.bottlerAccountId == null) { config.bottlerAccountId = TEST_DummyAccountFactory.getDefaultBottlerAccountId(insertMode); } 
        
        Plant__c dummyPlant = new Plant__c();
                 dummyPlant.Name        = TEST_ConfigHelper.chooseValue(config.name,             unique.uniqueSpaceless);
                 dummyPlant.Region__c   = config.regionId; 
                 dummyPlant.Bottler__c  = config.bottlerAccountId; 
         
        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyPlant );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyPlant;    }

        return dummyPlant;
    }
    
    public static Plant__c create (TEST_DummyInsertModeEnum insertMode) { return create ( new Config(), insertMode );                        }
    public static Plant__c create ()                                    { return create ( new Config(), TEST_DummyInsertModeEnum.NONE     ); }

    public static Plant__c create (Id accountId, Id regionId, TEST_DummyInsertModeEnum insertMode) { return create ( new Config(accountId, regionId), insertMode ); }

    //--------------------------------------------------------------------------------------------------

    // @depreciated : Use create (Config config, TEST_DummyInsertModeEnum insertMode)
    public static Plant__c create (Config config, Boolean insertNow)             { return create (config,     convert(insertNow));            }

    // @depreciated : Use create (TEST_DummyInsertModeEnum insertMode)
    public static Plant__c create (Boolean insertNow)                            { return create (new Config(), convert(insertNow));          }

    // @depreciated : Use create (Id accountId, Id regionId, TEST_DummyInsertModeEnum insertMode)
    public static Plant__c create (Id accountId, Id regionId, Boolean insertNow) { return create ( accountId, regionId, convert(insertNow));  }


    private static TEST_DummyInsertModeEnum convert (Boolean insertNow)
    {
        return (insertNow) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE;
    }

    // --------------------------------------------------------------------------------------------------------------------------------------
    
	public static Id getDefaultPlantId(TEST_DummyInsertModeEnum insertMode)
	{
		if (defaultPlantId != null) { return defaultPlantId; }
		if (!TEST_DummyInsertModeEnumHelper.isRealRequired(insertMode)) { return 'a0G110000000atg'; }
		
		Plant__c  dummyPlant     = create(TEST_DummyInsertModeEnum.REAL);
		          defaultPlantId = dummyPlant.id;
		
		return defaultPlantId;
	}    
}