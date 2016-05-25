@isTest
public class TEST_DummyBeverageFactory 
{
	private static final Map<String, String> COUNTRY_BY_COUNTRY_CODE_MAP = new Map<String, String>
	{
		'AT' => 'Austria',
		'BG' => 'Bulgaria',
		'CH' => 'Switzerland',
		'CZ' => 'Czech Republic',
        'ES' => 'Spain',
        'FR' => 'France',
		'GR' => 'Greece',
		'HU' => 'Hungary',
		'IT' => 'Italy',
		'PL' => 'Poland',
		'PT' => 'Portugal',
		'RO' => 'Romania',
		'RS' => 'Serbia'
	};
	
    public class Config
    {
        public String   name                = null;
        public Boolean  isActive            = null;
        public String   brand               = null;
        public String   country             = null;
        public String   countryCode         = null;
        public Boolean  isCurrentlySold     = null;
        public String   flavour             = null;
        public String   flavourCode         = null;
        public String   beverageType        = null;
        public String   beverageTypeCode    = null;
        public String   productDescription  = null;
        
        public Config () {}
    }
    
    public static Beverage__c create (Config config, TEST_DummyInsertModeEnum insertMode)
    {
    	if ((config.countryCode != null) && (config.country == null)) { config.country = COUNTRY_BY_COUNTRY_CODE_MAP.get(config.countryCode); }

        TEST_UniqueHelper unique = new TEST_UniqueHelper('Dummy Beverage');
        
        Beverage__c dummyBeverage = new Beverage__c();
                    dummyBeverage.name                  = TEST_ConfigHelper.chooseValue(config.name,                unique.uniqueString + ' Name');
                    dummyBeverage.Brand__c              = TEST_ConfigHelper.chooseValue(config.brand,               ECICCommonConstants.BEVERAGE_BRAND_DEFAULT);
                    dummyBeverage.Country__c            = TEST_ConfigHelper.chooseValue(config.country,             ECICCommonConstants.TEST_COUNTRY);
                    dummyBeverage.Country_Code__c       = TEST_ConfigHelper.chooseValue(config.countryCode,         ECICCommonConstants.COUNTRY_CODE_SPAIN);
                    dummyBeverage.Flavour__c            = TEST_ConfigHelper.chooseValue(config.flavour,             ECICCommonConstants.BEVERAGE_FLAVOUR_DEFAULT);
                    dummyBeverage.Flavour_Code__c       = TEST_ConfigHelper.chooseValue(config.flavourCode,         ECICCommonConstants.BEVERAGE_FLAVOUR_CODE_DEFAULT);
                    dummyBeverage.Type__c               = TEST_ConfigHelper.chooseValue(config.beverageType,        ECICCommonConstants.BEVERAGE_TYPE_DEFAULT);
                    dummyBeverage.Type_Code__c          = TEST_ConfigHelper.chooseValue(config.beverageTypeCode,    ECICCommonConstants.BEVERAGE_TYPE_CODE_DEFAULT);
                    dummyBeverage.Product_Description__c= TEST_ConfigHelper.chooseValue(config.productDescription,  ECICCommonConstants.BEVERAGE_PRODUCT_DESCRIPTION_DEFAULT);
                    dummyBeverage.Currently_Sold__c     = TEST_ConfigHelper.chooseValue(config.isCurrentlySold,     true);
                    dummyBeverage.Active__c             = TEST_ConfigHelper.chooseValue(config.isActive,            true);
        
        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyBeverage );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyBeverage;    }
        
        return dummyBeverage;
    }
    
    public static Beverage__c create (TEST_DummyInsertModeEnum insertMode) { return create ( new Config(), insertMode );                        }
    public static Beverage__c create ()                                    { return create ( new Config(), TEST_DummyInsertModeEnum.NONE     ); }
    
}