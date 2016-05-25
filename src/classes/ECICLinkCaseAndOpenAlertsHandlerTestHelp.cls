@isTest
public class ECICLinkCaseAndOpenAlertsHandlerTestHelp 
{
	private static final Integer LEAVE_NULL 	= -1;

	// -----------------------------------------------------------------------------------------------------------------------------------------------
	
	public static ECICLinkCaseAndOpenAlertsConfigEntry createDummyConfigEntry(SObject targetSObject, List<String> argumentList)
	{
		ECICLinkCaseAndOpenAlertsConfigEntry configEntry = new ECICLinkCaseAndOpenAlertsConfigEntry(targetSObject);
													 configEntry.setArgs(argumentList);
											  return configEntry;
	}

	
	// -----------------------------------------------------------------------------------------------------------------------------------------------
	
	public static ECICLinkCaseAndOpenAlertsMatchable createDummyMatchable(List<String> argList)
	{
		return new ECICLinkCaseAndOpenAlertsMatchable(argList);
	}       

	// -----------------------------------------------------------------------------------------------------------------------------------------------

	public static Date createDummyDate(Integer month)
	{
		Date dummyDate = date.valueOf(2008 + '-' + month + '-' + 5 + ' ' + 12 + ':' + 20 + ':' + 20);
		return dummyDate;
	}

	// -----------------------------------------------------------------------------------------------------------------------------------------------
	
	public static List<String> createDummyArgList(Integer listLength, Set<Integer> matchPlaceSet, Set<Integer> nullPlaceSet, Boolean isForMatchableConstructor)
	{
		List<String> dummyList = null;
		if (listLength > LEAVE_NULL)
		{
			dummyList = new List<String>();
			if (listLength >= 1)
			{
				for (Integer i=1; i <= listLength; i++)
				{
					String stringToAdd = ((matchPlaceSet != null) && matchPlaceSet.contains(i)) 
											? ('M' + i) 
											:  (
												((nullPlaceSet != null) && nullPlaceSet.contains(i))
													?	null
													: ( (isForMatchableConstructor ? 'T' : 'Q') + i)
											  );
					dummyList.add(stringToAdd);
				}
			}
		}
		return dummyList;
	}

	// -----------------------------------------------------------------------------------------------------------------------------------------------
	
	public static Open_Alert__c createOpenAlertForConfigTest(Boolean hasFieldActive) 
	{
		TEST_DummyOpenAlertFactory.Config openAlertConfig                 = new TEST_DummyOpenAlertFactory.Config();
		                                  openAlertConfig.categoryLevel3  = 'Acceptable Daily Intake';
		                                  openAlertConfig.startDate       = Date.today().addDays (hasFieldActive ? 0 : -91);
		                                  openAlertConfig.endDate         = Date.today().addDays (hasFieldActive ? 0 : -91);
		
		Open_Alert__c dummyOpenAlert = TEST_DummyOpenAlertFactory.create(openAlertConfig, TEST_DummyInsertModeEnum.REAL);
		
			   
		Open_Alert__c resultOpenAlert = [
											SELECT id, active__c, 
												BBE_Date__c,  beverage__c, 
												case_type__c, case_reason__c, Category_Level3__c,  Category_Level4__c,  
												closure_Batch__c,  closure_Supplier__c,
												outsourcing_company__c,   
												package_batch__c,  package_supplier__c,  place_of_purchase__c,  plant__c, point_of_sale__c, pos_key_account__c, 
												process_type__c, product__c,  product_package__c,  production_code__c,  production_date__c, production_line__c,
												promotion__c,  region_of_purchase__c 
											FROM Open_Alert__c
											WHERE id = :dummyOpenAlert.id
											LIMIT 1
										];
			   return resultOpenAlert;
	}

	// -----------------------------------------------------------------------------------------------------------------------------------------------

	public static Case createCaseForConfigTest(Boolean testGenerateEmails) 
	{
        TEST_DummyCaseConfig caseConfig                     = new TEST_DummyCaseConfig();
                             caseConfig.categoryLevel3      = 'Acceptable Daily Intake';
                             caseConfig.countryCode         = (testGenerateEmails) ? 'GE00' : null;
        
		Case          dummyCase         = TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.MOCK);
		return dummyCase;
	}

	public static Case createCaseForConfigTest() { return createCaseForConfigTest(false); }

	// -----------------------------------------------------------------------------------------------------------------------------------------------

	
	public static Boolean areAllMatchOrNull (Integer targetlistLength, Integer querylistLength, Set<Integer> matchPlaceSet, Set<Integer> nullPlaceSet)
	{
		Set<Integer> allPlaceSet = new Set<Integer>();
		if (matchPlaceSet != null) { allPlaceSet.addAll(matchPlaceSet); }
		if (nullPlaceSet  != null) { allPlaceSet.addAll(nullPlaceSet);  }
		
		for (Integer i=1; (i <= targetlistLength) && (i <= querylistLength) ; i++)
		{
			if (!(allPlaceSet.contains(i))) { return false; } 
		}

		return true;
	}

}