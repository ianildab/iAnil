/**
 * Helper for regression tests to assert that the new (Strategy-pattern) trigger-handler will deliver the same results
 * as the old (current trunk, as of 2013 September 24) trigger-handler.
 *
 * Methods are composed from old trigger-handler code, with the intention of ensuring consistency 
 * (not necessarily correctness, which is assumed and may be tested elsewhere).
 *
 * To start, this class will help with these old ECICCaseTriggerHandler methods:
 *  § updateUserTaskAssignment, 
 *  § recreateUserTasks, 
 *  § getActionPlanAssigneesByTaskTemplateId, 
 *  § createEmailMessagesForWebCases
 *
 * For each of the above, this class contains:
 * 1. A method derived from the old source.
 * 2. A wrapper for capturing and passing any results (to use the world loosely) of executing the method
 *
 * @author Brian Kessler <brian_kessler@epam.com>
 * @date   2013 September 24
 */
@isTest
public class ECICCaseTriggerHandlerRegressionTestHelp 
{
	// Legacy updateUserTaskAssignment ---------------------------------------------------------------------------------------------------------
	
	public class LegacyUpdateUserTaskAssignmentResultWrapper
	{
		public Set<String>  caseFieldsToCheckForChangeSet 					  {get; private set;}
		public Set<Id> 	 	changedCaseIdSet								  {get; private set;}
		public LegacyRecreateUserTasksResultWrapper recreateUserTasksResults  {get; private set;} 
		
		public LegacyUpdateUserTaskAssignmentResultWrapper(
					Set<String>  caseFieldsToCheckForChangeSet, Set<Id> changedCaseIdSet,
					LegacyRecreateUserTasksResultWrapper recreateUserTasksResults
				)
		{
			this.caseFieldsToCheckForChangeSet = caseFieldsToCheckForChangeSet;
			this.changedCaseIdSet 			   = changedCaseIdSet;
			this.recreateUserTasksResults	   = recreateUserTasksResults;
		}
	}
	
	public static LegacyUpdateUserTaskAssignmentResultWrapper  legacyUpdateUserTaskAssignment (List<Case> newCaseList, Map<ID, Case> oldCaseIdMap, Map<ID, Case> newCaseIdMap) 
    {
		// The original method builds this list using ECICActionPlanItemDao.findAllAssignees(), however in the current context this was not working.
		// It seemed better to manually add these fields than trying to debug the method for this test.
 		Set<String> caseFieldsToCheckForChangeSet = new Set<String>
	 		{
		        'Bottler_External_Relations__c',
		        'Bottler_Quality_Manager__c',
		        'Bottler_Quality_Owner__c',
		        'Consumer_Complaint_Manager__c',
		        'Distributor_External_Relations__c',
		        'Distributor_Quality__c',
		        'Distributor_Quality_Manager__c',
				'OwnerId',
		        'Quality_Admin_Assistant__c',
		        'Quality_Case_Owner__c',
		        'Quality_Manager__c',
		        'Service_Manager__c'
		        
	        // The following  fields have been commented out from ECICTestHelper.REGION_USER_FIELDS and therefore probably shouldn't be tested. 
	        // (confirmed by Gergely Molnar on 2013 September 25.)
		        // 'Infoline_Supervisor__c',
		        // 'Next_Open_Task_Reponsible_Lookup__c',
		        // 'Owner_Lookup__c',
	        };  
        
        Set<Id> changedCaseIdSet = new Set<Id>(); // set of case ids of which tasks need to be reassigned
        for (Case newCase : newCaseList) 
        {
            Case oldCase = oldCaseIdMap.get(newCase.id);

            for (String caseField: caseFieldsToCheckForChangeSet) 
            {
            	Id oldCaseFieldId = (Id)oldCase.get(caseField);
            	Id newCaseFieldId = (Id)newCase.get(caseField);
                if (oldCaseFieldId != newCaseFieldId) { changedCaseIdSet.add(newCase.id); }
            }
        }
        
        LegacyRecreateUserTasksResultWrapper recreateUserTasksResults = null;
        if (! changedCaseIdSet.isEmpty())  
        { 
        	recreateUserTasksResults = legacyRecreateUserTasks(changedCaseIdSet, newCaseIdMap); 
			System.debug (LoggingLevel.INFO, '####### recreateUserTasksResults : ' + recreateUserTasksResults );

        }
        
        return (new legacyUpdateUserTaskAssignmentResultWrapper(caseFieldsToCheckForChangeSet, changedCaseIdSet, recreateUserTasksResults));
    }

