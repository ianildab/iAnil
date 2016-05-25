@isTest
private class ECICTaskTriggerHandlerTest 
{
    private static final User                   TEST_RUN_USER  = TEST_DummyUserFactory.createDefaultTestRunUser();  
    private static final ECICTaskTriggerHandler TARGET_HANDLER = new ECICTaskTriggerHandler(false);

    private static Id dummyActionPlanItemId = null;

    private static void constructorTest(Boolean isTriggerExecuting)
    {
        ECICTaskTriggerHandler resultHandler = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultHandler = new ECICTaskTriggerHandler(isTriggerExecuting);
            }
            Test.stopTest();
        }
        
        System.assertEquals (isTriggerExecuting, resultHandler.isTriggerExecuting);
    }
    
    private static testMethod void notExecutingConstructorTest() { constructorTest(false); }
    private static testMethod void executingConstructorTest()    { constructorTest(true);  }

    // -------------------------------------------------------------------------------------------------------------
    
    private static void filterManuallyAddedTasksTest(Boolean hasTemplateId)
    {
    	Task dummyTask = createTask (null, null, hasTemplateId, false);

        List<Task> resultTaskList = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                 resultTaskList = TARGET_HANDLER.filterManuallyAddedTasks(new Task[] { dummyTask} ) ;
            }
            Test.stopTest();
        }
        
        System.assertEquals((hasTemplateId) ? 0 : 1, resultTaskList.size());
        if (!hasTemplateId) { System.assertEquals (dummyTask, resultTaskList[0]); }
    }

    private static testMethod void nullTemplateIdFilterManuallyAddedTasksTest() { filterManuallyAddedTasksTest(false); }
    private static testMethod void hasTemplateIdFilterManuallyAddedTasksTest()  { filterManuallyAddedTasksTest(true);  }

    // -------------------------------------------------------------------------------------------------------------

    private static testMethod void buildCaseTaskOwnerIdSetTest()
    {
        Id   dummyOwnerId = TEST_RUN_USER.id;
        Task dummyTask    = createTask (dummyOwnerId);

        Set<Id> resultCaseTaskOwnerIdSet = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCaseTaskOwnerIdSet = TARGET_HANDLER.buildCaseTaskOwnerIdSet (new List<Task>{ dummyTask });
            }
            Test.stopTest();
        }
        
        System.assert (resultCaseTaskOwnerIdSet.contains(dummyOwnerId));
    }

    // -------------------------------------------------------------------------------------------------------------

    private static void updateCaseTaskTypeTest(Boolean hasOwner, String profileName)
    {
    	User dummyCaseTaskOwnerUser = (hasOwner) ? createTaskOwnerUser(profileName) : null;
        Task dummyTask              = createTask ((dummyCaseTaskOwnerUser != null) ? dummyCaseTaskOwnerUser.id : null);
    	
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_HANDLER.updateCaseTaskType(dummyTask, dummyCaseTaskOwnerUser);
            }
            Test.stopTest();
        }

        String expectedTaskType = (hasOwner)
                                    ?
                                      (
                                        (ECICTaskTriggerHandler.TASK_TYPE_BY_PROFILE_NAME_MAPPING.containsKey(profileName))
                                            ? ECICTaskTriggerHandler.TASK_TYPE_BY_PROFILE_NAME_MAPPING.get(profileName)
                                            : ''
                                      )
                                    : null;

        System.assertEquals(expectedTaskType, dummyTask.task_type__c);
    }
