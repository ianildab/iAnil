public interface SEPTriggerHandlerStrategy {

    /**
     * @return boolean True if the execution is considered successful, false otherwise.
     *                 If the return value is false, the execution chain can be stopped.
     */
    boolean OnBeforeInsert(List<sObject> newValues);
    boolean OnAfterInsert(Map<ID, sObject> newValuesMap);

    boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap);
    boolean OnAfterUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap);

    boolean OnBeforeDelete(Map<ID, sObject> oldValuesMap);
    boolean OnAfterDelete(Map<ID, sObject> oldValuesMap);

    boolean OnAfterUndelete(Map<ID, sObject> newValuesMap);
}