	// Legacy recreateUserTasks ---------------------------------------------------------------------------------------------------------

	public class LegacyRecreateUserTasksResultWrapper
	{
        public Task[]     taskArray 					{get; private set;}
        public List<Task> tasksToDeleteList 			{get; private set;}
        public List<Task> tasksToCreateList 			{get; private set;}
        Map<ID, Case> 	  casesToUpdateIdMap			{get; private set;}
        Map<ID, String>   actionPlanItemAssigneesIdMap	{get; private set;}
        LegacyGetActionPlanAssigneesByTaskTemplateIdResultWrapper getActionPlanAssigneesByTaskTemplateIdResults {get; private set;}
		
		public LegacyRecreateUserTasksResultWrapper(
							Task[] taskArray, List<Task> tasksToDeleteList, List<Task> tasksToCreateList,
							Map<ID, Case> casesToUpdateIdMap, Map<ID, String> actionPlanItemAssigneesIdMap,
							LegacyGetActionPlanAssigneesByTaskTemplateIdResultWrapper getActionPlanAssigneesByTaskTemplateIdResults
				)
		{
			this.taskArray 									   = taskArray;
			this.tasksToDeleteList  						   = tasksToDeleteList;
			this.tasksToCreateList  						   = tasksToCreateList;
			this.casesToUpdateIdMap							   = casesToUpdateIdMap;
			this.actionPlanItemAssigneesIdMap 				   = actionPlanItemAssigneesIdMap;
			this.getActionPlanAssigneesByTaskTemplateIdResults = getActionPlanAssigneesByTaskTemplateIdResults;
		}
	}

    public static LegacyRecreateUserTasksResultWrapper legacyRecreateUserTasks (Set<ID> changedCaseIdSet, Map<ID, Case> newCaseIdMap) 
    {
		// The original method builds this list using ECICTaskDao.findNotModifiedAutogeneratedTasksOfCases(), however in the current context this was not working.
		// It seemed better to manually add these fields than trying to debug the method for this test.
        Task[] taskArray = ECICTaskDao.findNotModifiedAutogeneratedTasksOfCases(changedCaseIdSet);

        List<Task>      tasksToDeleteList            = null;
        List<Task>      tasksToCreateList            = null;
        Map<ID, Case>   casesToUpdateIdMap           = null;
        Map<ID, String> actionPlanItemAssigneesIdMap = null;
        LegacyGetActionPlanAssigneesByTaskTemplateIdResultWrapper getActionPlanAssigneesByTaskTemplateIdResults = null;

        if (! taskArray.isEmpty() ) 
        {
            tasksToDeleteList            = new List<Task>();
            tasksToCreateList            = new List<Task>();
            casesToUpdateIdMap           = new Map<ID, Case>();

            getActionPlanAssigneesByTaskTemplateIdResults = legacyGetActionPlanAssigneesByTaskTemplateId(taskArray);
			   actionPlanItemAssigneesIdMap 			  = getActionPlanAssigneesByTaskTemplateIdResults.actionPlanAssigneesByTaskTemplateIdMap;

            for (Task task : taskArray) 
            {
                Case   currentCase             = newCaseIdMap.get(task.whatId);
                String assignToUserInCaseField = actionPlanItemAssigneesIdMap.get(task.Template_ID__c);

                if (assignToUserInCaseField != null) 
                {
                    ID assignToUserId = (ID)currentCase.get(assignToUserInCaseField);
                    if (ECICCaseHelper.isQueueId(currentCase.ownerId)) 
                    {
                        currentCase.addError(System.Label.ownerCantBeQueueIfActivityExist);
                        return (new LegacyRecreateUserTasksResultWrapper(taskArray, tasksToDeleteList, tasksToCreateList, casesToUpdateIdMap, actionPlanItemAssigneesIdMap, getActionPlanAssigneesByTaskTemplateIdResults));
                    }
                    
                    if (assignToUserId == null) { assignToUserId = currentCase.ownerId; }

                    if (task.ownerId != assignToUserId)	 // NOTE: Task reassignment (Task.ownerId = assignToUserId) precondition is that Task.isModified__c provides correct value 
                    {
                        Task taskClone 		   = task.clone(false, true); 
                        	 taskClone.ownerId = assignToUserId;

                        tasksToDeleteList.add(task);
                        tasksToCreateList.add(taskClone);
                        casesToUpdateIdMap.put(currentCase.id, currentCase);
                    }
                }
            }

            if (! tasksToCreateList.isEmpty()) 	{ insert tasksToCreateList; }
            if (! tasksToDeleteList.isEmpty())  { delete tasksToDeleteList; }
            if (! casesToUpdateIdMap.isEmpty()) { ECICTaskTriggerHandler.updateNextOpenTaskReponsible(casesToUpdateIdMap); }
        }

        return (new LegacyRecreateUserTasksResultWrapper(taskArray, tasksToDeleteList, tasksToCreateList, casesToUpdateIdMap, actionPlanItemAssigneesIdMap, getActionPlanAssigneesByTaskTemplateIdResults));
    }

