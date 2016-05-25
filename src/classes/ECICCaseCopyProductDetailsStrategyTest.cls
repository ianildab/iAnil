@isTest
private class ECICCaseCopyProductDetailsStrategyTest 
{
	private static final User TEST_RUN_USER = ECICRunUserTestHelper.create();
	
	private static final ECICCaseCopyProductDetailsStrategy DUMMY_STRATEGY = new ECICCaseCopyProductDetailsStrategy();

	private static void doExecuteTest(Boolean hasProduct, Boolean productHasPrice) 	 	
 	{ 
		Decimal    dummyUnitPrice 		 = (productHasPrice) ? 15.52 						 : TEST_ConfigHelper.INTENTIONAL_NULL_FOR_NUMBER;
		Product__c dummyProduct 		 = (hasProduct) 	 ? createProduct(dummyUnitPrice) : null;
		
		Decimal    dummyCaseDefaultPrice = 908.10;
		Case 	   dummyCase 		     = createCase(dummyProduct, dummyCaseDefaultPrice);
		
		Boolean result = null; 
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				result = DUMMY_STRATEGY.doExecute(new List<Case>{ dummyCase });
			}
			Test.stopTest(); 
		} 
		
		Decimal expectedPrice = (hasProduct && productHasPrice) ? dummyUnitPrice : dummyCaseDefaultPrice;
		assertExecute(result, expectedPrice, dummyCase);
	}
	
	private static testMethod void noProductDoExecuteTest()  				{ doExecuteTest(false, false); }
	private static testMethod void hasProductWithoutPriceDoExecuteTest()  	{ doExecuteTest(true , false); }
	private static testMethod void hasProductWithPriceDoExecuteTest() 		{ doExecuteTest(true , true ); }
	
	// ------------------------------------------------------------------------------------------------------------

	private static void assertExecute(Boolean result, Decimal expectedPrice, Case resultCase)
	{
		System.assert (result);
		System.assertEquals (expectedPrice, resultCase.Product_Unit_Price__c);
	}
	
	// ------------------------------------------------------------------------------------------------------------
	
	private static testMethod void onBeforeInsertTest() 	 	
	{ 
		Decimal    dummyUnitPrice 		 = 1.13;
		Product__c dummyProduct 		 = createProduct(dummyUnitPrice);
		Case 	   dummyCase 		     = createCase(dummyProduct, 5.41);
		
		Boolean result = null; 
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				result = DUMMY_STRATEGY.onBeforeInsert(new List<Case>{ dummyCase });
			}
			Test.stopTest(); 
		} 
		
		assertExecute(result, dummyUnitPrice, dummyCase);
	}
	
	private static testMethod void onBeforeUpdateTest() 	 	
	{ 
		Decimal    dummyUnitPrice 		 = 2.63;
		Product__c dummyProduct 		 = createProduct(dummyUnitPrice);
		Case 	   dummyCase 		     = createCase(dummyProduct, 1.46);
		TEST_MockHelper.mockInsert(dummyCase);
		
		
		Boolean result = null; 
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				result = DUMMY_STRATEGY.onBeforeUpdate(null, new Map<Id, Case>{ dummyCase.id => dummyCase });	// old Cases are not used.
			}
			Test.stopTest(); 
		} 
		
		assertExecute(result, dummyUnitPrice, dummyCase);
	}

	// ------------------------------------------------------------------------------------------------------------

	private static Product__c createProduct(Decimal dummyUnitPrice)
	{
			TEST_DummyProductFactory.Config productConfig = new TEST_DummyProductFactory.Config();
		 									productConfig.unitPrice = dummyUnitPrice; 
			Product__c dummyProduct = TEST_DummyProductFactory.create(productConfig, TEST_DummyInsertModeEnum.MOCK);
			
			ECICCaseTriggerProductCache.productByIdCache.put(dummyProduct.id, dummyProduct);
			
			return dummyProduct;
	}
	
	private static Case createCase(Product__c dummyProduct, Decimal dummyCaseDefaultPrice)
	{
		TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
							 caseConfig.productId 		 = (dummyProduct != null) ? dummyProduct.id : null;
							 caseConfig.productUnitPrice = 908.10; 
		return TEST_DummyInquiryCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.NONE);
	}
	
}