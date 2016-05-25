public interface SEPTriggerHandler {

    void OnBeforeInsert(List<sObject> newValues);
    void OnAfterInsert(List<sObject> newValues, Map<ID, sObject> newValuesMap);

    void OnBeforeUpdate(List<sObject> oldValues, List<sObject> newValues, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap);
    void OnAfterUpdate(List<sObject> oldValues, List<sObject> newValues, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap);

    void OnBeforeDelete(List<sObject> oldValues, Map<ID, sObject> oldValuesMap);
    void OnAfterDelete(List<sObject> oldValues, Map<ID, sObject> oldValuesMap);
    
    void OnAfterUndelete(List<sObject> newValues, Map<ID, sObject> newValuesMap);
}