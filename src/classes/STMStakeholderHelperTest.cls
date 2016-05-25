@isTest
private class STMStakeholderHelperTest {    
    
    static STMIssueScore__c issueScore;
    
    
    /**
  * @author		Pavel Slepenkov (Pavel_Slepenkov@epam.com)
  * @date			25 Feb 2013
  * @description 	prepare test data for tests
  * @param        Boolean isBulk define mode of data preparation
  */
  static void prepareTestData(Boolean isBulk) {
    STMTestHelper.initTestEnvironment(isBulk);
    if (isBulk) {
    } else {
    }
  }
  
//----------------------------------------------------------------------------------------------------------------------
  /**
    * @author       Pavel Slepenkov (Pavel_Slepenkov@epam.com)
    * @date         25 Feb 2013
    * @description  check that all related to account issue scores will be removed
    *               if account will be marked as "Inactive"
    */
  static void removeRelatedIssueScoresFromInactivePersAccount() {
    prepareTestData(true);
    List<Account> personAccounts = STMTestHelper.personAccounts;
        System.assertNotEquals(null,personAccounts);
        for (Account a: personAccounts) {
            System.assertEquals(false, a.STMActive__pc);
        }
        for (Account a: personAccounts) {
            a.STMActive__pc = false;
        }
        update personAccounts;
        Set<Id> persAccIds = (new Map<Id,Account>(personAccounts)).keySet();
        System.assertEquals(0, [SELECT count() FROM STMIssueScore__c WHERE Contact__c IN: persAccIds]);
  }
  
  /**
    * @author       Pavel Slepenkov (Pavel_Slepenkov@epam.com)
    * @date         1 Mar 2013
    * @description  check that all related to contact issue scores will be removed
    *               if contact will be marked as "Inactive"
    */
    static void removeRelatedIssueScoresFromInactiveContact() {
        /* @TODO verify this test
        prepareTestData(true);
        List<Contact> contacts = STMTestHelper.contacts;
        System.assertNotEquals(null,contacts);
        for (Contact c: contacts) {
            System.assertEquals(true, c.STMActive__c);
        }
        for (Contact c: contacts) {
            c.STMActive__c = false;
        }
        update contacts;
        Set<Id> contactsIds = (new Map<Id, Contact>(contacts)).keySet();
        System.assertEquals(0, [SELECT count() FROM STMIssueScore__c WHERE Contact__c IN: contactsIds]);
        */
    }
  
//----------------------------------------------------------------------------------------------------------------------

	/**
	* @author       Roshan Sahatiya (roshan.sahatiya@capgemini.com)
    * @date         9 Jn 2015
    * @description  This method is no more relevant since STM users cannot create Person Accounts 	
		
  static testMethod void verifyRemoveRelatedIssueScoresFromInactivePersAccount_asRegUser() {
        System.runAs(STMTestHelper.createTestUser( STMTestHelper.generateUniqueEmail('stmRegUser'), 
                                    STMCommonConstants.PROFILE_STMG_REGULAR_USERS_PAC_TEAM,
                                    STMCommonConstants.ROLE_STMG_BEL_USER,
                                    STMCommonConstants.COUNTRY_CODE_BG)) {
            removeRelatedIssueScoresFromInactivePersAccount();
        }
  }
     */
    /*
    * @author       Roshan Sahatiya (roshan.sahatiya@capgemini.com)
    * @date         9 Jn 2015
    * @description  This method is no more relevant since STM users cannot create Person Accounts
    static testMethod void verifyRemoveRelatedIssueScoresFromInactivePersAccount_DBAdm() {
        System.runAs(STMTestHelper.createTestUser( STMTestHelper.generateUniqueEmail('dbAdmin'), 
                                    STMCommonConstants.PROFILE_STMG_DATABASE_ADMINISTRATOR,
                                    STMCommonConstants.ROLE_STMG_BEL_USER,
                                    STMCommonConstants.COUNTRY_CODE_BG)) {
            removeRelatedIssueScoresFromInactivePersAccount();
        }
    }
    */

//----------------------------------------------------------------------------------------------------------------------

    static testMethod void verifyRemoveRelatedIssueScoresFromInactiveContact_asRegUser() {
        System.runAs(STMTestHelper.createTestUser( STMTestHelper.generateUniqueEmail('stmRegUser'), 
                                                    STMCommonConstants.PROFILE_STMG_REGULAR_USERS_PAC_TEAM,
                                                    STMCommonConstants.ROLE_STMG_BEL_USER,
                                                    STMCommonConstants.COUNTRY_CODE_BG)) {
            removeRelatedIssueScoresFromInactiveContact();
        }
    }
       
    static testMethod void verifyRemoveRelatedIssueScoresFromInactiveContact_DBAdm() {
      System.runAs(STMTestHelper.createTestUser( STMTestHelper.generateUniqueEmail('dbAdmin'), 
                                                    STMCommonConstants.PROFILE_STMG_DATABASE_ADMINISTRATOR,
                                                    STMCommonConstants.ROLE_STMG_BEL_USER,
                                                    STMCommonConstants.COUNTRY_CODE_BG)) {
            removeRelatedIssueScoresFromInactiveContact();
        }
    }

//----------------------------------------------------------------------------------------------------------------------
    static testMethod void verifyInsertIssueScoresBulk() {      
        STMTestHelper.initTestEnvironment(true);
        STMIssue__c issue = STMTestHelper.getIssue();
        STMStakeholderHelper.insertIssueScores(STMTestHelper.contacts, (String)issue.id);
    }
    
    static testMethod void verifyInsertIssueScoresSingle() {      
        STMTestHelper.initTestEnvironment(false);
        STMIssue__c issue = STMTestHelper.getIssue();
        STMStakeholderHelper.insertIssueScores(new Contact[]{STMTestHelper.contact}, (String)issue.id);
    }
    
    static testMethod void verifyScoreNormalizerDots() {
        String testStringDots      = '99.99.99';
        String expectedResultDots  = '999999';
        String actualresultDots;
        
        actualresultDots = STMStakeholderHelper.scoreNormalizer(testStringDots);
        System.assertEquals( expectedResultDots, actualresultDots );
    }
    
    static testMethod void verifyScoreNormalizerSpaces() {
        String testStringSpaces      = '99   9 9     9   9';
        String expectedResultSpaces  = '999999';
        String actualresultSpaces;
        
        actualresultSpaces = STMStakeholderHelper.scoreNormalizer(testStringSpaces);
        System.assertEquals( expectedResultSpaces, actualresultSpaces );
    }
    
    static testMethod void verifyScoreNormalizerZeros() {
        String testStringZeros      = '9000990090099';
        String expectedResultZeros  = '999999';
        String actualresultZeros;
        
        actualresultZeros = STMStakeholderHelper.scoreNormalizer(testStringZeros);
        System.assertEquals( expectedResultZeros, actualresultZeros );
    }
    
    
    static testMethod void verifyScoreNormalizer() {
        String testString      = '99000..0900090.00.. 00... 00...90009';
        String expectedResult  = '999999';
        String actualresult;

        actualresult = STMStakeholderHelper.scoreNormalizer(testString);
        System.assertEquals( expectedResult, actualresult );
    }
}