public /* with sharing */ class CRMLegalAcceptanceTriggerHandler extends SEPTriggerHandlerAbstract {
    
    //private static final Boolean USE_LEGAL_ACCEPTANCE_PROPERTY_LOOKUP = false; // temporary flag requested by Zsolt_Penzes
    private static final String FIELD_SEPARATOR = ';';
    
    public CRMLegalAcceptanceTriggerHandler(boolean isTriggerExecuting){
        super(isTriggerExecuting);
    } 

    public override void OnBeforeInsert(List<sObject> newValues) {
        setLegalAcceptanceLookup(newValues);
        setPropertyRepresentationLookup(newValues);
		updateContactLookup((List<LegalAcceptance__c>)newValues);
    }

    public override void OnAfterInsert(List<sObject> newValues, Map<ID, sObject> newValuesMap) {
        updatePersonAccountCountryOfLegalJurisdictionList((List<LegalAcceptance__c>)newValues);	
    }
    
    private void setLegalAcceptanceLookup(List<LegalAcceptance__c> newValues) {
        Set<String> legalAcceptanceExtIds = new Set<String>();
        
        // LegalAcceptances that contains valid (not null or not empty string) legal acceptance ids
        // NOTE: Accepted Legal Acceptance to Legal Acceptance
        List<LegalAcceptance__c> valuesToProcess = new List<LegalAcceptance__c>();
        
        // Filter out the wrong values
        for (LegalAcceptance__c newAcceptedLegalAcceptance : newValues) {
            String legalAcceptanceId = newAcceptedLegalAcceptance.legalAcceptanceId__c;
            if(legalAcceptanceId == null) {
                newAcceptedLegalAcceptance.addError('LegalAcceptance id was null');
            } else if(legalAcceptanceId == '') {
                newAcceptedLegalAcceptance.addError('LegalAcceptance id was empty');
            } else {
                valuesToProcess.add(newAcceptedLegalAcceptance);
            }
        }
        
        // Process the right values
        for (LegalAcceptance__c newAcceptedLegalAcceptance : valuesToProcess) {
            if (newAcceptedLegalAcceptance.Legal_Acceptance__c == null) {
                legalAcceptanceExtIds.add(newAcceptedLegalAcceptance.legalAcceptanceId__c);
            }
        }
        
        if (! legalAcceptanceExtIds.isEmpty()) {
            Map<String, Legal_Acceptance__c> legalAcceptancesByExtId = CRMLegalAcceptanceDao.findByExtId(legalAcceptanceExtIds);

            for (LegalAcceptance__c newAcceptedLegalAcceptance : valuesToProcess) {
                
                if (newAcceptedLegalAcceptance.Legal_Acceptance__c == null) {
                    Legal_Acceptance__c legalAcceptance = legalAcceptancesByExtId.get(newAcceptedLegalAcceptance.legalAcceptanceId__c);
                    
                    if (legalAcceptance != null) {
                        newAcceptedLegalAcceptance.Legal_Acceptance__c = legalAcceptance.Id;
                    }
                }
            }
        }
    }

    private void setPropertyRepresentationLookup(List<LegalAcceptance__c> newValues) {
        Set<String> propertyRepresentationClientIds = new Set<String>();
        
        // Values that contains valid client ids (not null or not empty string), that refer to a property representation
        List<LegalAcceptance__c> valuesToProcess = new List<LegalAcceptance__c>();
        
        // Filter out the wrong values
        for(LegalAcceptance__c newAcceptedLegalAcceptance : newValues) {
            String ClientId = newAcceptedLegalAcceptance.ClientId__c;
            if(ClientId == null) {
                newAcceptedLegalAcceptance.addError('ClientId was null');
            } else if(ClientId == '') {
                newAcceptedLegalAcceptance.addError('ClientId was empty');
            } else {
                valuesToProcess.add(newAcceptedLegalAcceptance);
            }
        }
        
        // Process the right values
        for (LegalAcceptance__c newAcceptedLegalAcceptance : valuesToProcess) {
            if (newAcceptedLegalAcceptance.Property_Representation__c == null) {
                propertyRepresentationClientIds.add(newAcceptedLegalAcceptance.ClientId__c);
            }
        }
        
        if (! propertyRepresentationClientIds.isEmpty()) {
            Map<String, Property__c> propertiesByClientId = CRMPropertyDao.findByClientIds(propertyRepresentationClientIds);
            
            for (LegalAcceptance__c newAcceptedLegalAcceptance : valuesToProcess) {
                if (newAcceptedLegalAcceptance.Property_Representation__c == null) {
                    Property__c property = propertiesByClientId.get(newAcceptedLegalAcceptance.ClientId__c);
                    
                    if (property != null) {
                        newAcceptedLegalAcceptance.Property_Representation__c = property.Id;
                    }
                }
            }
        }        
    }
    
    private void updatePersonAccountCountryOfLegalJurisdictionList(List<LegalAcceptance__c> newValues) {
        
        Set<ID> personAccountIds = new Set<ID>();
        Set<ID> propertyRepresentationIds = new Set<ID>();

        for (LegalAcceptance__c legalAcceptance : newValues) {
            personAccountIds.add(legalAcceptance.Account__c);
            propertyRepresentationIds.add(legalAcceptance.Property_Representation__c);
        }
        
        Map<ID, Account> personAccounts = new Map<ID, Account>([SELECT ID, Country_of_Legal_Jurisdiction_List__c FROM Account WHERE id IN :personAccountIds]); // this should go into a separate DAO class
        Map<ID, Property__c> propertyRepresentations = new Map<ID, Property__c>([SELECT ID, Parent__r.Country_of_Legal_Jurisdiction__c FROM Property__c WHERE id IN :propertyRepresentationIds]); // this should go into a separate DAO class
        
        for (LegalAcceptance__c legalAcceptance : newValues) {
            Account personAccount = personAccounts.get(legalAcceptance.Account__c); // LegalAcceptance__c.Account__c is a Master-Detail field
            Property__c propertyRepresentation = propertyRepresentations.get(legalAcceptance.Property_Representation__c);
            
            if (propertyRepresentation != null) {
                String country = propertyRepresentation.Parent__r.Country_of_Legal_Jurisdiction__c;
    
                if (String.isNotBlank(country)) {
                    
                    if (personAccount.Country_of_Legal_Jurisdiction_List__c == null
                        || ! personAccount.Country_of_Legal_Jurisdiction_List__c.contains(country)) {
                            
                        // Put country on the Consumer's Country_of_Legal_Jurisdiction_List
                        
                        if (personAccount.Country_of_Legal_Jurisdiction_List__c == null) {
                            
                            personAccount.Country_of_Legal_Jurisdiction_List__c = country;
                            
                        } else {
                            Set<String> countries = new Set<String>(personAccount.Country_of_Legal_Jurisdiction_List__c.split(FIELD_SEPARATOR));
                            countries.add(country);
                            personAccount.Country_of_Legal_Jurisdiction_List__c = String.join(new List<String>(countries), FIELD_SEPARATOR);
                        }
                    }
                } else {
                    System.debug(LoggingLevel.WARN, 'Property representation [ClientId: '+legalAcceptance.ClientId__c+'] parent country is blank!');
                }
            }
        }
        
        update personAccounts.values();
    }
	
	//Inserting proper Ids to Contact__c fields
	private void updateContactLookup(List<LegalAcceptance__c> newValues) {
		//Collecting accountIds to a set of Ids
		Set<Id> accountIds = new Set<Id>();
		for(LegalAcceptance__c loopLegalAcc:newValues){
			accountIds.add(loopLegalAcc.Account__c);
		}
		
		//Mapping the ContactIds ot Account Ids
		Map<id,Account> idToAccount = new Map<id,Account>([SELECT Id, PersonContactId FROM Account WHERE Id IN :accountIds]);
		
		for(LegalAcceptance__c loopLegalAcc : newValues){
			if(idToAccount.containsKey(loopLegalAcc.Account__c)){
				loopLegalAcc.Contact__c = idToAccount.get(loopLegalAcc.Account__c).PersonContactId;
			}		
			else{
				loopLegalAcc.addError('There is no Account attached for the Legal Acceptance(Id:'+loopLegalAcc.Id+')');
			}
		}
    }
    
}