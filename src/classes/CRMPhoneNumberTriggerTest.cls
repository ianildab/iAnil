@isTest
public class CRMPhoneNumberTriggerTest {
    static testMethod void testPhoneNumberInsert(){
        Id accId = insertAccount('TestAccountPhoneNumber');
        Id phoneNumberId = insertPhoneNumber(accId);
        checkContactIdInsert(accId, PhoneNumberId);
    } 
    
    private static void checkContactIdInsert(Id accountId, Id PhoneNumberId){
        Account accWithContactId = [SELECT PersonContactId FROM Account WHERE Id = :accountId];
        PhoneNumber__c PhoneNumberWithContactId = [SELECT Contact__c FROM PhoneNumber__c WHERE Id = :PhoneNumberId];
        System.assertEquals(accWithContactId.PersonContactId, PhoneNumberWithContactId.Contact__c, 'The Contact Ids do do not match for the PhoneNumber insert');
    }
    
    private static ID insertPhoneNumber(Id accId){      
        PhoneNumber__c PhoneNumber = new PhoneNumber__c(
            pluralId__c= 'TEST_DS_consumer.email_aaa_1',
            dateVerified__c= Datetime.now(),    
            Account__c= accId,  
            countryCode__c='NL',
            value__c= '999888777'
        );
        insert PhoneNumber;
        return PhoneNumber.id;
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