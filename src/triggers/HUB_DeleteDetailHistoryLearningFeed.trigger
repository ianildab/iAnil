trigger HUB_DeleteDetailHistoryLearningFeed on HUB_Detailed_History__c (after insert) {
  
  if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) { return; }
  Set<Id> setOfIds = new set<Id>();
  if(!HUB_Validator_cls.hasAlreadyDone()){  
       for(HUB_Detailed_History__c t :Trigger.new)
        {
        setOfIds.add(t.Id);
        }
        
        if(setOfIds.size()>0)
        {
           HUB_DetailedHistoryHelper.DeletefeedDetailedHistory(setOfIds);
        }
          
          HUB_Validator_cls.setAlreadyDone();
  }
}