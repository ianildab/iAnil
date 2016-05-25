@isTest
private class ECICCaseTriggerUserCacheTest 
{
    public static final User TEST_RUN_USER = ECICRunUserTestHelper.create();

    private static testMethod void getUserByIdMapTest()
    {
    	ECICCaseTriggerUserCache.userByIdCache.put (TEST_RUN_USER.id, TEST_RUN_USER);
    	
    	Map<Id, User> resultUserByIdMap = null;
    	System.runAs(TEST_RUN_USER)
    	{
    		Test.startTest();
    		{
    			resultUserByIdMap = ECICCaseTriggerUserCache.getUserByIdMap();	
    		}
    		Test.stopTest();
    	}
    	
    	System.assert(resultUserByIdMap.containsKey(TEST_RUN_USER.id));
    	System.assertEquals (TEST_RUN_USER.profile.name, resultUserByIdMap.get(TEST_RUN_USER.id).profile.name);
    }

    private static testMethod void getBottlerUserByIdMapTest()
    {
    	ECICCaseTriggerUserCache.activeBottlerUserByIdCache.put (TEST_RUN_USER.id, TEST_RUN_USER);
    	
    	Map<Id, User> resultUserByIdMap = null;
    	System.runAs(TEST_RUN_USER)
    	{
    		Test.startTest();
    		{
    			resultUserByIdMap = ECICCaseTriggerUserCache.getBottlerUserByIdMap();	
    		}
    		Test.stopTest();
    	}
    	
    	System.assert(resultUserByIdMap.containsKey(TEST_RUN_USER.id));
    	System.assertEquals (TEST_RUN_USER.profile.name, resultUserByIdMap.get(TEST_RUN_USER.id).profile.name);
    }

    private static testMethod void activeUserIdByUserRoleDeveloperNameCache()
    {
    	UserRole dummyUserRole 		= [SELECT developerName FROM UserRole WHERE id = :TEST_RUN_USER.userRoleId LIMIT 1];
    	String   dummyDeveloperName = dummyUserRole.developerName;
    	ECICCaseTriggerUserCache.activeUserIdByUserRoleDeveloperNameCache.put (dummyDeveloperName, TEST_RUN_USER.id);
    	
    	Map<String, Id> resultUserIdByUserRoleDeveloperNameMapping = null;
    	System.runAs(TEST_RUN_USER)
		{
    		Test.startTest();
    		{
    			resultUserIdByUserRoleDeveloperNameMapping = ECICCaseTriggerUserCache.getUserIdByUserRoleDeveloperNameMapping();	
    		}
    		Test.stopTest();
    	}
    	
    	System.assert(resultUserIdByUserRoleDeveloperNameMapping.containsKey(dummyDeveloperName));
    	System.assertEquals (TEST_RUN_USER.id, resultUserIdByUserRoleDeveloperNameMapping.get(dummyDeveloperName));
    }
    
    private static testMethod void selectOwnerAndCreatorIdSetTest()
    {
   		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
    	ECICCaseTestHelper.CaseConfig caseConfig = new ECICCaseTestHelper.CaseConfig();
    								  caseConfig.ownerId = TEST_RUN_USER.id;
    	Case dummyCase = ECICCaseTestHelper.createDummyCase(caseConfig, false);

    	Set<Id> resultOwnerIdSet = null;
    	System.runAs(TEST_RUN_USER)
		{
    		Test.startTest();
    		{
    			resultOwnerIdSet = ECICCaseTriggerUserCache.selectOwnerAndCreatorIdSet(new List<Case> { dummyCase } );	
    		}
    		Test.stopTest();
    	}
    	
    	System.assert(resultOwnerIdSet.contains(CaseConfig.ownerId));
    }

