@isTest
private class ECICMasterDataObjectsTest {
    private static final Folder     DEFAULT_FOLDER                  = [SELECT Id, DeveloperName FROM Folder WHERE DeveloperName = 'English_Email_Templates' LIMIT 1];
    private static final User       TEST_RUN_USER                   = ECICRunUserTestHelper.create();
    private static final String     DEFAULT_FOLDER_LANGUAGE         = 'English';
    private static final String     EMAIL_TEMPLATE_FOLDER_SUFFIX    = '_Email_Templates';
    private static final Integer    AMOUNT_OF_TESTED_CASES          = 3;
    
    private static testMethod void testGetBaseURL() {
        PageReference pageRef = Page.QualityCommentPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getHeaders().put('Host', 'testValue');
        
        ECICGeneralController testedInstance = new ECICGeneralController(null);
        System.assertEquals('testValue', testedInstance.getBaseUrl());
    }
    
    private static void testResolveEmail(String templateName, String language) {
        System.runAs(TEST_RUN_USER) {
            System.assert(DEFAULT_FOLDER != null);
            System.assert([SELECT Count() FROM EmailTemplate] > 0);
            
            String expectedResult = getEmailTemplateId(templateName, language);
            System.assertEquals(expectedResult, ECICGeneralController.resolveEmail(templateName, language));
        }
    }
    
    private static testMethod void testResolveEmailDummyTemplateNonEmptyLang()  { testResolveEmail('dummyTestEmailTemplate', 'English');      }
    private static testMethod void testResolveEmailDummyTemplateEmptyLang()     { testResolveEmail('dummyTestEmailTemplate', '');             }
    private static testMethod void testResolveEmailDummyTemplateNullLang()      { testResolveEmail('dummyTestEmailTemplate', null);           }
    private static testMethod void testResolveEmailDummyTemplateDummyLang()     { testResolveEmail('dummyTestEmailTemplate', 'testLanguage'); }
    private static testMethod void testResolveEmailRealTemplateRealLang()       { testResolveEmail('Case_with_KB_Article', 'English');        }
    private static testMethod void testResolveEmailRealTemplateDummyLang()      { testResolveEmail('Case_with_KB_Article', 'testLanguage');   }
    private static testMethod void testResolveEmailRealTemplateEmptyLang()      { testResolveEmail('Case_with_KB_Article', '');               }
    
    private static Id getFolderIdByLang(String lang) {
        String ename = (!String.isEmpty(lang) ? lang : DEFAULT_FOLDER_LANGUAGE) + EMAIL_TEMPLATE_FOLDER_SUFFIX; 
        Folder[] fids = [SELECT Id FROM Folder WHERE DeveloperName = :ename LIMIT 1];
        if (fids.isEmpty()) {
            fids = [SELECT Id FROM Folder WHERE DeveloperName = :DEFAULT_FOLDER.DeveloperName LIMIT 1];
        }
        
        return (!fids.isEmpty()) ? fids[0].Id : null;
    }
    
    private static String getEmailTemplateId(String tmplName, String lang) {
        Id folderId = getFolderIdByLang(lang);
        tmplName = tmplName + '_%';
        
        List<EmailTemplate> templates = [SELECT Id FROM EmailTemplate WHERE DeveloperName LIKE :tmplName AND folderId = :folderId LIMIT 1];
        return (!templates.isEmpty()) ? templates[0].Id : null;
    }
    
    private static testMethod void testResolveTemplateEmptyName()    { testResolveTemplateId('dummyTestEmailTemplate');           }
    private static testMethod void testResolveTemplateNullName()     { testResolveTemplateId(null);                               }
    private static testMethod void testResolveTemplateRealName()     { testResolveTemplateId('Quality_Complaint_Fact_Sheet');     }
    
    private static void testResolveTemplateId(String templateName) {
        System.runAs(TEST_RUN_USER) {
            System.assert([SELECT Count() FROM EmailTemplate] > 0);
            
            ECICGeneralController testedInstance = new ECICGeneralController(null);
            List<EmailTemplate> templates = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :templateName];
            String expectedResult = templates.size() > 0 ? templates[0].Id : null;
            System.assertEquals(expectedResult, ECICGeneralController.resolveTemplateId(templateName));
        }
    }
    
    static testMethod void testUnlinkTrendCasesWebService() {
        Trend__c dummyTrend = TEST_DummyTrendFactory.create(TEST_DummyInsertModeEnum.REAL);
        
        TEST_DummyCaseConfig    caseConfig          = new TEST_DummyCaseConfig();
                                caseConfig.trendId  = dummyTrend.Id;
        List<Case>      cases   = TEST_DummyFastQualityComplaintCaseFactry.createList(AMOUNT_OF_TESTED_CASES, caseConfig, TEST_DummyInsertModeEnum.REAL);
        List<Trend__c>  trends  = [SELECT Id, CaseCount__c, ClosedCaseCount__c, Trend_Key__c FROM Trend__c ];
        
        System.assertEquals(1, trends.size());
        System.assertEquals(AMOUNT_OF_TESTED_CASES, trends[0].CaseCount__c);
        System.assertEquals(0, trends[0].ClosedCaseCount__c);
        System.assert(trends[0].Trend_Key__c != null);
        
        Set<Id> caseIds = new Set<Id>();
        for (Case c : cases) {
            System.assertEquals(trends[0].Id, c.trend__c);
            caseIds.add(c.Id);
        }
        
        System.runAs(TEST_RUN_USER) {
            Test.StartTest();
            {
                ECICGeneralController.unlinkTrendCases(new List<Id>(caseIds));
            }
            Test.StopTest();
        }
        
        assertUnlinkedCases();
    }
    
    private static void assertUnlinkedCases() {
        List<Case> unlinkCases = [SELECT Id, Status, Trend__c, No_Quality_Status_Change__c FROM Case];
        for (Case c : unlinkCases) {
            System.assertEquals(null, c.trend__c);
        }
    }
    
}