public class ECICPromotionTypeTriggerHandler extends SEPTriggerHandlerAbstract
{
    public ECICPromotionTypeTriggerHandler(boolean isTriggerExecuting) { super(isTriggerExecuting); }

    public override void onBeforeInsert(List<sObject> newValueSObjectList) 
    {
        processBefore((Promotion_Type__c[])newValueSObjectList, null);
    }

    public override void onBeforeUpdate(List<sObject> oldValueSObjectList, List<sObject> newValueSObjectList, Map<Id, sObject> oldValueSObjectByIdMap, Map<Id, sObject> newValueSObjectByIdMap) 
    {
        processBefore((Promotion_Type__c[])newValueSObjectList, (Map<Id, Promotion_Type__c>)oldValueSObjectByIdMap);
    }
    
    @testVisible private static void processBefore(List<Promotion_Type__c> newPromotionTypeList, Map<Id, Promotion_Type__c> oldPromotionTypeByIdMap)
    {
    	Boolean isInsert = (oldPromotionTypeByIdMap != null);
        ECICUtils.resolveOwner      (newPromotionTypeList, oldPromotionTypeByIdMap, isInsert);
        ECICUtils.resolveCountryCode(newPromotionTypeList, oldPromotionTypeByIdMap, isInsert);
    }
}