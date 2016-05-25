trigger CRMChangeConsumerStatusTrigger on Engagement__c (before insert, before update) {
  
    // Create a Map containing the consumers to avoid duplicate account error. There are 
    // several engagements referring to the same Account. A List cannot be updated (DML) 
    // containing the same Account multiple times as it will throw a Duplicate ID exception.
    // Thus, Accounts are collected in a Map and checked if the map already contains the 
    // account that the engagement refers to.
    Map<String, Account> consumerMap = new Map<String, Account>();
    
    // Create a list to hold the accounts that we need to update
    List<Account> updatedConsumers = new List<Account>();
    
    //Get the current values of consumer status for the accounts related to the engagements in the batch
    Set<id> accountIds = new Set<id>();
    for (Engagement__c e: trigger.new) accountIds.add(e.Consumer__c);
    Map<id,Account> accountMap = new Map<id,Account>([SELECT Id, Consumer_Status__pc, PersonContactId FROM Account WHERE Id in :accountIds]);
    
    List<RecordType> result = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Coke_ID_Engagement'];
    System.debug(Logginglevel.DEBUG, 'Coke_ID_Engagement result list' + result);
    String COKE_ID_ENGAGEMENT_RECORD_TYPE_ID = result[0].id;
    
    // Step through the list of engagements in the trigger
    for ( Engagement__c engagement : trigger.new ) { 
        if ( engagement.Consumer__c != NULL ) { 
            Account consumer = new Account( Id = engagement.Consumer__c );
            
            Account consumerForEngagement = accountMap.get(engagement.Consumer__c);
            
            // Exacttarget integration: Link engagement with it's contact for ability
            // to create engagement involved reports for exact target.
            engagement.Contact__c = consumerForEngagement.PersonContactId;
            
            // Fix for CRM-723
            //consumer.Consumer_Status__pc = engagement.Consumer__r.Consumer_Status__pc;
            consumer.Consumer_Status__pc = consumerForEngagement.Consumer_Status__pc;
            
            // Check if the consumer was already updated in a previous engagement in the iteration. If the map 
            // doesn't contain the conusmer, add it to the map. Otherwise, get the consumer from the map and
            // update its fields
            if ( consumerMap.isEmpty() || !consumerMap.containsKey( consumer.Id ) ) {
                consumerMap.put( consumer.Id, consumer );
            } else {
                consumer = consumerMap.get( consumer.Id );
            }            
                        
            // Interaction values are hard-coded constants. We might be able to query these from the translation 
            // programatically but for now it is hard coded.
            /*
                Consumer Statuses:
                0 - Active - active
                1 - Inactive - inactive
                2 - Blocked - blocked
                3 - Deleted - piiremoved / markedfordeletion
                
                Interactions:
                1 - Register
                2 - Activate Account
                3 - Request Account Deletion
                4 - Remove PII
                13 - Delete Not Activated Account
            */
           
            if (engagement.recordTypeId == COKE_ID_ENGAGEMENT_RECORD_TYPE_ID ){
                if ( engagement.Interaction__c == 'Register' && ( consumer.Consumer_Status__pc != 'Active' && consumer.Consumer_Status__pc != 'Piiremoved' ) ) {
                    consumer.Consumer_Status__pc = 'Inactive';
                } else if ( engagement.Interaction__c == 'Activate Account' ) {
                    // set up the Account Activation Date
                    // .date() returns the Date component of a Datetime in the local time zone of the context user.
                    if ( engagement.Create_Date__c != null ) {
                        consumer.Activation_Date__pc = engagement.Create_Date__c.date();
                    }
                    // set the Consumer Status to Active only if it was not Piiremoved before
                    if ( consumer.Consumer_Status__pc != 'Piiremoved' ) {
                        consumer.Consumer_Status__pc = 'Active';
                    }
                } else if ( engagement.Interaction__c == 'Remove PII' || engagement.Interaction__c == 'Delete Not Activated Account' ) {
                    consumer.Consumer_Status__pc = 'Piiremoved';

                    // Clear down the PII fields as required
                    consumer.Salutation = '';
                    consumer.FirstName = '';
                    consumer.LastName = 'No disponible';
                    consumer.PersonBirthdate = NULL;
                    consumer.PersonEmail = '';
                    consumer.PersonHasOptedOutOfEmail = TRUE; // this is not PII but still required not to send any emails to deleted consumers
                    consumer.BillingStreet = ''; // Country, State, City and Zip Code are not PII thus not deleted
                    consumer.ShippingStreet = '';
                    consumer.PersonMailingStreet = '';
                    consumer.PersonOtherStreet = '';
                    consumer.Fax = NULL;
                    consumer.Phone = NULL;
                    consumer.PersonHomePhone = NULL;
                    consumer.PersonMobilePhone = NULL;
                    consumer.PersonOtherPhone = NULL;
                    consumer.Screen_Name__pc = '';
                    consumer.sf4twitter__Fcbk_User_Id__pc = '';
                    consumer.sf4twitter__Twitter_User_Id__pc = ''; 
                    consumer.Identity_Card_Number__pc = '';
                    consumer.Website = NULL;
                }
            }
        }
    }

    updatedConsumers.addAll( consumerMap.values() );
  
    //We have finished stepping through the engagements and have a list of accounts.
    //If that list is not empty then we can run the update
    if( !updatedConsumers.isEmpty() ) {
 //     System.debug('Updated consumers lenght:_' + updatedConsumers.size());
        update updatedConsumers;
    }
}