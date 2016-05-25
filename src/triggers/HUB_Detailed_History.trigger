trigger HUB_Detailed_History on FeedItem (after insert,after delete) {
    if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) { return; }
    if(trigger.isafter){
        if(trigger.isInsert){
            HUB_DetailedHistoryHelper newInstsance=new HUB_DetailedHistoryHelper();
            newInstsance.afterInsert(Trigger.New);
        }
        if(trigger.isDelete){
            HUB_DetailedHistoryHelper newInstsance=new HUB_DetailedHistoryHelper();
            newInstsance.deleteFeedFromLearning(Trigger.old);
            newInstsance.deleteFeedFromContent(Trigger.old);
        }
    }
}