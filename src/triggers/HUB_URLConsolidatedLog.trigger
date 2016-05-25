trigger HUB_URLConsolidatedLog on HUB_URL__c (after insert) {
  if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) { return; }
  HUB_ConsolidatedLogHelper helper=new HUB_ConsolidatedLogHelper();
  helper.insertURLConsolidatedLog(Trigger.New);
}