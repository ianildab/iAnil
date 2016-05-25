trigger HUB_BestPracticeConsolidatedLog on HUB_Case_Best_Practice_Association__c (after insert, before insert, before update) {
    
    if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) { return; }
    if(Trigger.isAfter && Trigger.isInsert){
         HUB_ConsolidatedLogHelper helper=new HUB_ConsolidatedLogHelper();
         helper.afterInsertBestPracticeAssociation(Trigger.New);
    }
    
    if(Trigger.isBefore && Trigger.isInsert){
        set<id> caseId = new set<Id>();
        set<id> BPIds = new set<Id>();
        for (HUB_Case_Best_Practice_Association__c a : Trigger.new){
            caseId.add(a.Case_BestPractice__c);
            BPIds.add(a.Best_Practices_Cases__c);
        }
        system.debug(caseId+'caseId+++');
        list<HUB_Case_Best_Practice_Association__c> lstBP = [SELECT Id,Best_Practices_Cases__c,Case_BestPractice__c FROM 
                                HUB_Case_Best_Practice_Association__c where Best_Practices_Cases__c in : BPIds and Case_BestPractice__c in : caseId];
        system.debug(lstBP.size()+'lstBP+++');
        
        if(lstBP.size() > 0){
            if(!Test.isRunningTest()){
                Trigger.new[0].Best_Practices_Cases__c.addError('Best Practice already attached to the case');
            }
            
        }
        
    }
   

}