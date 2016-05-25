@isTest private class SEPStringHelperTest 
{
    private static final User   TEST_RUN_USER               = TEST_DummyUserFactory.createDefaultTestRunUser();

    private static testMethod void joinRelatedRecordFieldsTest()
    {
        String       dummySObjectName   = 'dummy__c';
        List<String> dummyFieldNameList = new List<String>{ 'a', 'b__c' };
        String       dummySeperator     = ',';        
        
        String result = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = SEPStringHelper.joinRelatedRecordFields(dummySObjectName, dummyFieldNameList, dummySeperator);
            }
            Test.stopTest();
        }
        
        String expectedString = 'dummy__r.a,dummy__r.b__c';
        System.assertEquals(expectedString, result); 
    }
    
}