public class ECICCaseTriggerActionPlanItemCache 
{
	@testVisible private static Set<String> actionPlanItemAssigneeTitleCache = new Set<String>();
	public  static Set<String> getActionPlanItemAssigneeTitleSet() { return actionPlanItemAssigneeTitleCache; }

	@testVisible private static Map<Id, Action_Plan_Item__c> caseActionPlanItemByIdCache = new Map<Id, Action_Plan_Item__c>();
	public  static Map<Id, Action_Plan_Item__c> getCaseActionPlanItemByIdMap() { return caseActionPlanItemByIdCache; }

	@testVisible private static Map<Id, String> caseActionPlanItemAssigneeTitleByIdCache = new Map<Id, String>();
	public  static Map<Id, String> 				getCaseActionPlanItemAssigneeTitleByIdMap() { return caseActionPlanItemAssigneeTitleByIdCache; }
	
	
	public static void populate (List<Case> currentCaseList)
	{
		if (actionPlanItemAssigneeTitleCache.isEmpty()) { buildActionPlanItemAssigneeTitleCache(); }

		Set<Id> 	caseIdSet 			= (new Map<Id, Case>(currentCaseList)).keySet();
        List<Task> 	taskList 			= ECICCaseTriggerTaskCache.selectTaskList(caseIdSet);
        
		Set<Id>		taskTemplateIdSet   = new Set<Id>();
        for (Task task : taskList) { taskTemplateIdSet.add(task.Template_ID__c); }
		
		Map<ID, Action_Plan_Item__c> caseActionPlanItemByIdMap = ECICActionPlanItemDao.findByIds(taskTemplateIdSet);
		caseActionPlanItemByIdCache.putAll (caseActionPlanItemByIdMap);
		
		Map<ID, String> caseActionPlanItemAssigneeTitleByIdMap = new Map<ID, String>();
        for (ID actionPlanItemId : caseActionPlanItemByIdMap.keySet()) 
        {
        	caseActionPlanItemAssigneeTitleByIdMap.put(actionPlanItemId, caseActionPlanItemByIdMap.get(actionPlanItemId).Assignee__c);
        }
		caseActionPlanItemAssigneeTitleByIdCache.putAll(caseActionPlanItemAssigneeTitleByIdMap);
	}
	
	@testVisible static void buildActionPlanItemAssigneeTitleCache()
	{
		actionPlanItemAssigneeTitleCache = new Set<String>(ECICActionPlanItemDao.findAllAssignees());
	}
}