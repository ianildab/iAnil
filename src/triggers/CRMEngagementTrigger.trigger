trigger CRMEngagementTrigger on Engagement__c (after insert, after update, before insert, before update) {
	
    if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) {
        return;
    }
    
    SEPTriggerHandlerInvoker.invoke(new CRMEngagementTriggerHandler(Trigger.isExecuting));
}