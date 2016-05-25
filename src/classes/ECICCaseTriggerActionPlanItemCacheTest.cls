@isTest
private class ECICCaseTriggerActionPlanItemCacheTest {
    private static final User TEST_RUN_USER = ECICRunUserTestHelper.create();
    
    private static testMethod void getActionPlanItemAssigneeTitleSetTest() {
        String dummyAssigneeTitle = 'Dummy';
        ECICCaseTriggerActionPlanItemCache.actionPlanItemAssigneeTitleCache.add (dummyAssigneeTitle);
        
        Set<String> resultPlanItemAssigneeTitleSet = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                resultPlanItemAssigneeTitleSet = ECICCaseTriggerActionPlanItemCache.getActionPlanItemAssigneeTitleSet();
            }
            Test.stopTest();
        }
        
        System.assert (resultPlanItemAssigneeTitleSet.contains(dummyAssigneeTitle));
    }
    
    private static testMethod void getCaseActionPlanItemByIdMapTest() {
        Action_Plan_Item__c dummyActionPlanItem = TEST_DummyActionPlanItemFactory.create(TEST_DummyInsertModeEnum.MOCK);
        ECICCaseTriggerActionPlanItemCache.caseActionPlanItemByIdCache.put (dummyActionPlanItem.id, dummyActionPlanItem);
        
        Map<Id, Action_Plan_Item__c> resultCaseActionPlanItemByIdMap = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                resultCaseActionPlanItemByIdMap = ECICCaseTriggerActionPlanItemCache.getCaseActionPlanItemByIdMap();
            }
            Test.stopTest();
        }
        
        System.assert (resultCaseActionPlanItemByIdMap.containsKey(dummyActionPlanItem.id));
        System.assertEquals (dummyActionPlanItem.Assignee__c, resultCaseActionPlanItemByIdMap.get(dummyActionPlanItem.id).Assignee__c);
    }
    
    private static testMethod void getCaseActionPlanItemAssigneeTitleByIdMapTest() {
        Action_Plan_Item__c dummyActionPlanItem         = TEST_DummyActionPlanItemFactory.create(TEST_DummyInsertModeEnum.MOCK);
        String              dummyActionPlanItemAssignee = dummyActionPlanItem.Assignee__c;
        ECICCaseTriggerActionPlanItemCache.caseActionPlanItemAssigneeTitleByIdCache.put (dummyActionPlanItem.id, dummyActionPlanItemAssignee);
        
        Map<Id, String> resultCaseActionPlanItemAssigneeTitleByIdMap = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                resultCaseActionPlanItemAssigneeTitleByIdMap = ECICCaseTriggerActionPlanItemCache.getCaseActionPlanItemAssigneeTitleByIdMap();
            }
            Test.stopTest();
        }
        
        System.assert (resultCaseActionPlanItemAssigneeTitleByIdMap.containsKey(dummyActionPlanItem.id));
        System.assertEquals (dummyActionPlanItemAssignee, resultCaseActionPlanItemAssigneeTitleByIdMap.get(dummyActionPlanItem.id));
    }
    
    private static testMethod void buildActionPlanItemAssigneeTitleCacheTest() {
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                ECICCaseTriggerActionPlanItemCache.buildActionPlanItemAssigneeTitleCache();
            }
            Test.stopTest();
        }
        assertPlanItemAssigneeTitleSet();
    }
    
    private static void assertPlanItemAssigneeTitleSet() {
        for (Schema.PicklistEntry assigneeEntry : Action_Plan_Item__c.Assignee__c.getDescribe().getPickListValues()) {
            // TODO: fix assertion
            //System.assert(ECICCaseTriggerActionPlanItemCache.actionPlanItemAssigneeTitleCache.contains(assigneeEntry.getValue()));
        }
    }
    
    private static testMethod void populateTest() {
        Action_Plan_Item__c dummyActionPlanItem         = TEST_DummyActionPlanItemFactory.create(TEST_DummyInsertModeEnum.REAL);
        String              dummyActionPlanItemAssignee = dummyActionPlanItem.Assignee__c;
        Case                dummyCase                   = TEST_DummyFastQualityComplaintCaseFactry.create(TEST_DummyInsertModeEnum.MOCK);
        ECICCaseTriggerActionPlanItemCache.caseActionPlanItemByIdCache.put (dummyActionPlanItem.id, dummyActionPlanItem);
        
        TEST_DummyTaskFactory.Config    dummyTaskConfig = new TEST_DummyTaskFactory.Config();
                                        dummyTaskConfig.caseId              = dummyCase.id;
                                        dummyTaskConfig.actionPlanItemId    = dummyActionPlanItem.id;
        Task dummyTask = TEST_DummyTaskFactory.create(dummyTaskConfig, TEST_DummyInsertModeEnum.MOCK);
        ECICCaseTriggerTaskCache.caseUnmodifiedTaskByTaskIdCache.put (dummyTask.id, dummyTask);
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                ECICCaseTriggerActionPlanItemCache.populate(new List<Case> {dummyCase});
            }
            Test.stopTest();
        }
        
        assertPlanItemAssigneeTitleSet();
        Map<Id, Action_Plan_Item__c> resultCaseActionPlanItemByIdMap = ECICCaseTriggerActionPlanItemCache.caseActionPlanItemByIdCache;
        System.assert (resultCaseActionPlanItemByIdMap.containsKey(dummyActionPlanItem.id));
        System.assertEquals (dummyActionPlanItemAssignee, resultCaseActionPlanItemByIdMap.get(dummyActionPlanItem.id).Assignee__c);
        
        Map<Id, String> resultCaseActionPlanItemAssigneeTitleByIdMap = ECICCaseTriggerActionPlanItemCache.caseActionPlanItemAssigneeTitleByIdCache;
        System.assert (resultCaseActionPlanItemAssigneeTitleByIdMap.containsKey(dummyActionPlanItem.id));
        System.assertEquals (dummyActionPlanItemAssignee, resultCaseActionPlanItemAssigneeTitleByIdMap.get(dummyActionPlanItem.id));
    }
}