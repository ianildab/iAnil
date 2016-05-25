trigger ECICLCBUCCEProductTrigger on CCE_Product__c (before insert,before update) {
  ECICLCBUCCEProductTriggerhelper.CountryCodeIdentify(trigger.new);
}