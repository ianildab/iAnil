@isTest
private class ECICGeneralTest {

  private static User testRunUser = ECICRunUserTestHelper.create();

  static testMethod  void verifyPTContactNames() {
      System.runAs(testRunUser) 
      {
  
         ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
         
         String cc = 'PT';
          Country_Specific_Settings__c cs = Country_Specific_Settings__c.getValues(cc);   
          
          if (cs == null || String.isEmpty(cs.Exception_list__c)) {    
              return;
          }
          
          Map<String, String> names = new Map<String, String>();
          List<Contact> contacts = new List<Contact>();
          names.put('Eduardo da Silva', 'Francisco');
          names.put('de Almeida', 'Joaquim');
          names.put('Ronaldo dos Santos', 'Cristiano');
          
          for(String name : names.keySet()) {
              Contact c = new Contact(firstname = names.get(name), lastname = name);
              contacts.add(c);
          }
     
         User u = ECICTestHelper.createTestUser('Portugal Contact Verifier',
                     ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT, // #Ecic Template Test
                     ECICCommonConstants.ROLE_DEFAULT,
                     ECICCommonConstants.COUNTRY_CODE_PT);
          verifyContactNamesAsUser(u, contacts, names);
      }
  }

  static testMethod void verifyContactNames() {
      System.runAs(testRunUser) 
      {
          ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
          Map<String, String> names = new Map<String, String>();
          List<Contact> contacts = new List<Contact>();
          names.put('Natallia', 'Bahlai');
          names.put('De Almeida', 'Joaquim');
          names.put('Ronaldo Dos Santos', 'Cristiano');
          
          for(String name : names.keySet()) {
              Contact c = new Contact(firstname = names.get(name), lastname = name);
              contacts.add(c);
          }
          
          User u = ECICTestHelper.createTestUser('Contact Verifier',
                     ECICCommonConstants.PROFILE_ECIC_NWEN_INFOLINE_AGENT,
                     ECICCommonConstants.ROLE_DEFAULT,
                     ECICCommonConstants.COUNTRY_CODE_GB);
  
          System.RunAs(u){
              insert contacts;
              
              List<ID> ids = new List<ID>();
              for (Contact c : contacts) {
                  ids.add(c.id);
              }
              
              contacts = [select lastname, firstname from contact where id in :ids];
              
              for (Contact c : contacts) {
              system.debug(c.lastname);
                  
                  String name = names.get(c.lastname);
                  System.assert(String.isNotBlank(name) );
                  System.assert(c.firstname == name);
              }
          }
      }
  }

  static testMethod void verifyESContactNames() {
      System.runAs(testRunUser) 
      {
          ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
          String cc = 'ES';
          Country_Specific_Settings__c cs = Country_Specific_Settings__c.getValues(cc);
          
          if (cs == null || String.isEmpty(cs.Exception_list__c)) {
              
          system.debug(cs.Exception_list__c);
              return;
          }
  
          Map<String, String> names = new Map<String, String>();
          List<Contact> contacts = new List<Contact>();
          names.put('de Unamuno', 'Miguel');
          names.put('del Rio', 'Dolores');
          names.put('Palau y Dulcet', 'Antonio');
          names.put('Costa i Llobera', 'Miquel');
          names.put('del Carmen Jimenez', 'Maria');
          names.put('de la Fuente', 'Beatriz');
      //    names.put('de las Casas', 'Bartolome');
          names.put('de los Santos', 'Tomas');
            
          
            
          for(String name : names.keySet()) {
              Contact c = new Contact(firstname = names.get(name), lastname = name);
              contacts.add(c);
                
          }
           
          
          User u = ECICTestHelper.createTestUser('Spanish Contact Verifier',
                     ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT,       // #Ecic Template Test
                     ECICCommonConstants.ROLE_DEFAULT,
                     ECICCommonConstants.COUNTRY_CODE_SPAIN);
          verifyContactNamesAsUser(u, contacts, names);
      }
  }

