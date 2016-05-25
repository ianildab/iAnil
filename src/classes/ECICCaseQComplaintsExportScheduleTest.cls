@isTest 
private class ECICCaseQComplaintsExportScheduleTest 
{
/*
    private static final User TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();

    // @see http://www.salesforce.com/us/developer/docs/apex_workbook/Content/apex_scheduling_2.htm
    private static testMethod void schedulableExecuteTest() 
    {
        Integer emailLimitBefore    = Limits.getEmailInvocations();
        Datetime dummyToDateTime    = System.today();
        Datetime cronDateTime       = dummyToDateTime.addDays(1);
        String   cronExpression     = TEST_ScheduleHelper.convertDateTimeToCronExpression(cronDateTime); 

        String dummyExportRecipient = 'dummy@complaint.example.com';
        String dummyCountryCode     = ECICCommonConstants.COUNTRY_CODE_DEFAULT;
        String dummyValue           = 'High';
                
        TEST_DummyCountrySpecificSettingsFactory.Config countrySpecificSettingConfig = new TEST_DummyCountrySpecificSettingsFactory.Config();
                                                        countrySpecificSettingConfig.countryCode = dummyCountryCode;
                                                        countrySpecificSettingConfig.qualityComplaintExportRecipients = dummyExportRecipient;
        TEST_DummyCountrySpecificSettingsFactory.create(countrySpecificSettingConfig, TEST_DummyInsertModeEnum.REAL);

        TEST_DummyQComplaintExportConfigFactory.create(new TEST_DummyQComplaintExportConfigFactory.Config(1, 'priority'), TEST_DummyInsertModeEnum.REAL);
        
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.countryCode = dummyCountryCode;
                             caseConfig.priority    = dummyValue;
                             caseConfig.createdDate = System.today().addDays(-2);
        Case dummyCase = TEST_DummyQualityComplaintCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.REAL);
 
        Messaging.SingleEmailMessage resultEmail = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                String jobId = System.schedule('ECICCaseQComplaintsExportSchedule_TEST', cronExpression, new ECICCaseQComplaintsExportSchedule());  // Schedule the test job
            }
            Test.stopTest();    // Because this is a test, job *should* execute immediately after Test.stopTest().
        }
     
        
    }
    
    // ------------------------------------------------------------------------------------------------
    
    private static testMethod void execute2Test() 
    { 
        
        ECICCaseQComplaintsExportSchedule targetSchedulable = new ECICCaseQComplaintsExportSchedule();
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                targetSchedulable.execute(true);
            }
            Test.stopTest();
        }  
    }
    
    // ------------------------------------------------------------------------------------------------
    
    private static testMethod void futureCreateAndSendCsvExportTest() 
    { 
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICCaseQComplaintsExportSchedule.futureCreateAndSendCsvExport(true);
            }
            Test.stopTest();
        } 
        
    }
    
    // ------------------------------------------------------------------------------------------------
    
    private static testMethod void createAndSendCsvExportTest() 
    { 
       
        String dummyExportRecipient = 'dummy@complaint.example.com';
        String dummyCountryCode     = ECICCommonConstants.COUNTRY_CODE_DEFAULT;
        String dummyValue           = 'High';
                
        TEST_DummyCountrySpecificSettingsFactory.Config countrySpecificSettingConfig = new TEST_DummyCountrySpecificSettingsFactory.Config();
                                                        countrySpecificSettingConfig.countryCode = dummyCountryCode;
                                                        countrySpecificSettingConfig.qualityComplaintExportRecipients = dummyExportRecipient;
        TEST_DummyCountrySpecificSettingsFactory.create(countrySpecificSettingConfig, TEST_DummyInsertModeEnum.REAL);

        List<Case> dummyCaseList = TEST_DummyQualityComplaintCaseFactory.createList(1, new TEST_DummyCaseConfig(), TEST_DummyInsertModeEnum.REAL);
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICCaseQComplaintsExportSchedule.createAndSendCsvExport(true);
            }
            Test.stopTest();
        } 
        
    }
    
    // ------------------------------------------------------------------------------------------------
    
    private static void buildRecipientEmailByCountryCodeMapTest(Boolean hasExportRecipient) 
        {
        String dummyCountryCode     = ECICCommonConstants.COUNTRY_CODE_DEFAULT;
        String dummyExportRecipient = 'dummy@complaint.example.com';
                
        TEST_DummyCountrySpecificSettingsFactory.Config config = new TEST_DummyCountrySpecificSettingsFactory.Config();
                                                        config.countryCode = dummyCountryCode;
                                                        config.qualityComplaintExportRecipients = (hasExportRecipient) ? dummyExportRecipient : TEST_ConfigHelper.INTENTIONAL_NULL;
        TEST_DummyCountrySpecificSettingsFactory.create(config, TEST_DummyInsertModeEnum.REAL);
        
        Map<String, String> resultRecipientEmailByCountryCodeMap = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultRecipientEmailByCountryCodeMap = ECICCaseQComplaintsExportSchedule.buildRecipientEmailByCountryCodeMap();
            }
            Test.stopTest();
        }
        
        System.assertEquals (hasExportRecipient ? dummyExportRecipient : null, resultRecipientEmailByCountryCodeMap.get(dummyCountryCode));
    }

    private static testMethod void noRecipientBuildRecipientEmailByCountryCodeMapTest()  { buildRecipientEmailByCountryCodeMapTest(false); }
    private static testMethod void hasRecipientBuildRecipientEmailByCountryCodeMapTest() { buildRecipientEmailByCountryCodeMapTest(true ); }
    // ------------------------------------------------------------------------------------------------
    
    private static testMethod void frAddEmptyCaseListsTest() 
    { 
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.countryCode = 'FR';
        List<Case> dummyCaseList = TEST_DummyQualityComplaintCaseFactory.createList(1, config, TEST_DummyInsertModeEnum.MOCK);

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICCaseQComplaintsExportSchedule.addEmptyCaseLists(new Set<String>{'FR'}, new Map<String, List<Case>>{ 'FR'=> dummyCaseList});
            }
            Test.stopTest();
        } 
       
    }
    
    private static testMethod void d0AddEmptyCaseListsTest() 
    { 
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.countryCode = 'D0';
        List<Case> dummyCaseList = TEST_DummyQualityComplaintCaseFactory.createList(1, config, TEST_DummyInsertModeEnum.MOCK);

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICCaseQComplaintsExportSchedule.addEmptyCaseLists(new Set<String>{'FR'}, new Map<String, List<Case>>{ 'FR'=> dummyCaseList});
            }
            Test.stopTest();
        } 
        
    }
    
    // ------------------------------------------------------------------------------------------------
    
    private static testMethod void createEmailTest() 
    { 
    
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICCaseQComplaintsExportSchedule.createEmail('dummyRecipient@example.com', Blob.valueOf('Dummy Country Cases CSV'));
            }
            Test.stopTest();
        } 
       
    }
    
    // ------------------------------------------------------------------------------------------------
    
    private static testMethod void addDocumentToSaveTest() 
    {
        Blob dummyBlob     = Blob.valueOf('Dummy Blob');
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICCaseQComplaintsExportSchedule.addDocumentToSave (dummyBlob);
            }
            Test.stopTest(); 
        }
        
        List<Document> resultDocumentList = ECICCaseQComplaintsExportSchedule.documentToSaveList;
        System.assertEquals(1, resultDocumentList.size());
        
        Document resultDocument = resultDocumentList[0];
        System.assertEquals('Export_' + ((Datetime) Date.today()).format('yyyy_MM_dd') + '.csv', resultDocument.name);
        System.assertEquals(dummyBlob,                                                           resultDocument.body);
        System.assertEquals('text/csv',                                                          resultDocument.contentType);
        System.assertEquals('txt',                                                               resultDocument.type);
    }
    
    // ------------------------------------------------------------------------------------------------
    
    private static testMethod void convertCasestoCsvTest() 
    { 
        
        List<Case> dummyCaseList = TEST_DummyQualityComplaintCaseFactory.createList(1, new TEST_DummyCaseConfig(), TEST_DummyInsertModeEnum.MOCK);

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICCaseQComplaintsExportSchedule.convertCasestoCsv(new Map<String, List<Case>>{ 'FR'=> dummyCaseList}); 
            }
            Test.stopTest();
        } 
        
    }
    
    // ------------------------------------------------------------------------------------------------
    
    private static testMethod void getPageContentTest() 
    { 
       
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICCaseQComplaintsExportSchedule.getPageContent('Dummy Post Content');
            }
            Test.stopTest();
        } 
        
    }
    
    // ------------------------------------------------------------------------------------------------
    
    private static testMethod void createRequestTest() 
    { 
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICCaseQComplaintsExportSchedule.createRequest('Dummy Post Content');
            }
            Test.stopTest();
        } 
    }
    
    // ------------------------------------------------------------------------------------------------
    
    private static testMethod void setLegacyInfo3Test() 
    { 
        
        List<Case> dummyCaseList = TEST_DummyQualityComplaintCaseFactory.createList(1, new TEST_DummyCaseConfig(), TEST_DummyInsertModeEnum.MOCK);

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICCaseQComplaintsExportSchedule.setLegacyInfo3(new Map<String, List<Case>>{ 'FR'=> dummyCaseList});
            }
            Test.stopTest();
        } 
        
    }
    
    // ---------------------------------------------------------------------------------------------------------------
        
    private static Account createDummyAccount (Boolean hasExternalId, Boolean isExternalIdUseable, String dummyCountryCode, String dummyExternalId)
    {
        TEST_DummyAccountFactory.Config accountConfig = new TEST_DummyAccountFactory.Config();
                                        accountConfig.externalId = (hasExternalId)
                                                                       ? ((isExternalIdUseable) ? (dummyCountryCode + 'CIC' + '_' + dummyExternalId) : 'Useless')
                                                                       : null;
        return TEST_DummyAccountFactory.create(accountConfig, TEST_DummyInsertModeEnum.MOCK);
    }

    private static String createCategorizationKey (String catLevel3, String catLevel4) { return catLevel3 + '###' + catLevel4; }

    private static void assertCategorization(String cat3, String cat4, String code, Map<String, String> resultCaseCategorizationByKeyMap)
    {
        String key = createCategorizationKey(cat3, cat4);
        System.assert (resultCaseCategorizationByKeyMap.containsKey(key));
        System.assertEquals (code, resultCaseCategorizationByKeyMap.get(key));
    }  
    */ 
}