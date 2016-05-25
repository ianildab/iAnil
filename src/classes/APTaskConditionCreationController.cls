/*
This class is use for creation and edit of Action plan item along with AP Task Conditions .
Which we are creating on same page .Name of pages which are using this class are ActionPlanTaskEdit and APTaskConditionCreation 
In this class we are first inserting or updating Action plan Item then we are inserting or updating  AP Task Conditions
*/
public with sharing class APTaskConditionCreationController {
    public list<AP_Task_Condition__c> atcList{get;set;}
    public list<ATCwrapper> wrapperList{get;set;}
    public Integer counter{get;set;}
    public string hidden{get;set;}
    public Action_Plan_Item__c actionPlanItem { get; set; }
    public String actionplan_id;
    private String itemId;
    private String apItemId;
    private String mode = 'create';
    private Action_Plan__c relatedActionPlan;
    private list<AP_Task_Condition__c> conditionsToBeDeleted ;
    public integer count;
    public boolean check;
    public APTaskConditionCreationController( ApexPages.StandardController stdController ){
    //------------ apItemId will return at a time of Edit condition only.
       conditionsToBeDeleted = new List<AP_Task_Condition__c>(); 
       apItemId = stdController.getId();
       system.debug('-------apItemId-----'+apItemId);
    //---------- itemId is reference id ---------------------------
       
       itemId = ApexPages.currentPage().getParameters().get( 'retUrl' );
     system.debug('-------itemId-----'+itemId);
       String apId = itemId.remove('/');
       string actionplanid;
       if(apId!=apItemId){
            if(apItemId!=null){
               actionplanid=[select Action_Plan__c from Action_Plan_Item__c where id=:apItemId].Action_Plan__c;
             }
             else{
             actionplanid=[select id from Action_Plan__c where id=:apId].id;
             }
              relatedActionPlan = [Select name, Country_Code__c from Action_Plan__c where id=: actionplanid limit 1];
        }
         else{
           system.debug('0000000000000'+apId+'--------------'+itemId);  
           string actionid=[select Action_Plan__c from Action_Plan_Item__c where id=:apId].Action_Plan__c;
           relatedActionPlan =[Select name, Country_Code__c from Action_Plan__c where id=: actionid limit 1];
         }
       if(apitemid != null){
            mode='edit';
            this.actionPlanItem = [Select name, Action_Plan__c, Active__c, Assignee__c,Description__c,
            ActivityDate__c, International_description__c, International_Name__c,Item_Unique_Name__c,
            Mode__c, Priority__c, Send_Notification_Email__c, Task_Number__c, Type__c, 
            (Select Condition_Unique_Name__c, Field_Name__c,Field_value__c,Operator__c, Values__c from AP_Task_Conditions__r ) from Action_Plan_Item__c where id=: apItemId];
            
            wrapperList = new list<ATCwrapper>();
            counter = 0;
            for(AP_Task_Condition__c aptc : this.actionPlanItem.AP_Task_Conditions__r){
                
                ATCwrapper actWrap = new ATCwrapper(aptc);
                counter++;
                actWrap.counterWrap = counter;
                actWrap.mode = 'edit';
                wrapperList.add(actWrap);
            }
               
       }
       else{
       mode='create';
       this.actionPlanItem = (Action_Plan_Item__c) stdController.getRecord();
       itemId = ApexPages.currentPage().getParameters().get( 'retUrl' );
       this.actionPlanItem.Action_Plan__c = itemId.remove('/');
     //  this.actionPlanItem.Item_Unique_Name__c=relatedActionPlan.Country_Code__c+'_'+relatedActionPlan.name;
       
       //this.actionPlanItem = new Action_Plan_Item__c();
       System.debug('***'+hidden);
       
       counter = 0;
           atcList = new list<AP_Task_Condition__c>(); 
           wrapperList = new list<ATCwrapper>();
          
               ATCwrapper actWrap = new ATCwrapper(new AP_Task_Condition__c()); 
               counter++;
               actWrap.counterWrap = counter;
               wrapperList.add(actWrap);
       }
       
       
    }
    
    public string  generateUniqueName(){
        string action_item_unique_name = relatedActionPlan.Country_Code__c+'_'+relatedActionPlan.name+'_'+this.actionPlanItem.Task_Number__c;
        return action_item_unique_name;
    }
    
    public list<AP_Task_Condition__c> getTaskCondition(){
        AP_Task_Condition__c apTask = new AP_Task_Condition__c();
        list<AP_Task_Condition__c> apt= new list<AP_Task_Condition__c>();
        apt.add(apTask);
        return apt;
    }
    
    public Pagereference saveTaskItems(){
    Database.SaveResult Api=null;
    if(mode == 'edit'){
       Api = database.update(actionPlanItem);
       system.debug('eeeeeeeee'+conditionsToBeDeleted);
       if(conditionsToBeDeleted != null && !conditionsToBeDeleted.isEmpty()){
            database.delete(conditionsToBeDeleted);
       }
       
       system.debug('----Api----'+Api);
    }
    else{
       AggregateResult[] groupedResults=[select MAX(Task_Number__c) from Action_Plan_Item__c where Action_Plan__c=:relatedActionPlan.id];
       for (AggregateResult ar : groupedResults)  
        count=integer.valueof(ar.get('expr0'));
         system.debug('----count----'+count);
        if(count==null){
        this.actionPlanItem.Task_Number__c= 1;
        }
        else{
        this.actionPlanItem.Task_Number__c=count+1;
              system.debug('----this.actionPlanItem.Task_Number__c----'+this.actionPlanItem.Task_Number__c);
        }
       this.actionPlanItem.Item_Unique_Name__c=relatedActionPlan.Country_Code__c+'_'+relatedActionPlan.name+'_'+this.actionPlanItem.Task_Number__c;
        system.debug('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'+this.actionPlanItem.Item_Unique_Name__c);
       Api= database.insert(actionPlanItem);
       system.debug('----Api----'+Api);
      }
        Pagereference newPage = new PageReference(itemId);
        //---- we are updating or inserting AP Task Conditions---------------------------
         list<AP_Task_Condition__c> updateApc;
    set<string> Apc_field_value;
        updateApc = new list<AP_Task_Condition__c>();
    Apc_field_value = new set<string>();
        if(!wrapperList.isEmpty()&& Api.isSuccess()){
            for(ATCwrapper atpWrap:wrapperList){
               
                if(atpWrap.mode == 'create')
                    atpWrap.ATC.Action_Plan_Item__c=Api.id; // assigning Action Plan item id to AP Task Conditions
                    
                    if(atpWrap.ATC.Field_value__c!=null && atpWrap.ATC.Operator__c!=null && atpWrap.ATC.Values__c!=null){
                    atpWrap.ATC.Condition_Unique_Name__c=generateUniqueName()+atpWrap.ATC.Field_value__c;
                    system.debug('----generateUniqueName()---'+generateUniqueName()+'----atpWrap.ATC.Field_Name__c----'+atpWrap.ATC.Field_Name__c+'---atpWrap.ATC.Condition_Unique_Name__c--'+atpWrap.ATC.Condition_Unique_Name__c);
                    string type= atpWrap.ATC.Field_value__c;
                    AP_Task_Condition_setting__c mcsd=AP_Task_Condition_setting__c.getValues(type);
                    atpWrap.ATC.Field_Name__c=mcsd.field_value__c;
                    Apc_field_value.add(atpWrap.ATC.Field_value__c);
                    updateApc.add(atpWrap.ATC);
                    system.debug('-----updateApc----'+updateApc);
                    check=true;    
                }
                else
                    {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,System.Label.Please_Enter_Value));
                    check=false;
                    }
            
                
        }
        }
        system.debug('-----Apc_field_value----'+Apc_field_value.size()+'-------updateApc-------'+updateApc.size());
        
        if(!updateApc.isEmpty() && (Apc_field_value.size()==updateApc.size()) && (check==true)){
           
            upsert updateApc; // insert or update AP Task Conditions 
            system.debug('-----updateApc11111111111----'+updateApc);
            return newPage;
        }
           if(Apc_field_value.size()!=updateApc.size()){
               system.debug('-----121212121212121212121----');
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,System.Label.Duplicate_Field));  
               
           }
        if(updateApc.isEmpty()){
             return newPage;
        }
            return null;
     /*  ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Record Saved Successfully.');
       ApexPages.addMessage(myMsg); 
     */
        
    }
    
    public void addRow(){
        //accountList.add(new Account());
        ATCwrapper actWrap = new ATCwrapper(new AP_Task_Condition__c()); 
        
        counter++;
        actWrap.counterWrap = counter; 
        wrapperList.add(actWrap); 
     //   return null;    
    }
    public void removingRow(){
    
        Integer param = Integer.valueOf(Apexpages.currentpage().getParameters().get('index'));
        system.debug('---param--'+param);
     //   conditionsToBeDeleted = new List<AP_Task_Condition__c>();
        
        for(Integer i=0;i<wrapperList.size();i++){
            if(wrapperList[i].counterWrap == param ){
               ATCwrapper deleteCondition =  wrapperList.remove(i);
                system.debug('----MMMMM---'+deleteCondition);
                 if(deleteCondition.ATC.id!=null){ 
                    conditionsToBeDeleted.add(deleteCondition.ATC);   
                     system.debug('----MM333333M---'+conditionsToBeDeleted+'00000000000000'+conditionsToBeDeleted.size());
                     
                 }
            }
        }
               
        counter--;
     //   return null;    
    }
    
    public pagereference cancel(){
        Pagereference newPage = new PageReference(itemId);
        return newPage;
    }
    
    public class ATCwrapper{
        public AP_Task_Condition__c ATC{get;set;}
        public Integer counterWrap{get;set;}
        public String mode = 'create';
        public ATCwrapper(AP_Task_Condition__c actc){
            this.ATC = actc;  
             
        }
    }
}