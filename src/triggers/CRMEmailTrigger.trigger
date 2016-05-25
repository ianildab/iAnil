trigger CRMEmailTrigger on Email__c(
  after delete,
  after insert,
  after undelete,
  after update,
  before delete,
  before insert,
  before update) {
  
  if(SEPTriggerHandlerInvoker.skipTriggerInvocation()) {
    return;
  }
  
  SEPTriggerHandlerInvoker.invoke(
    new CRMEmailTriggerHandler(Trigger.isExecuting)
  );
  
}