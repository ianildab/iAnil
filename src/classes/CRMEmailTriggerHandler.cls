public /* with sharing */ class CRMEmailTriggerHandler extends SEPTriggerHandlerAbstract {

    public CRMEmailTriggerHandler(boolean isTriggerExecuting) {
        super(isTriggerExecuting);
    }

    // The property representation lookups will be filled up based on the Email id field
    public override void OnBeforeInsert(List<sObject> newValues) {
		updateContactLookup((List<Email__c>)newValues);
    }
	
	//Inserting proper Ids to Contact__c fields
	private void updateContactLookup(List<Email__c> newValues) {
		//Collecting accountIds to a set of Ids
		Set<Id> accountIds = new Set<Id>();
		for(Email__c loopEmail:newValues){
			accountIds.add(loopEmail.Account__c);
		}
		
		//Mapping the ContactIds to Account Ids
		Map<id,Account> idToAccount = new Map<id,Account>([SELECT Id, PersonContactId FROM Account WHERE Id IN :accountIds]);
		
		for(Email__c loopEmail : newValues){
			if(idToAccount.containsKey(loopEmail.Account__c)){
				loopEmail.Contact__c = idToAccount.get(loopEmail.Account__c).PersonContactId;
			}		
			else{
				loopEmail.addError('There is no Account attached for the Email(Id:'+loopEmail.Id+')');
			}
		}
    }
}