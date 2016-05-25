public /* with sharing */ class ECICActionPlanItemDao {
	
	public static Map<ID, Action_Plan_Item__c> findByIds(Set<ID> actionPlanItemIds) {
		return new Map<ID, Action_Plan_Item__c>([SELECT id, Assignee__c FROM Action_Plan_Item__c WHERE id IN :actionPlanItemIds]);
	}

	public static List<String> findAllAssignees() {
		List<String> result = new List<String>();
		
		AggregateResult[] groupedResult = [SELECT Assignee__c FROM Action_Plan_Item__c GROUP BY Assignee__c];
		
		for (AggregateResult ar : groupedResult) {
			String assignee = (String)ar.get('Assignee__c');
			result.add(assignee);
		}
		
		return result;
		
	}
}