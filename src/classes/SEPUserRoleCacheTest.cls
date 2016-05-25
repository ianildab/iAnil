@isTest
private class SEPUserRoleCacheTest 
{
    private static final User   TEST_RUN_USER       = TEST_DummyUserFactory.createDefaultTestRunUser();

    private static testMethod void makeUserRoleCachesTest()
    { 
    	UserRole dummyUserRole = TEST_DummyUserRoleFactory.create (TEST_DummyInsertModeEnum.REAL);

        List<Map<String,UserRole>> resultUserRoleByKeyMapList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultUserRoleByKeyMapList = SEPUserRoleCache.makeUserRoleCaches();
            }
            Test.stopTest();
        } 

        Map<String,UserRole> resultUserRoleByIdAsStringMap  = resultUserRoleByKeyMapList[0];
        assertUserRoleCache(dummyUserRole, (String) dummyUserRole.id,   resultUserRoleByIdAsStringMap);

        Map<String,UserRole> resultUserRoleByNameMap        = resultUserRoleByKeyMapList[1];
        assertUserRoleCache(dummyUserRole, dummyUserRole.name,          resultUserRoleByNameMap);
        assertUserRoleCache(dummyUserRole, dummyUserRole.developerName, resultUserRoleByNameMap);

        Map<String,UserRole> resultUserRoleByDevNameMap     = resultUserRoleByKeyMapList[2];
        assertUserRoleCache(dummyUserRole, dummyUserRole.developerName, resultUserRoleByDevNameMap);
    }
    
    // --------------------------------------------------------------------------------------------------
    
    private static testMethod void getUserRolesByIdMapTests()
    { 
        UserRole dummyUserRole = TEST_DummyUserRoleFactory.create (TEST_DummyInsertModeEnum.MOCK);
        SEPUserRoleCache.USER_ROLES_BY_ID_CACHE.put (dummyUserRole.id, dummyUserRole);

        Map<Id,UserRole> resultUserRoleByIdMap = null;
        UserRole         resultUserRole        = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultUserRoleByIdMap = SEPUserRoleCache.getUserRolesByIdMap();
                resultUserRole        = SEPUserRoleCache.get(dummyUserRole.id);
            }
            Test.stopTest();
        } 

        assertUserRoleCache(dummyUserRole, dummyUserRole.id,   resultUserRoleByIdMap);
        assertUserRole     (dummyUserRole, resultUserRole);
    }
    
    // --------------------------------------------------------------------------------------------------
    
    private static testMethod void getUserRolesByNameMapTests()
    { 
        UserRole dummyUserRole = TEST_DummyUserRoleFactory.create (TEST_DummyInsertModeEnum.MOCK);
        SEPUserRoleCache.USER_ROLES_BY_NAME_CACHE.put (dummyUserRole.name, dummyUserRole);

        Map<String,UserRole> resultUserRoleByNameMap = null;
        UserRole             resultUserRole          = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultUserRoleByNameMap = SEPUserRoleCache.getUserRolesByNameMap();
                resultUserRole          = SEPUserRoleCache.get(dummyUserRole.name);
            }
            Test.stopTest();
        } 

        assertUserRoleCache(dummyUserRole, dummyUserRole.name,   resultUserRoleByNameMap);
        assertUserRole     (dummyUserRole, resultUserRole);
    }
    
    // --------------------------------------------------------------------------------------------------
    
    private static testMethod void getUserRolesByDevNameMapTests()
    { 
        UserRole dummyUserRole = TEST_DummyUserRoleFactory.create (TEST_DummyInsertModeEnum.MOCK);
        SEPUserRoleCache.USER_ROLES_BY_DEVELOPER_NAME_CACHE.put (dummyUserRole.developerName, dummyUserRole);

        Map<String,UserRole> resultUserRoleByNameMap = null;
        UserRole             resultUserRole          = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultUserRoleByNameMap = SEPUserRoleCache.getUserRolesByDevNameMap();
                resultUserRole          = SEPUserRoleCache.getByDevName(dummyUserRole.developerName);
            }
            Test.stopTest();
        } 

        assertUserRoleCache(dummyUserRole, dummyUserRole.developerName,   resultUserRoleByNameMap);
        assertUserRole     (dummyUserRole, resultUserRole);
    }

    // --------------------------------------------------------------------------------------------------
    
    private static void getUserRoleByIdMapTest(Boolean isNamedRoleInCache)
    { 
    	UserRole dummyUserRole = TEST_DummyUserRoleFactory.create (TEST_DummyInsertModeEnum.MOCK);
    	if (isNamedRoleInCache) { SEPUserRoleCache.USER_ROLES_BY_DEVELOPER_NAME_CACHE.put (dummyUserRole.developerName, dummyUserRole); }

        Map<Id,UserRole> resultUserRoleByIdMap = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultUserRoleByIdMap = SEPUserRoleCache.getUserRoleByIdMap(new Set<String>{ dummyUserRole.developerName });
            }
            Test.stopTest();
        } 

        if (isNamedRoleInCache) { assertUserRoleCache(dummyUserRole, dummyUserRole.id,   resultUserRoleByIdMap); }
        else                    { System.assert (!resultUserRoleByIdMap.containsKey(dummyUserRole.id));           }
    }

    private static testMethod void notInCacheGetUserRoleByIdMapTest() { getUserRoleByIdMapTest(false); }
    private static testMethod void inCacheGetUserRoleByIdMapTest()    { getUserRoleByIdMapTest(true);  }
    
    // --------------------------------------------------------------------------------------------------
    
    private static void getNameLikeByIdMapTest(Boolean isLikeNameInCache)
    { 
    	String matchingPart = 'MATCHING_PART';
    	TEST_DummyUserRoleFactory.Config config = new TEST_DummyUserRoleFactory.Config();
    	                                 config.name = 'Dummy ' + (isLikeNameInCache ? matchingPart : '') + 'User Role';
        UserRole dummyUserRole = TEST_DummyUserRoleFactory.create (config, TEST_DummyInsertModeEnum.MOCK);
        if (isLikeNameInCache) { SEPUserRoleCache.USER_ROLES_BY_ID_CACHE.put (dummyUserRole.id, dummyUserRole); }

        Map<Id,UserRole> resultUserRoleByIdMap = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultUserRoleByIdMap = SEPUserRoleCache.getNameLikeByIdMap(matchingPart);
            }
            Test.stopTest();
        } 

        if (isLikeNameInCache) { assertUserRoleCache(dummyUserRole, dummyUserRole.id,   resultUserRoleByIdMap); }
        else                   { System.assert (!resultUserRoleByIdMap.containsKey(dummyUserRole.id));          }
    }

    private static testMethod void notInCacheGetNameLikeByIdMapTest() { getNameLikeByIdMapTest(false); }
    private static testMethod void inCacheGetNameLikeByIdMapTest()    { getNameLikeByIdMapTest(true);  }
    
    // --------------------------------------------------------------------------------------------------

    private static void assertUserRoleCache (UserRole dummyUserRole, Id key, Map<Id, UserRole> userRoleByKeyMap)
    {
        System.assert(userRoleByKeyMap.containsKey(key));
        assertUserRole(dummyUserRole, userRoleByKeyMap.get(key));
    }
    
    private static void assertUserRoleCache (UserRole dummyUserRole, String key, Map<String,UserRole> userRoleByKeyMap)
    {
        System.assert(userRoleByKeyMap.containsKey(key));
        assertUserRole(dummyUserRole, userRoleByKeyMap.get(key));
    }

    private static void assertUserRole(UserRole dummyUserRole, UserRole resultUserRole)
    {
        System.assertEquals (dummyUserRole.id,            resultUserRole.id);
        System.assertEquals (dummyUserRole.name,          resultUserRole.name);
        System.assertEquals (dummyUserRole.developerName, resultUserRole.developerName);
    }
    
    
}