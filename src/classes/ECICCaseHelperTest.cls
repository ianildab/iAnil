@isTest
private class ECICCaseHelperTest 
{
	public static final User    TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();  

	private static void isUserIdTest(Boolean isUserId, Boolean isNull)
	{ 
		Id dummyId = (!isNull) ? ( (isUserId) ? '00520000001qmXm' : '00111000004gFL4' ) : null;

		Boolean result = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				result = ECICCaseHelper.isUserId(dummyId); 
			}
			Test.stopTest();
		} 
		
		System.assertEquals ((isUserId && (!isNull)), result);
	}
	
	private static testMethod void trueUserIdTest()		{ isUserIdTest(true,  false);  }
	private static testMethod void falseUserIdTest()	{ isUserIdTest(false, false);  }
	private static testMethod void nullUserIdTest()		{ isUserIdTest(false, true);   }

	private static void isGroupIdTest(Boolean isGroupId, Boolean isNull)
	{ 
		Id dummyId = (!isNull) ? ( (isGroupId) ? '00G11000004gFL4' : '00111000004gFL4' ) : null;

		Boolean result = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				result = ECICCaseHelper.isGroupId(dummyId); 
			}
			Test.stopTest();
		} 
		
		System.assertEquals ((isGroupId && (!isNull)), result);
	}
	
	private static Id createDummySObjectId(SObject dummySObject)
	{
		insert dummySObject;
		return dummySObject.Id;
	}
	
	private static testMethod void trueGroupIdTest()	{ isGroupIdTest(true,  false);  }
	private static testMethod void falseGroupIdTest()	{ isGroupIdTest(false, false);  }
	private static testMethod void nullGroupIdTest()	{ isGroupIdTest(false, true);   }
	
	private static void isQueueIdTest(Boolean isQueueId, Boolean isNull)
	{ 
		Id dummyId = (!isNull) ? ( (isQueueId) ? ('00GR000000mUZYg') : '00111000004gFL4' ) : null;

		Boolean result = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				result = ECICCaseHelper.isQueueId(dummyId); 
			}
			Test.stopTest();
		} 
		
		System.assertEquals ((isQueueId && (!isNull)), result);
	}
	
	private static testMethod void trueQueueIdTest()	{ isQueueIdTest(true,  false);  }
	private static testMethod void falseQueueIdTest()	{ isQueueIdTest(false, false);  }
	private static testMethod void nullQueueIdTest()	{ isQueueIdTest(false, true);   }


}