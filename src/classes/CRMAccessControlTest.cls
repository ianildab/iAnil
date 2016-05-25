/* Apex test class for Access Control - CRM-1324
 * https://tcccdiam.atlassian.net/browse/CRM-1324
 */

@isTest
public with sharing class CRMAccessControlTest {
    /* Created by Andor Penzes */
    
    /* CRM-1324 - As a CRM or CIC Agent, I will only be able to view or send communications to consumers
     * who have accepted the Legal Acceptances of countries I am authorized to access, or
     * I have access to their Country of Residence.
     * 
     * Test Design Method: State Transition
     *
     * The action made by the custumer, inserting data into the salesforce instance.
     * States represents the accessibility of the costumer made for the given agent.
     * 
     * Actions:
     * - Consumer accepts legal acceptance which country is not accessible for the agent (LA-)
     * - Consumer accepts legal acceptance which country is accessible for the agent (LA+)
     * - Consumer moves to a country which is not accessible for the agent (M-)
     * - Consumer moves to a country which is accessible for the agent (M+)
     *
     * States:
     * - Access Denied (D)
     * - Access by Legal Acceptance (A-LA)
     * - Access by State of Residence (A-R)
     * - Access by State Legal Acceptance and Residence (A-B)
     *
     * Full test design can be found here:
     * https://svnbud.epam.com/tccc-crm2/testing/related_docs/test_plans/CRM_1324_Test_Case_Set.docx
     *
     * NOTES:
     * The original idea was to create a full integration test of the insert of accepted legal acceptance
     * and of the accessibility of the account records. But the System.RunAs does not work as it expected
     * in the context, by this reason semi-integration test is created. The insertion of the accepted
     * leagal acceptance is done by the 'insert' method, this is the integration level of testing, after
     * that the accessing the records through record IDs is done, and an oracle, set based sharing rule
     * implementation mimicing how the sharing rules supposed to be working. The results of the oracle
     * implementation and the real working code are compared to each other. At high level test cases can be
     * found in the document defined above.
     */
    
    /* Consumers are normal accounts in the salesforce */
    private class Consumer {
        ID accountID;
    }
    
    /* PropRep is represented in property of a property pair */
    private class PropRep {
        ID propertyRepresentationID;
        ID propertyID;
    }

    private static final String CRM_PROFILE = 'CRM Trusted User';
    private static final String CRM_CREATOR_PROFILE = 'CRM Data Loader';
    
    private static final String CRM_FR_USER_ROLE = 'CRM FR User';
    private static final String CRM_GB_USER_ROLE = 'CRM GB User';
    private static final String CRM_IE_USER_ROLE = 'CRM IE User';
    private static final String CRM_PT_USER_ROLE = 'CRM PT User';
    private static final String CRM_ES_USER_ROLE = 'CRM ES User';
    private static final String CRM_IB_USER_ROLE = 'Coca-Cola Iberia';
    
    private static final String COUNTRY_FR = 'FR';
    private static final String COUNTRY_GB = 'GB';
    private static final String COUNTRY_IE = 'IE';
    private static final String COUNTRY_PT = 'PT';
    private static final String COUNTRY_ES = 'ES';
    
    private static ID PROPERTY_RECORDTYPEID;
    private static ID PROPERTY_REPRESENTATION_RECORDTYPEID;
    
    static {
        PROPERTY_RECORDTYPEID = [SELECT id FROM RecordType WHERE name = 'Consumer DB Property' LIMIT 1].Id;
        PROPERTY_REPRESENTATION_RECORDTYPEID = [SELECT id FROM RecordType WHERE name = 'Consumer DB Property Representation' LIMIT 1].Id;
    }
    
    
    /* TEST CASES FOR AGENT WITH ACCESS TO TWO COUNTRIES
     * The agent has access to the 'Country 2' and 'Country 3'
     */    
    
    static testMethod void testCase1LongPath() {
        /* Given */
        // User agent = agent('agent@creator.com', CRM_PROFILE, CRM_IB_USER_ROLE);
        Set<String> laCountries = new Set<String>();
        Set<String> agentCountries = new Set<String>();
        
        agentCountries.add(COUNTRY_PT);
        agentCountries.add(COUNTRY_ES);
        
        String country2 = COUNTRY_PT;
        String country3 = COUNTRY_ES;
        String country4 = COUNTRY_FR;
        
        Consumer consumer = consumer('consumer', country4);
        PropRep laCountry3 = propertyRepresentationWithCountry(country3, 1);
        hasNoAccess(consumer, agentCountries, laCountries);
        
        /* When */ moves(consumer, country2);
        /* Then */ hasAccess(consumer, agentCountries, laCountries);
        
        /* When */ moves(consumer, country4);
        /* Then */ hasNoAccess(consumer, agentCountries, laCountries);
        
        /* When */ acceptsLaIn(laCountries, consumer, laCountry3, 1);
        /* Then */ hasAccess(consumer, agentCountries, laCountries);        
    }
        
    
    /* TEST CASES FOR AGENT WITH ACCESS TO ONLY ONE COUNTY */
    
    static testMethod void testCase2PathToTotalAcceptance1() {
        /* Given */
        Set<String> laCountries = new Set<String>();
        Set<String> agentCountries = new Set<String>();
        agentCountries.add(COUNTRY_FR);
        
        String country1 = COUNTRY_GB;
        String country2 = COUNTRY_FR;
        Consumer consumer = consumer('consumer', country1);
        PropRep laCountry2 = propertyRepresentationWithCountry(country2, 1);
        hasNoAccess(consumer, agentCountries, laCountries);
        
        /* When */ moves(consumer, country2);
        /* Then */ hasAccess(consumer, agentCountries, laCountries);
        
        /* When */ acceptsLaIn(laCountries, consumer, laCountry2, 2);
        /* Then */ hasAccess(consumer, agentCountries, laCountries);
    }
    
    static testMethod void testCase3PathToTotalAcceptance2() {
        /* Given */
        Set<String> laCountries = new Set<String>();
        Set<String> agentCountries = new Set<String>();
        agentCountries.add(COUNTRY_GB);
        
        String country1 = COUNTRY_FR;
        String country2 = COUNTRY_GB;
        Consumer consumer = consumer('consumer', country1);
        PropRep laCountry2 = propertyRepresentationWithCountry(country2, 1);
        hasNoAccess(consumer, agentCountries, laCountries);
        
        /* When */ acceptsLaIn(laCountries, consumer, laCountry2, 1);
        /* Then */ hasAccess(consumer, agentCountries, laCountries);
        
        /* When */ moves(consumer, country2);
        /* Then */ hasAccess(consumer, agentCountries, laCountries);
    }
    
    /* Base test case that test if the a French agent
     * has access to the French consumer
     */
    static testMethod void testCaseOnlyFrenchCostumer() {
        /* Given */
        Set<String> laCountries = new Set<String>();
        Set<String> agentCountries = new Set<String>();
        agentCountries.add(COUNTRY_FR);
        
        String country1 = COUNTRY_FR;
        Consumer consumer = consumer('consumer', country1);
        PropRep laCountry2 = propertyRepresentationWithCountry(country1, 1);
        hasAccess(consumer, agentCountries, laCountries);
    }
    
    /* Test if a consumer accets a legal acceptance, the agent
     * has access to that consumer
     */
    static testMethod void testCaseDebugLegalAcceptance() {
        /* Given */
        Set<String> laCountries = new Set<String>();
        Set<String> agentCountries = new Set<String>();
        agentCountries.add(COUNTRY_GB);
        
        String country1 = COUNTRY_FR;
        String country2 = COUNTRY_GB;
        Consumer consumer = consumer('consumer', country1);
        PropRep laCountry2 = propertyRepresentationWithCountry(country2, 1);
        
        /* When */ acceptsLaIn(laCountries, consumer, laCountry2, 1);
        /* Then */ hasAccess(consumer, agentCountries, laCountries);
    }    
    
    static testMethod void testCaseWithEmptyLegalAcceptenceID() {
        /* Given */
        Set<String> laCountries = new Set<String>();
        Set<String> agentCountries = new Set<String>();
        agentCountries.add(COUNTRY_GB);
        
        String country1 = COUNTRY_FR;
        String country2 = COUNTRY_GB;
        String laInfoExtId = '';
        String alaExtId = 'TEST_DS_ALA_EXT';
        Consumer consumer = consumer('consumer', country1);
        PropRep laCountry2 = propertyRepresentationWithCountry(country2, 1);
        
        ID laId = insertAcceptedLegalAcceptance(laCountries, consumer, laCountry2, alaExtId, laInfoExtId);
        isNotInsertedAcceptedLegalAcceptance(laId);     
    }
    
    static testMethod void testCaseWithoutClientID() {
        /* Given */
        Set<String> laCountries = new Set<String>();
        Set<String> agentCountries = new Set<String>();
        agentCountries.add(COUNTRY_GB);
        
        String country1 = COUNTRY_FR;
        String country2 = COUNTRY_GB;
        String laInfoExtId = 'TEST_DS_ALA';
        String alaExtId = 'TEST_DS_ALA_EXT';
        Consumer consumer = consumer('consumer', country1);
        PropRep laCountry2 = propertyRepresentationWithCountryClientId(country2, 1, null);
        
        ID laId = insertAcceptedLegalAcceptance(laCountries, consumer, laCountry2, alaExtId, laInfoExtId);
        isNotInsertedAcceptedLegalAcceptance(laId);
    }
    
    static testMethod void testCaseWithEmptyClientID() {
        /* Given */
        Set<String> laCountries = new Set<String>();
        Set<String> agentCountries = new Set<String>();
        agentCountries.add(COUNTRY_GB);
        
        String country1 = COUNTRY_FR;
        String country2 = COUNTRY_GB;
        String laInfoExtId = 'TEST_DS_ALA';
        String alaExtId = 'TEST_DS_ALA_EXT';
        Consumer consumer = consumer('consumer', country1);
        PropRep laCountry2 = propertyRepresentationWithCountryClientId(country2, 1, '');
        
        ID laId = insertAcceptedLegalAcceptance(laCountries, consumer, laCountry2, alaExtId, laInfoExtId);
        isNotInsertedAcceptedLegalAcceptance(laId);
    }
    
    /* ************** *
     * Domain methods *
     * ************** */
     
    /* Creates a consumer */
    private static Consumer consumer(String name, String country) {
        Consumer consumer;
        ID accountID = insertAccount(name, country);
        consumer = new Consumer();
        consumer.accountID = readAccount(accountID).id;//accountID;
        return consumer;
    }
     
    /* Creates a country with a given name, including the
     * Property and Property Representation for this country,
     * Countries with the same name could be created.
     */
    private static PropRep propertyRepresentationWithCountry(String country, Integer id) {
        PropRep propRep;
        String i = String.valueOf(id);
        String propertyExtId = 'TEST_DS_P_' + i;
        String propRepExtId = 'TEST_DS_PR_' + i;
        String propRepClientId = 'CLIENT_ID_' + i;
        ID propID = insertProperty(propertyExtId, propertyExtId, country);
        ID propRepID = insertPropertyRepresentation(propID, propRepExtId, propRepClientId, propRepExtId);
        propRep = new PropRep();
        propRep.propertyID = propID;
        propRep.propertyRepresentationID = propRepID;
        return propRep;
    }
    
    /* Creates a country with a given name, including the
     * Property and Property Representation for this country, clientId
     * Countries with the same name could be created.
     */
    private static PropRep propertyRepresentationWithCountryClientId(String country, Integer id, String clientId) {
        PropRep propRep;
        String i = String.valueOf(id);
        String propertyExtId = 'TEST_DS_P_' + i;
        String propRepExtId = 'TEST_DS_PR_' + i;
        String propRepClientId = clientId;
        ID propID = insertProperty(propertyExtId, propertyExtId, country);
        ID propRepID = insertPropertyRepresentation(propID, propRepExtId, propRepClientId, propRepExtId);
        propRep = new PropRep();
        propRep.propertyID = propID;
        propRep.propertyRepresentationID = propRepID;
        return propRep;
    }   
    
    /* Consumer moves to the given country */
    private static void moves(Consumer consumer, String country) {
        Account account = readAccount(consumer.accountId);
        account.Country_Code__pc = country;
        update account;
    }
    
    /* Consumer accepts the given legal acceptance, for the given country */
    private static void acceptsLaIn(Set<String> expLaCountries, Consumer consumer, PropRep country, Integer id) {
        // Accepting a given legal acceptance means the creation of a
        // new Accepted Legal Acceptence object within salesforce
        String i = String.valueOf(id);
        String extId = 'TEST_DS_ALA_' + i;
        String laInfoExtId = 'TEST_DS_LA_' + i;
        insertAcceptedLegalAcceptance(expLaCountries, consumer, country, extId, laInfoExtId);
    }
    
    /* Creates a set of a semi-colon seperated list, if there is duplicated
     * element in the list throws an assertion error.
     */
    private static Set<String> listToSet(String vs) {
        if(vs == null) {
            return new Set<String>();
        }
        String[] values = vs.split(';');
        Set<String> result = new Set<String>();
        for(String value : values) {
            if(result.contains(value)) {
                System.assert(False, 'Duplicate value in the collection: ' + value);
            } else {
                result.add(value);
            }
        }
        return result;
    }
    
    /* Calculates the consumer's legal acceptance country set, and throws an
     * error if the calculated set differs from the expected one.
     * after adds the country of the residence to the consumers country set.
     */
    private static Set<String> calculateCountrySet(Consumer consumer, Set<String> laCountrySet) {
        Account account = readAccount(consumer.accountId);
        Set<String> cljls = listToSet(account.Country_of_Legal_Jurisdiction_List__c);
        System.assertEquals(laCountrySet, cljls, 'Sets of accepted legal acceptance countries differ.');
        Set<String> ccs = new Set<String>(); // Consumer Countries
        ccs.add(account.Country_Code__pc);
        ccs.addAll(cljls);
        return ccs;
    }
    
    /* Checks if the accepted legal acceptance is inserted into the
     * database, if not fails
     */
    private static void isNotInsertedAcceptedLegalAcceptance(ID Id) {
        if(Id == null) {
            return;
        }
        LegalAcceptance__c la = readAcceptedLegalAcceptance(Id);
        System.assert(la == null, 'LegalAcceptance was found for id:' + Id);
    }
    
    /* Checks if the consumer has the same legal acceptance country set, and at least one
     * of the agent's country set is in the legal acceptance country set of the consumer
     * if not an assertion is arose.
     */
    private static void hasAccess(Consumer consumer, Set<String> agentCountries, Set<String> laCountries) {
        Set<String> ccs = calculateCountrySet(consumer, laCountries); // Consumer Country Set

        for(String ac : agentCountries) { // ac: Agent Counrty
            if(ccs.contains(ac)) {
                // The agent has access to the user
                return;
            }
        }
        System.assert(False, 'The agent does not have access to the consumer');
    }
    
    /* Checks if the Agent has no access to the consumer's record
     * Fails the actual test if the agent has access to the consumer's
     * record, otherwise do nothing.
     */
    private static void hasNoAccess(Consumer consumer, Set<String> agentCountries, Set<String> laCountries) {
        Set<String> ccs = calculateCountrySet(consumer, laCountries); // Consumer Country Set
        
        for(String ac : agentCountries) { // ac: Agent Counrty
            if(ccs.contains(ac)) {
                System.assert(False, 'The agent does have access to the consumer');
            }
        }
        // The agent does not have access to the consumer
    }
    
    /* ******* *
     * Helpers *
     * ******* */

    /* Insert a CRM related account to the database 
     * Produces the ID of the inserted account
     */
    private static ID insertAccount(String name, String country) {
        Account account = new Account(
            LastName=name,
            Salutation='Mr',
            FirstName='test',
            PersonBirthdate=date.newInstance(2008, 12, 1),
            PersonEmail='test@email.com',
            PersonHasOptedOutOfEmail=FALSE,
            BillingStreet='test',
            ShippingStreet='test',
            PersonMailingStreet='test',
            PersonOtherStreet='test',
            Country_Code__pc = country,
            Fax='12345',
            Phone='123456',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678',
            PersonOtherPhone='123456789',
            Screen_Name__pc='test',
            sf4twitter__Fcbk_User_Id__pc='test',
            sf4twitter__Twitter_User_Id__pc='test',
            Identity_Card_Number__pc='test',
            Website='test' );
        insert account;
        return account.id;
    }
    
    /* Read the CRM related from the database for the given ID */
    private static Account readAccount(ID accountId) {
        Account account;
        account = [
            SELECT
                id,
                Activation_Date__pc,
                Consumer_Status__pc,
                Salutation,
                FirstName,
                LastName,
                PersonBirthdate,
                PersonEmail,
                PersonHasOptedOutOfEmail,
                BillingStreet,
                ShippingStreet,
                PersonMailingStreet,
                PersonOtherStreet,
                Country_Code__pc,
                Fax,
                Phone,
                PersonHomePhone,
                PersonMobilePhone,
                PersonOtherPhone,
                Screen_Name__pc,
                sf4twitter__Fcbk_User_Id__pc,
                sf4twitter__Twitter_User_Id__pc,
                Identity_Card_Number__pc,
                Website,
                ET_CRM_Registration_Brand__c,
                Country_of_Legal_Jurisdiction_List__c
            FROM Account
            WHERE Id =:accountId
        ];
        return account;
    }
    
    private static ID insertProperty(String extId, String uniqueName, String country) {
        Property__c property = new Property__c(
            Property_Ext_ID__c=extId,
            Property_Unique_Name__c=uniqueName,
            Name='eudb.property',
            Description__c='',
            RecordTypeId=PROPERTY_RECORDTYPEID, // TODO
            Country_of_Legal_Jurisdiction__c=country,
            Language__c='es_MX',
            Brand__c='Coke Zero',
            Status__c='Live'
        );
        insert property;
        return property.id;
    }
    
    private static ID insertPropertyRepresentation(ID parentID, String extId, String clientId, String uniqueName) {
        Property__c propRepr = new Property__c(
            Property_Ext_ID__c=extId,
            Property_Representation_Client_ID__c=clientId,
            Property_Unique_Name__c=uniqueName,
            Parent__c=parentID,
            Name=uniqueName,
            Type__c='Mobile Site',
            Description__c='',
            RecordTypeId=PROPERTY_REPRESENTATION_RECORDTYPEID,
            URL__c='',
            Status__c='Live'
        );
        insert propRepr;
        return propRepr.id;
    }
    
    private static Property__c readProperty(ID propertyId) {
        Property__c property;
        property = [
            SELECT
                Id,
                Property_Ext_ID__c,
                Property_Unique_Name__c,
                Name,
                Description__c,
                RecordTypeId,
                Country_of_Legal_Jurisdiction__c,
                Language__c,
                Brand__c,
                Status__c
            FROM Property__c
            WHERE Id =: propertyId
        ];
        return property;
    }
    
    private static Property__c readPropertyRepresentation(ID propRepID) {
        Property__c propRep = [
            SELECT
                Property_Ext_ID__c,
                Property_Representation_Client_ID__c,
                Property_Unique_Name__c,
                Parent__c,
                Name,
                Type__c,
                Description__c,
                RecordTypeId,
                URL__c,
                Status__c
            FROM Property__c
            WHERE Id =: propRepID
        ];
        return propRep;
    }

    /* Inserts a legal acceptance to the salesforce database, if the insertion
     * is failed, returns null as an ID
     */
    private static ID insertLegalAcceptance(String extId, String uniqueName) {
        Legal_Acceptance__c la = new Legal_Acceptance__c(
            Country__c='ES',
            Description__c=null,
            Language__c='ES',
            LegalAcceptance_Ext_ID__c=extId,
            Type__c=null,
            LegalAcceptance_Unique_Name__c=uniqueName,
            Level__c=null,
            Status__c=null,
            URL__c=null,
            Version__c=null
        );
        try {
            insert la;
            return la.id;
        } catch (Exception e) {
            return null;
        }
    }
 
    /* Inserts an accepted legal acceptance to the salesforce database and
     * the set maintaned for the oracle implementation, if the insertion failed
     * the returned id is null
     */
    private static ID insertAcceptedLegalAcceptance(Set<String> expLaCountries, Consumer c, PropRep pr, String alaExtId, String laInfoExtId) {
        Property__c property = readProperty(pr.propertyId);
        expLaCountries.add(property.Country_of_Legal_Jurisdiction__c);
        Account consumer = readAccount(c.accountId);
        Property__c propRep = readPropertyRepresentation(pr.propertyRepresentationId);
        insertLegalAcceptance(laInfoExtId, laInfoExtId);
        DateTime now = DateTime.now();
        LegalAcceptance__c legalAcceptance = new LegalAcceptance__c( // This is the salesforce object for accepted legal acceptance
            dateAccepted__c=now,
            clientId__c=propRep.Property_Representation_Client_ID__c, // Client id in the property representation
            Account__c=consumer.Id,
            legalAcceptanceId__c=laInfoExtId,
            pluralId__c=alaExtId
        );
        try {
            insert legalAcceptance;
            checkContactIdInsert(consumer.Id,legalAcceptance.id);
            return legalAcceptance.id;
        } catch (Exception e) {
            return null;
        }
    }
    
    /* Reads an accepted legal acceptance from the salesforce database. If
     * the id is not found it returns null, if more than one is found
     * System.assert is called
     */
    private static LegalAcceptance__c readAcceptedLegalAcceptance(ID laId) {
        List<LegalAcceptance__c> las = null;
        las = [
            SELECT
                dateAccepted__c,
                clientId__c,
                Account__c,
                legalAcceptanceId__c,
                pluralId__c
            FROM
                LegalAcceptance__c
            WHERE
                ID =: laId
        ];
        integer size = las.size();
        if(size == 0) {
            return null;
        } else if(size > 1) {
            System.assert(False, 'More than one LegalAcceptance is found for the id: ' + laId);
            return null;
        } else {
            return las[0];
        }
    }
    
    private static void checkContactIdInsert(Id accountId, Id legalAccId){
        Account accWithContactId = [SELECT PersonContactId FROM Account WHERE Id = :accountId];
        LegalAcceptance__c LegalAcceptanceWithContactId = [SELECT Contact__c FROM LegalAcceptance__c WHERE Id = :legalAccId];
        System.assertEquals(accWithContactId.PersonContactId, LegalAcceptanceWithContactId.Contact__c, 'The Contact Ids do do not match for the LegalAcceptance insert');
    }
    
}