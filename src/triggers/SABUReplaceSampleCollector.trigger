trigger SABUReplaceSampleCollector on SABU_Replace_Sample_Collector__c (after insert) {
    if(trigger.isInsert){
        SABU_ReplaceSampleCollector.replaceSampleCollectorAfterInsert(trigger.new);        
    }
}