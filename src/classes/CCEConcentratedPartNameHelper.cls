public with sharing class CCEConcentratedPartNameHelper
{
    
    public static void checkPartName(LIST<Concentrate_Part_Number__c> cList, Map<String,Concentrated_Part_Number_CS__c> myMap)
    {
        for(Concentrate_Part_Number__c cpm : cList)
        {
            Boolean b = myMap.containsKey(cpm.Name);           
            if(b==False)
            {           
                cpm.addError(System.Label.PartNameError);
            }
        }        
    }
}