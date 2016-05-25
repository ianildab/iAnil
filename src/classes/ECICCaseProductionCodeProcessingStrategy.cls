public class ECICCaseProductionCodeProcessingStrategy extends ECICCaseProcessingStrategyAbstract {
    
    private static final Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);
    
    public override boolean OnBeforeInsert(List<sObject> newValues) {
        execute(null, (List<Case>)newValues);
        
        return true;
    }

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        execute((Map<ID, Case>)oldValuesMap, (List<Case>)newValuesMap.values());
        
        return true;
    }
    
    private void execute(Map<ID, Case> oldCasesMap, Case[] newCasesList) {      
        for (Case newCase : newCasesList) {
            //#RecordType
            String developerName = RECORD_TYPES_BY_ID_MAP.get(newCase.RecordTypeID).DeveloperName;
            //This is implement only for Iberia Quality complaint because bottler is not integrated in salesforce for other regions
            if(developerName.contains(ECICCommonConstants.QUALITY_COMPLAINT_DEVNAME) && developerName.contains(ECICCommonConstants.IBERIA_REGION)){
            //if (newCase.RecordTypeID == ECICCommonConstants.CASE_QUILITY_COMPLAINT_RT_ID) {
                
                Case oldCase = oldCasesMap != null ? oldCasesMap.get(newCase.id) : null;

                if (newCase.Production_Code__c != null 
                    || (newCase.Product__c != null 
                        && newCase.BBE_Date__c != null)) {

                    if (oldCase == null) {
        
                        // a new case is inserted
                        ECICBatchDecodingHelper.processProdCodeDecoding(newCase);
                        
                    } else {
                         
                        boolean prodCodeChanged = (newCase.Production_Code__c != oldCase.Production_Code__c);
                        Boolean prodChanged = (newCase.Product__c != oldCase.Product__c);
                        Boolean bbeChanged = (newCase.BBE_Date__c != oldCase.BBE_Date__c);
                        
                        Boolean prodLineCleared = ( newCase.Production_Line__c == null && newCase.Production_Line__c != oldCase.Production_Line__c);
                        Boolean plantCleared = (newCase.Plant__c == null && newCase.Plant__c != oldCase.Plant__c);
                        Boolean prodDateCleared = (newCase.Production_Date__c == null && newCase.Production_Date__c != oldCase.Production_Date__c);
                        
                        if (prodCodeChanged || prodChanged || bbeChanged || prodLineCleared || plantCleared || prodDateCleared) {
                            ECICBatchDecodingHelper.processProdCodeDecoding(newCase);
                        }
                    }
                }
            
        }
        else if(developerName.contains(ECICCommonConstants.QUALITY_COMPLAINT_DEVNAME) && developerName.contains(ECICCommonConstants.GERMANY_REGION)){}
           //Below logic works for Germany Quality complaint 
            Case oldCase = oldCasesMap != null ? oldCasesMap.get(newCase.id) : null;
                if (newCase.Production_Code__c != null){
                     if (oldCase == null) {
                        // a new case is inserted
                       ECICBatchDecodingHelper.processProdCodeDecoding(newCase);
                     
                     }
                     
                     else{
                     Boolean prodCodeChanged = (newCase.Production_Code__c != oldCase.Production_Code__c);
               
                     Boolean plantCleared = (newCase.Plant__c == null && newCase.Plant__c != oldCase.Plant__c);
                     
                          if ((prodCodeChanged ||  plantCleared) ) {
                                ECICBatchDecodingHelper.processProdCodeDecoding(newCase);
                            }  
                     }
               }
        
    }
}

}