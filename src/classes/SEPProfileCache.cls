public class SEPProfileCache 
{
	
	private static Map<Id,Profile> 		PROFILES_BY_ID_CACHE		= null;
	private static Map<String,Profile>  PROFILES_BY_NAME_CACHE  	= null;
	
	static  
	{
		if ((PROFILES_BY_ID_CACHE == null) || (PROFILES_BY_ID_CACHE.isEmpty()))  
	{
			List<Map<String,Profile>> profileMapList = makeProfileCaches(); 
			PROFILES_BY_ID_CACHE   = ECICMapHelper.castStringMapToIdMap(profileMapList[0]); 
			PROFILES_BY_NAME_CACHE 	 = profileMapList[1];
		}
	}

	public static List<Map<String,Profile>>  makeProfileCaches()
	{
		List<Map<String,Profile>> profileMapList = new List<Map<String,Profile>>
		{
			new Map<String,Profile>(),
			new Map<String,Profile>()
		};

		    for (Profile profile : [SELECT Id, Name FROM Profile]) 		
		    {  														
		        {													
            	profileMapList[0].put(profile.id,Profile);	
            	profileMapList[1].put(profile.name,Profile);	
		    }
		}
		return profileMapList;
		}
	
	public static Map<Id,Profile> 	   getProfilesByIdMap() 	{ return PROFILES_BY_ID_CACHE;   }
	public static Map<String, Profile> getProfilesByNameMap()   { return PROFILES_BY_NAME_CACHE; }

	public static Profile get (Id profileId)       { return PROFILES_BY_ID_CACHE.get(profileId);        }
	public static Profile get (String profileName) { return PROFILES_BY_NAME_CACHE.get(profileName);    }

	public static Boolean isUserAdmin(Id profileId) { return (PROFILES_BY_ID_CACHE.get(profileId).name == ECICCommonConstants.PROFILE_SYSTEM_ADMIN); }
	public static Boolean isUserAdmin() 				{ return isUserAdmin(UserInfo.getProfileId()); }
	public static Boolean isUserAdmin(Profile profile)	{ return isUserAdmin(profile.id); }
	public static Boolean isUserAdmin(User    user)		{ return isUserAdmin(user.profileId); }
}