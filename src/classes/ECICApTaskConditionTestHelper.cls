@isTest
public class ECICApTaskConditionTestHelper 
{
    public static final String HAS_UNIQUE_NAME = '';
    public static final String UNIQUE_NAME_IS_EMPTY = 'isEmpty';
    public static final String UNIQUE_NAME_IS_NULL = 'isNull';
    
    
    public class ActionPlanTaskConfig
    {
        public String conditionUniqueNameStatus = '';   
        public String testName = '';
        public String fieldName 			    = null;
        public String operator 			        = null;
        public String delimitedValues           = null;
        
        public ActionPlanTaskConfig () {}
        public ActionPlanTaskConfig (String nameStatus) { this.conditionUniqueNameStatus = nameStatus; }
    }
    
    public static AP_Task_Condition__c createDummyApTaskCondition(String itemMode, String uniqueNameCondition, String triggerType)
    {
            // Create Dummy Task and the Dummy Item containing the Task to test.
            
            Action_Plan_Item__c dummyActionPlanItem = ECICActionPlanItemTestHelper.createDummyActionPlanItem(
                                                                    ECICActionPlanTestHelper.createDummyActionPlan(true),
                                                                    (new ECICActionPlanItemTestHelper.ActionPlanItemConfig(itemMode)),                                                                  
                                                                    true
                                                            );
            return ECICApTaskConditionTestHelper.createDummyApTaskCondition(
                                                                    dummyActionPlanItem,
                                                                    (new ECICApTaskConditionTestHelper.ActionPlanTaskConfig(uniqueNameCondition)),
                                                                    (triggerType != 'isInsert')
                                                            ); 
    }
    
    
    public static AP_Task_Condition__c createDummyApTaskCondition(Action_Plan_Item__c actionPlanItem, ActionPlanTaskConfig actionPlanTaskConfig, String testName, Boolean insertNow) 
    {
        Integer uniqueInt           = (Integer) (ECICTestHelperAddon.getUniqueRandom() * 2147483647);
        String apTaskConditionName  = testName.left(20) + testName.right(20) + (': DAPTaskCon: ' + uniqueInt).right(20);
        
        AP_Task_Condition__c apTaskCondition                          = new AP_Task_Condition__c();
                             apTaskCondition.Action_Plan_Item__c      = actionPlanItem.id;
                             
             if (actionPlanTaskConfig.conditionUniqueNameStatus == HAS_UNIQUE_NAME)           {apTaskCondition.Condition_Unique_Name__c =  apTaskConditionName; }
             else if (actionPlanTaskConfig.conditionUniqueNameStatus == UNIQUE_NAME_IS_EMPTY) {apTaskCondition.Condition_Unique_Name__c =  ''; }
             else if (actionPlanTaskConfig.conditionUniqueNameStatus == UNIQUE_NAME_IS_NULL)  {}
                             
	   apTaskCondition.Field_Name__c	= TEST_ConfigHelper.chooseValue(actionPlanTaskConfig.fieldName,				'Can_Process__c'); 	// from picklist
	   apTaskCondition.Operator__c		= TEST_ConfigHelper.chooseValue(actionPlanTaskConfig.operator,				'equals');			// from picklist
	   apTaskCondition.Values__c		= TEST_ConfigHelper.chooseValue(actionPlanTaskConfig.delimitedValues,		apTaskConditionName + (Integer) (ECICTestHelperAddon.getUniqueRandom() * 999999));

        if (insertNow) {insert apTaskCondition;}                            
        return apTaskCondition;
    }

    public static AP_Task_Condition__c createDummyApTaskCondition(Action_Plan_Item__c actionPlanItem, ActionPlanTaskConfig actionPlanTaskConfig, Boolean insertNow) 
    {
        return createDummyApTaskCondition(actionPlanItem, actionPlanTaskConfig, 'Anonymous Test', insertNow);   
    }

    public static AP_Task_Condition__c createDummyApTaskCondition(Action_Plan_Item__c actionPlanItem, Boolean insertNow) 
    {
        return createDummyApTaskCondition(actionPlanItem, new ActionPlanTaskConfig(), 'Anonymous Test', insertNow);
    }

    public static AP_Task_Condition__c createDummyApTaskCondition(Action_Plan_Item__c actionPlanItem, String testName, Boolean insertNow) 
    {
        return createDummyApTaskCondition(actionPlanItem, new ActionPlanTaskConfig(), testName, insertNow);
    }


    public static List<AP_Task_Condition__c> createDummyApTaskConditionList(Action_Plan_Item__c actionPlanItem, Integer quantity, String testName, Boolean insertNow)
    {
   
        List<AP_Task_Condition__c> apTaskConditionList = new List<AP_Task_Condition__c>();

        for (Integer i=1; i<=quantity; i++)
        {
            apTaskConditionList.add(createDummyApTaskCondition(actionPlanItem, testName + i, false )); 
        } 

        if (insertNow) {insert apTaskConditionList;}                            
        
        return apTaskConditionList;
    }

    public static List<AP_Task_Condition__c> createDummyApTaskConditionList(Action_Plan_Item__c actionPlanItem, Integer quantity, Boolean insertNow)
    {
        return createDummyApTaskConditionList(actionPlanItem, quantity, 'Anonymous Test', insertNow);
    }

    public static List<AP_Task_Condition__c> createDummyApTaskConditionList(Integer quantity, Boolean insertNow) 
    {
        return createDummyApTaskConditionList(
                                                ECICActionPlanItemTestHelper.createDummyActionPlanItem(
                                                                    ECICActionPlanTestHelper.createDummyActionPlan(false),
                                                                    false
                                                        ), 
                                                quantity, 
                                                insertNow
                                               );
    }
}