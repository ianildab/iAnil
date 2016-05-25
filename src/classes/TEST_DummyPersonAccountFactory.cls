/**
* @description  This class is intended to facilitate creating and populating dummy PersonAccounts for unit testing.*      
* @author       Brian Kessler <Brian_Kessler@epam.com>
* @date         2013 October 02
*/
@isTest
public class TEST_DummyPersonAccountFactory 
{
    public class Config
    {
    	public Id	   recordTypeId 		= null;
    	public String  firstName    		= null;
        public String  lastName   			= null;
        public String  email				= null;
    	public String  ShippingPostalCode   = null;
        public String  ShippingCountry   	= null;
        public String  ShippingState   		= null;
        public String  ShippingCity			= null;
        public String  ShippingStreet		= null;
    }
    
    // Methods for creating one PersonAccount -----------------------------------------------------------------------

    /** 
    * @description  Method to create dummy PersonAccount for testing.
    * @author       Brian Kessler <Brian_Kessler@epam.com>
    * @date         2013 October 02
    * @param        Config config : Use inner class to configure dummy records.
    * @param        Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
    * @return       PersonAccount
    **/
    public static Account createDummy (Config config, Boolean insertNow)
    {
        Account dummyPersonAccount = ECICAccountTestHelper.personAccount;
                dummyPersonAccount.RecordTypeId 	  = TEST_ConfigHelper.chooseValue(Config.recordTypeId,  	   	(Id) ECICCommonConstants.ACCOUNT_PERSON_RT_ID);
                dummyPersonAccount.FirstName  		  = TEST_ConfigHelper.chooseValue(Config.firstName,  	   		ECICCommonConstants.ACCOUNT_PERSON_FIRST_NAME);
                dummyPersonAccount.LastName  		  = TEST_ConfigHelper.chooseValue(Config.lastName,   			ECICCommonConstants.ACCOUNT_PERSON_LAST_NAME);
      			dummyPersonAccount.ShippingPostalCode = TEST_ConfigHelper.chooseValue(Config.shippingPostalCode,   	ECICCommonConstants.TEST_POSTAL_CODE);
      			dummyPersonAccount.ShippingCountry    = TEST_ConfigHelper.chooseValue(Config.shippingCountry,   	ECICCommonConstants.TEST_COUNTRY);
      			dummyPersonAccount.ShippingState      = TEST_ConfigHelper.chooseValue(Config.shippingState,   		ECICCommonConstants.TEST_CITY_STATE_AND_REGION);
      			dummyPersonAccount.ShippingCity       = TEST_ConfigHelper.chooseValue(Config.shippingCity,   		ECICCommonConstants.TEST_CITY_STATE_AND_REGION);
      			dummyPersonAccount.ShippingStreet     = TEST_ConfigHelper.chooseValue(Config.shippingStreet,   		ECICCommonConstants.TEST_STREET);
                dummyPersonAccount.personEmail  	  = TEST_ConfigHelper.chooseValue(Config.email,  	   		    null);
        if (insertNow) { insert dummyPersonAccount; } 
        return dummyPersonAccount;
    }

    /** 
    * @description  Method to create dummy PersonAccount for testing.
    * @author       Brian Kessler <Brian_Kessler@epam.com>
    * @date         2013 October 02
    * @param        Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
    * @return       PersonAccount
    **/
    public static Account createDummy (Boolean insertNow) { return createDummy(new Config(), insertNow); }

    /** 
    * @description  Method to create dummy PersonAccount for testing; won't be inserted into SFDC DB at create time.
    * @author       Brian Kessler <Brian_Kessler@epam.com>
    * @date         2013 October 02
    * @param        Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
    * @return       PersonAccount
    **/
    public static Account createDummy()  { return createDummy(false); }

    // Methods for creating multiple PersonAccounts -----------------------------------------------------------------------
    
    /** 
    * @description  Method to create dummy PersonAccount list for testing.
    * @author       Brian Kessler <Brian_Kessler@epam.com>
    * @date         2013 October 02
    * @param        Integer numberOfPersonAccounts : How many PersonAccounts to create
    * @param        Config config : Use inner class to configure dummy records.
    * @param        Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
    * @return       List<PersonAccount>
    **/
    public static List<Account> createDummyList (Integer numberOfPersonAccounts, Config config, Boolean insertNow )
    {
        List<Account> dummyPersonAccountList = new List<Account>();
        for (Integer i=1; i<=numberOfPersonAccounts; i++)
        {
            dummyPersonAccountList.add(createDummy(config, false));            
        }
        if (insertNow) { insert dummyPersonAccountList; } 
        return dummyPersonAccountList;
    }
    
