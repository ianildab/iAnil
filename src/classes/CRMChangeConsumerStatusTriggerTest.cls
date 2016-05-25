public class CRMChangeConsumerStatusTriggerTest {
    
    static testMethod void verifyAccountDeleteEngagement() {
        Account testAccount = new Account(LastName = 'testAccount',
                                          Salutation = 'Mr' ,
                                          FirstName = 'test',
                                          PersonBirthdate = date.newInstance(2008, 12, 1),
                                          PersonEmail = 'test@email.com' ,
                                          PersonHasOptedOutOfEmail = FALSE ,
                                          BillingStreet = 'test' ,
                                          ShippingStreet = 'test' ,
                                          PersonMailingStreet = 'test' ,
                                          PersonOtherStreet = 'test' ,
                                          Fax = '12345' ,
                                          Phone = '123456' ,
                                          PersonHomePhone = '1234567' ,
                                          PersonMobilePhone = '12345678' ,
                                          PersonOtherPhone = '123456789' ,
                                          Screen_Name__pc = 'test' ,
                                          sf4twitter__Fcbk_User_Id__pc = 'test' ,
                                          sf4twitter__Twitter_User_Id__pc = 'test' ,
                                          Identity_Card_Number__pc = 'test' ,
                                          Website = 'test',
                                          Shipping_Country__c = 'France' );
          insert testAccount;
          
          Engagement__c engagementDelete = new Engagement__c(Name='testEngagement', Consumer__c = testAccount.Id, Interaction__c = 'Remove PII', RecordTypeId = Schema.SObjectType.Engagement__c.RecordTypeInfosByName.get('Coke ID Engagement').RecordTypeId);
          insert engagementDelete ;
          
          testAccount = [SELECT id, 
                              Activation_Date__pc, 
                              Consumer_Status__pc,
                              Salutation,
                              FirstName,
                              LastName,
                              PersonBirthdate,
                              PersonEmail,
                              PersonHasOptedOutOfEmail,
                              BillingStreet,
                              ShippingStreet ,
                              PersonMailingStreet ,
                              PersonOtherStreet ,
                              Fax ,
                              Phone ,
                              PersonHomePhone ,
                              PersonMobilePhone ,
                              PersonOtherPhone ,
                              Screen_Name__pc ,
                              sf4twitter__Fcbk_User_Id__pc ,
                              sf4twitter__Twitter_User_Id__pc ,
                              Identity_Card_Number__pc ,
                              Website 
                              FROM Account WHERE Id =:testAccount.Id];
          
          System.debug( Logginglevel.DEBUG, 'Account Salutation : ' + testAccount.Salutation );
          System.debug( Logginglevel.DEBUG, 'Account FirstName : ' + testAccount.FirstName );
          System.debug( Logginglevel.DEBUG, 'Account LastName : ' + testAccount.LastName );
          System.debug( Logginglevel.DEBUG, 'Account PersonBirthdate : ' + testAccount.PersonBirthdate );
          System.debug( Logginglevel.DEBUG, 'Account PersonHasOptedOutOfEmail : ' + testAccount.PersonHasOptedOutOfEmail );
          System.debug( Logginglevel.DEBUG, 'Account BillingStreet : ' + testAccount.BillingStreet );
          System.debug( Logginglevel.DEBUG, 'Account ShippingStreet : ' + testAccount.ShippingStreet );
          System.debug( Logginglevel.DEBUG, 'Account PersonMailingStreet : ' + testAccount.PersonMailingStreet );
          System.debug( Logginglevel.DEBUG, 'Account PersonOtherStreet : ' + testAccount.PersonOtherStreet );
          System.debug( Logginglevel.DEBUG, 'Account Fax : ' + testAccount.Fax );
          System.debug( Logginglevel.DEBUG, 'Account Phone : ' + testAccount.Phone );
          System.debug( Logginglevel.DEBUG, 'Account PersonHomePhone : ' + testAccount.PersonHomePhone );
          System.debug( Logginglevel.DEBUG, 'Account PersonMobilePhone : ' + testAccount.PersonMobilePhone );
          System.debug( Logginglevel.DEBUG, 'Account PersonOtherPhone : ' + testAccount.PersonOtherPhone );
          System.debug( Logginglevel.DEBUG, 'Account Screen_Name__pc : ' + testAccount.Screen_Name__pc );
          System.debug( Logginglevel.DEBUG, 'Account sf4twitter__Fcbk_User_Id__pc : ' + testAccount.sf4twitter__Fcbk_User_Id__pc );
          System.debug( Logginglevel.DEBUG, 'Account sf4twitter__Twitter_User_Id__pc : ' + testAccount.sf4twitter__Twitter_User_Id__pc );
          System.debug( Logginglevel.DEBUG, 'Account Identity_Card_Number__pc : ' + testAccount.Identity_Card_Number__pc );
          System.debug( Logginglevel.DEBUG, 'Account Website : ' + testAccount.Website );
          
          System.assert(testAccount.Salutation == null);
          System.assert(testAccount.FirstName == null);
          System.assert(testAccount.LastName == 'No Disponible');
          System.assert(testAccount.PersonBirthdate == NULL);
          System.assert(testAccount.PersonHasOptedOutOfEmail == TRUE);
          System.assert(testAccount.BillingStreet == null);
          System.assert(testAccount.ShippingStreet == null);
          System.assert(testAccount.PersonMailingStreet == null);
          System.assert(testAccount.PersonOtherStreet == null);
          System.assert(testAccount.Fax == null);
          System.assert(testAccount.Phone == null);
          System.assert(testAccount.PersonHomePhone == null);
          System.assert(testAccount.PersonMobilePhone == null);
          System.assert(testAccount.PersonOtherPhone == null);
          System.assert(testAccount.Screen_Name__pc == null);
          System.assert(testAccount.sf4twitter__Fcbk_User_Id__pc == null);
          System.assert(testAccount.sf4twitter__Twitter_User_Id__pc == null);
          System.assert(testAccount.Identity_Card_Number__pc == null);
          System.assert(testAccount.Website == null);
    }
    
    static testMethod void verifyHugeAmountEngagement() {
      Account testAccount = new Account(LastName = 'testAccount');
      insert testAccount;
      List<Engagement__c> engagements = new List<Engagement__c>();
      Integer engAmount = 150;
      
      for (integer i=0; i < engAmount; i++){
        Engagement__c engagementLogin = new Engagement__c(Name = 'testEngagement', Consumer__c = testAccount.Id, Interaction__c = 'Login');
        engagements.add(engagementLogin);
      }
      insert engagements;
      System.assertEquals(engAmount, [SELECT Count() FROM Engagement__c]);
    }
    
    static testMethod void verifyWrongOrderedEngagement()         { changeConsumerStatusTest(new List<String>{'Remove PII','Request Account Deletion','Login','Activate Account','Register'},   'Piiremoved');  }
    static testMethod void verifyEngagementPermutationAct()       { changeConsumerStatusTest(new List<String>{'Activate Account'},                                                              'Active');   }
    static testMethod void verifyEngagementPermutationReg()       { changeConsumerStatusTest(new List<String>{'Register'},                                                                      'Inactive'); }
    static testMethod void verifyEngagementPermutationDel()       { changeConsumerStatusTest(new List<String>{'Remove PII'},                                                                    'Piiremoved');  }
    static testMethod void verifyEngagementPermutationActReg()    { changeConsumerStatusTest(new List<String>{'Activate Account','Register'},                                                   'Active');   }
    static testMethod void verifyEngagementPermutationActDel()    { changeConsumerStatusTest(new List<String>{'Activate Account','Remove PII'},                                                 'Piiremoved');  }
    static testMethod void verifyEngagementPermutationRegAct()    { changeConsumerStatusTest(new List<String>{'Register','Activate Account'},                                                   'Active');   }
    static testMethod void verifyEngagementPermutationRegDel()    { changeConsumerStatusTest(new List<String>{'Register','Remove PII'},                                                         'Piiremoved');  }
    static testMethod void verifyEngagementPermutationDelAct()    { changeConsumerStatusTest(new List<String>{'Remove PII','Activate Account'},                                                 'Piiremoved');  }
    static testMethod void verifyEngagementPermutationDelReg()    { changeConsumerStatusTest(new List<String>{'Remove PII','Register'},                                                         'Piiremoved');  }
    static testMethod void verifyEngagementPermutationActRegDel() { changeConsumerStatusTest(new List<String>{'Activate Account','Register','Remove PII'},                                      'Piiremoved');  }
    static testMethod void verifyEngagementPermutationActDelReg() { changeConsumerStatusTest(new List<String>{'Activate Account','Remove PII','Register'},                                      'Piiremoved');  }
    static testMethod void verifyEngagementPermutationRegActDel() { changeConsumerStatusTest(new List<String>{'Register','Activate Account','Remove PII'},                                      'Piiremoved');  }
    static testMethod void verifyEngagementPermutationRegDelAct() { changeConsumerStatusTest(new List<String>{'Register','Remove PII','Activate Account'},                                      'Piiremoved');  }
    static testMethod void verifyEngagementPermutationDelRegAct() { changeConsumerStatusTest(new List<String>{'Remove PII','Register','Activate Account'},                                      'Piiremoved');  }
    static testMethod void verifyEngagementPermutationDelActReg() { changeConsumerStatusTest(new List<String>{'Remove PII','Activate Account','Register'},                                      'Piiremoved');  }
    static testMethod void verifyNonActivationDeleteLogic()       { changeConsumerStatusTest(new List<String>{'Register','Delete Not Activated Account'},                                       'Piiremoved');  }
    
    private static void changeConsumerStatusTest(List<String> interactions, String expectedStatus) {
        Account testAccount = new Account(LastName = 'testAccount');
        insert testAccount;
        
        List<Engagement__c> engList = new List<Engagement__c>();
        Date expectedDate = null;
        Date testDate = null;
        
        for (String interation : interactions) {
            testDate = (interation == 'Activate Account') ? Date.newInstance(2008, 12, 1) : null;
            engList.add(new Engagement__c(Name = 'testEngagement', Consumer__c = testAccount.Id, Interaction__c = interation, Create_Date__c = testDate, RecordTypeId = Schema.SObjectType.Engagement__c.RecordTypeInfosByName.get('Coke ID Engagement').RecordTypeId));
            if (testDate != null) {
                expectedDate = testDate;
            }
        }
        insert engList;
        
        testAccount = [SELECT id, Activation_Date__pc, Consumer_Status__pc FROM Account WHERE Id =:testAccount.Id];
        
        System.debug( Logginglevel.DEBUG, 'Activate Account Date: ' + testAccount.Activation_Date__pc);
        System.debug( Logginglevel.DEBUG, 'Account Status: ' + testAccount.Consumer_Status__pc);
        
        System.assertEquals(expectedDate,   testAccount.Activation_Date__pc);
        System.assertEquals(expectedStatus, testAccount.Consumer_Status__pc);
    }
    
    static testMethod void verifyContactIDInsertionIntoEngagement() {
      Account testAccount = new Account(LastName = 'testAccount');
      insert testAccount;
      
      Account accAfterInsert = [
        SELECT PersonContactId, isPersonAccount
        FROM Account
        WHERE Id =: testAccount.Id];
      
      System.assert(accAfterInsert.isPersonAccount,'Created account is not a persion account.');
      
      Engagement__c accountRegistration = new Engagement__c(Name = 'testEngagement', Consumer__c = accAfterInsert.Id, Interaction__c = 'Register');
      Engagement__c accountActivation   = new Engagement__c(Name = 'testEngagement', Consumer__c = accAfterInsert.Id, Interaction__c = 'Activate Account', Create_Date__c= datetime.newInstance(2008, 12, 1, 12, 30, 2));
      insert new List<Engagement__c>{ accountRegistration, accountActivation };
      
      Engagement__c accRegEngagementAfterInsert = [
        SELECT id, Interaction__c, Contact__c
        FROM Engagement__c
        WHERE Id =: accountRegistration.Id];
      
      Engagement__c accActEngagementAfterInsert = [
        SELECT id, Interaction__c, Contact__c
        FROM Engagement__c
        WHERE Id =: accountActivation.Id];
      
      System.assert(
          accRegEngagementAfterInsert.Contact__c == accAfterInsert.PersonContactId,
          'Registration engagement does not have the Contact field filled up.');
      System.assert(
          accActEngagementAfterInsert.Contact__c == accAfterInsert.PersonContactId,
          'Activation engagement does not have the Contact field filled up.');
    }
    
}