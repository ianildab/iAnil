abstract public /* with sharing */ class SEPTriggerHandlerStrategyAbstract implements SEPTriggerHandlerStrategy {

    public virtual boolean OnBeforeInsert(List<sObject> newValues) {
        System.debug(LoggingLevel.ERROR, 'Method not implemented.'); // how about throwing a custom exception? :)
        
        return true;
    }
    
    public virtual boolean OnAfterInsert(Map<ID, sObject> newValuesMap) {
        System.debug(LoggingLevel.ERROR, 'Method not implemented.'); // how about throwing a custom exception? :)
        
        return true;
    }

    public virtual boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        System.debug(LoggingLevel.ERROR, 'Method not implemented.'); // how about throwing a custom exception? :)
        
        return true;
    }
    
    public virtual boolean OnAfterUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        System.debug(LoggingLevel.ERROR, 'Method not implemented.'); // how about throwing a custom exception? :)
        
        return true;
    }
    
    public virtual boolean OnBeforeDelete(Map<ID, sObject> oldValuesMap) {
        System.debug(LoggingLevel.ERROR, 'Method not implemented.'); // how about throwing a custom exception? :)
        
        return true;
}
    
    public virtual boolean OnAfterDelete(Map<ID, sObject> oldValuesMap) {
        System.debug(LoggingLevel.ERROR, 'Method not implemented.'); // how about throwing a custom exception? :)
        
        return true;
    }
    
    public virtual boolean OnAfterUndelete(Map<ID, sObject> newValuesMap) {
        System.debug(LoggingLevel.ERROR, 'Method not implemented.'); // how about throwing a custom exception? :)
        
        return true;
    }
    
}