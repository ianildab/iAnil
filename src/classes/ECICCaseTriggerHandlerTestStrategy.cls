@isTest
public class ECICCaseTriggerHandlerTestStrategy extends ECICCaseProcessingStrategyAbstract
{
	public  static final String DO_FAIL_TEST = 'Failure Test';
	
	private static final String ON_BEFORE_INSERT_EXPECTED_STRING 	= 'On Before Insert';
	private static final String ON_AFTER_INSERT_EXPECTED_STRING 	= 'On After Insert';
	private static final String ON_BEFORE_UPDATE_EXPECTED_STRING 	= 'On Before Update';
	private static final String ON_AFTER_UPDATE_EXPECTED_STRING 	= 'On After Update';
	private static final String ON_BEFORE_DELETE_EXPECTED_STRING 	= 'On Before Delete';
	private static final String ON_AFTER_DELETE_EXPECTED_STRING 	= 'On After Delete';
	private static final String ON_AFTER_UNDELETE_EXPECTED_STRING 	= 'On After Undelete';
	
    public override boolean OnBeforeInsert(List<sObject> newSObjectValueList) 										  { return modifySubjects (newSObjectValueList, 		ON_BEFORE_INSERT_EXPECTED_STRING);  }
    public override boolean OnAfterInsert(Map<ID, sObject> newSObjectValueMap) 										  { return addComments    (newSObjectValueMap.values(), ON_AFTER_INSERT_EXPECTED_STRING);   }
    public override boolean OnBeforeUpdate(Map<ID, sObject> oldSObjectValueMap, Map<ID, sObject> newSObjectValueMap)  { return modifySubjects (newSObjectValueMap.values(), ON_BEFORE_UPDATE_EXPECTED_STRING);  } 
    public override boolean OnAfterUpdate(Map<ID, sObject> oldSObjectValueMap, Map<ID, sObject> newSObjectValueMap)   { return addComments 	  (newSObjectValueMap.values(), ON_AFTER_UPDATE_EXPECTED_STRING); 	}
    public override boolean OnBeforeDelete(Map<ID, sObject> oldSObjectValueMap) 									  { return addContacts 	  (oldSObjectValueMap.values(), ON_BEFORE_DELETE_EXPECTED_STRING);  } 
    public override boolean OnAfterDelete(Map<ID, sObject> oldSObjectValueMap)  									  { return addContacts	  (oldSObjectValueMap.values(), ON_AFTER_DELETE_EXPECTED_STRING); 	}
    public override boolean OnAfterUndelete(Map<ID, sObject> newSObjectValueMap) 									  { return addComments    (newSObjectValueMap.values(), ON_AFTER_UNDELETE_EXPECTED_STRING); }
    	
	// -----------------------------------------------------
     
    private static Boolean modifySubjects(List<sObject> newSObjectValueList, String expectedResultString)
    {
    	Integer i = 0;
    	for (Case currentCase : (List<Case>) newSObjectValueList)
    	{
    		if (currentCase.subject == DO_FAIL_TEST) 
    		{ 
    			return false; 
    		}
    		currentCase.subject = expectedResultString + ++i;
    	}
    	
    	return true;
    }
    
    private static Boolean addComments(List<sObject> newSObjectValueList, String expectedResultString)
    {
    	List<CaseComment> newCaseCommentList = new List<CaseComment>();
    	Integer i = 0;
    	for (Case currentCase : (List<Case>) newSObjectValueList)
    	{
    		if (currentCase.subject == DO_FAIL_TEST) 
    		{ 
    			return false; 
    		}
    		
    		newCaseCommentList.add(new CaseComment( parentId = currentCase.id, commentBody = expectedResultString + ++i ));
    	}
    	insert newCaseCommentList;
    	return true;
    }
    
    private static Boolean addContacts(List<sObject> newSObjectValueList, String expectedResultString)
    {
    	Map<Id, Contact> newContactByCaseIdMap = new Map<Id, Contact>();
    	Integer i = 0;
    	for (Case currentCase : (List<Case>) newSObjectValueList)
    	{
    		if (currentCase.subject == DO_FAIL_TEST) 
    		{ 
    			return false; 
    		}
    		
    		Contact newContact = new Contact (
    											lastName  = expectedResultString + ++i, 
    											email = currentCase.id + '@delete.example.com'
    										 );
    		newContactByCaseIdMap.put (currentCase.id, newContact);
    	}
    	insert newContactByCaseIdMap.values();
    	return true;
    }
    
    
    //--------------------------------------------------------------------------------------------------------------------------------
    
    public static void assertExecution (Boolean passTestExpected, Boolean passTestResult, SEPTriggerTypeEnum dummyTriggerType, Case dummyCase)
    {
      	System.assertEquals (passTestExpected, passTestResult);
	  	if (passTestResult)
	  	{
	  		if 		(dummyTriggerType == SEPTriggerTypeEnum.BEFORE_INSERT)  { System.assert    (dummyCase.subject.contains(ON_BEFORE_INSERT_EXPECTED_STRING));  }
	  		else if (dummyTriggerType == SEPTriggerTypeEnum.AFTER_INSERT)   { assertHasComment (dummyCase.id, 			   ON_AFTER_INSERT_EXPECTED_STRING);    }
	  		else if (dummyTriggerType == SEPTriggerTypeEnum.BEFORE_UPDATE)  { System.assert    (dummyCase.subject.contains(ON_BEFORE_UPDATE_EXPECTED_STRING));  }
	  		else if (dummyTriggerType == SEPTriggerTypeEnum.AFTER_UPDATE)   { assertHasComment (dummyCase.id, 			   ON_AFTER_UPDATE_EXPECTED_STRING);    }
	  		else if (dummyTriggerType == SEPTriggerTypeEnum.AFTER_UNDELETE) { assertHasComment (dummyCase.id, 			   ON_AFTER_UNDELETE_EXPECTED_STRING);  }
	  	}
	}
    
    public static void assertExecution (Boolean passTestExpected, Boolean passTestResult, SEPTriggerTypeEnum dummyTriggerType, Id dummyCaseId)
    {
      	System.assertEquals (passTestExpected, passTestResult);
	  	if (passTestResult)
	  	{
	  		if 		(dummyTriggerType == SEPTriggerTypeEnum.BEFORE_DELETE)  { assertHasContact (dummyCaseId, 			   ON_BEFORE_DELETE_EXPECTED_STRING);   }
	  		else if (dummyTriggerType == SEPTriggerTypeEnum.AFTER_DELETE)   { assertHasContact (dummyCaseId, 			   ON_AFTER_DELETE_EXPECTED_STRING);    }
	  	}
	}


	private static void assertHasComment (Id dummyCaseId, String expectedResultString)
	{
		List<CaseComment> resultCaseCommentList = [SELECT commentBody FROM CaseComment WHERE parentId = :dummyCaseId];
		System.assertNotEquals (0, resultCaseCommentList.size()); // There could be more than one because we need to insert before we can perform these tests and insertion might also execute this method.
		System.assert (resultCaseCommentList[0].commentBody.contains(expectedResultString));
	}   		   
    
	private static void assertHasContact (Id dummyCaseId, String expectedResultString)
	{
		String expectedEmail = dummyCaseId + '@delete.example.com';
		List<Contact> resultCaseContactList = [
												SELECT lastName 
												FROM Contact 
												WHERE email = :expectedEmail
											  ];
		System.assertEquals (1, resultCaseContactList.size());
		System.assert (resultCaseContactList[0].lastName.contains(expectedResultString));
	}   		   
    
    
    
    
}