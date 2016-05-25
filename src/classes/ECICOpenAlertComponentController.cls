public with sharing class ECICOpenAlertComponentController {
    public    Id             userId {get;set;}
    
    public List<Open_Alert__c> getExpiredList() {
        return ECICOpenAlertNotificationCache.getOpenAlertListByUserIdMap().get(userId);
    }
    
    public String getURL() {
        return URL.getSalesforceBaseUrl().toExternalForm();
    }

}