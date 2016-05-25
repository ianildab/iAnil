@isTest
private class ECICCaseTriggerTaskCacheTest 
{
  	private static final User 			TEST_RUN_USER 				= ECICRunUserTestHelper.create();
  	
	// --------------------------------------------------------------------------------------------------------

	private static testMethod void getCaseUnmodifiedTaskByTaskIdMapTest() 		
	{ 
		Task dummyTask = TEST_DummyTaskFactory.create(true);
		ECICCaseTriggerTaskCache.caseUnmodifiedTaskByTaskIdCache.put (dummyTask.id, dummyTask);
		 
		Map<Id,Task> resultCaseUnmodifiedTaskByTaskIdMap = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				resultCaseUnmodifiedTaskByTaskIdMap =  ECICCaseTriggerTaskCache.getCaseUnmodifiedTaskByTaskIdMap();
			}
			Test.stopTest();
	}
	
		System.assert (resultCaseUnmodifiedTaskByTaskIdMap.containsKey(dummyTask.id));
		System.assertEquals (dummyTask, resultCaseUnmodifiedTaskByTaskIdMap.get(dummyTask.id));
	}

	private static testMethod void getCaseUnmodifiedTaskListByCaseIdMapTest() 	
	{
		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		Case dummyCase = ECICCaseTestHelper.createDummyCase(true);
		
		TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
									 taskConfig.caseId = dummyCase.id;
		Task dummyTask = TEST_DummyTaskFactory.create(taskConfig, true);
		ECICCaseTriggerTaskCache.caseUnmodifiedTaskByTaskIdCache.put (dummyTask.id, dummyTask);

		Map<Id,List<Task>> resultCaseUnmodifiedTaskListByCaseIdMap = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				resultCaseUnmodifiedTaskListByCaseIdMap =  ECICCaseTriggerTaskCache.getCaseUnmodifiedTaskListByCaseIdMap();
			}
			Test.stopTest();
		}
		
		System.assert (resultCaseUnmodifiedTaskListByCaseIdMap.containsKey(dummyCase.id));
		System.assertEquals (dummyTask, resultCaseUnmodifiedTaskListByCaseIdMap.get(dummyCase.id)[0]);
	}
		
	//-----------------------------------------------------------------------------------------------------------------------------------

	private static testMethod void getNumberOfTasksbyCaseIdMapTest() 										  
	{
		 Id 	dummyCaseId = '00311000003wzqX';
		 Task	dummyTask	= TEST_DummyTaskFactory.create(false);
		 
		 Map<Id,List<Task>> dummyCaseTaskListByCaseIdMap = new Map<Id,List<Task>>{ dummyCaseId => new List<Task>{dummyTask} };
		 
		 Map<Id, Decimal> resultNumberOfTasksByCaseIdMap = null;
		 System.runAs(TEST_RUN_USER)
		 {
		 	Test.startTest();
		 	{
				 resultNumberOfTasksByCaseIdMap =  ECICCaseTriggerTaskCache.getNumberOfTasksbyCaseIdMap(dummyCaseTaskListByCaseIdMap);
		 	} 
		 	Test.stopTest();
		 } 
		 
		 System.assert(resultNumberOfTasksByCaseIdMap.containsKey(dummyCaseId));
		 System.assertEquals (1, resultNumberOfTasksByCaseIdMap.get(dummyCaseId)); 
	}
	
	private static testMethod void getNumberOfAllIncompleteTasksByCaseIdMapTest() 							  
	{
		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		Case dummyCase = ECICCaseTestHelper.createDummyCase(true);
		
		TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
									 taskConfig.caseId = dummyCase.id;
		Task dummyTask = TEST_DummyTaskFactory.create(taskConfig, true);
		 
		 ECICCaseTriggerTaskCache.caseTaskByTaskIdCache = new Map<Id,Task>{ dummyTask.id => dummyTask };
		 
		 Map<Id, Decimal> resultNumberOfTasksByCaseIdMap = null;
		 System.runAs(TEST_RUN_USER)
		 {
		 	Test.startTest();
		 	{
				 resultNumberOfTasksByCaseIdMap =  ECICCaseTriggerTaskCache.getNumberOfAllIncompleteTasksByCaseIdMap();
		 	} 
		 	Test.stopTest();
		 } 
		 
		 System.assert(resultNumberOfTasksByCaseIdMap.containsKey(dummyCase.Id));
		 System.assertEquals (1, resultNumberOfTasksByCaseIdMap.get(dummyCase.Id)); 
	}

	private static testMethod void getNumberOfIncompleteManualAndModifiedAutogeneratedTasksByCaseIdMapTest() 							  
	{
		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		Case dummyCase = ECICCaseTestHelper.createDummyCase(true);
		
		TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
									 taskConfig.caseId = dummyCase.id;
		Task dummyTask = TEST_DummyTaskFactory.create(taskConfig, true);
		 
		 ECICCaseTriggerTaskCache.caseIncompleteManualAndModifiedAutogeneratedTasksByTaskIdCache = new Map<Id,Task>{ dummyTask.id => dummyTask };
		 
		 Map<Id, Decimal> resultNumberOfTasksByCaseIdMap = null;
		 System.runAs(TEST_RUN_USER)
		 {
		 	Test.startTest();
		 	{
				 resultNumberOfTasksByCaseIdMap =  ECICCaseTriggerTaskCache.getNumberOfIncompleteManualAndModifiedAutogeneratedTasksByCaseIdMap();
		 	} 
		 	Test.stopTest();
		 } 
		 
		 System.assert(resultNumberOfTasksByCaseIdMap.containsKey(dummyCase.Id));
		 System.assertEquals (1, resultNumberOfTasksByCaseIdMap.get(dummyCase.Id)); 
	}
	
	//-----------------------------------------------------------------------------------------------------------------------------------
		
	private static testMethod void addTasksToInsertTest() 						
	{ 
		Task dummyTask = TEST_DummyTaskFactory.create(true);

		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				ECICCaseTriggerTaskCache.addTasksToInsert(new List<Task>{ dummyTask } ); 
			}
			Test.stopTest();
		}
		
		System.assert (ECICCaseTriggerTaskCache.tasksToInsertCache.contains(dummyTask)); 
	}

	private static testMethod void doInsertionsTest() 							
	{ 
		String dummySubject = 'Insertion Test Task';
		
		TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
									 taskConfig.subject = dummySubject;
		Task dummyTask = TEST_DummyTaskFactory.create(taskConfig, false);
		ECICCaseTriggerTaskCache.tasksToInsertCache.add(dummyTask);

		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				ECICCaseTriggerTaskCache.doInsertions(); 
			}
			Test.stopTest();
		}
		
		List<Task> resultTaskList = [SELECT id FROM Task WHERE subject = :dummySubject];
		System.assertEquals (1, resultTaskList.size()); 
	}

	private static testMethod void addTasksToDeleteTest() 						
	{ 
		Task dummyTask = TEST_DummyTaskFactory.create(true);

		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				ECICCaseTriggerTaskCache.addTasksToDelete(new List<Task>{ dummyTask } ); 
			}
			Test.stopTest();
		}
		
		System.assert (ECICCaseTriggerTaskCache.tasksToDeleteCache.contains(dummyTask)); 
	}


	// --------------------------------------------------------------------------------------------------------
	
	private static testMethod void addTasksToDeleteByCaseIdSetTest() 			
	{
		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		Case dummyCase = ECICCaseTestHelper.createDummyCase(true);
		
		TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
									 taskConfig.caseId = dummyCase.id;
		Task dummyTask = TEST_DummyTaskFactory.create(taskConfig, true);
		ECICCaseTriggerTaskCache.caseUnmodifiedTaskByTaskIdCache.put (dummyTask.id, dummyTask);		

		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				ECICCaseTriggerTaskCache.addTasksToDeleteByCaseIdSet(new Set<Id>{ dummyCase.id });
			}
			Test.stopTest();
		}
		
		System.assert (ECICCaseTriggerTaskCache.tasksToDeleteCache.contains(dummyTask)); 
	}

	// --------------------------------------------------------------------------------------------------------
	
	private static testMethod void doDeletionsTest()
	{
		String dummySubject = 'Deletion Test Task';
		
		TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
									 taskConfig.subject = dummySubject;
		Task dummyTask = TEST_DummyTaskFactory.create(taskConfig, true);
		ECICCaseTriggerTaskCache.tasksToDeleteCache.add(dummyTask);

		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				ECICCaseTriggerTaskCache.doDeletions();
			}
			Test.stopTest();
		}

		List<Task> resultTaskList = [SELECT id FROM Task WHERE subject = :dummySubject];
		System.assertEquals (0, resultTaskList.size());
	}
	
	// --------------------------------------------------------------------------------------------------------

	private static testMethod void buildCaseUnmodifiedTaskByTaskIdMapTest()		
	{ 
		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		Case dummyCase = ECICCaseTestHelper.createDummyCase(true);
		
  		Action_Plan__c 		dummyActionPlan		= ECICActionPlanTestHelper.createDummyActionPlan(true);
  		Action_Plan_Item__c dummyActionPlanItem = ECICActionPlanItemTestHelper.createDummyActionPlanItem(dummyActionPlan, true);
		
		TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
									 taskConfig.caseId = dummyCase.id;
									 taskConfig.actionPlanItemId = dummyActionPlanItem.id;
		Task dummyTask = TEST_DummyTaskFactory.create(taskConfig, true);
		Map<Id,Task> dummyTaskByIdMap = new Map<Id,Task>{dummyTask.id => dummyTask};

		Map<Id,Task> resultCaseUnmodifiedTaskByTaskIdMap = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				resultCaseUnmodifiedTaskByTaskIdMap =  ECICCaseTriggerTaskCache.buildCaseUnmodifiedTaskByTaskIdMap (dummyTaskByIdMap);
			}
			Test.stopTest();
		}
		System.assert (resultCaseUnmodifiedTaskByTaskIdMap.containsKey(dummyTask.id));
		System.assertEquals (dummyTask, resultCaseUnmodifiedTaskByTaskIdMap.get(dummyTask.id));
	}

	private static testMethod void buildCaseIncompleteManualAndModifiedAutogeneratedTasksByTaskIdMapTest() 							  
	{
		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		Case dummyCase = ECICCaseTestHelper.createDummyCase(true);
		
		TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
									 taskConfig.caseId = dummyCase.id;
		Task 		 dummyTask 		  = TEST_DummyTaskFactory.create(taskConfig, true);
		Map<Id,Task> dummyTaskByIdMap = new Map<Id,Task>{dummyTask.id => dummyTask};

		 Map<Id,Task> resultTaskByTaskIdMap = null;
		 System.runAs(TEST_RUN_USER)
		 {
		 	Test.startTest();
		 	{
				 resultTaskByTaskIdMap =  ECICCaseTriggerTaskCache.buildCaseIncompleteManualAndModifiedAutogeneratedTasksByTaskIdMap (dummyTaskByIdMap);
		 	} 
		 	Test.stopTest();
		 } 
		 
		 System.assert(resultTaskByTaskIdMap.containsKey(dummyTask.id));
		 System.assertEquals(dummyTask, resultTaskByTaskIdMap.get(dummyTask.id));
	}
	

	private static testMethod void buildCaseTaskListByCaseIdMapTest() 			
	{ 
		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		Case dummyCase = ECICCaseTestHelper.createDummyCase(true);
		
		TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
									 taskConfig.caseId = dummyCase.id;
		Task dummyTask = TEST_DummyTaskFactory.create(taskConfig, true);

		Map<Id,List<Task>> resultCaseUnmodifiedTaskListByCaseIdMap = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				resultCaseUnmodifiedTaskListByCaseIdMap =  ECICCaseTriggerTaskCache.buildCaseTaskListByCaseIdMap (new Map<Id,Task>{dummyTask.id => dummyTask});
			}
			Test.stopTest();
		}
		
		System.assert (resultCaseUnmodifiedTaskListByCaseIdMap.containsKey(dummyCase.id));
		System.assertEquals (dummyTask, resultCaseUnmodifiedTaskListByCaseIdMap.get(dummyCase.id)[0]);
	}

	private static testMethod void selectTaskListTest() 						
	{ 
		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		Case dummyCase = ECICCaseTestHelper.createDummyCase(true);
		
		TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
									 taskConfig.caseId = dummyCase.id;
		Task dummyTask = TEST_DummyTaskFactory.create(taskConfig, true);
		ECICCaseTriggerTaskCache.caseUnmodifiedTaskByTaskIdCache.put (dummyTask.id, dummyTask);

		List<Task> resultTaskList = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				resultTaskList =  ECICCaseTriggerTaskCache.selectTaskList(new Set<Id>{ dummyCase.id });
			}
			Test.stopTest();
		}
		
		System.assertEquals (dummyTask, resultTaskList[0]);
	}

	private static testMethod void selectTaskListByCaseIdMapTest() 				
	{ 
		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		Case dummyCase = ECICCaseTestHelper.createDummyCase(true);
		
		TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
									 taskConfig.caseId = dummyCase.id;
		Task dummyTask = TEST_DummyTaskFactory.create(taskConfig, true);
		ECICCaseTriggerTaskCache.caseUnmodifiedTaskByTaskIdCache.put (dummyTask.id, dummyTask);

		Map<Id, List<Task>> resultTaskListByCaseIdMap = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				resultTaskListByCaseIdMap =  ECICCaseTriggerTaskCache.selectTaskListByCaseIdMap(new Set<Id>{ dummyCase.id });
			}
			Test.stopTest();
		}
		
		System.assert (resultTaskListByCaseIdMap.containsKey(dummyCase.id));
		System.assertEquals (dummyTask, resultTaskListByCaseIdMap.get(dummyCase.id)[0]);
	}

	// --------------------------------------------------------------------------------------------------------

	private static testMethod void populateTest() 								
	{ 
		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		Case dummyCase = ECICCaseTestHelper.createDummyCase(true);
		
  		Action_Plan__c 		dummyActionPlan		= ECICActionPlanTestHelper.createDummyActionPlan(true);
  		Action_Plan_Item__c dummyActionPlanItem = ECICActionPlanItemTestHelper.createDummyActionPlanItem(dummyActionPlan, true);
		
		TEST_DummyTaskFactory.Config taskConfig = new TEST_DummyTaskFactory.Config();
									 taskConfig.caseId = dummyCase.id;
									 taskConfig.actionPlanItemId = dummyActionPlanItem.id;
		Task dummyTask = TEST_DummyTaskFactory.create(taskConfig, true);
		ECICCaseTriggerTaskCache.caseUnmodifiedTaskByTaskIdCache.put (dummyTask.id, dummyTask);

		Map<Id, List<Task>> resultTaskListByCaseIdMap = null;
		System.runAs(TEST_RUN_USER)
		{
			Test.startTest();
			{
				ECICCaseTriggerTaskCache.populate(new List<Case>{ dummyCase });
			}
			Test.stopTest();
		}

		Map<Id, Task> resultCaseUnmodifiedTaskByTaskIdMap = ECICCaseTriggerTaskCache.caseUnmodifiedTaskByTaskIdCache;
		System.assert (resultCaseUnmodifiedTaskByTaskIdMap.containsKey(dummyTask.id));
		System.assertEquals (dummyTask.id, resultCaseUnmodifiedTaskByTaskIdMap.get(dummyTask.id).id);
	}
}