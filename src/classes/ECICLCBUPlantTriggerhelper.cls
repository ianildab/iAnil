public class ECICLCBUPlantTriggerhelper {
    public static void CountryCodeIdentify(list<Plant__c> cList){
        set<id> plantId=new Set<id>();
        Map<string,LCBU_Country__c> mapCode=LCBU_Country__c.getAll();
        Set<String> countries = mapCode.keySet();
        for(Plant__c cPl: cList){
            plantId.add(cPl.id);  
        }
        for(Plant__c cPla: cList){
            if(countries.contains(cPla.Country__c))
            cPla.Country_Code__c=mapCode.get(cPla.Country__c).Country_Code__c;
        }
    }
}