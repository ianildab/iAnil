public class ECICCaseTriggerBeverageCache {
    @testVisible
    private static Map<Id, Beverage__c> beverageByIdCache = new Map<Id, Beverage__c>();
    public  static Map<Id, Beverage__c> getBeverageByIdMap()  { return beverageByIdCache; }
    
    public static void populate (List<Case> currentCaseList) {
        Set<Id>     beverageIdSet           = new Set<Id>();
        Set<String> productDescriptionSet   = new Set<String>();
        
        for (Case currentCase : currentCaseList) {
            if (currentCase.Beverage__c != null) { beverageIdSet.add (currentCase.Beverage__c); }
            if (currentCase.Product__c != null) {
                Product__c cacheProduct = ECICCaseTriggerProductCache.getProductByIdMap().get(currentCase.Product__c);
                if (cacheProduct != null && String.isNotBlank(cacheProduct.Product_Description__c)) { productDescriptionSet.add (cacheProduct.Product_Description__c); }
            }
        }
        
        if (!beverageIdSet.isEmpty() || !productDescriptionSet.isEmpty()) {
            Map<Id, Beverage__c> beverageByIdMap = new Map<Id, Beverage__c>([
                                                                            SELECT Id, Active__c, Brand__c, Country__c, Country_Code__c, 
                                                                                Currently_Sold__c, Date_of_Launch__c, Flavour__c, Flavour_Code__c, 
                                                                                International_Name__c, Product_Code__c, Product_Description__c, 
                                                                                Type__c, Type_Code__c
                                                                            FROM Beverage__c 
                                                                            WHERE   id                      IN :beverageIdSet 
                                                                                OR  Product_Description__c  IN :productDescriptionSet
                                                                          ]);
            beverageByIdCache.putAll(beverageByIdMap);
        }
    }
    
}