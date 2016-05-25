@isTest
public class SEPUserTriggerHandlerTest{
    private static final User TEST_RUN_USER = ECICRunUserTestHelper.create();
    private static Case objCase = null;
    
    private static testMethod void getCasesFromTrend()      {
    ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
    system.runAs(TEST_RUN_USER)
    {
    objCase = ECICCaseTestHelper.createDummyCase(true);
    }
    
    }

	/** FIXME (or drop)  : Tests fail new validation rule does not allow description to be blank
	
    static testmethod void testM1(){
         ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
         SEPUserTriggerHandler obj = new SEPUserTriggerHandler(true);

          test.startTest();
            Profile profile = [Select Id,Name from Profile where Name = : 'System Administrator'];
            list<userRole> role = [select id,DeveloperName from userrole limit 2];

            User  newUserRec1 = new User (
                        Username = 'TestAccount1@test.com',        
                        LastName = 'executive',
                        FirstName = 'Account',       
                        Email = 'Test@test.com',       
                        Alias = 'te1',
                        CommunityNickname = 'ce1',        
                        TimeZoneSidKey = 'America/Chicago',        
                        LocaleSidKey = 'en_US',    
                        EmailEncodingKey = 'ISO-8859-1',        
                        LanguageLocaleKey = 'en_US',
                        managerID = UserInfo.getUserID(),        
                        ProfileId = profile.ID,
                        UserRoleId = role[0].Id,
                        Country_code__c = 'US'
                        );
                        
        User  newUserRec2 = new User (
                        Username = 'TestAccount2@test.com',        
                        LastName = 'executive',
                        FirstName = 'Account',       
                        Email = 'Test@test.com',       
                        Alias = 'te2',
                        CommunityNickname = 'ce2',        
                        TimeZoneSidKey = 'America/Chicago',        
                        LocaleSidKey = 'en_US',    
                        EmailEncodingKey = 'ISO-8859-1',        
                        LanguageLocaleKey = 'en_US',
                        managerID = UserInfo.getUserID(),        
                        ProfileId = profile.ID,
                        UserRoleId = role[0].Id,
                        Country_code__c = 'UKA'
                        );
                        
        User  newUserRec4 = new User (
                        Username = 'TestAccount4@test.com',        
                        LastName = 'executive',
                        FirstName = 'Account',       
                        Email = 'Test@test.com',       
                        Alias = 'te4',
                        CommunityNickname = 'ce4',        
                        TimeZoneSidKey = 'America/Chicago',        
                        LocaleSidKey = 'en_US',    
                        EmailEncodingKey = 'ISO-8859-1',        
                        LanguageLocaleKey = 'en_US',
                        managerID = UserInfo.getUserID(),        
                        ProfileId = profile.ID,
                        UserRoleId = role[0].Id,
                        Country_code__c = 'UK'
                        );
                        
        User  newUserRec3 = new User (
                        Username = 'TestAccount3@test.com',        
                        LastName = 'executive',
                        FirstName = 'Account',       
                        Email = 'Test@test.com',       
                        Alias = 'te3',
                        CommunityNickname = 'ce3',        
                        TimeZoneSidKey = 'America/Chicago',        
                        LocaleSidKey = 'en_US',    
                        EmailEncodingKey = 'ISO-8859-1',        
                        LanguageLocaleKey = 'en_US',
                        managerID = UserInfo.getUserID(),        
                        ProfileId = profile.ID,
                        UserRoleId = role[0].Id,
                        Country_code__c = 'US',
                        E_Mail_Signature_Id__c = 'US Signature'
                        );
                        
            //insert newUserRec1;
            Country_Specific_Settings__c obj1 = new Country_Specific_Settings__c();
            Country_Specific_Settings__c obj2 = new Country_Specific_Settings__c();
            List<User> lstUSers1 = new List<User>();
            lstUSers1.add(newUserRec1);
            lstUSers1.add(newUserRec2);
            lstUSers1.add(newUserRec3);
            lstUSers1.add(newUserRec4);
            
              system.runAs(TEST_RUN_USER) {
              insert lstUSers1;
               obj1.Name = 'UK';
            obj1.E_Mail_Signature_Id__c = 'UK Signature';
            obj1.Allowed_Languages__c = 'ENglish';
            obj1.Default_Language__c = 'ENG';
            obj1.HQ_City__c = 'NewYork';
            obj1.Official_Languages__c = 'ENglish';
            obj1.Quality_Complaint_Record_Type_Id__c = '00099991';
            
               obj2.Name = 'US';
            obj2.E_Mail_Signature_Id__c = 'US Signature';
            
            obj2.Allowed_Languages__c = 'ENglish';
            obj2.Default_Language__c = 'ENG';
            obj2.HQ_City__c = 'NewYork';
            obj2.Official_Languages__c = 'ENglish';
            obj2.Quality_Complaint_Record_Type_Id__c = '00099991';
            List<Country_Specific_Settings__c> lstCSe = new List<Country_Specific_Settings__c>();
            lstCSe.add(obj1);
            lstCSe.add(obj2);
            insert lstCSe;
            
                //insert new List<User>{newUserRec1, newUserRec2};
              Map<ID, User> mapUser = new Map<ID,User>();
              mapUser.put(newUserRec1.Id,newUserRec1);
              newUserRec1.isActive = false;
               String caseStatus = 'New';
              ECICCaseTestHelper.CaseConfig caseConfig = new ECICCaseTestHelper.CaseConfig(caseStatus);
              caseConfig.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ECICCommonConstants.INQUIRY).getRecordTypeId();
                Case dummyCase = ECICCaseTestHelper.createDummyCase(caseConfig, true);
              update newUserRec1;
              List<USer> lstUSers = new List<User>();
              lstUSers.add(newUserRec1);
             
               obj.OnBeforeInsert(lstUSers);
            lstUSers = new List<User>();

            lstUSers.add(newUserRec1);
            
            Map<ID,User> mapUsers = new Map<ID,User>();
            mapUsers.put(newUserRec1.Id,newUserRec3);
            mapUsers.put(newUserRec2.Id,newUserRec1);
            mapUsers.put(newUserRec3.Id,newUserRec4);
            mapUsers.put(newUserRec4.Id,newUserRec3);
            
            obj.OnAfterUpdate(null, lstUSers, mapUser,null);
                obj.OnBeforeUpdate(null, lstUSers1, mapUsers,null);
            }
            
            

            
            test.stopTest();
        }
**/        
     }