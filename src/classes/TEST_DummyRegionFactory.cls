@isTest
public class TEST_DummyRegionFactory 
{
	private static Set<String> 			  regionNameSet 			    = null;
    private static Region__c 			  defaultRegion   				= null;
	private static Id        			  defaultRegionId 				= null;
	
    private static Map<String, Region__c> defaultRegionMap = null;
    private static Id        			  defaultBottlerRegionId        = null;
    private static Id        			  defaultDistributorRegionId    = null;
	
	
	public class Config
	{
        public String 	name 			     	= null;
        public String	countryCode 		   	= null;
        public Id		externalRelationsUserId = null;
        public Id		qualityManagerUserId 	= null;
        public Id		qualityOwnerUserId   	= null;
        public Id       bottlerId               = null;
		
		public Config () 			{}
		public Config (String name) {this.name = name;}

		public Config (String name, String shift, String regionType, String countryCode)
		{
			this(name);
			this.countryCode				= countryCode;
			this.externalRelationsUserId 	= TEST_DummyCaseTaskUserFactory.get(regionType, shift, 'External_Relations').id;
			this.qualityManagerUserId		= TEST_DummyCaseTaskUserFactory.get(regionType, shift, 'Quality_Manager').id;
			this.qualityOwnerUserId			= TEST_DummyCaseTaskUserFactory.get(regionType, shift, 'Quality'+ (regionType=='bottler'?'_Owner':'')).id;
		}
	}
	
