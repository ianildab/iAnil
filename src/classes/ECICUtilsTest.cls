@isTest
private class ECICUtilsTest {
    private static final User       TEST_RUN_USER   = ECICRunUserTestHelper.create();
    private static final Integer    OBJECT_COUNT    = 3;
    private static final Integer    PERIOD          = 7;
    private static final Integer    THRESHOLD       = 3;
    
    static testMethod void createMailsTest() {
        EmailTemplate eTemplate                     = [SELECT Id, Name, DeveloperName FROM EmailTemplate LIMIT 1];
        Closed_Trend__c testObject                  = prepareSObject(TEST_DummyInsertModeEnum.MOCK);
        Messaging.SingleEmailMessage resultMessage  = null;
        
        System.runAs(TEST_RUN_USER) {
            Test.StartTest();
            {
                resultMessage = ECICUtils.createMail(testObject, eTemplate.Id, new List<String>{ECICCommonConstants.EMAIL}, TEST_RUN_USER.Id);
            }
            Test.StopTest();
        }
        
        System.assertNotEquals(null, resultMessage);
        System.assertEquals(eTemplate.Id,               resultMessage.getTemplateId());
        System.assertEquals(TEST_RUN_USER.Id,           resultMessage.getTargetObjectId());
        System.assertEquals(ECICCommonConstants.EMAIL,  resultMessage.getToAddresses()[0]);
        System.assertEquals(testObject.Id,              resultMessage.getWhatId());
    }
    
    // ----------------------------------------------------------------------------------------------------------
    
    static void sendMailsTest(Boolean isAllOrNone) {
        EmailTemplate eTemplate                     = [SELECT Id, Name, DeveloperName FROM EmailTemplate LIMIT 1];
        TEST_DummyInsertModeEnum insertionType      = (isAllOrNone == true) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.MOCK;
        Closed_Trend__c testObject                  = prepareSObject(insertionType);
        TEST_DummyContactFactory.Config contactConfig = new TEST_DummyContactFactory.Config();
                                        contactConfig.email = ECICCommonConstants.EMAIL;
        
        Contact testContact                         = TEST_DummyContactFactory.create(contactConfig, insertionType);
        Messaging.SingleEmailMessage emailMessage   = ECICUtils.createMail(testObject, eTemplate.Id, new List<String>{ECICCommonConstants.EMAIL}, testContact.Id);
        Integer emailLimitBefore                    = Limits.getEmailInvocations();
        Integer emailLimitAfter                     = null;
        
        System.runAs(TEST_RUN_USER) {
            Test.StartTest();
            {
                if (isAllOrNone == null) {
                    ECICUtils.sendMails(new List<Messaging.Email>{emailMessage});
                } else {
                    ECICUtils.sendMails(new List<Messaging.Email>{emailMessage}, isAllOrNone);
                }
                emailLimitAfter = Limits.getEmailInvocations();
            }
            Test.StopTest();
        }
        System.assertNotEquals(emailLimitBefore, emailLimitAfter);
    }
    
    static testMethod void sendMailsAllOrNoneNullTest()     { sendMailsTest(null); }
    static testMethod void sendMailsAllOrNoneTrueTest()     { sendMailsTest(true); }
    static testMethod void sendMailsAllOrNoneFalseTest()    { sendMailsTest(false); }
    
    // ----------------------------------------------------------------------------------------------------------
    
    static testMethod void collectRecipientsAddressesTest() {
            EmailTemplate eTemplate             = [SELECT Id, Name, DeveloperName FROM EmailTemplate LIMIT 1];
            Map<sObject, Set<Id>> recipientsMap = new Map<sObject, Set<Id>>();
            List<User> userList                 = prepareUsers(OBJECT_COUNT);
            List<sObject> objectList            = prepareSObjects(OBJECT_COUNT);
            Map<Id, User> userMap               = new Map<Id, User>(userList);
            List<Messaging.Email> emailList     = null;
            
            for (sObject obj : objectList) {
                recipientsMap.put(obj, userMap.keySet());
            }
            
            System.runAs(TEST_RUN_USER) {
                Test.StartTest();
                {
                    emailList = ECICUtils.collectRecipientsAddressesAndCreateMails(recipientsMap, userMap.keySet(), eTemplate.Id);
                }
                Test.StopTest();
            }
            
            System.assertEquals(userMap.keySet().size(), emailList.size());
    }
    
