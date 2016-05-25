@isTest
private class ECICCaseTriggerAcctAndCntCacheHlpTests {

/* FIXME: This method uses old, dubious, fragile test helpers and is now incompatible with the target class */
 static testMethod void CICContactSubChannelCloneTest() {
        ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
        TEST_DummyCaseTrigStrategyConfigFactory.create(TEST_DummyInsertModeEnum.REAL);
        List<Account> accounts  = [SELECT Id, Sub_Channel__pc FROM Account];
        system.debug('ppp'+accounts);
        
        Contact testCICContact = null;
        //#Ecic Template Test
        System.runAs(ECICRunUserTestHelper.create('ECIC_Administrator', ECICCommonConstants.PROFILE_ECIC_ADMINISTRATOR, ECICCommonConstants.ROLE_COCA_COLA_EUROPE, 'ES')) {
            testCICContact = createContact(accounts[0].Id, null);
           System.assertEquals('ECIC_Administrator', testCICContact.Owner.Profile.Name);
        }
        
        ECICCaseTriggerAccountAndContactCache.emailAndWebContactList = new List<Contact>{testCICContact};
        System.assertEquals(1, ECICCaseTriggerAccountAndContactCache.emailAndWebContactList.size());
        
        Test.startTest();
        
        Case webTestCase    = prepareTestCase(false, 'Web', null, 'Subject1');        
        List<Case> caseList = new List<Case>{ webTestCase};
        
        List<Contact> allContacts   = [SELECT Id, Sub_Channel__c FROM Contact];
        System.assertEquals(1, allContacts.size());
         
         
        ECICCaseTriggerAccountAndContactCache.populate(caseList);
        
        System.assertEquals(1, ECICCaseTriggerAccountAndContactCache.getEmailAndWebCaseIdentStringMap().size());
        System.assertEquals(1, ECICCaseTriggerAccountAndContactCache.emailAndWebContactList.size());
        //System.assertEquals(1, ECICCaseTriggerAccountAndContactCache.casesWithExistingContacts.size()); 
        System.assertEquals(1, ECICCaseTriggerAccountAndContactCache.casesWithoutExistingContacts.size());
        
        allContacts    = [SELECT Id, RecordTypeId, Email, Phone, MobilePhone, Sub_Channel__c, HomePhone, OtherPhone, Owner.Profile.Name, Account.IsPersonAccount FROM Contact]; 
   		System.assertEquals(webTestCase.Sub_Channel__c,allContacts[1].Sub_Channel__c);
        for(Contact contact : allContacts)
   		{
   			System.debug('Contact.Sub_Channel__c: ' + contact.Sub_Channel__c);
   			System.debug('Contact.Account.IsPersonAccount: ' + contact.Account.IsPersonAccount);
   		}
        
        
        Test.stopTest();
    }

/*
 static testMethod void nonCICPersonAccountSubChannelCloneTest() {
        ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
        TEST_DummyCaseTrigStrategyConfigFactory.create(TEST_DummyInsertModeEnum.REAL);
        User testSTMUser        = getSTMUser();
        List<Contact> contacts  = [SELECT Id FROM Contact];
        List<Account> accounts  = [SELECT Id FROM Account];
        System.assertEquals(0, contacts.size());
        System.assertEquals(2, accounts.size()); 
        
        System.runAs(testSTMUser) {
            contacts    = [SELECT Id, RecordTypeId, Email, Phone, Sub_Channel__c, MobilePhone, HomePhone, OtherPhone, Owner.Profile.Name, Account.IsPersonAccount FROM Contact];
            accounts    = [SELECT Id, Sub_Channel__pc FROM Account];
            //System.assertEquals(ECICCommonConstants.EMAIL,  contacts[0].Email                   );
            //System.assertEquals(ECICCommonConstants.PHONE,  contacts[0].phone                   );
            //System.assertEquals(true,                       contacts[0].Account.IsPersonAccount);
            
            System.assertEquals(1, contacts.size());
            System.debug('First Contact Id: ' + contacts[0].Id);
            System.assertEquals(3, accounts.size());
            System.assertEquals('STMG_Database Administrator', contacts[0].Owner.Profile.Name);
        }
        
        ECICCaseTriggerAccountAndContactCache.emailAndWebContactList = contacts;
        System.assertEquals(1, ECICCaseTriggerAccountAndContactCache.emailAndWebContactList.size());
        
        Test.startTest();
        
          
    	Case webTestCase    = prepareTestCaseWithSubChannel(false, 'Web', null, 'Subject1', 'other');
        Case emailTestCase  = prepareTestCaseWithSubChannel(false, 'Email', ECICCommonConstants.EMAIL,'Subject2' ,'other');
        List<Case> caseList = new List<Case>{ webTestCase, emailTestCase };
      
        
        ECICCaseTriggerAccountAndContactCache.populate(caseList);
        
        System.assertEquals(2, ECICCaseTriggerAccountAndContactCache.getEmailAndWebCaseIdentStringMap().size());
        System.assertEquals(1, ECICCaseTriggerAccountAndContactCache.emailAndWebContactList.size());
        System.assertEquals(1, ECICCaseTriggerAccountAndContactCache.casesWithExistingContacts.size()); 
        System.assertEquals(1, ECICCaseTriggerAccountAndContactCache.casesWithoutExistingContacts.size());
        
     	
    contacts    = [SELECT Id, RecordTypeId, Email, Phone, MobilePhone, Sub_Channel__c, HomePhone, OtherPhone, Owner.Profile.Name, Account.IsPersonAccount FROM Contact]; 
   	System.assertEquals(webTestCase.Sub_Channel__c,contacts[1].Sub_Channel__c);
   	for(Contact contact : contacts)
   	{
   		System.debug('Contact.Account.IsPersonAccount: ' + contact.Account.IsPersonAccount);
   	}
		         
        Test.stopTest();
    }
     */
 
private static Case prepareTestCaseWithSubChannel(Boolean isInsert, String origin, String email, String subject, string SubChannel) {
        ECICCaseTestHelper.CaseConfig caseConfig = new ECICCaseTestHelper.CaseConfig();
                                      caseConfig.plantId          = ECICTestHelper.plant.Id;
                                      caseConfig.productionLineId = ECICTestHelper.productionLine.Id;
                                      caseConfig.productId        = ECICTestHelper.product.Id;
                                      caseConfig.productionCode   = ECICCommonConstants.TEST_PRODUCTION_LINE_NAME;
                                      caseConfig.status           = ECICCommonConstants.STATUS_OPEN;
                                      caseConfig.origin           = origin;
                                      caseConfig.suppliedEmail    = email;
                                      caseConfig.subject          = subject;
                                      
        
        Case dummyCase = ECICCaseTestHelper.createDummyCase(caseConfig, isInsert);
        dummyCase.Sub_Channel__c = SubChannel;
        return dummyCase;
    }
    
