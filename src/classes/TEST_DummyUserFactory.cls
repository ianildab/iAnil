@isTest
public class TEST_DummyUserFactory 
{
	public  static final User SETUP_DATA_CREATION_USER = [  SELECT id FROM User WHERE (isActive = TRUE) AND (profileId = :(SEPProfileCache.get('System Administrator').id)) ORDER BY CreatedDate LIMIT 1 ];
//#Ecic Template Test
    public static final String[] ES_INFOLINE_AGENT_PARAM      = new String[]{'InfolineAgent',          ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT,        ECICCommonConstants.ROLE_ES_INFOLINE_AGENT,                         ECICCommonConstants.COUNTRY_CODE_SPAIN};
    public static final String[] ES_INFOLINE_SUPREVISOR_PARAM = new String[]{'ESInfolineSupervisor',   ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_SUPERVISOR,   ECICCommonConstants.ROLE_IBERIA_INFOLINE_SUPERVISOR,                ECICCommonConstants.COUNTRY_CODE_SPAIN};
    public static final String[] ES_BOTTLER                   = new String[]{'ESBottler',              ECICCommonConstants.PROFILE_ECIC_IBERIA_BOTTLER_QUALITY,       ECICCommonConstants.ROLE_IBERIA_BOTTLER_QUALITY,                    ECICCommonConstants.COUNTRY_CODE_SPAIN};
    public static final String[] ES_KO_QUALITY_AGENT          = new String[]{'ESKOQualityAgent',       ECICCommonConstants.PROFILE_ECIC_IBERIA_COCA_COLA_QUALITY,     ECICCommonConstants.ROLE_IBERIA_QUALITY_AGENT,                      ECICCommonConstants.COUNTRY_CODE_SPAIN};
    public static final String[] ES_KO_QUALITY_MANAGER        = new String[]{'ESKOQualityManager',     ECICCommonConstants.PROFILE_ECIC_IBERIA_COCA_COLA_QUALITY,     ECICCommonConstants.ROLE_IBERIA_QUALITY_MANAGER,                    ECICCommonConstants.COUNTRY_CODE_SPAIN};
    public static final String[] ES_EXTERNAL_RELATIONS        = new String[]{'ESExtRelation',          ECICCommonConstants.PROFILE_ECIC_IBERIA_EXTERNAL_RELATIONS,    ECICCommonConstants.ROLE_IBERIA_BOTTLER_EXTERNALS,                  ECICCommonConstants.COUNTRY_CODE_SPAIN};                     
  //End Of Template   
    private static final Map<String,Profile>  PROFILES_BY_NAME_MAP  = SEPProfileCache.getProfilesByNameMap();
    private static final Map<String,UserRole> USERROLES_BY_NAME_MAP = SEPUserRoleCache.getUserRolesByNameMap();

    private static User testRunUser = null;
    
    // -------------------------------------------------------------------------------------------------------------------
    
    public class Config
    {
    	public String testerName        = null;
        public String lastName          = null;
        public String alias             = null; 
        public String email             = null; 
        public String username          = null; 
        public String communityNickname = null;  
        public String languageLocaleKey = null;
        public String localeSidKey      = null;
        public String emailEncodingKey  = null;
        public String timeZoneSidKey    = null;
        public String countryCode       = null;
        
        public Id     profileId         = null;
        public String profileName       = null;     // Only used if profileId is null;  
        public Id     userRoleId        = null;
        public String userRoleName      = null;     // Only used if userRoleId is null;
        
        public Boolean isActive          = null;
        
        public Config() {}  
        
        public Config (String testerName, Id profileId, Id userRoleId, String countryCode)
        {
        	this.testerName  = testerName;
        	this.profileId   = profileId;
        	this.userRoleId  = userRoleId;
        	this.countryCode = countryCode;
        }  

