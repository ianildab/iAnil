@isTest
private class ECICPromotionTriggerHandlerTest 
{
    private static final User TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();
    private static final String COUNTRY_CODE_DEFAULT = ECICCommonConstants.COUNTRY_CODE_DEFAULT;

    private static void constructorTest(Boolean isTriggerExecuting) 
    {
        ECICPromotionTriggerHandler dummyHandler = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                dummyHandler = new ECICPromotionTriggerHandler(isTriggerExecuting);
            }
            Test.stopTest();
        } 
        
        System.assertEquals (isTriggerExecuting, dummyHandler.isTriggerExecuting);
    }

    private static testMethod void notExecutingConstructorTest() { constructorTest(false); } 
    private static testMethod void executingConstructorTest()    { constructorTest(false); } 
    
    // ------------------------------------------------------------------------------------------------------------------

    private static void getBlankCountryOwnerUserIdTest(Boolean hasUserAsOwner, Boolean hasCountryCode) 
    {
    	Id dummyOwnerId = (hasUserAsOwner) ? TEST_RUN_USER.id : '00111000004gFL4';
        Promotion__c dummyPromotion = createPromotion (dummyOwnerId, hasCountryCode);
        
        Id resultId = null;
        System.runAs(TEST_RUN_USER)
        { 
            Test.startTest();
            {
                resultId = ECICPromotionTriggerHandler.getBlankCountryOwnerUserId (dummyPromotion);
            }
            Test.stopTest();
        } 
        
        System.assertEquals ((hasUserAsOwner && !hasCountryCode) ? dummyOwnerId : null, resultId);
        System.assertEquals ((hasUserAsOwner                   ) ? dummyOwnerId : null, dummyPromotion.Owner_Lookup__c);
    }

    private static testMethod void hasNoneGetBlankCountryOwnerUserIdTest()    { getBlankCountryOwnerUserIdTest(false, false); } 
    private static testMethod void hasCountryGetBlankCountryOwnerUserIdTest() { getBlankCountryOwnerUserIdTest(false, true ); } 
    private static testMethod void hasUserGetBlankCountryOwnerUserIdTest()    { getBlankCountryOwnerUserIdTest(true , false); } 
    private static testMethod void hasBothGetBlankCountryOwnerUserIdTest()    { getBlankCountryOwnerUserIdTest(true , true ); } 
    
    // ------------------------------------------------------------------------------------------------------------------

    private static void getBlankCountryOwnerUserIdSetTest(Boolean hasCountryCode) 
    {
        Id dummyOwnerId = TEST_RUN_USER.id;
        Promotion__c dummyPromotion = createPromotion (dummyOwnerId, hasCountryCode);
        
        Set<Id> resultIdSet = null;
        System.runAs(TEST_RUN_USER)
        { 
            Test.startTest();
            {
                resultIdSet = ECICPromotionTriggerHandler.getBlankCountryOwnerUserIdSet (new List<Promotion__c>{ dummyPromotion });
            }
            Test.stopTest();
        } 
        
        System.assertEquals (!hasCountryCode, resultIdSet.contains(dummyOwnerId));
        System.assertEquals (dummyOwnerId, dummyPromotion.Owner_Lookup__c);
    }

    private static testMethod void noCountryGetBlankCountryOwnerUserIdSetTest()  { getBlankCountryOwnerUserIdSetTest(false);  }
    private static testMethod void hasCountryGetBlankCountryOwnerUserIdSetTest() { getBlankCountryOwnerUserIdSetTest(true );  }
    
    // ------------------------------------------------------------------------------------------------------------------

    private static void setCountryCode2Test(Boolean hasCountryCode, Boolean isUserInMap) 
    {
    	String        dummyOwnerCountry          = 'U1';
    	User          dummyOwner                 = TEST_RUN_USER;
    	              dummyOwner.country_code__c = dummyOwnerCountry;
        Id            dummyOwnerId               = dummyOwner.id;
        Promotion__c  dummyPromotion             = createPromotion (dummyOwnerId, hasCountryCode);
        
        Map<Id, User>       dummyOwnerUserByIdMap = new Map<Id, User>();
        if (isUserinMap) {  dummyOwnerUserByIdMap.put (dummyOwnerId, dummyOwner); }

        System.runAs(TEST_RUN_USER)
        { 
            Test.startTest();
            {
                ECICPromotionTriggerHandler.setCountryCodes(new List<Promotion__c>{ dummyPromotion }, dummyOwnerUserByIdMap);
            }
            Test.stopTest();
        } 

        String expectedCountry = (!hasCountryCode && isUserInMap)
                                    ? (dummyOwnerCountry)
                                    : ((hasCountryCode) ? COUNTRY_CODE_DEFAULT : '');
                                    
        System.assertEquals (expectedCountry, dummyPromotion.country_code__c);                                            
    }

    private static testMethod void hasNoneSetCountryCode2Test()       { setCountryCode2Test (false, false); } 
    private static testMethod void hasCountrySetCountryCode2Test()    { setCountryCode2Test (false, true ); } 
    private static testMethod void hasMappedUserSetCountryCode2Test() { setCountryCode2Test (true , false); } 
    private static testMethod void hasAllSetCountryCode2Test()        { setCountryCode2Test (true , true ); } 
    
    // ------------------------------------------------------------------------------------------------------------------
    
    private static void setCountryCode1Test(Boolean isUserInSet) 
    {
        User          dummyOwner                 = TEST_RUN_USER;
        Id            dummyOwnerId               = dummyOwner.id;
        Promotion__c  dummyPromotion             = createPromotion (dummyOwnerId, false);

        Set<Id> dummyOwnerUserIdSet = new Set<Id>();
        if (isUserInSet) { dummyOwnerUserIdSet.add(dummyOwnerId);}
        
        System.runAs(TEST_RUN_USER)
        { 
            Test.startTest();
            {
                ECICPromotionTriggerHandler.setCountryCodes(new List<Promotion__c>{ dummyPromotion }, dummyOwnerUserIdSet);
            }
            Test.stopTest();
        } 

        String expectedCountry = (isUserInSet) ? (dummyOwner.country_code__c) : '';
        System.assertEquals (expectedCountry, dummyPromotion.country_code__c);                                            
    }

    private static testMethod void userOutOfSetSetCountryCode1Test()   { setCountryCode1Test(false); } 
    private static testMethod void userInSetSetCountryCode1Test()      { setCountryCode1Test(true ); } 
    
    // ------------------------------------------------------------------------------------------------------------------
    
    private static void processBeforeTest(Boolean hasCountryCode) 
    {
        User          dummyOwner                 = TEST_RUN_USER;
        Id            dummyOwnerId               = dummyOwner.id;
        Promotion__c  dummyPromotion             = createPromotion (dummyOwnerId, hasCountryCode);

        System.runAs(TEST_RUN_USER)
        { 
            Test.startTest();
        { 
                ECICPromotionTriggerHandler.processBefore(new List<Promotion__c>{ dummyPromotion });
            }
            Test.stopTest();
            }

        String expectedCountry = (!hasCountryCode) ? (dummyOwner.country_code__c) : COUNTRY_CODE_DEFAULT;
        System.assertEquals (expectedCountry, dummyPromotion.country_code__c);                                            
    }
    
    private static testMethod void noCountryProcessBeforeTest()  { processBeforeTest(false); } 
    private static testMethod void hasCountryProcessBeforeTest() { processBeforeTest(true ); } 
    
    // ------------------------------------------------------------------------------------------------------------------
   
    private static void onBeforeTest(String targetFunction) 
        { 
        Id            dummyOwnerId               = TEST_RUN_USER.id;
        Promotion__c  dummyPromotion             = createPromotion (dummyOwnerId, false);
        List<Promotion__c> dummyPromotionList    = new List<Promotion__c>{ dummyPromotion };
        
        ECICPromotionTriggerHandler handler = new ECICPromotionTriggerHandler(false);
        System.runAs(TEST_RUN_USER)
        { 
            Test.startTest();
            {
                if    (targetFunction == 'onBeforeInsert')  { handler.onBeforeInsert(      dummyPromotionList            ); }
                else /*targetFunction == 'onBeforeUpdate'*/ { handler.onBeforeUpdate(null, dummyPromotionList, null, null); }
            }
            Test.stopTest();
        } 

        String expectedCountry = TEST_RUN_USER.country_code__c;
        System.assertEquals (expectedCountry, dummyPromotion.country_code__c);                                            
    }

    private static testMethod void onBeforeInsertTest() { onBeforeTest('onBeforeInsert'); } 
    private static testMethod void onBeforeUpdateTest() { onBeforeTest('onBeforeUpdate'); } 
    
    // ------------------------------------------------------------------------------------------------------------------
    
    private static Promotion__c createPromotion (Id dummyOwnerId, Boolean hasCountryCode)
    {
        TEST_DummyPromotionFactory.Config config = new TEST_DummyPromotionFactory.Config();
                                          config.ownerId       = dummyOwnerId;
                                          config.countryCode   = (hasCountryCode) ? COUNTRY_CODE_DEFAULT : '';
        return TEST_DummyPromotionFactory.create(config, TEST_DummyInsertModeEnum.NONE);
    }
    
}