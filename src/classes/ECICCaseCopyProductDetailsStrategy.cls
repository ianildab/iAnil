public class ECICCaseCopyProductDetailsStrategy extends ECICCaseProcessingStrategyAbstract { 

    public override boolean OnBeforeInsert(List<sObject> newCases) {
        return doExecute((List<Case>)newCases);
    }
    
    public override boolean OnBeforeUpdate(Map<ID, sObject> oldCasesMap, Map<ID, sObject> newCasesMap) {
        return doExecute((List<Case>)newCasesMap.values());
    }
    
    @testVisible private boolean doExecute(Case[] newCases) 
    {
        Map<Id, Product__c> productByIdMap = ECICCaseTriggerProductCache.getProductByIdMap();
        
        /* Copy the unit price of the product to the case */
        if (!productByIdMap.isEmpty()) 
        {
            for (Case currentCase : newCases) 
            {
            	if (productByIdMap.containsKey(currentCase.product__c)) 
            	{  
	                Product__c caseProd = productByIdMap.get(currentCase.product__c);
	                if (caseProd != null && caseProd.Product_Unit_Price__c != null) 
	                {
	                    currentCase.Product_Unit_Price__c = caseProd.Product_Unit_Price__c;  
	                }
                }
            }
        }
        return true;
    }

}