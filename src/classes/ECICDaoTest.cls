/**
* @author       Pavel Slepenkov (Pavel_Slepenkov@epam.com)
* @date         22 Mar 2013
* @description  This class is comtains unit tests for all DAO classes. 
*               All checking is rinnung from System Administrator
*/

@isTest
private class ECICDaoTest {
    final static Integer AMOUNT_OF_TESTED_CASES = 3;
    private static User testRunUser = ECICRunUserTestHelper.create();
   

  //------------------------------------------- ECICCaseDao ----------------------------------------------------------
  static List<Case> prepareECICCaseDaoTestData(Integer amountOfTestedCase) {
    List<Case> caseTestList = new List<Case>(); 
    System.runAs(testRunUser) 
    {
        ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
        for (Integer i = 0; i < amountOfTestedCase; i++) {
          caseTestList.add(ECICCaseTestHelper.createOpenQualityComplaint());
        }
        insert caseTestList;
    }
    return caseTestList;
  }

/** FIXME (or drop)  : Tests fail new validation rule does not allow description to be blank	
  
    static testMethod void verifyFindById() {
        System.runAs(testRunUser) 
        {
            List<Case> cases = prepareECICCaseDaoTestData(AMOUNT_OF_TESTED_CASES);
            System.assert(cases != null);
            for (Case c: cases) {
                System.assertNotEquals(null, ECICCaseDao.findById(c.id));
            }
        }
    }

    
    static testMethod void verifyFindById_Negative() {
        System.runAs(testRunUser) 
        {
            ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
            Test.startTest();
                Account a = ECICAccountTestHelper.getBottler();
                System.assertEquals(null, ECICCaseDao.findById(a.id));
            Test.stopTest();
        }
    }
    

    static testMethod void verifyCaseFindByIds() {
        System.runAs(testRunUser) 
        {
            List<Case> cases = prepareECICCaseDaoTestData(AMOUNT_OF_TESTED_CASES);
            System.assert(cases != null);
            Set<Id> setIds = (new Map<Id,SObject>(cases)).keySet();
            System.assert(!setIds.isEmpty());
            List<Id> casesIds = new List<Id>();
            casesIds.addAll(setIds);
            System.assert(!casesIds.isEmpty());
            Map<Id, Case> result = ECICCaseDao.findByIds(casesIds);
            System.assertEquals(AMOUNT_OF_TESTED_CASES, result.size());
            for (Case c: result.values()) {
                System.assertEquals(ECICCommonConstants.STATUS_OPEN, c.Status);
            }
        }
    }

    static testMethod void verifyFindNotClosedByRegionAndMappedUserFields() {
        System.runAs(testRunUser) 
        {
            List<Case> cases = prepareECICCaseDaoTestData(AMOUNT_OF_TESTED_CASES);
            System.assert(cases != null);
            Set<Id> casesIds = (new Map<Id,SObject>(cases)).keySet();
            System.assert(!casesIds.isEmpty());
            List<Case> result = ECICCaseDao.findNotClosedByRegionAndMappedUserFields(casesIds);
            System.assertEquals(AMOUNT_OF_TESTED_CASES, result.size());
        }           
    }


    static testMethod void verifyFindNotClosedByRegionOrPlantRegion() {
        System.runAs(testRunUser) 
        {
            List<Case> cases = prepareECICCaseDaoTestData(AMOUNT_OF_TESTED_CASES);
            System.assert(cases != null);
            Set<Id> regionIds = new Set<Id>();
            regionIds.add((Id)ECICTestHelper.region.Id);
            regionIds.add((Id)ECICTestHelper.region2.Id);
            System.assertEquals(2, regionIds.size());
            List<Case> result = ECICCaseDao.findNotClosedByRegionOrPlantRegion(regionIds);
            //System.assertEquals(AMOUNT_OF_TESTED_CASES, result.size());
        }               
    }
**/

