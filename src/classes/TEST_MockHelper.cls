@isTest
public class TEST_MockHelper 
{
	private static Integer mockIdCounter = 1;

	public static final Map<Schema.SObjectType, String> SOBJECT_PREFIX_BY_TOKEN_MAP = new Map<Schema.SObjectType, String>
	{
        Account.SObjectType                 =>  '001',  // Example: 00111000004gFL4
        Action_Plan__c.SObjectType          =>  'a21',  // Example: a2111000000984i
        Action_Plan_Item__c.SObjectType     =>  'a22',  // Example: a2211000000A6OH
        Beverage__c.SObjectType             =>  'a0n',  // Example: a0n110000001FbG
		Case.SObjectType					=>	'500',	// Example: 50011000001FTZs
		CaseComment.SObjectType             =>  '00a',  // Example: 00a110000007r2C
        Closed_Trend__c.SObjectType         =>  'a0A',  // Example: a0A11000001CrYf
        Competitor_Product__c.SObjectType   =>  'a0J',  // Example: a0Jg0000001YNCT
		Contact.SObjectType 				=>  '003',	// Example: 00311000003YG5e
		EmailMessage.SObjectType            =>  '02S',  // Example: 02s11000003VAAS
		EmailTemplate.SObjectType           =>  '00X',  // Example: 00X20000001mWDd
        Folder.SObjectType                  =>  '00l',  // Example: 00l20000001RZYM
		Open_Alert__C.SObjectType			=>	'a0D',	// Example: a0D110000003C4X
		Open_Alert_Case__c.SObjectType      =>  'a0C',  // Example: a0C110000001EAU
        Package__c.SObjectType              =>  'a11',  // Example: a11110000002OhQ
        Plant__c.SObjectType                =>  'a0G',  // Example: a0G110000000atg
		Product__c.SObjectType 				=>  'a0I',	// Example: a0I11000000Y56r
		Production_Line__c.SObjectType		=>  'a0H',	// Example: a0H110000001Tz2
		Profiles_Mapping__c.SObjectType 	=>  'a0E',	// Example: a0E110000001dyy
        Promotion__c.SObjectType            =>  'a1l',  // Example: a1lg00000002tDx
        Promotion_Type__c.SObjectType       =>  'a29',  // Example: a29g00000002724
		Region__c.SObjectType               =>  'a2C',  // Example: a2C11000000Cjix
		Task.SObjectType					=>	'00T',	// Example: 00T11000003LnrJ
		Trend__c.SObjectType				=>	'a0K',	// Example: a0K110000008v95
		User.SObjectType					=>  '005',	// Example: 00520000001qmXm
        UserRole.SObjectType                =>  '00E',  // Example: 00Eg0000000S65q
		User_Lookup_Mapping__c.SObjectType 	=>  'a07'	// Example: a0711000000QoVv
	};
	
	// Mock Boolean fields and methods --------------------------------------------------------------------------------------------------------------------
	
	private static Map<String, Map<String, Boolean>> mockBooleanFieldValueMapByIdMap = new Map<String, Map<String, Boolean>>();
	
	public static void setMockBoolean (String key, String fieldName, Boolean value)
	{
		if (!mockBooleanFieldValueMapByIdMap.containsKey(key)) { mockBooleanFieldValueMapByIdMap.put(key, new Map<String, Boolean>()); }
		mockBooleanFieldValueMapByIdMap.get(key).put(fieldName, value);
	}
	
	public static void setMockBoolean (SObject dummySObject, String fieldName, Boolean value)
	{
		// First we try to set the value from the Id
		if (dummySObject.id != null)
		{
			if (!mockBooleanFieldValueMapByIdMap.containsKey(dummySObject.id)) 
			{ 
				mockBooleanFieldValueMapByIdMap.put(dummySObject.id, new Map<String, Boolean>()); 
			}
			mockBooleanFieldValueMapByIdMap.get(dummySObject.id).put(fieldName, value);
		}
		else // We map values twice because while dummyCase.id is more reliably unique, this value won't always be populated when we need to get or set the value.
		{
			setMockBoolean (ECICMapHelper.createMapIdentifier(dummySObject, false), fieldName, value);
		}
	}


	public static Boolean getMockBoolean (String key, String fieldName)
	{
		if (
					(!mockBooleanFieldValueMapByIdMap.containsKey(key))
				||	(!mockBooleanFieldValueMapByIdMap.get(key).containsKey(fieldName))
		   )
		{ 
			return false;																			// If we can't match the string identifier, return false. 
		}

		return mockBooleanFieldValueMapByIdMap.get(key).get(fieldName);			// Return the string identifier's matching value.
		
	}
	
