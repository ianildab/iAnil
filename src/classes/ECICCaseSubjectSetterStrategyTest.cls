@isTest //commented this whole class since we are not using this strategy.
private class ECICCaseSubjectSetterStrategyTest { /* comment bock 1 start
    private static final User TEST_RUN_USER                     = ECICRunUserTestHelper.create();
    private static final User TEST_RUN_USER_ES                  = createTestUser();
    private static ECICCaseSubjectSetterStrategy dummyStrategy;
    private static final String TEST_CASE_SUBJECT               = 'TestSubject';
    
    private class CaseCategoryValue {
        public String caseType     = null;
        public String caseReason   = null;
        public String caseLevel3   = null;
        public String caseLevel4   = null;
        
        public CaseCategoryValue(String caseType, String caseReason, String caseLevel3, String caseLevel4) {
            this.caseType = caseType;
            this.caseReason = caseReason;
            this.caseLevel3 = caseLevel3;
            this.caseLevel4 = caseLevel4;
        }
        
        public List<String> getDeepestCategoryFieldAndValue() {
            List<String> returnCategoryFieldAndValue = new List<String>();
            String strFieldName = '';
            String strValue     = '';
            
            if(!String.isBlank(caseLevel4)) {
                strFieldName = 'Category_Level4__c'; strValue = caseLevel4;
            } else if (!String.isBlank(caseLevel3)){
                strFieldName = 'Category_Level3__c'; strValue = caseLevel3;
            } else if(!String.isBlank(caseReason)) {
                strFieldName = 'Reason'; strValue = caseReason;
            } else if (String.isBlank(caseType)) {
                strFieldName = 'Type'; strValue = caseType;
            }
            
            returnCategoryFieldAndValue.add(strFieldName);
            returnCategoryFieldAndValue.add(strValue);
            
            return returnCategoryFieldAndValue;
        }
        
    }
    
    private static void onBeforeInsert(CaseCategoryValue categoryValues) {
        Case dummyCase = null;
        
        System.runAs(TEST_RUN_USER) {
            dummyCase = createTestCase(categoryValues);
            createTestCustomSettings();
        }
        
        List<String> testDeepestFieldAndValue = categoryValues.getDeepestCategoryFieldAndValue();
        String deepestFiledAPIName  = testDeepestFieldAndValue.get(0);
        String deepestFiledValue    = testDeepestFieldAndValue.get(1);
        
        System.assertEquals(deepestFiledValue, (String)dummyCase.get(deepestFiledAPIName));
        System.assertEquals(TEST_CASE_SUBJECT, dummyCase.subject);
        
        System.runAs(TEST_RUN_USER_ES) {
            dummyStrategy = new ECICCaseSubjectSetterStrategy();
            dummyStrategy.OnBeforeInsert(new List<Case>{ dummyCase });
        }
        
        System.assertNotEquals(TEST_CASE_SUBJECT, dummyCase.subject);
    }
    
    static testMethod void beforeInsertDeepestReasonCategoryTest()  { onBeforeInsert(new CaseCategoryValue('Quality Complaint', 'Product Quality', null, null)); }
    static testMethod void beforeInsertDeepestLevel3CategoryTest()  { onBeforeInsert(new CaseCategoryValue('Quality Complaint', 'Product Quality', 'Injury', null)); }
    static testMethod void beforeInsertDeepestLevel4CategoryTest()  { onBeforeInsert(new CaseCategoryValue('Quality Complaint', 'Product Quality', 'Injury', 'Physical Injuries')); }
    
    //---------------------------------------------------------------------------------------------------
    
    private static void onBeforeUpdate(CaseCategoryValue categoryValuesOldCase, CaseCategoryValue categoryValuesNewCase) {
        Case dummyOldCase = null;
        Case dummyNewCase = null;
        
        System.runAs(TEST_RUN_USER) {
            createTestCustomSettings();
            dummyOldCase        = createTestCase(categoryValuesOldCase);
            
            System.runAs(TEST_RUN_USER_ES) {
                dummyStrategy = new ECICCaseSubjectSetterStrategy();
                dummyStrategy.OnBeforeInsert(new List<Case>{ dummyOldCase });
            }
            
            dummyNewCase        = createNewCase(dummyOldCase, categoryValuesNewCase);
            dummyNewCase.id     = dummyOldCase.id;
            
            System.runAs(TEST_RUN_USER_ES) {
                dummyStrategy = new ECICCaseSubjectSetterStrategy();
                dummyStrategy.OnBeforeUpdate(new Map<Id, Case>{ dummyOldCase.id => dummyOldCase },
                                             new Map<Id, Case>{ dummyNewCase.id => dummyNewCase });
            }
        }
        
        System.assertNotEquals(TEST_CASE_SUBJECT, dummyNewCase.subject);
        System.assertNotEquals(dummyOldCase.subject, dummyNewCase.subject);
    }
    
    static testMethod void beforeUpdateChangeCategoryTest()  { onBeforeUpdate(new CaseCategoryValue('Quality Complaint', 'Product Quality', 'Carbonation', 'Product Flat on Opening'),
                                                                              new CaseCategoryValue('Quality Complaint', 'Product Quality', 'Carbonation', 'Product Flat on Reopening')); }
    
    //---------------------------------------------------------------------------------------------------
    
    private static void createTestCustomSettings() {
        TEST_DummyCountrySpecificSettingsFactory.Config countrySettingsConfig = new TEST_DummyCountrySpecificSettingsFactory.Config();
                                        countrySettingsConfig.countryCode                   = 'ES';
                                        countrySettingsConfig.allowedlanguages              = 'es;en';
                                        countrySettingsConfig.defaultLanguage               = 'es';
                                        countrySettingsConfig.hQCity                        = 'Madrid';
                                        countrySettingsConfig.officialLanguages             = 'es';
                                        countrySettingsConfig.qualityComplaintRecordTypeId  = '01211000000Ci6lAAC';
        
        TEST_DummyCountrySpecificSettingsFactory.create(countrySettingsConfig, true);
    }
    
    private static Case createTestCase(CaseCategoryValue categoryValues) {
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.ownerId         = UserInfo.getUserId();
                             caseConfig.countryCode     = 'ES';
                             caseConfig.type            = String.isBlank(categoryValues.caseType) ? null : categoryValues.caseType;
                             caseConfig.Reason          = String.isBlank(categoryValues.caseReason) ? null : categoryValues.caseReason;
                             caseConfig.categoryLevel3  = String.isBlank(categoryValues.caseLevel3) ? null : categoryValues.caseLevel3;
                             caseConfig.categoryLevel4  = String.isBlank(categoryValues.caseLevel4) ? null : categoryValues.caseLevel4;
                             caseConfig.subject         = TEST_CASE_SUBJECT;
        
        Case dummyCase              = TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.MOCK);
        return dummyCase;
    }
    
    private static Case createNewCase (Case dummyOldCase, CaseCategoryValue categoryValues) {
        Case dummyNewCase = dummyOldCase.clone(false);
        dummyNewCase.Type                = String.isBlank(categoryValues.caseType)   ? null : categoryValues.caseType;
        dummyNewCase.Reason              = String.isBlank(categoryValues.caseReason) ? null : categoryValues.caseReason;
        dummyNewCase.Category_Level3__c  = String.isBlank(categoryValues.caseLevel3) ? null : categoryValues.caseLevel3;
        dummyNewCase.Category_Level4__c  = String.isBlank(categoryValues.caseLevel4) ? null : categoryValues.caseLevel4;
        return dummyNewCase;
    }
    
    private static User createTestUser() {
        Profile infolineAgentProfile    = [Select Name, Id From Profile WHERE Name = 'ECIC_Infoline Agent' LIMIT 1];
        UserRole infolineAgentUserRole  = [Select Name, Id, DeveloperName From UserRole WHERE developerName = 'ES_Infoline_Agent'];
        
        User testRunUser              = new User();
        testRunUser.LastName          = 'testLastName';
        testRunUser.Alias             = 'testA'; 
        testRunUser.Email             = 'test@runas.example.com'; 
        testRunUser.Username          = 'test@runas.example.com'; 
        testRunUser.CommunityNickname = 'testNickName';  
        testRunUser.ProfileId         = infolineAgentProfile.Id;
        testRunUser.UserRoleId        = infolineAgentUserRole.Id;
        testRunUser.LanguageLocaleKey = 'es';
        testRunUser.LocaleSidKey      = 'es_ES';
        testRunUser.EmailEncodingKey  = 'UTF-8';
        testRunUser.TimeZoneSidKey    = 'Europe/Berlin';
        testRunUser.Country_Code__c   = 'ES';
        
        return testRunUser;
    } comment block 1 end*/
}