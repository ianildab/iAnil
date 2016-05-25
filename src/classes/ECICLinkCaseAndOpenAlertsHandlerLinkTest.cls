@isTest
private class ECICLinkCaseAndOpenAlertsHandlerLinkTest 
{
  	private static final User 	 			TEST_RUN_USER 				 = ECICRunUserTestHelper.create();
  	private static final Map<String,Id>		CASE_RECORD_TYPE_BY_NAME_MAP = SEPRecordTypesCache.GetRecordTypeIdsByDeveloperNameMap(Case.SObjectType); 
	private static final Set<String> 		OPEN_CASE_STATUS_SET 		 = new Set<String>{ECICCommonConstants.STATUS_NEW, ECICCommonConstants.STATUS_OPEN}; 
	
	private static void linkCasesAndOpenAlerts1Test(String caseStatus, Boolean isCaseInIdSet, Boolean hasCondition) 			
	{
   		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
   		 
   		ECICCaseTestHelper.CaseConfig caseConfig = new ECICCaseTestHelper.CaseConfig(caseStatus);
   									  caseConfig.recordTypeId    = CASE_RECORD_TYPE_BY_NAME_MAP.get ('Inquiry Iberia');
   		if (hasCondition)			{ caseConfig.categoryLevel3  = 'Dummy Value';
                                    }
    						  caseConfig.channelOfAnswer = 'Phone';
        					
   		if (caseStatus == ECICCommonConstants.STATUS_CLOSED)  { caseConfig.infolineStatus = ECICCommonConstants.STATUS_CLOSED; }
		Case 		       dummyCase 		  = ECICCaseTestHelper.createDummyCase(caseConfig, true);
       
		List<Case>         dummyCaseList	  = new List<Case> { dummyCase };
		Set<Id> 		   dummyCaseIdSet	  = new Set<Id> { (isCaseInIdSet) ? dummyCase.id : null };

   		TEST_DummyOpenAlertFactory.Config openAlertConfig = new TEST_DummyOpenAlertFactory.Config();
   		if (hasCondition)				{ openAlertConfig.categoryLevel3  = 'Dummy Value'; }
		Open_Alert__c      dummyOpenAlert	 = TEST_DummyOpenAlertFactory.createDummy(openAlertConfig, true);
		Open_Alert_Case__c dummyOpenAlertCase = TEST_DummyOpenAlertCaseFactory.createDummy(dummyCase, dummyOpenAlert, true);
		 
		System.runAs(TEST_RUN_USER)
		{
			 ECICLinkCaseAndOpenAlertsHandler.linkCasesAndOpenAlerts (dummyCaseList, dummyCaseIdSet);
		}
		
		List<Open_Alert_Case__c> resultOpenAlertCaseList = [SELECT id FROM Open_Alert_Case__c WHERE id = :dummyOpenAlertCase.id]; 

		System.assertEquals (
				(
					(
						   ( (ECICCommonConstants.STATUS_CANCELLED == caseStatus)										 )    
						|| ( (ECICCommonConstants.STATUS_OPEN	   == caseStatus)  && (isCaseInIdSet) && (!hasCondition) )
					)
						? 0
						: 1
				),
				resultOpenAlertCaseList.size()
			);
	}

	private static testMethod void notInSetNewCaseSublistLinkedCasesAndOpenAlerts1Test() 					{ linkCasesAndOpenAlerts1Test (ECICCommonConstants.STATUS_NEW			, false,	false	); 		}
	private static testMethod void inSetNewCaseSublistLinkedCasesAndOpenAlerts1Test()			 			{ linkCasesAndOpenAlerts1Test (ECICCommonConstants.STATUS_NEW			, true,		false	); 		}
	private static testMethod void hasConditionNotInSetNewCaseSublistLinkedCasesAndOpenAlerts1Test() 		{ linkCasesAndOpenAlerts1Test (ECICCommonConstants.STATUS_NEW			, false,	true	); 		}
	private static testMethod void hasConditionInSetNewCaseSublistLinkedCasesAndOpenAlerts1Test() 			{ linkCasesAndOpenAlerts1Test (ECICCommonConstants.STATUS_NEW			, true,		true	); 		}

