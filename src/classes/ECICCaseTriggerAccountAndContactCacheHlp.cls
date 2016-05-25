public class ECICCaseTriggerAccountAndContactCacheHlp 
{
    private static Map<String, Case> sObjectIdentifyingStringMap        = ECICCaseTriggerAccountAndContactCache.getEmailAndWebCaseIdentStringMap();    
    private static Map<String, Region__c>   regionsByExtId              = ECICCaseTriggerAccountAndContactCache.getRegionsByExtId();
    private static List<Contact>            updateCICContactList        = ECICCaseTriggerAccountAndContactCache.getUpdateCICContactList();    
    private static Map<String, Account>     newCICAccountStringMap      = ECICCaseTriggerAccountAndContactCache.getNewCICAccountStringMap();
    private static Map<String, Contact>     newCICContactStringMap      = ECICCaseTriggerAccountAndContactCache.getNewCICContactStringMap();    
    private static Set<String>              countryCodeSet              = ECICCaseTriggerAccountAndContactCache.getCountryCodeSet();    
    private static String                   accountIdFieldName          = 'accountId';
    private static String                   contactIdFieldName          = 'contactId';
    private static String                   placeFieldName              = 'Place_of_Purchase__c';

    // ---------------------------------------------------------------------------------------------------

    public static void assignContactsToSObjects(Map<String, Contact[]> cicContactStringMap) 
    {
        SObject currentSObject = null;
        for (String identString : cicContactStringMap.keySet())                 // find a proper Account 
        {                                        
            currentSObject                              = (SObject) sObjectIdentifyingStringMap.get(identString);
            Contact[] CICContacts = cicContactStringMap.get(identString);

            if (CICContacts != null && !CICContacts.isEmpty())  { setContactFromStreamlineEnumContactMap(CICContacts, currentSObject); }
        }
    }

    private static void setContactFromStreamlineEnumContactMap(List<Contact> cicContactArray, SObject currentSObject) 
    {
        Map<String, String>      fieldNameValueMap = new Map<String, String>();
                                 fieldNameValueMap.put('Email',                          (String) currentSObject.get('SuppliedEmail'));
                                 fieldNameValueMap.put('Phone',                          (String) currentSObject.get('SuppliedPhone'));
                                 fieldNameValueMap.put('MobilePhone',                    (String) currentSObject.get('SuppliedMobile__c'));
                                 fieldNameValueMap.put('HomePhone',                      (String) currentSObject.get('SuppliedHomePhone__c'));
                                 fieldNameValueMap.put('OtherPhone',                     (String) currentSObject.get('SuppliedOtherPhone__c'));

            Contact contact = null;
            List<String> orderedFieldNameList = new List<String>{ 'Email', 'Phone', 'MobilePhone', 'HomePhone', 'OtherPhone' }; //  We need this because keys are not ordered. 
            for (String fieldName : orderedFieldNameList) 
            {
                contact = searchContactsForUniqueByFieldAndValue(cicContactArray, fieldName, fieldNameValueMap.get(fieldName));
                if (contact != null)                                    // if exactly one Contact is found by email/phone then assign it to the Case; otherwise do nothing 
                { 
                    setContactFromSearch(currentSObject, contact);
                    break; 
                }
            }
    }

    private static void setContactFromSearch(SObject currentSObject, Contact contact) 
    {
        if (currentSObject.get(accountIdFieldName) == null) { currentSObject.put(accountIdFieldName, contact.AccountId); }
        if (currentSObject.get(contactIdFieldName) == null) { currentSObject.put(contactIdFieldName, contact.Id);        }
        
        if (currentSObject.get('Sub_Channel__c') != null) 
        {
            string subChannel = (string)currentSObject.get('Sub_Channel__c');
            contact.Sub_Channel__c = subChannel;
        }
  
        // Workaround to error: INVALID_FIELD_FOR_INSERT_UPDATE, Account: bad field names on insert/update call:  AccountId: [ AccountId]
        boolean hasCicContactUpdate = updateContact(contact, currentSObject, false);
        if (hasCicContactUpdate)  {  updateCICContactList.add(createLimitedUpdateContact (contact));  } // update contact's empty fields
    }

    private static Contact searchContactsForUniqueByFieldAndValue(Contact[] contactArray, String fieldName, String searchValue) 
    {
        List<String> fieldsToCheckList = new List<String>{ fieldName };
        if (fieldName.contains('Phone'))                                                                            
        {                                                                                                       
            Set<String> phoneFieldSet    = new Set<String>{'Phone', 'MobilePhone', 'HomePhone', 'OtherPhone'};         // We need to check all the phone fields.
                        phoneFieldSet.remove(fieldName);                                                               // We want to check this first, but not twice.
            fieldsToCheckList.addAll(phoneFieldSet);
        }
        
        Contact result = null;
        for (String fieldToCheck : FieldsToCheckList)                           
        {
            for (Contact contact : contactArray) 
            {
                if ( ((String) contact.get(fieldToCheck) == searchValue) && (result == null) )  { result = contact; }  // contact found and contact is unique (thus-far) 
                else                                                                            { return null;      }  // duplicate contact found -> return null
        }
        }
        
        return result;
    }

    // ---------------------------------------------------------------------------------------------------

    // We only want/need to update name/email/phone on the object
    private static Contact createLimitedUpdateContact (Contact contactValueContainer) 
    {
        return new Contact(
                            ID              = contactValueContainer.ID,
                            FirstName       = contactValueContainer.FirstName,
                            LastName        = contactValueContainer.LastName,
                            Email           = contactValueContainer.Email,
                            Phone                       = contactValueContainer.Phone,
                            HomePhone                   = contactValueContainer.HomePhone,
                            MobilePhone                 = contactValueContainer.MobilePhone,
                            OtherPhone                  = contactValueContainer.OtherPhone,

                            Country_code__c             = contactValueContainer.Country_code__c,
                            MailingCountry              = contactValueContainer.MailingCountry,
                            Mailing_Country__c          = contactValueContainer.Mailing_Country__c,

                            Mailing_Municipality__c     = contactValueContainer.Mailing_Municipality__c,
                            Mailing_Streetname1__c      = contactValueContainer.Mailing_Streetname1__c,
                            Mailing_Streetname2__c      = contactValueContainer.Mailing_Streetname2__c,
                            Mailing_PostalCode__c       = contactValueContainer.Mailing_PostalCode__c,
                            
                            sf4twitter__Fcbk_User_Id__c = contactValueContainer.sf4twitter__Fcbk_User_Id__c,
                            LeadSource                  = contactValueContainer.LeadSource,
                            Sub_Channel__c              = contactValueContainer.Sub_Channel__c,
                            HasOptedOutOfEmail          = contactValueContainer.HasOptedOutOfEmail,
                            HasOptedOutOfFax            = contactValueContainer.HasOptedOutOfFax,
                            DoNotCall                   = contactValueContainer.DoNotCall
                          );
    }

    // ---------------------------------------------------------------------------------------------------------------------------------------------

    public static List<Map<String, SObject>> createAccountsAndContactsToSObjectsIdMapList() 
    {
        Map<String, ID>     caseToNonCICAccountStringIdentifierMap  = ECICCaseTriggerAccountAndContactCache.getCaseToNonCICAccountStringIdentifierMap();
        Map<String, ID>     caseToNonCICContactStringIdentifierMap  = ECICCaseTriggerAccountAndContactCache.getCaseToNonCICContactStringIdentifierMap();
        
        // Clone Accounts (person & business); Person and Business account fields must be queried separetelly for cloning as 'Name' field is read-only for Person Accounts
        Map<ID, Account> nonCICAccountsToClone = new Map<ID, Account>();
                         nonCICAccountsToClone.putAll(ECICCaseTriggerAccountAndContactCache.getBusinessAccountsByIdsToClone());
                         nonCICAccountsToClone.putAll(ECICCaseTriggerAccountAndContactCache.getPersonAccountsByIdsToClone()); // 'Name' field is not queried here
        
        Map<SObject, SObject> clonedNonCICAccounts  = (Map<SObject, SObject>) cloneObjects((List<SObject>)nonCICAccountsToClone.values());
        Map<String, SObject>  newCICAccountIdMap    = mapClonedObjectsToSObjects(caseToNonCICAccountStringIdentifierMap, nonCICAccountsToClone, clonedNonCICAccounts); 
        
        // Clone Contacts of business accounts
        Map<ID, Contact>      nonCICContactsToCloneContactIdMap = ECICCaseTriggerAccountAndContactCache.getNonCICContactsByIdsToClone();
        Map<SObject, SObject> clonedNonCICContactsSObjectMap    = (Map<SObject, SObject>) cloneObjects(nonCICContactsToCloneContactIdMap.values());
        Map<String, SObject>  newCICContactIdMap                = mapClonedObjectsToSObjects(caseToNonCICContactStringIdentifierMap, nonCICContactsToCloneContactIdMap, clonedNonCICContactsSObjectMap);
        
        List<Map<String, SObject>>  resultIdMapList             = new List<Map<String, SObject>>();
                                    resultIdMapList.add(newCICAccountIdMap);
                                    resultIdMapList.add(newCICContactIdMap);
        return resultIdMapList;
    }

    // ---------------------------------------------------------------------------------------------------

    /*
     * Cloning objects is done through an sobject to sobject mapping to avoid potential double cloning
     */
    private static Map<SObject, SObject> cloneObjects(SObject[] objectArray) 
    {
        Map<SObject, SObject> resultSObjectMap = new Map<SObject, SObject>();
        for (SObject originalObject : objectArray) {
            if (! resultSObjectMap.containsKey(originalObject)) {
                SObject sObjectClone = null;
                
                if (originalObject.getSObjectType() == Account.SObjectType) {
                    sObjectClone = (SObject) ECICAccountDao.clone((Account) originalObject);
                    //sObjectClone.put('RecordTypeId',      ECICCommonConstants.ACCOUNT_PERSON_RT_ID);
                } else {
                    sObjectClone = originalObject.clone(false, true);
                }
                
                resultSObjectMap.put(originalObject, sObjectClone); 
            }
        }
        return resultSObjectMap;
    }

    private static Map<String, SObject> mapClonedObjectsToSObjects(Map<String, ID> caseToOriginalObjectStringMap, Map<String, SObject> originalObjectStringMap, Map<SObject, SObject> clonedObjectMap) 
    {
        Map<String, SObject> resultSObjectStringMap = new Map<String, SObject>();
        // map the new clones to the SObjects
        for (String SObjectstring : caseToOriginalObjectStringMap.keySet()) {
            String  originalObjectString    = caseToOriginalObjectStringMap.get(SObjectstring);
            SObject originalObject          = originalObjectStringMap.get(originalObjectString);
            SObject cloneObject             = clonedObjectMap.get(originalObject);
            
            resultSObjectStringMap.put(SObjectstring, cloneObject);
        }
        return resultSObjectStringMap;
    }

    private static Map<String, SObject> mapClonedObjectsToSObjects(Map<String, ID> caseToOriginalObjectStringMap, Map<ID, SObject> originalObjectIdMap, Map<SObject, SObject> clonedObjectMap) 
    {
        return mapClonedObjectsToSObjects(caseToOriginalObjectStringMap, ECICMapHelper.castIdMapToStringMap(originalObjectIdMap), clonedObjectMap);
    }

    private static Map<String, SObject> mapClonedObjectsToSObjects(Map<ID, ID> caseToOriginalObjectIdMap, Map<ID, SObject> originalObjectIdMap, Map<SObject, SObject> clonedObjectMap) 
    {
        return mapClonedObjectsToSObjects(ECICMapHelper.castIdMapToStringMap(caseToOriginalObjectIdMap), ECICMapHelper.castIdMapToStringMap(originalObjectIdMap), clonedObjectMap);
    }

    //--------------------------------------------------------------------------------------------------------------------------------------------
    // This will need to be modified to return a string.        
    public static void createNewCICAccountStringMap (Map<String, SObject> sobjectAccountsBySObjectId) 
    {
        for (String sObjectStringId : sobjectAccountsBySObjectId.keySet()) {
            Account currentAccount  = (Account) sObjectAccountsBySObjectId.get(sObjectStringId);
            sObject currentSObject  = sObjectIdentifyingStringMap.get(sObjectStringId);  
            
            if (currentAccount.RecordTypeId == ECICCommonConstants.ACCOUNT_PERSON_RT_ID)    // set values explicitly on the cloned object 
            {   
                updatePersonAccount(currentAccount, currentSObject);
            }
            
            if ( String.isBlank(currentAccount.ShippingCity)) { // Set shipping address on cloned person/business accounts (web2case provides such information) 
                String placeOfPurchase = null;
                if (regionsByExtId.containsKey((String) currentSObject.get(placeFieldName))) {
                    placeOfPurchase = regionsByExtId.get((String) currentSObject.get(placeFieldName)).Name;
                }
                currentAccount.ShippingCity = placeOfPurchase;
            }
            
            if ( String.isBlank(currentAccount.ShippingCountry)) {  // Set shipping country 
                currentAccount.ShippingCountry = (String) currentSObject.get('Country_Code__c');
            }
            
            newCICAccountStringMap.put(sObjectStringId, currentAccount);
        }
    }

    public static void createNewCICContactStringMap (Map<String, SObject> sobjectContactsBySObjectId) 
    {
        for (String sObjectStringId : sobjectContactsBySObjectId.keySet()) {
            Contact currentContact      = (Contact) sobjectContactsBySObjectId.get(sObjectStringId);
            SObject currentSObject      = sObjectIdentifyingStringMap.get(sObjectStringId);
            updateContact(currentContact, currentSObject, true );  // set values explicitly on the cloned object
            newCICContactStringMap.put( sObjectStringId, currentContact);
        }
    }

// -----------------------------------------------------------------------------------------------------------------------------------------------------------

    public static void insertBusinessAccountContacts() 
    {
        if ((newCICContactStringMap != null) && (! newCICContactStringMap.isEmpty()))               // Link contacts to accounts
        { 
            for (String sObjectStringId : newCICContactStringMap.keySet()) 
            {
                if (newCICAccountStringMap.containsKey(sObjectStringId)) 
                {
                    Account newCICAccount = newCICAccountStringMap.get(sObjectStringId);            // It is not clear how this value could be useful since this is not in the map to be inserted.
                    if (newCICAccount.RecordTypeId == ECICCommonConstants.ACCOUNT_BUSINESS_RT_ID)   // Someone did this "just for sure", bit I'm not sure of what.
                    {  
                        Contact newCICContact           = newCICContactStringMap.get(sObjectStringId);
                                newCICContact.AccountId = newCICAccount.Id;                         // It is not clear how this value could be useful since this is not in the map to be inserted. 
                    }
                }
            }
            insert newCICContactStringMap.values();
        }
    }

// -----------------------------------------------------------------------------------------------------------------------------------------------------------

   private static boolean updateSObject(SObject sObjectRecord, Boolean isAccount, SObject currentSObject, Boolean forceUpdate) 
   {
        Map<String, String> suppliedNameMap   = ((currentSObject.get('SuppliedLastName__c') != null) || (currentSObject.get('SuppliedName') != null))
                                                    ?  getNameMap(currentSObject)
                                                    :  new Map<String, String>();

        Boolean result      = false;
                result     |= updateSObject    (sObjectRecord,                           'FirstName',                          suppliedNameMap.get('firstName'),                      forceUpdate);   
                result     |= updateSObject    (sObjectRecord,                           'LastName',                           suppliedNameMap.get('lastName') ,                      forceUpdate);   
                result     |= updateSObject    (sObjectRecord, ((isAccount)?'person':'')+'Email',                      (String) currentSObject.get('SuppliedEmail'),                  forceUpdate);   

                result     |= updatePhone      (sObjectRecord,                                                                  currentSObject,                                       forceUpdate);
                result     |= updateSObject    (sObjectRecord, ((isAccount)?'person':'')+'HomePhone',                  (String) currentSObject.get('SuppliedHomePhone__c'),           forceUpdate);   
                result     |= updateSObject    (sObjectRecord, ((isAccount)?'person':'')+'MobilePhone',                (String) currentSObject.get('SuppliedMobile__c'),              forceUpdate);   
                result     |= updateSObject    (sObjectRecord, ((isAccount)?'person':'')+'OtherPhone',                 (String) currentSObject.get('SuppliedOtherPhone__c'),          forceUpdate);   
                   
                result     |= updateSObject    (sObjectRecord, 'sf4twitter__Fcbk_User_Id__'+((isAccount)?'p':'')+'c',  (String) currentSObject.get('SuppliedFcbk_User_Id__c'),        forceUpdate);    
                result     |= updateSObject    (sObjectRecord, ((isAccount)?'person':'')+'LeadSource',                 (String) currentSObject.get('Origin'),                         forceUpdate);   
                result     |= updateSObject    (sObjectRecord, 'Sub_Channel__'+((isAccount)             ?'p':'')+'c',  (String) currentSObject.get('Sub_Channel__c'),                 forceUpdate);   
                
                //result     |= updateSObject    (sObjectRecord, ((isAccount)?'person':'')+'Salutation',                 (String) currentSObject.get('SuppliedSalutation__c'),          forceUpdate);
                
                result     |= updateOptOut     (sObjectRecord, isAccount, currentSObject);

                result     |= updateSObject    (sObjectRecord,                           'Country_code__c',            (String) currentSObject.get('Country_code__c'),                forceUpdate);
                result     |= updateSObject    (sObjectRecord, ((isAccount)?'Shipping':'Mailing') +'Country',              (String) currentSObject.get('Country_code__c'),                forceUpdate);
                result     |= updateSObject    (sObjectRecord, ((isAccount)?'Shipping':'Mailing') +'_Country__c',          (String) currentSObject.get('Country_code__c'),                forceUpdate);
                result     |= updateAddress    (sObjectRecord, isAccount, currentSObject, forceUpdate);

         if (isAccount) // Set fields with no Contact equivalent only on Account records   
         {
               result      |= updateSObject    (sObjectRecord,                           'ShippingCountry',            (String) currentSObject.get('Country_code__c'),                forceUpdate);
               result      |= updateSObject    (sObjectRecord,                           'Country_code__pc',           (String) currentSObject.get('Country_code__c'),                forceUpdate);
    } 

         return result;
    } 
    
    private static Boolean updateSObject (SObject sObjectRecord, String fieldName, String value, Boolean forceUpdate) 
    {
        if (requiresUpdate(sObjectRecord, fieldName, value, forceUpdate)) 
        {
            sObjectRecord.put(fieldName, value);
            return true;
        }
        return false;
    }

    private static Boolean updatePhone  (SObject sObjectRecord, SObject currentSObject, Boolean forceUpdate)
    {
        List<String> phoneFieldNameList = new List<String>{ 'SuppliedPhone', 'SuppliedMobile__c', 'SuppliedHomePhone__c', 'SuppliedOtherPhone__c' };
        for (String phoneFieldName : phoneFieldNameList)
        {
           Boolean result  = updateSObject    (sObjectRecord, 'Phone', (String) currentSObject.get(phoneFieldName), forceUpdate);
           if (!String.isBlank((String) sObjectRecord.get('Phone'))) { return result; }     
        }
        return false;       
    }

    private static Boolean updateAddress (SObject sObjectRecord, Boolean isAccount, SObject currentSObject, Boolean forceUpdate) 
    {
        if (requiresUpdate (sObjectRecord, ((isAccount)?'Shipping':'Mailing')+'_Municipality__c',  (String) currentSObject.get('SuppliedMailingCity__c'), forceUpdate))
        {
                updateAddress (sObjectRecord, isAccount, 'Municipality',  (String) currentSObject.get('SuppliedMailingCity__c'));
                updateAddress (sObjectRecord, isAccount, 'Streetname1',   (String) currentSObject.get('SuppliedMailing_Streetname1__c'));
                updateAddress (sObjectRecord, isAccount, 'Streetname2',   (String) currentSObject.get('SuppliedMailing_Streetname2__c'));
                updateAddress (sObjectRecord, isAccount, 'PostalCode',    (String) currentSObject.get('SuppliedMailingZip__c'));
                return true;
        }
        return false;
    }
    
    private static Boolean updateAddress (SObject sObjectRecord, Boolean isAccount, String fieldName, String value)
    {
        String targetFieldName = ((isAccount)?'Shipping_':'Mailing_')+ fieldName +'__c';
        value = (value != null) ? value : '';
        updateSObject (sObjectRecord, targetFieldName, value, true);   
        return true;
    }

    private static Boolean updateOptOut(SObject sObjectRecord, Boolean isAccount, SObject currentSObject)
    {
        String suppliedOptInString = (String) currentSObject.get('SuppliedOptIn__c');
        if (suppliedOptInString != null)
        {
            Boolean suppliedOptIn = (suppliedOptInString == '1');
            updateOptOut     (sObjectRecord, ((isAccount)?'person':'')+'HasOptedOutOfEmail',         !suppliedOptIn);
            updateOptOut     (sObjectRecord, ((isAccount)?'person':'')+'HasOptedOutOfFax',           !suppliedOptIn);
            updateOptOut     (sObjectRecord, ((isAccount)?'person':'')+'DoNotCall',                  !suppliedOptIn);
            return true;
        }
        return false;
    }

    private static Boolean updateOptOut (SObject sObjectRecord, String fieldName, Boolean value) 
    {
        sObjectRecord.put(fieldName, value);
        return true;
    }

    private static Boolean requiresUpdate (SObject sObjectRecord, String fieldName, String value, Boolean forceUpdate) 
    {
        return ( (forceUpdate) ||   ( (String.isBlank((String) (sObjectRecord.get(fieldName)))) && (String.isNotBlank(value)) ) );
    }
    
    private static Boolean updateContact      (Contact contact, SObject currentSObject, boolean forceUpdate) 
    { 
        return updateSObject((SObject) contact, false, currentSObject, forceUpdate); 
    }
     
    private static void    updatePersonAccount(Account account, SObject currentSObject)                      
    {
        updateSObject((SObject) account, true,  currentSObject, false      ); 
    }

    //--------------------------------------------------------------------------------------------------------------------------------------------

    public static void createPersonAccountsToSObjectIdMap(Map<String, Case> casesWithoutExistingContacts) 
    {
        // no Account found, create a new 'Unknown' account
        for (String caseIdentString : casesWithoutExistingContacts.keySet()) {
            SObject currentSObject = (SObject) casesWithoutExistingContacts.get(caseIdentString);
            String placeOfPurchase = null;
            
            String  placeName                  = (String) currentSObject.get(placeFieldName);
            Boolean regionByIdMapContainsPlace = regionsByExtId.containsKey(placeName); 
            if (regionByIdMapContainsPlace) 
            { 
                Region__c namedRegion = regionsByExtId.get(placeName); 
                placeOfPurchase       = namedRegion.Name; 
            }
            
            Account newCICAccount = createCasePersonAccount(currentSObject, placeOfPurchase);
            newCICAccountStringMap.put(caseIdentString, newCICAccount);
        }
    }

    private static Account createCasePersonAccount (SObject currentSObject, String placeOfPurchase) 
    {
       Account newAccount = new Account(
                                RecordTypeId                        = ECICCommonConstants.ACCOUNT_PERSON_RT_ID,
                                sf4twitter__Fcbk_User_Id__pc        =   (String) currentSObject.get('SuppliedFcbk_User_Id__c'),
                                PersonLeadSource                    =   (String) currentSObject.get('Origin'),
                                PersonEmail                         =   (String) currentSObject.get('SuppliedEmail'),
                                Phone                               =   (String) currentSObject.get('SuppliedPhone'),
                                personHomePhone                     =   (String) currentSObject.get('SuppliedHomePhone__c'), 
                                personMobilePhone                   =   (String) currentSObject.get('SuppliedMobile__c'),    
                                personOtherPhone                    =   (String) currentSObject.get('SuppliedOtherPhone__c'),
                                ShippingCountry                     =   (String) currentSObject.get('Country_Code__c'),
                                Shipping_Country__c                 =   (String) currentSObject.get('Country_Code__c'),
                                Country_code__c                     =   (String) currentSObject.get('Country_Code__c'), 
                                Country_code__pc                    =   (String) currentSObject.get('Country_Code__c'),
                                ShippingCity                        =            placeOfPurchase,
                                Shipping_Municipality__c            =   (String) currentSObject.get('SuppliedMailingCity__c'),   
                                Shipping_Streetname1__c             =   (String) currentSObject.get('SuppliedMailing_Streetname1__c'),   
                                Shipping_Streetname2__c             =   (String) currentSObject.get('SuppliedMailing_Streetname2__c'),   
                                
                                Profession_Function__pc             =   (String) currentSObject.get('Supplied_Account_Type__c'),
                                Sub_Channel__pc                     =   (String) currentSObject.get('Sub_Channel__c')
                           );
        if((String) currentSObject.get('Country_Code__c')=='DE'){
                newAccount.Preferred_Language__pc = 'German';
                String zipcode=getZipCode((String) currentSObject.get('SuppliedMailingZip__c'));
                if(zipcode!= null && String.isNotEmpty(zipcode)){
                              newAccount.Zip_Code__pc= zipcode;                            
                }
                                               
            }else{
                 newAccount.Shipping_postalCode__c              =   (String) currentSObject.get('SuppliedMailingZip__c');    
            }             
     
        
        Map<String, String> nameMap   = getNameMap(currentSObject);
        String              firstName = (nameMap.containsKey('firstName')) ? nameMap.get('firstName') : null;
        String              lastName  = (nameMap.containsKey('lastName'))  ? nameMap.get('lastName')  : null;

        if (firstName != null) { newAccount.FirstName = firstName; }        
        if (lastName  != null) { newAccount.LastName  = lastName;  }        
        
        //new fields added coming from Belgium web Cases ****START****
        
        String caseCountryCode = (String) currentSObject.get('Country_Code__c');
        if(caseCountryCode == 'BE' || caseCountryCode == 'LU' || caseCountryCode == 'NL'){
            String contactBirthdate = (String) currentSObject.get('Supplied_Birthdate__c');
            if(!String.isEmpty(contactBirthdate)){
                String []splitDate =contactBirthdate.split('-',3)[0] != contactBirthdate ? contactBirthdate.split('-',3) : contactBirthdate.split('/',3);
                if(splitDate.size() == 3 && !String.isEmpty(splitDate[0]) && !String.isEmpty(splitDate[1]) && !String.isEmpty(splitDate[2])){
                Integer day = Integer.valueOf(splitDate[0]);
                Integer month = Integer.valueOf(splitDate[1]);
                Integer year = Integer.valueOf(splitDate[2]);
                Date d = Date.newInstance(year, month, day);
                newAccount.PersonBirthdate = d;
                }
            }
            newAccount.fax = (String) currentSObject.get('supplied_Fax__c');
            newAccount.Preferred_Language__pc = (String) currentSObject.get('Supplied_Preferred_Language__c');
        }
        
        
        //****END****

        if (String.isBlank(newAccount.phone))
        {
            if      (String.isNotBlank(newAccount.personMobilePhone))  { newAccount.phone = newAccount.personMobilePhone; } 
            else if (String.isNotBlank(newAccount.personHomePhone))    { newAccount.phone = newAccount.personHomePhone;   } 
            else if (String.isNotBlank(newAccount.personOtherPhone))   { newAccount.phone = newAccount.personOtherPhone;  }
        }
        
        String suppliedOptInString = (String) currentSObject.get('SuppliedOptIn__c');
        if (suppliedOptInString != null)
        {
            Boolean suppliedOptIn = (suppliedOptInString == '1');
            newAccount.PersonHasOptedOutOfEmail = !suppliedOptIn;
            newAccount.PersonHasOptedOutOfFax   = !suppliedOptIn;
            newAccount.PersonDoNotCall          = !suppliedOptIn;
        }
        
        //Code added because of the validation rules present on account for GB.
        if(newAccount.Country_code__pc == 'GB'){
          String ageRange = (String) currentSObject.get('Supplied_Age_Range__c');
          String title = (String) currentSObject.get('Supplied_Title__c');
          String gender = (String) currentSObject.get('Supplied_Gender__c');
          Date birthDate = (Date) currentSObject.get('Supplied_Birthdate_Formula__c');
          
          string dateOfBirth = String.valueOf(birthDate);
           newAccount.Age_GB__pc = String.isBlank(ageRange) ? 'Unknown' : ageRange;
           newAccount.Title__pc  = String.isBlank(title) ? 'Unknown' : title;
           newAccount.Gender__pc= String.isBlank(gender) ? 'Unknown' : gender;
           newAccount.PersonBirthdate = String.isBlank(dateOfBirth) ? NULL : birthDate;
        }

        return newAccount;                           
    }
    
    private static Map<String, String> getNameMap(SObject currentSObject)
    {
        String   lastName    = (String) currentSObject.get('SuppliedLastName__c');
        if ((String.isNotBlank(lastName)))  
        {
            return new Map<String, String>
            {
                'firstName' => (String) currentSObject.get('SuppliedFirstName__c'),
                'lastName'  => lastName
            };
        }
        else return getNameMap((String) currentSObject.get('SuppliedName'));
    }
    //*** To Populate zip code on Person Account***
    Private static String getZipCode(string suppliedMailingZip){
        List<Zip_Code__c> currentZipCode=new List<Zip_Code__c>() ;
        String zipcode='';
        if(suppliedMailingZip!=null){   
             currentZipCode=[SELECT Id FROM Zip_Code__c WHERE Name =: suppliedMailingZip ];
             if(!currentZipCode.IsEmpty()){
                 zipcode=currentZipCode[0].id;
             }
        }
        return zipcode;
    }

    private static Map<String, String> getNameMap(String name) 
    {
        String   personName = String.isNotBlank(name) ? name.trim() : System.label.NameUnknown;
        Integer  index      = personName.indexOf(' ');

        return new Map<String, String>
        {
            'firstName' => ((index  > 0) ? personName.substring(0, index).trim()  : null),
            'lastName'  => ((index  > 0) ? personName.substring(index).trim()     : personName)
        };
    }
  

    //----------------------------------------------------------------------------------------------------------------------------------------------

    public static void setOwnerIdOnAccountsAndContacts() 
    {
        Map<String, ID> accountOwnerIdsByCountryStringMap = getAccountOwnerIdsByCountries();
        for (String sObjectStringId : newCICAccountStringMap.keySet()) {
            SObject currentSObject = sObjectIdentifyingStringMap.get(sObjectStringId);
            Account currentAccount = newCICAccountStringMap.get(sObjectStringId);
            
            ID accountOwnerId = null;
            try { 
                accountOwnerId = accountOwnerIdsByCountryStringMap.get((String) currentSObject.get('Country_code__c'));
            } catch (Exception ex) {
            }
            
            // look for the owner by country code
            if (accountOwnerId == null) {
                accountOwnerId = Userinfo.getUserId();
            }
            currentAccount.OwnerId = accountOwnerId;                                                        // set owner on Account
            
            if ((newCICContactStringMap != null) && (newCICContactStringMap.containsKey(sObjectStringId))) {
                Contact currentContact  = newCICContactStringMap.get(sObjectStringId);
                currentContact.OwnerId  = accountOwnerId;                                                   // set owner on Contact
            }
        }
    }

    // ----------------------------------------------------------------------------------------------------------------------------------------------------

    private static Map<String, ID> getAccountOwnerIdsByCountries() 
    {
        Map<String, ID>     resultOwnerIdStringMap                      = new Map<String, ID>();
        Map<String, User>   serviceManagerUsersByCountryStringMap       = getServiceManagerUsersByCountries();
        Map<String, User>   defaultAccountOwnerUsersByCountryStringMap  = ECICCaseTriggerAccountAndContactCache.getDefaultAccountOwnerUsersByCountryStringMap();
        
        for (String countryCode : countryCodeSet) {
            if (serviceManagerUsersByCountryStringMap.containsKey(countryCode)) {
                resultOwnerIdStringMap.put(countryCode, serviceManagerUsersByCountryStringMap.get(countryCode).id);
            } else if (defaultAccountOwnerUsersByCountryStringMap.containsKey(countryCode)) {
                resultOwnerIdStringMap.put(countryCode, defaultAccountOwnerUsersByCountryStringMap.get(countryCode).id);
            }
        }
        
        return resultOwnerIdStringMap;
    }
    
    private static Map<String, User> getServiceManagerUsersByCountries() 
    {
        Map<String, User>   resultUserStringMap   = new Map<String, User>(); 
        Map<String, String> roleNamesByCountryMap = new Map<String, String>();
        
        for (String countryCode : countryCodeSet) {
            User_Lookup_Mapping__c mapping = User_Lookup_Mapping__c.getInstance(countryCode);
            if (mapping != null) { 
                roleNamesByCountryMap.put(countryCode, mapping.Service_Manager__c); 
            }
        }
        
        if (! roleNamesByCountryMap.isEmpty()) {
            Map<String, User> activeUsersByRoleNamesMap = ECICUserDao.findActiveByRoleNames(roleNamesByCountryMap.values());
            for (String countryCode : countryCodeSet) {
                String roleName = roleNamesByCountryMap.get(countryCode);
                if (activeUsersByRoleNamesMap.containsKey(roleName)) {
                    resultUserStringMap.put(countryCode, activeUsersByRoleNamesMap.get(roleName));
                }
            }
        }
        
        return resultUserStringMap; 
    }
}