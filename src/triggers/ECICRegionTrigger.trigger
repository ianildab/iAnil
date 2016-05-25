trigger ECICRegionTrigger on Region__c (before insert, before update, after insert, after update) {
    
    if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) {
        return;
    }

    SEPTriggerHandlerInvoker.invoke(new ECICRegionTriggerHandler(Trigger.isExecuting));
}