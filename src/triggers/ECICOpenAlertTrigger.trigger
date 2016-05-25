trigger ECICOpenAlertTrigger on Open_Alert__c (before insert, before update, after insert) {    
    if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) {
        return;
    }

    ECICOpenAlertTriggerHandler handler = new ECICOpenAlertTriggerHandler(Trigger.isExecuting);
    SEPTriggerHandlerInvoker.invoke(handler);
}