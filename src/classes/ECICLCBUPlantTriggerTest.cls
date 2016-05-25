@isTest
public class ECICLCBUPlantTriggerTest 
{
    public static List<Plant__c> plantList =new List<Plant__c>();
    static TestMethod void insertPlant()
    {
        Plant__c plant1 =new Plant__c();
        plant1.Name = 'Estrella Azul';
        plant1.LCBU_Plant_Code__c = 'ILSA';
        plant1.LCBU_Region__c = 'Latin Center - CAMCAR';
        plant1.Country__c = 'Panamá';
        plantList.add(plant1);
        
        Plant__c plant2 =new Plant__c();
        plant2.Name = 'FEMSA Calle Blancos';
        plant2.LCBU_Plant_Code__c = 'SJ';
        plant2.LCBU_Region__c = 'Latin Center - CAMCAR';
        plant2.Country__c = 'Costa Rica';
        plantList.add(plant2);
        
        List<LCBU_Country__c> lcbuCList = new LIST<LCBU_Country__c>();
        
        LCBU_Country__c l1 = new LCBU_Country__c(Name = 'Costa Rica', Country_Code__c = 'CR');
        LCBU_Country__c l2 = new LCBU_Country__c(Name = 'Panamá', Country_Code__c = 'PN');
        lcbuCList.add(l1);
        lcbuCList.add(l2);
        
        insert lcbuCList;
        
        insert plantList;      
    }

}