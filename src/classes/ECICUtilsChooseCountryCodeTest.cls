/**
 * Tests for ECICUtils method chooseCountryCode (SObject currentSObject, Map<Id,User> userIdMap)
 *
 * Tests:
 * 	1. Test the method itself.
 * 	2. Test the method in the context of resolveCountryCode()
 *	3. Test the method in the context of insert triggers.
 *  4. Test the method in the context of upsert triggers.
 *
 * Moreover, tests include the possibilites that
 * 1. Data Country_Code__c may be null, empty, or not-null.
 * 2. The data's owner's Country_Code__c may be null, empty, or not-null.
 * 3. The data and the owner may have different Country_Code__c values.
 *
 * (Not tested: The impossibility that the running user doesn't have a Country_Code)
 *
 **/
@isTest
private class ECICUtilsChooseCountryCodeTest 
{
	public static  final User TEST_RUN_USER	= ECICRunUserTestHelper.create();  

	// chooseCountryCode() Tests ------------------------------------------------------------------------------------------------------------

	private static void chooseAccountCountryCodeMethodTest(String dataCountryCode, Boolean hasUserAsOwner, String ownerCountryCode) 				
	{
		System.runAs(TEST_RUN_USER) {
			User 		 dummyOwner 	= (hasUserAsOwner)  ? createDummyOwner (ownerCountryCode) : null; 
			QueueSObject dummyQueue 	= (!hasUserAsOwner) ? createDummyQueue () 			      : null;
			Account 	 dummyAccount 	=	createDummyAccount(dataCountryCode, ((hasUserAsOwner) ? dummyOwner.id : dummyQueue.id)); 
	
			Map<Id,User>	      dummyUserIdMap = new Map<Id,User>{ TEST_RUN_USER.id	=>	TEST_RUN_USER };
			if (hasUserAsOwner) { dummyUserIdMap.put (dummyOwner.id, dummyOwner); } 
	
			String resultCountryCode = null;
			resultCountryCode = ECICUtils.chooseCountryCode((sObject) dummyAccount, dummyUserIdMap);
	
	    	System.assertEquals (getExpectedCountryCode(dummyAccount, hasUserAsOwner, dummyOwner), resultCountryCode);
    	}
	}
	
	private static testMethod void dataCCNullOwnerCCNullChooseAccountCountryCodeMethodTest() 		{ chooseAccountCountryCodeMethodTest(null, true,   null); }
	private static testMethod void dataCCNullOwnerCCEmptyChooseAccountCountryCodeMethodTest() 		{ chooseAccountCountryCodeMethodTest(null, true,   '');   }
	private static testMethod void dataCCNullOwnerNotUserChooseAccountCountryCodeMethodTest() 		{ chooseAccountCountryCodeMethodTest(null, false,  'ES'); }
	private static testMethod void dataCCNullOwnerCCHasValueChooseAccountCountryCodeMethodTest() 	{ chooseAccountCountryCodeMethodTest(null, true,   'ES'); }

	private static testMethod void dataCCEmptyOwnerCCNullChooseAccountCountryCodeMethodTest() 		{ chooseAccountCountryCodeMethodTest('',   true,   null); }
	private static testMethod void dataCCEmptyOwnerCCEmptyChooseAccountCountryCodeMethodTest() 		{ chooseAccountCountryCodeMethodTest('',   true,   '');   }
	private static testMethod void dataCCEmptyOwnerNotUserChooseAccountCountryCodeMethodTest() 		{ chooseAccountCountryCodeMethodTest('',   false,  'ES'); }
	private static testMethod void dataCCEmptyOwnerCCHasValueChooseAccountCountryCodeMethodTest() 	{ chooseAccountCountryCodeMethodTest('',   true,   'ES'); }

