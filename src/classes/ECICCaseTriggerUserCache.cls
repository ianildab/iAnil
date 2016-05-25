public class ECICCaseTriggerUserCache 
{
	@testVisible private static Map<Id, User> userByIdCache = new Map<Id, User>();
	public  static Map<Id, User> getUserByIdMap() { return userByIdCache; }
	
	@testVisible private static Map<Id, User> activeBottlerUserByIdCache = new Map<Id, User>();
	public  static Map<Id, User> getBottlerUserByIdMap() { return activeBottlerUserByIdCache; }
	
	@testVisible private static Map<String, Id> activeUserIdByUserRoleDeveloperNameCache = new Map<String, Id>();
	// @return Role name to userId mapping based on user lookup mappings (in custom settings; for all supported countries).
	public  static Map<String, Id> getUserIdByUserRoleDeveloperNameMapping() { return activeUserIdByUserRoleDeveloperNameCache; }
	
	public static void populate (List<Case> currentCaseList)
	{
		Id			currentUserId        = UserInfo.getUserId();						// Collect value  required to fetch data for ECICCaseCountryCodeValidatorStrategy
		Set<Id> 	ownerAndCreatorIdSet = selectOwnerAndCreatorIdSet(currentCaseList);	// Collect values required to fetch data for ECICCaseCountryCodeSetterStrategy and ECICCaseInfolineStatusSetterStrategy
		Set<String> roleNameSet	   	 = selectRoleNameSet();					// Collect values required to fetch data for ECICCaseMulSetterStrategy
		Set<Id> 	bottlerRoleIdSet = selectBottlerRoleIdSet();			// Collect values required to fetch data for ECICCaseQComplBottlerUserSetterStrategy
        populate (currentUserId, ownerAndCreatorIdSet, roleNameSet, bottlerRoleIdSet);
	}
	
	@testVisible private static void populate (Id currentUserId, Set<Id> ownerAndCreatorIdSet, Set<String> roleNameSet, Set<Id> bottlerRoleIdSet)
	{
		Map<Id, User> userByIdMap = new Map<Id, User>([
														SELECT id, Name, isActive, Country_Code__c, Enabled_Countries__c, ProfileId, profile.name, userRoleId, userRole.developerName 
														FROM User 
														WHERE  (id = :currentUserId) 
															OR (id IN :ownerAndCreatorIdSet)
															OR ((isActive = true) AND (userRole.developerName IN :roleNameSet))
															OR ((isActive = true) AND (userRoleId 			  IN :bottlerRoleIdSet))
													  ]);
		userByIdCache.putAll (userByIdMap);
		buildActiveUserIdByUserRoleDeveloperNameCache(userByIdMap, roleNameSet);
		buildActiveBottlerUserByIdCache (userByIdMap, bottlerRoleIdSet);
	}

	@testVisible private static Set<Id> selectOwnerAndCreatorIdSet(List<Case> currentCaseList)
	{
		Set<Id> ownerAndCreatorIdSet = new Set<Id>();
		for (Case currentCase : currentCaseList)
		 { 
		 	// Collects "CreatedById" if the Owner is not a User (e.g. it is a Queue)
		 	ID userId = ECICCaseHelper.isUserId(currentCase.OwnerId) ? currentCase.OwnerId : currentCase.createdById;	
		 	ownerAndCreatorIdSet.add(userId); 
		 } 
		return ownerAndCreatorIdSet;
	}

	@testVisible private static Set<Id> selectBottlerRoleIdSet()
	{
        return SEPUserRoleCache.getUserRoleByIdMap(new Set<String>
	        {
	            ECICCommonConstants.ROLE_IBERIA_BOTTLER_EXTERNALS,
	            ECICCommonConstants.ROLE_IBERIA_BOTTLER_QUALITY,
	            ECICCommonConstants.ROLE_IBERIA_BOTTLER_QUALITY_MANAGER
	        }
        ).keySet();
	}

	@testVisible private static Set<String> selectRoleNameSet()
	{
        User_Lookup_Mapping__c[] userLookupMappingsArray = User_Lookup_Mapping__c.getAll().values();	// Get roles from mapping of all countries
	        Set<String> roleNameSet = new Set<String>();
		        for (User_Lookup_Mapping__c mapping : userLookupMappingsArray) 
		        {
		            for (String mappedRoleField : ECICCommonConstants.USER_FIELDS) 
		            {
		                String roleName = (String)mapping.get(mappedRoleField);
		                if (roleName != null) { roleNameSet.add(roleName); }
		            }
		        }
		return roleNameSet;
	}

	@testVisible private static void buildActiveBottlerUserByIdCache(Map<Id, User> userByIdMap, Set<Id> bottlerRoleIdSet)
	{
		Map<Id, User> activeBottlerUserByIdMap = new Map<Id, User>();
		for (User user : userByIdMap.values())
		{
			if ((user.IsActive) && (bottlerRoleIdSet.contains(user.UserRoleId)))
			{
				activeBottlerUserByIdMap.put(user.id, user);
			}
		}
		activeBottlerUserByIdCache.putAll (activeBottlerUserByIdMap);
	}
	
	@testVisible private static void buildActiveUserIdByUserRoleDeveloperNameCache(Map<Id, User> userByIdMap, Set<String> roleNameSet)
	{
		Map<String, Id> activeUserIdByUserRoleDeveloperNameMap = new Map<String, Id>();
		for (User user : userByIdMap.values())
		{
			if ((user.IsActive) && (user.UserRoleId != null) && roleNameSet.contains(user.userRole.developerName))
			{
				// NOTE: handling multiple users in the same role is not supported (no info how to deal with that situation)
				activeUserIdByUserRoleDeveloperNameMap.put(user.userRole.developerName, user.id);
		}
		}
		activeUserIdByUserRoleDeveloperNameCache.putAll (activeUserIdByUserRoleDeveloperNameMap);
	}
	
}