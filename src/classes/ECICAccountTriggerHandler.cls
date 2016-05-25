public /* with sharing */ class ECICAccountTriggerHandler extends SEPTriggerHandlerAbstract {
/*
    public boolean IsTriggerContext {
        get { return isTriggerExecuting;}
    }
*/
    public ECICAccountTriggerHandler (boolean isTriggerExecuting){
        super(isTriggerExecuting);
    }

    public override void OnBeforeInsert(List<sObject> newValues) {
        ECICUtils.resolveOwner(newValues, null, true);
            ECICUtils.resolveCountryCode(newValues, null, true);
        onBefore((Account[])newValues, null, true);
        setKeyStakeholder((Account[])newValues);
    }
    
    public override void OnAfterInsert(List<sObject> newValues, Map<ID, sObject> newValuesMap) {
        synchAddress((Account[])newValues, null, true);
    }
    
    public override void OnBeforeUpdate(List<sObject> oldValues, List<sObject> newValues, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        ECICUtils.resolveOwner(newValues, oldValuesMap, false);
        ECICUtils.resolveCountryCode(newValues, oldValuesMap, false);
        onBefore((List<Account>)newValues, (Map<ID, Account>)oldValuesMap, false);
        setKeyStakeholder((Account[])newValues);
       // ECICSABUFunctionalUtility.updateCaseCityFromConsumerCity((Map<ID, Account>)newValuesMap, (List<Account>)oldValues);
    }

    public override void OnAfterUpdate(List<sObject> oldValues, List<sObject> newValues, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        synchAddress((Account[])newValues, (Map<ID, Account>)oldValuesMap, false);
    }

    private void onBefore(List<Account> newObjs, Map<ID, Account> oldMap, boolean isInsert) {    
        Map<String, Id> regions = new Map<String, Id>();
        for(Region__c r:[SELECT Id, Name FROM Region__c]){ regions.put(r.Name, r.Id); }
       
        for (Account a : newObjs) 
        {
            if (!isAccount(a)) { continue; }	// This should never happen!
            
            if(a.ShippingState != null)
            { 
                if(regions.get(a.ShippingState) != null )								   { a.Region__c = regions.get(a.ShippingState); }
            }
            
            if (a.IsPersonAccount) 
            {
                if (isInsert || ECICProperNamesHelper.isNameChanged (oldMap.get(a.id), a)) { ECICProperNamesHelper.updateNames(a); }
                
                if (String.isBlank(a.Country_Code__pc) && !String.isBlank(a.Country_Code__c))	{ a.Country_Code__pc = a.Country_Code__c;  }
                else																	   		{ a.Country_Code__c  = a.Country_Code__pc; } 
            }
        }
    }
    
    private boolean isAccount(Account a) {
        return a.recordTypeId == ECICCommonConstants.ACCOUNT_BUSINESS_RT_ID || a.recordTypeId == ECICCommonConstants.ACCOUNT_PERSON_RT_ID;    
    }
    
    private boolean isPersonAccount(Account a) {
        return a.recordTypeId == ECICCommonConstants.ACCOUNT_PERSON_RT_ID;    
    }
    /**
    *    CIC-46: Account.ShippingAddress is propagated to Contact.MailingAddress
    *   //Temporary Workaround implemented for CIC-539, which need to be refactored during https://tcccdiam.atlassian.net/browse/CRM-1229 (UserInfo.getProfileId() != ECICCommonConstants.PROFILE_CRM_DATA_LOADER_ID)
    */
    private void synchAddress(List<Account> newObjs, Map<ID, Account> oldMap, boolean isInsert) {
        if (UserInfo.getProfileId() != ECICCommonConstants.PROFILE_CRM_DATA_LOADER_ID) { 

            List<Contact> contacts = new List<Contact>();
            
            for (Account a : newObjs) {
                if (a.IsPersonAccount && isPersonAccount(a)) {
                    if (isInsert || isShippingAddressChanged(oldMap.get(a.id), a)) {                    
                        Contact c = new Contact(id = a.PersonContactId);
                        c.MailingCity = a.Shipping_Municipality__c ;
                        c.MailingState = a.shipping_administrativearea__c ;
                        c.MailingCountry = a.Shipping_Country__c ;
                        c.MailingPostalCode = a.shipping_postalCode__c ;
                        c.MailingStreet = a.Shipping_Streetname1__c;
                        contacts.add(c);
                    }
                }
            }
            
            if (!contacts.isEmpty()) {
                update contacts; 
            } 
        }
    }
    
    private boolean isShippingAddressChanged(Account old, Account a) {
        return old.ShippingCity != a.ShippingCity || old.ShippingCountry != a.ShippingCountry 
                    || old.ShippingPostalCode != a.ShippingPostalCode || old.ShippingState != a.ShippingState || old.ShippingStreet != a.ShippingStreet;
    }

    private void setKeyStakeholder(List<Account> newObjs) {
        if (UserInfo.getProfileId() != ECICCommonConstants.PROFILE_CRM_DATA_LOADER_ID) { 
            for (Account a : newObjs) {
                if (a.IsPersonAccount && isPersonAccount(a)){
                    if(ECICCommonConstants.KEY_STAKEHOLDERS_PROFESSION.contains(a.Profession_Function__pc)) {
                        a.Key_Stakeholder__pc = true;
                    }/*else{
                        a.Key_Stakeholder__pc = false;
                    }*/
                }            
            } 
        }
    }    

}