	private static testMethod void dataHasCCOwnerCCNullChooseAccountCountryCodeMethodTest() 		{ chooseAccountCountryCodeMethodTest('PT', true,   null); }
	private static testMethod void dataHasCCOwnerCCEmptyChooseAccountCountryCodeMethodTest() 		{ chooseAccountCountryCodeMethodTest('PT', true,   '');   }
	private static testMethod void dataHasCCOwnerNotUserChooseAccountCountryCodeMethodTest() 		{ chooseAccountCountryCodeMethodTest('PT', false,  'ES'); }
	private static testMethod void dataCCNotEqualsOwnerCCChooseAccountCountryCodeMethodTest() 		{ chooseAccountCountryCodeMethodTest('PT', true,   'ES'); }
	private static testMethod void dataCCEqualsOwnerCCChooseAccountCountryCodeMethodTest() 			{ chooseAccountCountryCodeMethodTest('PT', true,   'PT'); }
	
	// resolveCountryCode() Tests ------------------------------------------------------------------------------------------------------------
	// Only asserts CountryCode
	  
	private static void resolveCountryCodeMethodTest(String dataCountryCode, Boolean hasUserAsOwner, String ownerCountryCode) 				
	{
		System.runAs(TEST_RUN_USER) {
			User 		 dummyOwner 	= (hasUserAsOwner)  ? createDummyOwner (ownerCountryCode) : null; 
			QueueSObject dummyQueue 	= (!hasUserAsOwner) ? createDummyQueue () 			      : null;
			Account 	 dummyAccount 	=	createDummyAccount(dataCountryCode, ((hasUserAsOwner) ? dummyOwner.id : dummyQueue.id)); 
	
			ECICUtils.resolveCountryCode((new List<sObject> { (Sobject) dummyAccount }), null, null);
	
	    	System.assertEquals (getExpectedCountryCode(dummyAccount, hasUserAsOwner, dummyOwner), dummyAccount.Country_Code__c);
    	}
	}

	private static testMethod void dataCCNullOwnerNotUserResolveCountryCodeMethodTest() 		{ resolveCountryCodeMethodTest(null, false,  'ES'); }
	private static testMethod void dataCCNullOwnerCCHasValueResolveCountryCodeMethodTest() 		{ resolveCountryCodeMethodTest(null, true,   'ES'); }
	private static testMethod void dataCCEmptyOwnerNotUserResolveCountryCodeMethodTest() 		{ resolveCountryCodeMethodTest('',   false,  'ES'); }
	private static testMethod void dataCCEmptyOwnerCCHasValueResolveCountryCodeMethodTest() 	{ resolveCountryCodeMethodTest('',   true,   'ES'); }
	// Note: It is not a valid use case for the owner's Country Code to be null or empty, so we don't care that such tests WILL fail.	

	private static testMethod void dataHasCCOwnerCCNullResolveCountryCodeMethodTest() 			{ resolveCountryCodeMethodTest('PT', true,   null); }
	private static testMethod void dataHasCCOwnerCCEmptyResolveCountryCodeMethodTest() 			{ resolveCountryCodeMethodTest('PT', true,   '');   }
	private static testMethod void dataHasCCOwnerNotUserResolveCountryCodeMethodTest() 			{ resolveCountryCodeMethodTest('PT', false,  'ES'); }
	private static testMethod void dataCCNotEqualsOwnerCCResolveCountryCodeMethodTest() 		{ resolveCountryCodeMethodTest('PT', true,   'ES'); }
	private static testMethod void dataCCEqualsOwnerCCResolveCountryCodeMethodTest() 			{ resolveCountryCodeMethodTest('PT', true,   'PT'); }


	// Actual Trigger Tests ------------------------------------------------------------------

	private static void chooseAccountCountryCodeTriggerTest(String newDataCountryCode, String ownerCountryCode, Boolean isInsertTest) 				
	{
		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		System.runAs(TEST_RUN_USER) {
			User 		 dummyOwner 	= createDummyOwner (ownerCountryCode); 
			Account 	 dummyAccount 	= createDummyAccount((isInsertTest) ? newDataCountryCode : 'DE', dummyOwner.id, (!isInsertTest));

    		if (isInsertTest) { insert dummyAccount; }
    		else
    		{
	    		dummyAccount.country_code__c = newDataCountryCode;
				update dummyAccount;
    		}
    	
    		Account resultAccount = [SELECT country_code__c FROM Account WHERE id = :dummyAccount.id LIMIT 1];
    		System.assertEquals (getExpectedCountryCode(dummyAccount, true, dummyOwner), resultAccount.Country_Code__c);
    	}
	}

