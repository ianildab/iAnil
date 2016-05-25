@isTest private class SEPTriggerHandlerStrategyTest 
{
    private static final String ON_BEFORE_INSERT_SUBJECT  = 'On Before Insert';
    private static final String ON_AFTER_INSERT_SUBJECT   = 'On After Insert';
    private static final String ON_BEFORE_UPDATE_SUBJECT  = 'On Before Update';
    private static final String ON_AFTER_UPDATE_SUBJECT   = 'On After Update';
    private static final String ON_BEFORE_DELETE_SUBJECT  = 'On Before Delete';
    private static final String ON_AFTER_DELETE_SUBJECT   = 'On After Delete';
    private static final String ON_AFTER_UNDELETE_SUBJECT = 'On After Undelete';
            
    public class TestStrategy implements SEPTriggerHandlerStrategy
    {
	    public Boolean onBeforeInsert(List<SObject> newSObjectList)                                   { return execute(newSObjectList,         ON_BEFORE_INSERT_SUBJECT);  }
	    public Boolean onAfterInsert(Map<ID, SObject> newSObjectMap)                                  { return execute(newSObjectMap.values(), ON_AFTER_INSERT_SUBJECT);   }
	    public Boolean onBeforeUpdate(Map<ID, SObject> oldSObjectMap, Map<ID, sObject> newSObjectMap) { return execute(newSObjectMap.values(), ON_BEFORE_UPDATE_SUBJECT);  }
	    public Boolean onAfterUpdate(Map<ID, SObject> oldSObjectMap, Map<ID, sObject> newSObjectMap)  { return execute(newSObjectMap.values(), ON_AFTER_UPDATE_SUBJECT);   }
	    public Boolean onBeforeDelete(Map<ID, SObject> oldSObjectMap)                                 { return execute(oldSObjectMap.values(), ON_BEFORE_DELETE_SUBJECT);  }
	    public Boolean onAfterDelete(Map<ID, SObject> oldSObjectMap)                                  { return execute(oldSObjectMap.values(), ON_AFTER_DELETE_SUBJECT);   }    
	    public Boolean onAfterUndelete(Map<ID, SObject> newSObjectMap)                                { return execute(newSObjectMap.values(), ON_AFTER_UNDELETE_SUBJECT); }
	    
	    private Boolean execute (List<SObject> newSObjectList, String newSubject)
	    {
	    	for (SObject currentSObject : newSObjectList)
	    	{
	    		currentSObject.put('subject', newSubject);
	    	}
	    	return true;
	    }
    }

    // -------------------------------------------------------------------------------------------------------------------------------------------

    private static final User         TEST_RUN_USER   = ECICRunUserTestHelper.create(); 
    private static final TestStrategy TARGET_STRATEGY = new TestStrategy();

    private static void strategyTest (String triggerCondition)
    {
        Case dummyCase = TEST_DummyInquiryCaseFactory.create((triggerCondition == ON_BEFORE_INSERT_SUBJECT) ? TEST_DummyInsertModeEnum.NONE : TEST_DummyInsertModeEnum.MOCK);
        
        Boolean result = null;
        System.runAs (TEST_RUN_USER)
        {
            Test.startTest();
            {
            	     if (triggerCondition == ON_BEFORE_INSERT_SUBJECT)  { result = TARGET_STRATEGY.onBeforeInsert  (       new List<Case>    { dummyCase                 }); }
                else if (triggerCondition == ON_AFTER_INSERT_SUBJECT)   { result = TARGET_STRATEGY.onAfterInsert   (       new Map<Id, Case> { dummyCase.id => dummyCase }); }
                else if (triggerCondition == ON_BEFORE_UPDATE_SUBJECT)  { result = TARGET_STRATEGY.onBeforeUpdate  ( null, new Map<Id, Case> { dummyCase.id => dummyCase }); }
                else if (triggerCondition == ON_AFTER_UPDATE_SUBJECT)   { result = TARGET_STRATEGY.onAfterUpdate   ( null, new Map<Id, Case> { dummyCase.id => dummyCase }); }
                else if (triggerCondition == ON_BEFORE_DELETE_SUBJECT)  { result = TARGET_STRATEGY.onBeforeDelete  (       new Map<Id, Case> { dummyCase.id => dummyCase }); }
                else if (triggerCondition == ON_AFTER_DELETE_SUBJECT)   { result = TARGET_STRATEGY.onAfterDelete   (       new Map<Id, Case> { dummyCase.id => dummyCase }); }
                else if (triggerCondition == ON_AFTER_UNDELETE_SUBJECT) { result = TARGET_STRATEGY.onAfterUndelete (       new Map<Id, Case> { dummyCase.id => dummyCase }); }
            }
            Test.stopTest();
        }
        
        System.assert (result);
        System.assertEquals (triggerCondition, dummyCase.subject);
    }

    private static testMethod void onBeforeInsertTest()  { strategyTest (ON_BEFORE_INSERT_SUBJECT);  }
    private static testMethod void onAfterInsertTest()   { strategyTest (ON_AFTER_INSERT_SUBJECT);   }
    private static testMethod void onBeforeUpdateTest()  { strategyTest (ON_BEFORE_UPDATE_SUBJECT);  }
    private static testMethod void onAfterUpdateTest()   { strategyTest (ON_AFTER_UPDATE_SUBJECT);   }
    private static testMethod void onBeforeDeleteTest()  { strategyTest (ON_BEFORE_DELETE_SUBJECT);  }
    private static testMethod void onAfterDeleteTest()   { strategyTest (ON_AFTER_DELETE_SUBJECT);   }
    private static testMethod void onAfterUndeleteTest() { strategyTest (ON_AFTER_UNDELETE_SUBJECT); }
}