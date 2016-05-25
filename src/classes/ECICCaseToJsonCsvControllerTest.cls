@isTest
private class ECICCaseToJsonCsvControllerTest
{
/*
     private static final User TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();
    private static final User DUMMY_AUTHOR  = [SELECT id, name FROM User WHERE id = :TEST_RUN_USER.id];

    private static testMethod void generateCSV() 
    {
        Case dummyCase = TEST_DummyInquiryCaseFactory.create(TEST_DummyInsertModeEnum.NONE);
        String  dummyCountryCode = ECICCommonConstants.COUNTRY_CODE_DEFAULT;
        String  dummyExternalId  = '123456';
        Account dummyAccount     = createDummyAccount(true, true, dummyCountryCode, dummyExternalId);
        
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {                
                dummyCase.AccountId = dummyAccount.Id;    
                ECICCaseToJsonCsvController eCICCaseToJsonCsvController = new ECICCaseToJsonCsvController();
                eCICCaseToJsonCsvController.testCase = dummyCase;
                string result = eCICCaseToJsonCsvController.getCsvExport();
                eCICCaseToJsonCsvController.getExportCode(dummyCase);
                eCICCaseToJsonCsvController.transform(dummyCase,'EXPORT_CODE');
                eCICCaseToJsonCsvController.transform(dummyCase,'EXPORT_MOTIF_MAPPING');
                eCICCaseToJsonCsvController.transform(dummyCase,'EXPORT_RED_FLAG');
                eCICCaseToJsonCsvController.transform(dummyCase,'EXPORT_SENSITIVE_FLAG');
                eCICCaseToJsonCsvController.transform(dummyCase,'EXPORT_CONTACT_CITY');
                eCICCaseToJsonCsvController.transverse(dummyCase,'account.id'); 
            }
            Test.stopTest();
        }         
    }
    
    
     private static Account createDummyAccount (Boolean hasExternalId, Boolean isExternalIdUseable, String dummyCountryCode, String dummyExternalId)
    {
        TEST_DummyAccountFactory.Config accountConfig = new TEST_DummyAccountFactory.Config();
                                        accountConfig.externalId = (hasExternalId)
                                                                       ? ((isExternalIdUseable) ? (dummyCountryCode + 'CIC' + '_' + dummyExternalId) : 'Useless')
                                                                       : null;
        return TEST_DummyAccountFactory.create(accountConfig, TEST_DummyInsertModeEnum.MOCK);
    }
    
    
    
    
    */
    
}