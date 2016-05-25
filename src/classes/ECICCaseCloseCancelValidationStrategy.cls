public class ECICCaseCloseCancelValidationStrategy extends ECICCaseProcessingStrategyAbstract {
    private static final Map<String, Case_Fields_Blacklist__c>  BLACKLIST_MAP       = Case_Fields_Blacklist__c.getAll();
    @TestVisible
    private static Boolean isError = false;
    
    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        execute((Map<ID, Case>)oldValuesMap, (List<Case>)newValuesMap.values());
        
        return true;
    }
    
    private void execute(Map<ID, Case> oldCasesMap, Case[] newCasesList) {
        String USER_PROFILE_NAME   = SEPProfileCache.get(Id.valueOf(UserInfo.getProfileId())).Name;
        
        for (Case newCase : newCasesList) {
            Case oldCase = oldCasesMap.get(newCase.ID);
            
            if (oldCase.isClosed 
                && newCase.isClosed 
                && USER_PROFILE_NAME != ECICCommonConstants.PROFILE_SYSTEM_ADMIN) {
                
                  for (String field : BLACKLIST_MAP.keySet()) {
                    if (newCase.get(field) != oldCase.get(field)) {
                       string str=(string)oldCase.get(field);
                        // Fix of INC3650714-- Filter added
                        if(field=='Reason' && string.isblank(str)){
                          break;
                        }
                        else{            
                        newCase.addError(Label.Case_reopen);
                                    isError = true;                         //isError variable - for testing purposes only.
                                    break;
                        }
                    }
                } 
            }
        }
    }
    
}