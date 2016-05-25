@isTest
private class ECICCaseTriggerEmailMessageCacheTest {
    private static final User 	TEST_RUN_USER = ECICRunUserTestHelper.create();
    
    private static testMethod void getWebCaseEmailListTest() {
        EmailMessage dummyEmailMessage = TEST_DummyEmailMessageFactory.create(TEST_DummyInsertModeEnum.NONE);
        ECICCaseTriggerEmailMessageCache.webCaseEmailCache.add(dummyEmailMessage);
        
        List<EmailMessage> resultWebCaseEmailList = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                resultWebCaseEmailList = ECICCaseTriggerEmailMessageCache.getWebCaseEmailList();
            }
            Test.stopTest();
        }
        
        System.assert((new Set<EmailMessage>(resultWebCaseEmailList)).contains(dummyEmailMessage));
    }
    
    private static testMethod void addEmailMessagesToInsertListTest() {
        EmailMessage dummyEmailMessage = TEST_DummyEmailMessageFactory.create(TEST_DummyInsertModeEnum.NONE);
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                ECICCaseTriggerEmailMessageCache.addEmailMessagesToInsertList(new List<EmailMessage>{dummyEmailMessage});
            }
            Test.stopTest();
        }
        
        System.assert((new Set<EmailMessage>(ECICCaseTriggerEmailMessageCache.emailMessagesToInsertCache)).contains(dummyEmailMessage));
    }
    
    private static void addEmailMessageTest(Boolean isAddressListTest) {
        String dummyEmailAddress    = 'from.dummy@example.com';
        String dummySubject         = 'Dummy Subject';
        String dummyBody            = 'Dummy Body';
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                if (isAddressListTest) {
                    ECICCaseTriggerEmailMessageCache.addEmailMessageToSendList(new List<String>{dummyEmailAddress}, dummySubject, dummyBody);
                } else {
                    ECICCaseTriggerEmailMessageCache.addEmailMessageToSendList(dummyEmailAddress, dummySubject, dummyBody);
                }
            }
            Test.stopTest();
        }
        
        Messaging.SingleEmailMessage resultMessage = ECICCaseTriggerEmailMessageCache.emailMessagesToSendCache[0];
        System.assertEquals(dummyEmailAddress,  resultMessage.getToAddresses()[0]);
        System.assertEquals(dummySubject,       resultMessage.getSubject());
        System.assertEquals(dummyBody,          resultMessage.getPlainTextBody());
    }
    
    private static testMethod void addEmailMessageWithOneFromAddressToSendListTest()    { addEmailMessageTest(false); }
    private static testMethod void addEmailMessageWithFromAddressListToSendListTest()   { addEmailMessageTest(true);  }
    
    private static void populateTest(Boolean isWebCase, Boolean hasContactId, Boolean hasEmailMessage) {
        Contact dummyContact = (hasContactId) ? TEST_DummyContactFactory.create(TEST_DummyInsertModeEnum.MOCK) : null;
        
        TEST_DummyCaseConfig    caseConfig              = new TEST_DummyCaseConfig();
                                caseConfig.origin       = (isWebCase)       ? 'Web'             : 'Phone';
                                caseConfig.contactId    = (hasContactId)    ? dummyContact.id   : null;
        Case dummyCase = TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.MOCK);
        
        EmailMessage dummyEmailMessage = null;
        if (hasEmailMessage) {
            TEST_DummyEmailMessageFactory.Config    emailConfig             = new TEST_DummyEmailMessageFactory.Config();
                                                    emailConfig.parentId    = dummyCase.id;
                                                    emailConfig.fromAddress = (hasContactId) ? dummyContact.Email : null;
            dummyEmailMessage = TEST_DummyEmailMessageFactory.create(emailConfig, TEST_DummyInsertModeEnum.MOCK);
            if (isWebCase && hasContactId) { ECICCaseTriggerEmailMessageCache.webCaseEmailCache.add(dummyEmailMessage); }
        }
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                ECICCaseTriggerEmailMessageCache.populate(new List<Case> { dummyCase } );
            }
            Test.stopTest();
        }
        
        List<EmailMessage> resultWebCaseEmailCache = ECICCaseTriggerEmailMessageCache.webCaseEmailCache;
        if (hasEmailMessage) {
            if  (isWebCase && hasContactId) { assertCacheContainsEmail(resultWebCaseEmailCache,    dummyEmailMessage.id); }
            else                            { assertCacheNotContainsEmail(resultWebCaseEmailCache, dummyEmailMessage.id); }
        } else {
            System.assertEquals(0, ECICCaseTriggerEmailMessageCache.webCaseEmailCache.size());
        }
    }
    
    private static void assertCacheContainsEmail (List<EmailMessage> resultWebCaseEmailCache, Id dummyEmailMessageId)
    {
        Map<Id, EmailMessage> emailMessageByIdMap = new Map<Id, EmailMessage>(resultWebCaseEmailCache);
        System.assert(emailMessageByIdMap.containsKey(dummyEmailMessageId));
    }
    
    private static void assertCacheNotContainsEmail (List<EmailMessage> resultWebCaseEmailCache, Id dummyEmailMessageId)
    {
        Map<Id, EmailMessage> emailMessageByIdMap = new Map<Id, EmailMessage>(resultWebCaseEmailCache);
        System.assert(!emailMessageByIdMap.containsKey(dummyEmailMessageId));
    }
    
    private static testMethod void notWebNoIdNoEmailPopulateTest()		{ populateTest (	false,	false,	false	); }
    private static testMethod void notWebWithIdNoEmailPopulateTest()	{ populateTest (	true,	false,	false	); }
    private static testMethod void webNoIdNoEmailPopulateTest()			{ populateTest (	false,	true,	false	); }
    private static testMethod void webWithIdNoEmailPopulateTest()		{ populateTest (	true,	true,	false	); }
    
    private static testMethod void notWebNoIdHasEmailPopulateTest()		{ populateTest (	false,	false,	true	); }
    private static testMethod void notWebWithIdHasEmailPopulateTest()	{ populateTest (	true,	false,	true	); }
    private static testMethod void webNoIdHasEmailPopulateTest()		{ populateTest (	false,	true,	true	); }
    private static testMethod void webWithIdHasEmailPopulateTest()		{ populateTest (	true,	true,	true	); }
    
    private static testMethod void doInsertionsTest() {
        Case dummyCase = TEST_DummyFastQualityComplaintCaseFactry.create(TEST_DummyInsertModeEnum.REAL);
        TEST_DummyEmailMessageFactory.Config    emailConfig = new TEST_DummyEmailMessageFactory.Config();
                                                emailConfig.parentId    = dummyCase.id;
        EmailMessage dummyEmailMessage = TEST_DummyEmailMessageFactory.create(emailConfig, TEST_DummyInsertModeEnum.NONE);
        ECICCaseTriggerEmailMessageCache.emailMessagesToInsertCache.add(dummyEmailMessage);
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                ECICCaseTriggerEmailMessageCache.doInsertions();
            }
            Test.stopTest();
        }
        
        List<EmailMessage> resultEmailList = [SELECT subject FROM EmailMessage WHERE subject = :dummyEmailMessage.subject];
        System.assertEquals (1, resultEmailList.size());
    }
    
    private static testMethod void doSendTest() {
        Integer emailsSentBefore    = Limits.getEmailInvocations();
        Integer emailsSentAfter     = 0;
        
        Messaging.SingleEmailMessage    mail = new Messaging.SingleEmailMessage();
                                        mail.setToAddresses(new List<String>{'from.dummy@example.com'});
                                        mail.setSubject('Dummy Subject');
                                        mail.setPlainTextBody('Dummy Body');
                                        mail.saveAsActivity = false;
        ECICCaseTriggerEmailMessageCache.emailMessagesToSendCache.add(mail);
        
        List<Messaging.SendEmailResult> sendResultList = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                sendResultList = ECICCaseTriggerEmailMessageCache.doSend();
                emailsSentAfter = Limits.getEmailInvocations();
            }
            Test.stopTest();
        }
        
        System.assertEquals(1, sendResultList.size());
        System.assert(sendResultList[0].success);
        System.assertNotEquals(emailsSentBefore, emailsSentAfter,'should have decreased');
    }
}