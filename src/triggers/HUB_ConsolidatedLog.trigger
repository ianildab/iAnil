trigger HUB_ConsolidatedLog on FeedItem (after insert,after delete) {

    if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) { return; }
    if(trigger.isafter)  
    {
           if(trigger.isinsert)
           {
           if(!HUB_Validator_cls.hasAlreadyDone()){  
           system.debug('$$$$$$$$$ entering');
            HUB_ConsolidatedLogHelper hcl=new HUB_ConsolidatedLogHelper();
                 hcl.afterInsertUpdate(Trigger.new);
                 HUB_Validator_cls.setAlreadyDone();
        
                 } 
                }       
               }  
               
        if(trigger.isafter)  
        {       
        if(trigger.isdelete)
        {
           if(!HUB_Validator_cls.hasAlreadyDone()){  
           system.debug('$$$$$$$$$ entering');
            HUB_ConsolidatedLogHelper hcl=new HUB_ConsolidatedLogHelper();
                 hcl.beforeDelete(Trigger.old);
                  HUB_Validator_cls.setAlreadyDone();
                  }
        }
    }
}