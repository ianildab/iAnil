trigger ECICPlantTrigger on Plant__c (before insert, before update) {
    
    if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) {
        return;
    }
    ECICLCBUPlantTriggerhelper.CountryCodeIdentify(trigger.new); 
    for (Plant__c p : Trigger.new) {
        //Country Code calculation
        String ownerID = p.OwnerId;
        p.Owner_Lookup__c = ownerID.startsWith('005') ? p.OwnerId : null;
    }
}