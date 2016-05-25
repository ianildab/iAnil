trigger ECICProductTrigger on Product__c (before insert, before update) {
    
    if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) {
        return;
    }
        
    SEPTriggerHandlerInvoker.invoke(new ECICProductTriggerHandler(Trigger.isExecuting));
}