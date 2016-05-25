@isTest
public class TEST_DummyProductionLineFactory
{
    public class Config
    {
        public String name             = null;
        public Id     plantId          = null;
        
        public Config(){}
        public Config(Id plantId) { this.plantId = plantId; }
    }
    
    public static Production_Line__c create (Config config, TEST_DummyInsertModeEnum insertMode)
    {
        Test_UniqueHelper unique = new Test_UniqueHelper('Production Line'); 

        Production_Line__c dummyProductLine = new Production_Line__c ();
                           dummyProductLine.Name       = TEST_ConfigHelper.chooseValue(config.name,             unique.uniqueSpaceless);
                           dummyProductLine.Plant__c   = TEST_ConfigHelper.chooseValue(config.plantId,          TEST_DummyPlantFactory.create(true).id);
        
        
        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyProductLine );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyProductLine;    }
    
        return dummyProductLine;
    }
    
    public static Production_Line__c create (TEST_DummyInsertModeEnum insertMode) { return create ( new Config(), insertMode );                        }
    public static Production_Line__c create ()                                    { return create ( new Config(), TEST_DummyInsertModeEnum.NONE     ); }

    public static Production_Line__c create (Id plantId, TEST_DummyInsertModeEnum insertMode)  { return create ( new Config(plantId), insertMode ); }
    
    //--------------------------------------------------------------------------------------------------

    // @depreciated : Use create (Config config, TEST_DummyInsertModeEnum insertMode)
    public static Production_Line__c create (Config config, Boolean insertNow)    { return create (config,              convert(insertNow));   }

    // @depreciated : Use create (TEST_DummyInsertModeEnum insertMode)
    public static Production_Line__c create (Boolean insertNow)                   { return create (new Config(),         convert(insertNow));  }

    // @depreciated : Use create (Id plantId, TEST_DummyInsertModeEnum insertMode)
    public static Production_Line__c create (Id plantId, Boolean insertNow)       { return create ( new Config(plantId), convert(insertNow));  }

    private static TEST_DummyInsertModeEnum convert (Boolean insertNow)
    {
        return (insertNow) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE;
    }
    
    

}