    /** 
    * @description  Method to create dummy PersonAccount list for testing.
    * @author       Brian Kessler <Brian_Kessler@epam.com>
    * @date         2013 October 02
    * @param        Integer numberOfPersonAccounts : How many PersonAccounts to create
    * @param        Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
    * @return       List<PersonAccount>
    **/
    public static List<Account> createDummyList (Integer numberOfPersonAccounts,  Boolean insertNow )
    {
        return createDummyList(numberOfPersonAccounts, (new Config()), insertNow); 
    }
    
    /** 
    * @description  Method to create dummy PersonAccount list for testing; won't be inserted into SFDC DB at create time.
    * @author       Brian Kessler <Brian_Kessler@epam.com>
    * @date         2013 October 02
    * @param        Integer numberOfPersonAccounts : How many PersonAccounts to create
    * @return       List<PersonAccount>
    **/
    public static List<Account> createDummyList (Integer numberOfPersonAccounts) 
    { 
        return createDummyList(numberOfPersonAccounts, false); 
    }
    
    public static List<Account> createDummyList (List<Config> configList,  Boolean insertNow )
    {
    	List<Account> dummyPersonAccountList = new List<Account>();
    	for (Config config : configList)
    	{
    		dummyPersonAccountList.add(createDummy(config,false));
    	}
        if (insertNow) { insert dummyPersonAccountList; } 
    	return dummyPersonAccountList;
    }
 
  	// Assertion Methods --------------------------------------------------------------------------------------------------------------------
    
    /**
     *	@description 	Method to test if two PersonAccount are the same
     *	@author 		Brian Kessler <Brian_Kessler@epam.com>
     *	@date			2013 October 02
     *  @param			PersonAccount expectedPersonAccount 
     *  @param			PersonAccount actualPersonAccount
     *  @return			None
     **/
 	public static void assertEquals (Account expectedPersonAccount, Account actualPersonAccount)
    {
    	System.assertEquals(expectedPersonAccount.lastName,	actualPersonAccount.lastName);
    	System.assertEquals(expectedPersonAccount.firstName,	actualPersonAccount.firstName);
    } 

    /**
     *	@description 	Method to test if two PersonAccount Lists are the same
     *	@author 		Brian Kessler <Brian_Kessler@epam.com>
     *	@date			2013 October 02
     *  @param			List<PersonAccount> expectedPersonAccountList 
     *  @param			List<PersonAccount> actualPersonAccountList
     *  @return			None
     **/
 	public static void assertEquals (List<Account> expectedPersonAccountList, List<Account> actualPersonAccountList)
    {
    	System.assertEquals(expectedPersonAccountList.size(),		actualPersonAccountList.size());
    	expectedPersonAccountList.sort();
    	actualPersonAccountList.sort();
    	
    	for (Integer i=0; i<expectedPersonAccountList.size(); i++)
    	{
    		assertEquals (expectedPersonAccountList[i], actualPersonAccountList[i]);
    	}
    	
    } 
 
    /**
     *	@description 	Method to test if two PersonAccount Maps are the same
     *	@author 		Brian Kessler <Brian_Kessler@epam.com>
     *	@date			2013 October 02
     *  @param			Map<Id, List<PersonAccount>> expectedAccountPersonAccountMap 
     *  @param			Map<Id, List<PersonAccount>> actualAccountPersonAccountMap
     *  @return			None
     **/
 	public static void assertEquals (Map<Id, List<Account>> expectedAccountPersonAccountMap, Map<Id, List<Account>> actualAccountPersonAccountMap)
    {
    	System.assertEquals(expectedAccountPersonAccountMap.keySet().size(), actualAccountPersonAccountMap.keySet().size());
    	
    	for (Id id : expectedAccountPersonAccountMap.keySet())
    	{
    		System.assert(actualAccountPersonAccountMap.keySet().contains(id));
    		assertEquals (expectedAccountPersonAccountMap.get(id), actualAccountPersonAccountMap.get(id));
    	}
    	
    } 
    
}