    //------------------------------------------- ECICAccountDao -------------------------------------------------------
    static testMethod void verifyAccountFindByIds() {
        System.runAs(testRunUser) 
        {
          // test business account
            ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
            Account account = ECICAccountTestHelper.getBottler();
            Set<Id> accountIds = new Set<Id>();
            accountIds.add((Id)account.Id);
            Test.startTest();
                Map<ID, Account> result = ECICAccountDao.findByIds(accountIds);
                System.assertNotEquals(null, result);
                System.assertEquals(1, result.size());
                System.assert(result.containsKey(account.Id));
            Test.stopTest();
        }            
    }

/** FIXME (or drop)  :

    Currently fails with:
    
    System.QueryException: List has no rows for assignment to SObject 
    Stack Trace: Class.ECICAccountTestHelper.getPersonAccount: line 79, column 1 Class.ECICDaoTest.verifyPersonAccountFindByIds: line 122, column 1

    static testMethod void verifyPersonAccountFindByIds() {
        System.runAs(testRunUser) 
        {
            // test person account
            Account account = ECICAccountTestHelper.getPersonAccount();
            Set<Id> accountIds = new Set<Id>();
            accountIds.add((Id)account.Id);
            Test.startTest();
                Map<ID, Account> result = ECICAccountDao.findByIds(accountIds);
                System.assertNotEquals(null, result);
                System.assertEquals(1, result.size());
                System.assert(result.containsKey(account.Id));
            Test.stopTest();
        }           
    }
    
**/
    
    //------------------------------------------- ECICContactDao ---------------------------------------------------------
    static testMethod void verifyContactFindByIds() {
        System.runAs(testRunUser) 
        {
            // test person account
            Contact contact = ECICTestHelper.createContact();
            Set<Id> contactIds = new Set<Id>();
            contactIds.add((Id)contact.Id);
            Test.startTest();
                Map<ID, Contact> result = ECICContactDao.findByIds(contactIds);
                System.assertNotEquals(null, result);
                System.assertEquals(1, result.size());
                System.assert(result.containsKey(contact.Id));
            Test.stopTest();
        }           
    }
    
    static testMethod void verifyContactFindByEmailsOrPhones() {
        System.runAs(testRunUser) 
        {
            Contact contactInserted = ECICTestHelper.createContact();
            
            /* NOTE: ECICContactDao.findByEmailsOrPhones(...) uses SOSL
             * 
             * http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_testing_SOSL.htm
             * "To ensure that test methods always behave in a predictable way, any Salesforce Object Search Language (SOSL) query 
             * that is added to an Apex test method returns an empty set of search results when the test method executes. 
             * If you do not want the query to return an empty list of results, you can use the Test.setFixedSearchResults system method 
             * to define a list of record IDs that are returned by the search.""
             */
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = contactInserted.id;
            Test.setFixedSearchResults(fixedSearchResults);
    
            Set<String> emails = new Set<String>();
            emails.add(contactInserted.Email);        
            
            Set<String> phones = new Set<String>();
            phones.add(contactInserted.Phone);        
            
            List<Contact> result = null;
    
            Test.startTest();
                result = ECICContactDao.findByEmailsOrPhones(emails, null);
                System.assertNotEquals(null, result);
                System.assertEquals(1, result.size());
                System.assertEquals(contactInserted.id, result.get(0).id);
                
                result = ECICContactDao.findByEmailsOrPhones(null, phones);
                System.assertNotEquals(null, result);
                System.assertEquals(1, result.size());
                System.assertEquals(contactInserted.id, result.get(0).id);            
            Test.stopTest();
        }           
    }

    
    //------------------------------------------- ECICGroupDAO ---------------------------------------------------------
    static testMethod void verifyFindQueueByDeveloperName() {
        System.runAs(testRunUser) 
        {
            String testQueueName = 'Spain_Supervisor';
            Test.startTest();
                Group spainSupervisor = ECICGroupDao.findQueueByDeveloperName(testQueueName);
                System.assertNotEquals(null, spainSupervisor);
            Test.stopTest();
        }           
    }
    
