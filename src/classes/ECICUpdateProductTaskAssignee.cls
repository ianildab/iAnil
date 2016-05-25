public class ECICUpdateProductTaskAssignee 
{
    public static Task newTask;
    public static String parent;
    public static String shippingAdministrativeArea;
    public static Case parentCase;    
    public static void changeBottlerExternalRelations(List<Task> taskList)
    {
        if(taskList.size() > 0)
        {
            for(Task t:taskList)
            {
                if(t.Subject.equalsIgnoreCase('Enviar producto a los consumidores'))
                {
                    newTask = t;
                    parent = (String)newTask.WhatId;                
                }
            }
        }
        
        if(newTask != null && parent != '')
        {
            if(newTask.Subject.equalsIgnoreCase('Enviar producto a los consumidores') && parent.startsWithIgnoreCase('500'))
            {
            
                parentCase = [Select ID,Account.shipping_administrativearea__c,Region_of_Purchase__r.Name,Region_of_Purchase__r.Bottler_External_Relations__c from Case where ID=:parent limit 1];
                shippingAdministrativeArea = parentCase.Account.shipping_administrativearea__c;
                if(shippingAdministrativeArea != parentCase.Region_of_Purchase__r.Name && shippingAdministrativeArea != Null )
                {
                    List<Region__c> regionList = [Select Name,Bottler_External_Relations__c from Region__c where Name =:shippingAdministrativeArea limit 1];
                    if(regionList.size()>0)
                    {
                        newTask.OwnerId =  regionList.get(0).Bottler_External_Relations__c;
                    }
                    else
                    {
                        newTask.OwnerId = parentCase.Region_of_Purchase__r.Bottler_External_Relations__c;
                    }         
                   
                }
            }
        } 
        
    }
    
    
}