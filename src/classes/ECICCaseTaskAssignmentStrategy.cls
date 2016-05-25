public class ECICCaseTaskAssignmentStrategy extends ECICCaseProcessingStrategyAbstract 
{
    @testVisible private List<Task>  caseTasksToCreateList   = new List<Task>();
    @testVisible private List<Task>  caseTasksToDeleteList   = new List<Task>();

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) 
    {
        updateUserTaskAssignment((Map<ID, Case>)oldValuesMap, (Map<ID, Case>)newValuesMap);
        return true;
    }

    @testVisible private void updateUserTaskAssignment(Map<Id, Case> oldCasesByIdMap, Map<Id, Case> newCasesByIdMap) 
    {
        Set<String> caseFieldsToCheckForChangeSet = buildCaseFieldsToCheckForChangeSet();
        
        Set<ID> casesToReassignIdSet              = buildCasesToReassignIdSet(oldCasesByIdMap, newCasesByIdMap, caseFieldsToCheckForChangeSet);
        if (! casesToReassignIdSet.isEmpty())  { recreateUserTasks(casesToReassignIdSet, newCasesByIdMap); }
    }
    
    @testVisible private Set<String> buildCaseFieldsToCheckForChangeSet()
    {
        Set<String> actionPlanItemAssigneeSet = ECICCaseTriggerActionPlanItemCache.getActionPlanItemAssigneeTitleSet(); 

        Set<String> caseFieldsToCheckForChangeSet = new Set<String>();
        			caseFieldsToCheckForChangeSet.add('OwnerId');
        			caseFieldsToCheckForChangeSet.addAll(actionPlanItemAssigneeSet);
             return caseFieldsToCheckForChangeSet;
    }
        
    @testVisible private Set<Id> buildCasesToReassignIdSet(Map<Id, Case> oldCasesByIdMap, Map<Id, Case> newCasesByIdMap, Set<String> caseFieldsToCheckForChangeSet)
    {
        Set<ID> casesToReassignIdSet = new Set<ID>(); 				// set of case ids of which tasks need to be reassigned
        for (Case newCase : newCasesByIdMap.values())               
        {
            Case oldCase = oldCasesByIdMap.get(newCase.id);
            for (String field: caseFieldsToCheckForChangeSet)       // Check for updated 'ownerId and Task.Assignee__c' fields 
            {
                ID oldMappedUserId = (ID)oldCase.get(field);
                ID newMappedUserId = (ID)newCase.get(field); 
                if (newMappedUserId != oldMappedUserId) { casesToReassignIdSet.add(newCase.id); }
            }
        }
        return casesToReassignIdSet;
    }
    
    @testVisible private void recreateUserTasks(Set<ID> casesToRecreateIdSet, Map<ID, Case> newCasesByIdMap)  
    {
        Map<Id, List<Task>> taskByCaseIdMap = ECICCaseTriggerTaskCache.selectTaskListByCaseIdMap(casesToRecreateIdSet);
        if (! taskByCaseIdMap.isEmpty() ) 
        {
			for (Id caseId : taskByCaseIdMap.keySet())
			{
				recreateUserTasks(newCasesByIdMap.get(caseId), taskByCaseIdMap.get(caseId));
			}
        } 
        else
        {
            System.debug (LoggingLevel.WARN, '!!!!! No tasks found in ECICCaseTriggerTaskCache.caseTaskByTaskIdCache for Cases: ' + casesToRecreateIdSet);
        }    
    }

    @testVisible private void recreateUserTasks(Case currentCase, List<Task>	caseTaskList)
    {
	    for (Task originalTask : caseTaskList) 
        {
        	String assignToUserInCaseField = ECICCaseTriggerActionPlanItemCache.getCaseActionPlanItemAssigneeTitleByIdMap().get(originalTask.template_id__c);
                if (assignToUserInCaseField != null) 
                {
                assignTaskToUserInCaseField(currentCase, originalTask, assignToUserInCaseField);
            }
            else
            {
            	System.debug (LoggingLevel.WARN, '!!!!! No assignees found in ECICCaseTriggerActionPlanItemCache.getCaseActionPlanItemAssigneeTitleByIdMap for Action Plan Item Id: ' + originalTask.template_id__c);
            }    

	        if (! caseTasksToCreateList.isEmpty()) 	  { ECICCaseTriggerTaskCache.addTasksToInsert(caseTasksToCreateList); } 
	        if (! caseTasksToDeleteList.isEmpty()) 	  { ECICCaseTriggerTaskCache.addTasksToDelete(caseTasksToDeleteList); } 
	   }
    }
    
    @testVisible private void assignTaskToUserInCaseField(Case currentCase, Task originalTask, String assignToUserInCaseField)
    {
        if (ECICCaseHelper.isQueueId(currentCase.ownerId)) 
        {  
        	SEPErrorHelper.addError(currentCase, System.Label.ownerCantBeQueueIfActivityExist, false);
        	return; 
        }

                    ID assignToUserId = (ID)currentCase.get(assignToUserInCaseField);
                    if (assignToUserId == null) { assignToUserId = currentCase.ownerId; }

        if (originalTask.ownerId != assignToUserId) // NOTE: Task reassignment (Task.ownerId = assignToUserId) precondition is that Task.isModified__c provides correct value 
                    {
            reassignTask(currentCase, originalTask, assignToUserId);
        }
    }
    
    @testVisible private void reassignTask(Case currentCase, Task originalTask, Id assignToUserId)
    {
        Task taskClone = originalTask.clone(false, true); 
                        taskClone.ownerId = assignToUserId;

                    caseTasksToCreateList.add(taskClone);
        caseTasksToDeleteList.add(originalTask);
                        
					Task nextOpenTask  = ECICTaskComparable.selectFirstOpenTask(caseTasksToCreateList); 
					currentCase.Next_Open_Task_Reponsible_Lookup__c = nextOpenTask.ownerId; 
        
					if (ECICCaseQualityComplaintRecordTypeHelper.isQualityComplaint(currentCase.RecordTypeId)) 
					{ 
						currentCase.No_Quality_Status_Change__c = true; 
					}
                }

}