public /* with sharing */ class CRMExternalIdTriggerHandler extends SEPTriggerHandlerAbstract {

    public CRMExternalIdTriggerHandler(boolean isTriggerExecuting) {
        super(isTriggerExecuting);
    }

    // The property representation lookups will be filled up based on the ExternalId id field
    public override void OnBeforeInsert(List<sObject> newValues) {
		updateContactLookup((List<ExternalId__c>)newValues);
    }
	
	//Inserting proper Ids to Contact__c fields
	private void updateContactLookup(List<ExternalId__c> newValues) {
		//Collecting accountIds to a set of Ids
		Set<Id> accountIds = new Set<Id>();
		for(ExternalId__c loopExternalId:newValues){
			accountIds.add(loopExternalId.Account__c);
		}		
		
		//Mapping the ContactIds to Account Ids
		Map<id,Account> idToAccount = new Map<id,Account>([SELECT Id, PersonContactId FROM Account WHERE Id IN :accountIds]);
		
		for(ExternalId__c loopExternalId : newValues){
			if(idToAccount.containsKey(loopExternalId.Account__c)){
				loopExternalId.Contact__c = idToAccount.get(loopExternalId.Account__c).PersonContactId;
			}		
			else{
				loopExternalId.addError('There is no Account attached for the ExternalId(Id:'+loopExternalId.Id+')');
			}
		}
    }
}