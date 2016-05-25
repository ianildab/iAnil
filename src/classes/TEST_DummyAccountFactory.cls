@isTest
public class TEST_DummyAccountFactory 
{
	private static Map<String, Account> defaultCaseAccountMap          = null;
    private static Id                   defaultBottlerAccountId        = null;
    private static Id                   defaultPackageSupplierId       = null;
    private static Id                   defaultPointOfSaleKeyAccountId = null;
    private static Id                   defaultPointOfSaleAccountId    = null;
	
	public class Config
	{
		public String   firstName			= null;
		public String   lastName			= null;
		public String   countryCode         = null;
		public String   name				= null;
        public String 	shippingCity     	= null;
        public String 	shippingCountry     = null;
        public String 	shippingPostalCode  = null;
        public String 	shippingState     	= null;
        public String 	shippingStreet     	= null;
        public String 	tradeChannel     	= null;
        public String 	type     			= null;

        public String   externalId          = null;
        public Id		parentId 	    	= null;
		public Id 		recordTypeId		= null;
        public Id		regionId 	    	= null;
        public Id       ownerUserId         = null;
        
        public Boolean  isActive			= null;
        public Boolean  isPerson			= false;					// Default to Business Account.
        public Boolean  isPointOfSale		= false;
		
		public Config () {}
	}
	