    private static testMethod void selectRoleNameSetTest()
    {
    	TEST_DummyUserLookUpMappingFactory.createDefaultList(ECICCommonConstants.COUNTRY_CODE_DEFAULT, TEST_DummyInsertModeEnum.REAL);

   		Set<String> resultRoleNameSet = null;
    	System.runAs(TEST_RUN_USER)
		{
    		Test.startTest();
    		{
    			resultRoleNameSet = ECICCaseTriggerUserCache.selectRoleNameSet();	
    		}
    		Test.stopTest();
    	}

		// Following assertions match current (2014/02/14) environment on DevBKess.  
        System.assert(resultRoleNameSet.contains(ECICCommonConstants.ROLE_IBERIA_CONSUMER_QUALITY_COMPLAINTS_MANAGER));
        System.assert(resultRoleNameSet.contains(ECICCommonConstants.ROLE_IBERIA_QUALITY_ADMINISTRATIVE_ASSISTANT));
        System.assert(resultRoleNameSet.contains(ECICCommonConstants.ROLE_IBERIA_QUALITY_AGENT));
        System.assert(resultRoleNameSet.contains(ECICCommonConstants.ROLE_IBERIA_QUALITY_MANAGER));
        System.assert(resultRoleNameSet.contains(ECICCommonConstants.ROLE_IBERIA_INFOLINE_SUPERVISOR));
    }

    private static testMethod void selectBottlerRoleIdSetTest()
    {
   		Set<Id> resultUserRoleIdSet = null;
    	System.runAs(TEST_RUN_USER)
		{
    		Test.startTest();
    		{
    			resultUserRoleIdSet = ECICCaseTriggerUserCache.selectBottlerRoleIdSet();	
    		}
    		Test.stopTest();
    	}

        Set<String> bottlerRoleNameSet = new Set<String>
        {
            ECICCommonConstants.ROLE_IBERIA_BOTTLER_EXTERNALS,
            ECICCommonConstants.ROLE_IBERIA_BOTTLER_QUALITY,
            ECICCommonConstants.ROLE_IBERIA_BOTTLER_QUALITY_MANAGER
        };
		Set<Id> 		  expectedUserRoleIdSet   = SEPUserRoleCache.getUserRoleByIdMap(bottlerRoleNameSet).keySet();
		assertSameMembers (expectedUserRoleIdSet, resultUserRoleIdSet);
    }
    
    private static void assertSameMembers (Set<Id> expectedIdSet, Set<Id> resultIdSet)
    {
    	for (Id id : expectedIdSet)  { System.assert (resultIdSet.contains(id));   }
    	for (Id id : resultIdSet)    { System.assert (expectedIdSet.contains(id)); }
    }

	private static testMethod void buildActiveUserIdByUserRoleDeveloperNameCacheTest()
	{
		User		  dummyUser			  		= [SELECT id, isActive, userRoleId, userRole.developerName FROM USER WHERE id = :TEST_RUN_USER.id LIMIT 1];
		Map<Id, User> dummyUserByIdMap 	  		= new Map<Id, User>{ dummyUser.id => dummyUser };
		String		  dummyRoleDeveloperName    = dummyUser.userRole.developerName;
		Set<String>   dummyRoleDeveloperNameSet = new Set<String>{ dummyRoleDeveloperName };

    	System.runAs(TEST_RUN_USER)
    	{
    		Test.startTest();
    		{
    			ECICCaseTriggerUserCache.buildActiveUserIdByUserRoleDeveloperNameCache(dummyUserByIdMap, dummyRoleDeveloperNameSet);
    		}
    		Test.stopTest();
    	}

		Map<String, Id> resultUserIdByUserRoleDeveloperNameMapping = ECICCaseTriggerUserCache.activeUserIdByUserRoleDeveloperNameCache;
    	System.assert(resultUserIdByUserRoleDeveloperNameMapping.containsKey(dummyRoleDeveloperName));
    	System.assertEquals (dummyUser.id, resultUserIdByUserRoleDeveloperNameMapping.get(dummyRoleDeveloperName));
	}