    private static void getRecipients(Boolean isArray) {
        Set<Id> resultSet       = null;
        String recipientsStr    = String.join(ECICCommonConstants.USER_FIELDS, ECICCommonConstants.SEMICOLON);
        List<String> recipients = ECICCommonConstants.USER_FIELDS;
        List<Case> cases        = prepareCases(OBJECT_COUNT, TEST_DummyInsertModeEnum.NONE);
        
        System.runAs(TEST_RUN_USER) {
            Test.StartTest();
            {
                if (isArray) {
                    resultSet = ECICUtils.getRecipients(cases, recipients);
                } else {
                    resultSet = ECICUtils.getRecipients(cases, recipientsStr);
                }
            }
            Test.StopTest();
        }
        
        System.assertEquals(1, resultSet.size());
        System.assertEquals(true, resultSet.contains(TEST_RUN_USER.Id));
    }
    
    static testMethod void getRecipientsArrayTest()     { getRecipients(true); }
    static testMethod void getRecipientsStringTest()    { getRecipients(false); }
    
    // ----------------------------------------------------------------------------------------------------------
    
    private static void isEmptyTest(String inputStr) {
        Boolean result = null;
        System.runAs(TEST_RUN_USER) {
            Test.StartTest();
            {
                result = ECICUtils.isEmpty(inputStr);
            }
            Test.StopTest();
        }
        
        System.assertEquals(true, result);
    }
    
    static testMethod void stringNullTest()     { isEmptyTest(null); }
    static testMethod void stringEmptyTest()    { isEmptyTest(''); }
    
    // ----------------------------------------------------------------------------------------------------------
    
    static testMethod void buildQueryTest() {
        Map<String, Set<String>> conditionMap = new Map<String, Set<String>>();
        conditionMap.put('Category_Level3__c', new Set<String>{'c3value1','c3value2','c3value3'});
        conditionMap.put('Category_Level4__c', new Set<String>{'c4value1','c4value2'});
        String fromObject           = 'TestObject';
        List<String> queryFields    = new List<String>{'field1','field2'};
        List<String> fieldCondtions = new List<String>{'field3 = 1', 'field4 = \'zzz\''};
        String resultString         = null;
        
        System.runAs(TEST_RUN_USER) {
            Test.StartTest();
            {
                resultString = ECICUtils.buildQuery(conditionMap, queryFields, fromObject, fieldCondtions);
            }
            Test.StopTest();
        }
        
        String testContainsString1 = String.join(queryFields, ECICCommonConstants.COMMA_DEL);
        String testContainsString2 = ' FROM ' + fromObject;
        String testContainsString3 = 'Category_Level3__c IN (' + String.join(new List<String>(conditionMap.get('Category_Level3__c')), ECICCommonConstants.COMMA_DEL) + ')';
        String testContainsString4 = 'Category_Level4__c IN (' + String.join(new List<String>(conditionMap.get('Category_Level4__c')), ECICCommonConstants.COMMA_DEL) + ')';
        String testContainsString5 = String.join(fieldCondtions, ' AND ');
        
        System.assertNotEquals(null, resultString);
        System.assertEquals(true, resultString.contains(testContainsString1));
        System.assertEquals(true, resultString.contains(testContainsString2));
        System.assertEquals(true, resultString.contains(testContainsString3));
        System.assertEquals(true, resultString.contains(testContainsString4));
        System.assertEquals(true, resultString.contains(testContainsString5));
    }
    
    // ----------------------------------------------------------------------------------------------------------
    
    static void createCategoryKeysAPTest(Boolean isNullFields) {
        Action_Plan__c ap                       = (isNullFields) ? TEST_DummyActionPlanFactory.createEmpty(TEST_DummyInsertModeEnum.NONE)
                                                                : TEST_DummyActionPlanFactory.create(TEST_DummyInsertModeEnum.NONE);
        List<String> resultList                 = null;
        Map<String, String> notNullFieldsMap    = new Map<String, String> {
            'Case_Reason__c'        => '_2_',
            'Category_Level3__c'    => '_3_',
            'Category_Level4__c'    => '_4_'};
        Map<String, String> nullFieldsMap       = new Map<String, String> {
            'Country_Code__c'       => ''};
        
        Map<String, String> apFieldsForCheck    = (isNullFields) ? nullFieldsMap : notNullFieldsMap;
        
        System.runAs(TEST_RUN_USER) {
            Test.StartTest();
            {
                resultList = ECICUtils.createCategoryKeys(ECICCommonConstants.CASE_CHANNEL_OF_ANSWER, ap);
            }
            Test.StopTest();
        }
        
        Integer expectedSize    = (isNullFields) ? 1 : 3;
        Set<String> resultSet   = new Set<String>(resultList);
        System.assertEquals(expectedSize, resultList.size());
        
        String delim        = '';
        String fieldValue   = '';
        for (String filedName : apFieldsForCheck.keySet()) {
            fieldValue = (String) ap.get(filedName);
            System.assert(fieldValue != null);
            if (!String.isEmpty(fieldValue)) {
                for (String val : fieldValue.split(ECICCommonConstants.SEMICOLON, -1)) {
                    delim = apFieldsForCheck.get(filedName);
                    System.assertEquals(true, resultSet.contains(ap.Country_Code__c + '_' + ECICCommonConstants.CASE_CHANNEL_OF_ANSWER + delim + ((!isNullFields) ? val : '')));
                }
            }
        }
    }
    
