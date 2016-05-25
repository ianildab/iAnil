/**
* @author		Brian Kessler (Brian_Kessler@epam.com)
* @date			2013 May 21
* @description	This class exists to create dummy users for running tests. 
*/

@isTest
// @depreciated  Use TEST_DummyUserFactory.
public class ECICRunUserTestHelper 
{
	
    public static final String[] ES_INFOLINE_AGENT_PARAM      = TEST_DummyUserFactory.ES_INFOLINE_AGENT_PARAM;
    public static final String[] ES_INFOLINE_SUPREVISOR_PARAM = TEST_DummyUserFactory.ES_INFOLINE_SUPREVISOR_PARAM;
    public static final String[] ES_BOTTLER                   = TEST_DummyUserFactory.ES_BOTTLER;
    public static final String[] ES_KO_QUALITY_AGENT          = TEST_DummyUserFactory.ES_KO_QUALITY_AGENT;
    public static final String[] ES_KO_QUALITY_MANAGER        = TEST_DummyUserFactory.ES_KO_QUALITY_MANAGER;
    public static final String[] ES_EXTERNAL_RELATIONS        = TEST_DummyUserFactory.ES_EXTERNAL_RELATIONS;                     

	public static final User     SETUP_DATA_CREATION_USER     = TEST_DummyUserFactory.SETUP_DATA_CREATION_USER;
	public static       User     defaultTestRunUser           = TEST_DummyUserFactory.createDefaultTestRunUser();

    // @depreciated: Use TEST_DummyUserFactory.create(String testerName, Id testerProfileId, Id testerRoleId, String testerCountryCode, TEST_DummyInsertModeEnum insertMode); 
	public static User create(String testerName, Id testerProfileId, Id testerRoleId, String testerCountryCode, Boolean insertNow)
	{
		return TEST_DummyUserFactory.create(testerName, testerProfileId, testerRoleId, testerCountryCode, convert(insertNow));
    }

    // @depreciated: Use TEST_DummyUserFactory.create(String testerName, String testerProfileString, String testerRoleString, String testerCountryCode, TEST_DummyInsertModeEnum insertMode); 
	public static User create(String testerName, String testerProfileString, String testerRoleString, String testerCountryCode, Boolean insertNow) 
	{ 
		return TEST_DummyUserFactory.create(testerName, testerProfileString, testerRoleString, testerCountryCode, convert(insertNow));
	}

    // @depreciated: Use TEST_DummyUserFactory.create(String testerName, String testerProfileString, String testerRoleString, String testerCountryCode); 
	public static User create(String testerName, String testerProfileString, String testerRoleString, String testerCountryCode) 				   
	{
		return TEST_DummyUserFactory.create(testerName, testerProfileString, testerRoleString, testerCountryCode, TEST_DummyInsertModeEnum.REAL); 
	}
	
	// @depreciated: Use TEST_DummyUserFactory.create(String testerProfileString, String testerCountryCode);
	public static User create(String profileName, Boolean insertNow) 		    
	{
		return TEST_DummyUserFactory.create(profileName, profileName, ECICCommonConstants.ROLE_CIC_IBERIA_SERVICE_MANAGER, ECICCommonConstants.COUNTRY_CODE_UK, convert(insertNow)); 
	}

    // @depreciated: Use TEST_DummyUserFactory.create(String[] userParameterArray, TEST_DummyInsertModeEnum insertMode);
    public static User create(String[] userParameterArray, Boolean insertNow)  { return TEST_DummyUserFactory.create (userParameterArray, convert(insertNow)); }
    // @depreciated: Use TEST_DummyUserFactory.create(String[] userParameterArray);
    public static User create(String[] userParameterArray)					   { return TEST_DummyUserFactory.create (userParameterArray, TEST_DummyInsertModeEnum.REAL); }
		
    // ----------------------------------------------------------------------------------------

    // @depreciated: Use TEST_DummyUserFactory.create() OR TEST_DummyUserFactory.createDefaultTestRunUser();
	public static User create() { return TEST_DummyUserFactory.createDefaultTestRunUser(); }	 	
		
	// ----------------------------------------------------------------------------------------
	
    // @depreciated: Use TEST_DummyUserFactory.createList (List<String> profileNameList, TEST_DummyInsertModeEnum insertMode)
	public static List<User> createList (List<String> profileNameList, Boolean insertNow) { return TEST_DummyUserFactory.createList(profileNameList,  convert(insertNow)); }

    // @depreciated: Use TEST_DummyUserFactory.createList (List<String[]> profileStringArrayList, TEST_DummyInsertModeEnum insertMode)
	public static List<User> createList (List<String[]> profileStringArrayList, Boolean insertNow)  { return TEST_DummyUserFactory.createList(profileStringArrayList,  convert(insertNow)); }

    // ----------------------------------------------------------------------------------------
	
    // @depreciated: Use TEST_DummyUserFactory.createMap (List<String> profileNameList)
	public static Map<String,User> createMap (List<String> profileNameList) { return TEST_DummyUserFactory.createMap(profileNameList); }
	
    // @depreciated: Use TEST_DummyUserFactory.createMap (List<String> profileStringArrayList)
	public static Map<String,User> createMap (List<String[]> profileStringArrayList) { return TEST_DummyUserFactory.createMap(profileStringArrayList); }

    // ----------------------------------------------------------------------------------------
	
    private static TEST_DummyInsertModeEnum convert (Boolean insertNow) { return (insertNow) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE; }
	
	
}