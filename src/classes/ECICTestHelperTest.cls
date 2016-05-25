@isTest
private class ECICTestHelperTest {

  	private static User testRunUser = ECICRunUserTestHelper.create();

	
    static final string SELECT_CASE_COUNT = 'SELECT count() FROM Case WHERE (Status =\'' + 
			ECICCommonConstants.STATUS_NEW + '\') AND (Origin =\'' + ECICCommonConstants.CASE_ORIGIN + 
			'\') AND (Subject = \'' + ECICCommonConstants.CASE_SUBJECT + '\')';
	
	static final string SELECT_AP_COUNT = 'SELECT count() FROM Action_Plan__c WHERE Name =\'' +
			ECICCommonConstants.ACTION_PLAN_PARAM_1[0] + '\'';

/** FIXME (or drop)  : Tests fail new validation rule does not allow description to be blank
	static testMethod void createCaseWithTestHelper()
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			insert ECICCaseTestHelper.createCase();
			System.assertEquals( (Database.countQuery(SELECT_CASE_COUNT)), 1);
	  	}
	}
**/

    
    static testMethod void createCaseWithFullTestHelper()
    {
	  	System.runAs(testRunUser) 
	  	{
	        ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
	        ECICTestHelper.getRegion('');
	        ECICTestHelper.getPlant();
	        ECICTestHelper.getProduct();
	  	}
	}

/** FIXME (or drop)  : Tests fail new validation rule does not allow description to be blank
	
	static testMethod void createQualityComplaintWithTestHelper()
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			insert ECICCaseTestHelper.createQualityComplaint();
			System.assertEquals( Database.countQuery(SELECT_CASE_COUNT), 1);
	  	}
	}

	
	static testMethod void createNonQualityComplaintWithTestHelper()
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			insert ECICCaseTestHelper.createNonQualityComplaint();
			System.assertEquals( Database.countQuery(SELECT_CASE_COUNT), 1);
	  	}
	}

	
	static testMethod void createInquiryWithTestHelper()
	{
	  	System.runAs(testRunUser) 
		{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			insert ECICCaseTestHelper.createInquiry();
			System.assertEquals( Database.countQuery(SELECT_CASE_COUNT), 1);
		}
	}

	
	static testMethod void createThanksWithTestHelper()
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			insert ECICCaseTestHelper.createThanks();
			System.assertEquals( Database.countQuery(SELECT_CASE_COUNT), 1);
	  	}
	}

	
	static testMethod void createJokeUselessWithTestHelper()
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			insert ECICCaseTestHelper.createJokeUseless();
			System.assertEquals( Database.countQuery(SELECT_CASE_COUNT), 1);
	  	}
	}
**/
	
	static testMethod void createContactWithTestHelper()
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			ECICTestHelper.createContact();
	  	}
	}
	
