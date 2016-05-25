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
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class HUB_AllUserNotificationProcessorTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Test.startTest();
        String templateId = HUB_Notification.getEmailTemplateId(label.HUB_EmailTemplateAssignedNotPublished);
        Case c = [select id from Case limit 1];
        HUB_AllUserNotificationProcessor allNotify = new HUB_AllUserNotificationProcessor('SELECT id, UserType from user where (HUB_Region__c != \'\') limit 10', templateId,'',null);
        Database.executeBatch(allNotify);
        
        allNotify = new HUB_AllUserNotificationProcessor('SELECT id, UserType from user where (HUB_Region__c != \'\') limit 10',templateId,c,null);
        Database.executeBatch(allNotify);
        
        allNotify = new HUB_AllUserNotificationProcessor('',templateId,c,null);
        Database.executeBatch(allNotify);
                
        Test.stopTest();
    }
}