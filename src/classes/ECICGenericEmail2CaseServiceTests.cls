@IsTest
public  class ECICGenericEmail2CaseServiceTests {

public ECICGenericEmail2CaseServiceTests(){

        EmailToCasePresets__c preInstGB = new EmailToCasePresets__c(Queue_DeveloperName__c ='GB_CIC',RecordType_DeveloperName__c ='Inquiry_NWEN',Country_Code__c = 'GB',Name ='GB.Inquiry.Email',Priority__c='Medium',Origin__c='Email',Accepted_Emails__c='nwen.cic@gmail.com',isActive__c=True);
        EmailToCasePresets__c preInstFR = new EmailToCasePresets__c(Queue_DeveloperName__c ='France_CIC',RecordType_DeveloperName__c ='Inquiry_NWEN',Country_Code__c ='FR',Name ='FR.Inquiry.Email',Priority__c='Medium',Origin__c='Email',Accepted_Emails__c='nwen.cic@gmail.com',isActive__c=True);
        List<EmailToCasePresets__c> preList = new List<EmailToCasePresets__c>();
        preList.add(preInstGB);
        preList.add(preInstFR);
        
        insert preList;
            
        // Create a new email and envelope object
}      
        // Set up your data if you need to
     static testMethod void TestPass(){   
      Messaging.InboundEmail email  = new Messaging.InboundEmail();
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       Messaging.InboundEmailResult result = new messaging.InboundEmailResult();
        
        // Create the email body
        email.plainTextBody ='<?xml version="1.0" encoding="UTF-8"?><details><siteName>Coca-Cola Coca-Cola</siteName><visitDate>03/12/2015 03:17:45 PM</visitDate><emailSubject>SF Test</emailSubject><firstName>Poornima</firstName><lastName>Padki</lastName><email>poornimapadki78902@test.com</email><city>Ciudad</city><countryCode>GB</countryCode><country>Selecciona</country><phoneNumber>908349081</phoneNumber><birthDate>28/10/1917</birthDate><question>web to case date take n</question><categoryList>Preguntas generales</categoryList><purposeList>Hidratacin</purposeList></details>';

        General_Settings__c gsInst = TEST_DummyGeneralSettingsFactory.create(TEST_DummyInsertModeEnum.REAL);
               
        ECICGenericEmail2CaseService  edr = new ECICGenericEmail2CaseService();
        
        Test.startTest();
         result = edr.handleInboundEmail(email, env);
        Test.stopTest();
        
        System.assertEquals(result.success, true);
        
    }
    
        static testMethod void TestFail(){   
       Messaging.InboundEmail email  = new Messaging.InboundEmail();
       Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       Messaging.InboundEmailResult result = new messaging.InboundEmailResult();
        

        General_Settings__c gsInst1 = TEST_DummyGeneralSettingsFactory.create(TEST_DummyInsertModeEnum.REAL);
        // Create the email body
        email.plainTextBody ='';
               
        ECICGenericEmail2CaseService  edr = new ECICGenericEmail2CaseService();
        
        Test.startTest();
             result = edr.handleInboundEmail(email, env);
        Test.stopTest();
        
        System.assertEquals(result.success, true);
        
    }
}