	private static testMethod void buildActiveBottlerUserByIdCacheTest()
	{
		User		  dummyUser			  = [SELECT id, isActive, userRoleId, userRole.developerName FROM USER WHERE id = :TEST_RUN_USER.id LIMIT 1];
		Map<Id, User> dummyUserByIdMap 	  = new Map<Id, User>{ dummyUser.id => dummyUser };
		Id	  	  	  dummyUserRoleId	  = dummyUser.userRoleId;

    	System.runAs(TEST_RUN_USER)
    	{
    		Test.startTest();
    		{
    			ECICCaseTriggerUserCache.buildActiveBottlerUserByIdCache(dummyUserByIdMap, new Set<Id>{ dummyUserRoleId  });
    		}
    		Test.stopTest();
    	}

		Map<Id, User> resultBottlerUserByIdMap = ECICCaseTriggerUserCache.activeBottlerUserByIdCache;
    	System.assert(resultBottlerUserByIdMap.containsKey(dummyUser.id));
    	System.assertEquals (dummyUser, resultBottlerUserByIdMap.get(dummyUser.id));
	}

    private static testMethod void populateForSetsTest()
    {
		User		dummyUser			      = [SELECT id, Name, isActive, Country_Code__c, Enabled_Countries__c, ProfileId, profile.name, userRoleId, userRole.developerName FROM USER WHERE id = :TEST_RUN_USER.id LIMIT 1];
    	String	    dummyRoleDeveloperName    = dummyUser.userRole.developerName;
    	Id 			dummyUserId		      	  = dummyUser.id; 
    	Set<Id> 	dummyOwnerIdSet		      = new Set<Id> 	 { dummyUser.id }; 
    	Set<String> dummyRoleDeveloperNameSet = new Set<String>  { dummyRoleDeveloperName }; 
    	Set<Id> 	dummyBottlerRoleIdSet     = new Set<Id> 	 { dummyUser.userRoleId };
    	
    	System.runAs(TEST_RUN_USER)
    	{
    		Test.startTest();
    		{
    			ECICCaseTriggerUserCache.populate (dummyUserId, dummyOwnerIdSet, dummyRoleDeveloperNameSet, dummyBottlerRoleIdSet);
    		}
    		Test.stopTest();
    	}

		Map<Id, User> resultUserByIdMap = ECICCaseTriggerUserCache.userByIdCache;
    	System.assert(resultUserByIdMap.containsKey(dummyUser.id));
    	System.assertEquals (dummyUser.profile.name, resultUserByIdMap.get(dummyUser.id).profile.name);

		Map<String, Id> resultUserIdByUserRoleDeveloperNameMapping = ECICCaseTriggerUserCache.activeUserIdByUserRoleDeveloperNameCache;
    	System.assert(resultUserIdByUserRoleDeveloperNameMapping.containsKey(dummyRoleDeveloperName));
    	// We can't assert any particular UserRole Developer Name corresponds to any particular UserId 
    	// without knowing both that the UserRole will have one and only one possible value in the environment.

		Map<Id, User> resultBottlerUserByIdMap = ECICCaseTriggerUserCache.activeBottlerUserByIdCache;
    	System.assert(resultBottlerUserByIdMap.containsKey(dummyUser.id));
    	System.assertEquals (dummyUser, resultBottlerUserByIdMap.get(dummyUser.id));
    }

