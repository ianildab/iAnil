public class ECICCaseBeveragePackageCountryValidStr extends ECICCaseProcessingStrategyAbstract {
    private static final Map<Id, Beverage__c>   BEVERAGE_BY_ID_MAP                  = ECICCaseTriggerBeverageCache.getBeverageByIdMap();
    private static final Map<Id, Package__c>    PACKAGE_BY_ID_MAP                   = ECICCaseTriggerPackageCache.getPackageByIdMap();
    @testVisible
    private static      String errMessage                                           = null;
    @testVisible
    private static      Boolean isError                                             = false;
    
    public override boolean OnBeforeInsert(List<sObject> newCases) {
        return doExecute((List<Case>)newCases);
    }
    
    public override boolean OnBeforeUpdate(Map<ID, sObject> oldCasesMap, Map<ID, sObject> newCasesMap) {
        return doExecute((List<Case>)newCasesMap.values());
    }
    
    private boolean doExecute(Case[] newCases) {
        
        for (Case currentCase : newCases) {
            if (currentCase.Beverage__c != null
                && currentCase.Package__c != null) {
                
                Beverage__c beverage    = BEVERAGE_BY_ID_MAP.get(currentCase.Beverage__c);
                Package__c  pkg         = PACKAGE_BY_ID_MAP.get(currentCase.Package__c);
                
                if (!isCountryCodeMatch(beverage, pkg)) {
                    currentCase.addError(Label.Case_beverage_and_package_CC_dont_match);
                    if(Test.isRunningTest()) {
                        isError     = true;
                        errMessage  = Label.Case_beverage_and_package_CC_dont_match;
                    }
                }
            }
        }
        
        return true;
    }
    
    private static Boolean isCountryCodeMatch (Beverage__c beverage, Package__c pkg) {
        return      beverage.Country_Code__c    != null 
                &&  pkg.Country_Code__c         != null
                &&  beverage.Country_Code__c    == pkg.Country_Code__c;
    }

}