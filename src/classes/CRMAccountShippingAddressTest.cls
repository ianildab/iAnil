@isTest
public class CRMAccountShippingAddressTest {

    /* [CIC-539] CIC Class Modify CRM accounts Mailing address
     * The CRM Person Account shouldn't be modified when the shipping address is modified
     * 
     * Test Design Method: Decision Table
     *
     * There are four dimension of the test cases, which are:
     * - The user is Data Loader (D)
     * - The saved account is a CRM account (C)
     * - There is shipping address in the saved data (S)
     * - There is mailing address in the saved data  (M)
     *
     * The outcome is the mailing address is overwritten with the shipping address or not. (O)
     * This outcome is for insert and update trigger too.
     *
     * It means 16 possible combinations, 3 equivalence partitions.
     * The first partition is not relevant for the CRM related account
     * analysis.
     *
     * The table is:
     *    D C S M   O
     *  1 - - - -   Y P1
     *  2 - - - 1   Y P1
     *  3 - - 1 -   Y P1
     *  4 - - 1 1   Y P1
     *  5 - 1 - -   N P2
     *  6 - 1 - 1   N P2
     *  7 - 1 1 -   N P2
     *  8 - 1 1 1   N P2
     *  9 1 - - -   N P3 - Contradicts to the intuitions
     * 10 1 - - 1   N P3 - Contradicts to the intuitions
     * 11 1 - 1 -   N P3 - Contradicts to the intuitions
     * 12 1 - 1 1   N P3 - Contradicts to the intuitions
     * 13 1 1 - -   N P3
     * 14 1 1 - 1   N P3
     * 15 1 1 1 -   N P3
     * 16 1 1 1 1   N P3
     *
     * Picked test cases:
     *  4 - Existing mailing address must be overritten
     *  7 - Nonexisting mailing address must be left empty
     *  8 - Existing address must be left untouched
     * 11 - Nonexisting mailing address must be left empty
     * 16 - Existing mailing address must be left untouched
     *
     * NOTES:
     * During the current use of the system, the CRM related
     * accounts are loaded only with the data loader user.
     * The test cases from 5 to 8 are not valid for the
     * current usage of the system. This will be commented
     * out and JIRA links are provided.
     */

    /*private final static String DATA_LOADER_USER_OID = '00520000002oJpn';

    private final static String SHIPPING_COUNTRY     = 'Shipping Country';
    private final static String SHIPPING_STATE       = 'Shipping State';
    private final static String SHIPPING_CITY        = 'Shipping City';
    private final static String SHIPPING_POSTAL_CODE = 'Shipping Postal Code';
    private final static String SHIPPING_STREET      = 'Shipping Street';
    private final static String SHIPPING_COUNTRY_2     = 'Shipping Country 2';
    private final static String SHIPPING_STATE_2       = 'Shipping State 2';
    private final static String SHIPPING_CITY_2        = 'Shipping City 2';
    private final static String SHIPPING_POSTAL_CODE_2 = 'ShippingPostalCode2';
    private final static String SHIPPING_STREET_2      = 'Shipping Street 2';
    private final static String MAILING_COUNTRY     = 'Mailing Country';
    private final static String MAILING_STATE       = 'Mailing State';
    private final static String MAILING_CITY        = 'Mailing City';
    private final static String MAILING_POSTAL_CODE = 'Mailing Postal Code';
    private final static String MAILING_STREET      = 'Mailing Street';
    */
     