    private static Contact createContact(Id accId, User usr) {
        Contact testContact = new Contact(  firstname      = ECICCommonConstants.CONTACT_FIRSTNAME,
                                            lastname       = ECICCommonConstants.CONTACT_LASTNAME,
                                            email          = ECICCommonConstants.EMAIL,
                                            phone          = ECICCommonConstants.PHONE,
                                            accountId      = accId,
                                            MailingCity    = ECICCommonConstants.TEST_CITY_STATE_AND_REGION,
                                            MailingCountry = ECICCommonConstants.TEST_COUNTRY);
        if (usr != null) {testContact.OwnerId = usr.Id;}
        insert testContact;
        testContact = [SELECT Id, FirstName, LastName, Email, Phone, MobilePhone, HomePhone, OtherPhone, 
                        AccountId, Account.IsPersonAccount, Owner.Profile.Name 
                                FROM Contact 
                                WHERE firstname =: ECICCommonConstants.CONTACT_FIRSTNAME][0];
        return testContact;
    }
    
    private static User getSTMUser() {
        return [SELECT Id,FirstName,LastName,Name,ProfileId,Profile.Name FROM User WHERE Profile.Name = 'STMG_Database Administrator'];
    }

 private static Case prepareTestCase(Boolean isInsert, String origin, String email, String subject) {
        ECICCaseTestHelper.CaseConfig caseConfig = new ECICCaseTestHelper.CaseConfig();
                                      caseConfig.plantId          = ECICTestHelper.plant.Id;
                                      caseConfig.productionLineId = ECICTestHelper.productionLine.Id;
                                      caseConfig.productId        = ECICTestHelper.product.Id;
                                      caseConfig.productionCode   = ECICCommonConstants.TEST_PRODUCTION_LINE_NAME;
                                      caseConfig.status           = ECICCommonConstants.STATUS_OPEN;
                                      caseConfig.origin           = origin;
                                      caseConfig.suppliedEmail    = email;
                                      caseConfig.subject          = subject;
                                      
        
        Case dummyCase = ECICCaseTestHelper.createDummyCase(caseConfig, isInsert);
        return dummyCase;
    }

}