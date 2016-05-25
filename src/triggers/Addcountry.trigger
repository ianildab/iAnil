trigger Addcountry on sf4twitter__Twitter_Conversation__c (before insert) {
    for(sf4twitter__Twitter_Conversation__c Sft:trigger.new){
             Sft.country__c=Sft.Country_Code__c;   
       }
}