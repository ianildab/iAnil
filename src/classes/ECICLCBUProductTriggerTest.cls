@isTest
public class ECICLCBUProductTriggerTest 
{
    public static List<CCE_Product__c> productList =new List<CCE_Product__c>();
    static TestMethod void insertPlant()
    {
        CCE_Product__c prod1 =new CCE_Product__c();
        prod1.Name = 'Fruit Punch';
        prod1.Country__c = 'Costa Rica';
        productList.add(prod1);
        
        CCE_Product__c prod2 =new CCE_Product__c();
        prod2.Name = 'Lemon Lime';
        prod2.Country__c = 'Guatemala';
        productList.add(prod2);
        
        List<LCBU_Country__c> lcbuCList = new LIST<LCBU_Country__c>();
        
        LCBU_Country__c l1 = new LCBU_Country__c(Name = 'Costa Rica', Country_Code__c = 'CR');
        LCBU_Country__c l2 = new LCBU_Country__c(Name = 'Guatemala', Country_Code__c = 'GT');
        lcbuCList.add(l1);
        lcbuCList.add(l2);
        
        insert lcbuCList;
        insert productList;      
    }

}