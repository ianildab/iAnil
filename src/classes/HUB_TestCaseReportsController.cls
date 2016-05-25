@isTest
private class HUB_TestCaseReportsController {
static testMethod void testCaseReportsController(){
    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
    //Profile p2 = [SELECT Id FROM Profile WHERE Name='Hub Market Case Manager']; 
    UserRole uRole = [select id, name from UserRole where DeveloperName = 'HUB_Network_Super_User'];
    //Id recordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Topic Tracker').getRecordTypeId();
    User u1 = new User(Alias = 'newUser', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing',FirstName='Test',
                       LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,HUB_Country__c='Global',
                       TimeZoneSidKey='America/Los_Angeles', UserName='newHUBuserTest1@testorg.com',
                       UserRoleId = uRole.id, IsActive = true);
    //insert u1;
    /*User u2 = new User(Alias = 'newUser2', Email='newuser2@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing2',FirstName='Test2',
                       LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id,HUB_Country__c='Global',
                       TimeZoneSidKey='America/Los_Angeles', UserName='newHUBuserTest2@testorg.com', isActive = false);
    User u3 = new User(Alias = 'newUser3', Email='newuser3@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing3',FirstName='Test3',
                       LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id,HUB_Country__c='Global',
                       TimeZoneSidKey='America/Los_Angeles', UserName='newHUBuserTest3@testorg.com', isActive = false);*/
    Case case1;
    Case case2;
    HUB_Consolidated_Log__c log1;
    HUB_Consolidated_Log__c log2;
    /*System.RunAs(u1){
        case1=new Case(Subject='Test Class',Description='Test Class',HUB_Risk__c='Green',HUB_Category__c='Business',RecordTypeId=recordTypeId,
                     Issue__c='Addiction',Origin='Call Center',Priority='Medium',Status='Monitor',HUB_Velocity__c='Medium',
                     HUB_Impact__c='Brand',HUB_Brand__c='Sprite',HUB_Channel__c='Traditional Media',Region__c='Global',HUB_Business_Unit__c='Global',Country__c='Global');
      insert case1; 
        
      log1=new HUB_Consolidated_Log__c(Case__c=case1.id,Feed_Inserted_By__c=u1.id,Query_Id__c=case1.id);
    }
    System.RunAs(u2){
        case2=new Case(Subject='Test Class',Description='Test Class',HUB_Risk__c='Green',HUB_Category__c='Business',RecordTypeId=recordTypeId,
                     Issue__c='Addiction',Origin='Call Center',Priority='Medium',Status='Monitor',HUB_Velocity__c='Medium',
                     HUB_Impact__c='Brand',HUB_Brand__c='Sprite',HUB_Channel__c='Traditional Media',Region__c='Global',HUB_Business_Unit__c='Global',Country__c='Global');
     insert case2; 
        log2=new HUB_Consolidated_Log__c(Case__c=case2.id,Feed_Inserted_By__c=u2.id,Query_Id__c=case2.id);
    }*/
    
    User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    System.runAs ( thisUser ) {
        insert u1;
        HUB_User_Login_History__c loginHistory=new HUB_User_Login_History__c();
        loginHistory.First_Name__c=u1.FirstName;
        loginHistory.Last_Name__c=u1.LastName;
        loginHistory.Username__c=u1.Username;
        loginHistory.Hub_Market__c=u1.HUB_Country__c;
        loginHistory.User__c=u1.Id;
        insert loginHistory;
    }
        Test.StartTest();
          PageReference pageRef = Page.Hub_CaseReports;
          Test.setCurrentPage(pageRef);
          ApexPages.StandardController sc = new ApexPages.standardController(u1);
          Hub_CaseReportsController sic=new Hub_CaseReportsController(sc);
          sic.getUserMarkets();
          sic.fromDate=system.today();
          sic.toDate=system.today().addMonths(2);
          sic.userMarketFilter='Global';
          sic.setSortDirection('ASC');
          sic.sortExpression='HUB_Country__c';
          sic.showResults();
        //system.assert(sic.uniqueUsers.size()>0);
        Test.StopTest();
       
   
}
    @future
    private static void createHUBUserLoginHistory(Id uid){
        User u1 = [ Select id, FirstName, LastName, Username, HUB_Country__c from User where Id = :uid ];
        HUB_User_Login_History__c loginHistory=new HUB_User_Login_History__c();
        loginHistory.First_Name__c=u1.FirstName;
        loginHistory.Last_Name__c=u1.LastName;
        loginHistory.Username__c=u1.Username;
        loginHistory.Hub_Market__c=u1.HUB_Country__c;
        loginHistory.User__c=u1.Id;
        insert loginHistory;
    }
   /* static testMethod void testCaseReportsControllerNegative(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
    Profile p2 = [SELECT Id FROM Profile WHERE Name='Hub Market Case Manager']; 
    Id recordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Topic Tracker').getRecordTypeId();
    User u1 = new User(Alias = 'newUser', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing',FirstName='Test',
                       LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,HUB_Country__c='Global',
                       TimeZoneSidKey='America/Los_Angeles', UserName='newHUBuserTest4@testorg.com');
    User u2 = new User(Alias = 'newUser2', Email='newuser2@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing2',FirstName='Test2',
                       LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id,HUB_Country__c='Global',
                       TimeZoneSidKey='America/Los_Angeles', UserName='newHUBuserTest5@testorg.com');
        Case case1;
    Case case2;
    HUB_Consolidated_Log__c log1;
    HUB_Consolidated_Log__c log2;
    System.RunAs(u1){
        case1=new Case(Subject='Test Class',Description='Test Class',HUB_Risk__c='Green',HUB_Category__c='Business',RecordTypeId=recordTypeId,
                     Issue__c='Addiction',Origin='Call Center',Priority='Medium',Status='Monitor',HUB_Velocity__c='Medium',
                     HUB_Impact__c='Brand',HUB_Brand__c='Sprite',HUB_Channel__c='Traditional Media',Region__c='Global',HUB_Business_Unit__c='Global',Country__c='');
      insert case1; 
        
      log1=new HUB_Consolidated_Log__c(Case__c=case1.id,Feed_Inserted_By__c=u1.id,Query_Id__c=case1.id);
    }
    System.RunAs(u2){
        case2=new Case(Subject='Test Class',Description='Test Class',HUB_Risk__c='Green',HUB_Category__c='Business',RecordTypeId=recordTypeId,
                     Issue__c='Addiction',Origin='Call Center',Priority='Medium',Status='Monitor',HUB_Velocity__c='Medium',
                     HUB_Impact__c='Brand',HUB_Brand__c='Sprite',HUB_Channel__c='Traditional Media',Region__c='Global',HUB_Business_Unit__c='Global',Country__c='');
     insert case2; 
        log2=new HUB_Consolidated_Log__c(Case__c=case2.id,Feed_Inserted_By__c=u2.id,Query_Id__c=case2.id);
    }
    System.RunAs(u1){
         HUB_User_Login_History__c loginHistory=new HUB_User_Login_History__c();
        loginHistory.First_Name__c=u1.FirstName;
        loginHistory.Last_Name__c=u1.LastName;
        loginHistory.Username__c=u1.Username;
        loginHistory.Hub_Market__c=u1.HUB_Country__c;
        loginHistory.User__c=u1.Id;
        insert loginHistory;
        Test.StartTest();
          PageReference pageRef = Page.Hub_CaseReports;
          Test.setCurrentPage(pageRef);
          ApexPages.StandardController sc = new ApexPages.standardController(u1);
          Hub_CaseReportsController sic=new Hub_CaseReportsController(sc);
          sic.getUserMarkets();
          sic.fromDate=system.today();
          sic.toDate=system.today().addMonths(2);
          sic.userMarketFilter='Global';
          sic.showResults();
        //system.assert(sic.uniqueUsers.size()>0);
        Test.StopTest();
    }
    }*/
    /*
    static testMethod void testCaseReportsControllerNegative2(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
   
    User u1 = new User(Alias = 'newUser', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing',FirstName='Test',
                       LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id,HUB_Country__c='Global',
                       TimeZoneSidKey='America/Los_Angeles', UserName='newuser@testorg.com');
   
        
    System.RunAs(u1){
          Test.StartTest();
          PageReference pageRef = Page.Hub_CaseReports;
          Test.setCurrentPage(pageRef);
          ApexPages.StandardController sc = new ApexPages.standardController(u1);
          Hub_CaseReportsController sic=new Hub_CaseReportsController(sc);
          sic.getUserMarkets();
          sic.fromDate=system.today().addMonths(2);
          sic.toDate=system.today();
          sic.showResults();
        system.assert(sic.uniqueUsers.size()==0);
        Test.StopTest();
    }
    }*/
}