        public Config (String testerName, String profileName, String userRoleName, String countryCode)
        {
            this.testerName   = testerName;
            this.profileName  = profileName;
            this.userRoleName = userRoleName;
            this.countryCode  = countryCode;
        }  

        public Config (String[] userParameterArray)
        {
        	this (userParameterArray[0], userParameterArray[1], userParameterArray[2], userParameterArray[3]);
        }

        public Config (String profileName) { this.profileName  = profileName; }  

    }

    // -------------------------------------------------------------------------------------------------------------------
    
    public static User create (Config config, TEST_DummyInsertModeEnum insertMode)
    {
        if (config.profileId == null)  { config.profileId  = (config.profileName  != null) ? PROFILES_BY_NAME_MAP.get(config.profileName).id   : PROFILES_BY_NAME_MAP.get(ECICCommonConstants.PROFILE_ECIC_INFOLINE_AGENT).id; }
        if (config.userRoleId == null) { config.userRoleId = (config.userRoleName != null) ? USERROLES_BY_NAME_MAP.get(config.userRoleName).id : USERROLES_BY_NAME_MAP.get(ECICCommonConstants.ROLE_ES_INFOLINE_AGENT).id;     }
    	
        TEST_UniqueHelper uniqueHelper = new TEST_UniqueHelper((config.testerName != null) ? config.testerName : 'Dummy User');
                   String uniqueTesterName = uniqueHelper.uniqueString; 
                   String uniqueSpaceless  = uniqueHelper.uniqueSpaceless;
        
        User dummyUser = new User();
             dummyUser.lastName          = TEST_ConfigHelper.chooseValue(config.lastName,           uniqueTesterName);
             dummyUser.alias             = TEST_ConfigHelper.chooseValue(config.alias,              uniqueSpaceless.left(1)+uniqueSpaceless.right(7)); 
             dummyUser.email             = TEST_ConfigHelper.chooseValue(config.email,              uniqueSpaceless + '@runas.example.com'); 
             dummyUser.username          = TEST_ConfigHelper.chooseValue(config.username,           uniqueSpaceless + '@runas.example.com'); 
             dummyUser.communityNickname = TEST_ConfigHelper.chooseValue(config.communityNickname,  uniqueSpaceless);  
             dummyUser.languageLocaleKey = TEST_ConfigHelper.chooseValue(config.languageLocaleKey,  'en_US');
             dummyUser.localeSidKey      = TEST_ConfigHelper.chooseValue(config.localeSidKey,       'en_US');
             dummyUser.emailEncodingKey  = TEST_ConfigHelper.chooseValue(config.emailEncodingKey,   'UTF-8');
             dummyUser.timeZoneSidKey    = TEST_ConfigHelper.chooseValue(config.timeZoneSidKey,     'Europe/Berlin');
             dummyUser.country_Code__c   = TEST_ConfigHelper.chooseValue(config.countryCode,        ECICCommonConstants.COUNTRY_CODE_DEFAULT);
             dummyUser.isActive          = TEST_ConfigHelper.chooseValue(config.isActive,           true);
             dummyUser.profileId         = config.profileId;
             dummyUser.userRoleId        = config.userRoleId;

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  (        dummyUser );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  { System.runAs(SETUP_DATA_CREATION_USER) { insert dummyUser;  } }

        return dummyUser;
    }
    
    public static User create (TEST_DummyInsertModeEnum insertMode) { return create (new Config(), insertMode);                    }
    public static User create ()                                    { return create (new Config(), TEST_DummyInsertModeEnum.NONE); }

    public static User create(String testerName, Id testerProfileId, Id testerRoleId, String testerCountryCode, TEST_DummyInsertModeEnum insertMode)
    {
    	return create (new Config(testerName, testerProfileId, testerRoleId, testerCountryCode), insertMode);
    }
    
    public static User create(String testerName, String testerProfileString, String testerRoleString, String testerCountryCode, TEST_DummyInsertModeEnum insertMode)
    {
        return create (new Config(testerName, testerProfileString, testerRoleString, testerCountryCode), insertMode);
    }

