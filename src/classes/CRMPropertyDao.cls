public /* with sharing */ class CRMPropertyDao {
	
    public static Map<String, Property__c> findByClientIds(Set<String> clientIds) {
        Map<String, Property__c> result = new Map<String, Property__c>();
        
        Property__c[] properties = [SELECT ID, Property_Representation_Client_ID__c, Parent__c FROM Property__c WHERE Property_Representation_Client_ID__c IN :clientIds];
        
        for (Property__c property : properties) {
            result.put(property.Property_Representation_Client_ID__c, property);
        }
        
        return result;      
    }
}