	private static testMethod void notInSetClosedCaseSublistLinkedCasesAndOpenAlerts1Test()			 		{ linkCasesAndOpenAlerts1Test (ECICCommonConstants.STATUS_CLOSED		, false,	false	); 		}
	private static testMethod void inSetClosedCaseSublistLinkedCasesAndOpenAlerts1Test() 					{ linkCasesAndOpenAlerts1Test (ECICCommonConstants.STATUS_CLOSED		, true,		false	); 		}
	private static testMethod void hasConditionNotInSetClosedCaseSublistLinkedCasesAndOpenAlerts1Test() 	{ linkCasesAndOpenAlerts1Test (ECICCommonConstants.STATUS_CLOSED		, false,	true	); 		}
	private static testMethod void hasConditionInSetClosedCaseSublistLinkedCasesAndOpenAlerts1Test() 		{ linkCasesAndOpenAlerts1Test (ECICCommonConstants.STATUS_CLOSED		, true,		true	); 		}

	private static testMethod void notInSetCancelledCaseSublistLinkedCasesAndOpenAlerts1Test() 				{ linkCasesAndOpenAlerts1Test (ECICCommonConstants.STATUS_CANCELLED		, false,	false	); 		}
	private static testMethod void inSetCancelledCaseSublistLinkedCasesAndOpenAlerts1Test() 				{ linkCasesAndOpenAlerts1Test (ECICCommonConstants.STATUS_CANCELLED		, true,		false	); 		}
	private static testMethod void hasConditionNotInSetCancelledCaseSublistLinkedCasesAndOpenAlerts1Test() 	{ linkCasesAndOpenAlerts1Test (ECICCommonConstants.STATUS_CANCELLED		, false,	true	); 		}
	private static testMethod void hasConditionInSetCancelledCaseSublistLinkedCasesAndOpenAlerts1Test() 	{ linkCasesAndOpenAlerts1Test (ECICCommonConstants.STATUS_CANCELLED		, true,		true	); 		}

	private static testMethod void notInSetOpenCaseSublistLinkedCasesAndOpenAlerts1Test() 					{ linkCasesAndOpenAlerts1Test (ECICCommonConstants.STATUS_OPEN			, false,	false	); 		}
	private static testMethod void inSetOpenCaseSublistLinkedCasesAndOpenAlerts1Test() 						{ linkCasesAndOpenAlerts1Test (ECICCommonConstants.STATUS_OPEN			, true,		false	); 		}
	private static testMethod void hasConditionNotInSetOpenCaseSublistLinkedCasesAndOpenAlerts1Test() 		{ linkCasesAndOpenAlerts1Test (ECICCommonConstants.STATUS_OPEN			, false,	true	); 		}
	//private static testMethod void hasConditionInSetOpenCaseSublistLinkedCasesAndOpenAlerts1Test() 			{ linkCasesAndOpenAlerts1Test (ECICCommonConstants.STATUS_OPEN			, true,		true	); 		}

	// ----------------------------------------------------------------------------------------

