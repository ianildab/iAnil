public class ECICOpenAlertNotificationCache {
    private static  final Integer  DAYS_TIL_EXPIRATION = 0;
    private static  final Date     EXPIRING_DATE       = System.today().addDays(DAYS_TIL_EXPIRATION);
    private static Map<Id, List<Open_Alert__c>> openAlertListByUserIdMapCache = new Map<Id, List<Open_Alert__c>>();
    public  static Map<Id, List<Open_Alert__c>> getOpenAlertListByUserIdMap()  { return openAlertListByUserIdMapCache; }
    
    public static void populate (Set<Id> userIdSet) {
        
        List<Open_Alert__c> openAlertList = [SELECT id, name, ownerId, end_date__c  
                                                FROM Open_Alert__c  
                                                WHERE active__c = 'true'
                                                    AND ownerId IN :userIdSet
                                                    AND end_date__c <= :EXPIRING_DATE];
        
        for(Open_Alert__c openAlert : openAlertList) {
            List<Open_Alert__c> currentOwnerList = openAlertListByUserIdMapCache.get(openAlert.ownerId);
            
            if (currentOwnerList == null) {
                currentOwnerList = new List<Open_Alert__c>();
                openAlertListByUserIdMapCache.put(openAlert.ownerId, currentOwnerList);
            }
            
            currentOwnerList.add(openAlert);
        }
    }
}