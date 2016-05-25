public with sharing class ECICContactTriggerHandler extends SEPTriggerHandlerAbstract {

    public ECICContactTriggerHandler (boolean isTriggerExecuting){
       super(isTriggerExecuting);
    }

	public override void OnBeforeInsert(List<sObject> newValues) {
        ECICUtils.resolveOwner(newValues, null, true);
            ECICUtils.resolveCountryCode(newValues, null, true);
        onBefore((List<Contact>)newValues, null, true);
    }
    
	public override void OnBeforeUpdate(List<sObject> oldValues, List<sObject> newValues, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        ECICUtils.resolveOwner(newValues, oldValuesMap, false);
        ECICUtils.resolveCountryCode(newValues, oldValuesMap, false);
        onBefore((List<Contact>)newValues, (Map<ID, Contact>)oldValuesMap, false);
    }
    
    public override void OnAfterInsert(List<sObject> newValueSObjectList, Map<ID, sObject> newValuesSObjectMap) {}
    public override void OnAfterUpdate(List<sObject> oldValueSObjectList, List<sObject> newValueSObjectList, Map<ID, sObject> oldValuesSObjectMap, Map<ID, sObject> newValuesSObjectMap) {} 
    
    private void onBefore(List<Contact> newObjs, Map<ID, Contact> oldMap, boolean isInsert) 
    {
        for(Contact c : newObjs) 
        {
            if (!isContact(c)) { continue; }
            if (isInsert || ECICProperNamesHelper.isNameChanged(Trigger.oldMap.get(c.id), c)) { ECICProperNamesHelper.updateNames(c); }
        }
    }
    
    private boolean isContact(Contact c) { return c.RecordTypeId == null; }
    
}