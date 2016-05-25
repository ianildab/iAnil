@isTest
private class ECICCaseTaskAssignmentStrategyTest 
{
    private static final User                           TEST_RUN_USER   = ECICRunUserTestHelper.create(); 
    private static final ECICCaseTaskAssignmentStrategy TARGET_STRATEGY = new ECICCaseTaskAssignmentStrategy();

    private static void reassignTaskTest(Boolean isQualityCase) 
    {
        Task dummyOriginalTask   = TEST_DummyTaskFactory.create(TEST_DummyInsertModeEnum.NONE); 

        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             /*#CICTemplateTest*/
                             caseConfig.recordTypeId          = TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(isQualityCase ? ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME : ECICCommonConstants.INQUIRY_IBERIA_DEVNAME);
                             caseConfig.noQualityStatusChange = false;
        Case dummyCurrentCase    = TEST_DummyGenericCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.NONE); 

        Id   dummyAssignToUserId = '00520000001qmXm';
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_STRATEGY.reassignTask(dummyCurrentCase, dummyOriginalTask, dummyAssignToUserId);
            }
            Test.stopTest();
        }
        
        assertReassignedTask(dummyCurrentCase, dummyOriginalTask, dummyAssignToUserId);
        System.assertEquals(isQualityCase,        dummyCurrentCase.no_quality_status_change__c);
    }

    private static testMethod void inquiryCaseReassignTaskTest() { reassignTaskTest (false); } 
    private static testMethod void qualityCaseReassignTaskTest() { reassignTaskTest (true);  } 

    // ---------------------------------------------------------------------------------------------------------------
 
    private static void assignTaskToUserInCaseFieldTest(Boolean caseOwnerIsQueue, Boolean assignToIsNull, Boolean taskOwnerChanges) 
    {
        String dummyAssignToUserInCaseField = 'bottler_quality_manager__c';
        Id     dummyOtherUserId             = '00520000001qmXm';
        Id     dummyTaskTargetUserId        = assignToIsNull ? null : dummyOtherUserId;

        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.ownerId                     = caseOwnerIsQueue ? '00G11000004gFL4' : TEST_RUN_USER.id;
        Case dummyCurrentCase = TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.NONE);
             dummyCurrentCase.put (dummyAssignToUserInCaseField, dummyTaskTargetUserId);

        TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
                                     taskConfig.ownerId = (taskOwnerChanges) 
                                                            ? '00520000001qmX1' 
                                                            : ( (dummyTaskTargetUserId != null) ? dummyTaskTargetUserId : TEST_RUN_USER.id );
        Task   dummyOriginalTask = TEST_DummyTaskFactory.create(taskConfig, TEST_DummyInsertModeEnum.NONE); 

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_STRATEGY.assignTaskToUserInCaseField(dummyCurrentCase, dummyOriginalTask, dummyAssignToUserInCaseField);
            }
            Test.stopTest();
        } 
        
        if (caseOwnerIsQueue)
        {
            String errorMessage = TEST_MockHelper.getMockString(dummyCurrentCase, 'error');
            System.assert (errorMessage.contains(System.Label.ownerCantBeQueueIfActivityExist));
        }
        else if (taskOwnerChanges)
        {
            Id expectedTaskAssigneeId = assignToIsNull ? TEST_RUN_USER.id : dummyOtherUserId;
            assertReassignedTask(dummyCurrentCase, dummyOriginalTask, expectedTaskAssigneeId);
        }
        // else nothing to check for.
    }
 
    private static testMethod void notQueNotNullNoChangeAssignTaskToUserInCaseFieldTest()   { assignTaskToUserInCaseFieldTest ( false,  false,  false   ); } 
    private static testMethod void notQueNotNullChangeAssignTaskToUserInCaseFieldTest()     { assignTaskToUserInCaseFieldTest ( false,  false,  true    ); } 
    private static testMethod void notQueNullNoChangeAssignTaskToUserInCaseFieldTest()      { assignTaskToUserInCaseFieldTest ( false,  true,   false   ); } 
    private static testMethod void notQueNullChangeAssignTaskToUserInCaseFieldTest()        { assignTaskToUserInCaseFieldTest ( false,  true,   true    ); }
    private static testMethod void hasQueNotNullNoChangeAssignTaskToUserInCaseFieldTest()   { assignTaskToUserInCaseFieldTest ( true,   false,  false   ); } 
    private static testMethod void hasQueNotNullChangeAssignTaskToUserInCaseFieldTest()     { assignTaskToUserInCaseFieldTest ( true,   false,  true    ); } 
    private static testMethod void hasQueNullNoChangeAssignTaskToUserInCaseFieldTest()      { assignTaskToUserInCaseFieldTest ( true,   true,   false   ); } 
    private static testMethod void hasQueNullChangeAssignTaskToUserInCaseFieldTest()        { assignTaskToUserInCaseFieldTest ( true,   true,   true    ); } 

    // ---------------------------------------------------------------------------------------------------------------
 
    private static void recreateUserTasks2Test(Boolean assigneeInActionPlanItemCache, Boolean reassignTasks) 
    {
        Id     dummyActionPlanItemId        = 'a2211000000A6OH';
        String dummyAssignToUserInCaseField = 'bottler_quality_manager__c';
        Id     dummyTaskTargetUserId        = '00520000001qmXm';

        Case dummyCurrentCase = TEST_DummyInquiryCaseFactory.create(TEST_DummyInsertModeEnum.NONE);
             dummyCurrentCase.put (dummyAssignToUserInCaseField, dummyTaskTargetUserId);

        TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
                                     taskConfig.ownerId    = (reassignTasks) ? '00520000001qmX1' : dummyTaskTargetUserId;
                                     taskConfig.templateId = dummyActionPlanItemId; 
        Task   dummyOriginalTask = TEST_DummyTaskFactory.create(taskConfig, TEST_DummyInsertModeEnum.NONE); 

        if (assigneeInActionPlanItemCache)
        { 
            ECICCaseTriggerActionPlanItemCache.caseActionPlanItemAssigneeTitleByIdCache.put (dummyActionPlanItemId, dummyAssignToUserInCaseField);
        }

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_STRATEGY.recreateUserTasks(dummyCurrentCase, new List<Task>{ dummyOriginalTask } );
            }
            Test.stopTest();
        } 

        if (assigneeInActionPlanItemCache && reassignTasks)
        {
            assertReassignedTask(dummyCurrentCase, dummyOriginalTask, dummyTaskTargetUserId);
        }
    }

    private static testMethod void notInCacheRecreateUserTasks2Test() { recreateUserTasks2Test(false, false); } 
    private static testMethod void noReassignRecreateUserTasks2Test() { recreateUserTasks2Test(true,  false); } 
    private static testMethod void reassignRecreateUserTasks2Test()   { recreateUserTasks2Test(true,  true);  } 
 
    // ---------------------------------------------------------------------------------------------------------------
 
    private static void recreateUserTasks1Test(Boolean tasksInCache) 
    {
        Id     dummyActionPlanItemId        = 'a2211000000A6OH';
        String dummyAssignToUserInCaseField = 'bottler_quality_manager__c';
        Id     dummyTaskTargetUserId        = '00520000001qmXm';

        Case          dummyCurrentCase = TEST_DummyInquiryCaseFactory.create(TEST_DummyInsertModeEnum.MOCK);
                      dummyCurrentCase.put (dummyAssignToUserInCaseField, dummyTaskTargetUserId);
        Set<Id>       dummyCasesToRecreateIdSet    = new Set<Id>        { dummyCurrentCase.id }; 
        Map<Id, Case> dummyNewCasesByIdMap         = new Map<Id, Case>  { dummyCurrentCase.id => dummyCurrentCase};

        TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
                                     taskConfig.ownerId    = '00520000001qmX1';
                                     taskConfig.templateId = dummyActionPlanItemId;
                                     taskConfig.caseId     = dummyCurrentCase.id;
        Task   dummyOriginalTask = TEST_DummyTaskFactory.create(taskConfig, TEST_DummyInsertModeEnum.MOCK); 

        ECICCaseTriggerActionPlanItemCache.caseActionPlanItemAssigneeTitleByIdCache.put (dummyActionPlanItemId, dummyAssignToUserInCaseField);
        
        if (tasksInCache)
        {
            ECICCaseTriggerTaskCache.caseUnmodifiedTaskByTaskIdCache.put (dummyOriginalTask.id, dummyOriginalTask);
        }

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_STRATEGY.recreateUserTasks(dummyCasesToRecreateIdSet, dummyNewCasesByIdMap);
            }
            Test.stopTest();
        } 

        if (tasksInCache)
        {
            assertReassignedTask(dummyCurrentCase, dummyOriginalTask, dummyTaskTargetUserId);
        }
    }
 
    private static testMethod void notInCacheRecreateUserTasks1Test() { recreateUserTasks1Test(false); } 
    private static testMethod void inCacheRecreateUserTasks1Test()    { recreateUserTasks1Test(true);  } 
 
    // ---------------------------------------------------------------------------------------------------------------
 
    private static testMethod void buildCaseFieldsToCheckForChangeSetTest() 
    {
        String dummyTitle = 'Dummy Assignee';
        ECICCaseTriggerActionPlanItemCache.actionPlanItemAssigneeTitleCache.add (dummyTitle);
       
        Set<String> resultCaseFieldsToCheckForChangeSet = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCaseFieldsToCheckForChangeSet = TARGET_STRATEGY.buildCaseFieldsToCheckForChangeSet();
            }
            Test.stopTest();
        } 
        
        System.assert(resultCaseFieldsToCheckForChangeSet.contains(dummyTitle));
        System.assert(resultCaseFieldsToCheckForChangeSet.contains('OwnerId'));
    }
 
    // ---------------------------------------------------------------------------------------------------------------
 
    private static void buildCasesToReassignIdSetTest(Boolean hasOwnerChanged, Boolean hasAssigneeChanged) 
            {
        String dummyTitle = 'bottler_quality_manager__c';
        ECICCaseTriggerActionPlanItemCache.actionPlanItemAssigneeTitleCache.add (dummyTitle);

        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.ownerUserId                 = '00520000001qmo1';
                             caseConfig.bottlerQualityManagerUserId = '00520000001bqm1';
        Case          dummyNewCase          = TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.MOCK);
        Map<Id, Case> dummyNewCasesByIdMap  = new Map<Id, Case>{ dummyNewCase.id => dummyNewCase }; 
 
        Case          dummyOldCase = dummyNewCase.clone(false);
                      dummyOldCase.id                            = dummyNewCase.id;
                      dummyOldCase.ownerId                       = (hasOwnerChanged)     ? '00520000001qmo2' : caseConfig.ownerUserId;
                      dummyOldCase.bottler_quality_manager__c    = (hasAssigneeChanged)  ? '00520000001bqm2' : caseConfig.bottlerQualityManagerUserId;
        Map<Id, Case> dummyOldCasesByIdMap  = new Map<Id, Case>{ dummyOldCase.id => dummyOldCase }; 

        Set<String>   dummyCaseFieldsToCheckForChangeSet = new Set<String>{ 'OwnerId', dummyTitle };
        
        Set<Id> resultCasesToReassignIdSet = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCasesToReassignIdSet = TARGET_STRATEGY.buildCasesToReassignIdSet(dummyOldCasesByIdMap, dummyNewCasesByIdMap, dummyCaseFieldsToCheckForChangeSet);
            }
            Test.stopTest();
        } 
        
        Boolean caseExpectedInSet = hasOwnerChanged || hasAssigneeChanged;
        System.assertEquals (caseExpectedInSet, resultCasesToReassignIdSet.contains(dummyNewCase.id));
    }

    private testMethod static void noChangeBuildCasesToReassignIdSetTest()          { buildCasesToReassignIdSetTest(false, false); }
    private testMethod static void assigneeChangedBuildCasesToReassignIdSetTest()   { buildCasesToReassignIdSetTest(false, true ); }
    private testMethod static void ownerChangedBuildCasesToReassignIdSetTest()      { buildCasesToReassignIdSetTest(true,  false); }
    private testMethod static void bothChangedBuildCasesToReassignIdSetTest()       { buildCasesToReassignIdSetTest(true,  true ); }
 
    // ---------------------------------------------------------------------------------------------------------------
 
    private static void updateUserTaskAssignmentTest(Boolean hasCaseToReassign) 
    {
        String dummyAssignToUserInCaseField = 'bottler_quality_manager__c';
        ECICCaseTriggerActionPlanItemCache.actionPlanItemAssigneeTitleCache.add (dummyAssignToUserInCaseField);

        Id     dummyActionPlanItemId        = 'a2211000000A6OH';
        ECICCaseTriggerActionPlanItemCache.caseActionPlanItemAssigneeTitleByIdCache.put (dummyActionPlanItemId, dummyAssignToUserInCaseField);

        Id     dummyTaskTargetNewUserId     = '00520000001qmXm';
        Id     dummyTaskTargetOldUserId     = (hasCaseToReassign) ? '00520000001qmX2' : dummyTaskTargetNewUserId;
        
        Case          dummyNewCase          = TEST_DummyInquiryCaseFactory.create(TEST_DummyInsertModeEnum.MOCK);
                      dummyNewCase.put (dummyAssignToUserInCaseField, dummyTaskTargetNewUserId);
        Map<Id, Case> dummyNewCasesByIdMap  = new Map<Id, Case>{ dummyNewCase.id => dummyNewCase }; 

        Case          dummyOldCase = dummyNewCase.clone(false);
                      dummyOldCase.id                            = dummyNewCase.id;
                      dummyOldCase.bottler_quality_manager__c    = dummyTaskTargetOldUserId;
        Map<Id, Case> dummyOldCasesByIdMap  = new Map<Id, Case>{ dummyOldCase.id => dummyOldCase }; 
        
        TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
                                     taskConfig.ownerId    = dummyTaskTargetOldUserId;
                                     taskConfig.templateId = dummyActionPlanItemId;
                                     taskConfig.caseId     = dummyNewCase.id;
        Task   dummyOriginalTask = TEST_DummyTaskFactory.create(taskConfig, TEST_DummyInsertModeEnum.MOCK); 
        
        ECICCaseTriggerTaskCache.caseUnmodifiedTaskByTaskIdCache.put (dummyOriginalTask.id, dummyOriginalTask);
        

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_STRATEGY.updateUserTaskAssignment(dummyOldCasesByIdMap, dummyNewCasesByIdMap);
            }
            Test.stopTest();
        }
        
        if (hasCaseToReassign)
        {
             assertReassignedTask(dummyNewCase, dummyOriginalTask, dummyTaskTargetNewUserId);
        }
        else
        {
            System.assertEquals (0,     TARGET_STRATEGY.caseTasksToCreateList.size());
            System.assertEquals (0,     TARGET_STRATEGY.caseTasksToDeleteList.size());
            System.assertEquals (null,  dummyNewCase.next_open_task_reponsible_lookup__c);
        }
        
    }

    private static testMethod void noReassignUpdateUserTaskAssignmentTest()     { updateUserTaskAssignmentTest(false); } 
    private static testMethod void needsReassignUpdateUserTaskAssignmentTest()  { updateUserTaskAssignmentTest(true);  } 
 
    // ---------------------------------------------------------------------------------------------------------------
 
    private static testMethod void onBeforeUpdateTest() 
    {
        String dummyAssignToUserInCaseField = 'bottler_quality_manager__c';
        ECICCaseTriggerActionPlanItemCache.actionPlanItemAssigneeTitleCache.add (dummyAssignToUserInCaseField);

        Id     dummyActionPlanItemId        = 'a2211000000A6OH';
        ECICCaseTriggerActionPlanItemCache.caseActionPlanItemAssigneeTitleByIdCache.put (dummyActionPlanItemId, dummyAssignToUserInCaseField);

        Id     dummyTaskTargetNewUserId     = '00520000001qmXm';
        Id     dummyTaskTargetOldUserId     = '00520000001qmX2';
        
        Case          dummyNewCase          = TEST_DummyInquiryCaseFactory.create(TEST_DummyInsertModeEnum.MOCK);
                      dummyNewCase.put (dummyAssignToUserInCaseField, dummyTaskTargetNewUserId);
        Map<Id, Case> dummyNewCasesByIdMap  = new Map<Id, Case>{ dummyNewCase.id => dummyNewCase }; 

        Case          dummyOldCase = dummyNewCase.clone(false);
                      dummyOldCase.id                            = dummyNewCase.id;
                      dummyOldCase.bottler_quality_manager__c    = dummyTaskTargetOldUserId;
        Map<Id, Case> dummyOldCasesByIdMap  = new Map<Id, Case>{ dummyOldCase.id => dummyOldCase }; 
        
        TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
                                     taskConfig.ownerId    = dummyTaskTargetOldUserId;
                                     taskConfig.templateId = dummyActionPlanItemId;
                                     taskConfig.caseId     = dummyNewCase.id;
        Task   dummyOriginalTask = TEST_DummyTaskFactory.create(taskConfig, TEST_DummyInsertModeEnum.MOCK); 
        
        ECICCaseTriggerTaskCache.caseUnmodifiedTaskByTaskIdCache.put (dummyOriginalTask.id, dummyOriginalTask);
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = TARGET_STRATEGY.onBeforeUpdate(dummyOldCasesByIdMap, dummyNewCasesByIdMap);
            }
            Test.stopTest();
        }
        
        System.assert(result);
        assertReassignedTask(dummyNewCase, dummyOriginalTask, dummyTaskTargetNewUserId);
    }

    // ---------------------------------------------------------------------------------------------------------------

    private static void assertReassignedTask(Case resultCurrentCase, Task dummyOriginalTask, Id dummyAssignToUserId)
    {
        List<Task>  resultCaseTasksToCreateList = TARGET_STRATEGY.caseTasksToCreateList;
        System.assertEquals (1,                   resultCaseTasksToCreateList.size());
        System.assertEquals (dummyAssignToUserId, resultCaseTasksToCreateList[0].ownerId);

        List<Task>  resultCaseTasksToDeleteList = TARGET_STRATEGY.caseTasksToDeleteList;
        System.assertEquals (1,                   resultCaseTasksToDeleteList.size());
        System.assertEquals (dummyOriginalTask,   resultCaseTasksToDeleteList[0]);
        
        System.assertEquals(dummyAssignToUserId,  resultCurrentCase.next_open_task_reponsible_lookup__c);
}

}