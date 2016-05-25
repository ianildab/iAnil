@isTest
public class TEST_DummyCompetitorProductFactory 
{
    public class Config
    {
        public String name         = null;
        public Id     ownerId      = null;
        public Id     ownerUserId  = null;
        
        public Config(){}
    }
    
    public static Competitor_Product__c create (Config config, TEST_DummyInsertModeEnum insertMode)
    {
        Test_UniqueHelper unique = new Test_UniqueHelper('Competitor Product'); 

        Competitor_Product__c dummyCompetitorProduct = new Competitor_Product__c ();
                          dummyCompetitorProduct.Name               = TEST_ConfigHelper.chooseValue(config.name,             unique.uniqueSpaceless);
        
        if (config.ownerId == null) { config.ownerId             = config.ownerUserId;     } // If ownerId has no value, will overwrite with value from ownerUserId (which might still be blank).
        if (config.ownerId != null) { dummyCompetitorProduct.ownerId = config.ownerId;         } // Only give ownerId a value if it is not null; otherwise allow to default.
        
        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyCompetitorProduct );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyCompetitorProduct;    }
    
        return dummyCompetitorProduct;
    }
    
    public static Competitor_Product__c create (TEST_DummyInsertModeEnum insertMode) { return create ( new Config(), insertMode );                        }
    public static Competitor_Product__c create ()                                    { return create ( new Config(), TEST_DummyInsertModeEnum.NONE     ); }

}