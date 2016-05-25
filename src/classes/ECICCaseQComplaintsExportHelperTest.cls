@isTest
private class ECICCaseQComplaintsExportHelperTest  
{
    private static final User TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();
    
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
        
        ECICCaseQComplaintsExportHelper.CSVCaseFieldLists resultCaseFieldLists = null;
        System.runAs(TEST_RUN_USER) 
        {
            Test.startTest();
            {
                resultCaseFieldLists = ECICCaseQComplaintsExportHelper.buildSortedCaseFieldLists();
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

    
    // -----------------------------------------------------------------------------------------
    
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
                resultCaseFieldByRankMap = ECICCaseQComplaintsExportHelper.getCaseFieldByRankMap();
            }
            Test.stopTest();
        }
        
        System.assert (resultCaseFieldByRankMap.containsKey(dummyRank));
        System.assertEquals (dummyFieldName, resultCaseFieldByRankMap.get(dummyRank));
    }

    
    // -----------------------------------------------------------------------------------------
    
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
                dateResult     = ECICCaseQComplaintsExportHelper.formatDatetime (dummyCase, 'bbe_date__c');
                datetimeResult = ECICCaseQComplaintsExportHelper.formatDatetime (dummyCase, 'createdDate');
            }
            Test.stopTest();
        }

        System.assertEquals (dummyDatetime.format('dd/MM/yyyy HH:mm:ss', 'Europe/Paris'), datetimeResult); 
        System.assertEquals (((Datetime) dummyDate).format('dd/MM/yyyy', 'Europe/Paris'), dateResult); 
    }
}