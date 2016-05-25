trigger ECICPromotionTrigger on Promotion__c (before insert, before update) 
{
    if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) { return; }
    SEPTriggerHandlerInvoker.invoke(new ECICPromotionTriggerHandler(Trigger.isExecuting));
}