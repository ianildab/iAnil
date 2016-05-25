/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must ha
 ve some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData = true)
private class HUB_NotificationTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Test.startTest();
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        Case caseRecord = new Case();
        caseRecord.AccountId = acc.Id;
        caseRecord.HUB_Region__c ='Global';  // hub_change
        insert caseRecord;

        Case c = [select id, subject, CreatedById, CaseNumber from case WHERE Id = :caseRecord.Id limit 1 ];
        String templateid = HUB_Notification.getEmailTemplateId(label.HUB_EmailTemplateCaseCreated);
        Messaging.Singleemailmessage mail = HUB_Notification.composeEmailFromTemplate(templateId, c.id);
        HUB_Notification.composeEmailFromTemplate(templateid, c.id);
        HUB_Notification.getRelatedCountryCaseManagerIds( c.CreatedById);
        HUB_Notification.getRelatedCountryUserIds( c.CreatedById);
        HUB_Notification.getGroupMemberUserData('Chatter Admins', 'email');
        HUB_Notification.getRelatedRegionUserIds( c.CreatedById);
        HUB_Notification.SearchAndDestroy(new List<String>{'test1','test2','test3'},'test1');
        //HUB_Notification.scheduleNotificationJobs();
        Test.stopTest();
    }
}