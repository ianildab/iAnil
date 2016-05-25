public with sharing class STMContactTriggerHandler {
    private boolean m_isExecuting = false;
    public static boolean firstRun = true;
 
    public STMContactTriggerHandler (boolean isExecuting){
        m_isExecuting = isExecuting;
    }
    
    
    public void OnBeforeInsert(sObject[] inserted){
        STMStakeholderHelper.fillStakeholderKey(inserted);
    }
    
    public void OnBeforeUpdate(sObject[] old, sObject[] updated, Map<ID, sObject> newMap){
        STMStakeholderHelper.fillStakeholderKey(updated);
    }
    
    public void OnAfterInsert(sObject[] inserted){
        STMStakeholderHelper.removeRelatedIssueScores(inserted);
    }
    
    public void OnAfterUpdate(sObject[] old, sObject[] updated, Map<ID, sObject> newMap){
        if (firstRun) {
            firstRun = false;
        } else {
            return;
        }
        STMStakeholderHelper.removeRelatedIssueScores(updated);        
    }
    
}