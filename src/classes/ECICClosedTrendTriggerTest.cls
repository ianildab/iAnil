@isTest
private class ECICClosedTrendTriggerTest 
{
	private static final User                          TEST_RUN_USER  = TEST_DummyUserFactory.createDefaultTestRunUser();
	private static final Id						       DUMMY_PLANT_ID = TEST_DummyPlantFactory.create(TEST_DummyInsertModeEnum.REAL).id;

	private static void triggerTest (Boolean isInsertTest, Boolean skipTriggersTest)
	{
    	Boolean isUpdateTest                           = !isInsertTest;
        if (skipTriggersTest) 
        { 
         SEPTriggerHandlerInvoker.pretendTestNotRunning = true;

			TEST_DummyGeneralSettingsFactory.Config settingConfig = new TEST_DummyGeneralSettingsFactory.Config();
													settingConfig.skipTriggers = skipTriggersTest;
			TEST_DummyGeneralSettingsFactory.create(settingConfig, TEST_DummyInsertModeEnum.REAL);
    }

    	Closed_Trend__c          dummyNewClosedTrend        = createOriginalClosedTrend(isInsertTest);

        if (isUpdateTest) { dummyNewClosedTrend.Country_Code__c = ECICCommonConstants.COUNTRY_CODE_DEFAULT; }
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
            	if   (isInsertTest)      { insert dummyNewClosedTrend; }
            	else /* is Update Test*/ { update dummyNewClosedTrend; }
            }
            Test.stopTest();
        }
        
        // Fields updated by DML operation are not immediately visible, so we must use SOQL to see this works.
        Closed_Trend__c resultClosedTrend = [SELECT country_code_string__c FROM Closed_Trend__c WHERE id = :dummyNewClosedTrend.id LIMIT 1];
        System.assertEquals ((!skipTriggersTest) ? ECICCommonConstants.COUNTRY_CODE_DEFAULT : null , resultClosedTrend.country_code_string__c);
	}	

	private static testMethod void doInsertTriggerTest()     { triggerTest (true,  false); }
    private static testMethod void doUpdateTriggerTest()     { triggerTest (false, false); }

	private static testMethod void skipInsertTriggerTest()   { triggerTest (true,  true ); }
	private static testMethod void skipUpdateTriggerTest()   { triggerTest (false, true ); }

	// --------------------------------------------------------------------------------------------------------------------------------
    
    private static Closed_Trend__c createOriginalClosedTrend(Boolean isInsertTest)
    {
    	TEST_DummyClosedTrendFactory.Config         config = new TEST_DummyClosedTrendFactory.Config();
    	                                            config.countryCode = (isInsertTest) ? ECICCommonConstants.COUNTRY_CODE_DEFAULT :  'Z1' ;
    	                                           	config.plantId     = DUMMY_PLANT_ID;
    	return TEST_DummyClosedTrendFactory.create (config, (isInsertTest) ? TEST_DummyInsertModeEnum.NONE : TEST_DummyInsertModeEnum.REAL);
    }

}