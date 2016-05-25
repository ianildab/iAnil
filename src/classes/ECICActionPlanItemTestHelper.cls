@isTest
public class ECICActionPlanItemTestHelper 
{        
    public class ActionPlanItemConfig
    {
        public String mode = '';
        public ActionPlanItemConfig() {}    
        public ActionPlanItemConfig(String itemMode) { this.mode = itemMode; }
    }
    
    public static Action_Plan_Item__c createDummyActionPlanItem(Action_Plan__c actionPlan, ActionPlanItemConfig actionPlanItemConfig, String testName, Boolean insertNow) 
    {
        Integer uniqueInt          = (Integer) (ECICTestHelperAddon.getUniqueRandom() * 999999);

        String actionPlanItemName  = testName + ': Dummy Action Plan Item: ' + uniqueInt;

        Action_Plan_Item__c actionPlanItem                              = new Action_Plan_Item__c();
                            actionPlanItem.Action_Plan__c               = actionPlan.id;
                            actionPlanItem.Item_Unique_Name__c          = actionPlanItemName.left(20) + actionPlanItemName.right(30);
                            actionPlanItem.International_Name__c        = actionPlanItemName;
                            actionPlanItem.Description__c               = actionPlanItemName + 'Description';
                            actionPlanItem.International_description__c = actionPlanItemName + 'Description';

                            actionPlanItem.Task_Number__c               = (Integer) ECICTestHelperAddon.getUniqueRandom() * 999999;

                            actionPlanItem.Mode__c                      = (
                                                                            (actionPlanItemConfig.mode != '') 
                                                                            ? actionPlanItemConfig.mode 
                                                                            : ECICActionPlanHelper.KEY          // From picklist
                                                                            );                                  
                                                                            
                            actionPlanItem.Type__c                      = 'Email';                              // From picklist
                            actionPlanItem.Active__c                    = true;
                            actionPlanItem.Send_Notification_Email__c   = false;

     						actionPlanItem.Assignee__c                  = 'OwnerId';  							// From picklist
                            actionPlanItem.ActivityDate__c              = date.today();
                            actionPlanItem.Priority__c                  = 'High';                               // From picklist
                            actionPlanItem.Conditions_Count__c          = 0;
                            
        if (insertNow) {insert actionPlanItem;}                             
        return actionPlanItem;
    }

    public static Action_Plan_Item__c createDummyActionPlanItem(Action_Plan__c actionPlan, ActionPlanItemConfig actionPlanItemConfig, Boolean insertNow)
    {
        return createDummyActionPlanItem(actionPlan, actionPlanItemConfig, 'Anonymous Test', insertNow); 
    } 


    public static Action_Plan_Item__c createDummyActionPlanItem(Action_Plan__c actionPlan, Boolean insertNow) 
    {
        return createDummyActionPlanItem(actionPlan, new ActionPlanItemConfig(), insertNow); 
    }

    public static List<Action_Plan_Item__c> createDummyActionPlanItemList(Integer quantity, Boolean insertNow) 
    {
        List<Action_Plan_Item__c> actionPlanItemList = new List<Action_Plan_Item__c>();

        for (Integer i=1; i<=quantity; i++)
        {
            actionPlanItemList.add(createDummyActionPlanItem(ECICActionPlanTestHelper.createDummyActionPlan(false),false)); 
        } 

        if (insertNow) {insert actionPlanItemList;}                             
        return actionPlanItemList;
    }

    public static List<Action_Plan_Item__c> createDummyActionPlanItemList(Action_Plan__c actionPlan, Integer quantity, Boolean insertNow) 
    {
        List<Action_Plan_Item__c> actionPlanItemList = new List<Action_Plan_Item__c>();

        for (Integer i=1; i<=quantity; i++)
        {
            actionPlanItemList.add(createDummyActionPlanItem(actionPlan,false)); 
        } 

        if (insertNow) {insert actionPlanItemList;}                             
        return actionPlanItemList;
    }

    
    public static List<Action_Plan_Item__c> createDummyActionPlanItemList(Action_Plan__c dummyActionPlan, String[] fieldsToTestArray)
    {
			System.debug(LoggingLevel.INFO, '################ dummyActionPlan : ' + dummyActionPlan);
			System.debug(LoggingLevel.INFO, '################ fieldsToTestArray : ' + fieldsToTestArray);

			List<Action_Plan_Item__c> dummyActionPlanList = new List<Action_Plan_Item__c>();
			for (String fieldToTest : fieldsToTestArray)
			{
				System.debug(LoggingLevel.INFO, '################ fieldToTest : ' + fieldToTest);
				
				Action_Plan_Item__c      dummyActionPlanItem  = createDummyActionPlanItem(dummyActionPlan, false);
									     dummyActionPlanItem.put('Assignee__c', fieldToTest);
				dummyActionPlanList.add (dummyActionPlanItem);
									
				System.debug(LoggingLevel.INFO, '################ dummyActionPlanItem : ' + dummyActionPlanItem);
				System.debug(LoggingLevel.INFO, '################ dummyActionPlanList : ' + dummyActionPlanList);
				
			}								  
			insert dummyActionPlanList;
			return dummyActionPlanList;
    } 
    

}