@isTest
private class ECICOpenAlertCaseHelperTest 
{
    private static final User    TEST_RUN_USER  = TEST_DummyUserFactory.createDefaultTestRunUser();

    private static testMethod void createOpenAlertCaseTest()                
    {
        Case          dummyCase         = TEST_DummyFastQualityComplaintCaseFactry.create(TEST_DummyInsertModeEnum.MOCK);
        ECICLinkCaseAndOpenAlertsConfigEntry dummyCaseConfig  = ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyConfigEntry(dummyCase,      new List<String>());
        
        Open_Alert__c dummyOpenAlert        = TEST_DummyOpenAlertFactory.create(TEST_DummyInsertModeEnum.MOCK);
        ECICLinkCaseAndOpenAlertsConfigEntry dummyAlertConfig = ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyConfigEntry(dummyOpenAlert, new List<String>());

        Open_Alert_Case__c resultOpenAlertCase = null; 
        System.runAs(TEST_RUN_USER)
        {
            resultOpenAlertCase = ECICOpenAlertCaseHelper.createOpenAlertCase(dummyCaseConfig, dummyAlertConfig);
        }
        
        System.assertEquals(resultOpenAlertCase.case__c,       dummyCase.id);
        System.assertEquals(resultOpenAlertCase.case__r,       dummyCase);
        System.assertEquals(resultOpenAlertCase.open_alert__c, dummyOpenAlert.id);
        System.assertEquals(resultOpenAlertCase.open_alert__r, dummyOpenAlert);
        System.assertEquals(resultOpenAlertCase.name,          dummyOpenAlert.name + ' / ' + dummyCase.caseNumber);
    }

    // ----------------------------------------------------------------------------------------

}