@isTest
private class ECICMapHelperTest {
    private static final User		TEST_RUN_USER			=	ECICRunUserTestHelper.create();
    private static final Integer	OBJECTS_AMOUNT			=	3;

    private static void castMethodsTest(String objName, Boolean isIdToString) {
        System.runAs(TEST_RUN_USER) {
            ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
            String extraFields = '';
            String fromObject = objName;
            if (objName == 'SObject' || objName == 'Case') {
                fromObject = 'Case';
                prepareCaseTestData();
            } else if (objName == 'Id' || objName == 'Contact') {
                fromObject = 'Contact'; 
                extraFields += ', ownerId ';
                prepareContactTestData();
            }
            
            Test.startTest();
                List<sObject> sObjectList = Database.query('SELECT Id ' + extraFields + 'FROM ' + fromObject + ' LIMIT :OBJECTS_AMOUNT');
                System.assertEquals(OBJECTS_AMOUNT, sObjectList.size());
                
                Set<Id> initialKeys = getInitialKeySet(sObjectList);
                
                if (isIdToString) {
                    Set<String> returnedKeys = verifyCastIdToStringMethods(objName, sObjectList);
                    System.assert(initialKeys.equals(returnedKeys));
                } else {
                    Set<Id> returnedKeys = verifyCastStringToIdMethods(objName, sObjectList);
                    System.assert(initialKeys.equals(returnedKeys));
                }
            Test.stopTest();
        }
    }

/** FIXME (or drop)  : Tests fail new validation rule does not allow description to be blank
    static testMethod void castIdMapToStringMapCaseTest()     { castMethodsTest('Case',     true);  }
    static testMethod void castIdMapToStringMapSObjectTest()  { castMethodsTest('SObject',  true);  }
    static testMethod void castObjectMapToCaseMapTest()       { castMethodsTest('Case',     false); }
    static testMethod void castStringMapToIdMapSObjectTest()  { castMethodsTest('SObject',  false); }
**/	
    
    static testMethod void castIdMapToStringMapContactTest()  { castMethodsTest('Contact',  true);  }
    static testMethod void castIdMapToStringMapIDTest()       { castMethodsTest('Id',       true);  }
    static testMethod void castStringMapToIdMapUserRoleTest() { castMethodsTest('UserRole', false); }
    static testMethod void castStringMapToIdMapProfileTest()  { castMethodsTest('Profile',  false); }
    
    private static Set<String> verifyCastIdToStringMethods(String objName, List<sObject> sObjectList) {
        Set<String> returnedKeys = null;
        if (objName == 'SObject') {
            returnedKeys = ECICMapHelper.castIdMapToStringMap(getSObjectMap(sObjectList)).keySet();
        } else if(objName == 'Case') {
            returnedKeys = ECICMapHelper.castIdMapToStringMap(getCaseMap(sObjectList)).keySet();
        } else if(objName == 'Contact') {
            returnedKeys = ECICMapHelper.castIdMapToStringMap(getContactMap(sObjectList)).keySet();
        } else if(objName == 'Id') {
            returnedKeys = ECICMapHelper.castIdMapToStringMap(getIdMap(sObjectList)).keySet();
        }
        return returnedKeys;
    }
    
    private static Set<Id> verifyCastStringToIdMethods(String objName, List<sObject> sObjectList) {
        Set<Id> returnedKeys = null;
        if (objName == 'Case') {
            returnedKeys = ECICMapHelper.castObjectMapToCaseMap(getCaseMapId(sObjectList)).keySet();
        } else if(objName == 'SObject') {
            returnedKeys = ECICMapHelper.castStringMapToIdMap(getsObjectMapId(sObjectList)).keySet();
        } else if(objName == 'UserRole') {
            returnedKeys = ECICMapHelper.castStringMapToIdMap(getUserRoleMapId(sObjectList)).keySet();
        } else if(objName == 'Profile') {
            returnedKeys = ECICMapHelper.castStringMapToIdMap(getProfileMapId(sObjectList)).keySet();
        }
        return returnedKeys;
    }
    