	private static testMethod void dataCCNullOwnerCCHasValueChooseAccountCountryCodeInsertTest() 	{ chooseAccountCountryCodeTriggerTest(null, 'ES',	true); }
	private static testMethod void dataCCEmptyOwnerCCHasValueChooseAccountCountryCodeInsertTest() 	{ chooseAccountCountryCodeTriggerTest('',   'ES',	true); }
	private static testMethod void dataHasCCOwnerCCNullChooseAccountCountryCodeInsertTest() 		{ chooseAccountCountryCodeTriggerTest('PT', null,	true); }
	private static testMethod void dataHasCCOwnerCCEmptyChooseAccountCountryCodeInsertTest() 		{ chooseAccountCountryCodeTriggerTest('PT', '',		true); }
	private static testMethod void dataCCNotEqualsOwnerCCChooseAccountCountryCodeInsertTest() 		{ chooseAccountCountryCodeTriggerTest('PT', 'ES',	true); }
	private static testMethod void dataCCEqualsOwnerCCChooseAccountCountryCodeInsertTest() 			{ chooseAccountCountryCodeTriggerTest('PT', 'PT',	true); }

	private static testMethod void dataCCEmptyOwnerCCHasValueChooseAccountCountryCodeUpdateTest() 	{ chooseAccountCountryCodeTriggerTest('',   'ES',	false); }
	private static testMethod void dataHasCCOwnerCCNullChooseAccountCountryCodeUpdateTest() 		{ chooseAccountCountryCodeTriggerTest('FR', null,	false); }
	private static testMethod void dataHasCCOwnerCCEmptyChooseAccountCountryCodeUpdateTest() 		{ chooseAccountCountryCodeTriggerTest('FR', '',		false); }
	private static testMethod void dataCCNotEqualsOwnerCCChooseAccountCountryCodeUpdateTest() 		{ chooseAccountCountryCodeTriggerTest('FR', 'ES',	false); }
	private static testMethod void dataCCEqualsOwnerCCChooseAccountCountryCodeUpdateTest() 			{ chooseAccountCountryCodeTriggerTest('PT', 'PT',	false); }

	// Helper methods -------------------------------------------------------------------------------------------------------------------------------------

	private static User createDummyOwner (String ownerCountryCode)
	{
		User   dummyOwner = ECICTestHelper.createTestUser(ECICRunUserTestHelper.ES_INFOLINE_AGENT_PARAM, false); 
		 	   dummyOwner.Country_Code__c = ownerCountryCode;
  		insert dummyOwner;
  		return dummyOwner;
	}
	
	private static QueueSObject createDummyQueue()
	{
		Group  dummyGroup = new Group (name='Dummy Group', type='Queue');					 	
		insert dummyGroup;
		
		QueueSObject dummyQueue = new QueueSObject (queueId = dummyGroup.id, sObjectType='Lead'); 		
			  insert dummyQueue;
			  return dummyQueue;
	}

	
	private static Account createDummyAccount(String dataCountryCode, Id ownerId, Boolean insertNow)
	{
		Account	dummyAccount 	= ECICAccountTestHelper.createDummyAccount('Generic', false); 
				dummyAccount.Country_Code__c = dataCountryCode;
				dummyAccount.OwnerId 		 = ownerId;
				dummyAccount.CreatedById 	 = TEST_RUN_USER.id;
				dummyAccount.ShippingState = ECICCommonConstants.TEST_CITY_STATE_AND_REGION;
		if (insertNow) { insert dummyAccount; }
		return  dummyAccount;  
	}

	private static Account createDummyAccount(String dataCountryCode, Id ownerId) { return createDummyAccount(dataCountryCode, ownerId, false); }


	private static String getExpectedCountryCode(Account dummyAccount, Boolean hasUserAsOwner, User dummyOwner)
	{
    	return ((dummyAccount.Country_Code__c != null) && (dummyAccount.Country_Code__c != ''))
    									?	dummyAccount.Country_Code__c
    									:	(
    											((hasUserAsOwner) && (dummyOwner.Country_Code__c != null) && (dummyOwner.Country_Code__c != ''))	
    												?	dummyOwner.Country_Code__c
    												: 	TEST_RUN_USER.Country_Code__c
											);
	}



}