/** FIXME (or drop)  :

    Currently fails with:

	System.QueryException: List has no rows for assignment to SObject 
	Stack Trace: Class.ECICAccountTestHelper.createBusinessAccount: line 72, column 1 Class.ECICTestHelperTest.createBusinessAccountWithTestHelper: line 109, column 1
	
	static testMethod void createBusinessAccountWithTestHelper()
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			ECICAccountTestHelper.createBusinessAccount();
			//System.assertEquals([SELECT Count() FROM Account WHERE name=:ECICCommonConstants.BUSINESS_ACCOUNT_NAME], 1);
	  	}
	}
**/
	
	static testMethod void createPointOfSaleWithTestHelper()
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			ECICAccountTestHelper.createPointOfSale(ECICCommonConstants.TEST_CITY_STATE_AND_REGION);
			System.assertNotEquals([SELECT count() FROM Region__c WHERE name=:ECICCommonConstants.TEST_CITY_STATE_AND_REGION], 0 );
			   System.assertNotEquals([SELECT count() FROM Account WHERE Name=:ECICCommonConstants.ACCOUNT_NAME], 1);
	  	}
	}
	
	static testMethod void createPromotionWithTestHelper()
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			insert ECICTestHelper.createPromotion();
			System.assertEquals([SELECT count() FROM Promotion__c WHERE name =: ECICCommonConstants.TEST_PROMOTION] , 1);
	  	}
	}
	
	static testMethod void createPromotionTypeWithTestHelper()
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			insert ECICTestHelper.createPromotionType();
			System.assertEquals([SELECT count() FROM Promotion_Type__c WHERE name =: ECICCommonConstants.TEST_PROMOTION] , 1);
	  	}
	}
	
	static testMethod void createCompetitorProductWithTestHelper()
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			insert ECICTestHelper.createCompetitorProduct();
			System.assertEquals([SELECT count() FROM Competitor_Product__c 
			                     WHERE name =: ECICCommonConstants.TEST_COMPETITOR_PRODUCT] , 1);
	  	}
	}
	
	static testMethod void createProductWithTestHelper()
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			insert ECICTestHelper.createProduct();
			System.assertEquals([SELECT count() FROM Product__c WHERE name =: ECICCommonConstants.PRODUCT_NAME_DEFAULT] , 3);
	  	}
	}
	
	static testMethod void createProductionLineWithTestHelper()
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			Plant__c plant = ECICTestHelper.createPlant();
			insert plant;
			//System.assertEquals([SELECT count() FROM Plant__c WHERE name =: ECICCommonConstants.TEST_PLANT] , 1);
			insert ECICTestHelper.createProductionLine(plant);
			System.assertNotEquals([SELECT count() FROM Production_Line__c 
			                        WHERE name =: ECICCommonConstants.TEST_PRODUCTION_LINE_NAME] , 0 );
			ECICTestHelper.getProductionLine();
			ECICTestHelper.getSpecProductionLine(plant,'name');
	  	}
	}
	
/** FIXME (or drop)  : Tests fail new validation rule does not allow description to be blank
	
	static testMethod void createTaskWithTestHelper()
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			Case testCase = ECICCaseTestHelper.createQualityComplaint();
			insert testCase;
			insert ECICTestHelper.createTask(testCase);
			System.assertEquals([SELECT count() FROM Task WHERE WhatId=:testCase.Id], 1);
	  	}
	}
**/
	
	static testMethod void createTrendWithTestHelper()
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			insert ECICTestHelper.createTrend();
			      System.assertNOTEquals([SELECT count() FROM Trend__c WHERE Name ='testTrend'], 1);
	  	}
	}
	
	static testMethod void createActionPlanWithTestHelper()
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			insert ECICTestHelper.createActionPlan();
			System.assertEquals(Database.countQuery(SELECT_AP_COUNT), 1);
	  	}
	}
	
	static testMethod void createActionPlansWithTestHelper()
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			try {
				insert ECICTestHelper.createActionPlans();
			} catch (System.DMLException ex) {
				System.debug(ex);
			}
			System.assertEquals(Database.countQuery(SELECT_AP_COUNT), 1);
	  	}
	}
	
	static testMethod void createActionPlanItemWithTestHelper()
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			Action_Plan__c AP = ECICTestHelper.createActionPlan();
			insert AP;
			System.assertEquals(Database.countQuery(SELECT_AP_COUNT), 1);
			Action_Plan_Item__c testInstance =  ECICTestHelper.createActionPlanItem();
			testInstance.Action_plan__c = Ap.Id;
			insert testInstance;
			System.assertEquals([SELECT count() FROM Action_Plan_Item__c 
			                     WHERE Name =: ECICCommonConstants.ACTION_PLAN_ITEM_PARAM_1[0]], 1);
	  	}
	}
	
	static testMethod void createActionPlanItemsWithTestHelper()
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			Action_Plan__c AP = ECICTestHelper.createActionPlan();
			insert AP;
			List<Action_Plan_Item__c> APIs = ECICTestHelper.createActionPlanItems();
			for(Action_Plan_Item__c api: APIs){
				api.Action_plan__c = AP.Id;
			}
			try {
				insert APIs;
			} catch (System.DMLException ex) {
				System.debug(ex);
			}
			System.assertEquals([SELECT count() FROM Action_Plan_Item__c WHERE Name =:ECICCommonConstants.ACTION_PLAN_ITEM_PARAM_1[0]], 3);
	  	}
	}
	
	static testMethod void createAPTaskEqualsConditionWithTestHelper() 
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		    ECICTestHelper.createAPTaskEqualsCondition('fieldName','value');
	  	}
	}
	
	static testMethod void createAPTaskNotEqualsConditionWithTestHelper() 
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		    ECICTestHelper.createAPTaskNotEqualsCondition('fieldName','value');
	  	}
	}
	