  static void verifyContactNamesAsUser(User u, List<Contact> contacts, Map<String, String> names) {
         if (u != null) {
           Test.startTest();
              System.RunAs(u){
                  insert contacts;
                  
                  List<ID> ids = new List<ID>();
                  for (Contact c : contacts) {
                      ids.add(c.id);
                  }
                  
                  contacts = [select lastname, firstname from contact where id in :ids];
                                for (Contact c : contacts) {
                  system.debug(c.lastname);
                      
                      String name = names.get(c.lastname);
                      
                       
                     System.assert( name != null);
                       System.assert(c.firstname.equals(name));
                  }
                  
                  String ln = 'De Calle';
                  Contact c = new Contact(lastname = ln.toLowercase());
                  insert c;
                  
                  c = [select lastname from contact where id = :c.id ];
                  System.assert(c.lastname == ln);
                  
                  ln = 'de San Martin';
                  c = new Contact(lastname = ln.toLowercase(), firstname = 'Jose');
                  insert c;
                  
                  c = [select lastname from contact where id = :c.id ];
                  System.assert(c.lastname == ln);
                  
                  ln = 'Cordon-Cardo';
                  c = new Contact(lastname = ln, firstname = 'Carlos');
                  insert c;
                  
                  c = [select lastname from contact where id = :c.id ];
                  System.assert(c.lastname == ln); 
              }//end of System.RunAs
              Test.stopTest();
         }
  }  

  static testMethod void verifyAccountNames() {//TODO: add common method for both PA and Contacts
      System.runAs(testRunUser) 
      {
             ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE); 
             String cc = 'ES';
              Country_Specific_Settings__c cs = Country_Specific_Settings__c.getValues(cc);
              if (cs == null || String.isEmpty(cs.Exception_list__c)) {
                  return;
              }
      
              Map<String, String> names = new Map<String, String>();
              names.put('de Unamuno', 'Miguel');
              names.put('de la Fuente', 'Beatriz');
              names.put('del Carmen Jimenez', 'Maria');
           //   names.put('de las Casas', 'Bartolome');
              names.put('de los Santos', 'Tomas');
              names.put('del Rio', 'Dolores');
              names.put('Palau y Dulcet', 'Antonio');
              names.put('Costa i Llobera', 'Miquel');
              
              List<Account> contacts = new List<Account>();
              for(String name : names.keySet()) {
                  Account c = new Account(firstname = names.get(name).toLowercase(), lastname = name.toLowercase());
                  contacts.add(c);
              }
      
              User u = ECICTestHelper.createTestUser('Account Verifier',
                         ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT,
                         ECICCommonConstants.ROLE_DEFAULT,
                         ECICCommonConstants.COUNTRY_CODE_SPAIN);
              if (u != null) {
                  System.RunAs(u){
                      insert contacts;
                      
                      List<ID> ids = new List<ID>();
                      for (Account c : contacts) {
                          ids.add(c.id);
                      }        
                      
                      contacts = [select lastname, firstname from Account where id in :ids];
                      system.debug('ooooooooooooooooooooooo'+contacts);
                      for (Account c : contacts) {
                         system.debug('oooooc.lastnameoooooo'+c.lastname+'5555555555555'+names.get(c.lastname));
                          String name = names.get(c.lastname);
                            System.assert( name != null);
                            System.assert(c.firstname.equals(name));
                      }
                      
                      String ln = 'De Calle';
                      Account c = new Account(lastname = ln.toLowercase());
                      insert c;
                      
                      c = [select lastname from Account where id = :c.id ];
                      System.assert(c.lastname == ln);
                      
                      ln = 'de San Martin';
                      c = new Account(lastname = ln.toLowercase(), firstname = 'Jose');
                      insert c;
                      
                      c = [select lastname from Account where id = :c.id ];            
                      System.assert(c.lastname == ln);
                      
                      ln = 'Cordon-Cardo';
                      c = new Account(lastname = ln, firstname = 'Carlos');
                      insert c;
                      
                      c = [select lastname from Account where id = :c.id ];            
                      System.assert(c.lastname == ln);
                  }//end of System.RunAs
              }
       }        
  }  

