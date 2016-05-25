trigger HUB_CreateLogForNewContent on HUB_Contents__c  (after insert,after update) {
   
   if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) { return; }
   if(Trigger.isInsert){
    HUB_DetailedHistoryHelper newInstance=new HUB_DetailedHistoryHelper ();
    newInstance.afterInsertConent(Trigger.new);
 }
 if(Trigger.isupdate){
    HUB_DetailedHistoryHelper newInstance=new HUB_DetailedHistoryHelper ();
    newInstance.afterUpdateContent(Trigger.new,Trigger.old);
 }
}