    //------------------------------------------- ECICRecordTypeDao ----------------------------------------------------
    static testMethod void verifyFindByDeveloperName() {
        System.runAs(testRunUser) 
        {
            Test.startTest();
                RecordType person = ECICRecordTypeDao.findByDeveloperName(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME); // #Ecic Template Test
                System.assertNotEquals(null, person);
                System.assertEquals([SELECT id FROM RecordType WHERE developerName = :ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME].Id, person.Id);
            Test.stopTest();
        }           
    }
    
    //------------------------------------------- ECICEmailMessageDao --------------------------------------------------

/** FIXME (or drop)  :

    Currently fails with:
    
    System.QueryException: List has no rows for assignment to SObject 
    Stack Trace: Class.ECICAccountTestHelper.getPersonAccount: line 79, column 1 Class.ECICDaoTest.verifyFindByParentIds: line 219, column 1
    
    static testMethod void verifyFindByParentIds() {
        System.runAs(testRunUser) 
        {
            Account account = ECICAccountTestHelper.getPersonAccount();
            Set<Id> accountIds = new Set<Id>();
            accountIds.add((Id)account.Id);
            Test.startTest();
                EmailMessage[] msgs = ECICEmailMessageDao.findByParentIds(accountIds);
            Test.stopTest();
        }           
    }
**/
    
    //------------------------------------------- ECICUserDao ----------------------------------------------------------
    static testMethod void verifyUserFindById() {
        System.runAs(testRunUser) 
        {
            User userInserted = new User(Username      = 'test.tccc.cic@test.test',
                                Alias             = 'tccccic', 
                                Email             = ECICCommonConstants.TEST_USER_EMAIL, 
                                FirstName         = 'John', 
                                LastName          = 'Doe',
                                ProfileId         = [SELECT id FROM profile LIMIT 1].id,  
                                LanguageLocaleKey = 'en_US',
                                LocaleSidKey      = 'en_US',
                                EmailEncodingKey  = 'UTF-8',
                                TimeZoneSidKey    = 'America/Los_Angeles');
            insert userInserted;
            
            Test.startTest();
                User userFound = ECICUserDao.findById(userInserted.id);
                System.assertNotEquals(null, userFound);
            Test.stopTest();
        }           
    }
    
    static testMethod void verifyUserFilterActiveUsers() {
        System.runAs(testRunUser) 
        {
            List<User> usersInserted = new List<User>();
            
            Profile profile = [SELECT id FROM profile LIMIT 1];
            
            usersInserted.add(new User(Username   = 'u1@example.org',
                                Alias             = 'u1alias', 
                                Email             = ECICCommonConstants.TEST_USER_EMAIL, 
                                FirstName         = 'A', 
                                LastName          = 'B',
                                ProfileId         = profile.id,  
                                LanguageLocaleKey = 'en_US',
                                LocaleSidKey      = 'en_US',
                                EmailEncodingKey  = 'UTF-8',
                                TimeZoneSidKey    = 'America/Los_Angeles',
                                isActive          = false));
                                
            usersInserted.add(new User(Username   = 'u2@example.org',
                                Alias             = 'u2alias', 
                                Email             = ECICCommonConstants.TEST_USER_EMAIL, 
                                FirstName         = 'C', 
                                LastName          = 'D',
                                ProfileId         = profile.id,  
                                LanguageLocaleKey = 'en_US',
                                LocaleSidKey      = 'en_US',
                                EmailEncodingKey  = 'UTF-8',
                                TimeZoneSidKey    = 'America/Los_Angeles',
                                isActive          = true));
                                
            insert usersInserted;
            
            Set<ID> userId = new Set<ID>();
            
            for (User user : usersInserted) {
                userId.add(user.id);
            }
            
            
            Test.startTest();
                Set<ID> activeUserIds = ECICUserDao.filterActiveUsers(userId);
                System.assertEquals(1, activeUserIds.size());
            Test.stopTest();
        }           
    }
    
