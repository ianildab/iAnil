public /* with sharing */ class CRMEngagementTriggerHandler extends SEPTriggerHandlerAbstract {

    public CRMEngagementTriggerHandler(boolean isTriggerExecuting){
        super(isTriggerExecuting);
    }

    public override void OnAfterInsert(List<sObject> newValues, Map<ID, sObject> newValuesMap) {
        new CRMEngagementBrandCopyStrategy().OnAfterInsert(newValuesMap);
    }
	
	public override void OnAfterUpdate(List<sObject> oldValues, List<sObject> newValues, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        new CRMEngagementBrandCopyStrategy().OnAfterUpdate(oldValuesMap,newValuesMap);
    }
}