public class ECICUserDao {
    
    public static User findById(ID id) {
        return (User)getFirstResult([SELECT id, Name, Country_Code__c, Enabled_Countries__c, ProfileId
                                      FROM User 
                                      WHERE id = :id]);
    }
    
    public static Map<ID, User> findByIds(Set<ID> ids) {
        return new Map<ID, User>([SELECT id, Name, Country_Code__c, Enabled_Countries__c, ProfileId
                                    FROM User 
                                    WHERE id IN :ids]);
    }
    
    public static Set<ID> filterActiveUsers(Set<ID> userIds) {
        Map<ID, User> result = new Map<ID, User>([SELECT id, Country_Code__c, Enabled_Countries__c FROM User WHERE isActive = true AND id IN :userIds]);
        return result.keySet(); 
    }
    
    /**
     * Find 1 active user for each provided role name
     */
    public static Map<String, User> findActiveByRoleNames(List<String> roleNames) {
        Map<String, User> result = new Map<String, User>();
        
        User[] users = [SELECT ID, UserRole.DeveloperName, Country_Code__c, Enabled_Countries__c, ProfileId 
                            FROM User 
                            WHERE isActive = true 
                                AND UserRole.DeveloperName IN :roleNames];

        for (User user : users) {
            if (! result.containsKey(user.UserRole.DeveloperName)) {
                result.put(user.UserRole.DeveloperName, user);
            }
        }
                                            
        return result;
    }
    
    public static Map<String, User> findAllFirstActiveByProfileNameAndCountryCode(String profileName, Set<String> countryCodes) {
        Map<String, User> result = new Map<String, User>();
        Set<String> profileNames = new Set<String> {ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_SUPERVISOR,
                                                    ECICCommonConstants.PROFILE_ECIC_NWEN_INFOLINE_SUPERVISOR,ECICCommonConstants.PROFILE_ECIC_GERMANY_INFOLINE_SUPERVISOR};
        
        User[] users = [SELECT ID, Profile.name, Country_Code__c, Enabled_Countries__c, ProfileId 
                            FROM User 
                            WHERE isActive = true 
                                AND Profile.name IN :profileNames
                                AND Country_Code__c IN :countryCodes
                            ORDER BY CreatedDate DESC];
                            
        for (User user : users) {
            if (! result.containsKey(user.Country_Code__c)) {
                result.put(user.Country_Code__c, user);
            }
        }
                                            
        return result;
    }

    private static SObject getFirstResult(SObject[] resultList) {
        return (! resultList.isEmpty()) ? resultList.get(0) : null;
    }
}