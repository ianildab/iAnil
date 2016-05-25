@isTest
public class TEST_DummyPromotionFactory 
{
    public class Config
    {
        public String name         = null;
        public String countryCode  = null;
        public Id     ownerId      = null;
        public Id     ownerUserId  = null;
        
        public Config(){}
    }
    
    public static Promotion__c create (Config config, TEST_DummyInsertModeEnum insertMode)
    {
        Test_UniqueHelper unique = new Test_UniqueHelper('Promotion'); 

        Promotion__c dummyPromotion = new Promotion__c ();
                          dummyPromotion.Name               = TEST_ConfigHelper.chooseValue(config.name,             unique.uniqueSpaceless);
                          dummyPromotion.Country_Code__c    = TEST_ConfigHelper.chooseValue(config.countryCode,      null);
        
        if (config.ownerId == null) { config.ownerId         = config.ownerUserId;     } // If ownerId has no value, will overwrite with value from ownerUserId (which might still be blank).
        if (config.ownerId != null) { dummyPromotion.ownerId = config.ownerId;         } // Only give ownerId a value if it is not null; otherwise allow to default.
        
        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyPromotion );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyPromotion;    }
    
        return dummyPromotion;
    }
    
    public static Promotion__c create (TEST_DummyInsertModeEnum insertMode) { return create ( new Config(), insertMode );                        }
    public static Promotion__c create ()                                    { return create ( new Config(), TEST_DummyInsertModeEnum.NONE     ); }

}