	public static Boolean getMockBoolean (SObject dummySObject, String fieldName)
	{
		if ((dummySObject == null) || (fieldName == null)) 
		{ 
			return false; 																			// Return false if either value required to find the value is null.
		}
		
		if (dummySObject.id != null)																// First we try to get the value from the Id.
		{
			if (	 
				     (mockBooleanFieldValueMapByIdMap.containsKey(dummySObject.id)) 
			  && (mockBooleanFieldValueMapByIdMap.get(dummySObject.id).containsKey(fieldName))
			) 
		{
				return mockBooleanFieldValueMapByIdMap.get(dummySObject.id).get(fieldName);			// Return value matched to the SObject.id, if there is a match
		}
		}
			
		return getMockBoolean (ECICMapHelper.createMapIdentifier(dummySObject, false), fieldName);		// As backup, create a string identifier.	
	}

	// -------------------------------------------------------------------------------------

	private static Map<String, Map<String, String>> mockStringFieldValueMapByIdMap = new Map<String, Map<String, String>>();

	public static void setMockString (String key, String fieldName, String value)
	{
		if (!mockStringFieldValueMapByIdMap.containsKey(key)) { mockStringFieldValueMapByIdMap.put(key, new Map<String, String>()); }
		mockStringFieldValueMapByIdMap.get(key).put(fieldName, value);
	}

	public static void setMockString (SObject dummySObject, String fieldName, String value)
	{
		// First we try to set the value from the Id
		if (dummySObject.id != null)
		{
			if (!mockStringFieldValueMapByIdMap.containsKey(dummySObject.id)) 
			{ 
				mockStringFieldValueMapByIdMap.put(dummySObject.id, new Map<String, String>()); 
			}
			mockStringFieldValueMapByIdMap.get(dummySObject.id).put(fieldName, value);
			
		}
		else // Wwhile dummyCase.id is more reliably unique, this value won't always be populated when we need to get or set the value.
		{
			setMockString (ECICMapHelper.createMapIdentifier(dummySObject, false), fieldName, value);
		}
	}

	public static String getMockString (String key, String fieldName)
	{
		if (
					(!mockStringFieldValueMapByIdMap.containsKey(key))
				||	(!mockStringFieldValueMapByIdMap.get(key).containsKey(fieldName))
		   )
		{ 
			return null;																			// If we can't match the string identifier, return false. 
		}

		return mockStringFieldValueMapByIdMap.get(key).get(fieldName);			// Return the string identifier's matching value.
	}
	
	public static String getMockString (SObject dummySObject, String fieldName)
	{
		if ((dummySObject == null) || (fieldName == null)) 
		{ 
			return null; 																			// Return false if either value required to find the value is null.
		}
		
		if (dummySObject.id != null)																// First we try to get the value from the Id.
		{
			if (	 
				     (mockStringFieldValueMapByIdMap.containsKey(dummySObject.id)) 
			  && (mockStringFieldValueMapByIdMap.get(dummySObject.id).containsKey(fieldName))
			) 
		{
				return mockStringFieldValueMapByIdMap.get(dummySObject.id).get(fieldName);			// Return value matched to the SObject.id, if there is a match
		}
		}
		
		return getMockString (ECICMapHelper.createMapIdentifier(dummySObject, false), fieldName);	
		}

    // -------------------------------------------------------------------------------------

    private static Map<String, Map<String, Integer>> MockIntegerFieldValueMapByIdMap = new Map<String, Map<String, Integer>>();

    public static void setMockInteger (String key, String fieldName, Integer value)
    {  
        if (!MockIntegerFieldValueMapByIdMap.containsKey(key)) { MockIntegerFieldValueMapByIdMap.put(key, new Map<String, Integer>()); }
        MockIntegerFieldValueMapByIdMap.get(key).put(fieldName, value);
    }

    public static void setMockInteger (SObject dummySObject, String fieldName, Integer value)
    {
        // First we try to set the value from the Id
        if (dummySObject.id != null)
        {
            if (!MockIntegerFieldValueMapByIdMap.containsKey(dummySObject.id)) 
            { 
                MockIntegerFieldValueMapByIdMap.put(dummySObject.id, new Map<String, Integer>()); 
            }
            MockIntegerFieldValueMapByIdMap.get(dummySObject.id).put(fieldName, value);
            
        }
        else // Wwhile dummyCase.id is more reliably unique, this value won't always be populated when we need to get or set the value.
        {
            setMockInteger (ECICMapHelper.createMapIdentifier(dummySObject, false), fieldName, value);
        }
    }

