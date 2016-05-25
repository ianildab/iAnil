@isTest
public class SABU_SMS_Helper_Test 
{
    private static List<Case> testCases=new List<Case>();
    private static List<Case> testCasesUp=new List<Case>();
    private static List<Account> testAccounts=new List<Account>();
    private static List<Account> personAccount=new List<Account>();
    private static List<Account> SCAccount=new List<Account>();
    private static List<Case> testCasesOld = new List<Case>();
    private static List<Plant__c> testPlant = new List<Plant__c>();
    private static List<Production_Line__c> testPL = new List<Production_Line__c>(); 
    private static string countryCode = 'ZA';
    private static List<CCE_Product__c> testProduct = new List<CCE_Product__c>();
    private static final Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);
    private static string recordTypeCase;
    private static string InquiryrecordTypeCase;
    private static List<Contact> SCContact = new List<Contact>();
    
    public static testMethod void sendSABUsmsListTest()
    {   
        
            testAccounts = TestDataUtility.createAccount(1);
            testAccounts[0].type='Bottler';
            testAccounts[0].Shipping_Country__c='South Africa';
            testAccounts[0].shipping_administrativearea__c = 'testRegion';
            Database.insert(testAccounts);
        
            RecordType personAccId    =   [SELECT Id,Name,SobjectType FROM RecordType WHERE Name = 'Person' AND SobjectType = 'Account'];
            RecordType businessAccId    =   [SELECT Id,Name,SobjectType FROM RecordType WHERE Name = 'Company' AND SobjectType = 'Account'];
            //personAccount =   TestDataUtility.createAccount(1);
            Account a = new Account();
            a.LastName='Test1';
            a.PersonMobilePhone='0891234567';
            a.Country_Code__c='ZA';
            a.Preferred_Language__pc='English';
            a.RecordTypeId  =   personAccId.id;
            personAccount.add(a);
            Database.insert(personAccount);
        
            testPlant = TestDataUtility.createPlant(countryCode,1);
            testPlant[0].Name = 'Bloemfontein';
            testPlant[0].active__c = true;
            testPlant[0].LCBU_Plant_Code__c = 'CB';
            Database.Insert(testPlant);
        
            Production_Line__c pl = new Production_Line__c(Name = '1');
            pl.Active__c = True;
            pl.Plant__c = testPlant[0].Id;
            pl.Country_Code__c = countryCode ;
            pl.Pack__c = 'PET';
            pl.Content__c = '2.00L';            
            testPL.add(pl);
            Database.insert(testPL);
        
            CCE_Product__c pr = new CCE_Product__c();
            pr.Active__c = True;
            pr.Brand__c = 'Coca-Cola';
            pr.Country_Code__c = countryCode;
            pr.Flavour__c = 'Coca-Cola';
            pr.Packaging__c = 'PET';
            pr.Size__c = '1.50L';
            pr.Shelf_Life_In_Days__c = 168.0; 
            testProduct.add(pr);
            Database.insert(testProduct);
        
            City__c cty = new City__c(Name='ORIENTAL PLAZA , STANDERTON');
            Database.insert(cty);            
            
            recordTypeCase = schema.SObjectType.Case.getRecordTypeInfosByName().get('Quality Complaint SABU').getRecordTypeId();
            InquiryrecordTypeCase = schema.SObjectType.Case.getRecordTypeInfosByName().get('Inquiry SABU').getRecordTypeId();
                        
            testCases = TestDataUtility.createCase(personAccount[0].id,5);
            testCases[0].reason = 'Product Quality';
            testCases[0].Category_Level3__c = 'CARBONATION';
            testCases[0].Country_Code__c = countryCode; 
            testCases[0].CCE_Product__c = testProduct[0].Id;
            testCases[0].RecordTypeId = recordTypeCase;
            testCases[0].Status = 'Open';
            testCases[0].Subject = 'test';
            testCases[0].Description = 'test';   
            testCases[0].City__c =cty.Id;
            testCasesUp.add(testCases[0]);
        
            testCases[1].reason = 'Commercial & Distribution (I)';
            testCases[1].Category_Level3__c = 'Beverage Distribution';
            testCases[1].Country_Code__c = countryCode;
            testCases[1].RecordTypeId = InquiryrecordTypeCase;       
            testCases[1].Status = 'Open';
            testCases[1].Description = 'test';
            testCases[1].Subject = 'test';
            testCases[1].City__c =cty.Id;
               
            testCasesUp.add(testCases[1]);
            
            /*testCases[2].reason = 'Product Quality';
            testCases[2].Category_Level3__c = 'CARBONATION';
            testCases[2].Country_Code__c = countryCode;
            testCases[2].CCE_Product__c = testProduct[0].Id;
            //testCases[2].Production_Line__c = testPL[0].Id;
            testCases[2].RecordTypeId = recordTypeCase;
            testCases[2].Status = 'New';
            testCases[2].Description = 'test';
            //testCases[2].Text_BBE_Date__c = '30SEP16';
            //testCases[0].production_date__c = date.ValueOf('2016-04-30');
//            testCases[2].Production_Code__c = 'CB112:23';  
            //testCases[2].LCBU_Plant_code__c = 'CB';
            testCases[2].City__c =cty.Id;         
        
             testCasesUp.add(testCases[2]);*/
            //database.insert(testCases[2]);
            
            
           
            //database.insert(testCases[3]);
            
            //database.Insert(testCasesUp);
           
            //testCases[2].production_date__c = date.ValueOf('2016-04-30');
            //testCasesUp.add(testCases[2]);
            
            //database.insert(testCases);
            system.debug(testCases + 'testCasesnowCheck');
            //testCasesUp[0].Status = 'Open';   
            //testCasesUp[1].Status = 'Open';
           // testCases[2].Status = 'Open';
            //database.update(testCasesUp);
            /*testCases[0].Status = 'Open';
            testCases[1].Status = 'Open';
            testCases[2].Status = 'Open';
            database.update(testCases);*/
            
            /*UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
            system.debug('portalRole is ' + portalRole);
            
            Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
            User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'PortalAdmin@test.com',
            Alias = 'Portal',
            Email='PortalAdmin@test.com',
            EmailEncodingKey='UTF-8',
            Firstname='PortalAdmin',
            Lastname='test',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
            );
            Database.insert(portalAccountOwner1);*/
            
            Account objSCAcc;
            Contact objSCCon;
            User u1;            
            
            //System.runAs ( portalAccountOwner1 ) {
            objSCAcc = new Account();
            objSCAcc.Name='Test1';
            objSCAcc.Phone ='0891234567';
            objSCAcc.Country_Code__c='ZA';
            //objSCAcc.Preferred_Language__pc='English';
            objSCAcc.RecordTypeId  =   businessAccId.id;
            //objSCAcc.OwnerId = portalAccountOwner1.Id;
            SCAccount.add(objSCAcc);
            Database.insert(SCAccount);
            
            objSCCon = new Contact();
            objSCCon.FirstName = 'test1';
            objSCCon.LastName = 'test2';
            objSCCon.AccountId = SCAccount[0].Id;
            objSCCon.MobilePhone = '0891234567';
            SCContact.add(objSCCon);
            Database.insert(SCContact);
           //}
            
            /*Profile p = [SELECT Id FROM Profile WHERE Name='ECIC SABU Sample Collector'];
            u1 = new User(Alias = 'standt1',Email='standarduser1@testorg.com',EmailEncodingKey='UTF-8',LastName='Testing2', 
                            LanguageLocaleKey='en_US',LocaleSidKey='en_US', 
                            Country_Code__c='ZA',Enabled_Countries__c='ZA; BW; NA; LS; SZ; ZW; ZM; MW; AO',ProfileId = p.Id,
                            TimeZoneSidKey='America/Los_Angeles',UserName='cokestandarduser1@testorg.com', ContactId = SCContact[0].Id);
                            insert u1;
                            
            User u2 = new User(Alias = 'standt2',Email='standarduser2@testorg.com',EmailEncodingKey='UTF-8',LastName='Testing2', 
                            LanguageLocaleKey='en_US',LocaleSidKey='en_US',Country_Code__c='ZA',
                            Enabled_Countries__c='ZA; BW; NA; LS; SZ; ZW; ZM; MW; AO',ProfileId = p.Id,
                            TimeZoneSidKey='America/Los_Angeles', 
                            UserName='cokestandarduser2@testorg.com');
                            insert u2;
            User u3 = new User(Alias = 'standt3',Email='standarduser3@testorg.com',EmailEncodingKey='UTF-8',LastName='Testing3', 
                            LanguageLocaleKey='en_US',LocaleSidKey='en_US',Country_Code__c='IA',Enabled_Countries__c='',
                            ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',UserName='cokestandarduser3@testorg.com');
                            insert u3;*/
            /*City__c city = new City__c(CountryCode__c='ZA', Name='Test City');  
            insert city;*/
            
            //Geo_Mapping__c geomapping = new Geo_Mapping__c(City__c = city.Id, Plant__c = testPlant[0].Id  ,Unique_City__c='test' );
            Geo_Mapping__c geomapping = new Geo_Mapping__c(City__c = cty.Id, Plant__c = testPlant[0].Id  ,Unique_City__c='test' );    
            insert geomapping;
            
            /*Sample_Collector__c sc = new Sample_Collector__c( Geo_Mapping__c= geomapping.Id , User__c = u1.Id);
            insert sc;
            
            Sample_Collector__c sc1 = new Sample_Collector__c( Geo_Mapping__c= geomapping.Id , User__c = u3.Id);
            insert sc1;*/
            
            Mobile_Operator__c mobileOperator   =   new Mobile_Operator__c(Name='2789',Value__c='278393001780576');
        
            Service_Settings__c serviceSetting  =   new Service_Settings__c();
            serviceSetting.Name = 'SABU SMS Service';
            serviceSetting.Content_Type__c = 'text/xml;charset=UTF-8';
            serviceSetting.NODE__c = 'colaHTTP';
            serviceSetting.PASSWORD__c = 'Zqs2Zkh6';
            serviceSetting.CountryCode__c = '27';
            serviceSetting.Endpoint__c = 'http://196.11.240.180:8080/mtnusa/client.jsp';
            serviceSetting.Operation__c = 'POST';
            serviceSetting.USERNAME__c = 'colaHTTP';
            serviceSetting.TRANSFORM__c = 'SUBMIT_SM';
            serviceSetting.Business_Unit__c = 'SABU';
            
            Common_Settings__c commonSetting1 = new Common_Settings__c(Name = 'SABU_EnableSendSMS',Value__c = 'true');            
            Common_Settings__c commonSetting2 = new Common_Settings__c(Name = 'SMSFakeResponse',Value__c = 'true');
            Common_Settings__c commonSetting3 = new Common_Settings__c(Name = 'SMSFakeResponseSuccess',Value__c = 'true');
            
            insert serviceSetting;
            insert commonSetting1;
            insert commonSetting2;
            insert commonSetting3;
            insert mobileOperator;
        
            Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new CCCSABU_SendSMSServiceMockImpl());
            database.Insert(testCasesUp);
            Test.stopTest();
        
            /*testCases[2].Status = 'Open';
            update testCases[2];*/
        
            /*CaseTeamRole teamRole   =   [SELECT Id,Name FROM CaseTeamRole WHERE Name = 'SABU Sample Collector'];
            List<CaseTeamMember> teamMembers    =   new List<CaseTeamMember>();
            CaseTeamMember teamMember   =   new CaseTeamMember();
            teamMember.MemberId = u1.id;
            teamMember.ParentId = testCases[2].id;
            teamMember.TeamRoleId   =   teamRole.id;
            teamMembers.add(teamMember);
            insert teamMembers;*/
        
            
            /*String sampleCollector_roleId = ECICCommonConstants.SABU_SAMPLE_COLLECTOR_ROLEID ;
            String qualityCoordinator_roleId = ECICCommonConstants.SABU_Quality_Coordinator_ROLE_ID ;
            system.assertNotEquals(null,[select Member.Id from CaseTeamMember where ParentId =:testCases[2].id AND (TeamRoleId =:Case_Team_Role__c.getInstance('SABU Quality Coordinator').CaseTeamRoleId__c OR TeamRoleId =:Case_Team_Role__c.getInstance('SABU Sample Collector').CaseTeamRoleId__c)]);*/
            
                
       }
        
        
        
}