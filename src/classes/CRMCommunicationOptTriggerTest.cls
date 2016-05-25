@isTest
public class CRMCommunicationOptTriggerTest {

    /* Testing level is integration testing
     * ------------------------------------
     *
     * Database insert and select are used as mechenism of the data manipulation
     * in the system.
     *
     * Test Design is a simple decision table based on the optid values of the
     * inserted communication opt records, valid and invalid values. Outcomes
     * are binary: can be inserted and cannot be inserted.
     * 
     * The next test design method based on the boundary value analysis, if
     * in every position of the inserted set, the invalid values got rejected.
     */

    private static ID PROPERTY_RECORDTYPEID;
    private static ID PROPERTY_REPRESENTATION_RECORDTYPEID;
    
    static {
        PROPERTY_RECORDTYPEID = [SELECT id FROM RecordType WHERE name = 'Consumer DB Property' LIMIT 1].Id;
        PROPERTY_REPRESENTATION_RECORDTYPEID = [SELECT id FROM RecordType WHERE name = 'Consumer DB Property Representation' LIMIT 1].Id;
    }    
    
    /* Opt insertion tests */
    
    static testMethod void testOneCOInsert() {
        /* Given */
        String OPT_EXT_ID = 'OPT_1';
        ID account = insertAccount('Test_Account');
        //ID opt = insertOpt(OPT_EXT_ID,'OPT_NAME_1');
        ID opt = insertOpt(OPT_EXT_ID);
        String CLIENT_ID = 'CLIENT_ID1';
        insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID);
        
