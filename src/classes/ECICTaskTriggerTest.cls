@isTest
private class ECICTaskTriggerTest {
    private static final User           TEST_RUN_USER   = ECICRunUserTestHelper.create();
    
    private static Task singleTaskTest (Task dummyTask, String triggerType) {
             if (triggerType == 'isInsert') { insert dummyTask; }
        else if (triggerType == 'isUpdate') { update dummyTask; }
        else if (triggerType == 'isDelete') { delete dummyTask; }
        
        return dummyTask;
    }
    
    private static Boolean isTaskDeleted(Task tsk) {
        Integer taskCount        = [SELECT Id FROM Task WHERE Id=:tsk.Id].size();
        Integer taskDeletedCount = [SELECT Id FROM Task WHERE IsDeleted = true AND id =:tsk.Id ALL ROWS].size();
        return taskCount == 0 && taskDeletedCount == 1;
    }
    
    //--------------------------------------------------------------------------------------------------------------
    
    private static void triggerTest(String triggerType, Boolean isSkipTriggers) {
        prepareGeneralSettings(isSkipTriggers);
        if (isSkipTriggers) { SEPTriggerHandlerInvoker.pretendTestNotRunning  = true; }
        
        Case dummyCase = createDummyCase(TEST_DummyInsertModeEnum.REAL);
        Task dummyTask = createDummyTask(dummyCase, (triggerType == 'isInsert') ? TEST_DummyInsertModeEnum.NONE : TEST_DummyInsertModeEnum.REAL);
        if (triggerType == 'isUpdate') { dummyTask.International_Name__c = 'testInternationalName'; }
        
        System.assertEquals(false, dummyCase.No_Quality_Status_Change__c);
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                singleTaskTest(dummyTask, triggerType);
            }
            Test.stopTest();
        }
        
        List<Task> dummyTaskList = [SELECT Id, ownerId, International_Name__c, Task_type__c, WhatId FROM Task];
        List<Case> dummyCaseList = [SELECT Id, Next_Open_Task_Reponsible_Lookup__c, No_Quality_Status_Change__c FROM Case];
        Boolean expectedQualityStatusChange = isSkipTriggers ? false : true;
        
        if(triggerType == 'isDelete') { 
            System.assertEquals(true, isTaskDeleted(dummyTask));
        } else {
            System.assertEquals(1, dummyTaskList.size());
            System.assertEquals(1, dummyCaseList.size());
            System.assertEquals(expectedQualityStatusChange, dummyCaseList[0].No_Quality_Status_Change__c);
        }
    }
    
    static testMethod void insertSingleTaskNotSkipInvocationTest()  { triggerTest('isInsert', false);   }
    static testMethod void insertSingleTaskSkipInvocationTest()     { triggerTest('isInsert', true);    }
    
    static testMethod void updateSingleTaskNotSkipInvocationTest()  { triggerTest('isUpdate', false);   }
    static testMethod void updateSingleTaskSkipInvocationTest()     { triggerTest('isUpdate', true);    }
    
    static testMethod void deleteSingleTaskNotSkipInvocationTest()  { triggerTest('isDelete', false);   }
    static testMethod void deleteSingleTaskSkipInvocationTest()     { triggerTest('isDelete', true);    }
    
    //--------------------------------------------------------------------------------------------------------------
    
    private static void prepareGeneralSettings(Boolean isSkipTriggers) {
        TEST_DummyGeneralSettingsFactory.Config settingsConfig = new TEST_DummyGeneralSettingsFactory.Config();
                                                settingsConfig.skipTriggers = isSkipTriggers;
        
        TEST_DummyGeneralSettingsFactory.create(settingsConfig, TEST_DummyInsertModeEnum.REAL);
    }
    
    private static Case createDummyCase(TEST_DummyInsertModeEnum insertionMode) {
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.noQualityStatusChange = false;
        
        return TEST_DummyFastQualityComplaintCaseFactry.create (caseConfig, insertionMode);
    }
    
    private static Task createDummyTask(Case dummyCase, TEST_DummyInsertModeEnum insertionMode) {
        TEST_DummyTaskFactory.Config config = new TEST_DummyTaskFactory.Config();
                                     config.caseId     = dummyCase.Id;
        
        return TEST_DummyTaskFactory.create(config, insertionMode);
    }

}