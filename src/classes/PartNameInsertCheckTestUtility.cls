@isTest
public class PartNameInsertCheckTestUtility 
{
    public static Concentrate_Part_Number__c createTestDataPartNumber(String Name,Case c)
    {
            Concentrate_Part_Number__c cpn = new Concentrate_Part_Number__c();
            cpn.Name = Name;
            cpn.Case__c=c.Id; 
         	return cpn;
        
    }
}