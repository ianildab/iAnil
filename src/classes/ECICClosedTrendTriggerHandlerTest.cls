@isTest
private class ECICClosedTrendTriggerHandlerTest 
{
	private static final User                          TEST_RUN_USER  = TEST_DummyUserFactory.createDefaultTestRunUser();
	private static final ECICClosedTrendTriggerHandler TARGET_HANDLER = new ECICClosedTrendTriggerHandler(false);
	
    private static void constructorTest(Boolean isTriggerExecuting) 
    {
        ECICClosedTrendTriggerHandler dummyHandler = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                dummyHandler = new ECICClosedTrendTriggerHandler(isTriggerExecuting);
            }
            Test.stopTest();
        } 
        
        System.assertEquals (isTriggerExecuting, dummyHandler.isTriggerExecuting);
    }

    private static testMethod void notExecutingConstructorTest() { constructorTest(false); } 
    private static testMethod void executingConstructorTest()    { constructorTest(false); } 
    
    // --------------------------------------------------------------------------------------------------------------------------------
    
    private static void processBeforeTest(Boolean hasOld, Boolean hasCountryCodeChange) 
    {
    	Closed_Trend__c          dummyNewClosedTrend        = createNewClosedTrend();
        List<Closed_Trend__c>    dummyNewClosedTrendList    = new List<Closed_Trend__c>{ dummyNewClosedTrend } ; 

        Map<Id, Closed_Trend__c> dummyOldClosedTrendByIdMap = null;
        if (hasOld)
        {    	
            Closed_Trend__c              dummyOldClosedTrend = createOldClosedTrend (dummyNewClosedTrend, hasCountryCodeChange);
			dummyNewClosedTrend.id     = dummyOldClosedTrend.id;
			dummyOldClosedTrendByIdMap = new Map<Id, Closed_Trend__c>{ dummyOldClosedTrend.id => dummyOldClosedTrend };
        }
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_HANDLER.processBefore(dummyNewClosedTrendList, dummyOldClosedTrendByIdMap);
            }
            Test.stopTest();
        } 
        
        Boolean expectSet = !hasOld || hasCountryCodeChange;
        System.assertEquals (expectSet ? ECICCommonConstants.COUNTRY_CODE_DEFAULT : null, dummyNewClosedTrend.country_code_string__c); 
    }

    private static testMethod void noOldProcessBeforeTest()     { processBeforeTest(false, false); } 
    private static testMethod void hasOldProcessBeforeTest()    { processBeforeTest(true , false); } 
    private static testMethod void hasChangeProcessBeforeTest() { processBeforeTest(true , true ); } 
    
    // --------------------------------------------------------------------------------------------------------------------------------
    
    private static void onBeforeMethodTest(Boolean isInsertTest)
    {
    	Boolean isUpdateTest = !isInsertTest;
    	
    	Closed_Trend__c          dummyNewClosedTrend        = createNewClosedTrend();
        List<Closed_Trend__c>    dummyNewClosedTrendList    = new List<Closed_Trend__c>{ dummyNewClosedTrend } ; 

        Map<Id, Closed_Trend__c> dummyOldClosedTrendByIdMap = null;
        if (isUpdateTest)
        {    	
            Closed_Trend__c              dummyOldClosedTrend = createOldClosedTrend (dummyNewClosedTrend, true);
			dummyNewClosedTrend.id     = dummyOldClosedTrend.id;
			dummyOldClosedTrendByIdMap = new Map<Id, Closed_Trend__c>{ dummyOldClosedTrend.id => dummyOldClosedTrend };
        }
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
            	if   (isInsertTest)      { TARGET_HANDLER.onBeforeInsert (dummyNewClosedTrendList ); 										 }
            	else /* is Update Test*/ { TARGET_HANDLER.onBeforeUpdate (null, dummyNewClosedTrendList, dummyOldClosedTrendByIdMap,  null); } // null values are not used.
            }
            Test.stopTest();
        }
        
        System.assertEquals (ECICCommonConstants.COUNTRY_CODE_DEFAULT, dummyNewClosedTrend.country_code_string__c); 
        } 

    private static testMethod void onBeforeInsertTest()    { onBeforeMethodTest(true);  } 
    private static testMethod void onBeforeUpdateTest()    { onBeforeMethodTest(false); } 
	
	// --------------------------------------------------------------------------------------------------------------------------------
	
    private static Closed_Trend__c createNewClosedTrend()
    {
    	TEST_DummyClosedTrendFactory.Config         config = new TEST_DummyClosedTrendFactory.Config();
    	                                            config.countryCode = ECICCommonConstants.COUNTRY_CODE_DEFAULT;
    	return TEST_DummyClosedTrendFactory.create (config, TEST_DummyInsertModeEnum.NONE);
    }
    
	private static Closed_Trend__c createOldClosedTrend (Closed_Trend__c dummyNewClosedTrend, Boolean hasCountryCodeChange)
	{
            Closed_Trend__c              dummyOldClosedTrend = dummyNewClosedTrend.clone(false);
            						     dummyOldClosedTrend.Country_Code__c = (hasCountryCodeChange) ? 'Z1' : ECICCommonConstants.COUNTRY_CODE_DEFAULT;
			TEST_MockHelper.mockInsert(  dummyOldClosedTrend    );
			return 					     dummyOldClosedTrend;
	}


}