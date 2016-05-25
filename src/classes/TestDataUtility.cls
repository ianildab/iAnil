@isTest
public class TestDataUtility {
    
    public static User createUser() {
        
      Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
      User u = new User(Alias = 'standt', 
                        Email='standarduser@testorg.com', 
                                                                                EmailEncodingKey='UTF-8', 
                        LastName='Testing', 
                        LanguageLocaleKey='en_US', 
                                                                                LocaleSidKey='en_US', 
                        ProfileId = p.Id, 
                                                                                TimeZoneSidKey='America/Los_Angeles', 
                        UserName='cokestandarduser@testorg.com');
                        //insert u;
      return u;
    }
    public static List<Account> createAccount(Integer numAccts) {
        List<Account> testAct = new List<Account>();
        
        for(Integer i=0;i<numAccts;i++) {
            Account a = new Account(Name='TestAccount' + i);
            testAct.add(a);
        }
        //insert testAct;
        return testAct;
    }
    
    public static List<Case> createCase(String AccountId,Integer numCases) {
        List<Case> testCase = new List<Case>();
        
        for(Integer i=0;i<numCases;i++) {
            Case c = new Case(AccountId = accountId,
                              Status = 'New',            
                              Origin = 'Phone'
                              );
            testCase.add(c);
        }
        //insert testCase;
        return testCase;
    }
    
    public static List<Plant__c> createPlant(String countryCode, Integer numPlants) {
        List<Plant__c> testPlants = new List<Plant__c>();
        
        for(Integer i=0;i<numPlants;i++) {
            Plant__c p = new Plant__c(Active__c = true,
                              name = 'TestPlant ' + i,
                              Country_Code__c = countryCode
                              );
            testPlants.add(p);
        }
        return testPlants;
    }
    
    public static List<Region__c> createRegion(String countryCode, Integer numRegions) {
        List<Region__c> testRegion = new List<Region__c>();
        
        for(Integer i=0;i<numRegions;i++) {
            Region__c p = new Region__c(name = 'TestRegion ' + i,
                              Country_Code__c = countryCode
                              );
            testRegion.add(p);
        }
        return testRegion;
    }
    
    public static List<CaseTeamRole> createCaseTeamRole(Integer numCaseTeamRoles) {
        List<CaseTeamRole> testCaseTeamRoles = new List<CaseTeamRole>();
        
        for(Integer i=0;i<numCaseTeamRoles;i++) {
            CaseTeamRole p = new CaseTeamRole(name = 'CaseTeamRole ' + i,
                                                AccessLevel = 'Edit'
                              );
            testCaseTeamRoles.add(p);
        }
        return testCaseTeamRoles;
    }
    
    public static List<CaseTeamTemplate> createCaseTeamTemplate(Integer numCaseTeamTemplate) {
        List<CaseTeamTemplate> testCaseTeamTemplate = new List<CaseTeamTemplate>();
        
        for(Integer i=0;i<numCaseTeamTemplate;i++) {
            CaseTeamTemplate p = new CaseTeamTemplate(name = 'Quality Complaint Iberia' + i,
                                                Description = 'Test Description'
                              );
            testCaseTeamTemplate.add(p);
        }
        return testCaseTeamTemplate;
    }
    
    public static List<CaseTeamTemplateMember> createCaseTeamTemplateMember(Integer numCaseTeamTemplateMember) {
        List<CaseTeamTemplateMember> testCaseTeamTemplateMember = new List<CaseTeamTemplateMember>();
        
        for(Integer i=0;i<numCaseTeamTemplateMember;i++) {
            CaseTeamTemplateMember p = new CaseTeamTemplateMember();
            testCaseTeamTemplateMember.add(p);
        }
        return testCaseTeamTemplateMember;
    }
    
    public static void createCaseTeam(String CaseId,Integer numCaseTeams) {
        
    } 
    
    public static List<CaseTeamMember> createCaseTeamMember(Integer numCaseTeamMember) {
        List<CaseTeamMember> testCaseTeamMember = new List<CaseTeamMember>();
        
        for(Integer i=0;i<numCaseTeamMember;i++) {
            CaseTeamMember p = new CaseTeamMember();
            testCaseTeamMember.add(p);
        }
        return testCaseTeamMember;
        }
     
     public static List<sf4twitter__Twitter_Account__c> createTwitterAcc(Integer numTwiAccts) {
        List<sf4twitter__Twitter_Account__c> testtwiAct = new List<sf4twitter__Twitter_Account__c>();
        
        for(Integer i=0;i<numTwiAccts;i++) {
            sf4twitter__Twitter_Account__c a = new sf4twitter__Twitter_Account__c(Name='TestAccount' + i,sf4twitter__Username__c = 'abc' + i);
            testtwiAct.add(a);
        }
        return testtwiAct;
    }
    
    public static List<sf4twitter__Twitter_Conversation__c> createconversation(Integer numConvs) {
        List<sf4twitter__Twitter_Conversation__c> testconv = new List<sf4twitter__Twitter_Conversation__c>();
        
        for(Integer i=0;i<numConvs;i++) {
            sf4twitter__Twitter_Conversation__c a = new sf4twitter__Twitter_Conversation__c(sf4twitter__Author_External_Id__c = '1234' + i,sf4twitter__TwitterID__c = 'abc' + i);
            testconv.add(a);
        }
        return testconv;
    }
     
}