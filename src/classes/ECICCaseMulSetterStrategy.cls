public class ECICCaseMulSetterStrategy extends ECICCaseProcessingStrategyAbstract 
{
    public override boolean OnBeforeInsert(List<sObject> newValues) 
    {
    	doExecution ((List<Case>)newValues);
        return true;
    }

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) 
    {
    	List<Case> requiresExecutionCaseList = buildRequiresExecutionCaseList ((Map<ID, Case>) oldValuesMap, (List<Case>) newValuesMap.values());

        if (!requiresExecutionCaseList.isEmpty()) 
        {
            doExecution(requiresExecutionCaseList);
        }

        return true;
    }

    /**
     * Check if running the whole strategy is neccessary.
     */
    @testVisible private List<Case> buildRequiresExecutionCaseList (Map<ID, Case> oldCasesMap, Case[] newCasesList) 
    {
    	List<Case> requiresExecutionCaseList = new List<Case>();
    	
        for (Case newCase : newCasesList) 
        {
        	if ( hasCountryCodeChanged(newCase, oldCasesMap) || hasEmptyLookupUserField (newCase))
            {
				requiresExecutionCaseList.add(newCase);
            }
        }
        
        return requiresExecutionCaseList;
    }

            // check if country code has changed            
    @testVisible private Boolean hasCountryCodeChanged (Case newCase, Map<Id, Case> oldCaseByIdMap)
    {
         Case oldCase = ((oldCaseByIdMap != null) && (oldCaseByIdMap.containsKey(newCase.id))) 
         						? (oldCaseByIdMap.get(newCase.id)) 
         						: (null);
         
         return ((oldCase == null) || ( oldCase.Country_code__c != newCase.Country_code__c));
            }
            
            // check if there is an empty user lookup field
    @testVisible private Boolean hasEmptyLookupUserField (Case newCase)
    {
        for (String mappedUserField : ECICCommonConstants.USER_FIELDS) 
        {
            if ((ID)newCase.get(mappedUserField) == null) { return true; }
        }
        return false;
            }

    @testVisible private void doExecution(Case[] casesList) 
    {
        for (Case newCase : casesList) 
        {
        	doExecution (newCase);
        }
    }
    
    @testVisible private void doExecution (Case newCase)
    {
            User_Lookup_Mapping__c mapping = User_Lookup_Mapping__c.getValues(newCase.Country_Code__c);
        if (mapping != null) 
        {
            for (String mappedUserField : ECICCommonConstants.USER_FIELDS) 
            {
                ID newMappedUserId = getUserForMappedField(mappedUserField, mapping);
                    newCase.put(mappedUserField, newMappedUserId);
                }
            }           
        }
    
    @testVisible private ID getUserForMappedField(String mappedUserField, User_Lookup_Mapping__c mapping) 
    {
        ID result = null;
        String roleName = (String)mapping.get(mappedUserField);
        
        if (roleName != null) 
        {
            result = ECICCaseTriggerUserCache.getUserIdByUserRoleDeveloperNameMapping().get(roleName);
            if (result == null) 
            {
                System.debug(LoggingLevel.WARN, 'No user is mapped to role ['+roleName+']');
            }
        } 
        else 
        {
            System.debug(LoggingLevel.WARN, 'No role is mapped to field ['+mappedUserField+']');
        }
        
        return result;
    }
}