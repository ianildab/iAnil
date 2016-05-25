public class ECICCaseTriggerTaskCache 
{
	@testVisible private static Map<Id,Task> caseTaskByTaskIdCache = new Map<Id,Task>();

	@testVisible private static Map<Id,Task> 	  caseUnmodifiedTaskByTaskIdCache = new Map<Id,Task>();
	public  static Map<Id,Task> 	  getCaseUnmodifiedTaskByTaskIdMap()     { return caseUnmodifiedTaskByTaskIdCache; }
	public  static Map<Id,List<Task>> getCaseUnmodifiedTaskListByCaseIdMap() { return buildCaseTaskListByCaseIdMap(caseUnmodifiedTaskByTaskIdCache); }

	public static Map<Id, Decimal> getNumberOfAllIncompleteTasksByCaseIdMap()
	{
		return getNumberOfTasksbyCaseIdMap(buildCaseTaskListByCaseIdMap(caseTaskByTaskIdCache));
	}

	@testVisible private static Map<Id,Task> caseIncompleteManualAndModifiedAutogeneratedTasksByTaskIdCache = new Map<Id,Task>();
	public static Map<Id, Decimal> getNumberOfIncompleteManualAndModifiedAutogeneratedTasksByCaseIdMap()
	{
		return getNumberOfTasksbyCaseIdMap(buildCaseTaskListByCaseIdMap(caseIncompleteManualAndModifiedAutogeneratedTasksByTaskIdCache));
	}

	@testVisible private static Map<Id, Decimal> getNumberOfTasksbyCaseIdMap (Map<Id,List<Task>> caseTaskListByCaseIdMap)
	{
		Map<Id, Decimal> numberOfTasksByCaseIdsMap = new Map<Id, Decimal>();
		for (Id id : caseTaskListByCaseIdMap.keySet())
		{
			numberOfTasksByCaseIdsMap.put (id, (Decimal) caseTaskListByCaseIdMap.size());
		}
		return numberOfTasksByCaseIdsMap;
	}

	//-----------------------------------------------------------------------------------------------------------------------------------
            
	@testVisible private static Set<Task> tasksToInsertCache = new Set<Task>();		// We use Set here to prevent duplicates

	public static void addTasksToInsert			   (List<Task> tasksToInsertList)	   { tasksToInsertCache.addAll(tasksToInsertList); 						    }

    public static void doInsertions () 
    { 
    	if (! tasksToInsertCache.isEmpty())  
    	{ 
    		insert new List<Task>(tasksToInsertCache); 								// But we must convert to List before inserting.
    		tasksToInsertCache = new Set<Task>(); 
    	} 
    }	

	//-----------------------------------------------------------------------------------------------------------------------------------

	@testVisible private static Set<Task> tasksToDeleteCache   = new Set<Task>();	// We use Set here to prevent duplicates

	public static void addTasksToDelete	(List<Task> tasksToDeleteSet)			
	{ 
		tasksToDeleteCache.addAll(tasksToDeleteSet);
		for (Task task : tasksToDeleteSet) { caseUnmodifiedTaskByTaskIdCache.remove(task.id); }
	}

	public static void addTasksToDeleteByCaseIdSet (Set<Id> caseIdsOfTasksToDeleteSet)  { addTasksToDelete(selectTaskList(caseIdsOfTasksToDeleteSet)); }

    public static void doDeletions  () 
    { 
    	if (! tasksToDeleteCache.isEmpty()) 
    	{ 
    		delete new List<Task>(tasksToDeleteCache);									// But we must convert to List before deleting.
    		tasksToDeleteCache = new Set<Task>(); 
    		 
    	} 
    }	

	//-----------------------------------------------------------------------------------------------------------------------------------
	
	public static void populate (List<Case> currentCaseList)
	{
		Set<Id> 	currentCaseIdSet	  = (new Map<Id, Case>(currentCaseList)).keySet();
        String 		query 				  = 'SELECT id, isClosed, isDeleted, isModified__c, '
						                        + String.join(ECICCommonConstants.TASK_FIELDS, ECICCommonConstants.COMMA_DEL)
						                        + ' FROM Task'
						                        + ' WHERE whatId IN :currentCaseIdSet'
                        						+ '     AND isClosed = false';
		Map<Id,Task> caseTaskByTaskIdMap  = new Map<Id,Task>((List<Task>) Database.query(query));
		caseTaskByTaskIdCache.putAll(caseTaskByTaskIdMap);
												
		Map<Id,Task> caseUnmodifiedTaskByTaskIdMap = buildCaseUnmodifiedTaskByTaskIdMap(caseTaskByTaskIdMap);
		caseUnmodifiedTaskByTaskIdCache.putAll(caseUnmodifiedTaskByTaskIdMap);

		Map<Id,Task> caseIncompleteManualAndModifiedAutogeneratedTasksByTaskIdMap = buildCaseIncompleteManualAndModifiedAutogeneratedTasksByTaskIdMap(caseTaskByTaskIdMap);
		caseIncompleteManualAndModifiedAutogeneratedTasksByTaskIdCache.putAll(caseIncompleteManualAndModifiedAutogeneratedTasksByTaskIdMap);
	}

	//-----------------------------------------------------------------------------------------------------------------------------------
	
	@testVisible private static Map<Id,Task> buildCaseUnmodifiedTaskByTaskIdMap (Map<Id,Task> taskByTaskIdMap)
	{
		Map<Id,Task> caseTaskMap = new Map<Id,Task>();
		for (Id id : taskByTaskIdMap.keySet())
		{
			Task task = taskByTaskIdMap.get(id);
			if (
					 	(!task.isClosed                 )
					 && (!task.isDeleted                )
					 && ( task.isModified__c  != 'true' ) 	
					 && ( task.template_id__c != null   )
				)
			{
				caseTaskMap.put(id, task);
			}
		}
		return caseTaskMap; 
	}

	@testVisible private static Map<Id,Task> buildCaseIncompleteManualAndModifiedAutogeneratedTasksByTaskIdMap (Map<Id,Task> taskByTaskIdMap)
	{
		Map<Id,Task> caseTaskMap = new Map<Id,Task>();
		for (Id id : taskByTaskIdMap.keySet())
		{
			Task task = taskByTaskIdMap.get(id);
			if (
					 	(!task.isClosed)								// For some reason, !task.isDeleted is NOT checked by the original function.
					 && ( 					
					 		(  task.template_id__c == null	)			// NOTE: manual task: template ID = null
					 	 || (( task.template_id__c != null) && (task.isModified__c == 'true' ) ) 	 
					 	)
				)
			{
				caseTaskMap.put(id, task);
			}
		}
		return caseTaskMap; 
	}

	@testVisible private static Map<Id, List<Task>> buildCaseTaskListByCaseIdMap(Map<Id,Task> caseTaskByTaskIdMap)
	{
		Map<Id, List<Task>> caseTaskListByCaseIdMap = new Map<Id, List<Task>>();
		for (Task task : caseTaskByTaskIdMap.values())
		{
			if (caseTaskListByCaseIdMap.get(task.whatId) == null) {  caseTaskListByCaseIdMap.put(task.whatId, new List<Task>()); }
			caseTaskListByCaseIdMap.get(task.whatId).add(task);
		}
		return caseTaskListByCaseIdMap;
	}

	//-----------------------------------------------------------------------------------------------------------------------------------
    
    public static List<Task> selectTaskList (Set<Id> caseIdSet)
    {
    	List<Task> selectedTaskList = new List<Task>();
    	Map<Id,List<Task>> caseTaskListByCaseIdMap = getCaseUnmodifiedTaskListByCaseIdMap();
    	for (Id id : caseIdSet)
    	{
    		if (caseTaskListByCaseIdMap.containsKey(id)) { selectedTaskList.addAll(caseTaskListByCaseIdMap.get(id)); 		   } 
    	}
    	return selectedTaskList;
    }

    public static Map<Id, List<Task>> selectTaskListByCaseIdMap (Set<Id> caseIdSet)
    {
    	Map<Id, List<Task>> selectedTaskListByCaseIdMap = new Map<Id, List<Task>>();
    	Map<Id,List<Task>> caseTaskListByCaseIdMap = getCaseUnmodifiedTaskListByCaseIdMap();
    	for (Id id : caseIdSet)
    	{
    		if (caseTaskListByCaseIdMap.containsKey(id))  { selectedTaskListByCaseIdMap.put(id, caseTaskListByCaseIdMap.get(id)); 		    } 
    	}
    	return selectedTaskListByCaseIdMap;
    }
}