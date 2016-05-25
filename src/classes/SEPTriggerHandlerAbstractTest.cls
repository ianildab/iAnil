@isTest 
public class SEPTriggerHandlerAbstractTest 
{
	public class DummyTriggerHandler extends SEPTriggerHandlerAbstract
	{
		public DummyTriggerHandler(boolean isTriggerExecuting) { super(isTriggerExecuting);}
        public override void OnBeforeInsert (List<sObject> newValuesList) { super.OnBeforeInsert(newValuesList); }
        public override void OnAfterInsert  (List<sObject> newValuesList, Map<ID, sObject> newValuesMap) { super.OnAfterInsert (newValuesList, newValuesMap); }
        public override void OnBeforeUpdate (List<sObject> oldValuesList, List<sObject> newValuesList, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) { super.OnBeforeUpdate(oldValuesList, newValuesList, oldValuesMap, newValuesMap); }
        public override void OnAfterUpdate  (List<sObject> oldValuesList, List<sObject> newValuesList, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) { super.OnAfterUpdate(oldValuesList, newValuesList, oldValuesMap, newValuesMap); }
        public override void OnBeforeDelete (List<sObject> oldValuesList, Map<ID, sObject> oldValuesMap) { super.OnBeforeDelete(oldValuesList, oldValuesMap); }
        public override void OnAfterDelete  (List<sObject> oldValuesList, Map<ID, sObject> oldValuesMap) { super.OnAfterDelete(oldValuesList, oldValuesMap); }
        public override void OnAfterUndelete(List<sObject> oldValuesList, Map<ID, sObject> oldValuesMap) { super.OnAfterUndelete(oldValuesList, oldValuesMap); }
	} 
	
	private static final DummyTriggerHandler HANDLER = new DummyTriggerHandler(true);
	
	private static testMethod void onBeforeInsertTest() { HANDLER.onBeforeInsert (new List<sObject>()); }
	private static testMethod void onBeforeUpdateTest() { HANDLER.onBeforeUpdate (new List<sObject>(), new List<sObject>(), new Map<ID, sObject>(), new Map<ID, sObject>()); }
	private static testMethod void onBeforeDeleteTest() { HANDLER.onBeforeDelete (new List<sObject>(), new Map<ID, sObject>()); }
	private static testMethod void onAfterDeleteTest()  { HANDLER.onAfterDelete  (new List<sObject>(), new Map<ID, sObject>()); }
	private static testMethod void onAfterInsertTest()  { HANDLER.onAfterInsert  (new List<sObject>(), new Map<ID, sObject>()); }
	private static testMethod void onAfterUpdateTest()  { HANDLER.onAfterUpdate  (new List<sObject>(), new List<sObject>(), new Map<ID, sObject>(), new Map<ID, sObject>()); }
	private static testMethod void onAfterUndeleteTest(){ HANDLER.onAfterUndelete(new List<sObject>(), new Map<ID, sObject>()); }
	
}