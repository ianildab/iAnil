@isTest
private class ECICCaseAccountWorkstreamTest 
{
    private static final User TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();

    private static void hasContactDetailTest(Boolean haveEqualValues, Boolean haveNonNullValues)
    {
        String dummyFieldValue  = (haveNonNullValues) ? 'Dummy 1' : null;
        String dummyDetailValue = (haveNonNullValues) ? ((haveEqualValues) ? 'Dummy 1' : 'Dummy 2') : null;

        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = ECICCaseAccountWorkstream.hasContactDetail (dummyFieldValue, dummyDetailValue);
            }
            Test.stopTest();
        } 
        
        Boolean expectedResult = haveEqualValues && haveNonNullValues;
        System.assertEquals(expectedResult, result);
    }

    private static testMethod void differentValuesHasContactDetailTest() { hasContactDetailTest(false, true ); }
    private static testMethod void bothNullHasContactDetailTest()        { hasContactDetailTest(true,  false); }
    private static testMethod void bothSameHasContactDetailTest()        { hasContactDetailTest(true,  true ); }
    
    //----------------------------------------------------------------------------------------------------------------
    
    private static void hasContactDetailsTest(Boolean hasEmail, Boolean hasPhone, Boolean hasMobilePhone, Boolean hasHomePhone, Boolean hasOtherPhone)
    {
        String dummyEmail = 'dummy@example.com';
        String dummyPhone = '+001 510 369 1248';
        
        Contact dummyContact = createContact(
                                                ((hasEmail)       ? dummyEmail  : 'nonmatch@example.com'), 
                                                ((hasPhone)       ? dummyPhone  : '+001 510 369 0001'   ),
                                                ((hasMobilePhone) ? dummyPhone  : '+001 510 369 0002'   ), 
                                                ((hasHomePhone)   ? dummyPhone  : '+001 510 369 0003'   ), 
                                                ((hasOtherPhone)  ? dummyPhone  : '+001 510 369 0004'   ) 
                                            ); 
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = ECICCaseAccountWorkstream.hasContactDetails (dummyContact, dummyEmail, dummyPhone);
            }
            Test.stopTest();
        } 

        Boolean expectedResult = hasEmail || hasPhone || hasMobilePhone || hasHomePhone || hasOtherPhone;
        System.assertEquals(expectedResult, result);
    }
    
    private static testMethod void hasNoneHasContactDetailsTest()                { hasContactDetailsTest( false, false, false, false, false ); }
    private static testMethod void hasOtherPhoneHasContactDetailsTest()          { hasContactDetailsTest( false, false, false, false, true  ); }
    private static testMethod void hasHomePhoneHasContactDetailsTest()           { hasContactDetailsTest( false, false, false, true,  false ); }
    private static testMethod void hasHomeAndOtherPhoneHasContactDetailsTest()   { hasContactDetailsTest( false, false, false, true,  true  ); }
    private static testMethod void hasMobilePhoneHasContactDetailsTest()         { hasContactDetailsTest( false, false, true,  false, false ); }
    private static testMethod void hasMobileAndHomePhoneHasContactDetailsTest()  { hasContactDetailsTest( false, false, true,  true,  false ); }
    private static testMethod void hasPhoneHasContactDetailsTest()               { hasContactDetailsTest( false, true,  false, false, false ); }
    private static testMethod void hasPhoneAndMobilePhoneHasContactDetailsTest() { hasContactDetailsTest( false, true,  true,  false, false ); }
    private static testMethod void hasEmailHasContactDetailsTest()               { hasContactDetailsTest( true,  false, false, false, false ); }
    private static testMethod void hasEmailAndHomePhoneHasContactDetailsTest()   { hasContactDetailsTest( true,  false, false, true,  false ); }
    private static testMethod void hasEmailAndTwoPhonesHasContactDetailsTest()   { hasContactDetailsTest( true,  true,  false, false, true  ); }
    private static testMethod void HasAllHasContactDetailsTest()                 { hasContactDetailsTest( true,  true,  true,  true,  true  ); }

    //----------------------------------------------------------------------------------------------------------------

    private static void mapContactTest(Boolean mapHasKey)
    {
        ECICCaseAccountWorkstream.WorkstreamEnum                 dummyWorkstreamEnum = ECICCaseAccountWorkstream.WorkstreamEnum.CIC;
        Contact                                                  dummyContact        = TEST_DummyContactFactory.create(TEST_DummyInsertModeEnum.NONE); 

        Map<ECICCaseAccountWorkstream.WorkstreamEnum, Contact[]> dummyWorkstreamMap  = new Map<ECICCaseAccountWorkstream.WorkstreamEnum, Contact[]>();
        if (mapHasKey) {                                         dummyWorkstreamMap.put (dummyWorkstreamEnum, new List<Contact>());                    }
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICCaseAccountWorkstream.mapContact(dummyWorkstreamMap, dummyWorkstreamEnum, dummyContact);
            }
            Test.stopTest();
        } 
        
        System.assert       (dummyWorkstreamMap.containsKey(dummyWorkstreamEnum));
        System.assertEquals (dummyContact, dummyWorkstreamMap.get(dummyWorkstreamEnum)[0]); 
    }
    
    private static testMethod void noKeyMapContactTest()  { mapContactTest (false); }
    private static testMethod void hasKeyMapContactTest() { mapContactTest (true);  }

    //----------------------------------------------------------------------------------------------------------------

    private static void selectWorkstreamEnumTest(String prefix)
    {
        String dummyOwnerProfileName = (prefix != null) ? (prefix + 'Dummy Profile Name') : null; // TODO

        ECICCaseAccountWorkstream.WorkstreamEnum resultWorkstream = null; 
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultWorkstream = ECICCaseAccountWorkstream.selectWorkstreamEnum (dummyOwnerProfileName);
            }
            Test.stopTest();
        }
        
        ECICCaseAccountWorkstream.WorkstreamEnum expectedWorkstream = null;
        if      (prefix == 'CRM')  { expectedWorkStream = ECICCaseAccountWorkstream.WorkstreamEnum.CRM; }
        else if (prefix == 'STM')  { expectedWorkStream = ECICCaseAccountWorkstream.WorkstreamEnum.STM; }
        else if (prefix == 'ECIC') { expectedWorkStream = ECICCaseAccountWorkstream.WorkstreamEnum.CIC; }
        // else leave expected value as null.
                                                                            
        System.assertEquals (expectedWorkstream, resultWorkstream);
    }

    private static testMethod void crmSelectWorkstreamEnumTest()   { selectWorkstreamEnumTest('CRM');   }
    private static testMethod void stmSelectWorkstreamEnumTest()   { selectWorkstreamEnumTest('STM');   }
    private static testMethod void ecicSelectWorkstreamEnumTest()  { selectWorkstreamEnumTest('ECIC');  }
    private static testMethod void otherSelectWorkstreamEnumTest() { selectWorkstreamEnumTest('Other'); }
    private static testMethod void nullSelectWorkstreamEnumTest()  { selectWorkstreamEnumTest(null);    }
    
    //----------------------------------------------------------------------------------------------------------------

    private static void findWorkstreamContactsTest(Boolean hasWorkstream, Boolean hasEmail, Boolean hasPhone)
    {
        String                                     dummyEmail          = (hasEmail) ? 'dummy@example.com'                                   : null;
        String                                     dummyPhone          = (hasPhone) ? '+001 510 369 1248'                                   : null;

        String                                     dummyProfileName    = (hasWorkstream) ? ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT : 'Marketing User'; //#CICTemplateTest

        Contact       dummyContact     = createContact(dummyEmail, dummyPhone, null, null, null); 
        TEST_MockHelper.mockInsert(dummyContact);
        if (hasWorkstream) { TEST_MockHelper.setMockString(dummyContact.id, 'owner.profile.name', dummyProfileName); }
        List<Contact> dummyContactList = new List<Contact>{ dummyContact }; 
        
        Map<ECICCaseAccountWorkstream.WorkstreamEnum, Contact[]> resultContactListByWorkstreamMap = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultContactListByWorkstreamMap = ECICCaseAccountWorkstream.findWorkstreamContacts (dummyEmail, dummyPhone, dummyContactList);
            }
            Test.stopTest();
        } 
        
        ECICCaseAccountWorkstream.WorkstreamEnum   expectedWorkstreamEnum = ECICCaseAccountWorkstream.WorkstreamEnum.CIC;  // Note: Owner.profile.name is NOT set from this.
        Boolean mappingExpected = ((hasWorkStream) && (hasEmail || hasPhone));
        System.assertEquals (mappingExpected, resultContactListByWorkstreamMap.containsKey(expectedWorkstreamEnum));
        if (mappingExpected) {  System.assertEquals (dummyContact, resultContactListByWorkstreamMap.get(expectedWorkstreamEnum)[0]); } 
    }
    
    private static testMethod void hasNoneFindWorkstreamContactsTest()               { findWorkstreamContactsTest(false, false, false); }
    private static testMethod void hasPhoneFindWorkstreamContactsTest()              { findWorkstreamContactsTest(false, false, true ); }
    private static testMethod void hasEmailFindWorkstreamContactsTest()              { findWorkstreamContactsTest(false, true,  false); }
    private static testMethod void hasBothContactFindWorkstreamContactsTest()        { findWorkstreamContactsTest(false, true,  true ); }

    private static testMethod void hasWorkstreamFindWorkstreamContactsTest()         { findWorkstreamContactsTest(true,  false, false); }
    private static testMethod void hasWorkstreamAndPhoneFindWorkstreamContactsTest() { findWorkstreamContactsTest(true,  false, true ); }
    private static testMethod void hasWorkstreamAndEmailFindWorkstreamContactsTest() { findWorkstreamContactsTest(true,  true,  false); }
    private static testMethod void hasAllFindWorkstreamContactsTest()                { findWorkstreamContactsTest(true,  true,  true ); }
    
    //----------------------------------------------------------------------------------------------------------------
    
    private static void getWorkstreamContactTest(ECICCaseAccountWorkstream.WorkstreamEnum dummyWorkstream, Boolean workstreamHasContact)
    {
        Contact       dummyContact     = (workstreamHasContact) ? TEST_DummyContactFactory.create(TEST_DummyInsertModeEnum.NONE) : null;
        
        Map<ECICCaseAccountWorkstream.WorkstreamEnum, Contact[]> dummyWorkstreamEnumContactMap = new Map<ECICCaseAccountWorkstream.WorkstreamEnum, Contact[]>();
        if (workstreamHasContact) { dummyWorkstreamEnumContactMap.put (dummyWorkstream, new List<Contact>{ dummyContact }); }
    
        Contact resultContact = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultContact = ECICCaseAccountWorkstream.getWorkstreamContact (dummyWorkstreamEnumContactMap);
            }
            Test.stopTest();
        } 
        
        System.assertEquals (((workstreamHasContact) ? dummyContact : null),  resultContact);
    }

    private static testMethod void noCRMContactGetWorkstreamContactTest()  { getWorkstreamContactTest(ECICCaseAccountWorkstream.WorkstreamEnum.CRM, false); }
    private static testMethod void hasCRMContactGetWorkstreamContactTest() { getWorkstreamContactTest(ECICCaseAccountWorkstream.WorkstreamEnum.CRM, true);  }
    private static testMethod void noSTMContactGetWorkstreamContactTest()  { getWorkstreamContactTest(ECICCaseAccountWorkstream.WorkstreamEnum.STM, false); }
    private static testMethod void hasSTMContactGetWorkstreamContactTest() { getWorkstreamContactTest(ECICCaseAccountWorkstream.WorkstreamEnum.STM, true);  }
    
    //----------------------------------------------------------------------------------------------------------------
    
    private static Contact createContact(String dummyEmail, String dummyPhone, String dummyMobilePhone, String dummyHomePhone, String dummyOtherPhone)
    {
        TEST_DummyContactFactory.Config config = new TEST_DummyContactFactory.Config();
                                        config.email       = dummyEmail; 
                                        config.phone       = dummyPhone; 
                                        config.mobilePhone = dummyMobilePhone; 
                                        config.homePhone   = dummyHomePhone; 
                                        config.otherPhone  = dummyOtherPhone; 
        
        return TEST_DummyContactFactory.create(config, TEST_DummyInsertModeEnum.NONE);                                 
    }
    
}