@isTest
private class STMVFPageControllersTest {
    static Integer AMOUNT_INSERTED_ISSUESCORES = 10;
    static Integer AMOUNT_TEST_RECORDS = 10;
    
    // STMAddStakeholdersController
    /*
    static testMethod void runSearchTest() {
        STMTestHelper.initTestEnvironment(true);
        List<Contact> contactSTMList = [SELECT Id, Name FROM Contact WHERE STMActive__c = false];
        List<STMG_Type__c> types = new List<STMG_Type__c>();
        for(Integer i = 0; i < contactSTMList.size(); i++) {
            types.add(STMTestHelper.createType(contactSTMList[i]));
            contactSTMList[i].STMActive__c = true;
        }
        insert types;
        update contactSTMList;
        
        List<STMIssue__c> issues =  [SELECT  Id, Name, IssueCategory__c, IssueObject__c, IssueTag__c FROM STMIssue__c];
        System.assertEquals(1, issues.size());
        
        List<Contact> contactList = [SELECT Id, Contact.FirstName, Contact.LastName, Contact.Account.Name, Contact.Name, 
                                            Contact.IsPersonAccount, Contact.Account.IsPersonAccount 
                                            FROM Contact 
                                            WHERE Contact.STMActive__c = true 
                                            AND Contact.Account.Name != null];
        System.assertEquals(STMTestHelper.AMOUNT_TEST_RECORDS/2, contactList.size());
        
        PageReference pageRef = Page.STMAddStakeholders;
        System.assertNotEquals(null, pageRef);
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('Id',          issues[0].Id);
        pageRef.getParameters().put('firstName',   contactList[0].FirstName);
        pageRef.getParameters().put('lastName',    contactList[0].LastName);
        pageRef.getParameters().put('accountName', contactList[0].Account.Name);
        System.assertEquals(issues[0].Id, ApexPages.currentPage().getParameters().get('id'));
        
        Test.startTest();
            STMAddStakeholdersController controller = new STMAddStakeholdersController();
            Integer defaultSize = controller.size;
            System.assertEquals(10,    defaultSize);
            
            List<Contact> contacts = controller.contacts;
            System.assertEquals(10,    contacts.size());
            System.assertEquals(100,   controller.noOfRecords);
            System.assertEquals(1,     controller.pageNumber);
            System.assertEquals(true,  controller.hasNext);
            System.assertEquals(false, controller.hasPrevious);
           
            controller.first();
            System.assertEquals(1,     controller.pageNumber);
            System.assertEquals(true,  controller.hasNext);
            System.assertEquals(false, controller.hasPrevious);
            
            controller.next();
            System.assertEquals(2,     controller.pageNumber);
            System.assertEquals(true,  controller.hasNext);
            System.assertEquals(true,  controller.hasPrevious);
            
            controller.last();
            System.assertEquals(10,    controller.pageNumber);
            System.assertEquals(false, controller.hasNext);
            System.assertEquals(true,  controller.hasPrevious);
            
            controller.previous();
            System.assertEquals(9,     controller.pageNumber);
            System.assertEquals(true,  controller.hasNext);
            System.assertEquals(true,  controller.hasPrevious);
            
            controller.runSearch();
            
            contacts = controller.contacts;
            System.assertEquals(1,     contacts.size());
            System.assertEquals(1,     controller.noOfRecords);
            System.assertEquals(1,     controller.pageNumber);
            System.assertEquals(false, controller.hasNext);
            System.assertEquals(false, controller.hasPrevious);
            
            controller.first();
            System.assertEquals(1,      controller.pageNumber);
            System.assertEquals(false,  controller.hasNext);
            System.assertEquals(false,  controller.hasPrevious);
            
            controller.next();
            System.assertEquals(1,      controller.pageNumber);
            System.assertEquals(false,  controller.hasNext);
            System.assertEquals(false,  controller.hasPrevious);
            
            controller.last();
            System.assertEquals(1,      controller.pageNumber);
            System.assertEquals(false,  controller.hasNext);
            System.assertEquals(false,  controller.hasPrevious);
            
            controller.previous();
            System.assertEquals(1,      controller.pageNumber);
            System.assertEquals(false,  controller.hasNext);
            System.assertEquals(false,  controller.hasPrevious);
        Test.stopTest();
    }
    */
    // STMAddStakeholdersController
    static testMethod void addStakeholdersTest() {
        prepareTestData();
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name FROM Contact]);
        System.assertEquals(AMOUNT_TEST_RECORDS, contactMap.size());
        STMIssue__c issue = STMTestHelper.getIssue();
        
        List<STMIssueScore__c> stmIssueScoreList = [SELECT Id FROM STMIssueScore__c];
        System.assertEquals(0, stmIssueScoreList.size());
        
        Test.startTest();
            Set<Id> contactSetId = contactMap.keySet();
            List<String> stringId = convertToStringList(contactSetId);
            
            STMAddStakeholdersController.addStakeholders(String.join(stringId, ':'), String.valueOf(issue.Id));
            
            stmIssueScoreList = [SELECT Id, Contact__c, Issue__c FROM STMIssueScore__c];
            System.assertEquals(AMOUNT_TEST_RECORDS, stmIssueScoreList.size());
            
            for(STMIssueScore__c stmIssue : stmIssueScoreList) {
                System.assertEquals(true, contactSetId.contains(stmIssue.Contact__c));
                System.assertEquals(true, stmIssue.Issue__c == issue.Id);
            }
        Test.stopTest();
    }
    
    private static List<String> convertToStringList(Set<Id> ids) {
        return String.join(new List<Id>(ids), ',').split(',');
    }
    
    private static void prepareTestData() {
        List<Contact> contactList = new List<Contact>();
        List<STMG_Type__c> types = new List<STMG_Type__c>();
        Account company = STMTestHelper.getCompany();
        Contact tmpContact = null;
        for(Integer i = 0; i < AMOUNT_TEST_RECORDS; i++) {
           tmpContact = STMTestHelper.createStkhContact('testContact' + i, company);
           contactList.add(tmpContact);
        }
        insert contactList;
        
        for(Contact cnt : contactList) {
           types.add(STMTestHelper.createType(cnt));
           cnt.STMActive__c = true;
        }
        insert types;
        update contactList;
    }
    
    // STMStakeholderMappingMapByIssue
    static testMethod void smokeSTMStakeholderMappingController() {
        PageReference pageRef = Page.STMStakeholderMappingMapByIssue;
        System.assertNotEquals(null, pageRef);
        Test.setCurrentPage(pageRef);
        STMIssue__c issue = STMTestHelper.getIssue();
        STMTestHelper.addIssueScoresToSpecifiedIssue(issue, AMOUNT_INSERTED_ISSUESCORES);
        ApexPages.StandardController sc = new ApexPages.StandardController(issue);
        STMStakeholderMappingController controller = new STMStakeholderMappingController(sc);
        
        controller.showStakeholdersWithSameScore();
        
        List<STMStakeholderMappingController.STM2Stakeholder> stmList = STMStakeholderMappingController.loadStakeholdersByIssue(null, null, null, null);
        System.assertEquals(null, stmList);
        
        stmList = STMStakeholderMappingController.loadStakeholdersByIssue((String)issue.id, '10', '1', '1');
        System.assertNotEquals(null, stmList);
        System.assertEquals   (AMOUNT_INSERTED_ISSUESCORES, stmList.size());
        
        STMStakeholderMappingController.STM2Stakeholder stkh = new STMStakeholderMappingController.STM2Stakeholder(4.11, 1.44, 'accountName','test');
        System.assertEquals(4.11,          stkh.influenceScore);
        System.assertEquals(1.44,          stkh.attitudeScore);
        System.assertEquals('accountName', stkh.accountName);
        System.assertEquals('test',        stkh.Id);
        
        controller.multiStkhListViewWasActivated = true;
        System.assertEquals(true, controller.multiStkhListViewWasActivated);
        controller.disbleMultiStkhListViewWasActivated();
        System.assertEquals(false, controller.multiStkhListViewWasActivated);
    }
    
    // STMIssueEvolutionMap
     private static testMethod void smokeSTMIssueEvolutionMapController() {
        PageReference pageRef = Page.STMIssueEvolutionMap;
        System.assertNotEquals(null, pageRef);
        Test.setCurrentPage(pageRef);
        
        STMIssueScore__c issueScore = STMTestHelper.getIssueScore();
        ApexPages.StandardController sc = new ApexPages.StandardController(issueScore);
        STMIssueEvolutionMapController controller = new STMIssueEvolutionMapController(sc);
        
        List<STMIssueEvolutionMapController.IssueScoreHistory> resultList = STMIssueEvolutionMapController.loadIssueScoreHistories(null);
        System.assertEquals(null, resultList);
        resultList = STMIssueEvolutionMapController.loadIssueScoreHistories(issueScore.Id);
        System.assertNotEquals(null, resultList);
        System.assertEquals(1, resultList.size());
    }
    
}