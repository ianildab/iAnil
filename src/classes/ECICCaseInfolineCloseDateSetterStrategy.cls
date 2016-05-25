/**
*    ECIC-2092: Quality Closed date is the date when the Quality Status is set to Closed
*/
public class ECICCaseInfolineCloseDateSetterStrategy extends ECICCaseProcessingStrategyAbstract {

    public override boolean OnBeforeInsert(List<sObject> newValues) {
        for (Case newCase : (Case[])newValues) {
            if (newCase.infoline_status__c == ECICCommonConstants.STATUS_CLOSED) {
                newCase.Infoline_Close_Date__c = system.today();        
            }
        }
        
        return true;
    }

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        Map<ID, Case> oldCasesMap = (Map<ID, Case>)oldValuesMap;
    	Map<ID, Case> newCasesMap = (Map<ID, Case>)newValuesMap;
    	
        for (Case newCase : newCasesMap.values()) {
            Case oldCase = oldCasesMap.get(newCase.id);
            
            if (newCase.infoline_status__c == ECICCommonConstants.STATUS_CLOSED
                && newCase.infoline_status__c != oldCase.infoline_status__c) {
                    
                newCase.Infoline_Close_Date__c = system.today();        
            }
        }
        
        return true;
    }
}