	private static void linkCasesAndOpenAlerts2Test(String whatInIdSet, Boolean hasMatch, Boolean hasOpenCaseAlert) 			
	{
   		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
   		 
   		List<String> dummyArgumentList = new List<String>();
   		 
   		ECICCaseTestHelper.CaseConfig caseConfig = new ECICCaseTestHelper.CaseConfig(ECICCommonConstants.STATUS_OPEN);
   									  caseConfig.recordTypeId    = CASE_RECORD_TYPE_BY_NAME_MAP.get ('Inquiry Iberia');
   									  caseConfig.categoryLevel3  = 'Matching Value'; 
   									  caseConfig.channelOfAnswer = 'Phone';
		Case 		       									dummyCase 		  = ECICCaseTestHelper.createDummyCase(caseConfig, true);
		ECICLinkCaseAndOpenAlertsConfigEntry 		dummyCaseConfigEntry = ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyConfigEntry(dummyCase, dummyArgumentList);
		List<ECICLinkCaseAndOpenAlertsConfigEntry> 	dummyCaseConfigEntryList		=  new List<ECICLinkCaseAndOpenAlertsConfigEntry>{ dummyCaseConfigEntry };

   		TEST_DummyOpenAlertFactory.Config openAlertConfig = new TEST_DummyOpenAlertFactory.Config();
   										  openAlertConfig.categoryLevel3  = (hasMatch) ? 'Matching Value' : 'Different Value';  
		Open_Alert__c      									dummyOpenAlert	 					= TEST_DummyOpenAlertFactory.createDummy(openAlertConfig, true);
		ECICLinkCaseAndOpenAlertsConfigEntry 		dummyOpenAlertConfigEntry 			= ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyConfigEntry(dummyOpenAlert, dummyArgumentList);
		List<ECICLinkCaseAndOpenAlertsConfigEntry> 	dummyOpenAlertConfigEntryList		=  new List<ECICLinkCaseAndOpenAlertsConfigEntry>{ dummyOpenAlertConfigEntry };

		if (hasOpenCaseAlert) 
		{
			Open_Alert_Case__c dummyOpenAlertCase = TEST_DummyOpenAlertCaseFactory.createDummy(dummyCase, dummyOpenAlert, true);
		}
		
		/* TODO: Complete Setup */
		Set<Id>			   			 								   		 dummyIdSet  =  new Set<Id>();
		if ((new set<String>{'Case',       'Both'}).contains(whatInIdSet)) { dummyIdSet.add (dummyCase.id); 	 }
		if ((new set<String>{'Open Alert', 'Both'}).contains(whatInIdSet)) { dummyIdSet.add (dummyOpenAlert.id); }

		System.runAs(TEST_RUN_USER)
		{
			 ECICLinkCaseAndOpenAlertsHandler.linkCasesAndOpenAlerts (dummyCaseConfigEntryList, dummyOpenAlertConfigEntryList, dummyIdSet);
		}
		 
		List<Open_Alert_Case__c> resultOpenAlertCaseList = [SELECT id FROM Open_Alert_Case__c WHERE (case__c = :dummyCase.id) OR (Open_alert__c = :dummyOpenAlert.id)  ]; 
	
		System.assertEquals (
								(
								 (hasOpenCaseAlert)
									? 1
									: 0
								),
								resultOpenAlertCaseList.size()
							);

		  /* TODO: Make MORE assertions */ 

	}

	private static testMethod void caseInSetCaseSublistLinkedCasesAndOpenAlerts2Test() 						 { linkCasesAndOpenAlerts2Test ('Case',			false,	false	); 		}
	private static testMethod void hasAlertCaseInSetCaseSublistLinkedCasesAndOpenAlerts2Test() 				 { linkCasesAndOpenAlerts2Test ('Case',			false,	true	); 		}
	private static testMethod void hasAlerthasMatchCaseInSetCaseSublistLinkedCasesAndOpenAlerts2Test() 		 { linkCasesAndOpenAlerts2Test ('Case',			true,	true	); 		}

	private static testMethod void openAlertInSetCaseSublistLinkedCasesAndOpenAlerts2Test() 				 { linkCasesAndOpenAlerts2Test ('Open Alert',	false,	false	); 		}
	private static testMethod void hasAlertOpenAlertInSetCaseSublistLinkedCasesAndOpenAlerts2Test() 		 { linkCasesAndOpenAlerts2Test ('Open Alert',	false,	true	); 		}
	private static testMethod void hasAlerthasMatchOpenAlertInSetCaseSublistLinkedCasesAndOpenAlerts2Test()  { linkCasesAndOpenAlerts2Test ('Open Alert',	true,	true	); 		}

	private static testMethod void bothInSetCaseSublistLinkedCasesAndOpenAlerts2Test() 						 { linkCasesAndOpenAlerts2Test ('Both',			false,	false	); 		}
	private static testMethod void hasAlertBothInSetCaseSublistLinkedCasesAndOpenAlerts2Test() 				 { linkCasesAndOpenAlerts2Test ('Both',			false,	true	); 		}
	private static testMethod void hasAlertHasConditioBothInSetCaseSublistLinkedCasesAndOpenAlerts2Test() 	 { linkCasesAndOpenAlerts2Test ('Both',			true,	true	); 		}

	private static testMethod void noneInSetCaseSublistLinkedCasesAndOpenAlerts2Test() 						 { linkCasesAndOpenAlerts2Test ('None',			false,	false	); 		}
	private static testMethod void hasAlertNoneInSetCaseSublistLinkedCasesAndOpenAlerts2Test() 				 { linkCasesAndOpenAlerts2Test ('None',			false,	true	); 		}
	private static testMethod void hasAlerthasMatchNoneInSetCaseSublistLinkedCasesAndOpenAlerts2Test() 		 { linkCasesAndOpenAlerts2Test ('None',			true,	true	); 		}

