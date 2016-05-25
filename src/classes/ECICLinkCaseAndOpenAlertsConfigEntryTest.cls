@isTest
private class ECICLinkCaseAndOpenAlertsConfigEntryTest 
{
    private static final User    TEST_RUN_USER  = ECICRunUserTestHelper.create();

    private static testMethod void ConfigEntrySetArgsTest()         
    {
        ECICLinkCaseAndOpenAlertsConfigEntry dummyConfigEntry = new ECICLinkCaseAndOpenAlertsConfigEntry(new Case());
        List<String> dummyArgList = ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyArgList(1, null , null, false);
        
        System.runAs(TEST_RUN_USER)    
        {
            dummyConfigEntry.setArgs (dummyArgList); 
        }
         
        System.assertEquals(dummyArgList, dummyConfigEntry.args);   
    }
    
    private static testMethod void ConfigEntryGetArgsTest()         
    {
        ECICLinkCaseAndOpenAlertsConfigEntry dummyConfigEntry = new ECICLinkCaseAndOpenAlertsConfigEntry(new Case());
        dummyConfigEntry.args = ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyArgList(1, null , null, false);
        
        List<String> resultArgList = null; 
        System.runAs(TEST_RUN_USER)
        {
            resultArgList = dummyConfigEntry.getArgs (); 
        } 
        
        System.assertEquals(dummyConfigEntry.args, resultArgList);   
    }

    // ----------------------------------------------------------------------------------------
    
    private static void getConfigsTest(Boolean isObjectListForOpenAlerts, Boolean hasFieldActive)                           
    {
        ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
        Open_Alert__c dummyOpenAlert = (isObjectListForOpenAlerts)  ? ECICLinkCaseAndOpenAlertsHandlerTestHelp.createOpenAlertForConfigTest(hasFieldActive) : null;
        Case          dummyCase      = (!isObjectListForOpenAlerts) ? ECICLinkCaseAndOpenAlertsHandlerTestHelp.createCaseForConfigTest()                    : null;
        
        List<ECICLinkCaseAndOpenAlertsConfigEntry> resultConfigEntryList = null;  
        System.runAs(TEST_RUN_USER)
        {
            // Must not cast Open_Alert__c to SObject before sending to getConfig() method or method will fail.
            if (isObjectListForOpenAlerts) { resultConfigEntryList = ECICLinkCaseAndOpenAlertsConfigEntry.getConfigs(new List<Open_Alert__c> { dummyOpenAlert } ); }
            else                           { resultConfigEntryList = ECICLinkCaseAndOpenAlertsConfigEntry.getConfigs(new List<Case>          { dummyCase      } ); } 
        }

        SObject expectedObject   = (isObjectListForOpenAlerts)  ? (SObject) dummyOpenAlert    : (SObject) dummyCase;
        Id      expectedObjectId = (isObjectListForOpenAlerts)  ?           dummyOpenAlert.id :           dummyCase.id;

        if (!isObjectListForOpenAlerts || (isObjectListForOpenAlerts && hasFieldActive))
        {
            System.assertEquals (1, resultConfigEntryList.size());
            ECICLinkCaseAndOpenAlertsConfigEntry resultConfigEntry = resultConfigEntryList[0];
                                    System.assertEquals (expectedObject,    resultConfigEntry.obj);
                                    System.assertEquals (expectedObjectId,  resultConfigEntry.id);
                                    System.assert       (new Set<String>(resultConfigEntry.args).contains('Acceptable Daily Intake'));
        }
        else { System.assertEquals (0, resultConfigEntryList.size()); }
    }

    private static testMethod void openAlertsGetConfigsTest()       { getConfigsTest(true,  false); }
    //private static testMethod void activeOpenAlertsGetConfigsTest() { getConfigsTest(true,  true);  }
    private static testMethod void notOpenAlertsGetConfigsTest()    { getConfigsTest(false, false); }
    

}