	// Legacy getActionPlanAssigneesByTaskTemplateId ---------------------------------------------------------------------------------------------------------

	public class LegacyGetActionPlanAssigneesByTaskTemplateIdResultWrapper
	{
		public Map<ID, String> 				actionPlanAssigneesByTaskTemplateIdMap 	{get; private set;}  // This is the original method result.
		public Set<ID> 						taskTemplateIdSet 						{get; private set;}
        public Map<ID, Action_Plan_Item__c> actionPlanItemAssigneesByIdMap 			{get; private set;}
		
		public LegacyGetActionPlanAssigneesByTaskTemplateIdResultWrapper(
						Map<ID, String> actionPlanAssigneesByTaskTemplateIdMap,
						Set<ID> taskTemplateIdSet, Map<ID, Action_Plan_Item__c> actionPlanItemAssigneesByIdMap
				)
		{
			this.actionPlanAssigneesByTaskTemplateIdMap = actionPlanAssigneesByTaskTemplateIdMap;
			this.taskTemplateIdSet 						= taskTemplateIdSet;
			this.actionPlanItemAssigneesByIdMap 		= actionPlanItemAssigneesByIdMap;
		}
	}
	
	public static LegacyGetActionPlanAssigneesByTaskTemplateIdResultWrapper legacyGetActionPlanAssigneesByTaskTemplateId(Task[] taskArray) 
	{
        Map<ID, String> actionPlanAssigneesByTaskTemplateIdMap = new Map<ID, String>();
        Set<ID> 		taskTemplateIdSet 	           		   = new Set<ID>();
        
        for (Task task : taskArray) { taskTemplateIdSet.add(task.Template_ID__c); }
         
        Map<ID, Action_Plan_Item__c> actionPlanItemAssigneesByIdMap = null;
        if (! taskTemplateIdSet.isEmpty()) 
        {
            actionPlanItemAssigneesByIdMap = ECICActionPlanItemDao.findByIds(taskTemplateIdSet);
            
            for (ID actionPlanItemId : actionPlanItemAssigneesByIdMap.keySet()) 
            {
                actionPlanAssigneesByTaskTemplateIdMap.put(actionPlanItemId, (actionPlanItemAssigneesByIdMap.get(actionPlanItemId).Assignee__c));
            }
        }
            
        return (new LegacyGetActionPlanAssigneesByTaskTemplateIdResultWrapper(actionPlanAssigneesByTaskTemplateIdMap, taskTemplateIdSet, actionPlanItemAssigneesByIdMap));
	}
	
	// Legacy createEmailMessagesForWebCases ---------------------------------------------------------------------------------------------------------

