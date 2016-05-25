@isTest
private class ECICCaseControllerTest 
{
  	private static final User TEST_RUN_USER = ECICRunUserTestHelper.create();
  	
  	private static void getLangCodesTest(Integer numberOfLanguageCodes, Boolean isLangCodeNull)
  	{
  		String centreCode = 'C1';
  		String langCodes = ''; 
  		if (numberOfLanguageCodes > 0) {for (Integer i=1; i <= numberOfLanguageCodes; i++) { langCodes += 'L' + i + ';'; }}

  		ECICCaseController controller = new ECICCaseController();
  						   controller.cntrCode = centreCode;
  		if (!isLangCodeNull) {  controller.langCode = langCodes; }
  		else
  		{
  			if (numberOfLanguageCodes != 0)
  			{
  				TEST_DummyCountrySpecificSettingsFactory.Config config = new TEST_DummyCountrySpecificSettingsFactory.Config();
  																config.countryCode = centreCode;
  																config.officialLanguages = langCodes;
  				TEST_DummyCountrySpecificSettingsFactory.create (config, true);
  			}
  		}

		String[] resultArray = null;  		
  		System.runAs(TEST_RUN_USER)
  		{
  			resultArray = controller.getLangCodes();
  		}
  		
  		System.assertEquals (numberOfLanguageCodes, resultArray.size());
  	}

	private static testMethod void getOneLangCodesNotNullTest()   { getLangCodesTest (1, false); }
	private static testMethod void getTwoLangCodesNotNullTest()   { getLangCodesTest (2, false); }
	private static testMethod void getThreeLangCodesNotNullTest() { getLangCodesTest (3, false); }
	
	private static testMethod void getZeroLangCodesNullTest()     { getLangCodesTest (0, true);  }
	private static testMethod void getOneLangCodesNullTest()   	  { getLangCodesTest (1, true);  }
	private static testMethod void getTwoLangCodesNullTest()   	  { getLangCodesTest (2, true);  }
	private static testMethod void getThreeLangCodesNullTest() 	  { getLangCodesTest (3, true);  }
	
	// TODO: Add tests for multiple controller center codes (ECICCaseController.centrCode)
	
	// -------------------------------------------------------------------------------------------------------------------------
	
	
	private static testMethod void getCasesNotNull()
	{
  		ECICCaseController controller = new ECICCaseController();
						   controller.cases = new List<Case>();
		
		List<Case> resultList = null;
  		System.runAs(TEST_RUN_USER)
  		{
  			resultList = controller.cases;
  		}
  		
  		System.assert (resultList != null);
	}

	private static void getCasesFromSObject(String sObjectName)
	{
   		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		
		SObject dummySObject = ((sObjectName == 'Trend__c')
							? (SObject) TEST_DummyTrendFactory.createDummy(true)
							: ( (sObjectName == 'Closed_Trend__c')
									? (SObject) TEST_DummyClosedTrendFactory.createDummy(true)
									: ( (sObjectName == 'Open_Alert__c')
										? (SObject) TEST_DummyOpenAlertFactory.createDummy(true)
										: null
									  )
								)
						);
		System.assert (dummySObject != null);
		
  		ECICCaseController controller = new ECICCaseController();
						   controller.obj = dummySObject;

		Case dummyCase = createDummyCase(sObjectName, dummySObject.id);
		
		List<Case> resultList = null;
  		System.runAs(TEST_RUN_USER)
  		{
  			resultList = controller.cases;
  		}
  		
  		System.assertEquals (1, resultList.size());
  		System.assertEquals (dummyCase.id, resultList[0].id);
	}

	private static testMethod void getCasesFromTrend() 		 { getCasesFromSObject('Trend__c'); }
	private static testMethod void getCasesFromOpenAlert()   { getCasesFromSObject('Open_Alert__c'); }
	
/** FIXME (see CIC-1260):

   [deploy] 1.  ECICCaseControllerTest.getCasesFromClosedTrend -- System.DmlException: Insert failed. First exception on row
 0; first error: CANNOT_INSERT_UPDATE_ACTIVATE_ENTITY, ECICCaseTrigger: execution of BeforeInsert
   [deploy]
   [deploy]     caused by: System.SObjectException: SObject row was retrieved via SOQL without querying the requested field:
 Region__c.Bottler__c
   [deploy]
   [deploy]     Class.ECICCaseTriggerAccountCache.addBottlerToIdSet: line 70, column 1
   [deploy]     Class.ECICCaseTriggerAccountCache.selectBottlerAccountIdSet: line 58, column 1
   [deploy]     Class.ECICCaseTriggerAccountCache.populate: line 12, column 1
   [deploy]     Class.ECICCaseTriggerRelatedRecordHelper.populateCaches: line 55, column 1
   [deploy]     Class.ECICCaseTriggerHandlerHelper.doCountrySpecificStrategies: line 57, column 1
   [deploy]     Class.ECICCaseTriggerHandler.executeStrategyChain: line 82, column 1
   [deploy]     Class.ECICCaseTriggerHan
   [deploy]     Stack trace: Class.ECICCaseTestHelper.createDummyCase: line 165, column 1
   [deploy]     Class.ECICCaseTestHelper.createDummyCase: line 285, column 1
   [deploy]     Class.TEST_DummyClosedTrendCaseFactory.createDummy: line 16, column 1
   [deploy]     Class.TEST_DummyClosedTrendCaseFactory.createDummy: line 25, column 1
   [deploy]     Class.ECICCaseControllerTest.createDummyCase: line 106, column 1
   [deploy]     Class.ECICCaseControllerTest.getCasesFromSObject: line 82, column 1
   [deploy]     Class.ECICCaseControllerTest.getCasesFromClosedTrend: line 95, column 1
   
    private static testMethod void getCasesFromClosedTrend() { getCasesFromSObject('Closed_Trend__c'); }
**/

	private static Case createDummyCase(String sObjectName, Id dummySObjectId)
	{
		Boolean     isTrendSObject        = (sObjectName == 'Trend__c');
		Boolean     isClosedTrendSObject  = (sObjectName == 'Closed_Trend__c');
		Boolean     isOpenAlertSObject    = (sObjectName == 'Open_Alert__c');
		
		Case   dummyCase = ECICCaseTestHelper.createDummyCase(!isTrendSObject);
		if (isTrendSObject) 		   {  dummyCase.put(sObjectName, dummySObjectId); insert dummyCase;}
		else if (isClosedTrendSObject) { TEST_DummyClosedTrendCaseFactory.createDummy(dummyCase.id, dummySObjectId, true); }  
		else if (isOpenAlertSObject)   { TEST_DummyOpenAlertCaseFactory.createDummy(dummyCase.id, dummySObjectId, true); }  
		return dummyCase;
	}
	
}