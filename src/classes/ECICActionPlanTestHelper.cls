@isTest
public class ECICActionPlanTestHelper 
{
    public static Action_Plan__c createDummyActionPlan(String channel, String reason, String catLevel3, String catLevel4, Boolean insertNow) 
    {
        Integer uniqueInt     = (Integer) (ECICTestHelperAddon.getUniqueRandom() * 999999);
        String actionPlanName = 'Dummy Action Plan' + uniqueInt;
        
        Action_Plan__c actionPlan                       = new Action_Plan__c();
                       actionPlan.Name                  = actionPlanName; 
                       actionPlan.Unique_Name__c        = actionPlanName;
                       actionPlan.International_Name__c = actionPlanName;
                       actionPlan.Rank__c               = (Integer) ECICTestHelperAddon.getUniqueRandom() * 999999;
                       actionPlan.Country_Code__c       = 'UK';
                       actionPlan.Active__c             = true;
     				   actionPlan.Case_Channel__c       = channel;								// From multipicklist
     				   actionPlan.Case_Reason__c        = reason;							  	// From multipicklist
     				   actionPlan.Category_Level3__c    = catLevel3;	 						// From multipicklist
     				   actionPlan.Category_Level4__c    = catLevel4;					  		// From multipicklist
        
        if (insertNow) {insert actionPlan;}                             
        return actionPlan;
    }

    public static Action_Plan__c createEmptyDummyActionPlan(Boolean insertNow) { return createDummyActionPlan('', '', '', '', insertNow); }
    public static Action_Plan__c createDummyActionPlan(Boolean insertNow) { return createDummyActionPlan('Phone', 'Product info', 'Formula - Ingredients', 'Vitamines', insertNow); }

    public static List<Action_Plan__c> createDummyActionPlanList(Integer quantity, Boolean insertNow) 
    {
     
        List<Action_Plan__c> actionPlanList = new List<Action_Plan__c>();

        for (Integer i=1; i<=quantity; i++)
        {
            actionPlanList.add(createDummyActionPlan(false));
        } 

        if (insertNow) {insert actionPlanList;}                             
        return actionPlanList;
    }
}