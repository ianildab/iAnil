// CRMCommunicationOptTriggerHandler handlers CommunicationOpt insertion.
// There is a need to create the lookup manually from CommunicationOpt to Opt
// using the 'Opt Id' value, which represents an external if to an Opt value.
public /* with sharing */ class CRMCommunicationOptTriggerHandler extends SEPTriggerHandlerAbstract {
    private Map<String, Opt__c> opts;
    public CRMCommunicationOptTriggerHandler(boolean isTriggerExecuting) {
        super(isTriggerExecuting);
    }
    
    // The Opt lookups possible will be modified, because we need update the given values
    // before the insertion of the values.
    public override void OnBeforeInsert(List<sObject> newValues) {
        updateOptLookup((List<CommunicationOpt__c>)newValues);
        updatePropertyRepresentationLookup((List<CommunicationOpt__c>)newValues);
		updateContactLookup((List<CommunicationOpt__c>)newValues);
    }
    
    public override void onAfterUpdate(List<sObject> oldValues, List<sObject> newValues, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        updateOptLookup((List<CommunicationOpt__c>)newValues);        
		updateContactLookup((List<CommunicationOpt__c>)newValues);
    }
    
    // Updates the lookup for every CommunicationOpt Opt values given in the input collections
    // based the values of the given OptId text values in the ComminucationOpt values,
    private void updateOptLookup(List<CommunicationOpt__c> newValues) {
    
        // Filter out the values that has invalid opt id values.
        // Invalid Opt Id is null or empty string
        // AND
        // Collect all the external ids found in the communication opt valid values
        List<CommunicationOpt__c> valuesToProccess = new List<CommunicationOpt__c>();
        Set<String> optUniqueNames = new Set<String>();
        for(CommunicationOpt__c co : newValues) {
            String optId = co.optId__c;
            if(optId == null) {
                co.addError('Opt Id was null');
            } else if (optId == '') {
                co.addError('Opt Id has empty string value');
            } else {
                optUniqueNames.add(co.optId__c);
                valuesToProccess.add(co);
            }
        }
        
        // Collects all the Opts for the given external ids
        opts = CRMOptDao.findByUniqueName(optUniqueNames);
        
        // Set all the Opt__c lookups in the CommunicationOpt values with the collected
        // Salesforce Ids
        if(trigger.isBefore){
            for(CommunicationOpt__c co : valuesToProccess) {
                String OptUniqueName = co.optId__c;
                if(opts.containsKey(OptUniqueName)) {
                    co.Opt__c = opts.get(OptUniqueName).Id;
                } else {
                    // ERROR PATH: External Id should be found
                    co.addError('There is no Opt in the system for the Unique Name: ' + OptUniqueName);
                }
            }
        }
    }
    
    // Sets all the property representation lookups in the given communication opt
    // records, based on the values of the clientId field, which should contain
    // non-emtpy values which refer a property representation record
    // through the property representation client id field
    private void updatePropertyRepresentationLookup(List<CommunicationOpt__c> newValues) {
        
        // Filter all the values which contains valid non empty client ids and
        // mark records with error in which the client id is null or empty.
        // AND
        // If the client id is valid it keeps it for further usage
        List<CommunicationOpt__c> valuesToProccess = new List<CommunicationOpt__c>();
        Set<String> clientIds = new Set<String>();
        for(CommunicationOpt__c co : newValues) {
            String clientId = co.clientId__c;
            if(clientId == null) {
                co.addError('Client ID was null');
            } else if(clientId == '') {
                co.addError('Client ID was empty string');
            } else {
                valuesToProccess.add(co);
                clientIds.add(clientId);
            }
        }
        
        // Collects all the property representation for the selected client ids
        Map<String, Property__c> propReprs = CRMPropertyDao.findByClientIds(clientIds);
        
        // Sets all the Property_Representation__c lookups with the salesforce Ids
        // if the salesforce id is found, otherwise mark the record with an error
        for(CommunicationOpt__c co : valuesToProccess) {
            String clientId = co.clientId__c;
            if(propReprs.containsKey(clientId)) {
                co.Property_Representation__c = propReprs.get(clientId).Id;
            } else {
                // ERROR PATH: This id should be found within the property representation records
                co.addError('There is no property representation in the system for the cleint id: ' + clientId);
            }
        }
        
    }
	
	//Inserting proper Ids to Contact__c fields
    private void updateContactLookup(List<CommunicationOpt__c> newValues) {
		//Collecting accountIds to a set of Ids
		Set<Id> accountIds = new Set<Id>();
        
       
        
		for(CommunicationOpt__c loopComOpt:newValues){
			accountIds.add(loopComOpt.Account__c);
		}
		
		//Mapping the ContactIds to Account Ids
		Map<id,Account> idToAccount = new Map<id,Account>([SELECT Id, PersonContactId, Com_Opts__c FROM Account WHERE Id IN :accountIds]);

		Boolean accountUpdateNeeded = false;
        
		for(CommunicationOpt__c loopCoOpt : newValues){
			if(idToAccount.containsKey(loopCoOpt.Account__c)){
                Account loopAccount = idToAccount.get(loopCoOpt.Account__c);
                if(trigger.isBefore){
                    loopCoOpt.Contact__c = loopAccount.PersonContactId;
                }
                String OptUniqueName = loopCoOpt.optId__c;                                               
                
                if(opts!=null && opts.get(OptUniqueName)!=null && opts.get(OptUniqueName).Generated_3Digit_Number__c!=null){
                    Integer loopG3DN = opts.get(OptUniqueName).Generated_3Digit_Number__c.intValue();
                	system.debug('loopG3DN 1:'+loopG3DN);
                	// This is for adding/removing the opt num to accounts Com_Opt field
                    String String3D = loopG3DN+'';
                    while(String3D.length()<3){
                        String3D='0'+String3D;
                    }
                    system.debug('String3D 1:'+String3D);

                    // Com_Opt Generated_3Digit_Number__c insert if it wasn't there
                    if(loopCoOpt.accepted__c=='true' && ( loopAccount.Com_Opts__c==null || !loopAccount.Com_Opts__c.contains(String3D))){                        
                    	if(loopAccount.Com_Opts__c==null || loopAccount.Com_Opts__c.length()<=251){
                            accountUpdateNeeded=true;
                            system.debug('Putting string:'+String3D);
                            if(loopAccount.Com_Opts__c==null){
                                loopAccount.Com_Opts__c='';
                            }
                            else if(loopAccount.Com_Opts__c.length()>0){
                                loopAccount.Com_Opts__c=loopAccount.Com_Opts__c+',';
                            }                        
                            loopAccount.Com_Opts__c= loopAccount.Com_Opts__c +String3D;
                            system.debug('Putting string loopAccount.Com_Opts__c:'+loopAccount.Com_Opts__c);
                        }
                        else{
                            system.debug('Too many opt Gen3DNum in Account:'+loopAccount.Name);
                        }
                    }
                    //If it is not accepted but in the account object
                    else if(loopCoOpt.accepted__c=='false' && loopAccount.Com_Opts__c!=null && loopAccount.Com_Opts__c.contains(String3D)){                        
                        accountUpdateNeeded=true;
                        
                        system.debug('Removing string loopAccount.Com_Opts__c:'+String3D);                        
                        if(loopAccount.Com_Opts__c.contains(','+String3D)){    
                            loopAccount.Com_Opts__c=loopAccount.Com_Opts__c.replaceAll(','+String3D , '');
                        }
                        else if(loopAccount.Com_Opts__c.contains(String3D+',')){
                            loopAccount.Com_Opts__c=loopAccount.Com_Opts__c.replaceAll(String3D+',' , '');
                        }
                        else{
                            loopAccount.Com_Opts__c=loopAccount.Com_Opts__c.replaceAll(String3D,'');
                        }
						system.debug('Removing string loopAccount.Com_Opts__c:'+loopAccount.Com_Opts__c);                        
                    }
                    system.debug('loopAccount.Com_Opts__c:'+loopAccount.Com_Opts__c);
                }
                else{
                    System.debug(opts.get(OptUniqueName)+'The opt does not have a generated number');
                }
                
			}		
			else{
				loopCoOpt.addError('There is no Account attached for the CommunicationOpt(Id:'+loopCoOpt.Id+')');
			}
		}
        if(accountUpdateNeeded){
            update idToAccount.values();
        }
        
    }
    
    
	
}