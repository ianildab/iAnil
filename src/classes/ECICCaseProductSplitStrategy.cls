public class ECICCaseProductSplitStrategy extends ECICCaseProcessingStrategyAbstract {
    private static final Map<Id, Product__c>    PRODUCT_BY_ID_MAP                   = ECICCaseTriggerProductCache.getProductByIdMap();
    private static final Map<Id, Beverage__c>   BEVERAGE_BY_ID_MAP                  = ECICCaseTriggerBeverageCache.getBeverageByIdMap();
    private static final Map<Id, Package__c>    PACKAGE_BY_ID_MAP                   = ECICCaseTriggerPackageCache.getPackageByIdMap();
    private static final Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);
    private static       List<String>           notificationMsgList                 = new List<String>();
    
    public override boolean OnBeforeInsert(List<sObject> newCases) {
        return doExecute((List<Case>)newCases);
    }
    
    public override boolean OnBeforeUpdate(Map<ID, sObject> oldCasesMap, Map<ID, sObject> newCasesMap) {
        return doExecute((List<Case>)newCasesMap.values());
    }
    
    private boolean doExecute(Case[] newCases) {
        
        for (Case currentCase : newCases) {
            
            if(isQualityComplaint(currentCase) && currentCase.product__c != null) {
                Product__c currentCaseProduct = PRODUCT_BY_ID_MAP.get(currentCase.product__c);
                
                if (currentCaseProduct != null && currentCaseProduct.Active__c) {
                    Beverage__c beverage    = findBeverageByProduct(currentCaseProduct);
                    Package__c  pkg         = findPackageByProduct(currentCaseProduct);
                    
                    currentCase.Beverage__c = verifyObjectId(currentCase,  beverage,   currentCaseProduct);
                    currentCase.Package__c  = verifyObjectId(currentCase,  pkg,        currentCaseProduct);
                }
            }
        }
        
        if (notificationMsgList.size() > 0) { notifySupportAboutSearchWarnings(); }
        return true;
    }
    
    private static Id verifyObjectId(Case currentCase, sObject obj, Product__c currentCaseProduct) {
        if (obj.Id == null) {
            String notificationStr = createNotificationString(currentCase, obj, currentCaseProduct);
            notificationMsgList.add(notificationStr);
        }
        
        return obj.Id;
    }
    
    private static Boolean isQualityComplaint(Case currentCase) {
        //#RecordType
        //return currentCase.RecordTypeID == ECICCommonConstants.CASE_QUILITY_COMPLAINT_RT_ID;
        return RECORD_TYPES_BY_ID_MAP.get(currentCase.RecordTypeID).DeveloperName.StartsWith(ECICCommonConstants.QUALITY_COMPLAINT_DEVNAME);
    }
    
    /**
      * CIC-1484
      * FOR MATCHING, USE THE CRITERIA BELOW:
      * Product and beverage match if:
      * • country codes match (it is OK if they do not match the country code of the case or the user)
      * • product descriptions match
      * • both are active
      **/
    private static Beverage__c findBeverageByProduct(Product__c product) {
        Beverage__c resultBeverage = new Beverage__c();
        
        for (Beverage__c beverage : BEVERAGE_BY_ID_MAP.values()) {
            if (    beverage.Active__c
                &&  product.Country_Code__c         == beverage.Country_Code__c
                &&  product.Product_Description__c  == beverage.Product_Description__c) {
                resultBeverage = beverage;
                break;
            }
        }
        
        return resultBeverage;
    }
    
    /**
      * CIC-1484
      * FOR MATCHING, USE THE CRITERIA BELOW:
      * Product and package match if:
      * • country codes match (it is OK if they do not match the country code of the case or the user)
      * • packaging of package matches package type of product 
      * • sizes match
      * • both are active
      **/
    private static Package__c findPackageByProduct(Product__c product) {
        Package__c resultPackage = new Package__c();
        
        for (Package__c pkg : PACKAGE_BY_ID_MAP.values()) {
            if (    pkg.Active__c
                &&  product.Country_Code__c == pkg.Country_Code__c
                &&  product.Package_Type__c == pkg.Packaging__c
                &&  product.Size__c         == pkg.Size__c) {
                resultPackage = pkg;
                break;
            }
        }
        
        return resultPackage;
    }
    
    private static String createNotificationString(Case errCase, sObject notFoundObject, Product__c product) {
        Schema.DescribeSObjectResult sObjectDescribeInfo = notFoundObject.getSObjectType().getDescribe();
        return  'No ' + sObjectDescribeInfo.getName() 
                      + ' was found for the next Product:\n Product: ' + product 
                      + '\n\nCase: ' + errCase +'\n';
    }
    
    private static void notifySupportAboutSearchWarnings() {
        String message = '';
        for (String notificationItem : notificationMsgList) {
            message += notificationItem;
        }
        
        String addressee = General_Settings__c.getInstance().supportEmail__c;
        if (String.isNotBlank(addressee)) {
            String subject = '[CaseTriggerHandler|ECICCaseProductSplitStrategy] WARNINGS on Case processing';
            ECICCaseTriggerEmailMessageCache.addEmailMessageToSendList (new List<String>{addressee}, subject, message);
        }
    }
}