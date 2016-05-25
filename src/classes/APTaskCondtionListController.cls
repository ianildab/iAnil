public with sharing class APTaskCondtionListController {
	public List<AP_Task_Condition__c> relatedTaskConditions { get; set; }
    public APTaskCondtionListController( ApexPages.StandardController stdController ){
    	System.debug('**********'+stdController.getRecord());
    	System.debug('**********'+System.currentPageReference());
    	String aptId = stdController.getId();
    	if(aptId != null){
    	   relatedTaskConditions = [Select Field_Name__c,Field_value__c, Operator__c, Values__c, Condition_Unique_Name__c, name from AP_Task_Condition__c where Action_Plan_Item__c =: aptId];
    	   System.debug('!!!!!!!!!'+relatedTaskConditions);
    	}
        
    }
}