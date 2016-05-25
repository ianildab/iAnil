/**
 * Unit tests to confirm copy of country from Account.country_code__pc to Account.country_code__c when
 * inserted or updated with new Contact Country Code.
 * @see https://tcccdiam.atlassian.net/i#browse/CIC-715
 **/ 

@isTest
private class ECICAccountTriggerHandlerCountryCodeTest 
{
  	private static final User 	TEST_RUN_USER = ECICRunUserTestHelper.create();
	private static final String COUNTRY_CODE_START_VALUE  = 'UK';
   	private static final String COUNTRY_CODE_TARGET_VALUE = 'ES';

	private static void copyCountryCodeToAccountTest (String accountType, Boolean isInsertTest)
	{
		Boolean isPersonAccountTest = (accountType == 'Person');
		Boolean isUpdateTest        = (!isInsertTest);
   		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		
		Account dummyAccount = ECICAccountTestHelper.createDummyAccount(accountType, false);
			    dummyAccount.Country_Code__c = COUNTRY_CODE_START_VALUE;			
		if (isPersonAccountTest) { dummyAccount.Country_Code__pc = (isUpdateTest) ? COUNTRY_CODE_START_VALUE : COUNTRY_CODE_TARGET_VALUE; }
		if (isUpdateTest) 
		{ 
			insert dummyAccount;
			if (isPersonAccountTest) { dummyAccount.Country_Code__pc = COUNTRY_CODE_TARGET_VALUE; }
		}

	  	System.runAs(TEST_RUN_USER) 
	  	{
			Test.startTest();
			{
				if (isInsertTest) { insert dummyAccount; }
				else			  { update dummyAccount; }
			}
			Test.stopTest();
	  	}		
		// if personAccount, contact was inserted when the personAccount was inserted
		
		Account resultAccount = [SELECT id, country_code__c FROM Account WHERE id = :dummyAccount.Id LIMIT 1];
		if (isPersonAccountTest) { System.assertEquals    (COUNTRY_CODE_TARGET_VALUE, resultAccount.country_code__c); }
		else					 { System.assertNotEquals (COUNTRY_CODE_TARGET_VALUE, resultAccount.country_code__c); }
	}

 	private static testMethod void businessInsertContactTest() 						{ copyCountryCodeToAccountTest('Business', true); }
	private static testMethod void businessUpdateContactWithNewCountryCodeTest() 	{ copyCountryCodeToAccountTest('Business', false); }

	private static testMethod void personInsertContactTest() 						{ copyCountryCodeToAccountTest('Person',   true); }
	private static testMethod void personUpdateContactWithNewCountryCodeTest() 		{ copyCountryCodeToAccountTest('Person',   false); }
}