trigger ECICCompetitorProductTrigger on Competitor_Product__c (before insert, before update) 
{
    if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) { return; }
    SEPTriggerHandlerInvoker.invoke(new ECICCompetitorProductTriggerHandler(Trigger.isExecuting));
}