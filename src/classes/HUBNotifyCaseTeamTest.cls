@isTest
public class HUBNotifyCaseTeamTest
{
    
    static testMethod void testNotifyCaseTeam()
    {
      Recordtype hubRecordtype = [Select name, id from RecordType where developerName = 'HUB_Issue_Tracker' Limit 1];
      Case cs=new Case(Subject='Test Class',Description='Test Class',HUB_Risk__c='Green',HUB_Category__c='Business',
                     HUB_Issue__c='Addiction', Origin='Call Center',Priority='Medium',Status='Monitor',HUB_Velocity__c='Medium',
                     HUB_Impact__c='Brand',HUB_Brand__c='Sprite',HUB_Channel__c='Traditional Media',HUB_Region__c='Global',
                     HUB_Business_Unit__c='Global',HUB_Country__c='', recordTypeId = hubRecordtype.id);
     insert cs;  
        
        User u = TestDataUtility.createUser();
        insert u;
        
        List<Account> acc = TestDataUtility.createAccount(1);
        insert acc;
        
        Contact c = new Contact(LastName = 'TestContact',Account = acc.get(0),Email = 'test@gmail.com',Country_Code__c = 'CR',Preferred_Language__c = 'English');
        insert c;
        
        HUB_Impacted_Region__c imp = new HUB_Impacted_Region__c(Impacted_Region__c = 'Global',Case__c = cs.Id,Country__c = 'Brazil');
        insert imp;
        
      /*  List<CaseTeamMember> ctList = new List<CaseTeamMember>();
        ctList.add(new CaseTeamMember(MemberId = c.Id));
        ctList.add(new CaseTeamMember(MemberId = u.Id));
        insert ctList;*/
        
        List<HUB_Consolidated_Log__c> logList = new List<HUB_Consolidated_Log__c>();
        logList.add(new HUB_Consolidated_Log__c(FeedType__c='TextPost',Query_Id__c=cs.Id,Case__c=cs.Id));
        logList.add(new HUB_Consolidated_Log__c(FeedType__c='Impacted Region Created',Query_Id__c=imp.Id,Case__c=cs.Id));
        logList.add(new HUB_Consolidated_Log__c(FeedType__c='CaseComment Creation/Updation',Query_Id__c=cs.Id,Case__c=cs.Id));
        insert logList;
        
        
        HUBNotifyCaseTeam.sendTemplatedEmail(new String[]{'test@gmail.com'},'test','test');
    }
    
    
}