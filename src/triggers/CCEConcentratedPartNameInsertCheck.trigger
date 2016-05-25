trigger CCEConcentratedPartNameInsertCheck on Concentrate_Part_Number__c (before insert,before update)
{

    private static Map<String, Concentrated_Part_Number_CS__c> PartNumbers = Concentrated_Part_Number_CS__c.getAll();
    CCEConcentratedPartNameHelper.checkPartName(Trigger.new,PartNumbers);
   
}