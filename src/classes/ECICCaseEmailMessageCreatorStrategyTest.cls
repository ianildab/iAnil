@isTest
private class ECICCaseEmailMessageCreatorStrategyTest 
{
	private static final User TEST_RUN_USER = ECICRunUserTestHelper.create();
	
	private static final ECICCaseEmailMessageCreatorStrategy DUMMY_STRATEGY = new ECICCaseEmailMessageCreatorStrategy(); 

	private static void filterWebCasesTest(Boolean isWebCase, Boolean hasContactId) 				
	{ 
		Contact dummyContact = (hasContactId) ? TEST_DummyContactFactory.create(TEST_DummyInsertModeEnum.MOCK) : null;
		
		TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
							 config.origin    = (isWebCase) 		   ? 'Web' 			 : 'Phone';
							 config.contactId = (dummyContact != null) ? dummyContact.id : TEST_ConfigHelper.INTENTIONAL_NULL; 
		Case	   dummyCase	 = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.MOCK);
		List<Case> dummyCaseList = new List<Case>{ dummyCase };
		
		ECICCaseEmailMessageCreatorStrategy.WebCaseData resultWebCaseData= null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				resultWebCaseData = DUMMY_STRATEGY.filterWebCases(dummyCaseList);
			}
			Test.stopTest();
		}
		
		if (isWebCase && hasContactId)
		{
			System.assert(resultWebCaseData.webCaseByIdMap.containsKey(dummyCase.id));
			System.assertEquals(dummyCase, resultWebCaseData.webCaseByIdMap.get(dummyCase.id));
			System.assert(resultWebCaseData.webCaseContactIdSet.contains(dummyContact.id)); 
		}
		else // if (!(isWebCase && hasContactId))
		{
			System.assert(!resultWebCaseData.webCaseByIdMap.containsKey(dummyCase.id));
			if (hasContactId) { System.assert(!resultWebCaseData.webCaseContactIdSet.contains(dummyContact.id)); }
		}
	}

	private static testMethod void isNothingFilterWebCasesTest()  { filterWebCasesTest ( false, false ); }
	private static testMethod void hasContactFilterWebCasesTest() { filterWebCasesTest ( false, true  ); }
	private static testMethod void isWebCaseFilterWebCasesTest()  { filterWebCasesTest ( true,  false ); }
	private static testMethod void isBothFilterWebCasesTest()     { filterWebCasesTest ( true,  true  ); }
	
	// ---------------------------------------------------------------------------------------------------------------
	
	private static void hasEmailByCaseIdAndSubjectTest(Boolean hasCaseAsParent, Boolean hasSubject) 				
	{ 
		ID 		dummyCaseId  = '50011000001FTZs'; 
		String	dummySubject = 'Target Subject';
		createEmailMessage(dummyCaseId, dummySubject, hasCaseAsParent, hasSubject);
		
		Boolean result = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				result = DUMMY_STRATEGY.hasEmailByCaseIdAndSubject(dummyCaseId, dummySubject); 
			}
			Test.stopTest();
		} 
		
		System.assertEquals(hasCaseAsParent && hasSubject, result);
	}
	
	private static testMethod void hasNothingHasEmailByCaseIdAndSubjectTest()  		{ hasEmailByCaseIdAndSubjectTest ( false, false ); }
	private static testMethod void hasSubjectHasEmailByCaseIdAndSubjectTest() 		{ hasEmailByCaseIdAndSubjectTest ( false, true  ); }
	private static testMethod void hasCaseAsParentHasEmailByCaseIdAndSubjectTest()  { hasEmailByCaseIdAndSubjectTest ( true,  false ); }
	private static testMethod void hasBothHasEmailByCaseIdAndSubjectTest()     		{ hasEmailByCaseIdAndSubjectTest ( true,  true  ); }

	// ---------------------------------------------------------------------------------------------------------------

	private static void createEmailMessageForWebCaseTest(Boolean hasCaseAsParent, Boolean hasSubject, Boolean hasContact, Boolean contactInCache)				
	{ 
		DUMMY_STRATEGY.webCaseContactByIdMap = new Map<Id, Contact>();
		Contact dummyContact = (hasContact) ? TEST_DummyContactFactory.create(TEST_DummyInsertModeEnum.MOCK) : null;
		if (hasContact && contactInCache) { DUMMY_STRATEGY.webCaseContactByIdMap.put(dummyContact.id, dummyContact); }
		
		TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
							 config.contactId = (dummyContact != null) ? dummyContact.id : TEST_ConfigHelper.INTENTIONAL_NULL; 
							 config.subject = 'Target Subject';
		Case	   dummyCase	 = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.MOCK);

		createEmailMessage(dummyCase.id, config.subject, hasCaseAsParent, hasSubject);


		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				DUMMY_STRATEGY.createEmailMessageForWebCase(dummyCase);
			}
			Test.stopTest();
		} 
		
		List<EmailMessage> resultEmailMessagesToInsertList = ECICCaseTriggerEmailMessageCache.emailMessagesToInsertCache;
		
		Boolean expectEmail = (!hasCaseAsParent || !hasSubject) && (hasContact && contactInCache);
		System.assertEquals (expectEmail ? 1 : 0, resultEmailMessagesToInsertList.size());
		if (expectEmail) { assertEmailMessage (dummyCase, dummyContact, resultEmailMessagesToInsertList[0]); }
	}

	private static testMethod void hasNothingCreateEmailMessageForWebCaseTest() 	   	  		 	{ createEmailMessageForWebCaseTest ( false, false, false, false ); }
	private static testMethod void hasContactCreateEmailMessageForWebCaseTest() 	   	  		 	{ createEmailMessageForWebCaseTest ( false, false, true,  false ); }
	private static testMethod void hasContactInCacheCreateEmailMessageForWebCaseTest() 	  		 	{ createEmailMessageForWebCaseTest ( false, false, true,  true  ); }
	
	private static testMethod void hasSubjectCreateEmailMessageForWebCaseTest() 	   	  		 	{ createEmailMessageForWebCaseTest ( false, true,  false, false ); }
	private static testMethod void hasSubjectAndContactCreateEmailMessageForWebCaseTest() 		 	{ createEmailMessageForWebCaseTest ( false, true,  true,  false ); }
	private static testMethod void hasSubjectAndContactInCacheCreateEmailMessageForWebCaseTest() 	{ createEmailMessageForWebCaseTest ( false, true,  true,  true  ); }

	private static testMethod void isParentCreateEmailMessageForWebCaseTest() 					 	{ createEmailMessageForWebCaseTest ( true,  false, false, false ); }
	private static testMethod void isParentWithContactCreateEmailMessageForWebCaseTest() 		 	{ createEmailMessageForWebCaseTest ( true,  false, true,  false ); }
	private static testMethod void isParentWithContactInCacheCreateEmailMessageForWebCaseTest()  	{ createEmailMessageForWebCaseTest ( true,  false, true,  true  ); }
	
	private static testMethod void matchedEmailCreateEmailMessageForWebCaseTest() 					{ createEmailMessageForWebCaseTest ( true,  true,  false, false ); }
	private static testMethod void matchedEmailWithContactCreateEmailMessageForWebCaseTest() 		{ createEmailMessageForWebCaseTest ( true,  true,  true,  false ); }
	private static testMethod void matchedEmailWithContactInCacheCreateEmailMessageForWebCaseTest() { createEmailMessageForWebCaseTest ( true,  true,  true,  true  ); }
	
	// ---------------------------------------------------------------------------------------------------------------

	private static void createEmailMessagesForWebCasesTest(Boolean isWebCase)				
	{ 
		Contact dummyContact = TEST_DummyContactFactory.create(TEST_DummyInsertModeEnum.MOCK);
		ECICCaseTriggerContactCache.webCaseContactByIdCache.put(dummyContact.id, dummyContact);
		
		TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
							 config.contactId = dummyContact.id;
							 config.origin    = (isWebCase) ? 'Web' : 'Phone'; 
		Case dummyCase = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.MOCK);

		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				DUMMY_STRATEGY.createEmailMessagesForWebCases(new List<Case>{ dummyCase });
			}
			Test.stopTest();
		} 
		
		List<EmailMessage> resultEmailMessagesToInsertList = ECICCaseTriggerEmailMessageCache.emailMessagesToInsertCache;
		
		System.assertEquals (isWebCase ? 1 : 0, resultEmailMessagesToInsertList.size());
		if (isWebCase) { assertEmailMessage (dummyCase, dummyContact, resultEmailMessagesToInsertList[0]); }
	}
	

	private static testMethod void phoneCaseCreateEmailMessagesForWebCasesTest() { createEmailMessagesForWebCasesTest(false); }			
	private static testMethod void webCaseCreateEmailMessagesForWebCasesTest()   { createEmailMessagesForWebCasesTest(true);  }			
	
	// ---------------------------------------------------------------------------------------------------------------
	
	private static testMethod void onAfterInsertTest()				
	{ 
		Contact dummyContact = TEST_DummyContactFactory.create(TEST_DummyInsertModeEnum.MOCK);
		ECICCaseTriggerContactCache.webCaseContactByIdCache.put(dummyContact.id, dummyContact);
		
		TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
							 config.contactId = dummyContact.id;
							 config.origin    = 'Web'; 
		Case dummyCase = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.MOCK);

		Boolean result = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				result = DUMMY_STRATEGY.onAfterInsert(new Map<Id, Case>{ dummycase.id => dummyCase });
			}
			Test.stopTest();
		} 
		
		System.assert(result);
		List<EmailMessage> resultEmailMessagesToInsertList = ECICCaseTriggerEmailMessageCache.emailMessagesToInsertCache;
		
		System.assertEquals (1, resultEmailMessagesToInsertList.size());
		assertEmailMessage (dummyCase, dummyContact, resultEmailMessagesToInsertList[0]); 
	}

	// ---------------------------------------------------------------------------------------------------------------

	private static EmailMessage createEmailMessage(Id dummyCaseId, String dummySubject, Boolean hasCaseAsParent, Boolean hasSubject, Boolean populateEmailList)
	{
		TEST_DummyEmailMessageFactory.Config emailConfig = new TEST_DummyEmailMessageFactory.Config();
											 emailConfig.parentId = (hasCaseAsParent) ? dummyCaseId  : '50011000001FTZz';
											 emailConfig.subject  = (hasSubject)	  ? dummySubject : 'Other Subject';
		EmailMessage   dummyEmailMessage = TEST_DummyEmailMessageFactory.create(emailConfig, false);

		if (populateEmailList) { DUMMY_STRATEGY.existingEmailMessages = new List<EmailMessage> { dummyEmailMessage }; }	

		return dummyEmailMessage;
	}

	private static EmailMessage createEmailMessage(Id dummyCaseId, String dummySubject, Boolean hasCaseAsParent, Boolean hasSubject)
	{
		return createEmailMessage(dummyCaseId, dummySubject, hasCaseAsParent, hasSubject, true);
	}
	
	// ---------------------------------------------------------------------------------------------------------------

	private static void assertEmailMessage (Case dummyCase, Contact dummyContact, EmailMessage resultEmail)
	{
		System.assertEquals( true, 		  		 	 resultEmail.incoming	 );
		System.assertEquals( dummyCase.id, 		 	 resultEmail.parentId	 );
		System.assertEquals( dummyContact.email, 	 resultEmail.fromAddress );
		System.assertEquals( dummyCase.subject,  	 resultEmail.subject	 );
		System.assertEquals( dummyCase.description,  resultEmail.textBody	 );
		System.assertEquals( '0',  		 			 resultEmail.status 	 );
	}	

	

}