public class ECICCaseCountryCodeValidatorStrategy extends ECICCaseProcessingStrategyAbstract // commenting this whole class since we are not using this strategy.
{   /* comment block 1 start
    @testVisible private Boolean caseCountryCodeValidatorStrategyTestRunning = false;

    public override boolean OnBeforeInsert(SObject[] newSObjectList) 
    {
        List<Case>  newCasesList                 = (List<Case>) newSObjectList;
        User currentUser                         = ECICCaseTriggerUserCache.getUserByIdMap().get(UserInfo.getUserId());
        Set<String> currentUsersEnabledCountries = getCurrentUsersEnabledCountries(currentUser);
        
        if (validateCountryCodeSet(newCasesList, currentUser))
        {
            return SEPProfileCache.isUserAdmin()
                    || validateAgainstCurrentUserEnabledCountries(NULL, newCasesList, currentUsersEnabledCountries);
        }
        else {return false;}
        
            }

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldSObjectValueMap, Map<ID, sObject> newSObjectValueMap) 
    {
        List<Case>  newCasesList                 = (List<Case>) newSObjectValueMap.values();    
        User currentUser                         = ECICCaseTriggerUserCache.getUserByIdMap().get(UserInfo.getUserId());
        Set<String> currentUsersEnabledCountries = getCurrentUsersEnabledCountries(currentUser);
        
        return SEPProfileCache.isUserAdmin() || validateAgainstCurrentUserEnabledCountries((Map<ID, Case>)oldSObjectValueMap, newCasesList, currentUsersEnabledCountries);
    }

    // -----------------------------------------------------------------------------------------------------------------

    private Boolean validateCountryCodeSet(List<Case> newCasesList, User currentUser)
    {
        boolean result = false;
        if (String.isBlank(currentUser.Country_code__c)) 
        {
            result = validateCaseListCountryCodes(newCasesList, System.Label.User_Country_Code_must_be_set + ' ['+currentUser.Name+']');
        }
        else 
        {  
            result = validateCaseListCountryCodes(newCasesList, System.Label.Case_Country_Code_must_be_set); // This should never happen! 
        }  
        return result;
    }
    
    private Boolean validateCaseListCountryCodes(List<Case> newCasesList, String errorMessageOnFalse)
    {
        Boolean result = false;
        for (Case currentCase : newCasesList)   
        {
            if (String.isBlank(currentCase.Country_code__c)) 
            {
                currentCase.addError(errorMessageOnFalse);
            }
            else { result = true; }
        }
        return result;
    }
        
    
    // Invoke from OnBeforeInsert()/OnBeforeUpdate()
    private Boolean validateAgainstCurrentUserEnabledCountries(Map<ID, Case> oldValuesMap, List<Case> newCasesList, Set<String> enabledCountryNameSet)
    {
        Boolean result = false;
        for (Case currentCase : newCasesList) 
        {
            if (Test.isRunningTest() && (currentCase.subject != ECICCaseCountryCodeValidatorStrategyTest.VALIDATION_STRATEGY_TEST)) { return true; }  
            Case oldCase = (oldValuesMap != NULL) ? oldValuesMap.get(currentCase.ID) : NULL;
            String ccErrorMessage = '';  
            if(oldCase == NULL && !enabledCountryNameSet.contains(currentCase.Country_Code__c)){
                ccErrorMessage = Label.Case_creation_in_the_specified_country_is_not_allowed;                                    
            }else if(oldCase != NULL && (!(currentCase.Status == 'New' || String.isEmpty(oldCase.Country_Code__c)))){
                      ccErrorMessage = Label.Case_Not_Change_Country_Code;            
            }else if(!enabledCountryNameSet.contains(currentCase.Country_Code__c)){
                      ccErrorMessage = Label.This_Country_Code_Not_Available_For_You;            
            }
            if(oldCase != NULL && oldCase.Country_Code__c == currentCase.Country_Code__c){
                ccErrorMessage = '';  
            }                  
            if (ccErrorMessage !=''){
                currentCase.addError(ccErrorMessage);
            }else { result = true; }
        }
        return result;      
    }
    
    // ---------------------------------------------------------------------------------------------------------------------------

    private Set<String> getCurrentUsersEnabledCountries(User currentUser) 
    {
        Set<String> enabledCountryNameSet = new Set<String>();
        if (currentUser.Enabled_Countries__c != null) 
        {
            enabledCountryNameSet.addAll(currentUser.Enabled_Countries__c.split(';'));
        }
        return enabledCountryNameSet;
    } comment block 1 end */
    
}