// # Ecic Template Test
    private static testMethod void PROFILE_ECIC_INFOLINE_AGENTUpdateCaseTaskTypeTest()      { updateCaseTaskTypeTest(true,  ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT);      }
    private static testMethod void PROFILE_ECIC_INFOLINE_SUPERVISORUpdateCaseTaskTypeTest() { updateCaseTaskTypeTest(true,  ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_SUPERVISOR); }
    private static testMethod void PROFILE_ECIC_COCA_COLA_QUALITYUpdateCaseTaskTypeTest()   { updateCaseTaskTypeTest(true,  ECICCommonConstants.PROFILE_ECIC_IBERIA_COCA_COLA_QUALITY);   }
    private static testMethod void PROFILE_ECIC_BOTTLER_QUALITYUpdateCaseTaskTypeTest()     { updateCaseTaskTypeTest(true,  ECICCommonConstants.PROFILE_ECIC_IBERIA_BOTTLER_QUALITY);     }
    private static testMethod void PROFILE_ECIC_EXTERNAL_RELATIONSUpdateCaseTaskTypeTest()  { updateCaseTaskTypeTest(true,  ECICCommonConstants.PROFILE_ECIC_IBERIA_EXTERNAL_RELATIONS);  }
    private static testMethod void PROFILE_CRM_DATA_LOADERUpdateCaseTaskTypeTest()          { updateCaseTaskTypeTest(true,  ECICCommonConstants.PROFILE_CRM_DATA_LOADER);          }
    private static testMethod void noOwnerUpdateCaseTaskTypeTest()                          { updateCaseTaskTypeTest(false, null);                                                 }

    // -------------------------------------------------------------------------------------------------------------

    private static testMethod void updateCaseTasksTypeTest()
    {
        User dummyCaseTaskOwnerUser = createTaskOwnerUser(ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT, true);
        Task dummyTask              = createTask (dummyCaseTaskOwnerUser.id);
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_HANDLER.updateCaseTasksType(new Task[] { dummyTask });
            }
            Test.stopTest();
        }
        
        System.assertEquals('CIC', dummyTask.task_type__c);
    }
    
    // -------------------------------------------------------------------------------------------------------------

    private static void processBeforeTest(Boolean hasTask)
    {
    	Case   dummyCase = TEST_DummyInquiryCaseFactory.create(TEST_DummyInsertModeEnum.REAL);
    	
    	Task   dummyNewTask      = null;
    	Task[] dummyNewTaskArray = null;
    	if (hasTask)
    	{
            User dummyCaseTaskOwnerUser = createTaskOwnerUser(ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT, true); //#Ecic Teamplate Test 
                 dummyNewTask           = createTask (dummyCaseTaskOwnerUser.id, dummyCase.Id);
                 dummyNewTaskArray      = new Task[] { dummyNewTask };
    	}
    	

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_HANDLER.processBefore(dummyNewTaskArray, null);  // As we've already tested ECICCaseTaskProcessorAbstract.iterateOnCaseTasks(), we should be able to disregard the potential impact of oldTasks here.
            }
            Test.stopTest();
        }

        if (hasTask) { System.assertEquals('CIC', dummyNewTask.task_type__c); }
        // else nothing to assert.
    }
    
    private static testMethod void hasTaskProcessBeforeTest() { processBeforeTest(true);  }
    private static testMethod void noTaskProcessBeforeTest()  { processBeforeTest(false); }

    // -------------------------------------------------------------------------------------------------------------
    
    private static void onBeforeMethodTest(Boolean isInsertTest)
    {
    	Boolean        isUpdateTest = !isInsertTest;
    	
        User           dummyCaseTaskOwnerUser = createTaskOwnerUser(ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT, true); //#Ecic Teamplate Test 
        Case           dummyCase              = TEST_DummyInquiryCaseFactory.create(TEST_DummyInsertModeEnum.REAL);
        Task           dummyNewTask           = createTask (dummyCaseTaskOwnerUser.id, dummyCase.Id);
        List<Task>     dummyNewTaskList       = new List<Task>{ dummyNewTask };
        
        Map<Id, Task> dummyOldTaskByIdMap     = null;
        if (isUpdateTest)
        {
            Task dummyOldTask = dummyNewTask.clone(false);
                 dummyOldTask.ownerId = TEST_RUN_USER.id;
            
            TEST_MockHelper.mockInsert(dummyOldTask);
            dummyOldTaskByIdMap = new Map<Id, Task>{ dummyOldTask.id => dummyOldTask};
            dummyNewTask.id = dummyOldTask.id;
        }

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                if   (isInsertTest)         { TARGET_HANDLER.onBeforeInsert(dummyNewTaskList);  }
                else /* is Update Test */   { TARGET_HANDLER.onBeforeUpdate(null, dummyNewTaskList, null, dummyOldTaskByIdMap); }  // dummyOldTaskList and dummyNewTaskByIdMap are not used so nulls will be ignored.
            }
            Test.stopTest();
        }

        System.assertEquals('CIC', dummyNewTask.task_type__c);
    }

    private static testMethod void onBeforeInsertTest() { onBeforeMethodTest(true);  }
    private static testMethod void onBeforeUpdateTest() { onBeforeMethodTest(false); }
    
    // -------------------------------------------------------------------------------------------------------------

    private static void updateNextOpenTaskReponsible2Test(Boolean isCaseInNextTaskMap, Boolean isQualityComplaint)
    {
    	User dummyCaseTaskOwnerUser = createTaskOwnerUser(ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT);//#Ecic Teamplate Test 
    	
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
    	                     caseConfig.recordTypeId          = (isQualityComplaint) 
		    	                                                   ? TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME)
		    	                                                   :TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(ECICCommonConstants.INQUIRY_IBERIA_DEVNAME);
    	                     caseConfig.ownerUserId           = TEST_RUN_USER.id;
    	                     caseConfig.noQualityStatusChange = false;
        Case          dummyCase                      = TEST_DummyGenericCaseFactory.create (caseConfig, TEST_DummyInsertModeEnum.NONE);
        
        Map<Id, Task> dummyNextOpenTaskByCaseIdMap   = new Map<Id, Task>();
        if (isCaseInNextTaskMap)
        {
            Task      dummyNextTask                  = createTask (dummyCaseTaskOwnerUser.id);
                      dummyNextOpenTaskByCaseIdMap.put (dummyCase.id, dummyNextTask);
        }
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICTaskTriggerHandler.updateNextOpenTaskReponsible(dummyCase, dummyNextOpenTaskByCaseIdMap);
            }
            Test.stopTest();
        }
        
        System.assertEquals((isCaseInNextTaskMap) ? dummyCaseTaskOwnerUser.id : null, dummyCase.next_open_task_reponsible_lookup__c);
        System.assertEquals((isQualityComplaint),                                     dummyCase.no_quality_status_change__c);
    }

    private static testMethod void unmappedInqirypdateNextOpenTaskReponsible2Test()            { updateNextOpenTaskReponsible2Test(false, false); }
    private static testMethod void mappedInquiryUpdateNextOpenTaskReponsible2Test()            { updateNextOpenTaskReponsible2Test(false, true ); }
    private static testMethod void unmappedQualityComplaintUpdateNextOpenTaskReponsible2Test() { updateNextOpenTaskReponsible2Test(true , false); }
    private static testMethod void mappedQualityComplaintUpdateNextOpenTaskReponsible2Test()   { updateNextOpenTaskReponsible2Test(true , true ); }

    // -------------------------------------------------------------------------------------------------------------

    private static testMethod void updateNextOpenTaskReponsible1Test()
    {
        User dummyCaseTaskOwnerUser = createTaskOwnerUser(ECICCommonConstants.PROFILE_ECIC_INFOLINE_AGENT, true);
        Case dummyCase              = createCaseWithTask(dummyCaseTaskOwnerUser.id);
      
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICTaskTriggerHandler.updateNextOpenTaskReponsible(new Map<Id, Case>{dummyCase.id => dummyCase}); 
            }
            Test.stopTest();
        }

        System.assertEquals(dummyCaseTaskOwnerUser.id, dummyCase.next_open_task_reponsible_lookup__c);
    }
    
    // -------------------------------------------------------------------------------------------------------------

    private static void updateRelatedCasesTest(Boolean caseTriggerToRunSavedValue)
    {
    	ECICCaseHelper.caseTriggerToRun = caseTriggerToRunSavedValue;
        User dummyCaseTaskOwnerUser     = createTaskOwnerUser(ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT, true);
        Case dummyCase                  = createCaseWithTask(dummyCaseTaskOwnerUser.id);

        List<Database.SaveResult> updateSaveResult = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                updateSaveResult = TARGET_HANDLER.updateRelatedCases(new Map<Id, Case>{dummyCase.id => dummyCase});
            }
            Test.stopTest();
        }
        
        System.assertEquals    (caseTriggerToRunSavedValue, ECICCaseHelper.caseTriggerToRun);
        System.assertEquals    (dummyCaseTaskOwnerUser.id,  dummyCase.next_open_task_reponsible_lookup__c);
        System.assertNotEquals (null, updateSaveResult);
    }
    private static testMethod void falseSavedUpdateRelatedCasesTest() { updateRelatedCasesTest(false); }
    private static testMethod void trueSavedUupdateRelatedCasesTest() { updateRelatedCasesTest(true);  }
    
    // -------------------------------------------------------------------------------------------------------------
            
    private static void processAfterTest(Boolean hasCase)
    {
        User dummyCaseTaskOwnerUser = createTaskOwnerUser(ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT, true);

    	Id dummyCaseId = null;
    	if (hasCase)
    	{
            Case dummyCase          = TEST_DummyInquiryCaseFactory.create (TEST_DummyInsertModeEnum.REAL);
                 dummyCaseId        = dummyCase.id;
    	}

        Task dummyTask              = createTask (dummyCaseTaskOwnerUser.id, dummyCaseId, true, true);

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_HANDLER.processAfter(new Task[] { dummyTask }, null); // As we've already tested ECICCaseTaskProcessorAbstract.iterateOnCaseTasks(), we should be able to disregard the potential impact of oldTasks here.
            }
            Test.stopTest();
        }
        
        if (hasCase)
        {
        	Case resultCase = [ SELECT next_open_task_reponsible_lookup__c FROM Case WHERE id = :dummyCaseId LIMIT 1];
        	System.assertEquals (dummyCaseTaskOwnerUser.id, resultCase.next_open_task_reponsible_lookup__c);
        }
        // else nothing to assert
    }

    private static testMethod void noCaseProcessAfterTest() { processAfterTest(false); }
    private static testMethod void hasCaseProcessAfterTest() { processAfterTest(true); }
    
    // -------------------------------------------------------------------------------------------------------------
    
    private static void onAfterMethodTest(String dmlType, Boolean manualTask)
    {
        Boolean isInsertTest = (dmlType == 'insert');
        Boolean isUpdateTest = (dmlType == 'update');
        Boolean isDeleteTest = (dmlType == 'delete');
    	
        User          dummyCaseTaskOwnerUser = createTaskOwnerUser(ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT, true);
        Case          dummyCase              = TEST_DummyInquiryCaseFactory.create (TEST_DummyInsertModeEnum.REAL);
        Id            dummyCaseId            =   dummyCase.id;

        Task          dummyTargetTask        = createTask (dummyCaseTaskOwnerUser.id, (!manualTask) ? dummyCaseId : null, true, true);
        List<Task>    dummyTargetTaskList    = new List<Task>   { dummyTargetTask };

        Map<Id, Task> dummyOldTaskByIdMap     = null;
        if (isUpdateTest)
        {
            Task dummyOldTask = dummyTargetTask.clone(false);
                 dummyOldTask.id      = dummyTargetTask.id;
                 dummyOldTask.ownerId = TEST_RUN_USER.id;
                 dummyOldTaskByIdMap  = new Map<Id, Task>{ dummyOldTask.id => dummyOldTask};
        }

        System.runAs(TEST_RUN_USER)
        {
        	// NOTE: The methods below do not presently (2014 April 17)  use the parameters which have been given null values.
            Test.startTest();
            {
                if      (isInsertTest) {  TARGET_HANDLER.onAfterInsert(dummyTargetTaskList, null); }
                else if (isUpdateTest) {  TARGET_HANDLER.OnAfterUpdate(null, dummyTargetTaskList, dummyOldTaskByIdMap, null); }
                else if (isDeleteTest) {  TARGET_HANDLER.onAfterInsert(dummyTargetTaskList, null); }
            }
            Test.stopTest();
        }
        
        if (!manualTask)
        {
	        Case resultCase = [ SELECT next_open_task_reponsible_lookup__c FROM Case WHERE id = :dummyCaseId LIMIT 1];
	        System.assertEquals (dummyCaseTaskOwnerUser.id, resultCase.next_open_task_reponsible_lookup__c);
        }
        // else nothing to assert.
    }

    private static void manualOnAfterInsertTest()       { onAfterMethodTest('insert', true);  } 
    private static void automaticOnAfterInsertTest()    { onAfterMethodTest('insert', false); }
    private static void onAfterUpdateTest()             { onAfterMethodTest('update', false); }
    private static void onAfterDeleteTest()             { onAfterMethodTest('delete', false); }

    // -------------------------------------------------------------------------------------------------------------

    private static Case createCaseWithTask(Id dummyCaseTaskOwnerUserId )
    {
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.ownerUserId           = TEST_RUN_USER.id;
        Case dummyCase      = TEST_DummyInquiryCaseFactory.create (caseConfig, TEST_DummyInsertModeEnum.REAL);
        
        Task dummyNextTask  = createTask (dummyCaseTaskOwnerUserId, dummyCase.id, true, true);
        
        return dummyCase;
    }
    
    // -------------------------------------------------------------------------------------------------------------

    private static Task createTask (Id dummyOwnerId, Id dummyCaseId, Boolean isTemplateIdRequired, Boolean isRealInsertRequired)
    {
        TEST_DummyTaskFactory.Config config = new TEST_DummyTaskFactory.Config();
                                     config.caseId     = dummyCaseId;
                                     config.templateId = (isTemplateIdRequired) ? getDummyActionPlanItemId(isRealInsertRequired) : TEST_ConfigHelper.INTENTIONAL_NULL;
        if (dummyOwnerId != null) {  config.ownerId    = dummyOwnerId; }
        return TEST_DummyTaskFactory.create(config, (isRealInsertRequired) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE);
    }

    private static Task createTask (Id dummyOwnerId, Id dummyCaseId) { return createTask (dummyOwnerId, dummyCaseId, false, false); }
    private static Task createTask (Id dummyOwnerId)                 { return createTask (dummyOwnerId, null,        false, false); }

    // -------------------------------------------------------------------------------------------------------------

    private static User createTaskOwnerUser(String profileName, Boolean isRealInsertRequired)
    {
        TEST_DummyUserFactory.Config userConfig = new TEST_DummyUserFactory.Config();
                                     userConfig.profileName = profileName; 
        User dummyUser = TEST_DummyUserFactory.create (userConfig, (isRealInsertRequired) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.MOCK);
        
        TEST_MockHelper.setMockString(dummyUser.id, 'Profile.Name', profileName);      // Work around to avoid DML and SOQL
        return dummyUser;
    }
    
    private static User createTaskOwnerUser(String profileName) { return createTaskOwnerUser(profileName, false); }

    // -------------------------------------------------------------------------------------------------------------

    private static Id getDummyActionPlanItemId(Boolean isRealInsertRequired)
    {
        if (dummyActionPlanItemId != null) { return dummyActionPlanItemId; }
        else if (!isRealInsertRequired)    { return 'a2211000000A6OH';     }
        
               dummyActionPlanItemId = TEST_DummyActionPlanItemFactory.create(TEST_DummyInsertModeEnum.REAL).id;
        return dummyActionPlanItemId;
    }
}