	public static Account create (Config config, TEST_DummyInsertModeEnum insertMode)
	{
		Account dummyAccount = new Account();

		if (config.isPerson) { configPerson   (dummyAccount, config); }	// Sets Person values direct to Account, or defaults to Config
		else				 { configBusiness (dummyAccount, config); }	// Sets Business values direct to Account, or defaults to Config

        Region__c dummyRegion  = null;
		if (((config.shippingCity == null) || (config.shippingState == null) || (config.regionId == null))) 
		{
			dummyRegion = TEST_DummyRegionFactory.getDefaultRegion(TEST_DummyInsertModeEnum.REAL);       // TODO: It should not be necessary to lock this to REAL, but then upstream must be enhanced to use "DML_LATER".
		}
		
		if (dummyAccount.shippingState != null) { TEST_DummyRegionFactory.confirm(dummyAccount.shippingState); }

		// Configure required Fields common to both Business and Person		
            dummyAccount.country_code__c                = TEST_ConfigHelper.chooseValue(config.countryCode,         null);
			dummyAccount.shippingCity		 			= TEST_ConfigHelper.chooseValue(config.shippingCity, 		dummyRegion, 'name');
			dummyAccount.shippingCountry	 			= TEST_ConfigHelper.chooseValue(config.shippingCountry, 	ECICCommonConstants.COUNTRY_CODE_DEFAULT);
			dummyAccount.shipping_Country__c 			= TEST_ConfigHelper.chooseValue(config.shippingCountry, 	ECICCommonConstants.COUNTRY_CODE_DEFAULT);
			dummyAccount.shippingPostalCode	 			= TEST_ConfigHelper.chooseValue(config.shippingPostalCode,	ECICCommonConstants.TEST_POSTAL_CODE);
			dummyAccount.shippingState		 			= TEST_ConfigHelper.chooseValue(config.shippingState, 		dummyRegion, 'name');
			dummyAccount.shipping_administrativearea__c = TEST_ConfigHelper.chooseValue(config.shippingState, 		dummyRegion, 'name');
			dummyAccount.shippingStreet		 			= TEST_ConfigHelper.chooseValue(config.shippingStreet, 		ECICCommonConstants.TEST_STREET);
			dummyAccount.Active__c			 			= TEST_ConfigHelper.chooseValue(config.isActive,			true);

		// Configure optional Fields, usually only used by business (but nothing stops PersonAccount from having these values, I think).
            dummyAccount.account_ext_id__c   			= TEST_ConfigHelper.chooseValue(config.externalId,          null);
			dummyAccount.parentId			 			= TEST_ConfigHelper.chooseValue(config.parentId, 			(id) null);
			dummyAccount.point_of_sale__c	 			= TEST_ConfigHelper.chooseValue(config.isPointOfSale,		null);
			dummyAccount.region__c			 			= TEST_ConfigHelper.chooseValue(config.regionId, 			dummyRegion);
			dummyAccount.trade_channel__c	 			= TEST_ConfigHelper.chooseValue(config.tradeChannel, 		null);
			dummyAccount.type				 			= TEST_ConfigHelper.chooseValue(config.type, 				null);

        if (config.ownerUserId != null) { dummyAccount.OwnerId = config.ownerUserId; } 

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyAccount );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyAccount;    }

		return dummyAccount;
	}

    public static Account create (TEST_DummyInsertModeEnum insertMode) { return create ( new Config(), insertMode );                        }
    public static Account create ()                                    { return create ( new Config(), TEST_DummyInsertModeEnum.NONE     ); }

    // -------------------------------------------------------------------------------------
    
    public static Map<String, Account> createCaseAccountMap(Region__c bottlerRegion, TEST_DummyInsertModeEnum insertMode)
	{

		Map <String, Account> accountByStringMap = new Map <String, Account>
		{
			'bottler' 	   	   =>  createBottler (bottlerRegion, false), 
			'packageSupplier'  =>  createPackageSupplier(false), 
			'pointOfSaleKey'   =>  createPointOfSaleKey(false)
		};

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( accountByStringMap.values() );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    accountByStringMap.values();    }

        Account pointOfSaleAccount = createPointOfSale(accountByStringMap.get('pointOfSaleKey').id, insertMode);  // We need a separate insert for Point of Sale because we first need its Key Account's id.  :-(
		accountByStringMap.put ('pointOfSale',  pointOfSaleAccount);

		return accountByStringMap;
	}
	
    public static Account createBottler (Region__c region, TEST_DummyInsertModeEnum insertMode) 
	{ 
		Config config = new Config();
			   config.shippingState = region.name;
			   config.regionId	    = region.id;
			   config.type		    = ECICCommonConstants.ACCOUNT_TYPE_BOTTLER;
        return create (config, insertMode); 
	}

    public static Account createPackageSupplier (TEST_DummyInsertModeEnum insertMode)  
	{ 
		Config config = new Config();
			   config.type		    = ECICCommonConstants.ACCOUNT_TYPE_SUPPLIER;
        return create (config, insertMode); 
	}

    public static Account createPointOfSale (Id keyAccountId, TEST_DummyInsertModeEnum insertMode) 
	{ 
		Config config = new Config();
			   config.parentId      = keyAccountId;
			   config.isPointOfSale = true;
        return create (config, insertMode); 
	}

    public static Account createPointOfSaleKey (TEST_DummyInsertModeEnum insertMode)  
	{ 
		Config config = new Config();
			   config.type		    = ECICCommonConstants.ACCOUNT_TYPE_POSKEYACCOUNT;
        return create (config, insertMode); 
	}

    //---------------------------------------------------------------------------

    public static List<Account> createList(Integer numberOfCases, Config config, TEST_DummyInsertModeEnum insertMode)
    {
        List<Account> dummyAccountList = new List<Account>();
        for (Integer i=1; i<=numberOfCases; i++) { dummyAccountList.add(create(config, TEST_DummyInsertModeEnum.NONE)); }

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyAccountList );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyAccountList;    }

        return dummyAccountList;
    }
    
    public static List<Account> createList(List<Config> configList, TEST_DummyInsertModeEnum insertMode)
    {
        List<Account> dummyAccountList = new List<Account>();
        for (Config config : configList) { dummyAccountList.add(create(config, TEST_DummyInsertModeEnum.NONE)); }

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyAccountList );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyAccountList;    }

        return dummyAccountList;
    }
    
    //--------------------------------------------------------------------------------------------------

	private static void configBusiness (Account dummyAccount, Config config)
	{
		Region__c dummyBottlerRegion = null;
		if (config.regionId == null) { dummyBottlerRegion = TEST_DummyRegionFactory.getDefaultBottlerRegion(); }

		TEST_UniqueHelper unique = new TEST_UniqueHelper ('Dummy  Business  Account');
		dummyAccount.recordTypeId	= TEST_ConfigHelper.chooseValue(config.recordTypeId, 		(Id) ECICCommonConstants.ACCOUNT_BUSINESS_RT_ID);
		dummyAccount.name			= TEST_ConfigHelper.chooseValue(config.name, 				unique.uniqueString + ' Name');
		
		config.regionId				= TEST_ConfigHelper.chooseValue(config.regionId, 			dummyBottlerRegion);
		config.tradeChannel 		= TEST_ConfigHelper.chooseValue(config.tradeChannel, 		ECICCommonConstants.ACCOUNT_TRADE_CHANNEL);
		config.type 				= TEST_ConfigHelper.chooseValue(config.type, 				ECICCommonConstants.ACCOUNT_TYPE_DEFAULT);
	}

	private static void configPerson (Account dummyAccount, Config config)
	{
		TEST_UniqueHelper unique = new TEST_UniqueHelper ('Dummy Person Account');
		
		
		dummyAccount.recordTypeId	= TEST_ConfigHelper.chooseValue(config.recordTypeId, 		(Id)ECICCommonConstants.ACCOUNT_PERSON_RT_ID);
		dummyAccount.firstName      = TEST_ConfigHelper.chooseValue(config.firstName, 			(unique.uniqueString + 'First Name').left(39));
		dummyAccount.lastName		= TEST_ConfigHelper.chooseValue(config.lastName, 			(unique.uniqueString + 'Last Name').left(79));
	}

	//---------------------------------------------------------------------------

    // @depreciated : Use create (Config config, TEST_DummyInsertModeEnum insertMode)
    public static Account create (Config config, Boolean insertNow)    { return create (config,     convert(insertNow));            }

    // @depreciated : Use create (TEST_DummyInsertModeEnum insertMode)
    public static Account create (Boolean insertNow)                     { return create (new Config(), convert(insertNow));            }

    // @depreciated : Use createCaseAccountMap(Region__c bottlerRegion, TEST_DummyInsertModeEnum insertMode)
	public static Map<String, Account> createCaseAccountMap(Region__c bottlerRegion, Boolean insertNow) { return createCaseAccountMap (bottlerRegion, convert(insertNow));  }

    // @depreciated : Use createBottler (Region__c region, TEST_DummyInsertModeEnum insertMode)
	public static Account createBottler (Region__c region, Boolean insertNow)  { return createBottler (region, convert(insertNow));  }

    // @depreciated : Use createPackageSupplier (TEST_DummyInsertModeEnum insertMode)
	public static Account createPackageSupplier (Boolean insertNow)  { return createPackageSupplier (convert(insertNow));  }

    // @depreciated : Use createPointOfSale (Id keyAccountId, TEST_DummyInsertModeEnum insertMode)
	public static Account createPointOfSale (Id keyAccountId, Boolean insertNow)  { return createPointOfSale (keyAccountId, convert(insertNow));  }

    // @depreciated : Use createPointOfSaleKey (TEST_DummyInsertModeEnum insertMode)
	public static Account createPointOfSaleKey (Boolean insertNow)  { return createPointOfSaleKey (convert(insertNow));  }

    private static TEST_DummyInsertModeEnum convert (Boolean insertNow)
    {
        return (insertNow) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE;
    }

	//---------------------------------------------------------------------------

    public static Id getDefaultBottlerAccountId         (TEST_DummyInsertModeEnum insertMode) { return getDefaultId ('bottler',         defaultBottlerAccountId,        '00111000000dBA1', insertMode); }
    public static Id getDefaultPackageSupplierAccountId (TEST_DummyInsertModeEnum insertMode) { return getDefaultId ('packageSupplier', defaultPackageSupplierId,       '001110000dPSKA1', insertMode); }
    public static Id getDefaultPointOfSaleKeyAccountId  (TEST_DummyInsertModeEnum insertMode) { return getDefaultId ('pointOfSaleKey',  defaultPointOfSaleKeyAccountId, '00111000dPoSKA1', insertMode); }
    public static Id getDefaultPointOfSaleAccountId     (TEST_DummyInsertModeEnum insertMode) { return getDefaultId ('pointOfSale',     defaultPointOfSaleAccountId,    '001110000dPoSA1', insertMode); }
    
    private static Id getDefaultId (String accountType, Id defaultId, Id mockId, TEST_DummyInsertModeEnum insertMode)
    {
        if      (defaultId  != null)                                          { return defaultId; }
        else if (!TEST_DummyInsertModeEnumHelper.isRealRequired(insertMode))  { return mockId;    }
        return getDefaultAccount(accountType).id;
    }

    private static Account getDefaultAccount (String accountType)
    {
        if ((defaultCaseAccountMap != null) && (defaultCaseAccountMap.get(accountType) != null)) { return defaultCaseAccountMap.get(accountType); }
        defaultCaseAccountMap = getDefaultCaseAccountMap();
        return defaultCaseAccountMap.get(accountType);
    }
     
    private static Map<String, Account> getDefaultCaseAccountMap()
    {
    	if (defaultCaseAccountMap != null) { return defaultCaseAccountMap; }
    	
        defaultCaseAccountMap = createCaseAccountMap(TEST_DummyRegionFactory.getDefaultBottlerRegion(), TEST_DummyInsertModeEnum.REAL);
        defaultBottlerAccountId         = defaultCaseAccountMap.get('bottler').id;
        defaultPackageSupplierId        = defaultCaseAccountMap.get('packageSupplier').id;
        defaultPointOfSaleKeyAccountId  = defaultCaseAccountMap.get('pointOfSaleKey').id;
        defaultPointOfSaleAccountId     = defaultCaseAccountMap.get('pointOfSale').id;
        return defaultCaseAccountMap;
    }
}