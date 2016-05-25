abstract public class SEPTriggerHandlerAbstract implements SEPTriggerHandler {

    @testVisible protected boolean isTriggerExecuting;
    
    public SEPTriggerHandlerAbstract(boolean isTriggerExecuting) {
        this.isTriggerExecuting = isTriggerExecuting;
    }
    
    public virtual void OnBeforeInsert(List<sObject> newValues) {
        
    }
    
    public virtual void OnAfterInsert(List<sObject> newValues, Map<ID, sObject> newValuesMap) {
        
    }

    public virtual void OnBeforeUpdate(List<sObject> oldValues, List<sObject> newValues, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        
    }
    
    public virtual void OnAfterUpdate(List<sObject> oldValues, List<sObject> newValues, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        
    }

    public virtual void OnBeforeDelete(List<sObject> oldValues, Map<ID, sObject> oldValuesMap) {
        
    }
    
    public virtual void OnAfterDelete(List<sObject> oldValues, Map<ID, sObject> oldValuesMap) {
        
    }
    
    public virtual void OnAfterUndelete(List<sObject> newValues, Map<ID, sObject> newValuesMap) {
        
    }
}