    private static testMethod void populateTest()
    {
    	TEST_DummyUserLookUpMappingFactory.createDefaultList(ECICCommonConstants.COUNTRY_CODE_DEFAULT, TEST_DummyInsertModeEnum.REAL);
    	
    	ECICRunUserTestHelper.createList(
    	       new List<String[]>
    	       {
                    new String[]{'ESInfolineSupervisor',        ECICCommonConstants.PROFILE_ECIC_INFOLINE_SUPERVISOR,   ECICCommonConstants.ROLE_IBERIA_INFOLINE_SUPERVISOR,                    ECICCommonConstants.COUNTRY_CODE_DEFAULT},
                    new String[]{'ESKOQualityAgent',            ECICCommonConstants.PROFILE_ECIC_COCA_COLA_QUALITY,     ECICCommonConstants.ROLE_IBERIA_QUALITY_AGENT,                          ECICCommonConstants.COUNTRY_CODE_DEFAULT},
                    new String[]{'ESKOQualityManager',          ECICCommonConstants.PROFILE_ECIC_COCA_COLA_QUALITY,     ECICCommonConstants.ROLE_IBERIA_QUALITY_MANAGER,                        ECICCommonConstants.COUNTRY_CODE_DEFAULT},
                    new String[]{'QualityComplaintsManager',    ECICCommonConstants.PROFILE_ECIC_COCA_COLA_QUALITY,     ECICCommonConstants.ROLE_IBERIA_CONSUMER_QUALITY_COMPLAINTS_MANAGER,    ECICCommonConstants.COUNTRY_CODE_DEFAULT},
                    new String[]{'QualityAdminAssistant',       ECICCommonConstants.PROFILE_ECIC_COCA_COLA_QUALITY,     ECICCommonConstants.ROLE_IBERIA_QUALITY_ADMINISTRATIVE_ASSISTANT,       ECICCommonConstants.COUNTRY_CODE_DEFAULT}
    	       },
    	       true
    	   );
    	
    	TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
    	                     config.countryCode = ECICCommonConstants.COUNTRY_CODE_DEFAULT;
    	                     config.ownerId = TEST_RUN_USER.id;
    	Case dummyCase = TEST_DummyQualityComplaintCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE); 

    	System.runAs(TEST_RUN_USER)
    	{
    		Test.startTest();
    		{
    			ECICCaseTriggerUserCache.populate(new List<Case>{dummyCase});	
    		}
    		Test.stopTest();
    	}
    	
    	// Check ECICCaseTriggerUserCache.userByIdCache
	    	Map<Id, User> resultUserByIdMap = ECICCaseTriggerUserCache.userByIdCache;
	    	System.assert(resultUserByIdMap.containsKey(TEST_RUN_USER.id));
	
	    	Profile expectedProfile = [SELECT name FROM Profile WHERE id = :TEST_RUN_USER.profileId LIMIT 1];
	    	System.assertEquals (expectedProfile.name, resultUserByIdMap.get(TEST_RUN_USER.id).profile.name);
	
	    	UserRole expectedUserRole = [SELECT developerName FROM UserRole WHERE id = :TEST_RUN_USER.userRoleId LIMIT 1];
	    	System.assertEquals (expectedUserRole.developerName, resultUserByIdMap.get(TEST_RUN_USER.id).userRole.developerName);
    	
    	// Check ECICCaseTriggerUserCache.userByIdCache.activeUserIdByUserRoleDeveloperNameCache
			Set<String> resultRoleNameSet = ECICCaseTriggerUserCache.activeUserIdByUserRoleDeveloperNameCache.keySet();
	    	System.assert(resultRoleNameSet.contains(ECICCommonConstants.ROLE_IBERIA_CONSUMER_QUALITY_COMPLAINTS_MANAGER));
	    	System.assert(resultRoleNameSet.contains(ECICCommonConstants.ROLE_IBERIA_QUALITY_ADMINISTRATIVE_ASSISTANT));
	    	System.assert(resultRoleNameSet.contains(ECICCommonConstants.ROLE_IBERIA_QUALITY_AGENT));
	    	System.assert(resultRoleNameSet.contains(ECICCommonConstants.ROLE_IBERIA_QUALITY_MANAGER));
	    	System.assert(resultRoleNameSet.contains(ECICCommonConstants.ROLE_IBERIA_INFOLINE_SUPERVISOR));
	    	// We can't assert any particular UserRole Developer Name corresponds to any particular UserId 
	    	// without knowing both that the UserRole will have one and only one possible value in the environment.

		// TODO: A more elaborate test setup should allow us to check ECICCaseTriggerUserCache.activeBottlerUserByIdCache
		//		but for now we will trust the results of populateForSetsTest to ensure that this is correct
		//		as ultimately this funciton deligates building caches to that function.
    }
}