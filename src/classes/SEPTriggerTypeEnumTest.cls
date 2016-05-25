@isTest
private class SEPTriggerTypeEnumTest 
{
    private static final User TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();

    // Not 100% certain we need this, but when tests are executed through web-ui, SFDC complained we [somehow] have 0% coverage.
    private static testMethod void enumTest()
    {
        List<SEPTriggerTypeEnum> enumMemeberList = SEPTriggerTypeEnum.values();

        Map<String, Boolean> hasEnumByEnumValueStringMap = new Map<String, Boolean>();
        System.runAs(TEST_RUN_USER)
        {
        	Test.startTest();
        	{
        		for (SEPTriggerTypeEnum enumMember : enumMemeberList)
        		{
        			hasEnumByEnumValueStringMap.put (String.valueOf(enumMember), true);
        		} 
        	}
            Test.stopTest();
        }

        List<String> expectedEnumValueList = new List<String>
        { 
            'BEFORE_INSERT', 'AFTER_INSERT', 
            'BEFORE_UPDATE', 'AFTER_UPDATE',
            'BEFORE_DELETE', 'AFTER_DELETE',
                             'AFTER_UNDELETE'
        };
         
        // This will prove no values have been removed, but allows additions.
        for (String expectedEnumValue : expectedEnumValueList)
        {
            System.assert(hasEnumByEnumValueStringMap.get(expectedEnumValue));
        }
    }
     
}