public class ECICLCBUCCEProductTriggerhelper {
    public static void CountryCodeIdentify(list<CCE_Product__c> cList){
    		Set<Id> prodId=new Set<Id>();
			Map<string,LCBU_Country__c> mapCode=LCBU_Country__c.getAll();
        	Set<String> countries = mapCode.keySet();
    		for(CCE_Product__c cpr: cList){
        		prodId.add(cpr.Id);
    		}
       
    		for(CCE_Product__c cpro:cList){
                if(countries.contains(cpro.Country__c))
        		 cpro.Country_Code__c=mapCode.get(cpro.Country__c).Country_Code__c;
    		}
        
    }

}