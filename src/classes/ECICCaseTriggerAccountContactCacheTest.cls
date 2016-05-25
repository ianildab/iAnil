@isTest
private class ECICCaseTriggerAccountContactCacheTest 
{

    private static final User    TEST_RUN_USER  = TEST_DummyUserFactory.createDefaultTestRunUser();

    /**
     *  FIXME: This seems to be a process test
     *  1. Ensure this code is covered by unit tests.
     *  2. Consider whether this process test provides any added value.
     *        a. If so, move it out the trunk into the /processTest directory.
     *        b. If not, drop it.
     **/
	static testMethod void CICContactTest() 
	{
		User dummyOwner = TEST_DummyUserFactory.create(TEST_DummyUserFactory.ES_INFOLINE_AGENT_PARAM, TEST_DummyInsertModeEnum.REAL);
		
		TEST_DummyAccountFactory.Config accountConfig = new TEST_DummyAccountFactory.Config();
		                                accountConfig.isPerson    = false;
		                                accountConfig.ownerUserId = dummyOwner.id;
        Account dummyAccount   = TEST_DummyAccountFactory.create (accountConfig, TEST_DummyInsertModeEnum.REAL);
        
        Contact testCICContact = createContact (dummyAccount.id, dummyOwner.id);                  
        ECICCaseTriggerAccountAndContactCache.emailAndWebContactList = new List<Contact>{testCICContact};
        
        Case dummyEmailTestCase   = prepareTestCase(false, 'Email', ECICCommonConstants.EMAIL, 'Email Test Case');
        Case dummyWebTestCase     = prepareTestCase(false, 'Web',   null,                      'Web Test Case');
        List<Case> caseList = new List<Case>{ dummyEmailTestCase, dummyWebTestCase };
        
        System.runAs(TEST_RUN_USER)
        {
	        Test.startTest();
	        {
		        ECICCaseTriggerAccountAndContactCache.populate(caseList);
	        }
        }
        
        System.assertEquals(2, ECICCaseTriggerAccountAndContactCache.getEmailAndWebCaseIdentStringMap().size());
        System.assertEquals(1, ECICCaseTriggerAccountAndContactCache.emailAndWebContactList.size());
        System.assertEquals(1, ECICCaseTriggerAccountAndContactCache.casesWithExistingContacts.size());
        System.assertEquals(1, ECICCaseTriggerAccountAndContactCache.casesWithoutExistingContacts.size());
    }
        
/** FIXME (or drop): 
    
	This test currently causes the following error:
	
	2.  ECICCaseTriggerAccountContactCacheTest.nonCICContactTest -- System.SObjectException: SObject row was retrieved via SOQL
		without querying the requested field: Account.sf4twitter__Twitter_User_Id__pc
			Stack trace: Class.ECICAccountDao.clone: line 91, column 1
			Class.ECICCaseTriggerAccountAndContactCacheHlp.cloneObjects: line 129, column 1
			Class.ECICCaseTriggerAccountAndContactCacheHlp.createAccountsAndContactsToSObjectsIdMapList: line 103, column 1
			Class.ECICCaseTriggerAccountAndContactCache.assignExistingAccountsAndContacts: line 164, column 1
			Class.ECICCaseTriggerAccountAndContactCache.caseCacheProcessing: line 96, column 1
			Class.ECICCaseTriggerAccountAndContactCache.populateCache: line 208, column 1
			Class.ECICCaseTriggerAccountAndContactCache.populate: line 88, column 1
			Class.ECICCaseTriggerAccountContactCacheTest.nonCICContactTest: line 64, column 1
	
	... However, as:
		a) This is a process test, instead of a proper unit test; and
		b) The target class is in a state of transition and should ultimately be destroyed
		
	... Perhaps this test won't be worth salvaging....
   
	
    static testMethod void nonCICContactTest() {
        ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
        TEST_DummyCaseTrigStrategyConfigFactory.create(TEST_DummyInsertModeEnum.REAL);
        User testSTMUser = getSTMUser();
        
        Account testAcc         = ECICAccountTestHelper.createBusinessAccount();
        System.assertEquals(false, testAcc.IsPersonAccount);
        Contact testSTMContact  = createContact(testAcc.Id, testSTMUser);
        
        List<Contact> contacts = [SELECT Id, Email, Phone, MobilePhone, HomePhone, OtherPhone, Owner.Profile.Name FROM Contact];
        System.assertEquals(1, contacts.size());
        System.assertEquals('STMG_Database Administrator', contacts[0].Owner.Profile.Name);
        
        ECICCaseTriggerAccountAndContactCache.emailAndWebContactList = new List<Contact>{testSTMContact};
        System.assertEquals(1, ECICCaseTriggerAccountAndContactCache.emailAndWebContactList.size());
        
        Test.startTest();
        
        Case webTestCase    = prepareTestCase(false, 'Web', null, 'Subject1');
        Case emailTestCase  = prepareTestCase(false, 'Email', ECICCommonConstants.EMAIL, 'Subject2');
        List<Case> caseList = new List<Case>{ webTestCase, emailTestCase };
        
        List<Contact> allContacts   = [SELECT Id FROM Contact];
        System.assertEquals(1, allContacts.size());
        
        
        ECICCaseTriggerAccountAndContactCache.populate(caseList);
        
        System.assertEquals(2, ECICCaseTriggerAccountAndContactCache.getEmailAndWebCaseIdentStringMap().size());
        System.assertEquals(1, ECICCaseTriggerAccountAndContactCache.emailAndWebContactList.size());
        System.assertEquals(1, ECICCaseTriggerAccountAndContactCache.casesWithExistingContacts.size()); 
        System.assertEquals(1, ECICCaseTriggerAccountAndContactCache.casesWithoutExistingContacts.size());
        
        
        Test.stopTest();
    }
**/
    
/** FIXME (or drop): 

    This test currently causes the following error:

    System.QueryException: List has no rows for assignment to SObject 
    Stack Trace: Class.ECICAccountTestHelper.getPersonAccount: line 79, column 1 Class.ECICCaseTriggerAccountContactCacheTest.nonCICPersonAccountTest: line 108, column 1

    ... However, as:
        a) This is a process test, instead of a proper unit test; and
        b) The target class is in a state of transition and should ultimately be destroyed
        
    ... Perhaps this test won't be worth salvaging....
    
    static testMethod void nonCICPersonAccountTest() {
        ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
        TEST_DummyCaseTrigStrategyConfigFactory.create(TEST_DummyInsertModeEnum.REAL);
        User testSTMUser        = getSTMUser();
        List<Contact> contacts  = [SELECT Id FROM Contact];
        List<Account> accounts  = [SELECT Id FROM Account];
        System.assertEquals(0, contacts.size());
        System.assertEquals(2, accounts.size());
        
        System.runAs(testSTMUser) {
            Account testAcc         = ECICAccountTestHelper.getPersonAccount();
            testAcc.PersonEmail     = ECICCommonConstants.EMAIL;
            testAcc.phone           = ECICCommonConstants.PHONE;
            update testAcc;
            
            contacts    = [SELECT Id, RecordTypeId, Email, Phone, MobilePhone, HomePhone, OtherPhone, Owner.Profile.Name, Account.IsPersonAccount FROM Contact];
            accounts    = [SELECT Id FROM Account];
            System.assertEquals(ECICCommonConstants.EMAIL,  contacts[0].Email                   );
            System.assertEquals(ECICCommonConstants.PHONE,  contacts[0].phone                   );
            System.assertEquals(true,                       contacts[0].Account.IsPersonAccount );
            
            System.assertEquals(1, contacts.size());
            System.assertEquals(3, accounts.size());
            System.assertEquals('STMG_Database Administrator', contacts[0].Owner.Profile.Name);
        }
        
        ECICCaseTriggerAccountAndContactCache.emailAndWebContactList = contacts;
        System.assertEquals(1, ECICCaseTriggerAccountAndContactCache.emailAndWebContactList.size());
        
        Test.startTest();
        
        Case webTestCase    = prepareTestCase(false, 'Web', null, 'Subject1');
        Case emailTestCase  = prepareTestCase(false, 'Email', ECICCommonConstants.EMAIL, 'Subject2');
        List<Case> caseList = new List<Case>{ webTestCase, emailTestCase };
        
        
        ECICCaseTriggerAccountAndContactCache.populate(caseList);
        
        System.assertEquals(2, ECICCaseTriggerAccountAndContactCache.getEmailAndWebCaseIdentStringMap().size());
        System.assertEquals(1, ECICCaseTriggerAccountAndContactCache.emailAndWebContactList.size());
        System.assertEquals(1, ECICCaseTriggerAccountAndContactCache.casesWithExistingContacts.size()); 
        System.assertEquals(1, ECICCaseTriggerAccountAndContactCache.casesWithoutExistingContacts.size());
        
        Test.stopTest();
    }
*/
    
