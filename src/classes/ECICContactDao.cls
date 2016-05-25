public class ECICContactDao {
    
    private final static String[] CONTACT_FIELDS = ECICUtils.getSObjectEditableFields(Contact.sObjectType); 
    private final static String   QUERY_FIELDS   = 'id, FirstName, LastName,Sub_Channel__c, Email, Phone, MobilePhone, HomePhone, OtherPhone, '
                                                    + 'sf4twitter__Fcbk_User_Id__c, Country_code__c, LeadSource, '
                                                    + 'MailingCountry, Mailing_Country__c, Mailing_Municipality__c, Mailing_Streetname1__c, Mailing_Streetname2__c, Mailing_PostalCode__c, '
                                                    + 'Owner.profile.name, Account.IsPersonAccount';

    public static Map<ID, Contact> findByIds(Set<ID> ids) 
    {
        return new Map<ID, Contact>((List<Contact>) Database.query('SELECT id, ' + String.join(CONTACT_FIELDS, ',') + ' FROM Contact  WHERE id IN :ids'));
    }
                        
    public static List<Contact> findByDetails(Set<String> emailSet, Set<String> phoneSet)
    {
        Set<Contact>                                     resultContactSet = new Set<Contact>();
        String whereClause =  '';

        if (!Test.isRunningTest())
        {    
            if (emailSet != null && ! emailSet.isEmpty()) {  resultContactSet.addAll(soslSearchContactFields(emailSet, 'EMAIL FIELDS')); }
            if (phoneSet != null && ! phoneSet.isEmpty()) {  resultContactSet.addAll(soslSearchContactFields(phoneSet, 'PHONE FIELDS')); }
        }
        else    // Not used for non-Test favour of SOSL, but see CIC-961
        {
            if ((emailSet != null) && (!emailSet.isEmpty()))    { whereClause +=  ' (email IN :emailSet) OR (SecondaryEmail__c IN :emailSet) '; }
            if ((phoneSet != null) && (!phoneSet.isEmpty()))    { whereClause += conditionalGetOr(whereClause) + ' (phone IN :phoneSet) OR (MobilePhone IN :phoneSet)  OR (HomePhone IN :phoneSet) '
                                     + ' OR (OtherPhone IN :phoneSet) OR (AssistantPhone IN :phoneSet) OR (STMGCentralCorporatePhone__c IN :phoneSet) '
                                     + ' OR (STM_Office_phone__c IN :phoneSet) OR  (STMGSecondaryPhone__c IN :phoneSet) '; }
        }

        if (whereClause != '') { resultContactSet.addAll ((List<Contact>) Database.query ('SELECT ' + QUERY_FIELDS + ' FROM Contact WHERE ' + whereClause)); }
        return new List<Contact>(resultContactSet);     
    }
    
    private static List<Contact> soslSearchContactFields(Set<String> values, String searchInFields) 
    {
        List<String> valuesAsList = new List<String>();
        valuesAsList.addAll(values);
        
        String valuesAsString = '"' + String.join(valuesAsList, '" OR "') + '"';
        String query = 'FIND \'' + valuesAsString + '\' IN ' + searchInFields + ' RETURNING Contact(' + QUERY_FIELDS + ')';
            
        List<List<SObject>> results = Search.query(query);
        return (List<Contact>)results.get(0);
    }
    
    public static List<Contact> findByEmailsOrPhones(Set<String> emailSet, Set<String> phoneSet) { return  findByDetails(emailSet, phoneSet); }
    
    private static String conditionalGetOr(String whereClause) { return (whereClause == '') ? '' : ' OR ';}
    
// -------------
        
    public static List<Contact> findContactList (List<SObject> sObjectList)
    {
        List<Set<String>> contactDetailSetList = findContactDetails(sObjectList, (sObjectList[0].getSObjectType() == Case.SObjectType)); 
        return ECICContactDao.findByDetails(contactDetailSetList.get(0), contactDetailSetList.get(1));
    }
    
    private static List<Set<String>> findContactDetails(List<sObject> sObjectList, Boolean isCaseList) 
    {
        List<Set<String>> resultSetList = new List<Set<String>>();
         
        Set<String> emailSet       = new Set<String>();
        Set<String> phoneSet       = new Set<String>();

        for (SObject currentSObject : sObjectList) 
        {
            if (isCaseList) // Not Case List is assumed to be Conversation.
            {
                if (String.isNotBlank((String) currentSObject.get('SuppliedEmail')))                    { emailSet.add       ((String) currentSObject.get('SuppliedEmail'));                        }
                if (String.isNotBlank((String) currentSObject.get('SuppliedPhone')))                    { phoneSet.add       ((String) currentSObject.get('SuppliedPhone'));                        }
                if (String.isNotBlank((String) currentSObject.get('SuppliedHomePhone__c')))             { phoneSet.add       ((String) currentSObject.get('SuppliedHomePhone__c'));                        }
                if (String.isNotBlank((String) currentSObject.get('SuppliedMobile__c')))                { phoneSet.add       ((String) currentSObject.get('SuppliedMobile__c'));                        }
                if (String.isNotBlank((String) currentSObject.get('SuppliedOtherPhone__c')))            { phoneSet.add       ((String) currentSObject.get('SuppliedOtherPhone__c'));                        }
            }
        }
        
        resultSetList.add(emailSet);
        resultSetList.add(phoneSet);

        return resultSetList;
    }
}