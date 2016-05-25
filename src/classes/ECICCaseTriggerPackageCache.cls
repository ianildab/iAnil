public class ECICCaseTriggerPackageCache {
    @testVisible
    private static Map<Id, Package__c> packageByIdCache = new Map<Id, Package__c>();
    public  static Map<Id, Package__c> getPackageByIdMap()  { return packageByIdCache; }
    
    public static void populate (List<Case> currentCaseList) {
        Set<Id>     packageIdSet            = new Set<Id>();
        Set<String> packageTypeSet          = new Set<String>();
        Set<String> sizeSet                 = new Set<String>();
        
        for (Case currentCase : currentCaseList) {
            if (currentCase.Package__c != null) { packageIdSet.add (currentCase.Package__c); }
            if (currentCase.Product__c != null) {
                Product__c cacheProduct = ECICCaseTriggerProductCache.getProductByIdMap().get(currentCase.Product__c);
                if (cacheProduct != null && String.isNotBlank(cacheProduct.Package_Type__c))            { packageTypeSet.add (cacheProduct.Package_Type__c); }
                if (cacheProduct != null && String.isNotBlank(cacheProduct.Size__c))                    { sizeSet.add (cacheProduct.Size__c); }
            }
        }
        
        if (!packageIdSet.isEmpty() || !packageTypeSet.isEmpty() || !sizeSet.isEmpty()) {
            Map<Id, Package__c> packageByIdMap = new Map<Id, Package__c>([
                                                                            SELECT Id, Active__c, Country__c, Country_Code__c,
                                                                                Packaging__c, Size__c
                                                                            FROM Package__c 
                                                                            WHERE   id                          IN :packageIdSet
                                                                                OR  Packaging__c                IN :packageTypeSet
                                                                                OR  Size__c                     IN :sizeSet
                                                                          ]);
            packageByIdCache.putAll(packageByIdMap);
        }
    }
    
}