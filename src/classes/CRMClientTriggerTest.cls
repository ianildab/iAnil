@isTest
public class CRMClientTriggerTest {

    /* Testing level is integration testing
     * ------------------------------------
     *
     * Database insert and select are used as mechanism of the data manipulation
     * in the system.
     *
     * Test Design is a simple decision table based on the cleintId values of the
     * inserted client records, valid and invalid values. Outcomes
     * are binary: can be inserted and cannot be inserted.
     * 
     * The next test design method based on the boundary value analysis, if
     * in every position of the inserted set, the invalid values got rejected.
     *
     * Test cases also consist of the first login to semantics
     * defined in the https://tcccdiam.atlassian.net/browse/CRM-1392 ticket
     * The first login to field on the account must be filled up with the
     * property ids connected to the client with the property representation lookup.
     * Inserting the same client, with different client id, and updating the very same
     * client should fill the property ids onto the firstLoginTo_1 and firstLoginTo_2
     * fields on the Account obejct.
     */
     
    private static ID PROPERTY_RECORDTYPEID;
    private static ID PROPERTY_REPRESENTATION_RECORDTYPEID;
    
    static {
        PROPERTY_RECORDTYPEID = [SELECT id FROM RecordType WHERE name = 'Consumer DB Property' LIMIT 1].Id;
        PROPERTY_REPRESENTATION_RECORDTYPEID = [SELECT id FROM RecordType WHERE name = 'Consumer DB Property Representation' LIMIT 1].Id;
    }

    /* Test if the insertion work properly */
    static testMethod void testInsert() {
        /* Given */
        ID account = insertAccount('Test_Account');
        String CLIENT_ID_1 = 'CLIENT_ID_1';
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID_1);
        
