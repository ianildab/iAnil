public class SEPTriggerHandlerInvoker {

	private static final boolean DEFAULT_SKIP_TRIGGERS_VALUE = false;
	@testVisible private static final Map<String, boolean> SKIP_OBJECT_TRIGGER_MAP = new Map<String, boolean>();

	// These should only be used for testing!
	@testVisible private static String  DUMMY_SOBJECT_NAME       = 'DummySObject';
	@testVisible private static Boolean realTrigger				 = true;
	@testVisible private static Boolean pretendTestNotRunning   = false; 
	@testVisible private static Boolean pretendSkipTriggersNull = false; 
	@testVisible private static Boolean pretendSObjectNotNull    = false;
	@testVisible private static Boolean pretendTriggerNewNotNull = false;
	@testVisible private static Boolean pretendTriggerOldNotNull = false;
	@testVisible private static Boolean pretendBefore			 = false;
	@testVisible private static Boolean pretendAfter    		 = false;
	@testVisible private static Boolean pretendInsert  			 = false;
	@testVisible private static Boolean pretendUpdate   		 = false;
	@testVisible private static Boolean pretendDelete   		 = false;
	@testVisible private static Boolean pretendUndelete 		 = false;

    /**
     * Evaluate global trigger execution.
     */
    public static boolean skipTriggerInvocation() 
    {
        boolean result = General_Settings__c.getInstance().skipTriggers__c;
        
        if ((result == null) || (pretendSkipTriggersNull)) { result = DEFAULT_SKIP_TRIGGERS_VALUE; }	// Value is not set, setting a default value
        
        // consider the global 'skipTriggers' flag only in real executions (and do NOT if invoked from unit tests)
        return 	( (! Test.isRunningTest()) || pretendTestNotRunning) && (result || skipObjectTrigger());  
    }
    
    /**
     * Enable/Disable per object trigger execution.
     */
    public static void skipObjectTriggerInvocation(String objectName, boolean skip) { SKIP_OBJECT_TRIGGER_MAP.put(objectName, skip); }

    /**
     * Evaluate per object trigger execution.
     */
    public static boolean skipObjectTrigger() 
    {
    	sObject obj = null;
    	if 	    ((Trigger.new != null && ! Trigger.new.isEmpty()) || (pretendTriggerNewNotNull)) 
    	{ 
    		obj = (!pretendTriggerNewNotNull) ? Trigger.new.get(0) : (new Account()); 
    	} 
    	else if ((Trigger.old != null && ! Trigger.old.isEmpty()) || (pretendTriggerOldNotNull)) 
    	{ 
    		obj = (!pretendTriggerOldNotNull) ? Trigger.old.get(0) : (new Account()); 
    	}
        
        if (obj == null) {  return false;  }	// This should never happen outside of tests.

        String objectName = (!pretendSObjectNotNull) 
        					? obj.getSObjectType().getDescribe().getName()
        					: DUMMY_SOBJECT_NAME;
        if (pretendTriggerNewNotNull || pretendTriggerOldNotNull) { objectName = DUMMY_SOBJECT_NAME; }
        return (SKIP_OBJECT_TRIGGER_MAP.get(objectName) == true);
    }
    
	/**
	 * Invoke the trigger handler according to the trigger type.
	 */
    public static void invoke(SEPTriggerHandler handler) 
    {
    	List<SObject>    newSObjectList  = (realTrigger) ? Trigger.new    : new List<SObject>{(SObject) new Account()};
    	List<SObject>    oldSObjectList  = (realTrigger) ? Trigger.old    : new List<SObject>{(SObject) new Account()};
		Map<Id, SObject> newSObjectIdMap = (realTrigger) ? Trigger.newMap : new Map<Id, SObject>{ '001D000000IRt53' => (SObject) new Account() };
		Map<Id, SObject> oldSObjectIdMap = (realTrigger) ? Trigger.oldMap : new Map<Id, SObject>{ '001D000000IRt53' => (SObject) new Account() };
    	
        if      ((pretendBefore && pretendInsert) || (realTrigger && Trigger.isBefore && Trigger.isInsert)) { handler.OnBeforeInsert (newSObjectList); 												     } 
        else if ((pretendAfter  && pretendInsert) || (realTrigger && Trigger.isAfter  && Trigger.isInsert)) { handler.OnAfterInsert  (newSObjectList, newSObjectIdMap);								     } 
        else if ((pretendBefore && pretendUpdate) || (realTrigger && Trigger.isBefore && Trigger.isUpdate)) { handler.OnBeforeUpdate (oldSObjectList, newSObjectList, oldSObjectIdMap, newSObjectIdMap); } 
        else if ((pretendAfter  && pretendUpdate) || (realTrigger && Trigger.isAfter  && Trigger.isUpdate)) { handler.OnAfterUpdate  (oldSObjectList, newSObjectList, oldSObjectIdMap, newSObjectIdMap); } 
        else if ((pretendBefore && pretendDelete) || (realTrigger && Trigger.isBefore && Trigger.isDelete)) { handler.OnBeforeDelete (oldSObjectList, oldSObjectIdMap); 								 } 
        else if ((pretendAfter  && pretendDelete) || (realTrigger && Trigger.isAfter  && Trigger.isDelete)) { handler.OnAfterDelete  (oldSObjectList, oldSObjectIdMap); 								 } 
        else if ((pretendUndelete 				) || (realTrigger && Trigger.isUndelete				     )) { handler.OnAfterUndelete(newSObjectList, newSObjectIdMap);                                  }
    }
}