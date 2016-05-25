trigger ECICClosedTrendTrigger on Closed_Trend__c (before insert, before update) 
{
    if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) { return; }
    
    SEPTriggerHandlerInvoker.invoke(new ECICClosedTrendTriggerHandler (Trigger.isExecuting));
}