    public static Integer getMockInteger (String key, String fieldName)
    {
        if (
                    (!MockIntegerFieldValueMapByIdMap.containsKey(key))
                ||  (!MockIntegerFieldValueMapByIdMap.get(key).containsKey(fieldName))
           )
        { 
            return null;                                                                            // If we can't match the string identifier, return false. 
        }

        return MockIntegerFieldValueMapByIdMap.get(key).get(fieldName);         // Return the string identifier's matching value.
    }
    
    public static Integer getMockInteger (SObject dummySObject, String fieldName)
    {
        if ((dummySObject == null) || (fieldName == null)) 
        { 
            return null;                                                                            // Return false if either value required to find the value is null.
        }
        
        if (dummySObject.id != null)                                                                // First we try to get the value from the Id.
        {
            if (     
                     (MockIntegerFieldValueMapByIdMap.containsKey(dummySObject.id)) 
              && (MockIntegerFieldValueMapByIdMap.get(dummySObject.id).containsKey(fieldName))
            ) 
	        {
	                return MockIntegerFieldValueMapByIdMap.get(dummySObject.id).get(fieldName);         // Return value matched to the SObject.id, if there is a match
	        }
         }
        
        return getMockInteger (ECICMapHelper.createMapIdentifier(dummySObject, false), fieldName);  
     }


    // Mock SObject List fields and methods --------------------------------------------------------------------------------------------------------------------
    
    private static Map<String, List<SObject>> mockSObjectListByKeyMap = new Map<String, List<SObject>>();
    
    public static void setMockSObjectList (String key, List<SObject> sObjectList)
    {
    	setMockBoolean ('useMockSObjectList', key, true);
        mockSObjectListByKeyMap.put(key, sObjectList);
    }
    
    public static void setMockSObjectList (String key, SObject singleSObject)
    {
    	setMockSObjectList (key, new List<SObject>{ singleSObject });
    }
    
    public static List<SObject> getMockSObjectList (String key)
    {
        return mockSObjectListByKeyMap.get(key);         // Return the string identifier's matching value.
    }

	// -------------------------------------------------------------------------------------

	public static void mockInsert (List<Case> dummyCaseList)
	{	
		// Not sure of the pros and cons of lying here and asserting that a trigger is running; will try being honest that it isn't.
		ECICCaseTriggerHandler handler = new ECICCaseTriggerHandler(false);	
		
		Boolean skipStrategies = getMockBoolean (dummyCaseList[0], 'skipStrategies'); // Takes value from first Case; does not support mixing doing and skipping in same list.
		Boolean doStrategies   = !skipStrategies;
		
		if (doStrategies) { handler.executeStrategyChain(SEPTriggerTypeEnum.BEFORE_INSERT, dummyCaseList, null, null); }
		// NOTE: Does not currently include/support/mock ECICActionPlanHelper.process().
		
		mockInsert ((List<SObject>) dummyCaseList);
		Map<Id, Case> dummyCaseByIdMap = new Map<Id, Case>(dummyCaseList);
									  
		// NOTE: Does not currently include/support/mock ECICActionPlanHelper.processAPTasksOnCaseInsert().
		// NOTE: Does not currently include/support/mock ECICLinkCaseAndOpenAlertsHandler.linkCasesAndOpenAlerts().
		if (doStrategies) { handler.executeStrategyChain(SEPTriggerTypeEnum.AFTER_INSERT, dummyCaseList, null, dummyCaseByIdMap); }
	}

	public static void mockInsert (Case dummyCase) { mockInsert (new List<Case> { dummyCase }); }

	// -------------------------------------------------------------------------------------

	public static void mockInsert (List<SObject> dummySObjectList)
	{	
		for (SObject dummySObject : dummySObjectList)
		{							
			String  mockIdString   = '00000000000' + mockIdCounter++;	// We increment the mockIdCounter so each dummy SObject gets a unique identifier.
			Integer subStringStart = (mockIdString.length() > 12) ? (mockIdString.length() - 12) : 0; 
			dummySObject.put('id', (Id) (SOBJECT_PREFIX_BY_TOKEN_MAP.get(dummySObject.getSObjectType()) + mockIdString.subString(subStringStart))); 
		}
	}

	public static void mockInsert (SObject dummySObject) { mockInsert (new List<SObject> { dummySObject }); }
}