	private static testMethod void hasMatchCaseInSetCaseSublistLinkedCasesAndOpenAlerts2Test() 				 { linkCasesAndOpenAlerts2Test ('Case',			true,	false	); 		}
	private static testMethod void hasMatchOpenAlertInSetCaseSublistLinkedCasesAndOpenAlerts2Test()	 		 { linkCasesAndOpenAlerts2Test ('Open Alert',	true,	false	); 		}
	private static testMethod void hasMatchBothInSetCaseSublistLinkedCasesAndOpenAlerts2Test() 			 	 { linkCasesAndOpenAlerts2Test ('Both',			true,	false	); 		}
	private static testMethod void hasMatchNoneInSetCaseSublistLinkedCasesAndOpenAlerts2Test() 				 { linkCasesAndOpenAlerts2Test ('None',			true,	false	); 		}

	// ----------------------------------------------------------------------------------------

	private static void linkCasesAndOpenAlerts3Test (Boolean hasMatch) 		
	{
   		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
   		 
   		List<String> dummyArgumentList = new List<String>();
   		 
   		ECICCaseTestHelper.CaseConfig caseConfig = new ECICCaseTestHelper.CaseConfig(ECICCommonConstants.STATUS_OPEN);
   									  caseConfig.recordTypeId    = CASE_RECORD_TYPE_BY_NAME_MAP.get ('Inquiry Iberia');
   									  caseConfig.categoryLevel3  = 'Matching Value'; 
   									  caseConfig.channelOfAnswer = 'Phone';
   									  caseConfig.countryCode     = 'ES';
		Case 		       									dummyCase 		  = ECICCaseTestHelper.createDummyCase(caseConfig, true);
		ECICLinkCaseAndOpenAlertsConfigEntry 		dummyCaseConfigEntry = ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyConfigEntry(dummyCase, dummyArgumentList);
		List<ECICLinkCaseAndOpenAlertsConfigEntry> 	dummyCaseConfigEntryList		=  new List<ECICLinkCaseAndOpenAlertsConfigEntry>{ dummyCaseConfigEntry };

   		TEST_DummyOpenAlertFactory.Config openAlertConfig = new TEST_DummyOpenAlertFactory.Config();
   										  openAlertConfig.categoryLevel3  = (hasMatch) ? 'Matching Value' : 'Different Value';  
   										  openAlertConfig.countryCodeString = 'ES';
   										  openAlertConfig.countryCode = 'ES';
		Open_Alert__c      									dummyOpenAlert	 					= TEST_DummyOpenAlertFactory.createDummy(openAlertConfig, true);
		ECICLinkCaseAndOpenAlertsConfigEntry 		dummyOpenAlertConfigEntry 			= ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyConfigEntry(dummyOpenAlert, dummyArgumentList);
		List<ECICLinkCaseAndOpenAlertsConfigEntry> 	dummyOpenAlertConfigEntryList		=  new List<ECICLinkCaseAndOpenAlertsConfigEntry>{ dummyOpenAlertConfigEntry };

		Open_Alert_Case__c dummyOpenAlertCase = TEST_DummyOpenAlertCaseFactory.createDummy(dummyCase, dummyOpenAlert, true);

		System.runAs(TEST_RUN_USER)
		{
			 ECICLinkCaseAndOpenAlertsHandler.linkCasesAndOpenAlerts (dummyCaseConfigEntryList, dummyOpenAlertConfigEntryList);
		}
		 
		System.assertEquals (dummyCase.Id, dummyOpenAlertCase.Case__c);
		System.assertEquals (dummyOpenAlert.Id, dummyOpenAlertCase.Open_Alert__c);
	}
	
	private static testMethod void caseSublistLinkedCasesAndOpenAlerts3Test() 					 { linkCasesAndOpenAlerts3Test (false	); 		}
	private static testMethod void hasConditionCaseSublistLinkedCasesAndOpenAlerts3Test() 		 { linkCasesAndOpenAlerts3Test (true	); 		}
}