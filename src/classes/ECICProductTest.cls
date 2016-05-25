@isTest
private class ECICProductTest {
  
    static Product__c product;
    static final String PRODUCT_NAME_FOR_CREATION      = 'Coca-Cola';
    static final String PRODUCT_NAME                   = 'Coca-Cola Light';
    static final String PRODUCT_NAME_NEW               = 'Fanta';
  
    static void prepareTestData() {
        product = ECICTestHelper.createProduct(PRODUCT_NAME_FOR_CREATION, 6, 'Month');
        product.International_Name__c = PRODUCT_NAME;
        insert product;
    }
  
    static void fillingName() {
        prepareTestData();
        product = [SELECT Id, Name, International_Name__c FROM Product__c WHERE id =: product.Id];
        System.assertEquals(PRODUCT_NAME, product.Name);
        System.assertEquals(PRODUCT_NAME, product.International_Name__c);
    }

    static void deactivateProductBasedOnCurrentlySold() {
        prepareTestData();
        product.Currently_Sold__c = false;
        update product;
        product = [SELECT Id, Active__c, Currently_Sold__c FROM Product__c WHERE id =: product.Id];
        System.assertEquals(false, product.Currently_Sold__c);
        System.assertEquals(false, product.Active__c);
    }
    
    static void reactivateProductBasedOnCurrentlySold() {
      deactivateProductBasedOnCurrentlySold();
      product.Currently_Sold__c = true;
        update product;
        product = [SELECT Id, Active__c, Currently_Sold__c FROM Product__c WHERE id =: product.Id];
        System.assertEquals(true, product.Currently_Sold__c);
        System.assertEquals(true, product.Active__c);
    }
    
    static void updateInternationalName() {
        prepareTestData();
        product = [SELECT Id, Name, International_Name__c FROM Product__c WHERE id =: product.Id];
        System.assertEquals(PRODUCT_NAME, product.Name);
        System.assertEquals(PRODUCT_NAME, product.International_Name__c);
        product.International_Name__c = PRODUCT_NAME_FOR_CREATION;
        update product;
        product = [SELECT Id, Name, International_Name__c FROM Product__c WHERE id =: product.Id];
        System.assertEquals(PRODUCT_NAME, product.Name);
        System.assertEquals(PRODUCT_NAME_FOR_CREATION, product.International_Name__c);
    }
    
    static void skipTriggerInvocation() {
        SEPTriggerHandlerInvoker.pretendTestNotRunning = true;
        General_Settings__c generalSettings = new General_Settings__c();
        generalSettings.skipTriggers__c = true;
        
        System.assertEquals(false, SEPTriggerHandlerInvoker.skipTriggerInvocation());
        upsert generalSettings;
        System.assertEquals(true, SEPTriggerHandlerInvoker.skipTriggerInvocation());
        
        prepareTestData();
        Product__c prod = [SELECT Id, Name, Active__c, Currently_Sold__c, International_Name__c FROM Product__c LIMIT 1];
        System.assert(prod.Name != prod.International_Name__c);
    }

//**********************************************************************************************************************
    static testMethod void verifyFillingInternationalName() {
        fillingName();
    }
    
    static testMethod void verifyFillingInternationalName_ESInfAgent() {
        System.runAs(ECICTestHelper.initTestEnvironmentByUser(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE,
                     ECICRunUserTestHelper.ES_INFOLINE_AGENT_PARAM)) {
               fillingName();
        }
    }

//----------------------------------------------------------------------------------------------------------------------

    static testMethod void verifyDeactivateProductBasedOnCurrentlySold() {
        deactivateProductBasedOnCurrentlySold(); 
    }
    
    static testMethod void verifyDeactivateProductBasedOnCurrentlySold_ESInfAgent() {
        System.runAs(ECICTestHelper.initTestEnvironmentByUser(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE,
                    ECICRunUserTestHelper.ES_INFOLINE_AGENT_PARAM)) {
            deactivateProductBasedOnCurrentlySold();
        }
    }

//----------------------------------------------------------------------------------------------------------------------

    static testMethod void verifyReactivateProductBasedOnCurrentlySold() {
        reactivateProductBasedOnCurrentlySold(); 
    }
    
    static testMethod void verifyReactivateProductBasedOnCurrentlySold_ESInfAgent() {
        System.runAs(ECICTestHelper.initTestEnvironmentByUser(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE,
                    ECICRunUserTestHelper.ES_INFOLINE_AGENT_PARAM)) {
            reactivateProductBasedOnCurrentlySold();
        }
    }
//----------------------------------------------------------------------------------------------------------------------

    static testMethod void verifyUpdateInternationalName() {
        updateInternationalName(); 
    }
    
    static testMethod void verifyUpdateInternationalName_ESInfAgent() {
        System.runAs(ECICTestHelper.initTestEnvironmentByUser(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE,
                 ECICRunUserTestHelper.ES_INFOLINE_AGENT_PARAM)) {
            updateInternationalName();
        }
    }
    
    static testMethod void verifySkipTriggerInvocation() {
        skipTriggerInvocation();
    }
    
    
}