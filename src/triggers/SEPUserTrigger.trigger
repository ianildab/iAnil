trigger SEPUserTrigger on User (before insert, before update, after update) {
  
  if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) {
    return;
  }
  
  SEPTriggerHandlerInvoker.invoke(new SEPUserTriggerHandler(Trigger.isExecuting));
}