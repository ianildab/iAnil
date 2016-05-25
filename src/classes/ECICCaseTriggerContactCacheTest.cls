@isTest
private class ECICCaseTriggerContactCacheTest {
    private static final User     TEST_RUN_USER = ECICRunUserTestHelper.create();
    
    private static testMethod void getWebCaseContactByIdMapTest() {
        Contact dummyContact = TEST_DummyContactFactory.create(TEST_DummyInsertModeEnum.MOCK);
        
        ECICCaseTriggerContactCache.webCaseContactByIdCache    = new Map<Id, Contact>{dummyContact.id => dummyContact};
        
        Map<Id, Contact>    resultContactByIdMap = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                resultContactByIdMap = ECICCaseTriggerContactCache.getWebCaseContactByIdMap();
            }
            Test.stopTest();
        }
        
        System.assert(resultContactByIdMap.containsKey(dummyContact.id));
        System.assertEquals(dummyContact.name, resultContactByIdMap.get(dummyContact.id).name);
    }
    
    private static void populateTest(Boolean isWebCase, Boolean hasContactId) {
        Contact dummyContact = (hasContactId) ? TEST_DummyContactFactory.create(TEST_DummyInsertModeEnum.REAL) : null;
        
        TEST_DummyCaseConfig    caseConfig = new TEST_DummyCaseConfig();
                                caseConfig.origin       = (isWebCase)       ? 'Web'             : 'Phone';
                                caseConfig.contactId    = (hasContactId)    ? dummyContact.id   : null;
        
        Case dummyCase = TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.NONE);
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                ECICCaseTriggerContactCache.populate(new List<Case> { dummyCase } );
            }
            Test.stopTest();
        }
        
        Map<Id, Contact>    resultContactByIdMap = ECICCaseTriggerContactCache.webCaseContactByIdCache;
        if (isWebCase && hasContactId)
        {
            System.assert(resultContactByIdMap.containsKey(dummyContact.id));
            System.assertEquals(dummyContact.lastName, resultContactByIdMap.get(dummyContact.id).lastName);
        }
        else if (hasContactId)
        {
            System.assert(! resultContactByIdMap.containsKey(dummyContact.id));
        }
        // There is nothing to check for if not web Case.
    }
    
    private static testMethod void notWebNoIdPopulateTest()     { populateTest ( false, false   ); }
    private static testMethod void notWebWithIdPopulateTest()   { populateTest ( true,  false   ); }
    private static testMethod void webNoIdPopulateTest()        { populateTest ( false, true    ); }
    private static testMethod void webWithIdPopulateTest()      { populateTest ( true,  true    ); }

}