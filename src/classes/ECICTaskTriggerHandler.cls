public class ECICTaskTriggerHandler extends SEPTriggerHandlerAbstract 
{
	@testVisible private static final Map<String, String> TASK_TYPE_BY_PROFILE_NAME_MAPPING = new Map<String, String>
	{
        ECICCommonConstants.PROFILE_ECIC_INFOLINE_AGENT       =>  'CIC',
        ECICCommonConstants.PROFILE_ECIC_INFOLINE_SUPERVISOR  =>  'CIC',
        ECICCommonConstants.PROFILE_ECIC_COCA_COLA_QUALITY    =>  'Quality',
        ECICCommonConstants.PROFILE_ECIC_BOTTLER_QUALITY      =>  'Quality',
        ECICCommonConstants.PROFILE_ECIC_EXTERNAL_RELATIONS   =>  'Quality',
        //#Ecic Template Test
        ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT       => 'CIC',
    ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_SUPERVISOR  => 'CIC',
   ECICCommonConstants.PROFILE_ECIC_NWEN_INFOLINE_AGENT      =>  'CIC',
  ECICCommonConstants.PROFILE_ECIC_NWEN_INFOLINE_SUPERVISOR  =>  'CIC',
   ECICCommonConstants.PROFILE_ECIC_GERMANY_INFOLINE_AGENT       =>  'CIC',
     ECICCommonConstants.PROFILE_ECIC_GERMANY_INFOLINE_SUPERVISOR  =>  'CIC',
      ECICCommonConstants.PROFILE_ECIC_COMMON_INFOLINE_AGENT      =>  'CIC',
      ECICCommonConstants.PROFILE_ECIC_COMMON_INFOLINE_SUPERVISOR  =>  'CIC',
    
    ECICCommonConstants.PROFILE_ECIC_IBERIA_COCA_COLA_QUALITY   =>  'Quality',
    ECICCommonConstants.PROFILE_ECIC_IBERIA_BOTTLER_QUALITY     =>  'Quality',
    ECICCommonConstants.PROFILE_ECIC_IBERIA_EXTERNAL_RELATIONS   =>  'Relation'
	};
	
    public ECICTaskTriggerHandler(boolean isTriggerExecuting) { super(isTriggerExecuting); }

    // ---------------------------------------------------------------------------------------------------
    
    public override void OnBeforeInsert(List<sObject> newValueSObjectList) 
    {
    	processBefore((Task[])newValueSObjectList, null);
    }

    public override void OnBeforeUpdate(List<sObject> oldValueSObjectList, List<sObject> newValueSObjectList, Map<Id, sObject> oldValueSObjectByIdMap, Map<Id, sObject> newValueSObjectByIdMap) 
    {
    	processBefore((Task[])newValueSObjectList, (Map<ID, Task>)oldValueSObjectByIdMap);
    }
    
    public override void OnAfterInsert(List<sObject> newValueSObjectList, Map<ID, sObject> newValueSObjectByIdMap) 
    {
		Task[] manuallyAddedTaskArray = filterManuallyAddedTasks((Task[])newValueSObjectList); 
    	processAfter(manuallyAddedTaskArray, null);
    }

    public override void OnAfterUpdate(List<sObject> oldValueSObjectList, List<sObject> newValueSObjectList, Map<Id, sObject> oldValueSObjectByIdMap, Map<Id, sObject> newValueSObjectByIdMap) 
    {
    	processAfter((Task[])newValueSObjectList, (Map<Id, Task>)oldValueSObjectByIdMap);
    }

    public override void OnAfterDelete(List<sObject> oldValueSObjectList, Map<ID, sObject> oldValueSObjectByIdMap) 
    {
    	processAfter((Task[])oldValueSObjectList, null);
    }
    
    // ---------------------------------------------------------------------------------------------------
    
	@testVisible private List<Task> filterManuallyAddedTasks(Task[] taskArray) 
	{
		List<Task> resultTaskList = new List<Task>();
		for (Task task : taskArray) 
		{
			if (task.template_id__c == null) { resultTaskList.add(task); }
		}
		return resultTaskList;
	}
	
	@testVisible private void processBefore(Task[] newTaskArray, Map<Id, Task> oldTaskByIdMap) 
	{
		// update the Case related Tasks' type
    	Task[] caseTaskArray = ECICTaskToCaseIdMappingProcessor.filterNonClosedCaseTasks(newTaskArray, oldTaskByIdMap); // check the related Case if it is not 'Closed'
		if  (! caseTaskArray.isEmpty()) { updateCaseTasksType(caseTaskArray); }
    }
    
    /*
	 * Update the task_type__c field in each task by owner profile name.
     */
	@testVisible private void updateCaseTasksType(Task[] caseTaskArray) 
	{
		Set<Id>       caseTasksOwnerIdSet      = buildCaseTaskOwnerIdSet (caseTaskArray);
	    Map<ID, User> caseTaskOwnerUserByIdMap = new Map<Id, User>([SELECT Id, Profile.Name FROM User WHERE id IN :caseTasksOwnerIdSet]);

	    for (Task task : caseTaskArray) 
	    { 
	    	updateCaseTaskType(task, caseTaskOwnerUserByIdMap.get(task.ownerId)); 
	    }     
	}

    @testVisible private Set<Id> buildCaseTaskOwnerIdSet (List<Task> taskList)
    {
        Set<Id> caseTasksOwnerIdSet = new Set<Id>();
        for (Task task : taskList) { caseTasksOwnerIdSet.add(task.ownerId); } // get the tasks' user's profile name
        return caseTasksOwnerIdSet;
    }
                
	@testVisible private void updateCaseTaskType(Task task, User caseTaskOwnerUser)
	{
        if (caseTaskOwnerUser != null) 
        {
	            String caseTaskOwnersProfileName = (caseTaskOwnerUser.Profile.Name != null) 
	                                                   ? caseTaskOwnerUser.Profile.Name
	                                                   : TEST_MockHelper.getMockString(caseTaskOwnerUser.id, 'Profile.Name');

            String taskType                  = TASK_TYPE_BY_PROFILE_NAME_MAPPING.get(caseTaskOwnersProfileName);
                   task.task_type__c         = (taskType != null) ? taskType : '';
        }
	}
	
	@testVisible private void processAfter(Task[] newTaskArray, Map<Id, Task> oldTaskByIdMap) 
	{
		Set<Id> caseIdSet  = ECICCaseIdCollectingProcessor.buildCaseIdSet(newTaskArray, oldTaskByIdMap);
		if (! caseIdSet.isEmpty()) 
		{
			// Try to update the related Cases
			Database.SaveResult[] saveResultArray = updateRelatedCases(ECICCaseDao.findByIds(new List<Id>(caseIdSet)));
	        
        	// Log errors if any
        	SEPErrorHelper.logErrors('Case', 'Failed to update cases in ECICTaskTrigger (ECICCaseTrigger is probably running)', saveResultArray, LoggingLevel.WARN);

            // If it fails it could/should mean that the ECICCaseTrigger is already running and taking care about these fields.
		}
	}

    @testVisible private List<Database.SaveResult> updateRelatedCases(Map<Id, Case> casesToUpdateByIdMap)
    {
 	    updateNextOpenTaskReponsible(casesToUpdateByIdMap);                                            // update field: Case.Next_Open_Task_Reponsible_Lookup__c
    	   
        Boolean caseTriggerToRunSavedValue    = ECICCaseHelper.caseTriggerToRun;                     // Consider only task.template == null related cases
        ECICCaseHelper.caseTriggerToRun       = false;                                                 // Prevent Case triggers executed again
        Database.SaveResult[] saveResultArray = Database.update(casesToUpdateByIdMap.values(), false); // Do not fail if updating a row fails (ECICCaseTrigger is probably running and taking care of these steps)
        ECICCaseHelper.caseTriggerToRun       = caseTriggerToRunSavedValue;
	
        return saveResultArray; 
    }
	
    @testVisible private static void updateNextOpenTaskReponsible(Map<Id, Case> casesToUpdateByIdMap) 
    {
        Set<Id> caseIdSet                     = casesToUpdateByIdMap.keySet();
        Map<Id, Task> nextOpenTaskByCaseIdMap = ECICTaskDao.findNextOpenTaskByCaseIds(caseIdSet);
        for (Id caseId : caseIdSet) 
        { 
        	updateNextOpenTaskReponsible(casesToUpdateByIdMap.get(caseId), nextOpenTaskByCaseIdMap); 
        }
    }
    
    @testVisible private static void updateNextOpenTaskReponsible(Case currentCase, Map<Id, Task> nextOpenTaskByCaseIdMap)
    {
            // Get the owner of the next open task with lowest rank value. Default value is NULL (if there are no more open tasks for the case).
        ID nextOpenTaskResponsible = (nextOpenTaskByCaseIdMap.containsKey(currentCase.id))
                                        ? nextOpenTaskByCaseIdMap.get(currentCase.id).ownerId
                                        : null;
            
            currentCase.Next_Open_Task_Reponsible_Lookup__c = nextOpenTaskResponsible;
        if (ECICCaseQualityComplaintRecordTypeHelper.isQualityComplaint(currentCase.RecordTypeId))
            {
                currentCase.No_Quality_Status_Change__c = true;
            }
        }
    }