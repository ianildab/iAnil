@isTest
private class ECICCaseTriggerStrategyConfigExceptnTest 
{
	private static void exceptionTest (Integer numberOfErrors)
	{
   		TEST_DummyGeneralSettingsFactory.create(TEST_DummyInsertModeEnum.REAL);
		Integer emailLimitBeforeException = Limits.getEmailInvocations();
		
		List<String> dummyErrorLogList = new List<String>();
		for (Integer i=1; i<=numberOfErrors; i++) { dummyErrorLogList.add('Error #' + i); }

		Boolean exceptionCaught = false;
		
		try { throw new ECICCaseTriggerStrategyConfigException(dummyErrorLogList); }
		catch (ECICCaseTriggerStrategyConfigException resultException) 
		{ 
			exceptionCaught = true; 

			String expectedStart = 'The Case_Trigger_Strategy_Configuration__c records contain'
									+ (
										 (numberOfErrors == 1)
										 	? 's the following error'
										 	: ' the following' + numberOfErrors + 'errors'
									  )
									+ ': ';
			System.assert (resultException.errorMessage.contains(expectedStart));
			for (Integer i=1; i<=numberOfErrors; i++) { System.assert (resultException.errorMessage.contains('Error #' + i)); }
		}
		
		System.assert(exceptionCaught);		
		System.assertNotEquals(emailLimitBeforeException,Limits.getEmailInvocations(),'should have decreased');
	}
	
	private static testMethod void oneErrorTest()  { exceptionTest (1);  }
	private static testMethod void twoErrorTest()  { exceptionTest (2);  }
	private static testMethod void tenErrorTest()  { exceptionTest (10); }
}