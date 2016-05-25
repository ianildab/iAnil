public /* with sharing */ class CRMEngagementBrandCopyStrategy extends SEPTriggerHandlerStrategyAbstract {
	
	private static final String REGISTRATION_INTERACTION = 'Register';

    public override boolean OnAfterInsert(Map<ID, sObject> newValuesMap) {
        copyBrandToAccount((List<Engagement__c>) newValuesMap.values());
        
        return true;
    }

    public override boolean OnAfterUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        copyBrandToAccount((List<Engagement__c>) newValuesMap.values());
        
        return true;
    }

    private void copyBrandToAccount(List<Engagement__c> engagements) {
    	Map<ID, String> accountIdToBrandMap = new Map<ID, String>();
    	
    	for (Engagement__c engagement : engagements) {
    		if (engagement.Interaction__c == REGISTRATION_INTERACTION) {
    			accountIdToBrandMap.put(engagement.Consumer__c, engagement.Brand__c);
            }
    	}
    	
    	System.debug(LoggingLevel.INFO, 'accountIdToBrandMap ---- '+accountIdToBrandMap);
    	
    	if (! accountIdToBrandMap.isEmpty()) {
    		List<Account> updatedAccounts = new List<Account>();
    		Map<String, String> brandIdToLabelMapping = getBrandIdToLabelMapping();
            System.debug(LoggingLevel.INFO, 'brandIdToLabelMapping ----- '+brandIdToLabelMapping);
    
            for (ID accountId : accountIdToBrandMap.keySet()) {
	            String brandId = accountIdToBrandMap.get(accountId);
	            String brandLabel = brandIdToLabelMapping.get(brandId);
                
                Account updateAccount = new Account(ID = accountId, ET_CRM_Registration_Brand__c = brandLabel);
                updatedAccounts.add(updateAccount);
	    	}
        
            SEPTriggerHandlerInvoker.skipObjectTriggerInvocation('Account', true);
            update updatedAccounts;
            SEPTriggerHandlerInvoker.skipObjectTriggerInvocation('Account', false);
    	}
    }
    
    private Map<String, String> getBrandIdToLabelMapping() {
    	Map<String, String> result = new Map<String, String>();
    	
    	Schema.DescribeFieldResult fieldDescription = Engagement__c.Brand__c.getDescribe();
    	List<Schema.PicklistEntry> fieldPicklistValues = fieldDescription.getPicklistValues();

		for (Schema.PicklistEntry fieldPicklistValue : fieldPicklistValues) {
			result.put(fieldPicklistValue.getValue(), fieldPicklistValue.getLabel());
			System.debug(LoggingLevel.INFO, 'fieldPicklistValue.getValue =  '+fieldPicklistValue.getValue() + ' ### fieldPicklistValue.getLabel = '+fieldPicklistValue.getLabel());
		}
		
		return result;
    }
}