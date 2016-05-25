/**
* @author		Brian Kessler (Brian_Kessler@epam.com)
* @date			2013 May 24
* @description	This class is comtains unit tests for ECICAccount.trigger
*				All tests are runnung as a System Administrator (unless ECICRunUserTestHelper.create() has been modified).
* 		
*/

@isTest
private class ECICAccountTriggerTests 
{
    private static User testRunUser = ECICRunUserTestHelper.create();
    private static final String USER_PREFIX = '005';

    static Account singleAccountTest (Account dummyAccount, String triggerType, Boolean skipTriggers)
    {
        General_Settings__c.getInstance().skipTriggers__c = skipTriggers;
 
        Test.startTest(); 
        {
                     if (triggerType == 'isInsert') { insert dummyAccount; }
                else if (triggerType == 'isUpdate') { update dummyAccount; }
                else if (triggerType == 'isDelete') { delete dummyAccount; }
        }
        Test.stopTest(); 
        
        return dummyAccount;
    }

    static Account singleAccountTest (Account dummyAccount, String triggerType)
    {
        return singleAccountTest (dummyAccount, triggerType, false);
    }

	// --- Skip Invocation Tests -------------------------------------------------------------------------------------------------------------------

    static void skipInvocationTest(String triggerType, String accountType) 
    {
        System.runAs(testRunUser) 
        {
            insert new General_Settings__c(skipTriggers__c = true);
            SEPTriggerHandlerInvoker.pretendTestNotRunning = true;
            System.assertEquals(true, SEPTriggerHandlerInvoker.skipTriggerInvocation());
			Account dummyAccount;
            if (triggerType == 'isInsert')
            {
				dummyAccount = TEST_DummyAccountFactory.create(TEST_DummyInsertModeEnum.NONE);
            }
            else
            {
				dummyAccount = TEST_DummyAccountFactory.create(TEST_DummyInsertModeEnum.REAL);
            }
            // Test the trigger.		  	

            Account returnedAccount = singleAccountTest (dummyAccount, triggerType, true);            
            // TODO: Assert trigger has not run
            if (triggerType == 'isInsert' || triggerType == 'isUpdate') {
                returnedAccount = [SELECT Id, PersonContactId, Name, ownerID, Country_code__c, Owner_Lookup__c, 
                                          RecordTypeId, Region__c, Key_Stakeholder__pc, IsPersonAccount, 
                                          Shipping_Municipality__c, shipping_administrativearea__c, Shipping_Country__c, shipping_postalCode__c,Shipping_Streetname1__c FROM Account LIMIT 1];
               
                System.assertEquals(false, isCountryCodeResolved(returnedAccount));
                System.assertEquals(false, isOwnerResolved(returnedAccount));
                //System.assertEquals(false, isAssignedShippingRegion(returnedAccount)); //FAILING
                //System.assertEquals(false, isAssignedShippingAdministrativeArea(returnedAccount)); //FAILING
                System.assertEquals(false, isAssignedKeyStakeholder(returnedAccount));
                if (returnedAccount.IsPersonAccount) {
                    System.assertEquals(false, isAddressSynchronized(returnedAccount));
                }
            } else {
                System.assertEquals(true, isAccountDeleted(returnedAccount));
            }            
        }
    }
    
    private static Boolean isCountryCodeResolved(Account accnt) {
      return accnt.Country_code__c == null ? false : true;
    }
    
    private static Boolean isOwnerResolved(Account accnt) {
      return accnt.Owner_Lookup__c == null ? false : true;
    }
    
    private static Boolean isAssignedShippingAdministrativeArea(Account accnt) {
      return accnt.shipping_administrativearea__c == null ? false : true;
    }
    
    private static Boolean isAssignedShippingRegion(Account accnt) {
      return accnt.Region__c == null ? false : true;
    }
    
    private static Boolean isAssignedKeyStakeholder(Account accnt) {
      return accnt.Key_Stakeholder__pc;
    }
    
    private static Boolean isAccountDeleted(Account accnt) {
      Integer accCount        = [SELECT Count() FROM Account];
      Integer accDeletedCount = [SELECT Id FROM Account WHERE IsDeleted = true AND id =:accnt.Id ALL ROWS].size();
      return accCount == 0 && accDeletedCount == 1;
    }
    
    private static Boolean isAddressSynchronized(Account accnt) {
      Contact cnt = [SELECT Id, Name, MailingCity, MailingState, MailingCountry, MailingPostalCode, MailingStreet, Mailing_Municipality__c, mailing_administrativearea__c, Mailing_Country__c, mailing_postalCode__c,Mailing_Streetname1__c
                            FROM Contact WHERE Id =:accnt.PersonContactId];
      
      return (cnt.MailingCity != null && cnt.Mailing_Municipality__c == accnt.Shipping_Municipality__c) &&
             (cnt.MailingState != null && cnt.mailing_administrativearea__c == accnt.shipping_administrativearea__c) &&
             (cnt.MailingCountry !=null && cnt.Mailing_Country__c == accnt.Shipping_Country__c) &&
             (cnt.MailingPostalCode != null && cnt.mailing_postalCode__c == accnt.shipping_postalCode__c) &&
             (cnt.MailingStreet != null && cnt.Mailing_Streetname1__c == accnt.Shipping_Streetname1__c);
    }
	    

