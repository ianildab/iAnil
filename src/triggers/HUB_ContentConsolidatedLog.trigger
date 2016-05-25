trigger HUB_ContentConsolidatedLog on HUB_Related_Content__c (after insert, before insert, before update) {
    
    if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) { return; }
    if(Trigger.isAfter && Trigger.isInsert){
         HUB_ConsolidatedLogHelper helper=new HUB_ConsolidatedLogHelper();
         helper.afterInsertRelatedContent(Trigger.New);
    }

}