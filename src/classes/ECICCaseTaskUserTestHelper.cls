//@depreciated : Use TEST_DummyCaseTaskUserFactory
@isTest
public class ECICCaseTaskUserTestHelper 
{
	public static final String                 USER_SHIFT_ORIGINAL 	             = TEST_DummyCaseTaskUserFactory.USER_SHIFT_ORIGINAL;
	public static final String                 USER_SHIFT_REPLACEMENT            = TEST_DummyCaseTaskUserFactory.USER_SHIFT_REPLACEMENT;
	public  final static Set<String>           ALL_CASE_USERS                    = TEST_DummyCaseTaskUserFactory.ALL_CASE_USERS_SET;
	public  final static Set<String>           ALL_CASE_OWNERS 	   	             = TEST_DummyCaseTaskUserFactory.ALL_CASE_OWNERS_SET;
	public  final static Set<String>           ALL_CASE_MANAGERS 	   	         = TEST_DummyCaseTaskUserFactory.ALL_CASE_MANAGERS_SET;
	public  final static Set<String>           ALL_QUALITY_CASE_USERS	  	     = TEST_DummyCaseTaskUserFactory.ALL_QUALITY_CASE_USERS_SET;
	public  final static Set<String>           ALL_CASE_EXTERNAL_RELATIONS       = TEST_DummyCaseTaskUserFactory.ALL_CASE_EXTERNAL_RELATIONS_SET;
	public  final static Set<String>           ALL_BOTTLER_CASE_USERS	  	     = TEST_DummyCaseTaskUserFactory.ALL_BOTTLER_CASE_USERS_SET;
	public  final static Set<String>           ALL_DISTRIBUTOR_CASE_USERS        = TEST_DummyCaseTaskUserFactory.ALL_DISTRIBUTOR_CASE_USERS_SET;
	public  final static Set<String>           ALL_REGIONALLY_DEFINED_USERS      = TEST_DummyCaseTaskUserFactory.ALL_REGIONALLY_DEFINED_USERS_SET;
	public  final static Set<String>           ALL_CUSTOM_SETTINGS_LOOKUP_USERS  = TEST_DummyCaseTaskUserFactory.ALL_CUSTOM_SETTINGS_LOOKUP_USERS_SET;
	public  final static Map<String, UserRole> CASE_TASK_USERROLES_BY_NAME_MAP   = TEST_DummyCaseTaskUserFactory.CASE_TASK_USERROLES_BY_ROLENAME_MAP; 
	public  final static Map<String, User>     CASE_TASK_USER_MAP                = TEST_DummyCaseTaskUserFactory.CASE_TASK_USER_BY_SHIFT_ROLENAME_MAP;
	public  final static String                COUNTRY_CODE                      = TEST_DummyCaseTaskUserFactory.COUNTRY_CODE;
	public  final static Id                    STANDARD_PROFILE_ID               = TEST_DummyCaseTaskUserFactory.STANDARD_PROFILE_ID;
	
    //@depreciated : Use TEST_DummyCaseTaskUserFactory.updateUserLookupMapping()
	public static void updateUserLookupMapping() { TEST_DummyCaseTaskUserFactory.updateUserLookupMapping(); }

    //@depreciated : Use TEST_DummyCaseTaskUserFactoryget(String regionType, String shift, String role) 
	public static User get(String regionType, String shift, String role) { return TEST_DummyCaseTaskUserFactory.get(regionType, shift, role); }
}