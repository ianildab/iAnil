@isTest
private class ECICCaseExportQualityComplaintsSchedTest 
{
    private static final User TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();
    
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
                resultRecipientEmailByCountryCodeMap = ECICCaseExportQualityComplaintsSchedable.buildRecipientEmailByCountryCodeMap();
            }
            Test.stopTest();
        }
        
        System.assertEquals (hasExportRecipient ? dummyExportRecipient : null, resultRecipientEmailByCountryCodeMap.get(dummyCountryCode));
    }

    private static testMethod void noRecipientBuildRecipientEmailByCountryCodeMapTest()  { buildRecipientEmailByCountryCodeMapTest(false); }
    private static testMethod void hasRecipientBuildRecipientEmailByCountryCodeMapTest() { buildRecipientEmailByCountryCodeMapTest(true ); }
    
    // ---------------------------------------------------------------------------------------------------------------
    
    private static testMethod void getCaseFieldByRankMapTest() 
    {
        String  dummyFieldName = 'dummy_field__c';
    	Integer dummyRank      = 1;
        TEST_DummyQComplaintExportConfigFactory.create (new TEST_DummyQComplaintExportConfigFactory.Config(dummyRank, dummyFieldName), TEST_DummyInsertModeEnum.REAL);    	                                               
    	 
        Map<Integer, String> resultCaseFieldByRankMap = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCaseFieldByRankMap = ECICCaseExportQualityComplaintsSchedable.getCaseFieldByRankMap();
            }
            Test.stopTest();
        }
        
        System.assert (resultCaseFieldByRankMap.containsKey(dummyRank));
        System.assertEquals (dummyFieldName, resultCaseFieldByRankMap.get(dummyRank));
    }
    
    // ---------------------------------------------------------------------------------------------------------------
    
    private static testMethod void buildSortedCaseFieldListsTest() 
    {
        Map<Integer, String> dummyExportFieldByRankMap = new Map<Integer, String>
        {
        	1 => 'EXPORT_CODE',
        	2 => 'EXPORT_MOTIF_MAPPING',
        	3 => 'EXPORT_RED_FLAG',
        	4 => 'EXPORT_SENSITIVE_FLAG',
            5 => 'Non_Key_Field',
            6 => 'Duplicated_Field',
            7 => 'Duplicated_Field'
        };

        TEST_DummyQComplaintExportConfigFactory.createMap (dummyExportFieldByRankMap, TEST_DummyInsertModeEnum.REAL);                                                     
        
        ECICCaseExportQualityComplaintsSchedable.CSVCaseFieldLists resultCaseFieldLists = null;
        System.runAs(TEST_RUN_USER) 
        {
            Test.startTest();
            {
                resultCaseFieldLists = ECICCaseExportQualityComplaintsSchedable.buildSortedCaseFieldLists();
            }
            Test.stopTest();
        }
        
        List<String> resultQueryFieldList  = resultCaseFieldLists.queryFieldList;
        List<String> resultExportFieldList = resultCaseFieldLists.exportFieldList;

        System.assertEquals(dummyExportFieldByRankMap.get(1), resultExportFieldList[0]);
        System.assertEquals(dummyExportFieldByRankMap.get(2), resultExportFieldList[1]);
        System.assertEquals(dummyExportFieldByRankMap.get(3), resultExportFieldList[2]);
        System.assertEquals(dummyExportFieldByRankMap.get(4), resultExportFieldList[3]);
        System.assertEquals(dummyExportFieldByRankMap.get(5), resultExportFieldList[4]);
        System.assertEquals(dummyExportFieldByRankMap.get(6), resultExportFieldList[5]);
        System.assertEquals(dummyExportFieldByRankMap.get(7), resultExportFieldList[6]);

        System.assertEquals(dummyExportFieldByRankMap.get(5), resultQueryFieldList[0]);
        System.assertEquals(dummyExportFieldByRankMap.get(6), resultQueryFieldList[1]);
        System.assertEquals(dummyExportFieldByRankMap.get(7), resultQueryFieldList[2]);
    }
    
    // ---------------------------------------------------------------------------------------------------------------
    
    private static void getExportCodeTest(Boolean hasAccount, Boolean hasExternalId, Boolean isExternalIdUseable) 
            {
    	String  dummyCountryCode = ECICCommonConstants.COUNTRY_CODE_DEFAULT;
    	String  dummyExternalId  = '123456';
    	Account dummyAccount     = (hasAccount) ? createDummyAccount(hasExternalId, isExternalIdUseable, dummyCountryCode, dummyExternalId) : null;
    	
    	TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
    	                     caseConfig.countryCode = dummyCountryCode;
    	Case dummyCase = TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.NONE);
    	     dummyCase.account = dummyAccount;

        String resultExportCode = null;    	                                           
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultExportCode = ECICCaseExportQualityComplaintsSchedable.getExportCode (dummyCase);
            }
            Test.stopTest();
        }
        
        Boolean externalIdExpected = hasAccount && hasExternalId && isExternalIdUseable;
        String  expectedCode       = (hasAccount)
                                        ? ((externalIdExpected) ? dummyExternalId : dummyAccount.id)
                                        : null;
        
        System.assertEquals(expectedCode, resultExportCode);
    }

    private static testMethod void noAccountIdGetExportCodeTest()       { getExportCodeTest(false, false, false); } 
    private static testMethod void useAccountIdGetExportCodeTest()      { getExportCodeTest(true , false, false); } 
    private static testMethod void uselessExternalIdGetExportCodeTest() { getExportCodeTest(true , true , false); } 
    private static testMethod void useExternalIdGetExportCodeTest()     { getExportCodeTest(true , true , true);  } 
    
    // ---------------------------------------------------------------------------------------------------------------
    
    private static void getMotifMappingTest(Boolean hasCat4) 
    {
    	String dummyCat3 = ECICCommonConstants.CASE_CATEGORY_LEVEL_3_PACKAGE_QUALITY_FILL_LEVEL;
    	String dummyCat4 = (hasCat4) ? ECICCommonConstants.CASE_CATEGORY_LEVEL_4_PACKAGE_QUALITY_LABEL : null;

        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.categoryLevel3 = dummyCat3;
                             caseConfig.categoryLevel4 = dummyCat4;
        Case dummyCase = TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.NONE);

        String resultMotifMapping = null;                                                
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultMotifMapping = ECICCaseExportQualityComplaintsSchedable.getMotifMapping (dummyCase);
            }
            Test.stopTest();
        }

        System.assertEquals(dummyCat3 + '|' + dummyCat4, resultMotifMapping);
    }

    private static testMethod void noCat4GetMotifMappingTest()  { getMotifMappingTest(false); } 
    private static testMethod void hasCat4GetMotifMappingTest() { getMotifMappingTest(false); } 
    
    // ---------------------------------------------------------------------------------------------------------------

    private static void getPotentialRiskKeyTests (String riskLevel) 
    {
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.potentialRisk = riskLevel;
                             caseConfig.riskType      = 'Blackmail';
        Case dummyCase = TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.NONE);

        String resultRedFlag = null;                                                
        String resultSensitiveFlag = null;                                                
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultRedFlag = ECICCaseExportQualityComplaintsSchedable.getRedFlag (dummyCase);
                resultSensitiveFlag = ECICCaseExportQualityComplaintsSchedable.getSensitiveFlag (dummyCase);
            }
            Test.stopTest();
        }

        System.assertEquals ((riskLevel == 'High Risk')   ? '1' : '0', resultRedFlag); 
        System.assertEquals ((riskLevel == 'Medium Risk') ? '1' : '0', resultSensitiveFlag); 
    }

    private static testMethod void noRiskGetPotentialRiskKeyTests()       { getPotentialRiskKeyTests('No Risk'    ); } 
    private static testMethod void mediumRiskGetPotentialRiskKeyTests()   { getPotentialRiskKeyTests('Medium Risk'); } 
    private static testMethod void highRiskGetPotentialRiskKeyTests()     { getPotentialRiskKeyTests('High Risk'  ); } 
    
    // ---------------------------------------------------------------------------------------------------------------

    private static testMethod void transformTest() 
    {
        String  dummyCountryCode = ECICCommonConstants.COUNTRY_CODE_DEFAULT;
        String  dummyCat3        = ECICCommonConstants.CASE_CATEGORY_LEVEL_3_PACKAGE_QUALITY_FILL_LEVEL;
        String  dummyCat4        = ECICCommonConstants.CASE_CATEGORY_LEVEL_4_PACKAGE_QUALITY_LABEL;
        String  dummyExternalId  = '123456';
        Account dummyAccount     = createDummyAccount(true, true, dummyCountryCode, dummyExternalId);
        
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.categoryLevel3 = dummyCat3;
                             caseConfig.categoryLevel4 = dummyCat4;
                             caseConfig.potentialRisk  = 'High Risk';
                             caseConfig.riskType       = 'Blackmail';
                             caseConfig.priority       = 'High';
                             caseConfig.countryCode    = dummyCountryCode;
        Case dummyCase = TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.NONE);
             dummyCase.account = dummyAccount;

        String exportCodeResult         = null;
        String exportMotifMappingResult = null;
        String exportRedFlagResult      = null;
        String exportSensitiveFlagRsult = null;
        String otherResult              = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                exportCodeResult         = ECICCaseExportQualityComplaintsSchedable.transform (dummyCase, 'EXPORT_CODE');
                exportMotifMappingResult = ECICCaseExportQualityComplaintsSchedable.transform (dummyCase, 'EXPORT_MOTIF_MAPPING');
                exportRedFlagResult      = ECICCaseExportQualityComplaintsSchedable.transform (dummyCase, 'EXPORT_RED_FLAG');
                exportSensitiveFlagRsult = ECICCaseExportQualityComplaintsSchedable.transform (dummyCase, 'EXPORT_SENSITIVE_FLAG');
                otherResult              = ECICCaseExportQualityComplaintsSchedable.transform (dummyCase, 'Other');
    }
            Test.stopTest();
        }
        
        System.assertEquals (dummyExternalId, exportCodeResult); 
        System.assertEquals (dummyCat3 + '|' + dummyCat4,   exportMotifMappingResult); 
        System.assertEquals ('1',             exportRedFlagResult); 
        System.assertEquals ('0',             exportSensitiveFlagRsult); 
        System.assertEquals (null,            otherResult); 
    }

    // ---------------------------------------------------------------------------------------------------------------
    
    private static testMethod void removeFinalCharacterTest() 
    {
        String dummyString = 'dummy,';
        
        String result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = ECICCaseExportQualityComplaintsSchedable.removeFinalCharacter (dummyString);
            }
            Test.stopTest();
        }
        
        System.assertEquals('dummy', result);
    }

    // ---------------------------------------------------------------------------------------------------------------
    
    private static testMethod void formatDatetimeTests() 
    {
        Datetime dummyDatetime = System.now();
        Date     dummyDate     = System.today();

        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.createdDate = dummyDatetime;
                             caseConfig.bbeDate     = dummyDate;
        Case dummyCase = TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.NONE);
    	
        String dateResult = null;
        String datetimeResult = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                dateResult     = ECICCaseExportQualityComplaintsSchedable.formatDatetime (dummyCase, 'bbe_date__c');
                datetimeResult = ECICCaseExportQualityComplaintsSchedable.formatDatetime (dummyCase, 'createdDate');
            }
            Test.stopTest();
        }

        System.assertEquals (dummyDatetime.format('dd/MM/yyyy HH:mm:ss', 'Europe/Paris'), datetimeResult); 
        System.assertEquals (((Datetime) dummyDate).format('dd/MM/yyyy', 'Europe/Paris'), dateResult); 
    }

    // ---------------------------------------------------------------------------------------------------------------
    private static testMethod void transverseTests() 
    {
        Datetime dummyDatetime = System.now();
        Date     dummyDate     = System.today();

        TEST_DummyAccountFactory.Config accountConfig = new TEST_DummyAccountFactory.Config();
                                        accountConfig.externalId = 'FRCIC_123456';
        Account     dummyAccount = TEST_DummyAccountFactory.create(accountConfig, TEST_DummyInsertModeEnum.MOCK);

        TEST_DummyBeverageFactory.Config beverageConfig = new TEST_DummyBeverageFactory.Config();
                                        beverageConfig.brand = ECICCommonConstants.BEVERAGE_BRAND_DEFAULT;
        Beverage__c dummyBeverage = TEST_DummyBeverageFactory.create(beverageConfig, TEST_DummyInsertModeEnum.MOCK);
        
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.countryCode = ECICCommonConstants.COUNTRY_CODE_DEFAULT;
                             caseConfig.createdDate = dummyDatetime;
                             caseConfig.bbeDate     = dummyDate;
        Case dummyCase = TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.MOCK);
             dummyCase.account     = dummyAccount;
             dummyCase.beverage__r = dummyBeverage;

        String noObjectNativeStringFieldResult     = null;
        String noObjectNativeDatetimeFieldResult   = null;
        String noObjectCustomStringFieldResult     = null;
        String noObjectCustomDateFieldResult       = null;

        String nativeObjectNativeStringFieldResult = null;
        String nativeObjectCustomStringFieldResult = null;
        String customObjectNativeStringFieldResult = null;
        String customObjectCustomStringFieldResult = null;

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                noObjectNativeStringFieldResult         = ECICCaseExportQualityComplaintsSchedable.transverse (dummyCase, 'id');
                noObjectNativeDatetimeFieldResult       = ECICCaseExportQualityComplaintsSchedable.transverse (dummyCase, 'createdDate');
                noObjectCustomStringFieldResult         = ECICCaseExportQualityComplaintsSchedable.transverse (dummyCase, 'country_code__c');
                noObjectCustomDateFieldResult           = ECICCaseExportQualityComplaintsSchedable.transverse (dummyCase, 'bbe_date__c');

                nativeObjectNativeStringFieldResult     = ECICCaseExportQualityComplaintsSchedable.transverse (dummyCase, 'account.id');
                nativeObjectCustomStringFieldResult     = ECICCaseExportQualityComplaintsSchedable.transverse (dummyCase, 'account.account_ext_id__c');
                customObjectNativeStringFieldResult     = ECICCaseExportQualityComplaintsSchedable.transverse (dummyCase, 'beverage__r.id');
                customObjectCustomStringFieldResult     = ECICCaseExportQualityComplaintsSchedable.transverse (dummyCase, 'beverage__r.brand__c');
            }
            Test.stopTest();
        }
        
        System.assertEquals(dummyCase.id,                                                 noObjectNativeStringFieldResult);
        System.assertEquals (dummyDatetime.format('dd/MM/yyyy HH:mm:ss', 'Europe/Paris'), noObjectNativeDatetimeFieldResult); 
        System.assertEquals(dummyCase.country_code__c,                                    noObjectCustomStringFieldResult);
        System.assertEquals (((Datetime) dummyDate).format('dd/MM/yyyy', 'Europe/Paris'), noObjectCustomDateFieldResult); 

        System.assertEquals(dummyAccount.id,                                              nativeObjectNativeStringFieldResult);
        System.assertEquals(dummyAccount.account_ext_id__c,                               nativeObjectCustomStringFieldResult);
        System.assertEquals(dummyBeverage.id,                                             customObjectNativeStringFieldResult);
        System.assertEquals(dummyBeverage.brand__c,                                       customObjectCustomStringFieldResult);
    }

    // ---------------------------------------------------------------------------------------------------------------

    private static void createRowElementTest(Boolean requiresTransform) 
    {
    	String dummyValue = 'Medium Risk';
    	
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.potentialRisk = dummyValue;
                             caseConfig.riskType      = 'Blackmail';
        Case dummyCase = TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.NONE);

        String csvFieldName = (requiresTransform) ? 'EXPORT_SENSITIVE_FLAG' : 'potential_risk__c';

        String result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = ECICCaseExportQualityComplaintsSchedable.createRowElement (dummyCase, csvFieldName);
            }
            Test.stopTest();
        }
        
        String expectedValue = '"' + ((requiresTransform) ? '1' : '' + dummyValue) + '";';
        System.assertEquals(expectedValue, result);
    }

    private static testMethod void transformCreateRowElementTest()  { createRowElementTest(true); } 
    private static testMethod void transverseCreateRowElementTest() { createRowElementTest(false); }

    // ---------------------------------------------------------------------------------------------------------------
    
    private static testMethod void createRowStringTest() 
    {
        TEST_DummyQComplaintExportConfigFactory.create(new TEST_DummyQComplaintExportConfigFactory.Config(1, 'priority'), TEST_DummyInsertModeEnum.REAL);

        String dummyValue = 'High';
        
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.priority    = dummyValue;
        Case dummyCase = TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.NONE);

        String result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = ECICCaseExportQualityComplaintsSchedable.createRowString (dummyCase);
            }
            Test.stopTest();
        }
        
        String expectedValue = '"' + dummyValue + '"\n';
        System.assertEquals(expectedValue, result);
    }

    // ---------------------------------------------------------------------------------------------------------------
    
    private static testMethod void createDataBlobTest() 
    {
        TEST_DummyQComplaintExportConfigFactory.create(new TEST_DummyQComplaintExportConfigFactory.Config(1, 'priority'), TEST_DummyInsertModeEnum.REAL);

        String dummyValue = 'High';
        
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.priority    = dummyValue;
        Case dummyCase = TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.NONE);

        Blob result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = ECICCaseExportQualityComplaintsSchedable.createDataBlob (new List<Case>{dummyCase});
            }
            Test.stopTest();
        }
        
        Blob expectedValue = Blob.valueOf('"' + dummyValue + '"\n');
        System.assertEquals(expectedValue.toString(), result.toString());
    }

    private static testMethod void addDocumentToSaveTest() 
    {
    	Blob dummyBlob     = Blob.valueOf('Dummy Blob');
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICCaseExportQualityComplaintsSchedable.addDocumentToSave (dummyBlob);
            }
            Test.stopTest(); 
        }
    	
    	List<Document> resultDocumentList = ECICCaseExportQualityComplaintsSchedable.documentToSaveList;
    	System.assertEquals(1, resultDocumentList.size());
    	
    	Document resultDocument = resultDocumentList[0];
    	System.assertEquals('Export_' + ((Datetime) Date.today()).format('yyyy_MM_dd') + '.csv', resultDocument.name);
    	System.assertEquals(dummyBlob,                                                           resultDocument.body);
    	System.assertEquals('text/csv',					                                         resultDocument.contentType);
        System.assertEquals('txt',                                                               resultDocument.type);
    }

    // ---------------------------------------------------------------------------------------------------------------
    
    private static testMethod void createEmailTest() 
    {
        String dummyExportRecipient = 'dummy@complaint.example.com';
        String dummyValue           = 'High';

        TEST_DummyQComplaintExportConfigFactory.create(new TEST_DummyQComplaintExportConfigFactory.Config(1, 'priority'), TEST_DummyInsertModeEnum.REAL);
        
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.priority    = dummyValue;
        Case dummyCase = TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.NONE);

        Messaging.SingleEmailMessage resultEmail = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultEmail = ECICCaseExportQualityComplaintsSchedable.createEmail(dummyExportRecipient, new List<Case>{dummyCase});
            }
            Test.stopTest();
        }
        
        String[] resultToAddressArray = resultEmail.getToAddresses();
        System.assertEquals(dummyExportRecipient, resultToAddressArray[0]);
        
        Messaging.EmailFileAttachment[] resultAttachmentArray = resultEmail.getFileAttachments();
        Blob                            resultAttachmentBody  = resultAttachmentArray[0].getBody();

        Blob expectedValue = Blob.valueOf('"' + dummyValue + '"\n');
        System.assertEquals(expectedValue.toString(), resultAttachmentBody.toString());
    }
    
    // ---------------------------------------------------------------------------------------------------------------

    private static void sendQualityComplaintExportCsvTest(Boolean hasRecipient, Boolean hasCase)
    {
        Integer emailLimitBefore    = Limits.getEmailInvocations();
        Datetime dummyToDateTime    = System.today();

        String dummyExportRecipient = (hasRecipient) ? 'dummy@complaint.example.com' : null;
        String dummyCountryCode     = ECICCommonConstants.COUNTRY_CODE_DEFAULT;
        String dummyValue           = 'High';
                
        TEST_DummyCountrySpecificSettingsFactory.Config countrySpecificSettingConfig = new TEST_DummyCountrySpecificSettingsFactory.Config();
                                                        countrySpecificSettingConfig.countryCode = dummyCountryCode;
                                                        countrySpecificSettingConfig.qualityComplaintExportRecipients = dummyExportRecipient;
        TEST_DummyCountrySpecificSettingsFactory.create(countrySpecificSettingConfig, TEST_DummyInsertModeEnum.REAL);

        TEST_DummyQComplaintExportConfigFactory.create(new TEST_DummyQComplaintExportConfigFactory.Config(1, 'priority'), TEST_DummyInsertModeEnum.REAL);
        
        Case dummyCase = null;
        if (hasCase)
        {
            TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                                 caseConfig.countryCode = dummyCountryCode;
                                 caseConfig.priority    = dummyValue;
                                 caseConfig.createdDate = System.today().addDays(-2);
            dummyCase = TEST_DummyQualityComplaintCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.REAL);
        }
 
        Messaging.SingleEmailMessage resultEmail = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICCaseExportQualityComplaintsSchedable.sendQualityComplaintExportCSV(true);
            }
            Test.stopTest();    // Because this is a test, job *should* execute immediately after Test.stopTest().
        }
     
        System.assertEquals((hasRecipient), TEST_MockHelper.getMockBoolean('sendEmailResult[0]', 'isSuccess'));
    }

    private static testMethod void noRecipientSendQualityComplaintExportCsvTest() { sendQualityComplaintExportCsvTest(false, false); } 
    private static testMethod void noCaseSendQualityComplaintExportCsvTest()      { sendQualityComplaintExportCsvTest(true,  false); }
    private static testMethod void hasAllSendQualityComplaintExportCsvTest()      { sendQualityComplaintExportCsvTest(true,  true ); } 
    
    // TODO implement test(s) for sendQualityComplaintExportCSV(false); ... but this won't add coverage.

    // ---------------------------------------------------------------------------------------------------------------

    // @see http://www.salesforce.com/us/developer/docs/apex_workbook/Content/apex_scheduling_2.htm
    private static testMethod void executeTest() 
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
                String jobId = System.schedule('ECICCaseExportQualityComplaintsSchedable_TEST', cronExpression, new ECICCaseExportQualityComplaintsSchedable());  // Schedule the test job
            }
            Test.stopTest();    // Because this is a test, job *should* execute immediately after Test.stopTest().
        }
     
        System.assert(TEST_MockHelper.getMockBoolean('sendEmailResult[0]', 'isSuccess'));
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
}