/** FIXME (or drop)  : Tests fail new validation rule does not allow description to be blank
  
  static testMethod void verifyCasesFromEmailMessage() {
      System.runAs(testRunUser) 
      {
         ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
         Case c  = ECICCaseTestHelper.createNonQualityComplaint();
         
         insert c;
         String email = 'test@test.test';
         String name = 'Test de Test';
         String toAddress = 'es.test@test.test';
         EmailMessage m = new EmailMessage();
         m.FromAddress = email;
         m.fromName = name;
         m.toAddress = toAddress;
         m.parentId = c.id;
         
         insert m;
         
         c = [select contactId, accountId from Case where id = :c.id];
         //system.assert(c.contactId != null);
         //system.assert(c.accountId != null);
         
         //Account a = [select PersonContactId, PersonEmail, name from Account where id = :c.accountId];
         //Contact contact = [select email, name from Contact where id = :c.contactId];
         
         //system.assertEquals(a.PersonContactId, contact.id);
         //system.assertEquals(a.PersonEmail, email);
         //system.assertEquals(contact.email, email);
         //system.assert(a.name.equalsIgnoreCase(name));
         //system.assert(contact.name.equalsIgnoreCase(name));
      }
  }

**/
  
  static testMethod void verifyUserTrigger() {
      System.runAs(testRunUser) 
      {
         if(ECICUtils.triggerActive('ECICUserTrigger')) {
             User usr = new User(
                     Username='john.doe.cic@test.test',
                     Alias = 'test123', 
                     Email='john.doe.cic@test.test', 
                     FirstName='John', 
                     LastName='Doe ', 
                     ProfileId = [SELECT id FROM profile WHERE name != 'System Administrator' LIMIT 1].id, 
                     LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', 
                     EmailEncodingKey='UTF-8', 
                     TimeZoneSidKey='America/Los_Angeles');
             insert usr;
             usr =  usr = [SELECT id, Country_Code__c FROM user WHERE Username='john.doe.cic@test.test' LIMIT 1];
             usr.Country_Code__c = 'ES';
             update usr;
         }
       }
  }
  
  
/** FIXME (or drop)  : Tests fail new validation rule does not allow description to be blank

  **
  * @author    Pavel Slepenkov (Pavel_Slepenkov@epam.com)
  * @date      20 Feb 2013
  * @description   test ECICWeb2Case page & controller
  *
    static testMethod void verifyWeb2Case() {
      System.runAs(testRunUser) 
      {
        ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
          PageReference pageRef = Page.ECICWeb2Case;
          Test.setCurrentPage(pageRef);
          Case qualityComplaint = ECICCaseTestHelper.createQualityComplaint();
          insert qualityComplaint;
          ApexPages.StandardController sc = new ApexPages.StandardController(qualityComplaint);
          ECICCommonConstants controller = new ECICCommonConstants(sc);
          System.assertEquals( ((String)Schema.SObjectType.Case.getRecordTypeInfosByName().get(ECICCommonConstants.QUALITY_COMPLAINT).getRecordTypeId()).substring(0,15),
           controller.getQualityComplaintRT());
  
          System.assertEquals( ((String)Schema.SObjectType.Case.getRecordTypeInfosByName().get(ECICCommonConstants.NON_QUALITY_COMPLAINT).getRecordTypeId()).substring(0,15),
          controller.getNonQualityComplaintRT());
  
          System.assertEquals( ((String)Schema.SObjectType.Case.getRecordTypeInfosByName().get(ECICCommonConstants.INQUIRY).getRecordTypeId()).substring(0,15),
          controller.getInquiryRT());
  
          System.assertEquals( ((String)Schema.SObjectType.Case.getRecordTypeInfosByName().get(ECICCommonConstants.JOKE_USELESS).getRecordTypeId()).substring(0,15),
          controller.getJokeRT());
  
          System.assertEquals( ((String)Schema.SObjectType.Case.getRecordTypeInfosByName().get(ECICCommonConstants.THANKS).getRecordTypeId()).substring(0,15),
          controller.getThanksRT());
      }
  }
**/

    
  /**
  * @author    Pavel Slepenkov (Pavel_Slepenkov@epam.com)
  * @date      21 Feb 2013
  * @description   verify behavior Account Trigger during insertion a big amount of accounts
  */
  static testMethod void verifyAccountBulkInsertion() {
      System.runAs(testRunUser) 
      {
      ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
      List<Account> accountsForInsert = new List<Account>();
      for (Integer i = 0; i < ECICCommonConstants.AMOUNT_OF_TESTED_INSTANCE; i++) {
          accountsForInsert.add(ECICAccountTestHelper.createAccount());
      }
      insert accountsForInsert;
      for (Account a :accountsForInsert) {
        a.isBulk__c = true;
      }
      update accountsForInsert;
      }
  }  
}