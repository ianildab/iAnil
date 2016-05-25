/**
* @description  This class is intended to facilitate creating and populating dummy Contacts for unit testing.*      
* @author       Brian Kessler <Brian_Kessler@epam.com>
* @date         2013 July 22
*/
@isTest
public class TEST_DummyContactFactory 
{
    public class Config
    {
    	public String  firstName    	= null;
        public String  lastName   		= null;
        public String  memberName   	= null;
        public String  email			= null;
        public String  phone			= null;
        public String  mobilePhone      = null;
        public String  homePhone        = null;
        public String  otherPhone       = null;
        public String  countryCode  	= null; 
        public Id      accountId        = null;
        public Id      ownerUserId      = null;
    }
    
    // Methods for creating one Contact -----------------------------------------------------------------------

    /** 
    * @description  Method to create dummy Contact for testing.
    * @author       Brian Kessler <Brian_Kessler@epam.com>
    * @date         2013 July 18
    * @param        Config config : Use inner class to configure dummy records.
    * @param        Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
    * @return       Contact
    **/
    public static Contact create (Config config, TEST_DummyInsertModeEnum insertMode)
    {
    	TEST_UniqueHelper uniqueHelper = new TEST_UniqueHelper('Contact'); 
    	
        Contact dummyContact = new Contact(); 
                dummyContact.lastName 	   	 	= TEST_ConfigHelper.chooseValue(Config.lastName,    uniqueHelper.uniqueString);
                dummyContact.firstName 	   	 	= TEST_ConfigHelper.chooseValue(Config.firstName,   uniqueHelper.uniqueString);
                dummyContact.email		    	= TEST_ConfigHelper.chooseValue(Config.email,  	    null);
                dummyContact.phone		    	= TEST_ConfigHelper.chooseValue(Config.phone,  	    null);
                dummyContact.mobilePhone        = TEST_ConfigHelper.chooseValue(Config.mobilePhone,       null);
                dummyContact.homePhone          = TEST_ConfigHelper.chooseValue(Config.homePhone,       null);
                dummyContact.otherPhone         = TEST_ConfigHelper.chooseValue(Config.otherPhone,       null);
                dummyContact.Country_Code__c	= TEST_ConfigHelper.chooseValue(Config.countryCode, null);
                dummyContact.AccountId          = TEST_ConfigHelper.chooseValue(Config.accountId,   (Id) null);
                
                if (config.ownerUserId != null) { dummyContact.OwnerId = config.ownerUserId; } 
                
		if 			(insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyContact );	} 
		else if 	(insertMode	== TEST_DummyInsertModeEnum.REAL)  { 					 insert    dummyContact;    }

