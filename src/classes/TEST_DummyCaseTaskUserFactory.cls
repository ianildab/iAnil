@isTest
public class TEST_DummyCaseTaskUserFactory 
{
    public  final static Map<String, UserRole> CASE_TASK_USERROLES_BY_ROLENAME_MAP; 
    public  final static Map<String, User>     CASE_TASK_USER_BY_SHIFT_ROLENAME_MAP;
    private final static Map<String, UserRole> STANDARD_USERROLES_BY_ROLENAME_MAP;

    public  final static String               COUNTRY_CODE                = ECICCommonConstants.COUNTRY_CODE_DEFAULT;    // This must match the Case Country Code!
    public  final static Id                   STANDARD_PROFILE_ID         = SEPProfileCache.get('Standard User').id;

    public  final static String               USER_SHIFT_ORIGINAL         = 'Original';
    public  final static String               USER_SHIFT_REPLACEMENT      = 'Replacement';

    public  final static Set<String> ALL_CASE_OWNERS_SET                  = new Set<String> { 'OwnerId', 'Bottler_Quality_Owner__c', 'Distributor_Quality__c', 'Quality_Case_Owner__c' };
    public  final static Set<String> ALL_CASE_MANAGERS_SET                = new Set<String> { 'Consumer_Complaint_Manager__c', 'Service_Manager__c', 'Bottler_Quality_Manager__c', 'Distributor_Quality_Manager__c', 'Quality_Manager__c' };
    public  final static Set<String> ALL_QUALITY_CASE_USERS_SET           = new Set<String> { 'Quality_Admin_Assistant__c', 'Quality_Manager__c', 'Quality_Case_Owner__c' };
    public  final static Set<String> ALL_CASE_EXTERNAL_RELATIONS_SET      = new Set<String> { 'Bottler_External_Relations__c', 'Distributor_External_Relations__c'};
    public  final static Set<String> ALL_BOTTLER_CASE_USERS_SET           = new Set<String> { 'Bottler_External_Relations__c', 'Bottler_Quality_Manager__c', 'Bottler_Quality_Owner__c' };
    public  final static Set<String> ALL_DISTRIBUTOR_CASE_USERS_SET       = new Set<String> { 'Distributor_External_Relations__c', 'Distributor_Quality_Manager__c', 'Distributor_Quality__c' };
    public  final static Set<String> ALL_CUSTOM_SETTINGS_LOOKUP_USERS_SET = new Set<String> { 'Consumer_Complaint_Manager__c', 'Service_Manager__c', 'Quality_Admin_Assistant__c', 'Quality_Manager__c', 'Quality_Case_Owner__c'};
    public  final static Set<String> ALL_REGIONALLY_DEFINED_USERS_SET     = createUserSet (new List<Set<String>> { ALL_BOTTLER_CASE_USERS_SET,  ALL_DISTRIBUTOR_CASE_USERS_SET });
    public  final static Set<String> ALL_CASE_USERS_SET                   = createUserSet (new List<Set<String>> { ALL_REGIONALLY_DEFINED_USERS_SET, ALL_CASE_OWNERS_SET, ALL_CASE_MANAGERS_SET, ALL_QUALITY_CASE_USERS_SET  }); 
    
    static
    {
        if ((CASE_TASK_USERROLES_BY_ROLENAME_MAP == null) || (CASE_TASK_USER_BY_SHIFT_ROLENAME_MAP == null) || (STANDARD_USERROLES_BY_ROLENAME_MAP == null))
        {
            System.runAs(TEST_DummyUserFactory.SETUP_DATA_CREATION_USER)
            {
                if (User_Lookup_Mapping__c.getInstance(ECICCommonConstants.COUNTRY_CODE_DEFAULT) == null)
                {
                  TEST_DummyUserLookUpMappingFactory.create (ECICCommonConstants.COUNTRY_CODE_DEFAULT, TEST_DummyInsertModeEnum.REAL);
                } 

                if (CASE_TASK_USERROLES_BY_ROLENAME_MAP  == null) { CASE_TASK_USERROLES_BY_ROLENAME_MAP  = createRoleHierarchy();                    }
                if (CASE_TASK_USER_BY_SHIFT_ROLENAME_MAP == null) { CASE_TASK_USER_BY_SHIFT_ROLENAME_MAP = createCaseTaskUserMap();                  }
                if (STANDARD_USERROLES_BY_ROLENAME_MAP   == null) { STANDARD_USERROLES_BY_ROLENAME_MAP   = SEPUserRoleCache.getUserRolesByNameMap(); }
            }
        }
    }

