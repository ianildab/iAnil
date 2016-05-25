@isTest
private class STMTypeTest {
    private final static String COMMON_ERROR_MSG = 'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, ';
    private final static String DELETE_ERROR_MSG = 'This Type cannot be deleted from this Active Stakeholder, because a Stakeholder should have at least one Type defined.';
    private final static Integer BATCH_SIZE = 3;
    /* Test case:
            insert stakeholder1
            link type1 with set1 of field values to stakeholder1
            link type2 with set1 of field values to stakeholder1
            >> ERROR 
    */    
    
    static void insertValidation(List<sObject> objList, Boolean isExists) {
        System.assertNotEquals(null, objList);
        System.assertEquals(BATCH_SIZE, objList.Size());
        if (isExists) {
            STMG_Type__c existsType                  = STMTestHelper.createType(objList[0]);
            existsType.Stakeholder_specialization__c = 'Education';
            insert existsType;
        }
        
        insert getSTMGTypes(objList);
        
        STMG_Type__c type2 = STMTestHelper.createType(objList[0]);
        try {
            insert type2;
        } catch (System.Dmlexception ex) {
            System.assertEquals(COMMON_ERROR_MSG + System.Label.typeDuplication + ': []', ex.getMessage() );
        }
    }
    
    static void deleteValidation(sObject obj) {
        if (obj instanceof Account && obj.get('IsPersonAccount') == false) {
            insert STMTestHelper.createType(obj);
        }
        System.assertNotEquals(null, obj);
        
        List<STMG_Type__c> typeList = [SELECT Id, Stakeholder_type__c, Stakeholder_specialization__c, 
                                              Stakeholder_subspecialization__c, Positions__c FROM STMG_Type__c];
        System.assertEquals(1, typeList.size());
        try {
            delete typeList;
            System.assertEquals(0,    [SELECT Count() FROM STMG_Type__c]);
        } catch (System.Dmlexception ex) {
            System.assertEquals(true, ex.getMessage().contains(DELETE_ERROR_MSG + ': []'));
            System.assertEquals(1,    [SELECT Count() FROM STMG_Type__c]);
        }
        
    }
    
    static void updateValidation(sObject obj) {
        if (obj instanceof Account && obj.get('IsPersonAccount') == false) {
            insert STMTestHelper.createType(obj);
        }
        System.assertNotEquals(null, obj);
        
        List<STMG_Type__c> typeList = [SELECT Id, Stakeholder_type__c, Stakeholder_specialization__c, 
                                              Stakeholder_subspecialization__c, Positions__c FROM STMG_Type__c];
        System.assertEquals(1,                               typeList.size());
        System.assertEquals(null,                            typeList[0].Positions__c);
        System.assertEquals('Non-Govenmental Organizations', typeList[0].Stakeholder_type__c);
        typeList[0].Positions__c        = 'Director';
        typeList[0].Stakeholder_type__c = 'Government';
        update typeList[0];
        
        System.assertEquals('Director',   typeList[0].Positions__c       );
        System.assertEquals('Government', typeList[0].Stakeholder_type__c);
    }
    
    //--------------------- Test execution section ---------------------------------------------------------------------
    //INSERT Tests
    static testMethod void verifyAccountBatchInsert()             { insertValidation(getCompanyAccount(), false); }
    static testMethod void verifyAccountBatchInsertWithExisting() { insertValidation(getCompanyAccount(), true);  }
    static testMethod void verifyPersonAccountBatchInsert()       { insertValidation(getPersonAccount(),  false); }
    static testMethod void verifyPersonAccBatchInsWithExisting()  { insertValidation(getPersonAccount(),  true);  }
    static testMethod void verifyContactBatchInsert()             { insertValidation(getContact(),        false); }
    static testMethod void verifyContactBatchInsertWithExisting() { insertValidation(getContact(),        true);  }
    
    //DELETE Tests
    static testMethod void verifyAccountDeleteValidation()        { deleteValidation(STMTestHelper.getCompany());       }
    static testMethod void verifyPersonAccountDeleteValidation()  { deleteValidation(STMTestHelper.getPersonAccount()); }
    static testMethod void verifyContactDeleteValidation()        { deleteValidation(STMTestHelper.getStkhContact());   }
    
    //UPDATE Tests
    static testMethod void verifyAccountUpdateValidation()        { updateValidation(STMTestHelper.getCompany());       }
    static testMethod void verifyPersonAccountUpdateValidation()  { updateValidation(STMTestHelper.getPersonAccount()); }
    static testMethod void verifyContactUpdateValidation()        { updateValidation(STMTestHelper.getStkhContact());   }
    
    //------------------------------------------------------------------------------------------------------------------
    private static List<STMG_Type__c> getSTMGTypes(List<sObject> objList) {
        List<STMG_Type__c> typesList = new List<STMG_Type__c>();
        for (sObject obj : objList) {
            typesList.add(STMTestHelper.createType(obj));
        }
        
        return typesList;
    }
    
    private static List<Account> getCompanyAccount() {
        List<Account> accList = new List<Account>();
        for (Integer i = 0; i < BATCH_SIZE; i++) {
            accList.add(STMTestHelper.createCompany('testAccount' + i));
        }
        
        insert accList;
        return [SELECT Id, Name, Type, isPersonAccount FROM Account];
    }
    
    private static List<Account> getPersonAccount() {
        List<Account> accList = new List<Account>();
        for (Integer i = 0; i < BATCH_SIZE; i++) {
            accList.add(STMTestHelper.createPersonAccount('testPersonAccount' + i));
        }
        insert accList;
        return [SELECT id, PersonContactId, RecordTypeId, Name, isPersonAccount, Active__c FROM Account];
    }
    
    private static List<Contact> getContact() {
        List<Contact> contactList = new List<Contact>();
        Account testAccount       = STMTestHelper.getCompany();
        for (Integer i = 0; i < BATCH_SIZE; i++) {
            contactList.add(STMTestHelper.createStkhContact('testContact' + i, testAccount));
        }
        
        insert contactList;
        return [SELECT Id, Name FROM Contact];
    }

}