    static testmethod void createCategoryKeysNotNullAPTest ()   { createCategoryKeysAPTest(false); }
    static testmethod void createCategoryKeysNullAPTest ()      { createCategoryKeysAPTest(true); }
    
    // ----------------------------------------------------------------------------------------------------------
    
    static testMethod void createCategoryKeysCaseTest() {
        String countryCode      = 'D0';
        String origin           = 'testOrigin';
        String reason           = 'testReason';
        String categoryLevel3   = 'testCatLevel3';
        String categoryLevel4   = 'testCatLevel4';
        String channel          = origin;
        Set<String> resultSet   = null;
        
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.countryCode     = countryCode;
                             caseConfig.origin          = origin;
                             caseConfig.reason          = reason;
                             caseConfig.categoryLevel3  = categoryLevel3;
                             caseConfig.categoryLevel4  = categoryLevel4;
                             
        Case testCase = TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.NONE);
        
        System.runAs(TEST_RUN_USER) {
            Test.StartTest();
            {
                resultSet = new Set<String>(ECICUtils.createCategoryKeys(testCase));
            }
            Test.StopTest();
        }
        
        System.assertEquals(true, resultSet.contains(countryCode + '_' + channel + '_4_' + categoryLevel4));
        System.assertEquals(true, resultSet.contains(countryCode + '__4_' + categoryLevel4));
        System.assertEquals(true, resultSet.contains(countryCode + '_' + channel + '_3_' + categoryLevel3));
        System.assertEquals(true, resultSet.contains(countryCode + '__3_' + categoryLevel3));
        System.assertEquals(true, resultSet.contains(countryCode + '_' + channel + '_2_' + reason));
        System.assertEquals(true, resultSet.contains(countryCode + '__2_' + reason));
        System.assertEquals(true, resultSet.contains(countryCode + '_' + channel));
    }
    
    // ----------------------------------------------------------------------------------------------------------
    
    static testMethod void triggerActiveTest() {
        ApexTrigger testTrigger = [SELECT Id, Name, Status FROM ApexTrigger LIMIT 1];
        Boolean result          = null;
        
        System.runAs(TEST_RUN_USER) {
            Test.StartTest();
            {
                result = ECICUtils.triggerActive(testTrigger.Name);
            }
            Test.StopTest();
        }
        
        System.assertEquals(result, testTrigger.Status == 'Active' ? true : false);
    }
    
    // ----------------------------------------------------------------------------------------------------------
    
    static void resolveOwnerTest(Boolean isUserOwner) {
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.ownerId = (isUserOwner) ? (ECICCaseHelper.GROUP_OBJECT_ID_PREFIX + '11000001FTZs') : TEST_RUN_USER.Id;
        
        Case dummyCase = TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.NONE);
        
        System.runAs(TEST_RUN_USER) {
            Test.StartTest();
            {
                ECICUtils.resolveOwner(new List<Case>{dummyCase}, null, null);
            }
            Test.StopTest();
        }
        
        System.assertEquals(dummyCase.Owner_Lookup__c, isUserOwner ? null: dummyCase.ownerID);
    }
    
    static testmethod void resolveNotNullOwnerTest()    { resolveOwnerTest(true); }
    static testmethod void resolveNullOwnerTest()       { resolveOwnerTest(false); }
    
    // ----------------------------------------------------------------------------------------------------------
    
    /**
      * ECICUtils.resolveCountryCode() and ECICUtils.chooseCountryCode() methods covered by this test class -> 'ECICUtilsChooseCountryCodeTest'
      */
    
    // ----------------------------------------------------------------------------------------------------------
    
    static void isFieldChangedTest(Boolean isFieldChanged) {
        String testFieldName            = 'status';
        Boolean result                  = null;
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.status = 'New';
        
        Case dummyCase1                 = TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.NONE);
        if (isFieldChanged) {caseConfig.status = 'Open';}
        Case dummyCase2                 = TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.NONE);
        
        System.runAs(TEST_RUN_USER) {
            Test.StartTest();
            {
                result = ECICUtils.isFieldChanged(dummyCase1, dummyCase2, testFieldName);
            }
            Test.StopTest();
        }
        
        Boolean expectedResult = isFieldChanged;
        System.assertEquals(expectedResult, result);
    }
    
    static testmethod void isFieldChangedTrueTest()     { isFieldChangedTest(true); }
    static testmethod void isFieldChangedFalseTest()    { isFieldChangedTest(false); }
    
    // ----------------------------------------------------------------------------------------------------------
    
    static void getCountryCodeTest(String emailString) {
        String result = null;
        
        System.runAs(TEST_RUN_USER) {
            Test.StartTest();
            {
                result = ECICUtils.getCountryCode(emailString);
            }
            Test.StopTest();
        }
        
        String expectedResult = (emailString == 'tester@test.es') ? 'ES' : null;
        System.assertEquals(expectedResult, result);
    }
    
    static testmethod void getCountryCodeEmptyEmailTest()   { getCountryCodeTest(''); }
    static testmethod void getCountryCodeEmailType1Test()   { getCountryCodeTest('tester@test.ess'); }
    static testmethod void getCountryCodeEmailType2Test()   { getCountryCodeTest('tester@test.es'); }
    static testmethod void getCountryCodeEmailType3Test()   { getCountryCodeTest('tester@test.e'); }
    
    // ----------------------------------------------------------------------------------------------------------
    
    static testMethod void getSObjectEditableFieldsTest() {
        List<String> fieldList = null;
        
        System.runAs(TEST_RUN_USER) {
            Test.StartTest();
            {
                fieldList = ECICUtils.getSObjectEditableFields('Case');
            }
            Test.StopTest();
        }
        
        System.assert(fieldList.size() > 0);
    }
    
    // ---------------------------------------------------------------------------------------------------------
    
    private static List<User> prepareUsers(Integer countUsers) {
        TEST_DummyUserFactory.Config userConfig = new TEST_DummyUserFactory.Config(TEST_DummyUserFactory.ES_INFOLINE_AGENT_PARAM);
        return TEST_DummyUserFactory.createList(countUsers, userConfig, TEST_DummyInsertModeEnum.REAL); 
    }
    
    private static List<Closed_Trend__c> prepareSObjects(Integer countObjects) {
        List<TEST_DummyClosedTrendFactory.Config> configList = new List<TEST_DummyClosedTrendFactory.Config>();
        for (Integer i = 0; i < countObjects; i++) {
            TEST_DummyClosedTrendFactory.Config closedTrendConfig = new TEST_DummyClosedTrendFactory.Config();
                                                closedTrendConfig.period    = PERIOD + i;
                                                closedTrendConfig.threshold = THRESHOLD + i;
            configList.add(closedTrendConfig);
        }
        
        return TEST_DummyClosedTrendFactory.createList(configList, TEST_DummyInsertModeEnum.MOCK);
    }
    
    private static Closed_Trend__c prepareSObject(TEST_DummyInsertModeEnum insertType) {
            TEST_DummyClosedTrendFactory.Config closedTrendConfig = new TEST_DummyClosedTrendFactory.Config();
                                                closedTrendConfig.period    = PERIOD;
                                                closedTrendConfig.threshold = THRESHOLD;
        
        return TEST_DummyClosedTrendFactory.create(closedTrendConfig, insertType);
    }
    
    private static List<Case> prepareCases(Integer numberOfCases, TEST_DummyInsertModeEnum insertMode) {
        List<Case> testCaseList = TEST_DummyFastQualityComplaintCaseFactry.createList(numberOfCases, new TEST_DummyCaseConfig(), insertMode);
        
        for (String userField : ECICCommonConstants.USER_FIELDS) {
            for (Case testCase : testCaseList) {
                testCase.put(userField, TEST_RUN_USER.Id);
            }
        }
        
        return testCaseList;
    }
}