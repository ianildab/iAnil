@isTest
public class ECICActionPlanControllerTest 
{
    private static final User    TEST_RUN_USER                        = TEST_DummyUserFactory.createDefaultTestRunUser();
 	
    private static testMethod void constructorTest()
    {
    	ECICActionPlanController resultController = null;
        System.runAs(TEST_RUN_USER)
        {
        	Test.startTest();
        	{
        		resultController = new ECICActionPlanController(null);
        	}
            Test.stopTest();
        }
           	
        System.assert(resultController != null);
    }
}