        /* When */ ID comOpt = insertCommunicationOpt('COPT_EXT_ID_1', OPT_EXT_ID, account, CLIENT_ID);
        checkCommunicationOpt(comOpt, opt);
        checkContactIdInsert(account,comOpt);
    }
    
    static testMethod void testThreeCOInsert() {
        /* Given */
        String OPT_Unique_Name_1 = 'OPT_1';
        String OPT_Unique_Name_2 = 'OPT_2';
        String OPT_Unique_Name_3 = 'OPT_3';
        String CLIENT_ID = 'CLIENT_ID1';
        
        ID account = insertAccount('Test_Account');
        /*
        ID opt1 = insertOpt(OPT_Unique_Name_1,'OPT_NAME_1');
        ID opt2 = insertOpt(OPT_Unique_Name_2,'OPT_NAME_2');
        ID opt3 = insertOpt(OPT_Unique_Name_3,'OPT_NAME_3');
        */
        ID opt1 = insertOpt(OPT_Unique_Name_1);
        ID opt2 = insertOpt(OPT_Unique_Name_2);
        ID opt3 = insertOpt(OPT_Unique_Name_3);
        
        insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID);

        CommunicationOpt__c[] comOpts = new CommunicationOpt__c[3];
        comOpts[0] = communicationOpt('COPT_EXT_ID_1', OPT_Unique_Name_1, account, CLIENT_ID);
        comOpts[1] = communicationOpt('COPT_EXT_ID_2', OPT_Unique_Name_2, account, CLIENT_ID);
        comOpts[2] = communicationOpt('COPT_EXT_ID_3', OPT_Unique_Name_3, account, CLIENT_ID);
        
        /* When */ Map<String,ID> ids = insertCommunicationOpts(comOpts);
        /* Then */ checkCommunicationOpt(ids.get(OPT_Unique_Name_1), opt1);
        /* Then */ checkCommunicationOpt(ids.get(OPT_Unique_Name_2), opt2);
        /* Then */ checkCommunicationOpt(ids.get(OPT_Unique_Name_3), opt3);
    }
    
    static testMethod void testOneWrongInsert() {
        /* Given */
        String CLIENT_ID = 'CLIENT_ID1';
        insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID);

        ID account = insertAccount('Test_Account');
        //ID opt = insertOpt('OPT_1','OPT_NAME_1');
        ID opt = insertOpt('OPT_1');
        ID comOpt = insertCommunicationOpt('COPT_EXT_ID_1', 'OPT_X', account, CLIENT_ID);
        
        checkWrongCommunicationOpt(comOpt);
    }
    
    static testMethod void testInsertThreeMissingFirstExtId() {
        /* Given */
        String OPT_EXT_ID_1 = 'OPT_1';
        String OPT_EXT_ID_2 = 'OPT_2';
        String OPT_EXT_ID_3 = 'OPT_3';
        String OPT_X = 'OPT_X';
        String CLIENT_ID = 'CLIENT_ID1';

        ID account = insertAccount('Test_Account');
        /*
        ID opt1 = insertOpt(OPT_EXT_ID_1,'OPT_NAME_1');
        ID opt2 = insertOpt(OPT_EXT_ID_2,'OPT_NAME_2');
        ID opt3 = insertOpt(OPT_EXT_ID_3,'OPT_NAME_3');
        */
        ID opt1 = insertOpt(OPT_EXT_ID_1);
        ID opt2 = insertOpt(OPT_EXT_ID_2);
        ID opt3 = insertOpt(OPT_EXT_ID_3);
        insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID);
        CommunicationOpt__c[] comOpts = new CommunicationOpt__c[3];
        comOpts[0] = communicationOpt('COPT_EXT_ID_1', OPT_X, account, CLIENT_ID);
        comOpts[1] = communicationOpt('COPT_EXT_ID_2', OPT_EXT_ID_2, account, CLIENT_ID);
        comOpts[2] = communicationOpt('COPT_EXT_ID_3', OPT_EXT_ID_3, account, CLIENT_ID);
        
        /* When */ Map<String,ID> ids = insertCommunicationOpts(comOpts);
        /* Then */ checkWrongCommunicationOpt(ids.get(OPT_X));
        /* Then */ checkCommunicationOpt(ids.get(OPT_EXT_ID_2), opt2);
        /* Then */ checkCommunicationOpt(ids.get(OPT_EXT_ID_3), opt3);
    }

    static testMethod void testInsertThreeMissingSecondExtId() {
        /* Given */
        String OPT_EXT_ID_1 = 'OPT_1';
        String OPT_EXT_ID_2 = 'OPT_2';
        String OPT_EXT_ID_3 = 'OPT_3';
        String OPT_X = 'OPT_X';
        String CLIENT_ID = 'CLIENT_ID1';

        ID account = insertAccount('Test_Account');
        /*
        ID opt1 = insertOpt(OPT_EXT_ID_1,'OPT_NAME_1');
        ID opt2 = insertOpt(OPT_EXT_ID_2,'OPT_NAME_2');
        ID opt3 = insertOpt(OPT_EXT_ID_3,'OPT_NAME_3');
        */
        ID opt1 = insertOpt(OPT_EXT_ID_1);
        ID opt2 = insertOpt(OPT_EXT_ID_2);
        ID opt3 = insertOpt(OPT_EXT_ID_3);
        
        insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID);
        CommunicationOpt__c[] comOpts = new CommunicationOpt__c[3];
        comOpts[0] = communicationOpt('COPT_EXT_ID_1', OPT_EXT_ID_1, account, CLIENT_ID);
        comOpts[1] = communicationOpt('COPT_EXT_ID_2', OPT_X, account, CLIENT_ID);
        comOpts[2] = communicationOpt('COPT_EXT_ID_3', OPT_EXT_ID_3, account, CLIENT_ID);
        
        /* When */ Map<String,ID> ids = insertCommunicationOpts(comOpts);
        /* Then */ checkCommunicationOpt(ids.get(OPT_EXT_ID_1), opt1);
        /* Then */ checkWrongCommunicationOpt(ids.get(OPT_X));
        /* Then */ checkCommunicationOpt(ids.get(OPT_EXT_ID_3), opt3);   
    }
    
    static testMethod void testInsertThreeMissingThirdExtId() {
        /* Given */
        String OPT_EXT_ID_1 = 'OPT_1';
        String OPT_EXT_ID_2 = 'OPT_2';
        String OPT_EXT_ID_3 = 'OPT_3';
        String OPT_X = 'OPT_X';
        String CLIENT_ID = 'CLIENT_ID1';

        ID account = insertAccount('Test_Account');
        /*
        ID opt1 = insertOpt(OPT_EXT_ID_1,'OPT_NAME_1');
        ID opt2 = insertOpt(OPT_EXT_ID_2,'OPT_NAME_2');
        ID opt3 = insertOpt(OPT_EXT_ID_3,'OPT_NAME_3');
        */
        ID opt1 = insertOpt(OPT_EXT_ID_1);
        ID opt2 = insertOpt(OPT_EXT_ID_2);
        ID opt3 = insertOpt(OPT_EXT_ID_3);
        insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID);
        CommunicationOpt__c[] comOpts = new CommunicationOpt__c[3];
        comOpts[0] = communicationOpt('COPT_EXT_ID_1', OPT_EXT_ID_1, account, CLIENT_ID);
        comOpts[1] = communicationOpt('COPT_EXT_ID_2', OPT_EXT_ID_2, account, CLIENT_ID);
        comOpts[2] = communicationOpt('COPT_EXT_ID_3', OPT_X, account, CLIENT_ID);
        
        /* When */ Map<String,ID> ids = insertCommunicationOpts(comOpts);
        /* Then */ checkCommunicationOpt(ids.get(OPT_EXT_ID_1), opt1);
        /* Then */ checkCommunicationOpt(ids.get(OPT_EXT_ID_2), opt2);
        /* Then */ checkWrongCommunicationOpt(ids.get(OPT_X));
    }

    static testMethod void testInsertOneEmptyExtId() {
        /* Given */
        ID account = insertAccount('Test_Account');
        //ID opt = insertOpt('OPT_1','OPT_NAME_1');
        ID opt = insertOpt('OPT_1');
        String CLIENT_ID = 'CLIENT_ID1';
        insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID);
        
        /* When */ ID comOpt = insertCommunicationOpt('COPT_EXT_ID_1', '', account, CLIENT_ID);
        /* Then */ checkWrongCommunicationOpt(comOpt);
    }

    static testMethod void testInsertOneNullExtId() {
        /* Given */
        ID account = insertAccount('Test_Account');
        //ID opt = insertOpt('OPT_1','OPT_NAME_1');
        ID opt = insertOpt('OPT_1');
        String CLIENT_ID = 'CLIENT_ID1';
        insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID);
        
        /* When */ ID comOpt = insertCommunicationOpt('COPT_EXT_ID_1', null, account, CLIENT_ID);
        /* Then */ checkWrongCommunicationOpt(comOpt);
    }
    
    /* 'Property Representation' insertion test */
    
    static testMethod void testInsertOnePropRep() {
        /* Given */
        String OPT_EXT_ID = 'OPT_1';
        String CLIENT_ID = 'CLIENT_ID1';
        ID account = insertAccount('Test_Account');
        //ID opt = insertOpt(OPT_EXT_ID,'OPT_NAME_1');
        ID opt = insertOpt('OPT_1');
        ID propRep = insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID);
        
        /* When */ ID comOpt = insertCommunicationOpt('COPT_EXT_ID_1', OPT_EXT_ID, account, CLIENT_ID);
        /* Then */ checkCommunicationOptPropRep(comOpt, propRep);
    }

    // Test if the null client id insertion does not work
    static testMethod void testInsertOnePropRepNullClientID() {
        /* Given */
        String OPT_EXT_ID = 'OPT_1';
        String CLIENT_ID = 'CLIENT_ID1';
        ID account = insertAccount('Test_Account');
        //ID opt = insertOpt(OPT_EXT_ID,'OPT_NAME_1');
        ID opt = insertOpt('OPT_1');
        ID propRep = insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID);
        
        /* When */ ID comOpt = insertCommunicationOpt('COPT_EXT_ID_1', OPT_EXT_ID, account, null);
        /* Then */ checkWrongCommunicationOpt(comOpt);
    }
    
    // Test if the empty client id insertion does not work
    static testMethod void testInsertOnePropRepEmptyClientID() {
        /* Given */
        String OPT_EXT_ID = 'OPT_1';
        String CLIENT_ID = 'CLIENT_ID1';
        ID account = insertAccount('Test_Account');
        //ID opt = insertOpt(OPT_EXT_ID,'OPT_NAME_1');
        ID opt = insertOpt('OPT_1');
        ID propRep = insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID);
        
        /* When */ ID comOpt = insertCommunicationOpt('COPT_EXT_ID_1', OPT_EXT_ID, account, '');
        /* Then */ checkWrongCommunicationOpt(comOpt);
    }   

    static testMethod void testThreeCOPropRepInsert() {
        /* Given */
        String OPT_EXT_ID_1 = 'OPT_1';
        String OPT_EXT_ID_2 = 'OPT_2';
        String OPT_EXT_ID_3 = 'OPT_3';
        String CLIENT_ID_1 = 'CLIENT_ID_1';
        String CLIENT_ID_2 = 'CLIENT_ID_2';
        String CLIENT_ID_3 = 'CLIENT_ID_3';
        
        ID account = insertAccount('Test_Account');
        /*
        ID opt1 = insertOpt(OPT_EXT_ID_1,'OPT_NAME_1');
        ID opt2 = insertOpt(OPT_EXT_ID_2,'OPT_NAME_2');
        ID opt3 = insertOpt(OPT_EXT_ID_3,'OPT_NAME_3');
        */
        ID opt1 = insertOpt(OPT_EXT_ID_1);
        ID opt2 = insertOpt(OPT_EXT_ID_2);
        ID opt3 = insertOpt(OPT_EXT_ID_3);
        
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID_1);
        ID prop2 = insertPropAndRepr('PROP_2', 'PROP_REP_2', CLIENT_ID_2);
        ID prop3 = insertPropAndRepr('PROP_3', 'PROP_REP_3', CLIENT_ID_3);

        CommunicationOpt__c[] comOpts = new CommunicationOpt__c[3];
        comOpts[0] = communicationOpt('COPT_EXT_ID_1', OPT_EXT_ID_1, account, CLIENT_ID_1);
        comOpts[1] = communicationOpt('COPT_EXT_ID_2', OPT_EXT_ID_2, account, CLIENT_ID_2);
        comOpts[2] = communicationOpt('COPT_EXT_ID_3', OPT_EXT_ID_3, account, CLIENT_ID_3);
        
        /* When */ Map<String,ID> ids = insertCommunicationOpts(comOpts);
        /* Then */ checkCommunicationOptPropRep(ids.get(OPT_EXT_ID_1), prop1);
        /* Then */ checkCommunicationOptPropRep(ids.get(OPT_EXT_ID_2), prop2);
        /* Then */ checkCommunicationOptPropRep(ids.get(OPT_EXT_ID_3), prop3);
    }
    
    static testMethod void testFourCOPropRepInsertNullAndEmtpy() {
        /* Given */
        String OPT_EXT_ID_1 = 'OPT_1';
        String OPT_EXT_ID_2 = 'OPT_2';
        String OPT_EXT_ID_3 = 'OPT_3';
        String OPT_EXT_ID_4 = 'OPT_4';
        String CLIENT_ID_1 = 'CLIENT_ID_1';
        String CLIENT_ID_2 = 'CLIENT_ID_2';
        String CLIENT_ID_3 = 'CLIENT_ID_3';
        String CLIENT_ID_4 = 'CLIENT_ID_4';
        
        ID account = insertAccount('Test_Account');
        /*
        ID opt1 = insertOpt(OPT_EXT_ID_1,'OPT_NAME_1');
        ID opt2 = insertOpt(OPT_EXT_ID_2,'OPT_NAME_2');
        ID opt3 = insertOpt(OPT_EXT_ID_3,'OPT_NAME_3');
        ID opt4 = insertOpt(OPT_EXT_ID_4,'OPT_NAME_4');
        */
        ID opt1 = insertOpt(OPT_EXT_ID_1);
        ID opt2 = insertOpt(OPT_EXT_ID_2);
        ID opt3 = insertOpt(OPT_EXT_ID_3);
        ID opt4 = insertOpt(OPT_EXT_ID_4);
        
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID_1);
        ID prop2 = insertPropAndRepr('PROP_2', 'PROP_REP_2', CLIENT_ID_2);
        ID prop3 = insertPropAndRepr('PROP_3', 'PROP_REP_3', CLIENT_ID_3);
        ID prop4 = insertPropAndRepr('PROP_4', 'PROP_REP_4', CLIENT_ID_4);

        CommunicationOpt__c[] comOpts = new CommunicationOpt__c[4];
        comOpts[0] = communicationOpt('COPT_EXT_ID_1', OPT_EXT_ID_1, account, '');
        comOpts[1] = communicationOpt('COPT_EXT_ID_2', OPT_EXT_ID_2, account, null);
        comOpts[2] = communicationOpt('COPT_EXT_ID_3', OPT_EXT_ID_3, account, '');
        comOpts[3] = communicationOpt('COPT_EXT_ID_4', OPT_EXT_ID_4, account, null);
        
        /* When */ Map<String,ID> ids = insertCommunicationOpts(comOpts);
        /* Then */ checkWrongCommunicationOpt(ids.get(OPT_EXT_ID_1));
        /* Then */ checkWrongCommunicationOpt(ids.get(OPT_EXT_ID_2));
        /* Then */ checkWrongCommunicationOpt(ids.get(OPT_EXT_ID_3));
        /* Then */ checkWrongCommunicationOpt(ids.get(OPT_EXT_ID_4));
    }
    
    static testMethod void testFourCOPropRepInsertNullAndEmtpy2() {
        /* Given */
        String OPT_EXT_ID_1 = 'OPT_1';
        String OPT_EXT_ID_2 = 'OPT_2';
        String OPT_EXT_ID_3 = 'OPT_3';
        String OPT_EXT_ID_4 = 'OPT_4';
        String CLIENT_ID_1 = 'CLIENT_ID_1';
        String CLIENT_ID_2 = 'CLIENT_ID_2';
        String CLIENT_ID_3 = 'CLIENT_ID_3';
        String CLIENT_ID_4 = 'CLIENT_ID_4';
        
        ID account = insertAccount('Test_Account');
        /*
        ID opt1 = insertOpt(OPT_EXT_ID_1,'OPT_NAME_1');
        ID opt2 = insertOpt(OPT_EXT_ID_2,'OPT_NAME_2');
        ID opt3 = insertOpt(OPT_EXT_ID_3,'OPT_NAME_3');
        ID opt4 = insertOpt(OPT_EXT_ID_4,'OPT_NAME_4');
        */
        ID opt1 = insertOpt(OPT_EXT_ID_1);
        ID opt2 = insertOpt(OPT_EXT_ID_2);
        ID opt3 = insertOpt(OPT_EXT_ID_3);
        ID opt4 = insertOpt(OPT_EXT_ID_4);
        
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID_1);
        ID prop2 = insertPropAndRepr('PROP_2', 'PROP_REP_2', CLIENT_ID_2);
        ID prop3 = insertPropAndRepr('PROP_3', 'PROP_REP_3', CLIENT_ID_3);
        ID prop4 = insertPropAndRepr('PROP_4', 'PROP_REP_4', CLIENT_ID_4);

        CommunicationOpt__c[] comOpts = new CommunicationOpt__c[4];
        comOpts[0] = communicationOpt('COPT_EXT_ID_1', OPT_EXT_ID_1, account, null);
        comOpts[1] = communicationOpt('COPT_EXT_ID_2', OPT_EXT_ID_2, account, '');
        comOpts[2] = communicationOpt('COPT_EXT_ID_3', OPT_EXT_ID_3, account, null);
        comOpts[3] = communicationOpt('COPT_EXT_ID_4', OPT_EXT_ID_4, account, '');
        
        /* When */ Map<String,ID> ids = insertCommunicationOpts(comOpts);
        /* Then */ checkWrongCommunicationOpt(ids.get(OPT_EXT_ID_1));
        /* Then */ checkWrongCommunicationOpt(ids.get(OPT_EXT_ID_2));
        /* Then */ checkWrongCommunicationOpt(ids.get(OPT_EXT_ID_3));
        /* Then */ checkWrongCommunicationOpt(ids.get(OPT_EXT_ID_4));
    }    
    
    /* The three digit indentifier should be copied from the OPT to
     * the account connected with the given CommunicationOpt object
     *
     * Decision Table for the test cases
     * Actions:
     * - The identifier is copied to the field of the account    (C)
     * - The identifier is deleted from the field of the account (D)
     * - The field of the account is not modified                (NC)
     *
     * Conditions:
     * INSERT
     * - Insert comopt for the included opt (I)
     * - Insert comopt for opt-ed out       (O)
     *
     * SET
     * - Empty set on the account                 (E)
     * - One elements set of the account          (S) Singleton
     * - More than one element on the account set (M)
     *
     * CONTAINS
     * - The inserted opt is already in the account field (Y/N)
     *
     * Table:
     * TCN         1  2  3  4  5  6  7  8  9 10
     * Conditions
     * ----------------------------------------
     * INSERT      I  I  I  I  I  O  O  O  O  O
     * SET         E  S  S  M  M  E  S  S  M  M
     * CONTAINS    -  Y  N  Y  N  -  Y  N  Y  N
     * ----------------------------------------
     * Action      C NC  C NC  C NC  D NC  D NC
     *
     * One extra test case is defined, named 11 which uses
     * the same set as the test case 9, but instead of
     * insert the update method is used.
     *
     * Test cases has a testAccountCommunicationOptPrefixes
     *
     * https://tcccdiam.atlassian.net/browse/CRM-1547
     * "As a Campaign Manager I want to be able to use individual email results and communication opt information together in a segmentation."
     */
    
    static testMethod void testAccountCommunicationOptPrefixesTC_01() {
        /* One element set is created after the insertion of a new comopt */
        
        /* Given */
        String OPT_EXT_ID_1 = 'OPT_1';
        String CLIENT_ID_1 = 'CLIENT_ID_1';
        
        ID account = insertAccount('Test_Account');

        ID opt1 = insertOpt(OPT_EXT_ID_1);
        
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID_1);

        CommunicationOpt__c[] comOpts = new CommunicationOpt__c[1];
        comOpts[0] = communicationOpt('COPT_EXT_ID_1', OPT_EXT_ID_1, account, CLIENT_ID_1, ACCEPTED);
        
        /* When */ Map<String,ID> ids = insertCommunicationOpts(comOpts);
        Account acc = readAccount(account);
        /* Then */ checkAccountComOpts(acc, '001');
    }
    
    static testMethod void testAccountCommunicationOptPrefixesTC_02() {
        /* One element set is not changed */
        /* Given */
        String OPT_EXT_ID_1 = 'OPT_1';
        String CLIENT_ID_1 = 'CLIENT_ID_1';
        
        ID account = insertAccount('Test_Account');

        ID opt1 = insertOpt(OPT_EXT_ID_1);
        
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID_1);

        CommunicationOpt__c[] comOpts = new CommunicationOpt__c[2];
        comOpts[0] = communicationOpt('COPT_EXT_ID_1', OPT_EXT_ID_1, account, CLIENT_ID_1, ACCEPTED);
        comOpts[1] = communicationOpt('COPT_EXT_ID_2', OPT_EXT_ID_1, account, CLIENT_ID_1, ACCEPTED);
        
        /* When */ Map<String,ID> ids = insertCommunicationOpts(comOpts);
        Account acc = readAccount(account);
        /* Then */ checkAccountComOpts(acc, '001');
    }

    static testMethod void testAccountCommunicationOptPrefixesTC_03() {
        /* Two elemented set is created */
        /* Given */
        String OPT_EXT_ID_1 = 'OPT_1';
        String OPT_EXT_ID_2 = 'OPT_2';
        String CLIENT_ID_1 = 'CLIENT_ID_1';
        
        ID account = insertAccount('Test_Account');

        ID opt1 = insertOpt(OPT_EXT_ID_1);
        ID opt2 = insertOpt(OPT_EXT_ID_2);
        
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID_1);

        CommunicationOpt__c[] comOpts = new CommunicationOpt__c[2];
        comOpts[0] = communicationOpt('COPT_EXT_ID_1', OPT_EXT_ID_1, account, CLIENT_ID_1, ACCEPTED);
        comOpts[1] = communicationOpt('COPT_EXT_ID_2', OPT_EXT_ID_2, account, CLIENT_ID_1, ACCEPTED);
        
        /* When */ Map<String,ID> ids = insertCommunicationOpts(comOpts);
        Account acc = readAccount(account);
        /* Then */ checkAccountComOpts(acc, '001');
        /* Then */ checkAccountComOpts(acc, '002');
    }

    static testMethod void testAccountCommunicationOptPrefixesTC_04() {
        /* Two elemented set is not changed */
        /* Given */
        String OPT_EXT_ID_1 = 'OPT_1';
        String OPT_EXT_ID_2 = 'OPT_2';
        String CLIENT_ID_1 = 'CLIENT_ID_1';
        
        ID account = insertAccount('Test_Account');

        ID opt1 = insertOpt(OPT_EXT_ID_1);
        ID opt2 = insertOpt(OPT_EXT_ID_2);
        
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID_1);

        CommunicationOpt__c[] comOpts = new CommunicationOpt__c[3];
        comOpts[0] = communicationOpt('COPT_EXT_ID_1', OPT_EXT_ID_1, account, CLIENT_ID_1, ACCEPTED);
        comOpts[1] = communicationOpt('COPT_EXT_ID_2', OPT_EXT_ID_2, account, CLIENT_ID_1, ACCEPTED);
        comOpts[2] = communicationOpt('COPT_EXT_ID_2', OPT_EXT_ID_2, account, CLIENT_ID_1, ACCEPTED);
        
        /* When */ Map<String,ID> ids = insertCommunicationOpts(comOpts);
        Account acc = readAccount(account);
        /* Then */ checkAccountComOpts(acc, '001');
        /* Then */ checkAccountComOpts(acc, '002');
    }

    static testMethod void testAccountCommunicationOptPrefixesTC_05() {
        /* Three elemented set is created */
        /* Given */
        String OPT_EXT_ID_1 = 'OPT_1';
        String OPT_EXT_ID_2 = 'OPT_2';
        String OPT_EXT_ID_3 = 'OPT_3';
        String CLIENT_ID_1 = 'CLIENT_ID_1';
        
        ID account = insertAccount('Test_Account');

        ID opt1 = insertOpt(OPT_EXT_ID_1);
        ID opt2 = insertOpt(OPT_EXT_ID_2);
        ID opt3 = insertOpt(OPT_EXT_ID_3);
        
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID_1);

        CommunicationOpt__c[] comOpts = new CommunicationOpt__c[3];
        comOpts[0] = communicationOpt('COPT_EXT_ID_1', OPT_EXT_ID_1, account, CLIENT_ID_1, ACCEPTED);
        comOpts[1] = communicationOpt('COPT_EXT_ID_2', OPT_EXT_ID_2, account, CLIENT_ID_1, ACCEPTED);
        comOpts[2] = communicationOpt('COPT_EXT_ID_3', OPT_EXT_ID_3, account, CLIENT_ID_1, ACCEPTED);
        
        /* When */ Map<String,ID> ids = insertCommunicationOpts(comOpts);
        Account acc = readAccount(account);
        /* Then */ checkAccountComOpts(acc, '001');
        /* Then */ checkAccountComOpts(acc, '002');
        /* Then */ checkAccountComOpts(acc, '003');
    }

    static testMethod void testAccountCommunicationOptPrefixesTC_06() {
        /* Empty set does not changes */
        /* Given */
        String OPT_EXT_ID_1 = 'OPT_1';
        String CLIENT_ID_1 = 'CLIENT_ID_1';
        
        ID account = insertAccount('Test_Account');

        ID opt1 = insertOpt(OPT_EXT_ID_1);
        
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID_1);

        CommunicationOpt__c[] comOpts = new CommunicationOpt__c[1];
        comOpts[0] = communicationOpt('COPT_EXT_ID_1', OPT_EXT_ID_1, account, CLIENT_ID_1, REJECTED);
        
        /* When */ Map<String,ID> ids = insertCommunicationOpts(comOpts);
        Account acc = readAccount(account);
        /* Then */ checkAccountComOptsEmptiness(acc);
    }

    static testMethod void testAccountCommunicationOptPrefixesTC_07() {
        /* One element set is deleted */
        /* Given */
        String OPT_EXT_ID_1 = 'OPT_1';
        String CLIENT_ID_1 = 'CLIENT_ID_1';
        
        ID account = insertAccount('Test_Account');

        ID opt1 = insertOpt(OPT_EXT_ID_1);
        
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID_1);

        CommunicationOpt__c[] comOpts = new CommunicationOpt__c[1];
        comOpts[0] = communicationOpt('COPT_EXT_ID_1', OPT_EXT_ID_1, account, CLIENT_ID_1, ACCEPTED);
        /* When */ Map<String,ID> ids = insertCommunicationOpts(comOpts);
        Account acc = readAccount(account);
        /* Then */ checkAccountComOpts(acc, '001');
        
        CommunicationOpt__c[] comOptsAfter = new CommunicationOpt__c[1];
        comOptsAfter[0] = communicationOpt('COPT_EXT_ID_2', OPT_EXT_ID_1, account, CLIENT_ID_1, REJECTED);
        
        /* When */ insertCommunicationOpts(comOptsAfter);
        acc = readAccount(account);
        /* Then */ checkAccountComOptsEmptiness(acc);
    }

    static testMethod void testAccountCommunicationOptPrefixesTC_08() {
        /* Given */
        String OPT_EXT_ID_1 = 'OPT_1';
        String OPT_EXT_ID_2 = 'OPT_2';
        String CLIENT_ID_1 = 'CLIENT_ID_1';
        
        ID account = insertAccount('Test_Account');

        ID opt1 = insertOpt(OPT_EXT_ID_1);
        ID opt2 = insertOpt(OPT_EXT_ID_2);
        
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID_1);

        CommunicationOpt__c[] comOpts = new CommunicationOpt__c[1];
        comOpts[0] = communicationOpt('COPT_EXT_ID_1', OPT_EXT_ID_1, account, CLIENT_ID_1, ACCEPTED);
        /* When */ Map<String,ID> ids = insertCommunicationOpts(comOpts);
        Account acc = readAccount(account);
        /* Then */ checkAccountComOpts(acc, '001');
        
        CommunicationOpt__c[] comOptsAfter = new CommunicationOpt__c[1];
        comOptsAfter[0] = communicationOpt('COPT_EXT_ID_2', OPT_EXT_ID_2, account, CLIENT_ID_1, REJECTED);
        
        /* When */ insertCommunicationOpts(comOptsAfter);
        acc = readAccount(account);
        /* Then */ checkAccountComOpts(acc, '001');
        /* Then */ checkAccountComOptsAbsent(acc, '002');
    }

    static testMethod void testAccountCommunicationOptPrefixesTC_09() {
        /* Given */
        String OPT_EXT_ID_1 = 'OPT_1';
        String OPT_EXT_ID_2 = 'OPT_2';
        String OPT_EXT_ID_3 = 'OPT_3';
        String CLIENT_ID_1 = 'CLIENT_ID_1';
        
        ID account = insertAccount('Test_Account');

        insertOpt(OPT_EXT_ID_1);
        insertOpt(OPT_EXT_ID_2);
        insertOpt(OPT_EXT_ID_3);
        
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID_1);

        CommunicationOpt__c[] comOpts = new CommunicationOpt__c[3];
        comOpts[0] = communicationOpt('COPT_EXT_ID_1', OPT_EXT_ID_1, account, CLIENT_ID_1, ACCEPTED);
        comOpts[1] = communicationOpt('COPT_EXT_ID_2', OPT_EXT_ID_2, account, CLIENT_ID_1, ACCEPTED);
        comOpts[2] = communicationOpt('COPT_EXT_ID_3', OPT_EXT_ID_3, account, CLIENT_ID_1, ACCEPTED);
        /* When */ Map<String,ID> ids = insertCommunicationOpts(comOpts);
        Account acc = readAccount(account);
        /* Then */ checkAccountComOpts(acc, '001');
        /* Then */ checkAccountComOpts(acc, '002');
        /* Then */ checkAccountComOpts(acc, '003');
        
        CommunicationOpt__c[] comOptsAfter = new CommunicationOpt__c[1];
        comOptsAfter[0] = communicationOpt('COPT_EXT_ID_4', OPT_EXT_ID_2, account, CLIENT_ID_1, REJECTED);
        
        /* When */ insertCommunicationOpts(comOptsAfter);
        acc = readAccount(account);
        /* Then */ checkAccountComOpts(acc, '001');
        /* Then */ checkAccountComOptsAbsent(acc, '002');
        /* Then */ checkAccountComOpts(acc, '003');
    }

    static testMethod void testAccountCommunicationOptPrefixesTC_10() {
        /* Given */
        String OPT_EXT_ID_1 = 'OPT_1';
        String OPT_EXT_ID_2 = 'OPT_2';
        String OPT_EXT_ID_3 = 'OPT_3';
        String CLIENT_ID_1 = 'CLIENT_ID_1';
        
        ID account = insertAccount('Test_Account');

        insertOpt(OPT_EXT_ID_1);
        insertOpt(OPT_EXT_ID_2);
        insertOpt(OPT_EXT_ID_3);
        
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID_1);

        CommunicationOpt__c[] comOpts = new CommunicationOpt__c[2];
        comOpts[0] = communicationOpt('COPT_EXT_ID_1', OPT_EXT_ID_1, account, CLIENT_ID_1, ACCEPTED);
        comOpts[1] = communicationOpt('COPT_EXT_ID_3', OPT_EXT_ID_3, account, CLIENT_ID_1, ACCEPTED);
        /* When */ Map<String,ID> ids = insertCommunicationOpts(comOpts);
        Account acc = readAccount(account);
        /* Then */ checkAccountComOpts(acc, '001');
        /* Then */ checkAccountComOptsAbsent(acc, '002');
        /* Then */ checkAccountComOpts(acc, '003');
        
        CommunicationOpt__c[] comOptsAfter = new CommunicationOpt__c[1];
        comOptsAfter[0] = communicationOpt('COPT_EXT_ID_4', OPT_EXT_ID_2, account, CLIENT_ID_1, REJECTED);
        
        /* When */ insertCommunicationOpts(comOptsAfter);
        acc = readAccount(account);
        /* Then */ checkAccountComOpts(acc, '001');
        /* Then */ checkAccountComOptsAbsent(acc, '002');
        /* Then */ checkAccountComOpts(acc, '003');    
    }
    

    static testMethod void testAccountCommunicationOptPrefixesTC_11() {
        /* Same as 9 but uses upsert */
        /* Given */
        String OPT_EXT_ID_1 = 'OPT_1';
        String OPT_EXT_ID_2 = 'OPT_2';
        String OPT_EXT_ID_3 = 'OPT_3';
        String CLIENT_ID_1 = 'CLIENT_ID_1';
        
        ID account = insertAccount('Test_Account');

        insertOpt(OPT_EXT_ID_1);
        insertOpt(OPT_EXT_ID_2);
        insertOpt(OPT_EXT_ID_3);
        
        ID prop1 = insertPropAndRepr('PROP_1', 'PROP_REP_1', CLIENT_ID_1);

        CommunicationOpt__c[] comOpts = new CommunicationOpt__c[3];
        comOpts[0] = communicationOpt('COPT_EXT_ID_1', OPT_EXT_ID_1, account, CLIENT_ID_1, ACCEPTED);
        comOpts[1] = communicationOpt('COPT_EXT_ID_2', OPT_EXT_ID_2, account, CLIENT_ID_1, ACCEPTED);
        comOpts[2] = communicationOpt('COPT_EXT_ID_3', OPT_EXT_ID_3, account, CLIENT_ID_1, ACCEPTED);
        /* When */ Map<String,ID> ids = insertCommunicationOpts(comOpts);
        Account acc = readAccount(account);
        /* Then */ checkAccountComOpts(acc, '001');
        /* Then */ checkAccountComOpts(acc, '002');
        /* Then */ checkAccountComOpts(acc, '003');
        
        CommunicationOpt__c[] comOptsAfter = new CommunicationOpt__c[1];
        comOptsAfter[0] = communicationOpt('COPT_EXT_ID_4', OPT_EXT_ID_2, account, CLIENT_ID_1, REJECTED);

        /* When */
        comOpts[1].accepted__c = 'false'; // REJECT
        Database.update(comOpts[1], false);
        
        acc = readAccount(account);
        /* Then */ checkAccountComOpts(acc, '001');
        /* Then */ checkAccountComOptsAbsent(acc, '002');
        /* Then */ checkAccountComOpts(acc, '003');    
    }    

    /* The updating of an opt whithout Generated_3Digit_Number__c field
     * https://tcccdiam.atlassian.net/browse/CRM-1547
     * "As a Campaign Manager I want to be able to use individual email results and communication opt information together in a segmentation."
     */
    static testMethod void testUpdate3DigitNumber() {
        /* The numbering of an opt should work for the Before Update trigger
         * This can be tested calling the specific handler method concretely.
         */
        /* Given */
        CRMOptTriggerHandler optHandler = new CRMOptTriggerHandler(true);
        List<Opt__c> opts = new List<Opt__c>();
        opts.add(createOpt('OPT_1'));
        opts.add(createOpt('OPT_1'));
    
        /* When */
        /* The implementation only depends on the new opt list, and
         * for testing purposes, this list has be created only.
         */
        optHandler.onBeforeUpdate(null, opts, null, null);
        System.assertEquals(1,opts[0].Generated_3Digit_Number__c, 'The Generated_3Digit_Number__c field on the opt object was not updated correctly.');
        System.assertEquals(2,opts[1].Generated_3Digit_Number__c, 'The Generated_3Digit_Number__c field on the opt object was not updated correctly.');
    }
    
    /* Helper methods */

    private static boolean ACCEPTED = true;
    private static boolean REJECTED = false;
    
    private static void checkContactIdInsert(Id accountId, Id commOptId){
        Account accWithContactId = [SELECT PersonContactId FROM Account WHERE Id = :accountId];
        CommunicationOpt__c commOptWithContactId = [SELECT Contact__c FROM CommunicationOpt__c WHERE Id = :commOptId];
        System.assertEquals(accWithContactId.PersonContactId, commOptWithContactId.Contact__c, 'The Contact Ids do do not match for the communication insert');
    }
    
    static void checkCommunicationOpt(ID comOptID, ID optID) {
        System.assertNotEquals(null, comOptID, 'Communication Opt is not inserted');
        CommunicationOpt__c comOpt = readCommunicationOpt(comOptID);
        System.assertEquals(optID, comOpt.Opt__c, 'The Opt lookup has no propper value');
    }
    
    /* If the insertion is not happened property the given ID should be null */
    static void checkWrongCommunicationOpt(ID comOptID) {
        System.assertEquals(null, comOptID, 'The insertion was successful');
    }
    
    /* Checks if the property representation lookup is filled up with the given id */
    static void checkCommunicationOptPropRep(ID comOptId, ID propRepId) {
        System.assertNotEquals(null, comOptId, 'Commuication Opt is not inserted');
        CommunicationOpt__c comOpt = readCommunicationOpt(comOptId);
        System.assertEquals(propRepId, comOpt.Property_Representation__c, 'The Property Representation lookup ha no propper value');
    }
    
    /* Checks if the given account 3digit set is empty */
    static void checkAccountComOptsEmptiness(Account account) {
        if(account.Com_opts__c != null && account.Com_Opts__c.length() != 0) {
            System.assert(false,
                'The opt is not found on the account: ' + account.ID
                + ' compOpts: ' + account.Com_Opts__c
            );
        }
    }    
    
    /* Checks if the given account contains the given list of Opt 3digit identifiers */
    static void checkAccountComOpts(Account account, String opt3DId) {
        if(!occursOnlyOnce(account.Com_Opts__c, opt3DId)) {
            System.assert(false,
                'The opt is not found on the account: ' + account.ID
                + ' the optID: ' + opt3DId
                + ' compOpts: ' + account.Com_Opts__c
            );
        }
    }

    /* Checks if the given account does not contain the given list of Opt 3digit identifiers */
    static void checkAccountComOptsAbsent(Account account, String opt3DId) {
        if(account.Com_Opts__c.contains(opt3DId)) {
            System.assert(false,
                'The opt is found on the account: ' + account.ID
                + ' the optID: ' + opt3DId
                + ' compOpts: ' + account.Com_Opts__c
            );
        }
    }
   
    /* Checks if the second string is a substring of the first
     * and appears only once. Returns false if the string is not
     * a substring
     */
    static boolean occursOnlyOnce(String whole, String part) {
        if(!whole.contains(part)) {
            return false;
        }
        return (whole.indexOf(part) == whole.lastIndexOf(part));
    }
    
    /* Database methods */
    
    private static Opt__c createOpt(String uniqueName) {
        Opt__c opt = new Opt__c();

        opt.Brand__c = 'Fanta'; // ???
        opt.Opt_Ext_Id__c = uniqueName+'Ext_Id';
        opt.Type__c = 'TCCC'; // ???
        opt.Opt_Unique_Name__c = uniqueName;
        opt.Status__c = 'Active'; // ???
        return opt;
    }
    
    private static ID insertOpt(String uniqueName) {
        Opt__c opt = createOpt(uniqueName);
        insert opt;
        return opt.id;
    }

    private static Opt__c readOpt(ID optId) {
        Opt__c opt = [
            SELECT
                Id,
                Brand__c,
                Opt_Ext_Id__c,
                Type__c,
                Opt_Unique_Name__c,
                Status__c
            FROM
                Opt__c
            WHERE
                Id =: optId
        ];
        return opt;
    }

    /* Database methods */

    private static CommunicationOpt__c communicationOpt(String extId, String optExtId, ID account, String clientId, boolean acceptedopt) {
        CommunicationOpt__c opt = communicationOpt(extId, optExtId, account, clientId);
        if(acceptedopt) {
           opt.accepted__c = 'true';
        } else {
           opt.accepted__c = 'false';
        }
        opt.dateAccepted__c = Datetime.now();
        return opt;
    }
    
    private static CommunicationOpt__c communicationOpt(String extId, String optExtId, ID account, String clientId) {
        CommunicationOpt__c opt = new CommunicationOpt__c();
        opt.accepted__c = null; // ???
        opt.dateAccepted__c = null; // ???
        opt.clientId__c = clientId;
        opt.Account__c = account; // ???
        opt.Opt__c = null; // ???
        opt.pluralId__c = extId;
        opt.format__c = null; // ???
        opt.optId__c = optExtId;
        opt.Property_Representation__c = null; // ???
        opt.schedulePreference__c = null; // ???
        opt.type__c = null; // ???
        return opt;
    }
    
    // Tries to insert a communication opt object, if it fails, the
    // returned external id is null.
    private static ID insertCommunicationOpt(String extId, String optExtId, ID account, String clientId) {
        CommunicationOpt__c opt = communicationOpt(extId, optExtId, account, clientId);
        try {
            insert opt;
            return opt.id;
        } catch (DMLException e) {
            System.Debug(e);
            return null;
        }
    }
    
    private static Map<String, ID> insertCommunicationOpts(List<CommunicationOpt__c> cos) {
        try {
            //Tries to insert each CommunicationOpt__c, if one fails
            //the rest are loaded.
            Database.insert(cos, false);
        } catch (DMLException e) {
            System.Debug(e);
        }
        Map<String, ID> uniqueNames = new Map<String, ID>();
        List<String> optIds = new List<String>();
        for(CommunicationOpt__c co : cos) {
            optIds.add(co.optId__c);
            uniqueNames.put(co.optId__c, null);
        }

        List<CommunicationOpt__c> inserteds = [SELECT Id, OptId__c FROM CommunicationOpt__c WHERE OptId__c IN :optIds];
        System.Debug('Inserted ComOpts: ' + inserteds);
        for(CommunicationOpt__c i : inserteds) {
            uniqueNames.put(i.optId__c, i.Id);
        }
        return uniqueNames;
    }
    
    private static Map<String, ID> upsertCommunicationOpts(List<CommunicationOpt__c> cos) {
        try {
            //Tries to upsert each CommunicationOpt__c, if one fails
            //the rest are loaded.
            Database.upsert(cos, null, false);
        } catch (DMLException e) {
            System.Debug(e);
        }
        Map<String, ID> uniqueNames = new Map<String, ID>();
        List<String> optIds = new List<String>();
        for(CommunicationOpt__c co : cos) {
            optIds.add(co.optId__c);
            uniqueNames.put(co.optId__c, null);
        }

        List<CommunicationOpt__c> inserteds = [SELECT Id, OptId__c FROM CommunicationOpt__c WHERE OptId__c IN :optIds];
        System.Debug('Inserted ComOpts: ' + inserteds);
        for(CommunicationOpt__c i : inserteds) {
            uniqueNames.put(i.optId__c, i.Id);
        }
        return uniqueNames;
    }    

    private static CommunicationOpt__c readCommunicationOpt(ID optId) {
        CommunicationOpt__c opt = [
            SELECT
                Id,
                accepted__c,
                dateAccepted__c,
                clientId__c,
                Account__c,
                Opt__c,
                pluralId__c,
                format__c,
                optId__c,
                Property_Representation__c,
                schedulePreference__c,
                type__c
            FROM
                CommunicationOpt__c
            WHERE
                Id =: optId
        ];
        return opt;
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

    /* Read the CRM realated account from the database for the given ID
     */
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
                Com_Opts__c
            FROM
                Account
            WHERE
                Id =: accountID
        ];
        return account;
    }    
    
    private static ID insertPropAndRepr(String propertyExtId, String propRepExtId, String clientID) {
        ID p = insertProperty(propertyExtId, propertyExtId);
        ID pr = insertPropertyRepresentation(p, propRepExtId, clientId, propRepExtId);
        return pr;
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
 
}