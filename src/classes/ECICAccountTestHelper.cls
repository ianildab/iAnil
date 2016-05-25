@isTest
// @depreciated: Use TEST_DummyAccountFactory
public class ECICAccountTestHelper 
{
	  // @depreciated: Use TEST_DummyAccountFactory.create (Config config, TEST_DummyInsertModeEnum insertMode)
	  public static Account createDummyAccount(String accountType, Boolean insertNow)
	  {
			TEST_DummyAccountFactory.Config config = new TEST_DummyAccountFactory.Config();
											config.isPerson = (accountType == 'Person');
			return TEST_DummyAccountFactory.create(config, convert(insertNow));
	  }

	   // @depreciated: Use TEST_DummyAccountFactory.create (Config config, TEST_DummyInsertModeEnum insertMode)
	  public static Account createDummyAccount(String accountType, String triggerType) { return createDummyAccount(accountType, (triggerType != 'isInsert')); }

	  public static Account businessAccount 
	  {
		get
		{
			TEST_DummyAccountFactory.Config config = new TEST_DummyAccountFactory.Config();
											config.recordTypeId = ECICCommonConstants.ACCOUNT_BUSINESS_RT_ID;
											config.type         = ECICCommonConstants.ACCOUNT_TYPE_DEFAULT;
											config.name         = ECICCommonConstants.ACCOUNT_BUSINESS_NAME;
											config.tradeChannel = ECICCommonConstants.ACCOUNT_TRADE_CHANNEL;
											config.isActive		= true;
											config.isPerson     = false;
			return TEST_DummyAccountFactory.create(config, TEST_DummyInsertModeEnum.NONE);
		}
		set;
	  }

  	  public static Account personAccount 
	  {
		get
		{
			TEST_DummyAccountFactory.Config config = new TEST_DummyAccountFactory.Config();
											config.recordTypeId 	  = ECICCommonConstants.ACCOUNT_PERSON_RT_ID;
											config.firstName		  = ECICCommonConstants.ACCOUNT_PERSON_FIRST_NAME;
											config.lastName			  = ECICCommonConstants.ACCOUNT_PERSON_LAST_NAME;
											config.shippingStreet     = ECICCommonConstants.TEST_STREET;
											config.shippingState      = ECICCommonConstants.TEST_CITY_STATE_AND_REGION;
											config.shippingPostalCode = ECICCommonConstants.TEST_POSTAL_CODE;
											config.shippingCountry    = ECICCommonConstants.TEST_COUNTRY;
											config.shippingCity       = ECICCommonConstants.TEST_CITY_STATE_AND_REGION;
											config.isPerson     	  = true;
			return TEST_DummyAccountFactory.create(config, TEST_DummyInsertModeEnum.NONE);
		}
		set;
	  }

	  // @depreciated: Use TEST_DummyAccountFactory.create (Config config, TEST_DummyInsertModeEnum insertMode)
	  public static Account createAccount(String Name, String Type)
	  {
			TEST_DummyAccountFactory.Config config = new TEST_DummyAccountFactory.Config();
											config.name = name;
											config.type = type;
											config.shippingStreet     = ECICCommonConstants.TEST_STREET;
											config.shippingState      = ECICCommonConstants.TEST_CITY_STATE_AND_REGION;
											config.shippingPostalCode = ECICCommonConstants.TEST_POSTAL_CODE;
											config.shippingCountry    = ECICCommonConstants.TEST_COUNTRY;
											config.shippingCity       = ECICCommonConstants.TEST_CITY_STATE_AND_REGION;
			return TEST_DummyAccountFactory.create(config, TEST_DummyInsertModeEnum.NONE);
	  }
	  
	  // @depreciated: Use TEST_DummyAccountFactory.create ()
	  public static Account createAccount()  { return createAccount(ECICCommonConstants.ACCOUNT_NAME, ECICCommonConstants.ACCOUNT_TYPE_DEFAULT); }
  
	  // @depreciated: Use TEST_DummyAccountFactory.create ()
	  public static Account createBusinessAccount()  
	  { 
			insert businessAccount;
			return [SELECT Id, Name, Type, ShippingStreet, ShippingPostalCode, ShippingCountry, ShippingCity, Region__c, IsPersonAccount FROM Account WHERE Id =:businessAccount.Id];
	  }
  
	  // @depreciated: Use TEST_DummyAccountFactory.create ()
	  public static Account getPersonAccount()  
	  { 
			insert personAccount;
			return [SELECT Id, RecordTypeId, FirstName, LastName, ShippingStreet, ShippingState, ShippingPostalCode, ShippingCountry, ShippingCity, IsPersonAccount FROM Account WHERE Id =: personAccount.Id];
	  }
  
	  // @depreciated: Use TEST_DummyAccountFactory.createPointOfSale (Id keyAccountId, TEST_DummyInsertModeEnum insertMode) 
	  public static Account createPointOfSale() 
	  {
		  Account testPoS 					= businessAccount;
				  testPoS.Point_of_Sale__c	= true;
				  testPoS.ParentId          = getPoSKeyAccount().Id;
		   return testPoS;
	  }

	  // @depreciated: Use TEST_DummyAccountFactory.createPointOfSale (Id keyAccountId, TEST_DummyInsertModeEnum insertMode) 
	  public static Account createPointOfSale(String regionName) 
	  {
			Account testPoS 					= createPointOfSale();
					testPoS.ShippingState		= regionName;
			 return testPoS;
	  }
  
