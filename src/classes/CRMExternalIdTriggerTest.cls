@isTest
public class CRMExternalIdTriggerTest {
    static testMethod void testExternalIdInsert(){
        Id accId = insertAccount('TestAccountExternalId');
        Id ExternalIdId = insertExternalId(accId);
        checkContactIdInsert(accId, ExternalIdId);
    } 
    
    private static void checkContactIdInsert(Id accountId, Id ExternalIdId){
        Account accWithContactId = [SELECT PersonContactId FROM Account WHERE Id = :accountId];
        ExternalId__c ExternalIdWithContactId = [SELECT Contact__c FROM ExternalId__c WHERE Id = :ExternalIdId];
        System.assertEquals(accWithContactId.PersonContactId, ExternalIdWithContactId.Contact__c, 'The Contact Ids do do not match for the ExternalId insert');
    }
    
    private static ID insertExternalId(Id accId){       
        ExternalId__c ExternalId = new ExternalId__c(
            pluralId__c= 'TEST_DS_consumer.externalid_tdg_1',
            lastUpdatedTime__c= DateTime.now().addDays(-10),
            Account__c= accId,
            type__c= 'National Id',
            useForLogin__c= 'FALSE',
            value__c= 'user.external.id_9990342'
        );
        insert ExternalId;
        return ExternalId.id;
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