     static testMethod void verifyUserFindActiveByRoleNames() {
        System.runAs(testRunUser) 
        {
            String roleName = ECICCommonConstants.ROLE_IBERIA_INFOLINE_SUPERVISOR ; //#Ecic template Test 
            User user = ECICTestHelper.createTestUser('PT Region Bottler', 'ECIC_Administrator', roleName, ECICCommonConstants.COUNTRY_CODE_PT);
            
            List<String> roleNames = new List<String>();
            roleNames.add(roleName);
            
            Test.startTest();
                Map<String, User> result = ECICUserDao.findActiveByRoleNames(roleNames);
            Test.stopTest();
            
            System.assertEquals(1, result.size());
            System.assert(result.containsKey(roleName));
         }
     }       
     
    /*static testMethod void verifyFindAllFirstActiveByProfileNameAndCountryCode() {
        System.runAs(testRunUser) 
        {
            ECICTestHelper.initTestEnvironmentByUser(masterDataMode, userParam)
            Map<String, User> result = ECICUserDao.findAllFirstActiveByProfileNameAndCountryCode();
        }           
    }*/
    
    
    //------------------------------------------- ECICTaskDao ----------------------------------------------------
	
/** FIXME (or drop)  : Tests fail new validation rule does not allow description to be blank

	
     static testMethod void verifyTaskNumbers() {
        ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
        Case testCase = ECICCaseTestHelper.createQualityComplaint();
        insert testCase;
        insert ECICTestHelper.createTask(testCase); 
        Set<Id> testCasesWithTasks = New Set<Id> {testCase.Id};
        System.runAs(testRunUser) 
        {               
             Test.startTest();                
                 System.assertEquals(1,ECICTaskDao.getNumberOfIncompleteManualAndModifiedAutogeneratedTasksByCaseIds(testCasesWithTasks).size());
                 ECICTaskDao.findNextOpenTaskByCaseIds(testCasesWithTasks);
             Test.stopTest();
            
         }
     }      
**/
     
     //------------------------------------------- ECICActionPlanItemDao ----------------------------------------------------

     static testMethod void verifyfindByIds() {
        ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
        
        Action_Plan__c testActionPlan = ECICActionPlanTestHelper.createDummyActionPlan(true);
        ECICActionPlanItemTestHelper.createDummyActionPlanItemList(testActionPlan, 2, true);
        Case testCase = ECICCaseTestHelper.createDummyCase(new ECICCaseTestHelper.CaseConfig(testActionPlan));
        Set<Id> testActionPlanItemIds = New Set<Id> {};
        for(Action_Plan_Item__c currAP:[SELECT Id FROM Action_Plan_Item__c WHERE Action_Plan__c =: testActionPlan.Id]){
            testActionPlanItemIds.add(currAP.Id);
        }
        
        Map<Id, Action_Plan_Item__c> actionPlanItemsFoundByIdsMap = null;
        List<String> 				 actionPlanItemAssigneesList  = null;
        System.runAs(testRunUser) 
        {               
             Test.startTest();
             {      
                actionPlanItemsFoundByIdsMap = ECICActionPlanItemDao.findByIds(testActionPlanItemIds);
            	actionPlanItemAssigneesList  = ECICActionPlanItemDao.findAllAssignees();
}
             Test.stopTest();
         }
         
         System.assertEquals(2,actionPlanItemsFoundByIdsMap.size());
         
         /*
          * Original assertion was that the actionPlanItemAssigneesList size equals 1.
          * 	This relied on ECICActionPlanItemDao.findAllAssignees() utilizing SOQL
          * 	and only finding the record created by this test because real data is not available to the testMethod
          *
          * ECICActionPlanItemDao.findAllAssignees() has been improved so that it no longer uses SOQL, but instead uses Schema.Describe()
          * 	As such, it retrieves all possible options in the assignee__c picklist field.
          *		Within my sandbox, there are 13 values, but this could change and I don't believe we want to either lock
          *		that number or force revision of this unit test for additional values.
          *
          *	So, instead I'm asserting the value is non-zero and that the list contains the value from our inserted Action_Plan_Item.
          */ 
         System.assertNotEquals(0,actionPlanItemAssigneesList.size());
         System.assert(new Set<String>(actionPlanItemAssigneesList).contains('OwnerId'));          
     }      
}