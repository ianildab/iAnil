public class ECICCaseTriggerProductCache 
{
    /**
     * 
     *  We are not using "final" with these caches because we wish to avoid race conditions.
     *
     *  Likewise, these get will return more data than required, but the logic to filter this will be too convoluted.
     *
     *  However, the surplus data is expected to be harmless.
     *
     **/	
    @testVisible private static Map<Id, Product__c> productByIdCache = new Map<Id, Product__c>();  
    public  static Map<Id, Product__c> getProductByIdMap()  { return productByIdCache; }
    private static Map<Id, Beverage__c> beverageByIdMap = null;
    private static Map<Id, Package__c>  packageByIdMap  = null;

    public static void populate (List<Case> currentCaseList)
    {
        /* Save the Product for the case */
        fillBeverageAndPackageMap(currentCaseList);
        
        Set<Id>     productIdSet    = new Set<Id>();
        Set<String> packageTypeSet  = new Set<String>();
        Set<String> sizeSet         = new Set<String>();
        Set<String> descriptionSet  = new Set<String>();
        
        for (Case currentCase : currentCaseList) {
            Beverage__c currentBeverage = beverageByIdMap.get(currentCase.Beverage__c);
            Package__c  currentPackage  = packageByIdMap.get(currentCase.Package__c);
            
            if (currentCase.Product__c != null) { productIdSet.add (currentCase.product__c); }
            if (currentBeverage != null && currentPackage != null) {
                packageTypeSet.add  (currentPackage.Packaging__c);
                sizeSet.add         (currentPackage.Size__c);
                descriptionSet.add  (currentBeverage.Product_Description__c);
            }
        }
        
        /* Copy the unit price of the product to the case */
        if (!productIdSet.isEmpty() || !packageTypeSet.isEmpty() || !sizeSet.isEmpty() || !descriptionSet.isEmpty()) 
        {
            Map<Id, Product__c> productByIdMap = new Map<Id, Product__c>([
                                                                            SELECT product_unit_price__c, Shelf_Life__c, Unit__c, 
                                                                                   Product_Description__c, Package_Type__c, Size__c, 
                                                                                   Active__c, Country_Code__c
                                                                            FROM Product__c 
                                                                            WHERE   id  IN  :productIdSet
                                                                              OR    (   Package_Type__c         IN :packageTypeSet
                                                                                    AND Size__c                 IN :sizeSet
                                                                                    AND Product_Description__c  IN :descriptionSet)
                                                                        ]);
            productByIdCache.putAll(productByIdMap);        
        }
        
    }
    
    private static void fillBeverageAndPackageMap(List<Case> currentCaseList) {
        Set<Id> beverageIdSet   = new Set<Id>();
        Set<Id> packageIdSet    = new Set<Id>();
        
        for (Case currentCase : currentCaseList) {
            if (currentCase.Beverage__c != null && currentCase.Package__c != null) {
                beverageIdSet.add (currentCase.Beverage__c);
                packageIdSet.add (currentCase.Package__c);
            }
        }
        
        beverageByIdMap = new Map<Id, Beverage__c>( [SELECT Id, Active__c, Brand__c, Country__c, Country_Code__c, 
                                                              Currently_Sold__c, Date_of_Launch__c, Flavour__c, Flavour_Code__c, 
                                                              International_Name__c, Product_Code__c, Product_Description__c, 
                                                              Type__c, Type_Code__c
                                                        FROM Beverage__c WHERE Id IN :beverageIdSet] );
        
        packageByIdMap = new Map<Id, Package__c>( [SELECT Id, Active__c, Country__c, Country_Code__c,
                                                             Packaging__c, Size__c
                                                        FROM Package__c WHERE Id IN :packageIdSet] );
    }


}