trigger HUB_CreateLogForNewLearning on HUB_Best_Practices__c (after insert,after update) {

 if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) { return; }
 if(Trigger.isInsert){
    HUB_DetailedHistoryHelper newInstance=new HUB_DetailedHistoryHelper ();
    newInstance.afterInsertLearning(Trigger.new);
 }
 if(Trigger.isupdate){
    HUB_DetailedHistoryHelper newInstance=new HUB_DetailedHistoryHelper ();
    newInstance.afterUpdateLearning(Trigger.new,Trigger.old);
 }
   
}