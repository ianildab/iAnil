public class ECICSObjectAccountCollections {
    private static String accountIdFieldName   = 'accountId';
    private static String contactIdFieldName   = 'contactId';
    
    public static void setNewCICAccountsOnCases(Map<String, Case> caseIdentStringMap) 
    {
      // Retrieve Accounts and Contacts from Cache Maps.
        Map<ID, Account>        cicPersonAccountIdMap       = ECICCaseTriggerAccountAndContactCache.getCICPersonAccountIdMap();
        Map<String, Account>    newCICAccountStringMap      = ECICCaseTriggerAccountAndContactCache.getNewCICAccountStringMap();
        Map<String, Contact>    newCICContactStringMap      = ECICCaseTriggerAccountAndContactCache.getNewCICContactStringMap();
        
        for (String caseIdentString : caseIdentStringMap.keySet())                                          // For each case, as identified by key 
        {
        	Account newCICPersonAccount;
            SObject currentSObject      = caseIdentStringMap.get(caseIdentString);
            Account newCICAccount       = newCICAccountStringMap.get(caseIdentString);                      // Find (Business) Account and/or
            
            if(newCICAccount != null)
            	newCICPersonAccount = cicPersonAccountIdMap.get(newCICAccount.id);                      // Person Account which should be associated with Case
            
            if(newCICPersonAccount != null){
	            if (currentSObject.get(accountIdFieldName) == null)                                             // If Case.account__c is null, 
	            {                           
	                currentSObject.put(accountIdFieldName, newCICPersonAccount.id);                             // ... assign PersonAccount Id.
	            }
            }

            if (newCICPersonAccount != null && newCICPersonAccount.RecordTypeId == ECICCommonConstants.ACCOUNT_PERSON_RT_ID)           // If newCICPersonAccount.IsPersonAccount 
            { 
                currentSObject.put(contactIdFieldName, newCICPersonAccount.PersonContactId);            // ... assign personAccount's contactId to contact__c
            }
            else if (newCICContactStringMap.containsKey(caseIdentString))                               // Alternatively, if there is a contact from the cache
            {
                currentSObject.put(contactIdFieldName, newCICContactStringMap.get(caseIdentString).id); // ... assign it to contact__c
            }
        }
    }
}