public /* with sharing */ class CRMLegalAcceptanceDao {

    public static Map<String, Legal_Acceptance__c> findByExtId(Set<String> legalAcceptanceExtIds) {
    	
        Map<String, Legal_Acceptance__c> result = new Map<String, Legal_Acceptance__c>();
        
        List<Legal_Acceptance__c> legalAcceptances = [SELECT ID, LegalAcceptance_Unique_Name__c FROM Legal_Acceptance__c WHERE LegalAcceptance_Unique_Name__c IN :legalAcceptanceExtIds];

        for (Legal_Acceptance__c legalAcceptance : legalAcceptances) {
            result.put(legalAcceptance.LegalAcceptance_Unique_Name__c, legalAcceptance);
        }
        
        return result;      
    } 
}