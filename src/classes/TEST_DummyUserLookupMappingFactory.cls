@isTest
public class TEST_DummyUserLookupMappingFactory 
{
	private static final Set<String> DEFAULT_COUNTRY_CODE_SET = new Set<String>{ ECICCommonConstants.COUNTRY_CODE_SPAIN, ECICCommonConstants.COUNTRY_CODE_PT, ECICCommonConstants.COUNTRY_CODE_UK, ECICCommonConstants.COUNTRY_CODE_US};
	
	public class Config
	{
		public String countryCode				= null;
		public String consumerComplaintManager  = null;
		public String qualityAssistantManager	= null;
		public String qualityCaseOwner			= null;
		public String qualityManager 			= null;
		public String serviceManager 			= null;
		
		public config() {}
		public config(String countryCode) { this.countryCode = countryCode; }
	}

	public static User_Lookup_Mapping__c create (Config config, TEST_DummyInsertModeEnum insertMode)
	{
            User_Lookup_Mapping__c dummyUserLookupMapping = new User_Lookup_Mapping__c ();
            					   dummyUserLookupMapping.Name 						    = TEST_ConfigHelper.chooseValue(config.countryCode,					ECICCommonConstants.COUNTRY_CODE_DEFAULT);
            					   dummyUserLookupMapping.Consumer_Complaint_Manager__c = TEST_ConfigHelper.chooseValue(config.consumerComplaintManager,	ECICCommonConstants.ROLE_IBERIA_CONSUMER_QUALITY_COMPLAINTS_MANAGER);
            					   dummyUserLookupMapping.Quality_Admin_Assistant__c    = TEST_ConfigHelper.chooseValue(config.qualityAssistantManager,		ECICCommonConstants.ROLE_IBERIA_QUALITY_ADMINISTRATIVE_ASSISTANT);
            					   dummyUserLookupMapping.Quality_Case_Owner__c 		= TEST_ConfigHelper.chooseValue(config.qualityCaseOwner,			ECICCommonConstants.ROLE_IBERIA_QUALITY_AGENT);
            					   dummyUserLookupMapping.Quality_Manager__c 		    = TEST_ConfigHelper.chooseValue(config.qualityManager,				ECICCommonConstants.ROLE_IBERIA_QUALITY_MANAGER);
            					   dummyUserLookupMapping.Service_Manager__c 		    = TEST_ConfigHelper.chooseValue(config.serviceManager,				ECICCommonConstants.ROLE_IBERIA_INFOLINE_SUPERVISOR);
	
		if 			(insertMode == TEST_DummyInsertModeEnum.MOCK)  { 									     TEST_MockHelper.mockInsert  ( dummyUserLookupMapping  );   }   
		else if 	(insertMode	== TEST_DummyInsertModeEnum.REAL)  { System.runAs(ECICRunUserTestHelper.SETUP_DATA_CREATION_USER) { insert dummyUserLookupMapping;    } }

						    return dummyUserLookupMapping;
	}

	public static User_Lookup_Mapping__c create (TEST_DummyInsertModeEnum insertMode) { return create (new Config(), insertMode); 				     }
	public static User_Lookup_Mapping__c create () 				  				      { return create (new Config(), TEST_DummyInsertModeEnum.NONE); }

	public static User_Lookup_Mapping__c create (String countryCode, TEST_DummyInsertModeEnum insertMode)  { return create (new Config(countryCode), insertMode); }
	
	// --------------------------------------------------------------------------------------------------------------------------------------------

	public static List<User_Lookup_Mapping__c> createList (Set<String> countryCodeSet, TEST_DummyInsertModeEnum insertMode)
	{
        List<User_Lookup_Mapping__c> dummyUserLookupMappingList = new List<User_Lookup_Mapping__c>();
        for (String countryCode: countryCodeSet) 
        {
            dummyUserLookupMappingList.add(create(countryCode, TEST_DummyInsertModeEnum.NONE));
        }

		if 			(insertMode == TEST_DummyInsertModeEnum.MOCK)  { 									     TEST_MockHelper.mockInsert  ( dummyUserLookupMappingList  );   } 
		else if 	(insertMode	== TEST_DummyInsertModeEnum.REAL)  { System.runAs(ECICRunUserTestHelper.SETUP_DATA_CREATION_USER) { insert dummyUserLookupMappingList;    } }
		
		return dummyUserLookupMappingList;
	}

    // Consider using createDefaultList (TEST_DummyInsertModeEnum insertMode) instead; tests shouldn't have this dependency on the current User.
    public static List<User_Lookup_Mapping__c> createDefaultList (String currentUserCountryCode, TEST_DummyInsertModeEnum insertMode)
    {
    	User_Lookup_Mapping__c[] userLookupMappingsArray = User_Lookup_Mapping__c.getAll().values();   // Get roles from mapping of all countries
        Set<String> existingCountryCodeSet = new Set<String>();
        for (User_Lookup_Mapping__c mapping : userLookupMappingsArray) 
        {
        	existingCountryCodeSet.add(mapping.name);
        }
    	
    	Set<String> countryCodeSet = new Set<String>();
    	for (String countryCode : DEFAULT_COUNTRY_CODE_SET)
    	{
            if (!existingCountryCodeSet.contains(countryCode)) { countryCodeSet.add(countryCode); }    		
    	}
    	
        if ((currentUserCountryCode != null) && (!countryCodeSet.contains(currentUserCountryCode))) { countryCodeSet.add(currentUserCountryCode); }

		return createList (countryCodeSet, insertMode);  
    }

    public static List<User_Lookup_Mapping__c> createDefaultList (TEST_DummyInsertModeEnum insertMode) { return createDefaultList (null, insertMode); }

}