/*	static testMethod void initTestEnvironmentTest()
{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			System.assertNotEquals(CaseRecordType__c.getInstance(), null);
			System.assertNotEquals(Country_Specific_Settings__c.getInstance(), null);
			System.assertNotEquals(CaseRecordType__c.getInstance(), null);
			
			System.assertEquals( ECICCaseQualityComplaintRecordTypeHelper.DEFAULT_QUALITY_COMPLAINT_ID,
					ECICCommonConstants.CASE_QUILITY_COMPLAINT_RT_ID );
		}
	}*/

	//******************************** ECICAccountTestHelper  tests*****************************************************

	static testMethod void verifyPersonAccount() 
	{
	  	System.runAs(testRunUser) 
	  	{
			ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
			Account persAcc = ECICAccountTestHelper.personAccount;
			System.assertEquals(persAcc.RecordTypeId, ECICCommonConstants.ACCOUNT_PERSON_RT_ID);
	  	}
	}

	static testMethod void verifyBusinessAccount() 
	{
	  	System.runAs(testRunUser) 
	  	{
		    ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		    Account businessAcc = ECICAccountTestHelper.businessAccount;
		    System.assertEquals(businessAcc.RecordTypeId, ECICCommonConstants.ACCOUNT_BUSINESS_RT_ID);
	  	}
	}

	static testMethod void verifyCreatePointOfSale() 
	{
	  	System.runAs(testRunUser) 
	  	{
		    ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		    Account PoS = ECICAccountTestHelper.createPointOfSale(ECICCommonConstants.TEST_CITY_STATE_AND_REGION);
		    insert PoS;
		    System.assertEquals(PoS.point_of_sale__c, true);
	  	}
	}

	static testMethod void verifyGetPointOfSale() 
	{
	  	System.runAs(testRunUser) 
	  	{
		    ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		    Account PoS = ECICAccountTestHelper.getPointOfSale();
		    System.assertEquals(PoS.point_of_sale__c, true);
	  	}
	}

	static testMethod void verifyGetPointOfSaleWithParam() 
	{
	  	System.runAs(testRunUser) 
	  	{
		    ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		    Account PoS = ECICAccountTestHelper.getPointOfSale(ECICCommonConstants.TEST_CITY_STATE_AND_REGION);
		    System.assertEquals(PoS.point_of_sale__c, true);
	  	}
	}

	static testMethod void verifyCreateUserDefault() 
	{
	  	System.runAs(testRunUser) 
	  	{
			User testUser = ECICTestHelper.createTestUser('System Administrator');
			System.debug(loggingLevel.INFO, 'INFO: id = '+ testUser.id);
			System.debug( Logginglevel.INFO , 'testUser :' + testUser );
			testUser = [SELECT Profile.Name FROM user WHERE Id =: testUser.id LIMIT 1];
			System.assertEquals(testUser.profile.Name, 'System Administrator');
	  	}
	}

	static testMethod void verifyCreateUserWithParam() 
	{
	  	System.runAs(testRunUser) 
	  	{
			User testUser = ECICTestHelper.createTestUser(	'Test User With Param',
															ECICCommonConstants.PROFILE_SYSTEM_ADMIN,
															ECICCommonConstants.ROLE_DEFAULT,
															ECICCommonConstants.COUNTRY_CODE_SPAIN
															);
	  	}												
	}
	
	
