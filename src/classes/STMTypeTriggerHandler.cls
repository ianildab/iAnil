public /*with sharing*/ class STMTypeTriggerHandler {
    private boolean m_isExecuting = false;
    public static boolean firstRun = true;
 
    public STMTypeTriggerHandler (boolean isExecuting) {
        m_isExecuting = isExecuting;
    }
    
    public void OnBeforeInsert(List<STMG_Type__c> inserted) {
        STMTypeHelper.checkTypeDuplication(inserted, null);
    }
    
    public void OnBeforeUpdate(List<STMG_Type__c> old, List<STMG_Type__c> updated, Map<ID, STMG_Type__c> oldMap) {
       STMTypeHelper.checkTypeDuplication(updated, oldMap);
    }
    
    public void onAfterInsert(List<STMG_Type__c> inserted) {
        STMTypeHelper.updateTypeListOnStakeholder(inserted, null, false);
    }
    
    public void onAfterUpdate(sObject[] old, List<STMG_Type__c> updated, Map<ID, STMG_Type__c> oldMap) {
        if (firstRun) {
            firstRun = false;
        } else {
            return;
        }
        STMTypeHelper.updateTypeListOnStakeholder(updated, oldMap, false);
    }
    
    public void onAfterDelete(List<STMG_Type__c> updated, Map<ID, STMG_Type__c> oldMap) {
        STMTypeHelper.updateTypeListOnStakeholder(updated, oldMap, true);
    }

    
}