    /**  
     *  Test case #4 - Existing mailing address must be overritten
     *  
     *  FIXME (or remove):     
     *   This test currently fails because the shipping fields have changed and these
     *   fields are no longer being populated.
     *
     *  As per CIC-1466, the native/standard fields have been replaced by:
     *        - Mailing_Streetname1__c
     *        - Mailing_Municipality__c
     *        - Mailing_Administrative_Area__c
     *        - Mailing_Country__c
     *        - Mailing_Postal_Code__c
     *   
    static testMethod void tc4_nonDataLoaderLoadsNonCRMAccount() {
        String testName = 'Non Data Loader, Non CRM Account. Existing mailing address must be overritten';
        Id accountId = saveCICAccount(
            SHIPPING_COUNTRY, SHIPPING_STATE, SHIPPING_CITY, SHIPPING_POSTAL_CODE, SHIPPING_STREET,
            MAILING_COUNTRY,  MAILING_STATE,  MAILING_CITY,  MAILING_POSTAL_CODE,  MAILING_STREET
        );
        Account account = loadCICAccount(accountId);
        testAccount(
            testName,
            account,
            SHIPPING_COUNTRY, SHIPPING_STATE, SHIPPING_CITY, SHIPPING_POSTAL_CODE, SHIPPING_STREET,
            SHIPPING_COUNTRY, SHIPPING_STATE, SHIPPING_CITY, SHIPPING_POSTAL_CODE, SHIPPING_STREET
        );
        updateShippingAddress(
            account,
            SHIPPING_COUNTRY_2, SHIPPING_STATE_2, SHIPPING_CITY_2, SHIPPING_POSTAL_CODE_2, SHIPPING_STREET_2
        );
        Account updatedAccount = loadCICAccount(accountId);
        testAccount(
            testName,
            updatedAccount,
            SHIPPING_COUNTRY_2, SHIPPING_STATE_2, SHIPPING_CITY_2, SHIPPING_POSTAL_CODE_2, SHIPPING_STREET_2,
            SHIPPING_COUNTRY_2, SHIPPING_STATE_2, SHIPPING_CITY_2, SHIPPING_POSTAL_CODE_2, SHIPPING_STREET_2
        );
    }
    **/
     
    /* Test case #7 - Nonexisting mailing address must be left empty */
    /* Commented out due to JIRA item: https://tcccdiam.atlassian.net/browse/CRM-1229
    static testMethod void tc7_nonDataLoaderLoadsCRMAccount() {
        String testName = 'Non Data Loader, CRM Account, Nonexisting mailing address must be left empty';
        Id accountId = saveCRMAccount(
            SHIPPING_COUNTRY, SHIPPING_STATE, SHIPPING_CITY, SHIPPING_POSTAL_CODE, SHIPPING_STREET,
            null,             null,           null,          null,                 null
        );
        Account account = loadCRMAccount(accountId);
        testAccount(
            testName,
            account,
            SHIPPING_COUNTRY, SHIPPING_STATE, SHIPPING_CITY, SHIPPING_POSTAL_CODE, SHIPPING_STREET,
            null,             null,           null,          null,                 null
        );
        updateShippingAddress(
            account,
            SHIPPING_COUNTRY_2, SHIPPING_STATE_2, SHIPPING_CITY_2, SHIPPING_POSTAL_CODE_2, SHIPPING_STREET_2
        );
        Account updatedAccount = loadCRMAccount(accountId);
        testAccount(
            testName,
            updatedAccount,
            SHIPPING_COUNTRY_2, SHIPPING_STATE_2, SHIPPING_CITY_2, SHIPPING_POSTAL_CODE_2, SHIPPING_STREET_2,
            null,             null,           null,          null,                 null
        );
    } */
     
    /* Test case #8 - Existing address must be left untouched */
    /* Commented out due to JIRA item: https://tcccdiam.atlassian.net/browse/CRM-1229
    static testMethod void tc8_nonDataLoaderLoadsCRMAccountWithDifferentAddress() {
        String testName = 'Non Data Loader, CRM Account, Existing address must be left untouched';
        Id accountId = saveCRMAccount(
            SHIPPING_COUNTRY, SHIPPING_STATE, SHIPPING_CITY, SHIPPING_POSTAL_CODE, SHIPPING_STREET,
            MAILING_COUNTRY,  MAILING_STATE,  MAILING_CITY,  MAILING_POSTAL_CODE,  MAILING_STREET
        );
        Account account = loadCRMAccount(accountId);
        testAccount(
            testName,
            account,
            SHIPPING_COUNTRY, SHIPPING_STATE, SHIPPING_CITY, SHIPPING_POSTAL_CODE, SHIPPING_STREET,
            MAILING_COUNTRY,  MAILING_STATE,  MAILING_CITY,  MAILING_POSTAL_CODE,  MAILING_STREET
        );
        updateShippingAddress(
            account,
            SHIPPING_COUNTRY_2, SHIPPING_STATE_2, SHIPPING_CITY_2, SHIPPING_POSTAL_CODE_2, SHIPPING_STREET_2
        );
        Account updatedAccount = loadCRMAccount(accountId);
        testAccount(
            testName,
            updatedAccount,
            SHIPPING_COUNTRY_2, SHIPPING_STATE_2, SHIPPING_CITY_2, SHIPPING_POSTAL_CODE_2, SHIPPING_STREET_2,
            MAILING_COUNTRY,  MAILING_STATE,  MAILING_CITY,  MAILING_POSTAL_CODE,  MAILING_STREET
        );
    } */
    