	  // @depreciated: Use TEST_DummyAccountFactory.createPointOfSale (Id keyAccountId, TEST_DummyInsertModeEnum insertMode) 
	  public static Account getPointOfSale() 
	  {
			Account testPoS 					= createPointOfSale();
			 insert testPoS;
			return [SELECT Id, Name,Point_of_Sale__c,Region__c, Type, Parent.Name, ParentId FROM Account WHERE Id=:testPoS.Id][0];
	  }

	  // @depreciated: Use TEST_DummyAccountFactory.createPointOfSale (Id keyAccountId, TEST_DummyInsertModeEnum insertMode) 
	  public static Account getPointOfSale(String regionName) 
	  {
			Account testPoS 			= createPointOfSale(regionName);
			 insert testPoS;
			return [SELECT Id, Name,Point_of_Sale__c,Region__c, Type, Parent.Name, ParentId FROM Account WHERE Id=:testPoS.Id][0];
	  }

	  // @depreciated: Use TEST_DummyAccountFactory.createPackageSupplier (TEST_DummyInsertModeEnum insertMode)
	  public static Account createSupplier() 
	  {
			Account supplier = businessAccount;
					supplier.Type = ECICCommonConstants.ACCOUNT_TYPE_SUPPLIER;
			 return supplier;
	  }
  
	  // @depreciated: Use TEST_DummyAccountFactory.createPackageSupplier (TEST_DummyInsertModeEnum insertMode)
	  public static Account getSupplier() 
	  {
			Account supplier = createSupplier();
					supplier.Type = ECICCommonConstants.ACCOUNT_TYPE_SUPPLIER;
			 insert supplier;
			 return [SELECT Id, Name,Point_of_Sale__c,Region__c FROM Account WHERE Id=:supplier.Id ][0];
	  }
  
	  // @depreciated: Use createBottler (Region__c region, TEST_DummyInsertModeEnum insertMode)
	  public static Account createBottler() 
	  {
			Account bottler = businessAccount;
					bottler.Type = ECICCommonConstants.ACCOUNT_TYPE_BOTTLER;
			 return bottler;
	  }	

	  // @depreciated: Use TEST_DummyAccountFactory.createBottler (Region__c region, Boolean insertNow)
	  public static Account createBottler(Id dummyRegionId, Boolean insertNow) 
	  {
			Account bottler = createBottler();
					bottler.Region__c  		 = dummyRegionId;
			if (insertNow) { insert bottler; }
			return bottler;
	  }	

	  // @depreciated: Use TEST_DummyAccountFactory.createBottler (Region__c region, Boolean insertNow)
	  public static Account getBottler() 
	  {
			Account bottler = createBottler();
			 insert bottler;
			return [SELECT Id, Name, Point_of_Sale__c, Region__c FROM Account WHERE Id=:bottler.Id][0];
	  }
    
	  // @depreciated: Use TEST_DummyAccountFactory.createPointOfSaleKey (TEST_DummyInsertModeEnum insertMode)  
	  public static Account createPoSKeyAccount() 
	  {
			Account posKeyAccount = businessAccount;
				    posKeyAccount.Type = ECICCommonConstants.ACCOUNT_TYPE_POSKEYACCOUNT;
		    return posKeyAccount;
	  }

	  // @depreciated: Use TEST_DummyAccountFactory.createPointOfSaleKey (TEST_DummyInsertModeEnum insertMode)  
	  public static Account getPoSKeyAccount() 
	  {
		Account posKeyAccount = createPoSKeyAccount();
				posKeyAccount.Type = ECICCommonConstants.ACCOUNT_TYPE_POSKEYACCOUNT;
		 insert posKeyAccount;
		return [SELECT Id, Name,Point_of_Sale__c, Region__c, Type, Parent.Name,ParentId FROM Account WHERE Id=:posKeyAccount.Id ][0];
	  }

	// ------------------------------------------------------------------------------------------------------------------------------------
	
	// @depreciated: Use TEST_DummyAccountFactory.create (Config config, TEST_DummyInsertModeEnum insertMode)
	public static Account createDummyPlantsLaboratory(String dummyCountryCode, Boolean insertNow)
	{
		Account dummyPlantsLaboratoryAccount = createDummyAccount ('Business', false);
				dummyPlantsLaboratoryAccount.account_ext_id__c = dummyCountryCode + '_PLANTS_LABORATORY';
		if (insertNow) { insert dummyPlantsLaboratoryAccount; }
		return dummyPlantsLaboratoryAccount;
	}

	// @depreciated: Use TEST_DummyAccountFactory.create (Config config, TEST_DummyInsertModeEnum insertMode)
	public static Account createLaboratory() 
	{
		Account laboratory = businessAccount;
				laboratory.Type = ECICCommonConstants.ACCOUNT_TYPE_LABORATORY;
		 return laboratory;
	}
  
	// @depreciated: Use TEST_DummyAccountFactory.create (Config config, TEST_DummyInsertModeEnum insertMode)
	public static Account getLaboratory() 
	{
		Account laboratory = createLaboratory();
  		 insert laboratory;
        return [SELECT Id, Name,Point_of_Sale__c, Region__c, Type, Parent.Name,ParentId FROM Account WHERE Id=:laboratory.Id ][0];
    }
  
	// ---------------------------------------------------------------------------------------
  
    private static TEST_DummyInsertModeEnum convert (Boolean insertNow)
    {
        return (insertNow) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE;
    }
  
  
}