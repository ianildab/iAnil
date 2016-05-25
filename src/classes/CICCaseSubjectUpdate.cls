public with sharing class CICCaseSubjectUpdate {
    
    static Map<String,String> caseReasonMap = new Map<String,String>();
    static Map<String,String> catLevel3Map = new Map<String,String>();
    public static void updateSubjectBeforeInsert(List<Case> oldValues, List<Case> newValues){
        
        populateTranslatedMap();
        
        List<RecordType> CSERecordTypes = ECICRecordTypeDao.findRecordTypesByRegion('CSE');
        RecordType NWENQCRecordType = ECICRecordTypeDao.findByDeveloperName('Quality_Complaint_NWEN'); 
        Boolean skipSubjectUpdate = false;
        for(Case newCase:newValues){
            
            for(RecordType rt : CSERecordTypes){
                if(newCase.recordtypeId == rt.id){
                    skipSubjectUpdate = true;
                }
            }
            
            if(skipSubjectUpdate){
                return;
            }
            String translatedCaseReason = caseReasonMap.get(newCase.reason) !=null ? caseReasonMap.get(newCase.reason) : '';
            String traslatedCaseCategory = catLevel3Map.get(newCase.Category_Level3__c) !=null ? catLevel3Map.get(newCase.Category_Level3__c) : '';

            String caseSubjectPrefix = '';
            
            if(newCase.recordTypeId == NWENQCRecordType.id){
                caseSubjectPrefix = (newCase.reason != null ? newCase.reason : '' ) + (newCase.Category_Level3__c != null ? ( ' - ' + newCase.Category_Level3__c ) : '');
            }
            else{
                caseSubjectPrefix = (newCase.reason != null ? translatedCaseReason : '' ) + (newCase.Category_Level3__c != null ? ( ' - ' + traslatedCaseCategory ) : '');
            }
            
             //String caseSubjectPrefix = (newCase.reason != null ? caseReasonMap.get(newCase.reason) : '' ) + (newCase.Category_Level3__c != null ? ( ' - ' + catLevel3Map.get(newCase.Category_Level3__c)) : '');
            if(newCase.Subject ==null){
                if(newCase.reason != null){
                    if(newCase.country_code__c == 'DE'){
                        newCase.Subject = translatedCaseReason;
                    }else{
                        newCase.Subject = caseSubjectPrefix;
                        }
                }
                
            }else{
                if(newCase.reason != null){
                        newCase.Subject = caseSubjectPrefix + ' ' + newCase.Subject;
                    }
                
            }
        }
        
    }
    
    public static void updateSubjectBeforeUpdate(List<Case> oldValues, List<Case> newValues){
    
        List<RecordType> CSERecordTypes = ECICRecordTypeDao.findRecordTypesByRegion('CSE');
        RecordType NWENQCRecordType = ECICRecordTypeDao.findByDeveloperName('Quality_Complaint_NWEN');
        Boolean skipSubjectUpdate = false;
        
        populateTranslatedMap();
     
        Map<String, Case> oldValueMap = new Map<String, Case>();
        Map<String, Case> newValueMap = new Map<String, Case>();
        for(Case oc : oldValues){
            oldValueMap.put(oc.id, oc);
        }
        for(Case oc : newValues){
            newValueMap.put(oc.id, oc);
        }
        
        for(Case newCase:newValues){
        
            for(RecordType rt : CSERecordTypes){
                if(newCase.recordtypeId == rt.id){
                    skipSubjectUpdate = true;
                }
            }
            
            if(skipSubjectUpdate){
                return;
            }
        
            Case oldCase = oldValueMap.get(newCase.id);
            
            String translatedCaseReason = caseReasonMap.get(newCase.reason) !=null ? caseReasonMap.get(newCase.reason) : '';
            String traslatedCaseCategory = catLevel3Map.get(newCase.Category_Level3__c) !=null ? catLevel3Map.get(newCase.Category_Level3__c) : '';
            
            String translatedOldCaseReason = caseReasonMap.get(oldCase.reason) !=null ? caseReasonMap.get(oldCase.reason) : '';
            String traslatedOldCaseCategory = catLevel3Map.get(oldCase.Category_Level3__c) !=null ? catLevel3Map.get(oldCase.Category_Level3__c) : '';
            
            String newSubjectPrefix = '';
            String oldSubjectPrefix = '';
            
            if(newCase.recordTypeId == NWENQCRecordType.id){
                newSubjectPrefix = (newCase.reason != null ? newCase.reason : '' )  + (newCase.Category_Level3__c != null ? ( ' - ' +  newCase.Category_Level3__c ): '');
                oldSubjectPrefix = (oldCase.reason != null ?  oldCase.reason : '' )  + (oldCase.Category_Level3__c != null ? ( ' - ' +  oldCase.Category_Level3__c ): '');
            }
            else{
                newSubjectPrefix = (newCase.reason != null ? translatedCaseReason : '' )  + (newCase.Category_Level3__c != null ? ( ' - ' +  traslatedCaseCategory ): '');
                oldSubjectPrefix = (oldCase.reason != null ?  translatedOldCaseReason : '' )  + (oldCase.Category_Level3__c != null ? ( ' - ' +  traslatedOldCaseCategory ): '');
            }
            
            
            //String newSubjectPrefix = (newCase.reason != null ? caseReasonMap.get(newCase.reason) : '' )  + (newCase.Category_Level3__c != null ? ( ' - ' +  catLevel3Map.get(newCase.Category_Level3__c )): '');
            //String oldSubjectPrefix = (oldCase.reason != null ?  caseReasonMap.get(oldCase.reason) : '' )  + (oldCase.Category_Level3__c != null ? ( ' - ' +  catLevel3Map.get(oldCase.Category_Level3__c )): '');
            if(newCase.Subject ==null){
                if(newCase.reason != null){
                    if(newCase.country_code__c == 'DE'){
                        newCase.Subject = translatedCaseReason;
                    }else{
                    newCase.Subject = newSubjectPrefix;
                    }
                 }
                
            }
            
            else if(isCatagorychange(oldCase, newcase)){
                    if(!String.isBlank(oldSubjectPrefix)){
                        if(newCase.country_code__c == 'DE'){
                            newCase.Subject = newCase.Subject.replace(translatedOldCaseReason, translatedCaseReason);
                        }else{
                         newCase.Subject = newCase.Subject.replace(oldSubjectPrefix, newSubjectPrefix);
                         }
                     }
                     else{
                           if(newCase.country_code__c == 'DE'){
                               newCase.subject = translatedCaseReason + ' ' + newCase.subject;
                           }else{
                             newCase.subject = newSubjectPrefix + ' ' + newCase.subject;
                             }
                         }
             }
             else if( isSubjectChange(oldCase, newcase) && !isCatagorychange(oldCase, newcase)){
                if(!newCase.Subject.contains(newSubjectPrefix)){
                    if(newCase.country_code__c == 'DE'){
                        newCase.subject = translatedCaseReason + ' ' + newCase.subject;
                    }else{
                    newCase.subject = newSubjectPrefix + ' ' + newCase.subject;}
                }
            }   
                
                
            }
        
        
    }
    
    private Static Boolean isCatagorychange(Case oldCase, Case newCase){
        Boolean isChanged =false;
        if(oldCase.reason != newCase.reason){
            return true;
        }
        if(oldCase.Category_Level3__c != newCase.Category_Level3__c ){
            return true;
        }
        else 
        return false;
    }
    
    private Static Boolean isSubjectChange(Case oldCase, Case newCase){
        
        if(oldCase.subject != newCase.subject){
            return true;
        }
        else 
        return false;
    }
    
    private static void populateTranslatedMap(){
        //populating reason translation map
        List<Schema.PicklistEntry> picklistValues = Case.Reason.getDescribe().getPicklistValues(); 
        for (Schema.PicklistEntry pe: picklistValues) {
            caseReasonMap.put(pe.getValue(),pe.getLabel()) ;
        }
        
        //populating category level3 translation map
        List<Schema.PicklistEntry> picklistValuesCL = Case.Category_Level3__c.getDescribe().getPicklistValues(); 
        for (Schema.PicklistEntry pe: picklistValuesCL) {
            catLevel3Map.put(pe.getValue(),pe.getLabel()) ;
        }
        
    }
    
   
}