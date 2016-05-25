public class HUB_CaseTriggerHelper{
    private static Boolean realTrigger = true;
    private static Case oldCase;
    private static Boolean sendContentRequested;
    private static Boolean sendSLAViolation;
    private static Boolean sendNewCaseCreated;
    private static Boolean sendHighRed;
    private static String templateId; 
    private static String templateIdForCommunity; //6.3.2015 by Ranjan
    private static List<String> recipients = new List<String>();
    private static List<String> hlfUserrecipients=new List<String>();//HUB 2.7  
    private static List<String> relatedBrandUserRecipients=new List<String>();//HUB 2.7  
    
    public static Boolean hubCaseTriggerListIdentifier(Case newCase){
        List<RecordType> hubRecordType = ECICCaseTriggerRegionCache.getRecordType(ECICCommonConstants.RECORDTYPE_BY_DEVELOPERNAME_EQUAL,'HUB_Issue_Tracker').Values();
        // [SELECT id FROM RecordType WHERE developerName = 'HUB_Issue_Tracker'];
        Id caseHUBRecordTypeId = hubRecordType != null ? hubRecordType[0].id : null;
        if(caseHUBRecordTypeId != null && newCase.recordTypeId == caseHUBRecordTypeId){
            return true;
        }
        else{ return false;}
    }
    
    public static void hubCaseTranslationFieldUpdateCheck(List<Case> hubCaseList, Map<Id,Case> oldMap){
         for(Case c:hubCaseList){
            if(c.Description != oldMap.get(c.Id).Description){
                c.isDescriptionChange__c =true;
            }
            if(c.Subject != oldMap.get(c.Id).Subject){
                c.isSubjectChange__c=true;
            }
         }
    
    }
    public static void hubCaseFeedActivityOnInsert(List<Case> hubCaseList){
        HUB_ConsolidatedLogHelper helper=new HUB_ConsolidatedLogHelper();
        helper.afterInsertCase(hubCaseList);
    }
    
    public static void hubCaseFeedActivityOnUpdate(List<Case> hubCaseList, Map<Id,Case> oldMap){
        if(!HUB_Validator_cls.hasAlreadyDone()){
            HUB_ConsolidatedLogHelper helper=new HUB_ConsolidatedLogHelper();
            for(Case c: hubCaseList){
                if(c.Description_Auto_Translate_EN__c == oldMap.get(c.Id).Description_Auto_Translate_EN__c && c.Subject_Auto_Translate_EN__c == oldMap.get(c.Id).Subject_Auto_Translate_EN__c){
                    helper.afterUpdateCase(hubCaseList, oldMap);
                }
            }
        }
    }
    
    public static void hubCaseSendRelatedMarketNotification(List<Case> hubCaseList){
    
        if (trigger.isBefore) {
            if (HUB_TriggerKey.getFired('TriggerBefore')) {
                return;
            }
    
            HUB_TriggerKey.setFired('TriggerBefore');       
        }       
    
        if (trigger.isAfter) {
            if (HUB_TriggerKey.getFired('TriggerAfter')) {
                return;
            }
    
            HUB_TriggerKey.setFired('TriggerAfter');        
        }   
        List<RecordType> rtypes = ECICCaseTriggerRegionCache.getRecordType(ECICCommonConstants.RECORDTYPE_BY_SOBJECT_TYPE, 'Case').Values();
        //[Select Name, Id,DeveloperName From RecordType where sObjectType='Case' and isActive=true];  
        Map<String,String> caseRecordTypes = new Map<String,String>{};
        for(RecordType rt: rtypes)
           caseRecordTypes.put(rt.DeveloperName,rt.Id);
        List<Case> cases = hubCaseList;
        //Case oldCase;
        //String templateId; 
        //String templateIdForCommunity; //6.3.2015 by Ranjan
        //List<String> recipients = new List<String>();
        //List<String> hlfUserrecipients=new List<String>();//HUB 2.7  
        //List<String> relatedBrandUserRecipients=new List<String>();//HUB 2.7   
        //Boolean sendContentRequested;
        //Boolean sendSLAViolation;
        //Boolean sendNewCaseCreated;
        //Boolean sendCaseUpdated; 
        // Boolean sendImcrAlert; //IMCR alert?
        //Boolean sendHighRed;
    
        for (Case cs : cases) {
            
       System.debug ( '-----'+cs.RecordTypeId);
            if (cs.RecordTypeId==caseRecordTypes.get('HUB_Issue_Tracker')){
                
                oldCase = null;
            
                sendContentRequested = false;
                sendSLAViolation = false;
                sendNewCaseCreated = false;
                sendHighRed = false;
               // sendCaseUpdated=false;    
                //sendImcrAlert=false;  //IMCR alert?
                try {
                    oldCase = (Case)trigger.oldMap.get(cs.id);
                } catch (Exception ex) {}
            
                if (trigger.isBefore) {
                    beforeProcess(cs, oldCase);
                } else if (trigger.isAfter) {
                    afterProcess(cs, oldCase);
                }
            }
        }
    }
    
    /** Case.HUB_Content_Status__c related code commented out after its deprecation*/
    
    public static void beforeProcess(Case c, Case old) {
        boolean setDate = false;
        boolean retainDate = false;
        if ((c.Status == 'Respond')   /* && (c.HUB_Content_Status__c == 'Existing')*/    ) {
            if (oldCase!=null) {
                if (( oldCase.Status != 'Respond')   /* || (oldCase.HUB_Content_Status__c != 'Existing')    */) { //it changed!
                    setDate = true;
                }
                
                if ((c.Status == 'Respond')     /* && (c.HUB_Content_Status__c == 'Existing')     */) {
                    retainDate = true;
                }               
            } else {
                setDate = true;
            }
        }
        
        if (setDate) {
            c.HUB_SRCEStartDate__c = system.now();      
        } else {
            if (!retainDate) {
                c.HUB_SRCEStartDate__c = null;
            }
        }       
    }
    
    public static void afterProcess(Case c, Case old){
        if (!(oldCase == null)) {
            //content status set to 'Requested'
            /**
            if ((c.HUB_Content_Status__c != old.HUB_Content_Status__c) && (c.HUB_Content_Status__c=='Requested')) {                
                sendContentRequested = true;
            }
            */
            
            //SLAViolation set to 'Yes'
            if (c.HUB_SLAViolation__c != old.HUB_SLAViolation__c) {
                if (c.HUB_SLAViolation__c == 'Yes') {
                    sendSLAViolation = true;
                }
            }
            
            //Priority=High / Risk=Red
            String oldVal = old.Priority + old.HUB_Risk__c;
            String newVal = c.Priority + c.HUB_Risk__c;
            
            if (oldVal != newVal) {
                if ((c.HUB_Risk__c == 'Red') && (c.Priority == 'High')) {
                    sendHighRed = true;                 
                }                   
            }
            //sendCaseUpdated=true; //imcr alert?
                           
        }//oldcase is not null - ends
        else {
            //new case
            
            sendNewCaseCreated = true;
            
                            
            if ((c.HUB_Risk__c == 'Red') && (c.Priority == 'High')) {
                sendHighRed = true;                 
            }
            
            /**
            if (c.HUB_Content_Status__c == 'Requested') {
                sendContentRequested = true;
            }
            */
            
            //who knows?
            if (c.HUB_SLAViolation__c == 'Yes') {
                sendSLAViolation = true;
            }
            //IMCR Alert?
            if(c.HUB_Is_IMCR__c=='Possible'){
              // sendImcrAlert=true;
            }
                                                
        }
        
        
        /** Case.HUB_Content_Status__c related code commented out after its deprecation*/
        /*
        if (sendContentRequested) {
            recipients.clear();
            List<String> recipientsStandard = new List<String>();
            List<String> recipientsCommunity = new List<String>();
            Map<String, String> mapIdAndType = new Map<String, String>();
            templateId = HUB_Notification.getEmailTemplateId(label.HUB_EmailTemplateNameContentStatusSetToRequested);
            mapIdAndType= HUB_Notification.getRelatedCountryCaseManagerIds(c.OwnerId);
            for(String id : mapIdAndType.keySet()){
                   if(mapIdAndType.get(id) == 'Standard'){
                     recipientsStandard.add(id);
                   }else{
                     recipientsCommunity.add(id);
                   }
             }
            
            recipients.add(c.OwnerId); //added - UAT reports that case owner did not receive notification
            recipients.addAll(recipientsStandard);
            recipients.addAll(recipientsCommunity);
            recipients = HUB_Notification.UniqueStringList(recipients);
            System.debug('******'+recipients);
            HUB_Notification.sendNotificationToList(recipients, c.id, templateId);  
                  
        }
        */
        
        /* -- commented out the email alert for SLA violation : 03-19-2015
        if (sendSLAViolation) {
            recipients.clear();
            Map<String, String> mapIdAndType = new Map<String, String>();
            List<String> recipientsStandard = new List<String>();
            List<String> recipientsCommunity = new List<String>();
            templateId = HUB_Notification.getEmailTemplateId(label.HUB_EmailTemplateNameSLABreached);
            templateIdForCommunity=HUB_Notification.getEmailTemplateId(label.HUB_EmailTemplateNameSLABreachedCommunity);//6.3.2015 by Ranjan
            //recipients = HUB_Notification.getRelatedCountryCaseManagerIds( c.OwnerId);
            mapIdAndType= HUB_Notification.getRelatedCountryCaseManagerIds(c.OwnerId);
            for(String id : mapIdAndType.keySet()){
                   if(mapIdAndType.get(id) == 'Standard'){
                     recipientsStandard.add(id);
                   }else{
                     recipientsCommunity.add(id);
                   }
             }
            HUB_Notification.sendNotificationToList(recipientsStandard, c.id, templateId);  
            HUB_Notification.sendNotificationToList(recipientsCommunity, c.id, templateIdForCommunity);               
        }
        */
       
        if (sendNewCaseCreated) {
            recipients.clear();
            Map<String, String> mapIdAndType = new Map<String, String>();
            Map<String, String> mapIdAndType1 = new Map<String, String>();
            Map<String, String> mapIdAndType2 = new Map<String, String>();
            Map<String, String> mapIdAndType3 = new Map<String, String>();
            List<String> recipientsStandard = new List<String>();
            List<String> recipientsCommunity = new List<String>();
            templateId = HUB_Notification.getEmailTemplateId(label.HUB_EmailTemplateCaseCreated);
            templateIdForCommunity=HUB_Notification.getEmailTemplateId(label.HUB_EmailTemplateCaseCreatedCommunity);//6.3.2015 by Ranjan
            //recipients = HUB_Notification.getRelatedCountryUserIds(c.OwnerId);
            //hlfUserrecipients=HUB_Notification.getRelatedTopicHLFUserIds(c.HUB_Issue__c );   //HUB 2.7
            //relatedBrandUserRecipients=HUB_Notification.getRelatedBrandUserIds(c.Id);   //HUB 2.7
            
            mapIdAndType1=HUB_Notification.getRelatedCountryUserIds(c.OwnerId);
            
            mapIdAndType2=HUB_Notification.getRelatedTopicHLFUserIds(c.HUB_Issue__c ); 
            
            mapIdAndType3=HUB_Notification.getRelatedBrandUserIds(c.Id);
            
            mapIdAndType.putAll(mapIdAndType1);
            mapIdAndType.putAll(mapIdAndType2);
            mapIdAndType.putAll(mapIdAndType3);
            
            for(String id : mapIdAndType.keySet()){
                   if(mapIdAndType.get(id) == 'Standard'){
                     recipientsStandard.add(id);
                   }else{
                     recipientsCommunity.add(id);
                   }
             }
            system.debug(recipientsStandard+'recipients====');    
            system.debug(recipientsCommunity+'recipients Community====');      
            HUB_Notification.sendNotificationToList(recipientsStandard, c.id, templateId); 
            HUB_Notification.sendNotificationToList(recipientsCommunity, c.id, templateIdForCommunity); 
            
            // send primary impacted region emails 
            Map<String, String> mapIdAndTypeImpact = new Map<String, String>();
            String impactTemplateId = HUB_Notification.getEmailTemplateId('Case: Impacted Region Added Case Creation');
          String imapctTemplateIdCommunity = HUB_Notification.getEmailTemplateId('Case: Impacted Region Added Case Creation Community');
           List<String> impactRecipientsStandard = new List<String>();
            List<String> impactRecipientsCommunity = new List<String>();
           mapIdAndTypeImpact = HUB_Notification.getCountryUserIds2(c.HUB_Country__c, c.HUB_Region__c);
            if (c.HUB_Country__c != '') {
                 for(String id : mapIdAndTypeImpact.keySet()){
                    if(mapIdAndType1.get(id) == null && mapIdAndType2.get(id) == null && mapIdAndType3.get(id) == null){
                      system.debug('send impacted alert+++++');
                        if(mapIdAndTypeImpact.get(id) == 'Standard'){
                            impactRecipientsStandard.add(id);
                        }else{
                            impactRecipientsCommunity.add(id);
                        }
                    }
                 }
                
                system.debug(impactRecipientsStandard+'impactRecipientsStandard++++');
                system.debug(impactTemplateId+'impactTemplateId++++');
                HUB_Notification.sendNotificationToList(impactRecipientsStandard, c.Id, impactTemplateId);
                HUB_Notification.sendNotificationToList(impactRecipientsCommunity, c.Id, imapctTemplateIdCommunity);
                system.debug('completed email');
            }
            
               
        }
     
        if (sendHighRed) {
            
             recipients.clear();
            String query = '';
            String allUsersGroup = '';
            if (allUsersGroup!='') {
                recipients = HUB_Notification.getGroupMemberUserData(allUsersGroup, 'id');
                query = 'select id,UserType from user where id in :recipients';
            }  else {
                query = 'select id,UserType from user where (HUB_Region__c != \'\') AND (isactive=true AND email != \'\')';
            }                    
            templateId = HUB_Notification.getEmailTemplateId(label.HUB_EmailTemplateCaseHighRed);
            templateIdForCommunity = HUB_Notification.getEmailTemplateId(label.HUB_EmailTemplateCaseHighRedCommunity);
            HUB_AllUserNotificationProcessor allNotify = new HUB_AllUserNotificationProcessor(query, templateId,templateIdForCommunity, c, recipients);
            Database.executeBatch(allNotify, 200);
            //allNotify.execute(null, [select id from user where id=:UserInfo.getUserId() AND (isactive=true AND email != '')]);
        }                       
    }
}