    private static Set<Id> getInitialKeySet(List<sObject> objList) {
        Set<ID> keySet = new Set<ID>();
        for (sObject obj : objList) {
            keySet.add(obj.Id);
        }
        return keySet;
    }
    
    private static Map<ID, SObject> getSObjectMap(List<sObject> objList) {
        Map<ID, SObject> returnMap = new Map<ID, SObject>();
        for (sObject obj : objList) {
            returnMap.put(obj.Id, obj);
        }
        return returnMap;
    }
    
    private static Map<ID, Case> getCaseMap(List<sObject> objList) {
        Map<ID, Case> returnMap = new Map<ID, Case>();
        for (Case cs : (List<Case>)objList) {
            returnMap.put(cs.Id, cs);
        }
        return returnMap;
    }
    
    private static Map<ID, Contact> getContactMap(List<sObject> objList) {
        Map<ID, Contact> returnMap = new Map<ID, Contact>();
        for (Contact ct : (List<Contact>)objList) {
            returnMap.put(ct.Id, ct);
        }
        return returnMap;
    }
    
    private static Map<ID, ID> getIdMap(List<sObject> objList) {
        Map<ID, ID> returnMap = new Map<ID, ID>();
        for (Contact ct : (List<Contact>)objList) {
            returnMap.put(ct.Id, ct.ownerId);
        }
        return returnMap;
    }
    
    private static Map<ID, sObject> getCaseMapId(List<sObject> objList) {
        Map<ID, sObject> returnMap = new Map<ID, sObject>();
        for (Case cs : (List<Case>)objList) {
            returnMap.put(cs.Id, cs);
        }
        return returnMap;
    }
    
    private static Map<String, SObject> getsObjectMapId(List<sObject> objList) {
        Map<String, SObject> returnMap = new Map<String, sObject>();
        for (Case cs : (List<Case>)objList) {
            returnMap.put(String.valueOf(cs.Id), cs);
        }
        return returnMap;
    }
    
    private static Map<String, UserRole> getUserRoleMapId(List<sObject> objList) {
        Map<String, UserRole> returnMap = new Map<String, UserRole>();
        for (UserRole ur : (List<UserRole>)objList) {
            returnMap.put(String.valueOf(ur.Id), ur);
        }
        return returnMap;
    }
    
    private static Map<String, Profile> getProfileMapId(List<sObject> objList) {
        Map<String, Profile> returnMap = new Map<String, Profile>();
        for (Profile pr : (List<Profile>)objList) {
            returnMap.put(String.valueOf(pr.Id), pr);
        }
        return returnMap;
    }

    // -------------------------------------------------------------------------------------------------
    
    private static void createMapIdentifierTest(Boolean hasId) 
    {
		TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
        Case testCase = TEST_DummyInquiryCaseFactory.create(config, TEST_DummyInsertModeEnum.NONE);
          	 testCase.id = (hasId) ? '50011000001FTZs' : null;

        String returnString = null;
        System.runAs(TEST_RUN_USER) 
        {
            Test.startTest();
            {
                 returnString = ECICMapHelper.createMapIdentifier(testCase, true);
            }
            Test.stopTest();
        }

        String expectedIdentifier = (hasId)
        								? (String) testCase.id
        								: 'Case' + testCase.Origin + testCase.suppliedEmail + testCase.Subject;
        System.assertEquals(expectedIdentifier, returnString);
    }
    
    private static testMethod void withIdCreateMapIdentifierTest() 	  { createMapIdentifierTest(true);  }
    private static testMethod void withoutIdCreateMapIdentifierTest() { createMapIdentifierTest(false); }

    // -------------------------------------------------------------------------------------------------

    private static void prepareCaseTestData() {
        List<Case> caseList = new List<Case>();
        for(Integer i = 0; i < OBJECTS_AMOUNT; i++) {
            caseList.add(ECICCaseTestHelper.createQualityComplaint());
        }
        
        insert caseList;
    }
    
    private static void prepareContactTestData() {
        TEST_DummyContactFactory.createDummyList(OBJECTS_AMOUNT, true);
    }
}