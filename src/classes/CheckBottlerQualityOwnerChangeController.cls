public class CheckBottlerQualityOwnerChangeController {
    
  public Static List<Action_Plan_Item__c> actionPlanItemRelatedToCase = new List<Action_Plan_Item__c>();
  public  Static List<Task> activitiesRelatedtoCase = new List<Task>();
  
     public static List<Task> NewTaskList = new List<Task>();
    
    
    public static void changeBottlerQualityOwner(List<Case> newCase,Map<ID,Case> oldCaseMap)
    {
        For(Case c:newCase)
        {
        Case OldCase=oldCaseMap.get(c.ID);

        if(c.Bottler_Quality_Owner__c != OldCase.Bottler_Quality_Owner__c ){
            
           actionPlanItemRelatedToCase = [select Name,Assignee__c From Action_Plan_Item__c Where Action_Plan__c =:c.Action_Plan__c AND Active__c = True And Assignee__c = 'Bottler_Quality_Owner__c' ];
           activitiesrelatedtoCase = [select OwnerId,Subject,WhatId From Task where WhatId =:c.Id] ;

             CheckBottlerQualityOwnerChangeController.checkOwner(actionPlanItemRelatedToCase,activitiesRelatedtoCase,c);
            }
            
        }
    }
    
    public static void checkOwner(List<Action_Plan_Item__c> actionPlanItemList, List<Task> taskList,Case c)
       
    {
      For(Action_Plan_Item__c act :actionPlanItemList)
           {   
              For(Task newtask :taskList)
              {
                  if(act.name.equalsIgnoreCase(newtask.subject))
              
                { 
                    newtask.OwnerId = c.Bottler_Quality_Owner__c;
                    NewTaskList.add(newtask);
                 
            
                }
                   }
            
                          }
   update NewTaskList;      
        
  }
}