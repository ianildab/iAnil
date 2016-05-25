@isTest 
private class ECICOpenAlertExpirationWarningBatchTest {
    private static final User    TEST_RUN_USER  = TEST_DummyUserFactory.createDefaultTestRunUser();
    private static final Id EMAIL_TEMPLATE_ID   = [SELECT id FROM EmailTemplate WHERE DeveloperName='Open_Alert_Expiration_Notification'].Id;
    
    private static testMethod void databaseExecuteBatchTest() {
        General_Settings__c gs = TEST_DummyGeneralSettingsFactory.create(TEST_DummyInsertModeEnum.REAL);
        gs.Open_Alert_Expiration_Template_Id__c = EMAIL_TEMPLATE_ID;
        update gs;
        Integer       emailLimitBefore = Limits.getEmailInvocations();
        Date          dummyEndDate     = System.today();
        Open_Alert__c dummyOpenAlert   = createOpenAlert(dummyEndDate, TEST_RUN_USER.id);
        
        ECICOpenAlertExpirationWarningBatchable warningBatchable = new ECICOpenAlertExpirationWarningBatchable();
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                Database.executeBatch(warningBatchable);
            }
            Test.stopTest();
        }
        
        Integer emailLimitAfter = ECICOpenAlertExpirationWarningBatchable.emailLimit;
        System.assertNotEquals (emailLimitBefore, emailLimitAfter, 'Should have decreased');
    }
    
    // -------------------------------------------------------------------------------------------------------------------------------------
    
    private static Open_Alert__c createOpenAlert(Date dummyEndDate, Id dummyOwnerUserId) {
         TEST_DummyOpenAlertFactory.Config config = new TEST_DummyOpenAlertFactory.Config();
                                           config.endDate     = dummyEndDate;
                                           config.ownerUserId = dummyOwnerUserId;
         return TEST_DummyOpenAlertFactory.create(config, TEST_DummyInsertModeEnum.REAL);
    }

}