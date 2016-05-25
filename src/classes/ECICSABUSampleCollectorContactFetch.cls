/*Created By Anil Jadhav
To fetch the mobile number of Consumer and Sample collector from case team member*/
public class ECICSABUSampleCollectorContactFetch 
{   
    private static final Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);
    public static LIST<Id> contactIds = new LIST<Id>();
    private static String developerName = '';
    
     
    public Static List<string> fetchSampleCollectors(Id caseId)
    {   
        //List<String> memberPhonesList = new LIST<String>();
        //List<string> lstAccountIds = new List<string>();
        String sampleCollector_roleId = ECICCommonConstants.SABU_SAMPLE_COLLECTOR_ROLEID ;
        String qualityCoordinator_roleId = ECICCommonConstants.SABU_Quality_Coordinator_ROLE_ID ;
        List<string> lstContactIds = new List<string>();
        
        List<string> lstQueryUser = new List<string>();
        //Case_Team_Role__c.getValues(sampleCollector_roleId).CaseTeamRoleId__c;
        //Case_Team_Role__c.getValues(qualityCoordinator_roleId).CaseTeamRoleId__c;
        try
        {
            for(CaseTeamMember c:[select Member.Id from CaseTeamMember where ParentId =:caseId AND (TeamRoleId =:Case_Team_Role__c.getValues(sampleCollector_roleId).CaseTeamRoleId__c OR TeamRoleId =:Case_Team_Role__c.getValues(qualityCoordinator_roleId).CaseTeamRoleId__c) ])
            {
                If(String.ValueOf(c.MemberId).startsWith('003'))
                    lstContactIds.add(c.MemberId);
                else if(String.ValueOf(c.MemberId).startsWith('005'))
                    lstQueryUser.add(c.MemberId);                                
            }
            
            //System.debug('**'+ c);
            If(lstQueryUser != null && lstQueryUser.size() > 0)
            {
                List<User> lstUser =[select contactId, Contact.MobilePhone, Contact.AccountId from User where Id in :lstQueryUser];
                //System.debug('**'+ u.contactId);
                if(lstUser != null && lstUser.size() > 0)
                {
                    for(User objUser : lstUser)
                    {
                        if(objUser.ContactId != null && Schema.Contact.SObjectType == objUser.ContactId.getSobjectType())
                        {
                            //memberPhonesList.add(u.Contact.MobilePhone);
                            //lstAccountIds.add(u.Contact.AccountId);
                            //lstAccountIds.put(u.Contact.AccountId, u.Contact.MobilePhone);
                            lstContactIds.add(objUser.ContactId);
                        }
                    }
                }
            }
            //System.debug('**'+ memberPhonesList);
            
        }Catch(Exception s){
            System.debug('***'+ s);
        }  
        System.debug('***'+ lstContactIds);
        //return memberPhonesList;
        //return lstAccountIds;  
        return lstContactIds;
    }
    
    Public static List<String> FetchCaseConsumerPhone(Id CaseId){
        LIST<String> ConsumerPhone = new LIST<String>();
        For(Case c: [select Id,Contact.id from Case where Id=: CaseId  ]){
            if(c != null){
                if(c.Contact.id!=null && Schema.Contact.SObjectType == c.Contact.Id.getSobjectType())
                {
                    contactIds.add(c.Contact.Id);               
                }
                         
            }
            for(Contact cont:[Select MobilePhone From Contact where Id IN :contactIds]){
                if(cont.MobilePhone !=null){ConsumerPhone.add(cont.MobilePhone);}
            }   
        }
       // System.debug('***'+ ConsumerPhone);
        return ConsumerPhone;
    }
}