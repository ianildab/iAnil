@isTest 
private class ECICTaskComparableTest 
{
	private static final User 	 TEST_RUN_USER 	 = ECICRunUserTestHelper.create();
	
	private static testMethod void constructorTest()
	{
		Task dummyTask = TEST_DummyTaskFactory.create();
		
		ECICTaskComparable resultComparable = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				resultComparable = new ECICTaskComparable(dummyTask);
			}
			Test.stopTest();
		}
	
		System.assertEquals (dummyTask, resultComparable.task);		
	}
	
	private static void compareToTest (Integer targetReturn)
	{
		Integer			   dummyFirstTaskNumer = 12;  // Number is arbitrary.
		
		Task 			   dummyFirstTask = TEST_DummyTaskFactory.create(false);
			 			   dummyFirstTask.Task_Number__c = dummyFirstTaskNumer;
		ECICTaskComparable dummyFirstComparable = new ECICTaskComparable(dummyFirstTask);

		Task 			   dummySecondTask = TEST_DummyTaskFactory.create(false);
			 			   dummySecondTask.Task_Number__c = dummyFirstTaskNumer - (targetReturn * 2);    // Multiplier is arbitrary; we just want to see a value returned is the target and not necessarily the task number.
		ECICTaskComparable dummySecondComparable = new ECICTaskComparable(dummySecondTask);
		
		Integer comparisonFirstResult  = null;
		Integer comparisonSecondResult = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				comparisonFirstResult  = dummyFirstComparable.compareTo(dummySecondComparable);
				comparisonSecondResult = dummySecondComparable.compareTo(dummyFirstComparable);
			}
			Test.stopTest();
		}
	
		System.assertEquals (targetReturn,  comparisonFirstResult);		
		System.assertEquals (-targetReturn, comparisonSecondResult);		
	}
	
	private static testMethod void greaterCompareToTest() { compareToTest (ECICTaskComparable.IS_GREATER); }
	private static testMethod void lesserCompareToTest()  { compareToTest (ECICTaskComparable.IS_LESSER);  }
	private static testMethod void equalCompareToTest()   { compareToTest (ECICTaskComparable.IS_EQUAL);   }
	
	private static testMethod void selectFirstOpenTaskTest()
	{
		Task 	   dummyFirstTask  = TEST_DummyTaskFactory.create(false);
			 	   dummyFirstTask.Task_Number__c = 10;										// Arbitrary lesser value
		Task 	   dummySecondTask = TEST_DummyTaskFactory.create(false);
			 	   dummySecondTask.Task_Number__c = 24; 									// Arbitrary greater value
		List<Task> dummyTaskList   = new List<Task> { dummySecondTask, dummyFirstTask }; 	// List order shouldn't matter.

		Task	   resultTask = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				resultTask = ECICTaskComparable.selectFirstOpenTask(dummyTaskList);
			}
			Test.stopTest();
		}
	
		System.assertEquals (dummyFirstTask, resultTask);		
	}
}