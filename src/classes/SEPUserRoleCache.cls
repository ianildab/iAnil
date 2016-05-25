public class SEPUserRoleCache 
{
	
	@testVisible private static final Map<Id,UserRole> 	    USER_ROLES_BY_ID_CACHE				= null;
	@testVisible private static final Map<String,UserRole>  USER_ROLES_BY_NAME_CACHE  			= null;
        @testVisible private static final Map<String,UserRole>  USER_ROLES_BY_DEVELOPER_NAME_CACHE  = null;
	
	static  
	{
		if ((USER_ROLES_BY_ID_CACHE == null) || (USER_ROLES_BY_ID_CACHE.isEmpty()))  
		{ 
			List<Map<String,UserRole>> userRoleMapList = makeUserRoleCaches(); 
			USER_ROLES_BY_ID_CACHE 				= ECICMapHelper.castStringMapToIdMap(userRoleMapList[0]); 
			USER_ROLES_BY_NAME_CACHE 			= userRoleMapList[1];
			USER_ROLES_BY_DEVELOPER_NAME_CACHE 	= userRoleMapList[2];
		}
	}

	public static List<Map<String,UserRole>> makeUserRoleCaches()
	{
		List<Map<String,UserRole>> userRoleMapList = new List<Map<String,UserRole>>
		{
			new Map<String,UserRole>(),
			new Map<String,UserRole>(),
			new Map<String,UserRole>()
		};
	
	    for (UserRole UserRole : [SELECT id, name, developerName FROM UserRole]) 		
	    {  														
	        {													
	            userRoleMapList[0].put(UserRole.id,UserRole);	
	            userRoleMapList[1].put(UserRole.name,UserRole);	
	            userRoleMapList[1].put(UserRole.developerName,UserRole);	
	            userRoleMapList[2].put(UserRole.developerName,UserRole);	
	        }
	    }
	    return userRoleMapList;
	}
	
	public static Map<Id,UserRole> 	    getUserRolesByIdMap() 	  	 { return USER_ROLES_BY_ID_CACHE;   	 }
	public static Map<String, UserRole> getUserRolesByNameMap()   	 { return USER_ROLES_BY_NAME_CACHE; 	 }
	public static Map<String, UserRole> getUserRolesByDevNameMap()   { return USER_ROLES_BY_DEVELOPER_NAME_CACHE; }

	public static UserRole get (Id     UserRoleId)   				 { return USER_ROLES_BY_ID_CACHE.get(UserRoleId);         }
	public static UserRole get (String UserRoleName) 		  		 { return USER_ROLES_BY_NAME_CACHE.get(UserRoleName);     }
	public static UserRole getByDevName (String UserRoleName) 	     { return USER_ROLES_BY_DEVELOPER_NAME_CACHE.get(UserRoleName);  }
	
    public static Map<Id, UserRole> getUserRoleByIdMap (Set<String> targetNameSet)
	{
		Map<Id, UserRole> roleByIdMap = new Map<Id, UserRole>();
		for (String targetName : targetNameSet)
		{
			UserRole targetRole = USER_ROLES_BY_DEVELOPER_NAME_CACHE.get(targetName);
		    if (targetRole != null) { roleByIdMap.put(targetRole.id, targetRole); } 	
		}
		return roleByIdMap;
	}
	
	public static Map<Id, UserRole> getNameLikeByIdMap (String targetName)
	{
		Map<Id, UserRole> nameLikeByIdMap = new Map<Id, UserRole>();
		for (Id userRoleId : USER_ROLES_BY_ID_CACHE.keySet())
		{
			if (USER_ROLES_BY_ID_CACHE.get(userRoleId).name.contains(targetName))
			{
				nameLikeByIdMap.put(userRoleId, USER_ROLES_BY_ID_CACHE.get(userRoleId));
			}
		}
		return nameLikeByIdMap;
	}
}