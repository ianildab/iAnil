public /* with sharing */ class CRMPhoneNumberTriggerHandler extends SEPTriggerHandlerAbstract {

    public CRMPhoneNumberTriggerHandler(boolean isTriggerExecuting) {
        super(isTriggerExecuting);
    }

    // The property representation lookups will be filled up based on the PhoneNumber id field
    public override void OnBeforeInsert(List<sObject> newValues) {
		updateContactLookup((List<PhoneNumber__c>)newValues);
    }
	
	//Inserting proper Ids to Contact__c fields
	private void updateContactLookup(List<PhoneNumber__c> newValues) {
		//Collecting accountIds to a set of Ids
		Set<Id> accountIds = new Set<Id>();
		for(PhoneNumber__c loopPhoneNumber:newValues){
			accountIds.add(loopPhoneNumber.Account__c);
		}
		
		//Mapping the ContactIds to Account Ids
		Map<id,Account> idToAccount = new Map<id,Account>([SELECT Id, PersonContactId FROM Account WHERE Id IN :accountIds]);
		
		for(PhoneNumber__c loopPhoneNumber : newValues){
			if(idToAccount.containsKey(loopPhoneNumber.Account__c)){
				loopPhoneNumber.Contact__c = idToAccount.get(loopPhoneNumber.Account__c).PersonContactId;
			}		
			else{
				loopPhoneNumber.addError('There is no Account attached for the PhoneNumber(Id:'+loopPhoneNumber.Id+')');
			}
		}
    }
}