    private static Case prepareTestCase(Boolean isInsert, String origin, String email, String subject) 
    {
    	if (email == null)
    	{
    		TEST_UniqueHelper unique = new TEST_UniqueHelper('Dummy Email');
    		email = unique.uniqueSpaceless + '@example.com';
    	}
    	
    	TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                                      caseConfig.status           = ECICCommonConstants.STATUS_OPEN;
                                      caseConfig.origin           = origin;
                                      caseConfig.suppliedEmail    = email;
                                      caseConfig.subject          = subject;
        return TEST_DummyInquiryCaseFactory.create(caseConfig, (isInsert) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE); 
    }
    
    private static Contact createContact(Id dummyAccountId, Id dummyOwnerUserId) 
    {
        TEST_DummyContactFactory.Config contactConfig = new TEST_DummyContactFactory.Config();
                                        contactConfig.email       = ECICCommonConstants.EMAIL;
                                        contactConfig.accountId   = dummyAccountId;
        if (dummyOwnerUserId != null) { contactConfig.ownerUserId = dummyOwnerUserId;    }
        Contact dummyContact =  TEST_DummyContactFactory.create(contactConfig, TEST_DummyInsertModeEnum.REAL);
        

        // TODO: There should be a SOQL-less way to accurately pass the owner profile name into TEST_MockHelper.
        if (dummyOwnerUserId == null)
        {
        	Contact resultContact = [SELECT ownerId FROM Contact WHERE id = :dummyContact.id ];
        	dummyOwnerUserId = resultContact.ownerId;
        }
        User dummyContactOwner = [SELECT profile.name FROM User WHERE id = :dummyOwnerUserId LIMIT 1];
        TEST_MockHelper.setMockString(dummyContact.id, 'owner.profile.name', dummyContactOwner.profile.name);

        return dummyContact;
    }                          

    private static User getSTMUser() 
    {
        return [SELECT Id,FirstName,LastName,Name,ProfileId,Profile.Name FROM User WHERE Profile.Name = 'STMG_Database Administrator'];
    }
}