	public class LegacyCreateEmailMessagesForWebCasesResultWrapper
	{
        List<EmailMessage> newEmailMessageList 		{get; private set;}
   	    List<EmailMessage> existingEmailMessageList {get; private set;}
        Set<ID> 		   webCaseIdSet 	   		{get; private set;}
        Set<ID> 		   contactIdSet 	   		{get; private set;}
        Map<ID, Contact>   contactIdMap				{get; private set;} 
        
		public LegacyCreateEmailMessagesForWebCasesResultWrapper(
				List<EmailMessage> newEmailMessageList, List<EmailMessage> existingEmailMessageList, 
				Set<ID> webCaseIdSet, Set<ID> contactIdSet, Map<ID, Contact>   contactIdMap
			)
		{
			this.newEmailMessageList 	  = newEmailMessageList;
			this.existingEmailMessageList = existingEmailMessageList;
			this.webCaseIdSet			  = webCaseIdSet;
			this.contactIdSet        	  = contactIdSet;
			this.contactIdMap			  = contactIdMap;
		}
	}
	
	public static LegacyCreateEmailMessagesForWebCasesResultWrapper legacyCreateEmailMessagesForWebCases(Map<ID, Case> newCasesIdMap) 
	{ 
       List<EmailMessage> newEmailMessageList = new List<EmailMessage>();
       Set<ID> 			  webCaseIdSet 		  = new Set<ID>();
       Set<ID> 			  contactIdSet 		  = new Set<ID>();
       
       for (Case currentCase : newCasesIdMap.values())						 
       {
	         if (currentCase.Origin == 'Web' && currentCase.ContactId != null) // filter Web originated Cases
	         {
	           	webCaseIdSet.add(currentCase.id);
	           	contactIdSet.add(currentCase.ContactId);
	         }
       }
      
   	   List<EmailMessage> existingEmailMessageList = null;
       Map<ID, Contact> contactIdMap			   = null; 
       
       if (! webCaseIdSet.isEmpty()) 
       {
         	existingEmailMessageList = ECICEmailMessageDao.findByParentIds(webCaseIdSet);
         	contactIdMap 		     = ECICContactDao.findByIds(contactIdSet); 
         
		    for (ID webCaseId : webCaseIdSet) 
		    {
		        Case currentCase = newCasesIdMap.get(webCaseId);
		        
		        // Try to avoid creating duplicates...
		        // This step is NOT obsolote as the custom ECIC email2case can create Cases with Origin = 'Web' where a real incoming email is attached to the new Case.
		        if (! hasEmailByCaseIdAndSubject(currentCase.id, currentCase.Subject, existingEmailMessageList)) 
		        {
		          	if (currentCase.contactId != null && contactIdMap.containsKey(currentCase.contactId)) 
		          	{
		            	Contact contact    = contactIdMap.get(currentCase.contactId);
		            	
		            	String textBody = currentCase.Description;
		               	EmailMessage newEmail = new EmailMessage();
		                        	 newEmail.Incoming      = true;
						             newEmail.parentId		= currentCase.id;
						             newEmail.FromAddress	= contact.Email;
						             newEmail.Subject		= currentCase.Subject;
						             newEmail.TextBody		= textBody;
		            				 newEmail.MessageDate	= System.now();
		            				 newEmail.Status         = '0'; 							// set status = 'New'
		            
		            	newEmailMessageList.add(newEmail);
		          	} 
		          // else no email attachement created for Case ['+currentCase.id+'] as Contact is empty.'
        		}
      		}
  
         if (! newEmailMessageList.isEmpty()) { insert newEmailMessageList; }
       }
		
	   return (new LegacyCreateEmailMessagesForWebCasesResultWrapper(newEmailMessageList, existingEmailMessageList, webCaseIdSet, contactIdSet, contactIdMap)); 
	}
	
	private static boolean hasEmailByCaseIdAndSubject(ID caseId, String subject, EmailMessage[] emailMessageArray) 
	{
       for (EmailMessage email : emailMessageArray) 
       {
         if (email.parentId == caseId && email.subject == subject) { return true; }
       }
       
       return false;
     }
	
}