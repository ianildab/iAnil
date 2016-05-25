trigger ECICCaseTrigger on Case (before update, before insert, after update, after insert, before delete, after delete, after undelete) 
{    
    if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) { return; }
    
    Boolean isBulkInsert = false;
    System.debug('@@Trigger.isInsert: ' +Trigger.isInsert);
    System.debug('@@isBulkInsert: ' +isBulkInsert);
        
    Common_Settings__c myCS1 = Common_Settings__c.getValues('Bulk Load Username');
    String strBulkLoadUser = (myCS1 == null ? '' : myCS1.Value__c);
    
    If(UserInfo.getUserName() == strBulkLoadUser)
        isBulkInsert = true;
    
    If(!isBulkInsert)
    {
        System.debug('@@Not bulk insert.');
        Boolean isHubCase = false;
        if(Trigger.isInsert || Trigger.isUpdate){
            if(Trigger.new != null){
                List <Case> newCases= Trigger.new;
                isHubCase = HUB_CaseTriggerHelper.hubCaseTriggerListIdentifier(newCases[0]);
                
            }
        }
        if(!isHubCase){
            if(trigger.isBefore){
                    if(trigger.isInsert){ 
                            CICCaseRecordTypeAssignementForSysmos.addCountryCodeAndRecordType(trigger.new);
                            CCEProductionCodeDecoding.populateProductionCodeBeforeInsert(trigger.new);
                            CCECaseTrend.checkTrendInsert(trigger.new);
                            
                    }
                }
                    
            if (ECICCaseHelper.caseTriggerToRun) 
            {
                ECICCaseTriggerHandler handler = new ECICCaseTriggerHandler(Trigger.isExecuting);
                SEPTriggerHandlerInvoker.invoke(handler);                
            }
           
            if(trigger.isBefore){
                    if(trigger.isUpdate) {  
                        
                        CICCaseSubjectUpdate.updateSubjectBeforeUpdate(trigger.old,trigger.new);
                        CCEProductionCodeDecoding.populateProductionCodeBeforeUpdate(trigger.new,trigger.oldMap);
                        ECICCaseTeamMembersAssignment.addMemberBeforeUpdate(trigger.new,trigger.old);
                        CCECaseTrend.checkTrendUpdate(trigger.new,trigger.old);
                        //CheckBottlerQualityOwnerChangeController.changeBottlerQualityOwner(Trigger.New,Trigger.oldMap);                              
                        ECICCommonSMSHelper.callSMSHelper(trigger.new,trigger.old);
                       
                        
                    }else if(trigger.isInsert){
                            CICCaseSubjectUpdate.updateSubjectBeforeInsert(trigger.old,trigger.new) ;
                            
                    }
                }
         
             
            if(trigger.isAfter && trigger.isInsert)
            {                
                ECICCaseTeamMembersAssignment.addMemberAfterInsert(trigger.new,trigger.old);      
                
                ECICCommonSMSHelper.callSMSHelper(trigger.new,trigger.old);       
                
            }
            
            if(trigger.isAfter && trigger.isUpdate){
                 CCECaseHistoryTracker.updateCaseHistoryTracker(trigger.new,trigger.old); 
            }
        }
            
        /* Global HUB Case TTrigger Funtionality */
        else{
            
            if( !trigger.isDelete && !trigger.isUndelete ){
                if(Trigger.isinsert){
                Hub_CaseTriggerHelper.hubCaseSendRelatedMarketNotification(Trigger.new);
                    if(Trigger.isAfter){
                        Hub_CaseTriggerHelper.hubCaseFeedActivityOnInsert(Trigger.new);
                        ECICCaseTeamMembersAssignment.addMemberAfterInsert(trigger.new,trigger.old);
                    }
                }
                if(Trigger.isUpdate){
                    if(Trigger.isBefore){
                       Hub_CaseTriggerHelper.hubCaseTranslationFieldUpdateCheck(Trigger.new, Trigger.oldMap);
                       ECICCaseTeamMembersAssignment.addMemberBeforeUpdate(trigger.new,trigger.old);
                    }
                        Hub_CaseTriggerHelper.hubCaseSendRelatedMarketNotification(Trigger.new);
                    if(Trigger.isAfter){
                        Hub_CaseTriggerHelper.hubCaseFeedActivityOnUpdate(Trigger.new, Trigger.oldMap);
                    }
                }
            }
        }
    }
}