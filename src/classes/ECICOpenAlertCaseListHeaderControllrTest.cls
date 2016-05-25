@isTest
private class ECICOpenAlertCaseListHeaderControllrTest 
{
    private static final User TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();
    
    private static void getListHeaderTest(Boolean isCountryFrance)
    {
        Datetime startDate = System.today().addDays(-3);
        Datetime endDate   = System.today().addDays(-1);
        ECICOpenAlertCaseListHeaderController targetController = new ECICOpenAlertCaseListHeaderController();
                                              targetController.controllerCountryCode = (isCountryFrance) ? 'FR' : ECICCommonConstants.COUNTRY_CODE_DEFAULT;
                                              targetController.controllerStartDate   = startDate;
                                              targetController.controllerEndDate     = endDate;
        
        String resultHeader = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
                resultHeader = targetController.getListHeader();
            Test.stopTest();
        }
        
        String expectedHeader = (isCountryFrance)
				                   ? (Label.Analyzed_period +': ' + startDate + '-' + endDate)
				                   : (Label.Cases_met_defined_criteria);
        
        System.assertEquals (expectedHeader, resultHeader);
    }

    private static testMethod void franceGetListHeaderTest() { getListHeaderTest (true);  }
    private static testMethod void spainGetListHeaderTest()  { getListHeaderTest (false); }

}