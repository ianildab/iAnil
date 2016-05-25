@isTest
public class ECICOpenAlertCaseUpdateBatchableTest 
{
    private static final User   TEST_RUN_USER               = TEST_DummyUserFactory.createDefaultTestRunUser();
    private static final String DUMMY_OPEN_ALERT_CASE_NAME  = 'Dummy Open Alert Case Name';
    private static final Id     DUMMY_OPEN_ALERT_ID         = TEST_DummyOpenAlertFactory.getDefaultOpenAlertId(TEST_DummyInsertModeEnum.MOCK); 
    private static final Id     DUMMY_CASE_ID               = TEST_DummyGenericCaseFactory.getDefaultCaseId(TEST_DummyInsertModeEnum.MOCK); 

    private static void transcribeOpenAlertCaseTest(Boolean hasName, Boolean isUpdate)
    {
    	Open_Alert_Case_Update_Holder__c dummyUpdateHolder  = createOpenAlertCaseUpsertHolder(hasName);
    	Open_Alert_Case__c               dummyOpenAlertCase = (isUpdate) ? TEST_DummyOpenAlertCaseFactory.create(TEST_DummyInsertModeEnum.Mock) : new Open_Alert_Case__c(); 
    	
        Open_Alert_Case__c resultOpenAlertCase = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultOpenAlertCase = ECICOpenAlertCaseUpdateBatchable.transcribeOpenAlertCase (dummyUpdateHolder, dummyOpenAlertCase, isUpdate);
            }
            Test.stopTest();
        } 
        
        assertOpenAlertCase(resultOpenAlertCase, null, null, null, hasName);
    }  

    private static testMethod void namelessInsertTranscribeOpenAlertCaseTest() { transcribeOpenAlertCaseTest(false, false); }
    private static testMethod void nameedInsertTranscribeOpenAlertCaseTest()   { transcribeOpenAlertCaseTest(true , false); }
    private static testMethod void namelessUpdateTranscribeOpenAlertCaseTest() { transcribeOpenAlertCaseTest(false, true ); }
    private static testMethod void nameedUpdateTranscribeOpenAlertCaseTest()   { transcribeOpenAlertCaseTest(true , true ); }

    // ------------------------------------------------------------------------------------------------------------

    private static void prepareOpenAlertCaseListTest(Boolean hasUpdateMap)
    {
	    Open_Alert_Case__c                     dummyOpenAlertCase                = null;
        Map<Id, Open_Alert_Case__c>            dummyOpenAlertCaseToUpdateByIdMap = null;
        if (hasUpdateMap)
        {
            dummyOpenAlertCase                  = TEST_DummyOpenAlertCaseFactory.create(TEST_DummyInsertModeEnum.MOCK);	
            dummyOpenAlertCaseToUpdateByIdMap   = new Map<Id, Open_Alert_Case__c>{ dummyOpenAlertCase.id => dummyOpenAlertCase };
        }

        Open_Alert_Case_Update_Holder__c       dummyUpdateHolder = (dummyOpenAlertCase != null) ? createOpenAlertCaseUpsertHolder(dummyOpenAlertCase.id) : createOpenAlertCaseUpsertHolder();
        List<Open_Alert_Case_Update_Holder__c> dummyHolderList   = new List<Open_Alert_Case_Update_Holder__c>{ dummyUpdateHolder };
        
        List<Open_Alert_Case__c> resultOpenAlertCaseList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultOpenAlertCaseList = ECICOpenAlertCaseUpdateBatchable.prepareOpenAlertCaseList(dummyHolderList, dummyOpenAlertCaseToUpdateByIdMap); 
            }
            Test.stopTest();
        } 
        
        System.assertEquals (1, resultOpenAlertCaseList.size());
        Open_Alert_Case__c resultOpenAlertCase = resultOpenAlertCaseList[0];
        assertOpenAlertCase(resultOpenAlertCase, (hasUpdateMap) ? dummyOpenAlertCase.id : null);
    }  

    private static testMethod void insertPrepareOpenAlertCaseListTest() { prepareOpenAlertCaseListTest(false); }
    private static testMethod void updatePrepareOpenAlertCaseListTest() { prepareOpenAlertCaseListTest(true);  }
    
    // ------------------------------------------------------------------------------------------------------------
      
    private static testMethod void prepareOpenAlertCaseInsertListTest()
    {
        List<Open_Alert_Case_Update_Holder__c> dummyHolderList = new List<Open_Alert_Case_Update_Holder__c>{ createOpenAlertCaseUpsertHolder() };
        
        List<Open_Alert_Case__c> resultOpenAlertCaseList = null;
        System.runAs(TEST_RUN_USER)
            {
            Test.startTest();
            {
                resultOpenAlertCaseList = ECICOpenAlertCaseUpdateBatchable.prepareOpenAlertCaseInsertList(dummyHolderList); 
        } 
            Test.stopTest();
        }
        
        System.assertEquals (1, resultOpenAlertCaseList.size());
        assertOpenAlertCase(resultOpenAlertCaseList[0]);
    }  

    // ------------------------------------------------------------------------------------------------------------
      
    private static testMethod void prepareOpenAlertCaseUpdateListTest()
    {
        Open_Alert_Case__c                     dummyOpenAlertCase                    = TEST_DummyOpenAlertCaseFactory.create(TEST_DummyInsertModeEnum.REAL);
        Set<Id>                                dummyUpdateRequiredOpenAlertCaseIdSet = new Set<Id>{ dummyOpenAlertCase.id };

        Open_Alert_Case_Update_Holder__c       dummyUpdateHolder                    = createOpenAlertCaseUpsertHolder(dummyOpenAlertCase.id);
        List<Open_Alert_Case_Update_Holder__c> dummyHolderList                      = new List<Open_Alert_Case_Update_Holder__c>{ dummyUpdateHolder };
        
        List<Open_Alert_Case__c> resultOpenAlertCaseList = null;
        System.runAs(TEST_RUN_USER)
            {
            Test.startTest();
            {
                resultOpenAlertCaseList = ECICOpenAlertCaseUpdateBatchable.prepareOpenAlertCaseUpdateList(dummyUpdateRequiredOpenAlertCaseIdSet, dummyHolderList);
        } 
            Test.stopTest();
        } 

        System.assertEquals (1, resultOpenAlertCaseList.size());
        Open_Alert_Case__c resultOpenAlertCase = resultOpenAlertCaseList[0];
        assertOpenAlertCase(resultOpenAlertCase, dummyOpenAlertCase.id);
    }  
    
    // ------------------------------------------------------------------------------------------------------------

    private static testMethod void prepareOpenAlertConfigEntryListTest()
    {
        Open_Alert__c dummyOpenAlert = TEST_DummyOpenAlertFactory.create (TEST_DummyInsertModeEnum.REAL); 
        ECICOpenAlertCaseUpdateBatchable.openAlertToNotifyByIdMap = new Map<Id, Open_Alert__c>{ dummyOpenAlert.id => dummyOpenAlert };
        
        List<ECICLinkCaseAndOpenAlertsConfigEntry> resultOpenAlertConfigEntryList = null;
        System.runAs(TEST_RUN_USER)
            {
            Test.startTest();
            {
                resultOpenAlertConfigEntryList = ECICOpenAlertCaseUpdateBatchable.prepareOpenAlertConfigEntryList ();
        } 
            Test.stopTest();
    }  

        System.assertEquals (1, resultOpenAlertConfigEntryList.size());
        ECICLinkCaseAndOpenAlertsConfigEntry    resultOpenAlertConfigEntry = resultOpenAlertConfigEntryList[0];
        System.assertEquals (dummyOpenAlert.id, resultOpenAlertConfigEntry.id);
        System.assertEquals (dummyOpenAlert.threshold__c,       resultOpenAlertConfigEntry.obj.get('threshold__c'));
    }  

    // ------------------------------------------------------------------------------------------------------------
      
    private static void executeTest(String testType, Boolean isBatchableTest)
    {
    	System.runAs(TEST_RUN_USER) // Attempted workaround for MIXED_DML_OPERATION
        {
    	    ECICLinkCaseAndOpenAlertsEmailHelperTest.setOpenAlertEmailTemplate();
        }
    	
        Boolean isInsertTest = (testType == 'insert');
        Boolean isUpdateTest = (testType == 'update');
        Boolean isDeleteTest = (testType == 'delete');

        TEST_DummyOpenAlertFactory.Config openAlertConfig = new TEST_DummyOpenAlertFactory.Config();
                                          openAlertConfig.additionalTo = 'dummy_email@test.example.com';
                                          openAlertConfig.recipients   = 'Quality_Manager__c';
                                          openAlertConfig.threshold    = 1;
        Open_Alert__c dummyOpenAlert   = TEST_DummyOpenAlertFactory.create(openAlertConfig, TEST_DummyInsertModeEnum.REAL);
        Id            dummyOpenAlertId = dummyOpenAlert.id;
        TEST_MockHelper.setMockInteger(dummyOpenAlert, 'case_count__c', 2);        

        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.qualityManagerUserId = TEST_RUN_USER.id;
        Id            dummyCaseId      = TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.REAL).id;

        Open_Alert_Case__c                dummyOpenAlertCase = (!isInsertTest) 
                                                                ? TEST_DummyOpenAlertCaseFactory.create(new TEST_DummyOpenAlertCaseFactory.Config(dummyCaseId, dummyOpenAlertId), TEST_DummyInsertModeEnum.REAL) 
                                                                : null;

        Open_Alert_Case_Update_Holder__c  dummyUpdateHolder  = createOpenAlertCaseHolder(
                                                                                            true, 
                                                                                            ((dummyOpenAlertCase != null) ? dummyOpenAlertCase.id : null), 
                                                                                            dummyOpenAlertId, 
                                                                                            dummyCaseId, 
                                                                                            ((isDeleteTest) ? 'Delete' : 'Upsert'),
                                                                                            TEST_DummyInsertModeEnum.REAL
                                                                                        );
                                                               
    	
        TEST_MockHelper.setMockBoolean('sendEmailResult[0]', 'isSuccess', false);
        ECICOpenAlertCaseUpdateBatchable updateBatchable = (isBatchableTest) ? new ECICOpenAlertCaseUpdateBatchable() : null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                if (isBatchableTest) { Database.executeBatch(updateBatchable);                                                                    }            
                else                 { ECICOpenAlertCaseUpdateBatchable.execute(new List<Open_Alert_Case_Update_Holder__c>{ dummyUpdateHolder }); }
                  
            }
            Test.stopTest();
        } 
        
        List<Open_Alert_Case__c> resultOpenAlertCaseList = [
                                                                SELECT id, name, open_alert__c, case__c, createdById, lastModifiedById 
                                                                FROM Open_Alert_Case__c 
                                                                WHERE name = :DUMMY_OPEN_ALERT_CASE_NAME
                                                           ];

        System.assertEquals((!isDeleteTest) ? 1 : 0, resultOpenAlertCaseList.size()); 
        if (!isDeleteTest)
        {                                                                  
            Open_Alert_Case__c resultOpenAlertCase = resultOpenAlertCaseList[0];
            assertOpenAlertCase(resultOpenAlertCase, ((isUpdateTest) ? dummyOpenAlertCase.id : null), dummyOpenAlertId, dummyCaseId, true);
            System.assert(TEST_MockHelper.getMockBoolean('sendEmailResult[0]', 'isSuccess'));
        }
        
        List<Open_Alert_Case_Update_Holder__c> resultOpenAlertCaseUpdateHolderList = [ SELECT id FROM Open_Alert_Case_Update_Holder__c WHERE id = :dummyUpdateHolder.id];
        System.assertEquals(0, resultOpenAlertCaseUpdateHolderList.size());                                                           
    }  

    private static testMethod void insertExecuteTest()          { executeTest('insert', false); }
    private static testMethod void updateExecuteTest()          { executeTest('update', false); }
    private static testMethod void deleteExecuteTest()          { executeTest('delete', false); }
    private static testMethod void insertBatchableExecuteTest() { executeTest('insert', true); }
    private static testMethod void updateBatchableExecuteTest() { executeTest('update', true); }
    private static testMethod void deleteBatchableExecuteTest() { executeTest('delete', true); }
    
    // ------------------------------------------------------------------------------------------------------------

    private static Open_Alert_Case_Update_Holder__c createOpenAlertCaseHolder(Boolean hasName, Id dummyOpenAlertCaseId, Id dummyOpenAlertId, Id dummyCaseId, String type, TEST_DummyInsertModeEnum insertMode)
    {
        TEST_DummyOpenAlertCaseUpdateHoldrFactry.Config config = new TEST_DummyOpenAlertCaseUpdateHoldrFactry.Config();
                                                        config.openAlertCaseName    = (hasName)                      ? DUMMY_OPEN_ALERT_CASE_NAME : TEST_ConfigHelper.INTENTIONAL_NULL;
                                                        config.openAlertCaseId      = (dummyOpenAlertCaseId != null) ? dummyOpenAlertCaseId       : TEST_ConfigHelper.INTENTIONAL_NULL;             
                                                        config.openAlertId          = (dummyOpenAlertId     != null) ? dummyOpenAlertId           : DUMMY_OPEN_ALERT_ID;
                                                        config.caseId               = (dummyCaseId          != null) ? dummyCaseId                : DUMMY_CASE_ID;
                                                        config.type                 = type;
                                                        config.requiresEmail        = true;
        return TEST_DummyOpenAlertCaseUpdateHoldrFactry.create(config, insertMode); 
    }
    
    private static Open_Alert_Case_Update_Holder__c createOpenAlertCaseUpsertHolder()
    {
        return createOpenAlertCaseHolder(true, null, null, null, 'Upsert', TEST_DummyInsertModeEnum.NONE); 
    }
    
    private static Open_Alert_Case_Update_Holder__c createOpenAlertCaseUpsertHolder(Boolean hasName)
    {
        return createOpenAlertCaseHolder(hasName, null, null, null, 'Upsert', TEST_DummyInsertModeEnum.NONE); 
    }

    private static Open_Alert_Case_Update_Holder__c createOpenAlertCaseUpsertHolder(Id dummyOpenAlertCaseId)
    {
        return createOpenAlertCaseHolder(true, dummyOpenAlertCaseId, null, null, 'Upsert', TEST_DummyInsertModeEnum.NONE); 
    }

    // ------------------------------------------------------------------------------------------------------------
    
    private static void assertOpenAlertCase(Open_Alert_Case__c resultOpenAlertCase, Id dummyOpenAlertCaseId, Id dummyOpenAlertId, Id dummyCaseId, Boolean hasName)
    {
        if (hasName)                        { System.assertEquals (DUMMY_OPEN_ALERT_CASE_NAME, resultOpenAlertCase.name); }

        if (dummyOpenAlertCaseId != null) { System.assertEquals (dummyOpenAlertCaseId,          resultOpenAlertCase.id);                    }
        else
        {
            System.assertEquals ((dummyOpenAlertId != null) ? dummyOpenAlertId : DUMMY_OPEN_ALERT_ID,           resultOpenAlertCase.open_alert__c);
            System.assertEquals ((dummyCaseId != null)      ? dummyCaseId      : DUMMY_CASE_ID,                 resultOpenAlertCase.case__c);
        }
    }

    private static void assertOpenAlertCase(Open_Alert_Case__c resultOpenAlertCase, Id dummyOpenAlertCaseId)    { assertOpenAlertCase(resultOpenAlertCase, dummyOpenAlertCaseId, null, null, true); }
    private static void assertOpenAlertCase(Open_Alert_Case__c resultOpenAlertCase)                             { assertOpenAlertCase(resultOpenAlertCase, null,                 null, null, true); }
    
}