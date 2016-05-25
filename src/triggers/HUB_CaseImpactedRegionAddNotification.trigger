/*** Author,email : Aldrin Rasdas , arasdas@coca-cola.com
* Date Create : May 28, 2013
* Description : A trigger that is used to notify users of specified country 
*
* REVISION HISTORY
*
* Author,email :
* Date Revised :
* Description :
*
*
* FOR HUB 1.2
*/
trigger HUB_CaseImpactedRegionAddNotification on HUB_Impacted_Region__c (after insert, after update) {
    
    if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) { return; }
    List<HUB_Impacted_Region__c> regions = trigger.new;
    HUB_Impacted_Region__c oldRegion;
    List<HUB_Impacted_Region__c> filteredRegions = new List<HUB_Impacted_Region__c>();
    
    for (HUB_Impacted_Region__c reg : regions) {
        oldRegion = null;
        try {
            oldRegion = trigger.oldMap.get(reg.id);
        }               
        catch (Exception ex) {/* throw an error as needed*/}
        
        if (oldRegion==null){
            //newly created
            if (reg.Impacted_Region__c != '') {
                filteredRegions.add(reg);
            }           
        } else {
            if (oldRegion.Country__c != reg.Country__c) {
                //it changed. go!
                if (reg.Country__c != '') {
                    filteredRegions.add(reg);
                }
            }
        }
    }
    
    if (filteredRegions.size()>0) {
        String templateId = HUB_Notification.getEmailTemplateId(label.HUB_EmailTemplateImpactedRegionAdded);
        String templateIdCommunity = HUB_Notification.getEmailTemplateId(label.HUB_EmailTemplateImpactedRegionAddedCommunity);
        
        Map<String, String> mapIdAndType = new Map<String, String>();
        Map<String, String> mapIdAndType1 = new Map<String, String>();
        
        List<String> recipientsStandard = new List<String>();
        List<String> recipientsCommunity = new List<String>();
        
        for (HUB_Impacted_Region__c reg : filteredRegions) {
            if (reg.Country__c != '') {
                 mapIdAndType = HUB_Notification.getCountryUserIds2(reg.Country__c, reg.Region__c);
                // mapIdAndType1 = HUB_Notification.getRelatedCountryUserIds(reg.CreatedById);
                 system.debug(mapIdAndType1+'mapIdAndType1+++');
                 for(String id : mapIdAndType.keySet()){
                    if(reg.isCaseCreation__c == false){
                        if(mapIdAndType.get(id) == 'Standard'){
                            recipientsStandard.add(id);
                        }else{
                            recipientsCommunity.add(id);
                        }
                    }
                 }
                 
                HUB_Notification.sendNotificationToList(recipientsStandard, reg.Id, templateId);
                HUB_Notification.sendNotificationToList(recipientsCommunity, reg.Id, templateIdCommunity);
            }
        }
    }
}