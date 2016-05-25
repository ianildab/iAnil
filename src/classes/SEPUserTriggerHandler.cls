public /*with sharing*/ class SEPUserTriggerHandler extends SEPTriggerHandlerAbstract {

    public SEPUserTriggerHandler (boolean isTriggerExecuting){
        super(isTriggerExecuting);
    }

    public override void OnBeforeInsert(List<sObject> newValues){
        updateTemplateImageFields(newValues, null);
    }

    public override void OnBeforeUpdate(List<sObject> oldValues, List<sObject> newValues, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap){
        updateTemplateImageFields((List<User>)newValues, (Map<ID, User>)oldValuesMap);
    }
    
    public override void OnAfterUpdate(List<sObject> oldValues, List<sObject> newValues, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap){
        processAfterUpdate( (List<User>)newValues, (Map<ID, User>)oldValuesMap );
    }
    
    private static void processAfterUpdate(List<User> newUsers, Map<ID, User> oldUsersMap) {
        
        Set<ID> deactivatedUserIds = new Set<ID>();
        Map<ID, ID> userIdToRoleIdMapping = new Map<ID, ID>();

        for (User newUser : newUsers) {
            User oldUser = oldUsersMap.get(newUser.id);
            
            if (newUser.isActive != oldUser.isActive) { // Check for active status
                if (newUser.isActive) {
                    // User activated.
                    // RUL: Do nothing. We don't have information.
                    // MUL: update Cases with the user's role
                    userIdToRoleIdMapping.put(newUser.id, newUser.UserRoleId);
                } else {
                    // User deactivated
                    // Remove from RUL (Regions), MUL (Cases)
                    deactivatedUserIds.add(newUser.id);
                }
            } else if (newUser.isActive
                        && newUser.UserRoleId != oldUser.UserRoleId) { // Check for role change of an active user
                userIdToRoleIdMapping.put(newUser.id, newUser.UserRoleId); // MUL fields with role to set
            }
        }
        
        System.debug('CIC: user ids to deactivate: ' + deactivatedUserIds);
        System.debug('CIC: user roles to set: ' + userIdToRoleIdMapping);
        
        if (! deactivatedUserIds.isEmpty()
            || ! userIdToRoleIdMapping.isEmpty()) {

            updateUserLookupsInCases(deactivatedUserIds, userIdToRoleIdMapping);
        }
        
        if (! deactivatedUserIds.isEmpty()) {
            clearUsersInRegions(deactivatedUserIds);
        }
    }

  /*
   * Update Case RUL and MUL fields.
   */
    @future
    private static void updateUserLookupsInCases(Set<ID> deactivatedUserIds, Map<ID, ID> userIdToRoleIdMapping) {
        
        Map<String, ID> roleNameToRoleIdMapping = createRoleNameToRoleIdMapping(userIdToRoleIdMapping.values());
         
        Set<ID> searchForUserIds = new Set<ID>();
        searchForUserIds.addAll(deactivatedUserIds);
        searchForUserIds.addAll(userIdToRoleIdMapping.keySet());
        
        List<Case> cases = ECICCaseDao.findNotClosedByRegionAndMappedUserFields(searchForUserIds);
        
        for (Case currentCase : cases) {
          
            if (ECICCaseQualityComplaintRecordTypeHelper.isQualityComplaint(currentCase.RecordTypeID)) {
                currentCase.No_Quality_Status_Change__c = true; // NOTE: to avoid validation exception on this field
            }

      clearCaseRULFields(currentCase, deactivatedUserIds);
      updateCaseMULFields(currentCase, deactivatedUserIds, userIdToRoleIdMapping, roleNameToRoleIdMapping);
        }
        
        update cases;
    }
    
  /*
   * Clear Case RUL fields.
   * (ECICRegionTrigger should take care about this but it result in record locking issues with ECICCaseTrigger.)
   */
    private static void clearCaseRULFields(Case currentCase, Set<ID> deactivatedUserIds) {
      
    for (String userField : ECICCommonConstants.REGION_USER_FIELDS) {
        ID userId = (ID)currentCase.get(userField);
        
        if (userId != null
          && deactivatedUserIds.contains(userId)) {
                    
              currentCase.put(userField, null); // remove user from lookup
              System.debug('----- User ['+userId+'] removed from Case ['+currentCase.id+'] field ['+userField+']');
          }
    }
    }
    
    /*
     * Clear deactivated user from Case MUL field.
     * Set active user in empty Case MUL field if user's Role matches
     */
    private static void updateCaseMULFields(Case currentCase, Set<ID> deactivatedUserIds, Map<ID, ID> userIdToRoleIdMapping, Map<String, ID> roleNameToRoleIdMapping) {
        User_Lookup_Mapping__c mapping = User_Lookup_Mapping__c.getValues(currentCase.country_code__c);
        
        for (String mappedUserField : ECICCommonConstants.USER_FIELDS) {
            ID mappedUserId = (ID)currentCase.get(mappedUserField);
            
            if (mappedUserId != null) {
                if (deactivatedUserIds.contains(mappedUserId) 
                    || userIdToRoleIdMapping.containsKey(mappedUserId)) {
                        
                    currentCase.put(mappedUserField, null); // remove user from MUL lookup
                }
            } else { // put a user in the empty lookup field if found one with the requested role
                if (mapping != null) {
                    String requestedRoleName = (String)mapping.get(mappedUserField);
                    ID requestedRoleId = roleNameToRoleIdMapping.get(requestedRoleName);
                    
                    if (requestedRoleId != null) {
                        // find a user (ID) who has this role (requestedRoleId)
                        ID userInRole = findUserIdByRoleId(requestedRoleId, userIdToRoleIdMapping);

                        if (userInRole != null) {
                            currentCase.put(mappedUserField, userInRole);
                        }
                        
                    } else {
                        System.debug(LoggingLevel.WARN, 'User Mapping Lookup for country [' + currentCase.country_code__c + '] misses entry for field [' + mappedUserField + ']');
                    }
                } else {
                    System.debug(LoggingLevel.WARN, 'User Mapping Lookup for country [' + currentCase.country_code__c + '] NOT found!');
                }
            }
        }
    }
    
    private static ID findUserIdByRoleId(ID requestedRoleId, Map<ID, ID> userIdToRoleIdMapping) {
      ID result = null; // user ID
      
    for (ID userId : userIdToRoleIdMapping.keySet()) {
        ID roleId = (ID)userIdToRoleIdMapping.get(userId);
    
        if (roleId == requestedRoleId) {
            result = userId;
            break;
        }
    }
    
    return result;
    }

    private static Map<String, ID> createRoleNameToRoleIdMapping(List<ID> roleIds) {
        Map<String, ID> result = new Map<String, ID>();
        
        List<UserRole> roles = [SELECT ID, DeveloperName FROM UserRole WHERE id IN :roleIds];
        
        for (UserRole role : roles) {
            if (role.DeveloperName != null) // can it be possible?...
            result.put(role.DeveloperName, role.ID);
        }
        
        return result;
    }

  /*
   * Remove deactivated users in Regions
   */
    @future
    private static void clearUsersInRegions(Set<ID> deactivatedUserIds) {        
        List<Region__c> regions = ECICRegionDao.findByBottlerFields(deactivatedUserIds);
        
        for (Region__c region : regions) {
            for (String bottlerFieldName : ECICCommonConstants.BOTTLER_FIELDS) {
                Id bottlerUserId = (Id) region.get(bottlerFieldName);
                
                if (/*userLookupID == null || */ deactivatedUserIds.contains(bottlerUserId)) {
                    region.put(bottlerFieldName, null); // remove user from the bottler field
                }
            }
        }
        
        update regions;
    }
    
    private void updateTemplateImageFields(List<User> newUsers, Map<ID, User> oldUsers)
    {
        for(User newUser : newUsers) {
            User oldUser = oldUsers != null ? oldUsers.get(newUser.ID) : null;
        {
            //Country_Specific_Settings__c : This is a custom setting where you have all country codes in it.
            //newUser.Country_Code__c : Contact object country code field.
            //E_Mail_Signature_Id__c : This is a field name in custom setting where you store Image ID for a country code.
            
           if (String.isBlank(newUser.E_Mail_Signature_Id__c)) {
                Country_Specific_Settings__c countrySpecificSettings = Country_Specific_Settings__c.getValues(newUser.Country_code__c);
                  
                if(countrySpecificSettings != null) {
                    newUser.E_Mail_Signature_Id__c = countrySpecificSettings.E_Mail_Signature_Id__c;
                } else {
                    System.debug(LoggingLevel.DEBUG, 'No country specific settings found for [' + newUser.Country_Code__c + ']');
                }              
                    
                                
            } else if (oldUser != null
                       && oldUser.Country_code__c != newUser.Country_code__c) {
                
                Country_Specific_Settings__c oldCountrySpecificSettings = Country_Specific_Settings__c.getValues(oldUser.Country_code__c);
                Country_Specific_Settings__c newCountrySpecificSettings = Country_Specific_Settings__c.getValues(newUser.Country_code__c);
                
                if (oldCountrySpecificSettings == null) {
                                        
                    if (String.isBlank(newUser.E_Mail_Signature_Id__c)) {
                        newUser.E_Mail_Signature_Id__c = newCountrySpecificSettings.E_Mail_Signature_Id__c;
                    }
                } else if (newCountrySpecificSettings == null) {
                                        
                    if (newUser.E_Mail_Signature_Id__c == oldCountrySpecificSettings.E_Mail_Signature_Id__c) {
                        newUser.E_Mail_Signature_Id__c = null;
                    }
                } else {
                                        
                    if (String.isBlank(newUser.E_Mail_Signature_Id__c)
                        || newUser.E_Mail_Signature_Id__c == oldCountrySpecificSettings.E_Mail_Signature_Id__c) {
                        
                        newUser.E_Mail_Signature_Id__c = newCountrySpecificSettings.E_Mail_Signature_Id__c;
                    }
                }
            }
        }
    }
}
    
}