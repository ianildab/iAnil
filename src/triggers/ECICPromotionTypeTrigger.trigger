trigger ECICPromotionTypeTrigger on Promotion_Type__c (before insert, before update) 
{
    if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) { return; }
    SEPTriggerHandlerInvoker.invoke(new ECICPromotionTypeTriggerHandler(Trigger.isExecuting));
}