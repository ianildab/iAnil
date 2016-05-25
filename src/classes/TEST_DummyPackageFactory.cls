@isTest
public class TEST_DummyPackageFactory {
    public class Config
    {
        public String   name                    = null;
        public Boolean  isActive                = null;
        public String   country                 = null;
        public String   countryCode             = null;
        public String   packaging               = null;
        public String   size                    = null;
        
        public Config () {}
    }
    
    public static Package__c create (Config config, TEST_DummyInsertModeEnum insertMode)
    {
        TEST_UniqueHelper unique = new TEST_UniqueHelper('Dummy Package');
        
        Package__c  dummyPackage = new Package__c();
                    dummyPackage.name                       = TEST_ConfigHelper.chooseValue(config.name,                    unique.uniqueString + ' Name');
                    dummyPackage.Country__c                 = TEST_ConfigHelper.chooseValue(config.country,                 ECICCommonConstants.TEST_COUNTRY);
                    dummyPackage.Country_Code__c            = TEST_ConfigHelper.chooseValue(config.countryCode,             ECICCommonConstants.COUNTRY_CODE_SPAIN);
                    dummyPackage.Packaging__c               = TEST_ConfigHelper.chooseValue(config.packaging,               ECICCommonConstants.PRODUCT_PACKAGING_DEFAULT);
                    dummyPackage.Size__c                    = TEST_ConfigHelper.chooseValue(config.size,                    ECICCommonConstants.PRODUCT_SIZE_DEFAULT);
                    dummyPackage.Active__c                  = TEST_ConfigHelper.chooseValue(config.isActive,                true);
        
        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyPackage );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyPackage;    }
        
        return dummyPackage;
    }
    
    public static Package__c create (TEST_DummyInsertModeEnum insertMode) { return create ( new Config(), insertMode );                        }
    public static Package__c create ()                                    { return create ( new Config(), TEST_DummyInsertModeEnum.NONE     ); }
    
}