	public static Region__c create (Config config, TEST_DummyInsertModeEnum insertMode)
	{
		TEST_UniqueHelper unique = new TEST_UniqueHelper ('Dummy Region');
		
		Region__c dummyRegion = new Region__c();
				  dummyRegion.name 							= TEST_ConfigHelper.chooseValue(config.name, 						unique.uniqueString);
			   	  dummyRegion.Bottler_External_Relations__c = TEST_ConfigHelper.chooseValue(config.externalRelationsUserId, 	TEST_DummyCaseTaskUserFactory.get('Bottler', TEST_DummyCaseTaskUserFactory.USER_SHIFT_ORIGINAL, 'External_Relations').id);
			   	  dummyRegion.Bottler_Quality_Manager__c    = TEST_ConfigHelper.chooseValue(config.qualityManagerUserId, 		TEST_DummyCaseTaskUserFactory.get('Bottler', TEST_DummyCaseTaskUserFactory.USER_SHIFT_ORIGINAL, 'Quality_Manager').id);
		 	   	  dummyRegion.Bottler_Quality__c 		    = TEST_ConfigHelper.chooseValue(config.qualityOwnerUserId, 			TEST_DummyCaseTaskUserFactory.get('Bottler', TEST_DummyCaseTaskUserFactory.USER_SHIFT_ORIGINAL, 'Quality_Owner').id);
				  dummyRegion.country_code__c				= TEST_ConfigHelper.chooseValue(config.countryCode, 				null);
				  dummyRegion.Bottler__c                    = TEST_ConfigHelper.chooseValue(config.bottlerId,                   (ID)null);

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyRegion );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyRegion;    }

		return dummyRegion;
	}

    public static Region__c create (TEST_DummyInsertModeEnum insertMode) { return create ( new Config(), insertMode );                        }
    public static Region__c create ()                                    { return create ( new Config(), TEST_DummyInsertModeEnum.NONE     ); }

    public static Region__c create (String regionType, String countryCode, TEST_DummyInsertModeEnum insertMode)
	{
        return create (new Config ('Dummy ' + regionType + ' Region', TEST_DummyCaseTaskUserFactory.USER_SHIFT_ORIGINAL, regionType, countryCode), insertMode);
    }

    // -------------------------------------------------------------------------------------

    // @depreciated : Use create (Config config, TEST_DummyInsertModeEnum insertMode)
    public static Region__c create (Config config, Boolean insertNow)    { return create (config,     convert(insertNow));            }

    // @depreciated : Use create (TEST_DummyInsertModeEnum insertMode)
    public static Region__c create (Boolean insertNow)                     { return create (new Config(), convert(insertNow));            }

    // @depreciated : Use create (String regionType, String countryCode, TEST_DummyInsertModeEnum insertMode)
    public static Region__c create (String regionType, String countryCode, Boolean insertNow) { return create (regionType, countryCode, convert(insertNow)); }

    private static TEST_DummyInsertModeEnum convert (Boolean insertNow)
    {
        return (insertNow) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE;
	}

	// Required for Quality Complaint Cases ---------------------------------------------------------------------------------------------------

	public static Map<String, Region__c> createDefaultRegionMap()
	{
		Map <String, Region__c> regionByStringMap = new Map <String, Region__c>
		{
			'Bottler' 	   =>  	create ('Bottler', 	   ECICCommonConstants.COUNTRY_CODE_DEFAULT, false),
			'Distributor'  =>	create ('Distributor', ECICCommonConstants.COUNTRY_CODE_DEFAULT, false)
		};
	
		insert regionByStringMap.values();
		return regionByStringMap;
	}


	public static void addBottlerAccount (List<Region__c> regionList, Id bottlerAccountId)
	{
		for (Region__c region : regionList)
		{
			region.Bottler__c = bottlerAccountId;
		}
		
		update regionList;
	}
	
	// ---------------------------------------------------------------------------------------------------

	public static void replace (Region__c targetRegion, String regionType)
	{
		update (reconfig(targetRegion, regionType));				  
	}
	
	private static Region__c reconfig (Region__c targetRegion, String regionType)
	{
			   targetRegion.Bottler_External_Relations__c = TEST_DummyCaseTaskUserFactory.get(regionType, TEST_DummyCaseTaskUserFactory.USER_SHIFT_REPLACEMENT, 'External_Relations').id;
			   targetRegion.Bottler_Quality_Manager__c    = TEST_DummyCaseTaskUserFactory.get(regionType, TEST_DummyCaseTaskUserFactory.USER_SHIFT_REPLACEMENT, 'Quality_Manager').id;
		 	   targetRegion.Bottler_Quality__c 		      = TEST_DummyCaseTaskUserFactory.get(regionType, TEST_DummyCaseTaskUserFactory.USER_SHIFT_REPLACEMENT, 'Quality'+ (regionType=='bottler'?'_Owner':'')).id;
		return targetRegion;
	}

    // ---------------------------------------------------------------------------------------------------

    public static Region__c getDefaultRegion  (TEST_DummyInsertModeEnum insertMode)
    {
    	if (defaultRegion != null)                                      { return defaultRegion;      }
    	if (!TEST_DummyInsertModeEnumHelper.isRealRequired(insertMode)) { return create(insertMode); }
    	 
        defaultRegion   = create(TEST_DummyInsertModeEnum.REAL);
        defaultRegionId = defaultRegion.id; 
        
        return defaultRegion;
    	
    }
    
    public static Id getDefaultRegionId(TEST_DummyInsertModeEnum insertMode)
    {
        if (defaultRegionId != null)                                    { return defaultRegionId;   }
        if (!TEST_DummyInsertModeEnumHelper.isRealRequired(insertMode)) { return 'a2C11000000Cjix'; }
        
        defaultRegion = getDefaultRegion(TEST_DummyInsertModeEnum.REAL);
        return defaultRegion.Id;
    }    
    
    //---------------------------------------------------------------------------

    public static Id getDefaultBottlerRegionId      (TEST_DummyInsertModeEnum insertMode) { return getDefaultId ('Bottler',      defaultBottlerRegionId,     'a2C11000000dbr1', insertMode); }
    public static Id getDefaultDistributorRegionId  (TEST_DummyInsertModeEnum insertMode) { return getDefaultId ('Distributor',  defaultDistributorRegionId, 'a2C11000000ddr1', insertMode); }
    
    public static Region__c getDefaultBottlerRegion()     { return getDefaultRegion('Bottler');     } 
    public static Region__c getDefaultDistributorRegion() { return getDefaultRegion('Distributor'); } 
    
    private static Id getDefaultId (String regionType, Id defaultId, Id mockId, TEST_DummyInsertModeEnum insertMode)
    {
        if      (defaultId  != null)                                          { return defaultId; }
        else if (!TEST_DummyInsertModeEnumHelper.isRealRequired(insertMode))  { return mockId;    }

        return getDefaultRegion(regionType).id;
    }

    private static Region__c getDefaultRegion (String regionType)
    {
        if ((defaultRegionMap != null) && (defaultRegionMap.get(regionType) != null)) { return defaultRegionMap.get(regionType); }

        defaultRegionMap = getDefaultRegionMap();
        return defaultRegionMap.get(regionType);
    }
    
    private static Map<String, Region__c> getDefaultRegionMap()
    {
        if (defaultRegionMap != null) { return defaultRegionMap; }

        defaultRegionMap = createDefaultRegionMap();
        defaultBottlerRegionId         = defaultRegionMap.get('Bottler').id;
        defaultDistributorRegionId     = defaultRegionMap.get('Distributor').id;
        return defaultRegionMap;
    }

    //---------------------------------------------------------------------------

    public static void confirm (String regionName)
	{
		if (regionNameSet == null)
		{
			List<Region__c> regionList = [SELECT name FROM Region__c];
			
			regionNameSet = new Set<String>();
			for (Region__c region : regionList) { regionNameSet.add(region.name); }
		}
		
		if (!(regionNameSet.contains(regionName)))
		{
			create(new Config(regionName), TEST_DummyInsertModeEnum.REAL);
			regionNameSet.add(regionName);
		}
	}
}