    private static Set<String> createUserSet(List<Set<String>> userSetList)
    {
        Set<String> completeUserSet = new Set<String>();
        for (Set<String> userSet : userSetList) {  completeUserSet.addAll(userSet); }
        return completeUserSet;
    }

    private static Map<String,UserRole> createRoleHierarchy()
    {
        List<UserRole> userRoleList = new List<UserRole>();
        for (String lookupUserName : ALL_CUSTOM_SETTINGS_LOOKUP_USERS_SET)
        {
            String devName = lookupUserName.left(lookupUserName.length()-3);
            userRoleList.add(new UserRole(name=lookupUserName, developerName=devName ));            
        }
        try { insert userRoleList; }
        catch (DmlException ex) {}                                                          // Roles already exists; needn't reinsert.
        
        Map<String,UserRole> userRoleMap = new Map<String,UserRole>();
        for (UserRole userRole : userRoleList) { userRoleMap.put(userRole.Name, userRole); }
        return userRoleMap;
    }

    private static Map<String, User> createCaseTaskUserMap() 
    {
        Map<String, User> caseTaskUserMap = new Map<String, User>();
        for (String caseRoleString : ALL_CASE_USERS_SET)
        {
            caseTaskUserMap.put(USER_SHIFT_ORIGINAL    + '_' + caseRoleString, createCaseTaskUser(USER_SHIFT_ORIGINAL,    caseRoleString));
            caseTaskUserMap.put(USER_SHIFT_REPLACEMENT + '_' + caseRoleString, createCaseTaskUser(USER_SHIFT_REPLACEMENT, caseRoleString));
        }       
        try { insert caseTaskUserMap.values(); }
        catch (DmlException ex){}                                                           // Users already exists; needn't reinsert.
        
        return caseTaskUserMap;
    }

    
    private static  User createCaseTaskUser(String shift, String caseRoleString)
    {
    	
    	TEST_UniqueHelper uniqueHelper = new TEST_UniqueHelper(shift + '_' + caseRoleString);
    	
    	TEST_DummyUserFactory.Config userConfig = new TEST_DummyUserFactory.Config();
    	                             userConfig.username          = uniqueHelper.uniqueSpaceless + '@example.com';
    	                             userConfig.lastName          = uniqueHelper.uniqueString;
    	                             userConfig.email             = uniqueHelper.uniqueSpaceless + '@example.com';
    	                             userConfig.alias             = shift.left(1) +       caseRoleString.left(3)+ ('' + uniqueHelper.uniqueInt).left(4);
    	                             userConfig.communityNickname = shift.left(5) + '_' + caseRoleString.left(34);
                                     userConfig.countryCode       = COUNTRY_CODE;
                                     userConfig.isActive          = true; 
                                     userConfig.profileId         = STANDARD_PROFILE_ID;
                                     userConfig.userRoleId        = ((shift == USER_SHIFT_ORIGINAL) && (CASE_TASK_USERROLES_BY_ROLENAME_MAP.keySet().contains(caseRoleString)))
                                                                            ? CASE_TASK_USERROLES_BY_ROLENAME_MAP.get(caseRoleString).id
                                                                            : null;
    	                             
        return TEST_DummyUserFactory.create (userConfig, TEST_DummyInsertModeEnum.NONE);
    }
    
    public static void updateUserLookupMapping()
    {
        List<User> usersToUpdateList = new List<User>();
        for (String caseRoleString: ALL_CUSTOM_SETTINGS_LOOKUP_USERS_SET)
        {
            usersToUpdateList.add(prepareUserUpdate (USER_SHIFT_ORIGINAL,    caseRoleString, ECICCommonConstants.ROLE_CIC_IBERIA_SERVICE_MANAGER));
            usersToUpdateList.add(prepareUserUpdate (USER_SHIFT_REPLACEMENT, caseRoleString, caseRoleString));
        }
        System.runAs(TEST_DummyUserFactory.SETUP_DATA_CREATION_USER) { update usersToUpdateList; }
    }
    
    private static User prepareUserUpdate (String shiftString, String caseRoleString, String targetRoleString)
    {
            User   user = CASE_TASK_USER_BY_SHIFT_ROLENAME_MAP.get(shiftString + '_' + caseRoleString);
                   user.UserRoleId = STANDARD_USERROLES_BY_ROLENAME_MAP.get(targetRoleString).id;
            return user;
    }
    
    public static User get(String regionType, String shift, String role)
    {
        return CASE_TASK_USER_BY_SHIFT_ROLENAME_MAP.get( shift + '_' + regionType + '_' + role + '__c' );
    }
}