    /* Test case #11 - Nonexisting mailing address must be left empty */
    /* But it contradicts to the intuition, anyway the way should the fix work
     * is written in the https://tcccdiam.atlassian.net/browse/CIC-539 ticket.
     */
    /*static testMethod void tc11_dataLoaderLoadsNonCRMAccount() {
        String testName = 'Data Loader, Non CRM Account, Nonexisting mailing address must be left empty';
        System.RunAs(dataLoaderUser()) {
            Id accountId = saveCICAccount(
                SHIPPING_COUNTRY, SHIPPING_STATE, SHIPPING_CITY, SHIPPING_POSTAL_CODE, SHIPPING_STREET,
                null,             null,           null,          null,                 null
            );
            Account account = loadCICAccount(accountId);
            testAccount(
                testName,
                account,
                SHIPPING_COUNTRY, SHIPPING_STATE, SHIPPING_CITY, SHIPPING_POSTAL_CODE, SHIPPING_STREET,
                null,             null,           null,          null,                 null
            );
            updateShippingAddress(
                account,
                SHIPPING_COUNTRY_2, SHIPPING_STATE_2, SHIPPING_CITY_2, SHIPPING_POSTAL_CODE_2, SHIPPING_STREET_2
            );
            Account updatedAccount = loadCICAccount(accountId);
            testAccount(
                testName,
                updatedAccount,
                SHIPPING_COUNTRY_2, SHIPPING_STATE_2, SHIPPING_CITY_2, SHIPPING_POSTAL_CODE_2, SHIPPING_STREET_2,
                null,               null,             null,            null,                   null
            );
        }
    }*/
     
    /* Test case #16 - Existing mailing address must be left untouched */
    /*static testMethod void tc16_dataLoaderLoadsCRMAccount() {
        String testName = 'Data Loader, CRM Account, Existing mailing address must be left untouched';
        System.RunAs(dataLoaderUser()) {
            Id accountId = saveCRMAccount(
                SHIPPING_COUNTRY, SHIPPING_STATE, SHIPPING_CITY, SHIPPING_POSTAL_CODE, SHIPPING_STREET,
                MAILING_COUNTRY,  MAILING_STATE,  MAILING_CITY,  MAILING_POSTAL_CODE,  MAILING_STREET
            );
            Account account = loadCRMAccount(accountId);
            testAccount(
                testName,
                account,
                SHIPPING_COUNTRY, SHIPPING_STATE, SHIPPING_CITY, SHIPPING_POSTAL_CODE, SHIPPING_STREET,
                MAILING_COUNTRY,  MAILING_STATE,  MAILING_CITY,  MAILING_POSTAL_CODE,  MAILING_STREET
            );
            updateShippingAddress(
                account,
                SHIPPING_COUNTRY_2, SHIPPING_STATE_2, SHIPPING_CITY_2, SHIPPING_POSTAL_CODE_2, SHIPPING_STREET_2
            );
            Account updatedAccount = loadCRMAccount(accountId);
            testAccount(
                testName,
                updatedAccount,
                SHIPPING_COUNTRY_2, SHIPPING_STATE_2, SHIPPING_CITY_2, SHIPPING_POSTAL_CODE_2, SHIPPING_STREET_2,
                MAILING_COUNTRY,  MAILING_STATE,  MAILING_CITY,  MAILING_POSTAL_CODE,  MAILING_STREET
            );
        }
    }*/
     
    /* Helpers */
    