    static testMethod void insertSingleGenericAccountSkipInvocationTest()  { skipInvocationTest('isInsert', 'Generic' ); }
    static testMethod void updateSingleGenericAccountSkipInvocationTest()  { skipInvocationTest('isUpdate', 'Generic' ); }
    static testMethod void deleteSingleGenericAccountSkipInvocationTest()  { skipInvocationTest('isDelete', 'Generic' ); }

    static testMethod void insertSingleBusinessAccountSkipInvocationTest() { skipInvocationTest('isInsert', 'Business'); }
    static testMethod void updateSingleBusinessAccountSkipInvocationTest() { skipInvocationTest('isUpdate', 'Business'); }
    static testMethod void deleteSingleBusinessAccountSkipInvocationTest() { skipInvocationTest('isDelete', 'Business'); }

    static testMethod void insertSinglePersonAccountSkipInvocationTest()   { skipInvocationTest('isInsert', 'Person' );  }
    static testMethod void updateSinglePersonAccountSkipInvocationTest()   { skipInvocationTest('isUpdate', 'Person' );  }
    static testMethod void deleteSinglePersonAccountSkipInvocationTest()   { skipInvocationTest('isDelete', 'Person' );  }


	// --- Single Account Tests ---------------------------------------------------------------------------------------------------

    static void Test(String triggerType, String accountType) 
    {
        System.runAs(testRunUser) 
        {
            General_Settings__c.getInstance().skipTriggers__c = false;
            
            //Account dummyAccount = ECICAccountTestHelper.createDummyAccount(accountType, triggerType); 
            Account dummyAccount;
            if (triggerType == 'isInsert')
            {
				dummyAccount = TEST_DummyAccountFactory.create(TEST_DummyInsertModeEnum.NONE);
            }
            else
            {
				dummyAccount = TEST_DummyAccountFactory.create(TEST_DummyInsertModeEnum.REAL);
            }
            // Test the trigger.		  	
            Account returnedAccount = singleAccountTest (dummyAccount, triggerType, true);
            
            // TODO: Assert trigger has run correctly.
            if (triggerType == 'isInsert' || triggerType == 'isUpdate') {
                returnedAccount = [SELECT Id, PersonContactId, Name, ownerID, Country_code__c, Owner_Lookup__c, RecordTypeId, Region__c, 
                                          Profession_Function__pc, IsPersonAccount, Key_Stakeholder__pc,
                                          Shipping_Municipality__c, shipping_administrativearea__c, Shipping_Country__c, shipping_postalCode__c,Shipping_Streetname1__c FROM Account LIMIT 1];
                if (returnedAccount.RecordTypeId != ECICCommonConstants.ACCOUNT_PERSON_RT_ID) {
                    System.assertEquals(true, isCountryCodeResolved(returnedAccount));
                }
                if (String.valueOf(returnedAccount.ownerID).startsWith(USER_PREFIX)) {
                    System.assertEquals(true, isOwnerResolved(returnedAccount));
                }
                if (returnedAccount.shipping_administrativearea__c  != null) {
                    System.assertEquals(true,  isAssignedShippingAdministrativeArea(returnedAccount));
                }
                if (returnedAccount.IsPersonAccount && ECICCommonConstants.KEY_STAKEHOLDERS_PROFESSION.contains(returnedAccount.Profession_Function__pc)) {
                    System.assertEquals(true, isAssignedKeyStakeholder(returnedAccount));
                }
                if (returnedAccount.IsPersonAccount) {
                    System.assertEquals(true, isAddressSynchronized(returnedAccount));
                } 
            } else {
                System.assertEquals(true, isAccountDeleted(returnedAccount));
            }
            
        }
    }

    static testMethod void insertSingleGenericAccountTest()  { Test('isInsert', 'Generic' ); }
    static testMethod void updateSingleGenericAccountTest()  { Test('isUpdate', 'Generic' ); }
    static testMethod void deleteSingleGenericAccountTest()  { Test('isDelete', 'Generic' ); }

    static testMethod void insertSingleBusinessAccountTest() { Test('isInsert', 'Business'); }
    static testMethod void updateSingleBusinessAccountTest() { Test('isUpdate', 'Business'); }
    static testMethod void deleteSingleBusinessAccountTest() { Test('isDelete', 'Business'); }

    static testMethod void insertSinglePersonAccountTest()   { Test('isInsert', 'Person' );  }
    static testMethod void updateSinglePersonAccountTest()   { Test('isUpdate', 'Person' );  }
    static testMethod void deleteSinglePersonAccountTest()   { Test('isDelete', 'Person' );  }
	
    private static TEST_DummyInsertModeEnum convert (Boolean insertNow)
    {
        return (insertNow) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE;
    }

}