    public static User create (String testerProfileString,  TEST_DummyInsertModeEnum insertMode) { return create (new Config(testerProfileString), insertMode); }
    public static User create (String[] userParameterArray, TEST_DummyInsertModeEnum insertMode) { return create (new Config(userParameterArray),  insertMode); }
    public static User create (String[] userParameterArray)                                      { return create (new Config(userParameterArray),  TEST_DummyInsertModeEnum.REAL); }

    //-------------------------------------------------------------------------------------------------------------------------------------
    
    public static User createDefaultTestRunUser()
    {
    	if (testRunUser == null)
    	{
    		testRunUser = create(ECICCommonConstants.PROFILE_SYSTEM_ADMIN, ECICCommonConstants.PROFILE_SYSTEM_ADMIN, ECICCommonConstants.ROLE_CIC_IBERIA_SERVICE_MANAGER, ECICCommonConstants.COUNTRY_CODE_UK, TEST_DummyInsertModeEnum.REAL); 
    	}
    	return testRunUser;
    }

    //-------------------------------------------------------------------------------------------------------------------------------------

    public static List<User> createList (List<Config> configList, TEST_DummyInsertModeEnum insertMode)
    {
        List<User> dummyUserList = new List<User>();
        for (Config config : configList) { dummyUserList.add(create(config, TEST_DummyInsertModeEnum.NONE)); }

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  (                   dummyUserList );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  { System.runAs(SETUP_DATA_CREATION_USER) { insert dummyUserList;  } }
        
        return dummyUserList;
    }
    
    public static List<User> createList (List<String> profileNameList, TEST_DummyInsertModeEnum insertMode)
    {
        List<Config> configList = new List<Config>();
        for (String profileName : profileNameList) { configList.add(new Config(profileName)); }
        return createList (configList, insertMode);
    }
    
    public static List<User> createList (List<String[]> profileStringArrayList, TEST_DummyInsertModeEnum insertMode)
    {
        List<Config> configList = new List<Config>();
        for (String[] profileStringArray : profileStringArrayList) { configList.add(new Config(profileStringArray)); }
        return createList (configList, insertMode);
    }

    public static List<User> createList(Integer countUsers, Config config, TEST_DummyInsertModeEnum insertMode) 
    {
        List<Config> configList = new List<Config>();
        for (Integer i = 0; i < countUsers; i++) { configList.add(config); }
        return createList (configList, insertMode);
    }        
    
    public static List<User> createList(Integer countUsers, TEST_DummyInsertModeEnum insertMode) { return createList (countUsers, new Config(), insertMode); }        

    //-------------------------------------------------------------------------------------------------------------------------------------
    
    public static Map<String,User> createMap (List<String> profileNameList)
    {
        Map<String,User> dummyUserMap = new Map<String,User>(); 
        for (User dummyUser : createList (profileNameList, TEST_DummyInsertModeEnum.REAL))
        {
            dummyUserMap.put(SEPProfileCache.get(dummyUser.profileId).name, dummyUser);
        }
        return dummyUserMap;
    }
    
    public static Map<String,User> createMap (List<String[]> profileStringArrayList)
    {
        Map<String,User> dummyUserMap = new Map<String,User>(); 
        for (User dummyUser : createList (profileStringArrayList, TEST_DummyInsertModeEnum.REAL))
        {
            dummyUserMap.put(SEPProfileCache.get(dummyUser.profileId).name, dummyUser);
        }
        return dummyUserMap;
    }

    public static Map<String,User> createMap (List<Config> configList)
    {
        Map<String,User> dummyUserMap = new Map<String,User>(); 
        for (Config config : configList) { dummyUserMap.put(config.testerName, create (config, TEST_DummyInsertModeEnum.NONE)); }
        insert dummyUserMap.values();
        return dummyUserMap;
    }
    

}