        return dummyContact;
    }

    /** 
    * @description  Method to create dummy Contact for testing.
    * @author       Brian Kessler <Brian_Kessler@epam.com>
    * @date         2013 July 18
    * @param        Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
    * @return       Contact
    **/
    public static Contact create (TEST_DummyInsertModeEnum insertMode) { return create(new Config(), insertMode); }

    /** 
    * @description  Method to create dummy Contact for testing; won't be inserted into SFDC DB at create time.
    * @author       Brian Kessler <Brian_Kessler@epam.com>
    * @date         2013 July 18
    * @param        Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
    * @return       Contact
    **/
    public static Contact create()  { return create(new Config(), TEST_DummyInsertModeEnum.NONE); }

    // Methods for creating multiple Contacts -----------------------------------------------------------------------
    
    /** 
    * @description  Method to create dummy Contact list for testing.
    * @author       Brian Kessler <Brian_Kessler@epam.com>
    * @date         2013 July 18
    * @param        Integer numberOfContacts : How many Contacts to create
    * @param        Config config : Use inner class to configure dummy records.
    * @param        Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
    * @return       List<Contact>
    **/
    public static List<Contact> createList (Integer numberOfContacts, Config config, TEST_DummyInsertModeEnum insertMode )
    {
        List<Contact> dummyContactList = new List<Contact>();
        for (Integer i=1; i<=numberOfContacts; i++)
        {
            dummyContactList.add(create(config, TEST_DummyInsertModeEnum.NONE));            
        }

		if 			(insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyContactList );	}  
		else if 	(insertMode	== TEST_DummyInsertModeEnum.REAL)  { 					 insert    dummyContactList;    }

        return dummyContactList;
    }
    
    /** 
    * @description  Method to create dummy Contact list for testing.
    * @author       Brian Kessler <Brian_Kessler@epam.com>
    * @date         2013 July 18
    * @param        Integer numberOfContacts : How many Contacts to create
    * @param        Boolean insertNow : Whether to insert into SFDC DB now, or wait for latter processing.
    * @return       List<Contact>
    **/
    public static List<Contact> createList (Integer numberOfContacts,  TEST_DummyInsertModeEnum insertMode )
    {
        return createList(numberOfContacts, (new Config()), insertMode); 
    }
    
    /** 
    * @description  Method to create dummy Contact list for testing; won't be inserted into SFDC DB at create time.
    * @author       Brian Kessler <Brian_Kessler@epam.com>
    * @date         2013 July 18
    * @param        Integer numberOfContacts : How many Contacts to create
    * @return       List<Contact>
    **/
    public static List<Contact> createList (Integer numberOfContacts) 
    { 
        return createList(numberOfContacts,  (new Config()), TEST_DummyInsertModeEnum.NONE); 
    }
 
    public static List<Contact> createList (List<Config> configList, TEST_DummyInsertModeEnum insertMode) 
    {
    	List<Contact> dummyContactList = new List<Contact>();
    	for (Config config : configList)
    	{
    		dummyContactList.add(create(config, TEST_DummyInsertModeEnum.NONE));
    	}

		if 			(insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyContactList );	} 
		else if 	(insertMode	== TEST_DummyInsertModeEnum.REAL)  { 					 insert    dummyContactList;    }

    	return dummyContactList;
    }
 
    //--------------------------------------------------------------------------------------------------

	// @depreciated : Use create (Config config, TEST_DummyInsertModeEnum insertMode)
	public static Contact createDummy (Config config, Boolean insertNow)    { return create (config, 	   convert(insertNow));            }

	// @depreciated : Use create (TEST_DummyInsertModeEnum insertMode)
	public static Contact createDummy (Boolean insertNow) 					{ return create (new Config(), convert(insertNow));            }

	// @depreciated : Use create (TEST_DummyInsertModeEnum insertMode)
	public static Contact createDummy () 									{ return create (new Config(), TEST_DummyInsertModeEnum.NONE); }

	// @depreciated : Use createList (Integer numberOfContacts, Config config, TEST_DummyInsertModeEnum insertMode )
    public static List<Contact> createDummyList (Integer numberOfContacts, Config config, Boolean insertNow ) { return createList(numberOfContacts, config, 		convert(insertNow)); 		 	}
    
	// @depreciated : Use createList (Integer numberOfContacts, TEST_DummyInsertModeEnum insertMode )
    public static List<Contact> createDummyList (Integer numberOfContacts,  Boolean insertNow ) 			  { return createList(numberOfContacts, (new Config()), convert(insertNow)); 			}
    
 	// @depreciated : Use createList (Integer numberOfContacts)
    public static List<Contact> createDummyList (Integer numberOfContacts)  								  { return createList(numberOfContacts, (new Config()), TEST_DummyInsertModeEnum.NONE); }

 	// @depreciated : Use createList (Integer numberOfContacts)
    public static List<Contact> createDummyList (List<Config> configList, Boolean insertNow)				  { return createList(					configList, 	convert(insertNow));			}
    
	private static TEST_DummyInsertModeEnum convert (Boolean insertNow)
	{
		return (insertNow) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE;
	}

  	// Assertion Methods --------------------------------------------------------------------------------------------------------------------
    
    /**
     *	@description 	Method to test if two Contact are the same
     *	@author 		Brian Kessler <Brian_Kessler@epam.com>
     *	@date			2013 August 07
     *  @param			Contact expectedContact 
     *  @param			Contact actualContact
     *  @return			None
     **/
 	public static void assertEquals (Contact expectedContact, Contact actualContact)
    {
    	System.assertEquals(expectedContact.lastName,	actualContact.lastName);
    	System.assertEquals(expectedContact.firstName,	actualContact.firstName);
    } 

    /**
     *	@description 	Method to test if two Contact Lists are the same
     *	@author 		Brian Kessler <Brian_Kessler@epam.com>
     *	@date			2013 August 07
     *  @param			List<Contact> expectedContactList 
     *  @param			List<Contact> actualContactList
     *  @return			None
     **/
 	public static void assertEquals (List<Contact> expectedContactList, List<Contact> actualContactList)
    {
    	System.assertEquals(expectedContactList.size(),		actualContactList.size());
    	expectedContactList.sort();
    	actualContactList.sort();
    	
    	for (Integer i=0; i<expectedContactList.size(); i++)
    	{
    		assertEquals (expectedContactList[i], actualContactList[i]);
    	}
    	
    } 
 
    /**
     *	@description 	Method to test if two Contact Maps are the same
     *	@author 		Brian Kessler <Brian_Kessler@epam.com>
     *	@date			2013 August 07
     *  @param			Map<Id, List<Contact>> expectedAccountContactMap 
     *  @param			Map<Id, List<Contact>> actualAccountContactMap
     *  @return			None
     **/
 	public static void assertEquals (Map<Id, List<Contact>> expectedAccountContactMap, Map<Id, List<Contact>> actualAccountContactMap)
    {
    	System.assertEquals(expectedAccountContactMap.keySet().size(), actualAccountContactMap.keySet().size());
    	
    	for (Id id : expectedAccountContactMap.keySet())
    	{
    		System.assert(actualAccountContactMap.keySet().contains(id));
    		assertEquals (expectedAccountContactMap.get(id), actualAccountContactMap.get(id));
    	}
    	
    } 
    
}