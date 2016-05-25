@isTest
public class CRMEmailTriggerTest {
    static testMethod void testEmailInsert(){
        Id accId = insertAccount('TestAccountEmail');
        Id emailId = insertEmail(accId);
        checkContactIdInsert(accId, emailId);
    } 
    
    private static void checkContactIdInsert(Id accountId, Id emailId){
        Account accWithContactId = [SELECT PersonContactId FROM Account WHERE Id = :accountId];
        Email__c EmailWithContactId = [SELECT Contact__c FROM Email__c WHERE Id = :emailId];
        System.assertEquals(accWithContactId.PersonContactId, EmailWithContactId.Contact__c, 'The Contact Ids do do not match for the Email insert');
    }
    
    private static ID insertEmail(Id accId){        
        Email__c email = new Email__c(
            pluralId__c= 'TEST_DS_consumer.email_aaa_1',
            dateVerified__c= Datetime.now(),    
            Account__c= accId,  
            primary__c= 'FALSE',    
            schedulePreference__c= '9am',   
            target__c= 'pc',    
            valid__c= 'TRUE',   
            value__c= 'ttt@ttt.ttt'
        );
        insert email;
        return email.id;
    }
    
    private static ID insertAccount(String name) {
        Account account = new Account(
            LastName=name,
            Salutation='Mr',
            FirstName='test',
            PersonBirthdate=date.newInstance(2008, 12, 1),
            PersonEmail='test@email.com',
            PersonHasOptedOutOfEmail=FALSE,
            BillingStreet='test',
            ShippingStreet='test',
            PersonMailingStreet='test',
            PersonOtherStreet='test',
            Country_Code__pc='ES',
            Fax='12345',
            Phone='123456',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678',
            PersonOtherPhone='123456789',
            Screen_Name__pc='test',
            sf4twitter__Fcbk_User_Id__pc='test',
            sf4twitter__Twitter_User_Id__pc='test',
            Identity_Card_Number__pc='test',
            Website='test' );
        insert account;
        return account.id;
    }
}