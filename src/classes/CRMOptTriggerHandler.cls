// CRMOptTriggerHandler handlers Opt insertion and on update

public /* with sharing */ class CRMOptTriggerHandler extends SEPTriggerHandlerAbstract {

    public CRMOptTriggerHandler(boolean isTriggerExecuting) {
        super(isTriggerExecuting);
    }
    
    public override void OnBeforeInsert(List<sObject> newValues) {
        updatedGenerate3DNumber(newValues);
    }
    
    public override void onBeforeUpdate(List<sObject> oldValues, List<sObject> newValues, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap){
         updatedGenerate3DNumber( newValues);
    }
    	
	//If an opt doesn't have a Generated 3 digit number already this method gives them
    private void updatedGenerate3DNumber(List<Opt__c> newValues) {        
        Boolean queryNeeded = false;
        
        for(Opt__c loopOpt : newvalues){
            if(loopOpt.Generated_3Digit_Number__c==null){
                queryNeeded=true;
            }
        }
        
        if(queryNeeded){
            Integer counter = 1;
            List<Opt__c> listOptsWG3DNum = [SELECT ID,Generated_3Digit_Number__c FROM Opt__c WHERE Generated_3Digit_Number__c!=null ORDER BY Generated_3Digit_Number__c DESC];
            if(listOptsWG3DNum!=null && listOptsWG3DNum.size()>0 && listOptsWG3DNum[0].Generated_3Digit_Number__c!=null){
                counter=listOptsWG3DNum[0].Generated_3Digit_Number__c.intValue()+1;
            }
            for(Opt__c loopOpt : newvalues){
                if(loopOpt.Generated_3Digit_Number__c==null){
                    loopOpt.Generated_3Digit_Number__c=counter;
                    counter++;
                }
            }            
        }
        
    }
	
}