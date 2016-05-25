public class ECICCaseProductMergeStrategy extends ECICCaseProcessingStrategyAbstract {
    //#RecordType
    //private static final Set<String>            ALLOWED_CASE_RT_NAMES               = new Set<String> {'Inquiry', 'Non_quality_Complaint', 'Simplified_Quality_Complaint'};
    //private static final Set<Id>                ALLOWED_CASE_RT_IDS                 = new Set<ID>();
    //private static final Map<String, Id>        CASE_RECORD_TYPE_IDS_BY_NAME_MAP    = ECICCaseHelper.CASE_RECORD_TYPE_IDS_BY_NAME_MAP;
    private static final Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);
    private static final Map<Id, Product__c>    PRODUCT_BY_ID_MAP                   = ECICCaseTriggerProductCache.getProductByIdMap();
    private static final Map<Id, Beverage__c>   BEVERAGE_BY_ID_MAP                  = ECICCaseTriggerBeverageCache.getBeverageByIdMap();
    private static final Map<Id, Package__c>    PACKAGE_BY_ID_MAP                   = ECICCaseTriggerPackageCache.getPackageByIdMap();
    @testVisible
    private static      String errMessage                                           = null;
    @testVisible
    private static      Boolean isError                                             = false;
   //#RecordType 
   // static {
   //     for (String caseRTName : ALLOWED_CASE_RT_NAMES) {
   //         ALLOWED_CASE_RT_IDS.add(CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(caseRTName));
   //     }
   // }
    
    public override boolean OnBeforeInsert(List<sObject> newCases) {
        return doExecute((List<Case>)newCases);
    }
    
    public override boolean OnBeforeUpdate(Map<ID, sObject> oldCasesMap, Map<ID, sObject> newCasesMap) {
        return doExecute((List<Case>)newCasesMap.values());
    }
   
    
    private boolean doExecute(Case[] newCases) {
        
        for (Case currentCase : newCases) {
            Beverage__c beverage    = BEVERAGE_BY_ID_MAP.get(currentCase.Beverage__c);
            Package__c  pkg         = PACKAGE_BY_ID_MAP.get(currentCase.Package__c);
            
            if( //#RecordType    
                //ALLOWED_CASE_RT_IDS.contains(currentCase.RecordTypeID) 
                isAllowedRecordType(currentCase)
                &&  beverage != null && beverage.Active__c
                &&  pkg      != null && pkg.Active__c       ) {
                
                if (!isCountryCodeMatch(beverage, pkg)) {
                    addCaseError(currentCase, Label.Case_beverage_and_package_CC_dont_match);
                    continue;
                }
                
                Product__c caseProduct = findProduct(beverage, pkg);
                if (caseProduct != null) {
                    currentCase.Product__c = caseProduct.Id;
                } else {
                    addCaseError(currentCase, Label.Case_product_not_found);
                }
            
            }
        }
        
        return true;
    }
    
     //#RecordType
    //This method is used to check if current case belongs to allowed record type of case, added by Balmukund 
    private boolean isAllowedRecordType(Case currentCase){
        String developerName = RECORD_TYPES_BY_ID_MAP.get(currentCase.RecordTypeID).DeveloperName;
        
        if(developerName.StartsWith(ECICCommonConstants.INQUIRY_DEVNAME)
        || developerName.StartsWith(ECICCommonConstants.NONQUALITY_COMPLAINT_DEVNAME)
        || developerName.StartsWith(ECICCommonConstants.NWEN_QUALITY_COMPLAINT_DEVNAME))
         return true;
         else
         return false;
    }
    
    private static void addCaseError(Case currentCase, String caseErrMessage) {
        currentCase.addError(caseErrMessage);
        if(Test.isRunningTest()) {
            isError     = true;
            errMessage  = caseErrMessage;
        }
    }
    
    /**
      * CIC-1484
      * FOR MATCHING, USE THE CRITERIA BELOW:
      * Product and beverage match if:
      * • country codes match (it is OK if they do not match the country code of the case or the user)
      * • product descriptions match
      * • both are active
      *
      * Product and package match if:
      * • country codes match (it is OK if they do not match the country code of the case or the user)
      * • packaging of package matches package type of product 
      * • sizes match
      * • both are active
      **/
    private static Product__c findProduct(Beverage__c beverage, Package__c pkg) {
        Product__c resultProduct = null;
        
        for (Product__c product : PRODUCT_BY_ID_MAP.values()) {
            if (    product.Active__c
                &&  product.Package_Type__c             == pkg.Packaging__c
                &&  product.Size__c                     == pkg.Size__c
                &&  product.Country_Code__c             == pkg.Country_Code__c
                &&  product.Country_Code__c             == beverage.Country_Code__c
                &&  product.Product_Description__c      == beverage.Product_Description__c) {
                resultProduct = product;
                break;
            }
        }
        
        return resultProduct;
    }
    
    private static Boolean isCountryCodeMatch (Beverage__c beverage, Package__c pkg) {
        return      beverage.Country_Code__c    != null 
                &&  pkg.Country_Code__c         != null
                &&  beverage.Country_Code__c    == pkg.Country_Code__c;
    }
    
}