        /* When */ ID c = insertClient('CID_1', CLIENT_ID_1, account);
        /* Then */ checkClient(c, prop1);
        /* Then */ checkContactIdInsert(account,c);
    }
    
    /* Test if the invalid client id that points to a nonexisting 
     * property representation, the insertion of the client gets rejected
     */
    static testMethod void testWrongInsert() {
        /* Given */
        ID account = insertAccount('Test_Account');
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', 'CLIENT_ID_1');
        
        /* When */ ID c = insertClient('CID_1', 'CLIENT_ID_2', account);
        /* Then */ checkWrongClient(c);
    }
    
    /* Test if the invalid client id that points to a nonexisting 
     * property representation, the insertion of the client gets rejected
     */
    static testMethod void testWrongInsertWithEmptyClientID() {
        /* Given */
        ID account = insertAccount('Test_Account');
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', 'CLIENT_ID_1');
        
        /* When */ ID c = insertClient('CID_1', '', account);
        /* Then */ checkWrongClient(c);
    }

    /* Test if the insertion invalid client id which is empty gets rejected
     */
    static testMethod void testWrongInsertWithNullClientID() {
        /* Given */
        ID account = insertAccount('Test_Account');
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', 'CLIENT_ID_1');
        
        /* When */ ID c = insertClient('CID_1', null, account);
        /* Then */ checkWrongClient(c);
    }
    
    /* Test if the insertion of one wrong client id is not happen
     * and the other two happens
     */
    static testMethod void testWrongInTheMiddle() {
        /* Given */
        ID account = insertAccount('Test_Account');
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', 'CLIENT_ID_1');
        ID prop2 = insertPropAndRepr('PROP_2', 'PROP_REP_2', 'CLIENT_ID_2');
        ID prop3 = insertPropAndRepr('PROP_3', 'PROP_REP_3', 'CLIENT_ID_3');
        List<Client__c> clients = new List<Client__c>();
        clients.add(createClient('CID_1', 'CLIENT_ID_1', account));
        clients.add(createClient('CID_2', 'CLIENT_ID_2x', account));
        clients.add(createClient('CID_3', 'CLIENT_ID_3', account));
        List<String> clientIds = new List<String>();
        clientIds.add('CID_1');
        clientIds.add('CID_2');
        clientIds.add('CID_3');
        
        /* When */ insertClients(clients);
        /* When */ Map<String, Client__c> clientsMap = readClients(clientIds);
        
        /* Then */ checkClient(clientsMap, 'CID_1', prop1);
        /* Then */ checkWrongClient(clientsMap, 'CID_2');
        /* Then */ checkClient(clientsMap, 'CID_3', prop3);
    }

    /* Test is the insertion of wrong element in every posision would fail
     */
    static testMethod void testFourWrongs() {
        /* Given */
        ID account = insertAccount('Test_Account');
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', 'CLIENT_ID_1');
        ID prop2 = insertPropAndRepr('PROP_2', 'PROP_REP_2', 'CLIENT_ID_2');
        ID prop3 = insertPropAndRepr('PROP_3', 'PROP_REP_3', 'CLIENT_ID_3');
        ID prop4 = insertPropAndRepr('PROP_4', 'PROP_REP_4', 'CLIENT_ID_4');
        List<Client__c> clients = new List<Client__c>();
        clients.add(createClient('CID_1', null, account));
        clients.add(createClient('CID_2', '', account));
        clients.add(createClient('CID_3', null, account));
        clients.add(createClient('CID_4', '', account));
        
        /* When */ Map<String,ID> inserteds = insertClients(clients);
        /* Then */ checkWrongClient(inserteds.get('CID_1'));
        /* Then */ checkWrongClient(inserteds.get('CID_2'));
        /* Then */ checkWrongClient(inserteds.get('CID_3'));
        /* Then */ checkWrongClient(inserteds.get('CID_4'));
    }

    /* Welcome email functionality is tested with the following decicion table
     *
     * NO:           01 02 03 04 05 06 07 08 09 10 11 12
     * PROP        | P1 P1 P1 P1 P1 P1 P2 P2 P2 P2 P2 P2
     * INSERT      | +  +  +  -  -  -  +  +  +  -  -  - 
     * UPDATE      | -  -  -  +  +  +  -  -  -  +  +  + 
     * FIRSTLOGIN  | -  +  +  -  +  +  -  +  +  -  +  + 
     * ACCOUNT     | -  -  P1 -  -  P1 P1 P1 P1 P1 P1 P1
     *                                       P2       P2
     *
     * OUTCOME     | -  C  C  -  C  -  -  C  -  -  C  - 
     * OUTCOME     | -  P1 P1 -  P1 P1 P1 P1 P1 P1 P1 P1
     *                                    P2 P2    P2 P2
     *
     * PROP: Property connected to the client through property representation
     *       P1: Property, P2: Different property than P2
     * INSERT: The client__c is inserted 
     * UPDATE: The client__c is updated
     * FIRSTLOGIN: The first login field is filled with some date value. Does the client
     *             contain first login date or not.
     * ACCOUNT: The active set of the welcome email, also show the example of the set like values
     *          E.g (- the set is empty / P1 P2 the account stores P1 and P2 property ext ids)
     * OUTCOME: Copy or not, also shows the example of the set like values
     *          E.g (- no copy, C copy the property id to the account)
     */
    
    static testMethod void clientWithT04() {
        /* Given */
        ID accountId = insertAccount('Test_Account');
        insertPropAndRepr('PROP_1', 'PROP_REP_1', 'CLIENT_ID_1');
        Client__c client = createEmtpyFirstLoginClient('CID_1', 'CLIENT_ID_1', accountId);
        insert client;
        
        /* TC 04 from decision table */
        /* When */ update client;
        /* Then */ checkNoPropertyOnAccountFirstLoginWasEmpty(accountId, 'PROP_1');
        /* Then */ Account account = readAccount(accountId);
        /* Then */ String firstLoginTo = firstLoginToToday(account);
        /* Then */ System.assertEquals(firstLoginTo, null, 'There are some invalid data on the first login to fields');
    }
    
    static testMethod void clientWithT02T08T09() {
        /* Given */
        ID accountId = insertAccount('Test_Account');
        insertPropAndRepr('PROP_1', 'PROP_REP_1', 'CLIENT_ID_1');
        insertPropAndRepr('PROP_2', 'PROP_REP_2', 'CLIENT_ID_2');
        /* TC 02 from the decision table */
        insert createFirstLoginTodayClient('CID_1', 'CLIENT_ID_1', accountId);
        checkPropertyOnAccountFirstLogin(accountId, 'PROP_1');
        
        /* TC 08 from the decision table */
        /* When */ insert createFirstLoginTodayClient('CID_2', 'CLIENT_ID_2', accountId);
        /* Then */ checkPropertyOnAccountFirstLogin(accountId, 'PROP_1');
        /* Then */ checkPropertyOnAccountFirstLogin(accountId, 'PROP_2');
        /* Then */ Account account = readAccount(accountId);
        /* Then */ String firstLoginTo3 = firstLoginToToday(account);
        
        /* TC 09 from the decision table */
        /* When */ insert createFirstLoginTodayClient('CID_3', 'CLIENT_ID_2', accountId);
        /* Then */ checkPropertyOnAccountFirstLogin(accountId, 'PROP_1');
        /* Then */ checkPropertyOnAccountFirstLogin(accountId, 'PROP_2');
        /* Then */ account = readAccount(accountId);
        /* Then */ String firstLoginTo4 = firstLoginToToday(account);
        /* Then */ System.assertEquals(firstLoginTo3, firstLoginTo4, 'The visited properties was different');
    }
    
    static testMethod void clientWithT02T07T10T11T12() {
        /* Given */
        ID accountId = insertAccount('Test_Account');
        insertPropAndRepr('PROP_1', 'PROP_REP_1', 'CLIENT_ID_1');
        insertPropAndRepr('PROP_2', 'PROP_REP_2', 'CLIENT_ID_2');
        /* TC 02 from the decision table */
        insert createFirstLoginTodayClient('CID_1', 'CLIENT_ID_1', accountId);
        checkPropertyOnAccountFirstLogin(accountId, 'PROP_1');
        
        /* TC 07 from the decision table */
        /* When */ Client__c client = createEmtpyFirstLoginClient('CID_2', 'CLIENT_ID_2', accountId);
        /* When */ insert client;
        /* Then */ checkPropertyOnAccountFirstLogin(accountId, 'PROP_1');
        
        /* TC 10 from the decision table */
        /* When */ update client;
        /* Then */ checkPropertyOnAccountFirstLogin(accountId, 'PROP_1');

        /* TC 11 from the decision table */
        /* When */ updateClientFirstLoginToday(client);
        /* When */ update client;
        /* Then */ checkPropertyOnAccountFirstLogin(accountId, 'PROP_1');
        /* Then */ checkPropertyOnAccountFirstLogin(accountId, 'PROP_2');
        /* Then */ Account account = readAccount(accountId);
        /* Then */ String firstLoginTo3 = firstLoginToToday(account);
        
        /* TC 12 from the decision table */
        /* When */ updateClientFirstLoginToday(client);
        /* When */ update client;
        /* Then */ checkPropertyOnAccountFirstLogin(accountId, 'PROP_1');
        /* Then */ checkPropertyOnAccountFirstLogin(accountId, 'PROP_2');
        /* Then */ account = readAccount(accountId);
        /* Then */ String firstLoginTo4 = firstLoginToToday(account);
        /* Then */ System.assertEquals(firstLoginTo3, firstLoginTo4, 'The visited properties was different');
    }

    /* Inserts the given property id to the account's first login 1 related fields, for yesterday.
     */
    static void insertFirstLogin1Property(ID accountId, ID prop) {
        Account account = readAccount(accountId);
        account.firstLoginTo_1__c = prop;
        account.welcomeEmailDate_1__c = System.today().addDays(-1);
        account.visitedProperties__c = prop;
        update account;
    }
    
    /* Inserts the given property id to the account's first login 2 related fields, for today.
     */
    static void insertFirstLogin2Property(ID accountId, ID prop) {
        Account account = readAccount(accountId);
        account.firstLoginTo_2__c = prop;
        account.welcomeEmailDate_2__c = System.today();
        account.visitedProperties__c = prop;
        update account;
    }

    static testMethod void clientWithT02T07T10T11T12WelcomeEmailDateAlreadyInserted() {
        /* Given */
        ID accountId = insertAccount('Test_Account');
        insertPropAndRepr('PROP_1', 'PROP_REP_1', 'CLIENT_ID_1');
        insertPropAndRepr('PROP_2', 'PROP_REP_2', 'CLIENT_ID_2');
        ID propRep3 = insertPropAndRepr('PROP_3', 'PROP_REP_3', 'CLIENT_ID_3');
        ID prop3 = readProperty('PROP_REP_3').Parent__c;
        insertFirstLogin1Property(accountId, prop3);
        /* TC 02 from the decision table */
        insert createFirstLoginTodayClient('CID_1', 'CLIENT_ID_1', accountId);
        checkPropertyOnAccountFirstLogin(accountId, 'PROP_1');
        
        /* TC 07 from the decision table */
        /* When */ Client__c client = createEmtpyFirstLoginClient('CID_2', 'CLIENT_ID_2', accountId);
        /* When */ insert client;
        /* Then */ checkPropertyOnAccountFirstLogin(accountId, 'PROP_1');
        
        /* TC 10 from the decision table */
        /* When */ update client;
        /* Then */ checkPropertyOnAccountFirstLogin(accountId, 'PROP_1');

        /* TC 11 from the decision table */
        /* When */ updateClientFirstLoginToday(client);
        /* When */ update client;
        /* Then */ checkPropertyOnAccountFirstLogin(accountId, 'PROP_1');
        /* Then */ checkPropertyOnAccountFirstLogin(accountId, 'PROP_2');
        /* Then */ Account account = readAccount(accountId);
        /* Then */ String firstLoginTo3 = firstLoginToToday(account);
        
        /* TC 12 from the decision table */
        /* When */ updateClientFirstLoginToday(client);
        /* When */ update client;
        /* Then */ checkPropertyOnAccountFirstLogin(accountId, 'PROP_1');
        /* Then */ checkPropertyOnAccountFirstLogin(accountId, 'PROP_2');
        /* Then */ account = readAccount(accountId);
        /* Then */ String firstLoginTo4 = firstLoginToToday(account);
        /* Then */ System.assertEquals(firstLoginTo3, firstLoginTo4, 'The visited properties was different');
    }
        
    
    static testMethod void clientWithT01T05T06() {
        /* This test case is test if an account receives a client without first login
         * after a first login update and after an update for the same property.
         * Also checks if the update does not inserts the same property value twice
         */
        /* Given */
        ID accountId = insertAccount('Test_Account');
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', 'CLIENT_ID_1');
        Client__c client = createEmtpyFirstLoginClient('CID_1', 'CLIENT_ID_1', accountId);

        /* TC 01 from the decision table */
        /* When */ insert client;
        /* Then */ checkNoPropertyOnAccountFirstLoginWasEmpty(accountId, 'PROP_1');
        
        /* TC 05 from the decision table */
        /* When */ updateClientFirstLoginToday(client);
        /* When */ update client;
        /* Then */ checkPropertyOnAccountFirstLogin(accountId, 'PROP_1');
        /* Then */ Account account = readAccount(accountId);
        /* Then */ String firstLoginTo1 = firstLoginToToday(account);
        
        /* TC 06 from the decision table */
        /* When */ updateClientFirstLoginToday(client);
        /* When */ update client;
        /* Then */ checkPropertyOnAccountFirstLogin(accountId, 'PROP_1');
        /* Then */ account = readAccount(accountId);
        /* Then */ String firstLoginTo2 = firstLoginToToday(account);
        /* Then */ System.assertEquals(firstLoginTo1, firstLoginTo2, 'The visited properties was different');
    }
    
    static testMethod void clientWithT02T03() {
        /* This test case is test if an account receives a client without first login
         * after a first login update and after an update for the same property.
         */
        /* Given */
        ID accountId = insertAccount('Test_Account');
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', 'CLIENT_ID_1');

        /* TC 02 from the decision table */
        /* When */ insert createFirstLoginTodayClient('CID_1', 'CLIENT_ID_1', accountId);
        /* Then */ checkPropertyOnAccountFirstLogin(accountId, 'PROP_1');
        /* Then */ Account account = readAccount(accountId);
        /* Then */ String firstLoginTo1 = firstLoginToToday(account);
        
        /* TC 03 from the decision table */
        /* When */ insert createFirstLoginTodayClient('CID_2', 'CLIENT_ID_1', accountId);
        /* Then */ checkPropertyOnAccountFirstLogin(accountId, 'PROP_1');
        /* Then */ account = readAccount(accountId);
        /* Then */ String firstLoginTo2 = firstLoginToToday(account);
        /* Then */ System.assertEquals(firstLoginTo1, firstLoginTo2, 'The visited properties was different');
    }    
    
    /* Check if the given property limit can be reached inserting
     * different properties all with the first login action.
     * https://tcccdiam.atlassian.net/browse/CRM-1392
     */
    static testMethod void negTestMoreThanPropertyLimit() {
        /* Given */
        ID account = insertAccount('Test_Account');
        insertPropAndRepr('PROP_1', 'PROP_REP_1', 'CLIENT_ID_1');
        insertPropAndRepr('PROP_2', 'PROP_REP_2', 'CLIENT_ID_2');
        insertPropAndRepr('PROP_3', 'PROP_REP_3', 'CLIENT_ID_3');
        insertPropAndRepr('PROP_4', 'PROP_REP_4', 'CLIENT_ID_4');
        insertPropAndRepr('PROP_5', 'PROP_REP_5', 'CLIENT_ID_5');
        insertPropAndRepr('PROP_6', 'PROP_REP_6', 'CLIENT_ID_6');
        insertPropAndRepr('PROP_7', 'PROP_REP_7', 'CLIENT_ID_7');
        insertPropAndRepr('PROP_8', 'PROP_REP_8', 'CLIENT_ID_8');
        insertPropAndRepr('PROP_9', 'PROP_REP_9', 'CLIENT_ID_9');
        insertPropAndRepr('PROP_10', 'PROP_REP_10', 'CLIENT_ID_10');
        insertPropAndRepr('PROP_11', 'PROP_REP_11', 'CLIENT_ID_11');
        insertPropAndRepr('PROP_12', 'PROP_REP_12', 'CLIENT_ID_12');
        insertPropAndRepr('PROP_13', 'PROP_REP_13', 'CLIENT_ID_13');
        insertPropAndRepr('PROP_14', 'PROP_REP_14', 'CLIENT_ID_14');
        insertPropAndRepr('PROP_15', 'PROP_REP_15', 'CLIENT_ID_15');
        insertPropAndRepr('PROP_16', 'PROP_REP_16', 'CLIENT_ID_16');
        insertPropAndRepr('PROP_17', 'PROP_REP_17', 'CLIENT_ID_17');
        insertPropAndRepr('PROP_18', 'PROP_REP_18', 'CLIENT_ID_18');
        insertPropAndRepr('PROP_19', 'PROP_REP_19', 'CLIENT_ID_19');
        insertPropAndRepr('PROP_20', 'PROP_REP_20', 'CLIENT_ID_20');
        insertPropAndRepr('PROP_21', 'PROP_REP_21', 'CLIENT_ID_21');
        insertPropAndRepr('PROP_22', 'PROP_REP_22', 'CLIENT_ID_22');
        insertPropAndRepr('PROP_23', 'PROP_REP_23', 'CLIENT_ID_23');
        insertPropAndRepr('PROP_24', 'PROP_REP_24', 'CLIENT_ID_24');
        insertPropAndRepr('PROP_25', 'PROP_REP_25', 'CLIENT_ID_25');
        insertPropAndRepr('PROP_26', 'PROP_REP_26', 'CLIENT_ID_26');
        insertPropAndRepr('PROP_27', 'PROP_REP_27', 'CLIENT_ID_27');
        List<Client__c> clients = new List<Client__c>();
        Integer hoursEarlier = 5;
        
        /* When */
        clients.add(createFirstLoginTodayClient('CID_1', 'CLIENT_ID_1', account));
        clients.add(createFirstLoginTodayClient('CID_2', 'CLIENT_ID_2', account));
        clients.add(createFirstLoginTodayClient('CID_3', 'CLIENT_ID_3', account));
        clients.add(createFirstLoginTodayClient('CID_4', 'CLIENT_ID_4', account));
        clients.add(createFirstLoginTodayClient('CID_5', 'CLIENT_ID_5', account));
        clients.add(createFirstLoginTodayClient('CID_6', 'CLIENT_ID_6', account));
        clients.add(createFirstLoginTodayClient('CID_7', 'CLIENT_ID_7', account));
        clients.add(createFirstLoginTodayClient('CID_8', 'CLIENT_ID_8', account));
        clients.add(createFirstLoginTodayClient('CID_9', 'CLIENT_ID_9', account));
        clients.add(createFirstLoginTodayClient('CID_10', 'CLIENT_ID_10', account));
        clients.add(createFirstLoginTodayClient('CID_11', 'CLIENT_ID_11', account));
        clients.add(createFirstLoginTodayClient('CID_12', 'CLIENT_ID_12', account));
        clients.add(createFirstLoginTodayClient('CID_13', 'CLIENT_ID_13', account));
        clients.add(createFirstLoginTodayClient('CID_14', 'CLIENT_ID_14', account));
        clients.add(createFirstLoginTodayClient('CID_15', 'CLIENT_ID_15', account));
        clients.add(createFirstLoginTodayClient('CID_16', 'CLIENT_ID_16', account));
        clients.add(createFirstLoginTodayClient('CID_17', 'CLIENT_ID_17', account));
        clients.add(createFirstLoginTodayClient('CID_18', 'CLIENT_ID_18', account));
        clients.add(createFirstLoginTodayClient('CID_19', 'CLIENT_ID_19', account));
        clients.add(createFirstLoginTodayClient('CID_20', 'CLIENT_ID_20', account));
        clients.add(createFirstLoginTodayClient('CID_21', 'CLIENT_ID_21', account));
        clients.add(createFirstLoginTodayClient('CID_22', 'CLIENT_ID_22', account));
        clients.add(createFirstLoginTodayClient('CID_23', 'CLIENT_ID_23', account));
        clients.add(createFirstLoginTodayClient('CID_24', 'CLIENT_ID_24', account));
        clients.add(createFirstLoginTodayClient('CID_25', 'CLIENT_ID_25', account));
        clients.add(createFirstLoginTodayClient('CID_26', 'CLIENT_ID_26', account));
        clients.add(createFirstLoginTodayClient('CID_27', 'CLIENT_ID_27', account));
        insertClients(clients);

        /* Then */
        checkPropertyOnAccountFirstLogin(account, 'PROP_1');
        checkPropertyOnAccountFirstLogin(account, 'PROP_2');
        checkPropertyOnAccountFirstLogin(account, 'PROP_3');
        checkPropertyOnAccountFirstLogin(account, 'PROP_4');
        checkPropertyOnAccountFirstLogin(account, 'PROP_5');
        checkPropertyOnAccountFirstLogin(account, 'PROP_6');
        checkPropertyOnAccountFirstLogin(account, 'PROP_7');
        checkPropertyOnAccountFirstLogin(account, 'PROP_8');
        checkPropertyOnAccountFirstLogin(account, 'PROP_9');
        checkPropertyOnAccountFirstLogin(account, 'PROP_10');
        checkPropertyOnAccountFirstLogin(account, 'PROP_11');
        checkPropertyOnAccountFirstLogin(account, 'PROP_12');
        checkPropertyOnAccountFirstLogin(account, 'PROP_13');
        checkPropertyOnAccountFirstLogin(account, 'PROP_14');
        checkPropertyOnAccountFirstLogin(account, 'PROP_15');
        checkPropertyOnAccountFirstLogin(account, 'PROP_16');
        checkPropertyOnAccountFirstLogin(account, 'PROP_17');
        checkPropertyOnAccountFirstLogin(account, 'PROP_18');
        checkPropertyOnAccountFirstLogin(account, 'PROP_19');
        checkPropertyOnAccountFirstLogin(account, 'PROP_19');
        checkPropertyOnAccountFirstLogin(account, 'PROP_20');
        checkPropertyOnAccountFirstLogin(account, 'PROP_21');
        checkPropertyOnAccountFirstLogin(account, 'PROP_22');
        checkPropertyOnAccountFirstLogin(account, 'PROP_23');
        checkPropertyOnAccountFirstLogin(account, 'PROP_24');
        checkPropertyOnAccountFirstLogin(account, 'PROP_25');
        checkPropertyOnAccountFirstLogin(account, 'PROP_26');
        checkNoPropertyOnAccountFirstLoginWasntEmpty(account, 'PROP_27');
    }

    /* Check if the given property limit can be reached inserting
     * different properties all with the first login action.
     * https://tcccdiam.atlassian.net/browse/CRM-1392
     */
    static testMethod void negTestMoreThanPropertyLimitAlreadyHasWelcomeEmail1() {
        /* Given */
        ID account = insertAccount('Test_Account');
        insertPropAndRepr('PROP_X', 'PROP_REP_X', 'CLIENT_ID_X');
        ID propx = readProperty('PROP_REP_X').Parent__c;
        insertFirstLogin2Property(account, propx);
        
        
        insertPropAndRepr('PROP_1', 'PROP_REP_1', 'CLIENT_ID_1');
        insertPropAndRepr('PROP_2', 'PROP_REP_2', 'CLIENT_ID_2');
        insertPropAndRepr('PROP_3', 'PROP_REP_3', 'CLIENT_ID_3');
        insertPropAndRepr('PROP_4', 'PROP_REP_4', 'CLIENT_ID_4');
        insertPropAndRepr('PROP_5', 'PROP_REP_5', 'CLIENT_ID_5');
        insertPropAndRepr('PROP_6', 'PROP_REP_6', 'CLIENT_ID_6');
        insertPropAndRepr('PROP_7', 'PROP_REP_7', 'CLIENT_ID_7');
        insertPropAndRepr('PROP_8', 'PROP_REP_8', 'CLIENT_ID_8');
        insertPropAndRepr('PROP_9', 'PROP_REP_9', 'CLIENT_ID_9');
        insertPropAndRepr('PROP_10', 'PROP_REP_10', 'CLIENT_ID_10');
        insertPropAndRepr('PROP_11', 'PROP_REP_11', 'CLIENT_ID_11');
        insertPropAndRepr('PROP_12', 'PROP_REP_12', 'CLIENT_ID_12');
        insertPropAndRepr('PROP_13', 'PROP_REP_13', 'CLIENT_ID_13');
        insertPropAndRepr('PROP_14', 'PROP_REP_14', 'CLIENT_ID_14');
        insertPropAndRepr('PROP_15', 'PROP_REP_15', 'CLIENT_ID_15');
        insertPropAndRepr('PROP_16', 'PROP_REP_16', 'CLIENT_ID_16');
        insertPropAndRepr('PROP_17', 'PROP_REP_17', 'CLIENT_ID_17');
        insertPropAndRepr('PROP_18', 'PROP_REP_18', 'CLIENT_ID_18');
        insertPropAndRepr('PROP_19', 'PROP_REP_19', 'CLIENT_ID_19');
        insertPropAndRepr('PROP_20', 'PROP_REP_20', 'CLIENT_ID_20');
        insertPropAndRepr('PROP_21', 'PROP_REP_21', 'CLIENT_ID_21');
        insertPropAndRepr('PROP_22', 'PROP_REP_22', 'CLIENT_ID_22');
        insertPropAndRepr('PROP_23', 'PROP_REP_23', 'CLIENT_ID_23');
        insertPropAndRepr('PROP_24', 'PROP_REP_24', 'CLIENT_ID_24');
        insertPropAndRepr('PROP_25', 'PROP_REP_25', 'CLIENT_ID_25');
        insertPropAndRepr('PROP_27', 'PROP_REP_27', 'CLIENT_ID_27');
        List<Client__c> clients = new List<Client__c>();
        Integer hoursEarlier = 5;
        
        /* When */
        clients.add(createFirstLoginTodayClient('CID_1', 'CLIENT_ID_1', account));
        clients.add(createFirstLoginTodayClient('CID_2', 'CLIENT_ID_2', account));
        clients.add(createFirstLoginTodayClient('CID_3', 'CLIENT_ID_3', account));
        clients.add(createFirstLoginTodayClient('CID_4', 'CLIENT_ID_4', account));
        clients.add(createFirstLoginTodayClient('CID_5', 'CLIENT_ID_5', account));
        clients.add(createFirstLoginTodayClient('CID_6', 'CLIENT_ID_6', account));
        clients.add(createFirstLoginTodayClient('CID_7', 'CLIENT_ID_7', account));
        clients.add(createFirstLoginTodayClient('CID_8', 'CLIENT_ID_8', account));
        clients.add(createFirstLoginTodayClient('CID_9', 'CLIENT_ID_9', account));
        clients.add(createFirstLoginTodayClient('CID_10', 'CLIENT_ID_10', account));
        clients.add(createFirstLoginTodayClient('CID_11', 'CLIENT_ID_11', account));
        clients.add(createFirstLoginTodayClient('CID_12', 'CLIENT_ID_12', account));
        clients.add(createFirstLoginTodayClient('CID_13', 'CLIENT_ID_13', account));
        clients.add(createFirstLoginTodayClient('CID_14', 'CLIENT_ID_14', account));
        clients.add(createFirstLoginTodayClient('CID_15', 'CLIENT_ID_15', account));
        clients.add(createFirstLoginTodayClient('CID_16', 'CLIENT_ID_16', account));
        clients.add(createFirstLoginTodayClient('CID_17', 'CLIENT_ID_17', account));
        clients.add(createFirstLoginTodayClient('CID_18', 'CLIENT_ID_18', account));
        clients.add(createFirstLoginTodayClient('CID_19', 'CLIENT_ID_19', account));
        clients.add(createFirstLoginTodayClient('CID_20', 'CLIENT_ID_20', account));
        clients.add(createFirstLoginTodayClient('CID_21', 'CLIENT_ID_21', account));
        clients.add(createFirstLoginTodayClient('CID_22', 'CLIENT_ID_22', account));
        clients.add(createFirstLoginTodayClient('CID_23', 'CLIENT_ID_23', account));
        clients.add(createFirstLoginTodayClient('CID_24', 'CLIENT_ID_24', account));
        clients.add(createFirstLoginTodayClient('CID_25', 'CLIENT_ID_25', account));
        clients.add(createFirstLoginTodayClient('CID_27', 'CLIENT_ID_27', account));
        insertClients(clients);

        /* Then */
        checkPropertyOnAccountFirstLogin(account, 'PROP_1');
        checkPropertyOnAccountFirstLogin(account, 'PROP_2');
        checkPropertyOnAccountFirstLogin(account, 'PROP_3');
        checkPropertyOnAccountFirstLogin(account, 'PROP_4');
        checkPropertyOnAccountFirstLogin(account, 'PROP_5');
        checkPropertyOnAccountFirstLogin(account, 'PROP_6');
        checkPropertyOnAccountFirstLogin(account, 'PROP_7');
        checkPropertyOnAccountFirstLogin(account, 'PROP_8');
        checkPropertyOnAccountFirstLogin(account, 'PROP_9');
        checkPropertyOnAccountFirstLogin(account, 'PROP_10');
        checkPropertyOnAccountFirstLogin(account, 'PROP_11');
        checkPropertyOnAccountFirstLogin(account, 'PROP_12');
        checkPropertyOnAccountFirstLogin(account, 'PROP_13');
        checkPropertyOnAccountFirstLogin(account, 'PROP_14');
        checkPropertyOnAccountFirstLogin(account, 'PROP_15');
        checkPropertyOnAccountFirstLogin(account, 'PROP_16');
        checkPropertyOnAccountFirstLogin(account, 'PROP_17');
        checkPropertyOnAccountFirstLogin(account, 'PROP_18');
        checkPropertyOnAccountFirstLogin(account, 'PROP_19');
        checkPropertyOnAccountFirstLogin(account, 'PROP_19');
        checkPropertyOnAccountFirstLogin(account, 'PROP_20');
        checkPropertyOnAccountFirstLogin(account, 'PROP_21');
        checkPropertyOnAccountFirstLogin(account, 'PROP_22');
        checkPropertyOnAccountFirstLogin(account, 'PROP_23');
        checkPropertyOnAccountFirstLogin(account, 'PROP_24');
        checkPropertyOnAccountFirstLogin(account, 'PROP_25');
        checkNoPropertyOnAccountFirstLoginWasntEmpty(account, 'PROP_27');
    }

    
    /* Check if the given account contains the property associated with the property representation */
    private static void checkPropertyOnAccountFirstLogin(ID accountId, String propertyExtId) {
        Account account = readAccount(accountId);
        ID property = readProperty(propertyExtId).ID;
        String firstLogin = firstLoginToToday(account);
        System.assertNotEquals(firstLogin, null,
            'First Login To field was empty.' +
            ' FirstLoginTo_1: ' + account.firstLoginTo_1__c +
            ' Welcome_email_1: ' + account.welcomeEmailDate_1__c +
            ' FirstLoginTo_2: ' + account.firstLoginTo_2__c +
            ' Welcome_email_2: ' + account.welcomeEmailDate_2__c
        );
        System.assert(
            firstLogin.contains(property),
            'The account does not contain the property ID. FirstLoginTo: ' +  firstLogin +
            ' FirstLoginTo_1: ' + account.firstLoginTo_1__c +
            ' Welcome_email_1: ' + account.welcomeEmailDate_1__c +
            ' FirstLoginTo_2: ' + account.firstLoginTo_2__c +
            ' Welcome_email_2: ' + account.welcomeEmailDate_2__c +
            ' Property: ' + property +
            ' Property Represetation ext id: ' + propertyExtId
        );
    }

    /* Check if the given account does not contains the property associated with the property representation, if the
     * firstLoginTo field was empty.
     */
    private static void checkNoPropertyOnAccountFirstLoginWasEmpty(ID accountId, String propertyExtId) {
        Account account = readAccount(accountId);
        ID property = readProperty(propertyExtId).ID;
        String firstLogin = firstLoginToToday(account);
        System.assert(
            firstLogin == null,
            'The account does not contain the property ID. FirstLoginTo: ' + 
               firstLogin + ' Property: ' + property +
            ' Property Represetation ext id: ' +
               propertyExtId
        );
    }
    
    /* Check if the given account contains the property associated with the property representation, if the
     * firstLoginTo field was not empty.
     */
    private static void checkNoPropertyOnAccountFirstLoginWasntEmpty(ID accountId, String propertyExtId) {
        Account account = readAccount(accountId);
        ID property = readProperty(propertyExtId).ID;
        String firstLogin = firstLoginToToday(account);
        System.assertNotEquals(firstLogin, null, 'First Login To field was null.');
        System.assert(
            !(firstLogin.contains(property)),
            'The account does contain the property ID. FirstLoginTo: ' + 
               firstLogin + ' Property: ' + property +
            ' Property Represetation ext id: ' +
               propertyExtId
        );
    }
    
    /* Returns the firstLoginTo value which contains property ids based on the today's date.
     */
    private static String firstLoginToToday(Account account) {
        String firstLogin = null;
        if(account.firstLoginTo_1__c != null) {
            firstLogin = account.firstLoginTo_1__c;
        }
        if(account.firstLoginTo_2__c != null) {
            if(firstLogin == null) {
                firstLogin = account.firstLoginTo_2__c;
            } else {
                firstLogin += ',';
                firstLogin += account.firstLoginTo_2__c;
            }
        }
        return firstLogin;
    }    
    
    /* The insertion was successful, if the account has the same contact ID
     * as on the client id.
     */
    private static void checkContactIdInsert(Id accountId, Id clientId){
        Account accWithContactId = [SELECT PersonContactId FROM Account WHERE Id = :accountId];
        Client__c clientWithContactId = [SELECT Contact__c FROM Client__c WHERE Id = :clientId];
        System.assertEquals(accWithContactId.PersonContactId, clientWithContactId.Contact__c, 'The Contact Ids do do not match for the client insert');
    }
    
    /* The insertion was successfull if the property representation is filled up
     * with the given property representation id
     */
    private static void checkClient(ID clientId, ID propRepID) {
        System.assertNotEquals(clientID, null, 'Client was not inserted');
        Client__c client = readClient(clientId);
        System.assertEquals(client.Property_Representation__c, propRepID, 'Property representation was not filled up');
    }
    
    /* Check if the given clientId represented client can be found in the given map, and
     * it has has the given property representation object
     */
    private static void checkClient(Map<String, Client__c> clients, String clientId, ID propRepId) {
        Client__c client = clients.get(clientId);
        //System.assertNotEquals(client, null, 'Client was not inserted');
        System.assertNotEquals(client, null, 'Client was not inserted'+clients);
        System.assertEquals(client.Property_Representation__c, propRepID, 'Property representation was not filled up');
    }
    
    /* The the insertion was erroneous than the produced client id is null */
    private static void checkWrongClient(ID clientId) {
        System.assertEquals(clientId, null, 'The insertion was successful');
    }
    
    /* Check if the given clientId is not found in the given dictionary.
     */
    private static void checkWrongClient(Map<String, Client__c> clients, String extId) {
        Client__c client = clients.get(extId);
        System.assertEquals(client, null, 'The insertion was successful');
    }
    
    /* Insert a CRM related account to the database 
     * Produces the ID of the inserted account
     */
    private static ID insertAccount(String name) {
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
            Country_Code__pc='ES',
            Fax='12345',
            Phone='123456',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678',
            PersonOtherPhone='123456789',
            Screen_Name__pc='test',
            sf4twitter__Fcbk_User_Id__pc='test',
            sf4twitter__Twitter_User_Id__pc='test',
            Identity_Card_Number__pc='test',
            Website='test'
            );
        insert account;
        return account.id;
    }
    
    /* Reads the account for the given account id */
    private static Account readAccount(ID accountID) {
        Account account = [
            SELECT
                LastName,
                Salutation,
                FirstName,
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
                firstLoginToYesterday__c,
                firstLoginTo_1__c,
                firstLoginTo_2__c,
                welcomeEmailDate_1__c,
                welcomeEmailDate_2__c
            FROM
                Account
            WHERE
                Id =: accountID
            ];
        return account;
    }
    
    private static Client__c createClient(String extId, String propRepClientId, ID accountId) {
        Client__c client = new Client__c(
            pluralId__c=extId,
            clientId__c=propRepClientId,
            Account__c=accountId,
            firstLogin__c=null,
            lastLogin__c=null,
            channel__c=null
        );
        return client;
    }

    /* Creates a client where the first and last login dates are filled up with the today login date. */
    private static Client__c createFirstLoginTodayClient(
        String extId,
        String propRepClientId,
        ID accountId
    ) {
        Datetime now = Datetime.now();
        Datetime last = now;
        Datetime first = now;
        Client__c client = new Client__c(
            pluralId__c=extId,
            clientId__c=propRepClientId,
            Account__c=accountId,
            firstLogin__c=first,
            lastLogin__c=last,
            channel__c=null
        );
        return client;
    }
    
    /* Sets the client first and last login date for today */
    private static void updateClientFirstLoginToday(Client__c client) {
        Datetime now = Datetime.now();
        client.firstLogin__c = now;
        client.lastLogin__c = now;
    }
    
    /* Creates a client where the first and last login date is not filled in */
    private static Client__c createEmtpyFirstLoginClient(
        String extId,
        String propRepClientId,
        ID accountId
    ) {
        Client__c client = new Client__c(
            pluralId__c=extId,
            clientId__c=propRepClientId,
            Account__c=accountId,
            firstLogin__c=null,
            lastLogin__c=null,
            channel__c=null
        );
        return client;
    }
    
    
    private static ID insertClient(String extId, String propRepClientId, ID accountId) {
        Client__c client = createClient(extId, propRepClientId, accountId);
        try {
            insert client;
            return client.id;
        } catch (Exception e) {
            System.debug(e);
            return null;
        }
    }
    
    private static Map<String, ID> insertClients(List<Client__c> clients) {
        try {
            Database.insert(clients, False);
        } catch (Exception e) {
            System.Debug('INSERT CLIENTS: ' + e);
        }
        Map<String, ID> clientExtIds = new Map<String, ID>();
        List<String> extIds = new List<String>();
        for(Client__c c : clients) {
            extIds .add(c.pluralId__c);
            clientExtIds.put(c.pluralId__c, null);
        }
        List<Client__c> inserteds = [SELECT Id, pluralId__c FROM Client__c WHERE pluralId__c IN :extIds];
        for(Client__c c : inserteds) {
            clientExtIds.put(c.pluralId__c, c.Id);
        }
        return clientExtIds;
    }
    
    private static Client__c readClient(ID cId) {
        return [
            SELECT
                Id,
                pluralId__c,
                clientId__c,
                Account__c,
                firstLogin__c,
                lastLogin__c,
                channel__c,
                Property_Representation__c
            FROM
                Client__c
            WHERE
                Id =: cId
        ];
    }
    
    /* Return an external id to Client__c object map that contains
     * the found objects for the given Ids
     */
    private static Map<String, Client__c> readClients(List<String> ids) {
        List<Client__c> clients = [
            SELECT
                Id,
                pluralId__c,
                clientId__c,
                Account__c,
                firstLogin__c,
                lastLogin__c,
                channel__c,
                Property_Representation__c
            FROM
                Client__c
            WHERE
                pluralId__c IN :ids
        ];
        Map<String, Client__c> clientMap = new Map<String, Client__c>();
        for(Client__c c : clients) {
            clientMap.put(c.pluralId__c, c);
        }
        System.debug('Found client ids: ' + clientMap.keySet());
        return clientMap;
    }
    
    private static ID insertProperty(String extId, String uniqueName) {
        Property__c property = new Property__c(
            Property_Ext_ID__c=extId,
            Property_Unique_Name__c=uniqueName,
            Name='eudb.property',
            Description__c='',
            RecordTypeId=PROPERTY_RECORDTYPEID,
            Country__c='ES',
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

    private static ID insertPropAndRepr(String propertyExtId, String propRepExtId, String clientID) {
        ID p = insertProperty(propertyExtId, propertyExtId);
        ID pr = insertPropertyRepresentation(p, propRepExtId, clientId, propRepExtId);      
        return pr;
    }
    
    private static Property__c readProperty(String propertyExtId) {
        try {
            Property__c prop = [
                SELECT
                    Property_Ext_ID__c,
                    Property_Unique_Name__c,
                    Name,
                    Description__c,
                    RecordTypeId,
                    Country__c,
                    Language__c,
                    Brand__c,
                    Status__c,
                    Parent__c
                FROM
                    Property__c
                WHERE
                    Property_Ext_ID__c =: propertyExtID];
            return prop;
        } catch (Exception e) {
            System.assert(False, 'Property is not found with ext ID: ' + propertyExtId);
            return null;
        }
    }
    
}