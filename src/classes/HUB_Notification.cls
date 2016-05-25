/*** Author,email : Aldrin Rasdas , arasdas@coca-cola.com
* Date Create : May 28, 2013
* Description : a class containing some common functions used in hub notifications
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
public class HUB_Notification {
    
    public static String EmailFromText = 'The Hub';
    public static integer CaseStageRespondContentStatusExistingNoKALeadDay = 1;
    public static integer CaseStageRespondContentStatusExistingNoKALeadTime = 0;
    public static integer ArticleAssignedNotPublishedLeadDay = 7;
    public static integer ArticleAssignedNotPublishedLeadTime = 0;
    public static OrgWideEmailAddress owa = [SELECT id, Address FROM OrgWideEmailAddress WHERE Address LIKE '%nexusdo-not%' OR DisplayName = 'NEXUS Do Not Reply' LIMIT 1];
    //public static OrgWideEmailAddress owa = [SELECT id, Address FROM OrgWideEmailAddress WHERE Address LIKE '%nexusdo-not%' OR DisplayName = 'HUB Do Not Reply' LIMIT 1]; 
    public static List<String> hubProfiles=new List<String>();

    public static List<String> getGroupMemberUserData(String grpName, String fieldName) {
        List<String> idList = new List<String>();   
        List<String> userData = new List<String>();
        
        //get the group id
        Group g;
        try {
            g = [SELECT id FROM group WHERE name = :grpName];
        }
        catch (Exception ex) {/* throw an error as needed*/}    
        
        if (g==null) {
            return userData;
        }       
        
        //enumerate group member ids (including nested group members);      
        idList = getGroupMemberIds(new List<String>{g.id});
        
        String query = 'SELECT ' + fieldName + ' from USER where id in :idList AND (isActive=true AND email <> \'\')'; 
        for (User u: Database.query(query)) {
            userData.add(String.valueOf(u.get(fieldName))); 
        }
        
        return userData;
    }
    
    private static List<String> getGroupMemberIds(List<String>grpIds) {
        List<String> ids = new List<String>();  
        for (Group g: [SELECT (select userOrGroupId from groupMembers) FROM group WHERE id in :grpIds]) {
            for (GroupMember gm : g.groupMembers) {
                ids.add(gm.userOrGroupId);
            }
        }
        
        
        if (ids.size()>0) {
            List<String> additionalIds = getGroupMemberIds(ids);
            if (additionalIds.size()>0) {
                ids.addAll(additionalIds);
            }
        }               
        
        return ids;
    }
    
    //gets the list of usersids for a specified region
    public static List<String> getRegionUserIds(String regionName) {
        List<String> ids = new List<String>();
        if (regionName == null) return ids;
        if (regionName == '') return ids;
        for (User u : [SELECT id from User where HUB_Region__c =:regionName AND (isActive=true AND email <> '')]) {
            ids.add(u.id);
        }
        return ids;
    } 
    //get the list of userids for a specified country
    public static Map<String, String> getCountryUserIds(String countryName) {
        //List<String> ids = new List<String>();
        Map<String, String> ids = new Map<String, String>();
        if (countryName == null) return ids; 
        if (countryName == '') return ids;       
        for (User u : [SELECT id, name,UserType  from User where (((HUB_Country__c =:countryName) or HUB_MarketsObserved1__c includes(:countryName) OR HUB_MarketsObserved2__c includes(:countryName)) AND  (HUB_Opt_Out__c=false AND isActive=true AND email <> '' and Id != :UserInfo.getUserId())) or (Id =:UserInfo.getUserId() and HUB_Receive_Creation_Alert_for_Cases__c = true and HUB_Opt_Out__c=false)]) {
           ids.put(u.id,u.UserType);
           //ids.add(u.id);
        }
        return ids;
    }

    //get the list of userids for a specified country and region
    public static Map<String, String> getCountryUserIds2(String countryName, String regionName) {
        Map<String, String> ids = new Map<String, String>();
        if (countryName == null) return ids;
        if (countryName == '') return ids;     
        if (RegionName == 'Europe')
        {
        for (User u : [SELECT id, name, UserType from User where (((HUB_Country__c =:countryName) or HUB_MarketsObserved1__c includes(:countryName) OR HUB_MarketsObserved2__c includes(:countryName)OR HUB_New_Case_EG__c = true) AND  (HUB_Opt_Out__c=false AND isActive=true AND email <> '') AND Id != :UserInfo.getUserId())]) {
            ids.put(u.id, u.UserType);
            } 
        }
        if (RegionName == 'Eurasia & Africa')
        {
        for (User u : [SELECT id, name, UserType from User where (((HUB_Country__c =:countryName) or HUB_MarketsObserved1__c includes(:countryName) OR HUB_MarketsObserved2__c includes(:countryName)OR HUB_New_Case_EAG__c = true) AND  (HUB_Opt_Out__c=false AND isActive=true AND email <> '') AND Id != :UserInfo.getUserId())]) {
            ids.put(u.id, u.UserType);
            } 
        }
        if (RegionName == 'Global')
        {
        for (User u : [SELECT id, name, UserType from User where (((HUB_Country__c =:countryName) or HUB_MarketsObserved1__c includes(:countryName) OR HUB_MarketsObserved2__c includes(:countryName)OR HUB_New_Case_Global__c = true) AND  (HUB_Opt_Out__c=false AND isActive=true AND email <> '') AND Id != :UserInfo.getUserId())]) {
            ids.put(u.id, u.UserType);
            } 
        }
        if (RegionName == 'Latin America')
        {
        for (User u : [SELECT id, name, UserType from User where (((HUB_Country__c =:countryName) or HUB_MarketsObserved1__c includes(:countryName) OR HUB_MarketsObserved2__c includes(:countryName)OR HUB_New_Case_LAG__c = true) AND  (HUB_Opt_Out__c=false AND isActive=true AND email <> '') AND Id != :UserInfo.getUserId())]) {
            ids.put(u.id, u.UserType);
            } 
        }
        if (RegionName == 'North America')
        {
        for (User u : [SELECT id, name, UserType from User where (((HUB_Country__c =:countryName) or HUB_MarketsObserved1__c includes(:countryName) OR HUB_MarketsObserved2__c includes(:countryName)OR HUB_New_Case_NA__c = true) AND  (HUB_Opt_Out__c=false AND isActive=true AND email <> '') AND Id != :UserInfo.getUserId())]) {
            ids.put(u.id, u.UserType);
            } 
        }
        if (RegionName == 'Pacific')
        {
        for (User u : [SELECT id, name, UserType from User where (((HUB_Country__c =:countryName) or HUB_MarketsObserved1__c includes(:countryName) OR HUB_MarketsObserved2__c includes(:countryName)OR HUB_New_Case_APAC__c = true) AND  (HUB_Opt_Out__c=false AND isActive=true AND email <> '') AND Id != :UserInfo.getUserId())]) {
            ids.put(u.id, u.UserType);
            } 
        }
        return ids;
    }
    
    public static List<String> getCountryCaseManagerIdsList(String countryName) {
        List<String> ids = new List<String>();
        if (countryName == null) return ids;
        if (countryName == '') return ids;
        for (User u : [SELECT id, name,UserType from User where (((HUB_Country__c =:countryName AND HUB_Country_Case_Manager__c=true) or HUB_MarketCaseManager1__c includes(:countryName) OR HUB_MarketCaseManager2__c includes(:countryName)OR HUB_Country__c = 'Global') AND  (HUB_Opt_Out__c=false AND isActive=true AND email <> ''))]) {
            ids.add(u.id);     
        }
        return ids;     
    }
    
    public static Map<String, String> getCountryCaseManagerIds(String countryName) {
        //List<String> ids = new List<String>();
        Map<String, String> ids = new Map<String, String>();
        if (countryName == null) return ids;
        if (countryName == '') return ids;
        for (User u : [SELECT id, name,UserType from User where (((HUB_Country__c =:countryName AND HUB_Country_Case_Manager__c=true) or HUB_MarketCaseManager1__c includes(:countryName) OR HUB_MarketCaseManager2__c includes(:countryName)OR HUB_Country__c = 'Global') AND  (HUB_Opt_Out__c=false AND isActive=true AND email <> ''))]) {
            //ids.add(u.id);     
            ids.put(u.id,u.UserType);     
        }
        return ids;     
    }
    
    public static Map<String, String> getRelatedCountryCaseManagerIds(String userId) {
        //List<String> ids = new List<String>();
        Map<String, String> ids = new Map<String, String>();
        try {
            User u = [select HUB_Country__c from user where id=:userId];
            ids = getCountryCaseManagerIds( u.HUB_Country__c );
        }   
        catch (Exception ex) {/* throw an error as needed*/}    
        return ids;     
    }
    
    public static Map<String,String> getRelatedCountryUserIds(String userId) {
        //List<String> ids = new List<String>();
        Map<String, String> ids = new Map<String, String>();
        
        try {
            User u = [select HUB_Country__c from user where id=:userId];
            ids = getCountryUserIds( u.HUB_Country__c );
        }   
        catch (Exception ex) {/* throw an error as needed*/}    
        return ids;     
    }   
    
    public static void fetchUserProfiles(){
       
      List<HUB_Profiles__c> profileList = HUB_Profiles__c.getAll().values();
        
      for(HUB_Profiles__c pf : profileList ){
            hubProfiles.add(pf.Profile_Name__c);
      }
    
     /* commented to include ECIC Profiles too
       for (List<Profile> profileList: [select name from profile where name like 'Hub%']) {
           for(Profile pf:profileList){
             hubProfiles.add(pf.name);
             hubProfiles.add('System Administrator'); //for debugging purpose
           }
       }
     */
       
    }
    public static Map<String,String> getRelatedBrandUserIds(String caseId) { //HUB 2.7 enhancement
        Map<String,String> ids = new Map<String,String>();
        
        try {
              fetchUserProfiles();
              String relatedBrand='';
              List<Case> csList=[select HUB_Brand__c from Case where id=:caseId];
              if(csList.size()>0){
                for(Case cs: csList){
                   if(cs.HUB_Brand__c!='' || cs.HUB_Brand__c !=null){
                     relatedBrand=cs.HUB_Brand__c;
                   }
                }
              }
              if(relatedBrand!='' || relatedBrand!=null){
               List<User> usrList=[select id,UserType  from user where HUB_Relevant_Brands__c INCLUDES(:relatedBrand) and profile.name in: hubProfiles and HUB_Receive_Relevant_Brand_Case_Alerts__c=:true];
               if(usrList.size()>0){
                  for(User usr:usrList ){
                       // ids.add(usr.id);
                       ids.put(usr.id,usr.UserType);
                  }
                }
              }
              
        }   
        catch (Exception ex) {/* throw an error as needed*/}    
        return ids;     
    }
    
    public static Map<String,String> getRelatedTopicHLFUserIds(String caseTopic) { //HUB 2.7 enhancement
        Map<String,String> ids = new Map<String,String>();
        
        try {
              fetchUserProfiles();
              String hlfvalue='';
             List<HUB_Topic_to_HLF__c> hlfList=[select User_HLF__c from HUB_Topic_to_HLF__c where Name=:caseTopic];
             for(HUB_Topic_to_HLF__c hlf: hlfList){
                hlfvalue=hlf.User_HLF__c ;
             }
             system.debug('map values'+hlfvalue);
             
            if(hlfvalue!='' || hlfvalue!=null){
            List<User> usrList = [select id,UserType  from user where HUB_Function__c=:hlfvalue  and profile.name in: hubProfiles and HUB_Receive_High_Level_fun_Case_Alerts__c=:true];
            if(usrList.size()>0){
              for(User usr:usrList ){
                    //ids.add(usr.id);
                    ids.put(usr.id,usr.UserType);
              }
            }
          } 
        }   
        catch (Exception ex) {/* throw an error as needed*/}    
        return ids;     
    }
    
    public static List<String> getRelatedRegionUserIds(String userId) {
        List<String> ids = new List<String>();
        
        try {
            User u = [select HUB_Region__c from user where id=:userId];
            ids = getRegionUserIds( u.HUB_Region__c );
        }   
        catch (Exception ex) {/* throw an error as needed*/}    
        return ids;     
    }
    
    public static Messaging.Singleemailmessage composeEmailFromTemplate(String templateId, String objectId) {
        Messaging.Singleemailmessage email;
        email = new Messaging.Singleemailmessage();
        email.setTemplateId(templateId);
        email.setWhatId(objectId);    
        email.setSaveAsActivity(false);
        //email.setSenderDisplayName( HUB_Notification.EmailFromText); 
        email.setOrgWideEmailAddressId(owa.id);  
        
        return email;
    }
    
    public static boolean sendNotificationToList(List<String> ids, String oid, String templateId) {
        
        List<Messaging.Singleemailmessage> emails = HUB_Notification.prepareIndividualMails(ids, oid, templateId);
        
            if (emails.size()>0) {  
                    
            List<Messaging.Sendemailresult> smr;
            system.debug('before sending email');
            smr = Messaging.sendEmail(emails,false);
            
            system.debug('success email'+smr);
        }
        return true;
    }
    
    public static List<Messaging.Singleemailmessage> prepareIndividualMails(List<String> ids, String oid, String tmpId) {
        
        List<Messaging.Singleemailmessage> emails = new List<Messaging.Singleemailmessage>();
        Messaging.Singleemailmessage email;
        
        if (ids==null) return emails;
        if (oid==null) return emails;
        if (tmpId==null) return emails;
        if (ids.size()==0) return emails;
        if (tmpId=='') return emails;      
        
        ids = UniqueStringList(ids);
        
        for (String recipient : ids) {
            email = composeEmailFromTemplate(tmpId, oid);//new Messaging.Singleemailmessage();
            email.setTargetObjectId(recipient);        
            emails.add(email);          
        }
        
        return emails;
         
    }
    
    public static List<String> UniqueStringList(List<String> s) {
        Map<String,String> mapset = new Map<String,String>();
        for (String v : s) {
            if (!mapset.containsKey(v)) {
                mapset.put(v,v);
            }
        }
        
        return mapset.values();
    }
    
    public static String getEmailTemplateId(String name) {
        String id = '';
        try {
            EmailTemplate tmp = [select id from EmailTemplate where name=:name limit 1];
            id = tmp.id;            
        }
        catch (Exception ex) {/* throw an error as needed*/}
        
        return id;      
    }    
    
    public static List<String> SearchAndDestroy(List<String> s, String target) {
        List<String> result = new List<String>();
        for (String src : s) {
            if (!(src.equalsIgnoreCase(target))) {
                result.add(src);
            }
        }
        
        return result;
    }    
    //IMCR Alert Notification
    /**public static boolean sendNotificationToIMCRAddress(List<String> imcrAddress,String templateId,String objectId){
        List<Messaging.Singleemailmessage> emails= new List<Messaging.SingleEmailMessage>();
        Messaging.Singleemailmessage message=new Messaging.SingleEmailMessage();
        message.setToAddresses(imcrAddress);
        message.setOrgWideEmailAddressId(owa.id);
        //message.setTargetObjectId(objectId);
        //message.setTemplateId(templateId); 
        message.setPlainTextBody('Hi Case update mail for you');
        //message.setWhatId(objectId);  
        message.setSubject('IMCR Alert');
        emails.add(message);
        system.debug('Mail Creation'+emails);
        
        if (emails.size()>0) {  
                
        List<Messaging.Sendemailresult> smr;
        
        smr = Messaging.sendEmail(emails,false);
    }
        return true;
      
    }*/
     public static void scheduleNotificationJobs() {
        String cronStrEveryHour = '0 0 * * * ?';
        String cronStrEveryDay4AM = '0 0 4 ? * MON-SUN';
        String cronStrEveryDay5AM = '0 0 5 ? * MON-SUN';        
        
       HUB_AttachedArticleNotification a1 = new HUB_AttachedArticleNotification();
        System.schedule('HUB_AttachedArticleNotification', cronStrEveryHour , a1);        
        
        HUB_CaseSRCENoArticleNotification a2 = new HUB_CaseSRCENoArticleNotification();
        System.schedule('HUB_CaseSRCENoArticleNotification', cronStrEveryHour , a2);      
        
        HUB_PublishedArticleNotificationCO1 a3 = new HUB_PublishedArticleNotificationCO1();
        System.schedule('HUB_PublishedArticleNotificationCO1', cronStrEveryHour , a3);
        
        HUB_PublishedArticleNotificationIssue1 a4 = new HUB_PublishedArticleNotificationIssue1();
        System.schedule('HUB_PublishedArticleNotificationIssue1', cronStrEveryHour , a4);
        
        HUB_PublishedArticleNotificationSingle1 a5 = new HUB_PublishedArticleNotificationSingle1();
        System.schedule('HUB_PublishedArticleNotificationSingle1', cronStrEveryHour , a5);
        
        HUB_PublishedArticleNotificationSummary1 a6 = new HUB_PublishedArticleNotificationSummary1();
        System.schedule('HUB_PublishedArticleNotificationSummary1', cronStrEveryDay4AM , a6);                                    
        
        HUB_UnpublishedArticleNotification1 a7 = new HUB_UnpublishedArticleNotification1();
        System.schedule('HUB_UnpublishedArticleNotification1', cronStrEveryDay5AM , a7);  
        
        HUB_UnpublishedArticleNotification1 a8 = new HUB_UnpublishedArticleNotification1();
        System.schedule('HUB_UnpublishedArticleNotification1', cronStrEveryHour , a8);
        
        HUB_PublishedArticleNotificationIssue2 a9 = new HUB_PublishedArticleNotificationIssue2();
        System.schedule('HUB_PublishedArticleNotificationIssue2', cronStrEveryHour , a9);
        
        HUB_PublishedArticleNotificationSingle2 a10 = new HUB_PublishedArticleNotificationSingle2();
        System.schedule('HUB_PublishedArticleNotificationSingle2', cronStrEveryHour , a10);
        
        HUB_PublishedArticleNotificationSummary2 a11 = new HUB_PublishedArticleNotificationSummary2();
        System.schedule('HUB_PublishedArticleNotificationSummary2', cronStrEveryDay4AM , a11);                                    
        
        HUB_UnpublishedArticleNotification2 a12 = new HUB_UnpublishedArticleNotification2();
        System.schedule('HUB_UnpublishedArticleNotification2', cronStrEveryDay5AM , a12);        
    }   
}