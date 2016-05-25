@isTest
public class TEST_DummyActionPlanItemFactory 
{
    public class Config
    {
        public Id      actionPlanId             = null;
        public String  testName                 = null;
        public String  uniqueName               = null;
        public String  internationalName        = null;
        public String  description              = null;
        public string  internationalDescription = null;
        public String  type                     = null;
        public String  itemMode                 = null;
        public String  priority                 = null;
        public String  assignee                 = null;
        public Integer taskNumber               = null;
        public Integer conditionsCount          = null;
        public Date    activityDate             = null;
        public Boolean isActive                 = null;
        public Boolean sendNotificationEmail    = null;
        
        public Config() {}    
        public Config(Id actionPlanId) { this.actionPlanId = actionPlanId; }
        public Config(String itemMode) { this.itemMode     = itemMode;     }
        
        public Config(Id actionPlanId, String itemMode, String testName) 
        { 
        	this.actionPlanId = actionPlanId;
        	this.itemMode     = itemMode;
        	this.testName     = testName;
        }
    }
    
    public static Action_Plan__c dummyActionPlan = null;
    
    public static Action_Plan_Item__c create (Config config, TEST_DummyInsertModeEnum insertMode)
    { 
    	if (config.actionPlanId == null) { config.actionPlanId = getActionPlanId(insertMode); } 
    	
        Test_UniqueHelper unique = new Test_UniqueHelper(((config.testName != null) ? (config.testName + ': ') : '') + 'Dummy Action Plan Item');
        
        Action_Plan_Item__c dummyActionPlanItem = new Action_Plan_Item__c();
                            dummyActionPlanItem.Action_Plan__c = config.actionPlanId;
                            dummyActionPlanItem.International_Name__c        = TEST_ConfigHelper.chooseValue(config.internationalName,          unique.uniqueString);
                            dummyActionPlanItem.Item_Unique_Name__c          = TEST_ConfigHelper.chooseValue(config.uniqueName,                 unique.uniqueString.left(20) + unique.uniqueString.right(30));
                            dummyActionPlanItem.Description__c               = TEST_ConfigHelper.chooseValue(config.description,                unique.uniqueString + ' Description');
                            dummyActionPlanItem.International_description__c = TEST_ConfigHelper.chooseValue(config.internationalDescription,   unique.uniqueString + ' International Description');
                            dummyActionPlanItem.Type__c                      = TEST_ConfigHelper.chooseValue(config.type,                       'Email');
                            dummyActionPlanItem.Mode__c                      = TEST_ConfigHelper.chooseValue(config.itemMode,                   ECICActionPlanHelper.KEY);
                            dummyActionPlanItem.Priority__c                  = TEST_ConfigHelper.chooseValue(config.priority,                   'High');
                            dummyActionPlanItem.Assignee__c                  = TEST_ConfigHelper.chooseValue(config.assignee,                   'OwnerId');
                            dummyActionPlanItem.Task_Number__c               = TEST_ConfigHelper.chooseValue(config.taskNumber,                 unique.uniqueInt);
                            dummyActionPlanItem.Conditions_Count__c          = TEST_ConfigHelper.chooseValue(config.conditionsCount,            0);
                            dummyActionPlanItem.ActivityDate__c              = TEST_ConfigHelper.chooseValue(config.activityDate,               date.today());
                            dummyActionPlanItem.Send_Notification_Email__c   = TEST_ConfigHelper.chooseValue(config.sendNotificationEmail,      false);
         
        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyActionPlanItem );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyActionPlanItem;    }

        return dummyActionPlanItem;
    }
    
    public static Action_Plan_Item__c create (TEST_DummyInsertModeEnum insertMode) { return create ( new Config(), insertMode );                        }
    public static Action_Plan_Item__c create ()                                    { return create ( new Config(), TEST_DummyInsertModeEnum.NONE     ); }

    public static Action_Plan_Item__c createDummyActionPlanItem(Action_Plan__c actionPlan, TEST_DummyInsertModeEnum insertMode) { return create(new Config(actionPlan.id), insertMode); }
    
    public static Action_Plan_Item__c create(Action_Plan__c actionPlan, Config config, String testName, TEST_DummyInsertModeEnum insertMode) 
    {
               config.actionPlanId = actionPlan.id;
               config.testName     = testName;
        return create (config, insertMode);
    }

    public static Action_Plan_Item__c create(Action_Plan__c actionPlan, Config config, TEST_DummyInsertModeEnum insertMode) { return create(actionPlan, config, 'Anonymous Test', insertMode); }

    // List Methods ---------------------------------------------    

    public static List<Action_Plan_Item__c> createList (List<Config> configList, TEST_DummyInsertModeEnum insertMode)
    {
        List<Action_Plan_Item__c> dummyActionPlanItemList = new List<Action_Plan_Item__c>();

        for (Config config : configList)
        {
            dummyActionPlanItemList.add(create(config, TEST_DummyInsertModeEnum.NONE));
        } 

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyActionPlanItemList );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyActionPlanItemList;    }

        return dummyActionPlanItemList;
    }


    public static List<Action_Plan_Item__c> createList (Integer quantity, Config config, TEST_DummyInsertModeEnum insertMode)
    {
        List<Config> configList = new List<Config>();

        for (Integer i=1; i<=quantity; i++)
        {
            configList.add(config);
        } 

        return createList (configList, insertMode);
    }

    public static List<Action_Plan_Item__c> createList (Integer quantity, TEST_DummyInsertModeEnum insertMode)                            { return createList (quantity, new Config(), insertMode); }
    public static List<Action_Plan_Item__c> createList (Action_Plan__c actionPlan, Integer quantity, TEST_DummyInsertModeEnum insertMode) { return createList (quantity, new Config(actionPlan.id), insertMode); }

    public static List<Action_Plan_Item__c> createList(Id caseActionPlanId, List<String> userLookupFieldsToTestList, TEST_DummyInsertModeEnum insertMode)
    {
        List<Config> configList = new List<Config>();

        for (String userLookupFields : userLookupFieldsToTestList)
        {
        	Config config = new Config(caseActionPlanId);
        	       config.assignee = userLookupFields;
                   configList.add(config);
        } 

        return createList (configList, insertMode);
    }
    
    public static List<Action_Plan_Item__c> createList(TEST_DummyCaseConfig caseConfig, TEST_DummyInsertModeEnum insertMode) { return createList (caseConfig.actionPlanId, caseConfig.userLookupFieldsToTestList, insertMode); }
     
    
    // ---------------------------------------------------------------------------------------------------------------------

    private static Id getActionPlanId(TEST_DummyInsertModeEnum insertMode)
    {
        if (dummyActionPlan != null)                     { return dummyActionPlan.id; }
        if (insertMode != TEST_DummyInsertModeEnum.REAL) { return 'a2211000000A6OH'; }
        
               dummyActionPlan = TEST_DummyActionPlanFactory.create (TEST_DummyInsertModeEnum.REAL);
        return dummyActionPlan.id;
    }
}