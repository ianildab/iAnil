public class ECICActionPlanCache {
	private static ECICActionPlanCache self;
	
	private ECICActionPlanCache () {
	}
	private final static String DELIMITER = ';';
	public Map<Id, Action_Plan__c> aplans {get; private set;}
	public Map<String, ID> keyMap {get; private set;}
	public Map<Id, List<Action_Plan_Item__c>> apitems {get; private set;}
	public Map<Id, Action_Plan_Item__c> conditions {get; private set;}    
	
	{
		aplans = new Map<Id, Action_Plan__c>([SELECT Rank__c,
			                                      Country_Code__c,
			                                      Case_Channel__c,
			                                      Case_Reason__c,
			                                      Category_Level3__c,
			                                      Category_Level4__c,
			                                      International_Name__c,
			                                      (SELECT Name,
			                                    		  Mode__c,
			                                    		  Priority__c,
			                                    		  ActivityDate__c,
			                                    		  Description__c,
			                                    		  Assignee__c,
			                                    		  Task_Number__c,
			                                    		  ID,
			                                    		  Action_Plan__r.Name,
			                                    		  International_Name__c,
			                                    		  International_description__c,
			                                    		  Send_Notification_Email__c
			                                    	FROM Action_Plan_Items__r
			                                    	WHERE active__c = true
			                                    	ORDER BY Task_Number__c) 
		                                    FROM Action_Plan__c
		                                    WHERE Active__c = true
		                                    ORDER BY Rank__c]);
		keyMap = new Map<String, ID>();
		apitems = new Map<Id, List<Action_Plan_Item__c>>();
		conditions = new Map<Id, Action_Plan_Item__c>([SELECT ID,
		                                               (SELECT Values__c, Field_name__c, Operator__c
		                                            	FROM AP_Task_Conditions__r) 
		                                            FROM Action_Plan_Item__c]);
		
		for (Action_Plan__c ap : aplans.values()) {
			List<String> keys = new List<String>();
			
			if (ECICUtils.isEmpty(ap.Case_Channel__c)) {
				keys = ECICUtils.createCategoryKeys('', ap);
			}
			else {
				for (String channel : ap.Case_Channel__c.split(DELIMITER , -1)) {
					keys.addAll(ECICUtils.createCategoryKeys(channel, ap));
				}
			}
			
			for (String key : keys) {
				if (keyMap.containsKey(key)) {
					Integer rank = (Integer) aplans.get(keyMap.get(key)).Rank__c;
					if (ap.Rank__c < rank) {
						keyMap.put(key, ap.Id);
					}
				}
				else {
					keyMap.put(key, ap.Id);
				}
			}
			
			apitems.put(ap.Id, ap.Action_Plan_Items__r);
		}
	}
	
	public static ECICActionPlanCache getInstance() {
		if (self != null) return self;
		
		// Create the single instance now. 
		self = new ECICActionPlanCache ();
		
		return self;
	}
	
	public Action_Plan__c getActionPlan(List<String> keys) {
		return getActionPlanById(getActionPlanID(keys));
	}
	
	public Action_Plan__c getActionPlanById(Id apid) {
		return aplans.get(apid);
	}
	
	public ID getActionPlanID(List<String> keys) {
		for (String key : keys) {
			if (keymap.containsKey(key)) {
				return keyMap.get(key);
			}
		}
		return null;
	}
	
	public List<Action_Plan_Item__c> getActionPlanItems(Id apid) {
		return apitems.get(apid);
	}
	
	public List<AP_Task_Condition__c> getConditions(Id iid) {
		return conditions.get(iid).AP_Task_Conditions__r;
	}
}