@isTest
public class TEST_DummyProductFactory 
{
    private static Id defaultProductId = null;
	
    public class Config
    {
        public String   name                    = null;
        public String   flavour                 = null;
        public String   flavourCode             = null;
        public String   packaging               = null;
        public Integer  shelfLife               = null;
        public String   size                    = null;
        public String   type                    = null;
        public String   unit                    = null;
        public Decimal  unitPrice               = null;
        public String   primaryContainer        = null;
        public String   primaryContainerCode    = null;
        public String   productDescription      = null;
        public String   packageType             = null;
        public String   country                 = null;
        public String   countryCode             = null;
        public Boolean  isActive                = null;
        public Boolean  isCurrentlySold         = null;
        
        public Config () {}
    }
    
    
    public static Product__c create (Config config, TEST_DummyInsertModeEnum insertMode)
    {
        TEST_UniqueHelper unique = new TEST_UniqueHelper('Dummy Product Name');
        
        Product__c dummyProduct = new Product__c();
                   dummyProduct.name                        = TEST_ConfigHelper.chooseValue(config.name,                    ECICCommonConstants.PRODUCT_NAME_DEFAULT);
                   dummyProduct.Flavour__c                  = TEST_ConfigHelper.chooseValue(config.flavour,                 ECICCommonConstants.PRODUCT_FLAVOUR_DEFAULT);
                   dummyProduct.Flavour_Code__c             = TEST_ConfigHelper.chooseValue(config.flavourCode,             ECICCommonConstants.BEVERAGE_FLAVOUR_CODE_DEFAULT);
                   dummyProduct.Packaging__c                = TEST_ConfigHelper.chooseValue(config.packaging,               ECICCommonConstants.PRODUCT_PACKAGING_DEFAULT);
                   dummyProduct.Shelf_Life__c               = TEST_ConfigHelper.chooseValue(config.shelfLife,               ECICCommonConstants.PRODUCT_SHELF_LIFE_DEFAULT);
                   dummyProduct.Size__c                     = TEST_ConfigHelper.chooseValue(config.size,                    ECICCommonConstants.PRODUCT_SIZE_DEFAULT);
                   dummyProduct.type__c                     = TEST_ConfigHelper.chooseValue(config.type,                    ECICCommonConstants.PRODUCT_TYPE_DEFAULT);
                   dummyProduct.Unit__c                     = TEST_ConfigHelper.chooseValue(config.unit,                    ECICCommonConstants.PRODUCT_UNIT_DEFAULT);
                   dummyProduct.Product_Unit_Price__c       = TEST_ConfigHelper.chooseValue(config.unitPrice,               ECICCommonConstants.PRODUCT_UNIT_PRICE_DEFAULT);
                   dummyProduct.Primary_Container__c        = TEST_ConfigHelper.chooseValue(config.primaryContainer,        ECICCommonConstants.PRODUCT_PRIMARY_CONTAINER_DEFAULT);
                   dummyProduct.Primary_Container_Code__c   = TEST_ConfigHelper.chooseValue(config.primaryContainerCode,    ECICCommonConstants.PRODUCT_PRIMARY_CONTAINER_CODE_DEFAULT);
                   dummyProduct.Product_Description__c      = TEST_ConfigHelper.chooseValue(config.productDescription,      ECICCommonConstants.PRODUCT_DESCRIPTION_DEFAULT);
                   dummyProduct.Package_Type__c             = TEST_ConfigHelper.chooseValue(config.packageType,             ECICCommonConstants.PRODUCT_PACKAGE_TYPE_DEFAULT);
                   dummyProduct.Country__c                  = TEST_ConfigHelper.chooseValue(config.country,                 ECICCommonConstants.TEST_COUNTRY);
                   dummyProduct.Country_Code__c             = TEST_ConfigHelper.chooseValue(config.countryCode,             ECICCommonConstants.COUNTRY_CODE_SPAIN);
                   dummyProduct.Active__c                   = TEST_ConfigHelper.chooseValue(config.isActive,                true);
                   dummyProduct.Currently_Sold__c           = TEST_ConfigHelper.chooseValue(config.isCurrentlySold,         true);
        
        if             (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyProduct );    } 
        else if     (insertMode    == TEST_DummyInsertModeEnum.REAL)  {                      insert    dummyProduct;    }

        return dummyProduct;
    }
    
    public static Product__c create (TEST_DummyInsertModeEnum insertMode) { return create ( new Config(), insertMode );                        }
    public static Product__c create ()                                    { return create ( new Config(), TEST_DummyInsertModeEnum.NONE     ); }
    
    // -------------------------------------------------------------------------------------

    public static List<Product__c> createList(Integer numberOfCases, Config config, TEST_DummyInsertModeEnum insertMode)
    {
        List<Product__c> dummyProductList = new List<Product__c>();
        for (Integer i=1; i<=numberOfCases; i++) { dummyProductList.add(create(config, TEST_DummyInsertModeEnum.NONE)); }

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyProductList );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyProductList;    }

        return dummyProductList;
    }
    
    public static List<Product__c> createList(List<Config> configList, TEST_DummyInsertModeEnum insertMode)
    {
        List<Product__c> dummyProductList = new List<Product__c>();
        for (Config config : configList) { dummyProductList.add(create(config, TEST_DummyInsertModeEnum.NONE)); }

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyProductList );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyProductList;    }

        return dummyProductList;
    }
    
    //--------------------------------------------------------------------------------------------------

    // @depreciated : Use create (Config config, TEST_DummyInsertModeEnum insertMode)
    public static Product__c create (Config config, Boolean insertNow)    { return create (config,        convert(insertNow));            }

    // @depreciated : Use create (TEST_DummyInsertModeEnum insertMode)
    public static Product__c create (Boolean insertNow)                     { return create (new Config(), convert(insertNow));            }

    private static TEST_DummyInsertModeEnum convert (Boolean insertNow)
    {
        return (insertNow) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE;
    }

    //--------------------------------------------------------------------------------------------------

    public static Product__c createDummyMonthProduct(Config config, Boolean insertNow)
    {
        config.name      = TEST_ConfigHelper.chooseValue (config.name,         ECICCommonConstants.PRODUCT_NAME_DEFAULT);
        config.shelfLife = TEST_ConfigHelper.chooseValue (config.shelfLife, ECICCommonConstants.PRODUCT_SHELF_LIFE_DEFAULT);
        config.unit         = TEST_ConfigHelper.chooseValue (config.unit,        ECICCommonConstants.PRODUCT_UNIT_MONTH);
        return TEST_DummyProductFactory.create (config, true);
    }
     // --------------------------------------------------------------------------------------------------------------------------------------
    
    public static Id getDefaultProductId(TEST_DummyInsertModeEnum insertMode)
    {
        if (defaultProductId != null) { return defaultProductId; }
        if (!TEST_DummyInsertModeEnumHelper.isRealRequired(insertMode)) { return 'a0I11000000Y56r'; }
        
        Product__c  dummyProduct     = create(TEST_DummyInsertModeEnum.REAL);
                    defaultProductId = dummyProduct.id;
        
        return defaultProductId;
    }    
    
    
    
}