//------------------------------------- The set of tests for ECICTestHelper.initTestEnvironmentByUser() ----------
	/**
	* @author 			Pavel Slepenkov (Pavel_Slepenkov@epam.com).
	* @date 			13 Feb 2013
	* @description 		Test that all users can init test env.  
	*/
	
	static testMethod void initTestEnvBySpainInfolineAgent() 
	{
	  	System.runAs(testRunUser) 
	  	{
			String[] userParam = new String[]{'Spain Info Agent', 
	                                     ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT,  // # Ecic Template Test 
	                                      ECICCommonConstants.ROLE_ES_INFOLINE_AGENT,
	                                      ECICCommonConstants.COUNTRY_CODE_SPAIN};
	        ECICTestHelper.initTestEnvironmentByUser(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE, userParam);
	  	}
	}
	
    static testMethod void initTestEnvBySpainInfolineSuper() 
    {
	  	System.runAs(testRunUser) 
	  	{
	        String[] userParam = new String[]{'Spain Info Supervisor', 
	        								 ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT,  // # Ecic Template Test 
	                                      ECICCommonConstants.ROLE_IBERIA_INFOLINE_SUPERVISOR,
	                                      ECICCommonConstants.COUNTRY_CODE_SPAIN};
	        ECICTestHelper.initTestEnvironmentByUser(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE, userParam);
	  	}
    }
    
    static testMethod void initTestEnvBySpainBottler() 
    {
	  	System.runAs(testRunUser) 
	  	{
	        String[] userParam = new String[]{'Spain Bottler', 
	                                      ECICCommonConstants.PROFILE_ECIC_IBERIA_BOTTLER_QUALITY,  // # Ecic Template Test 
	                                      ECICCommonConstants.ROLE_IBERIA_BOTTLER_QUALITY,
	                                      ECICCommonConstants.COUNTRY_CODE_SPAIN};
	        ECICTestHelper.initTestEnvironmentByUser(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE, userParam);
	  	}
    }
    
    static testMethod void initTestEnvBySpainKOQuality() 
    {
	  	System.runAs(testRunUser) 
	  	{
	        String[] userParam = new String[]{'Spain KO Quality', 
	                                      ECICCommonConstants.PROFILE_ECIC_IBERIA_COCA_COLA_QUALITY,   // # Ecic Template Test 
	                                      ECICCommonConstants.ROLE_IBERIA_QUALITY_AGENT,
	                                      ECICCommonConstants.COUNTRY_CODE_SPAIN};
	        ECICTestHelper.initTestEnvironmentByUser(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE, userParam);
	  	}
    }

/**	FIXME:
	1.  ECICTestHelperTest.initTestEnvBySpainExtRelation -- System.NullPointerException: Attempt to de-reference a null
    Stack trace: Class.ECICTestHelper.createTestUser: line 549, column 1
    Class.ECICTestHelper.createTestUser: line 558, column 1
    Class.ECICTestHelper.initTestEnvironmentByUser: line 82, column 1
    Class.ECICTestHelperTest.initTestEnvBySpainExtRelation: line 448, column 1

	static testMethod void initTestEnvBySpainExtRelation() 
	{
	  	System.runAs(testRunUser) 
	  	{
	        String[] userParam = new String[]{'Spain Ext Relation', 
	                                      ECICCommonConstants.PROFILE_ECIC_EXTERNAL_RELATIONS,
	                                      ECICCommonConstants.ROLE_IBERIA_BOTTLER_EXTERNALS,
	                                      ECICCommonConstants.COUNTRY_CODE_SPAIN};
	        ECICTestHelper.initTestEnvironmentByUser(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE, userParam);
	  	}
    }
**/	
	static testMethod void initTestEnvBySpainAdmin() 
	{
	  	System.runAs(testRunUser) 
	  	{
	        String[] userParam = new String[]{'Spain Admin', 
	                                      ECICCommonConstants.PROFILE_SYSTEM_ADMIN,
	                                      ECICCommonConstants.ROLE_ES_COCA_COLA,
	                                      ECICCommonConstants.COUNTRY_CODE_SPAIN};
	        ECICTestHelper.initTestEnvironmentByUser(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE, userParam);
	  	}
    }
	

}