    /*static private void testAccount(
        String testName,
        Account account,
        String shippingCountry, String shippingState, String shippingCity, String shippingPostalCode, String shippingStreet,
        String mailingCountry,  String mailingState,  String mailingCity,  String mailingPostalCode,  String mailingStreet
    ) {
        System.assertEquals(shippingCountry,    account.ShippingCountry,    testName + ' Shipping address was different (country)');
        System.assertEquals(shippingState,      account.ShippingState,      testName + ' Shipping address was different (state)');
        System.assertEquals(shippingCity,       account.ShippingCity,       testName + ' Shipping address was different (city)');
        System.assertEquals(shippingPostalCode, account.ShippingPostalCode, testName + ' Shipping address was different (postal code)');
        System.assertEquals(shippingStreet,     account.ShippingStreet,     testName + ' Shipping address was different (street)');
       // System.assertEquals(mailingCountry,     account.PersonMailingCountry,    testName + ' Mailing address was different (country)');
        System.assertEquals(mailingState,       account.PersonMailingState,      testName + ' Mailing address was different (state)');
        System.assertEquals(mailingCity,        account.PersonMailingCity,       testName + ' Mailing address was different (city)');
        System.assertEquals(mailingPostalCode,  account.PersonMailingPostalCode, testName + ' Mailing address was different (postal code)');
        System.assertEquals(mailingStreet,      account.PersonMailingStreet,     testName + ' Mailing address was different (street)');
    }
     
    static private Id saveCRMAccount(
        String shippingCountry, String shippingState, String shippingCity, String shippingPostalCode, String shippingStreet,
        String mailingCountry,  String mailingState,  String mailingCity,  String mailingPostalCode,  String mailingStreet
    ) {
        Date birthDate = Date.today().addYears(-30);
        Account crmAccount = new Account(
            LastName='testAccount' ,
            RecordTypeId = ECICCommonConstants.ACCOUNT_PERSON_RT_ID ,
            PersonBirthdate=birthDate ,
            Age_Range__c='3', // RANGE_25_30 = '3'
            Account_Ext_Id__c = 'COKEID_4585987542548695',
            ShippingStreet     = shippingStreet,
            ShippingState      = shippingState,
            ShippingPostalCode = shippingPostalCode,
            ShippingCountry    = shippingCountry,
            ShippingCity       = shippingCity,
            PersonMailingStreet      = mailingStreet,
            PersonMailingState       = mailingState,
            PersonMailingPostalCode  = mailingPostalCode,
            PersonMailingCountry     = mailingCountry,
            PersonMailingCity        = mailingCity            
        );
        insert(crmAccount);
        return crmAccount.Id;
    }

    static private Account loadAccount(Id accountid) {
        Account[] accounts = [
            select Id, 
                   ShippingCity,
                   ShippingCountry,
                   ShippingState,
                   ShippingPostalCode,
                   ShippingStreet,
                   PersonMailingCity,
                   PersonMailingCountry,
                   PersonMailingState,
                   PersonMailingPostalCode,
                   PersonMailingStreet
            from Account where Id =: accountid
        ];
        System.assertNotEquals(accounts.size(), 0, 'No account was found.');
        return accounts[0];
    }
     
    static private void updateShippingAddress(
        Account account,
        String shippingCountry,  String shippingState,  String shippingCity,  String shippingPostalCode,  String shippingStreet
    ) {
        account.ShippingCountry = shippingCountry;
        account.ShippingState   = shippingState;
        account.ShippingCity    = shippingCity;
        account.ShippingPostalCode = shippingPostalCode;
        account.ShippingStreet = shippingStreet;
        update(account);
    }
     
    static private Account loadCRMAccount(Id id) {
        return loadAccount(id);
    }
     
    static private Id saveCICAccount(
        String shippingCountry, String shippingState, String shippingCity, String shippingPostalCode, String shippingStreet,
        String mailingCountry,  String mailingState,  String mailingCity,  String mailingPostalCode,  String mailingStreet
    ) {
        Account personAccount = new Account(
            RecordTypeId       = ECICCommonConstants.ACCOUNT_PERSON_RT_ID,
            FirstName          = ECICCommonConstants.ACCOUNT_PERSON_FIRST_NAME,
            LastName           = ECICCommonConstants.ACCOUNT_PERSON_LAST_NAME,
            ShippingStreet     = shippingStreet,
            ShippingState      = shippingState,
            ShippingPostalCode = shippingPostalCode,
            ShippingCountry    = shippingCountry,
            ShippingCity       = shippingCity,
            PersonMailingStreet      = mailingStreet,
            PersonMailingState       = mailingState,
            PersonMailingPostalCode  = mailingPostalCode,
            PersonMailingCountry     = mailingCountry,
            PersonMailingCity        = mailingCity
        );
        insert(personAccount);
        return personAccount.Id;
    }
     
    static private Account loadCICAccount(Id id) {
        return loadAccount(id);
    }
     
    static private User dataLoaderUser() {
        User[] users = [select Id from User where Id =: DATA_LOADER_USER_OID];
        System.assertNotEquals(users.size(), 0, 'No data loader user is found.');
        return users[0];
    }*/
    
}