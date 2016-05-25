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
private class HUB_PublishedArticleNotifySingleTest2{

    static testMethod void myUnitTest() {
        Test.startTest();
        HUB_PublishedArticleNotificationSingle2 batch = new HUB_PublishedArticleNotificationSingle2();
        batch = new HUB_PublishedArticleNotificationSingle2('xxxx');
        batch.setAsBatch(false);
        batch.start(null);
        batch.execute(null);        
        batch.execute(null,[SELECT Title, Summary, OwnerId FROM HUB_Internal_Use_Only_Core_Message__kav WHERE PublishStatus='Online' AND Language = 'en_US' limit 5]);
        batch.execute(null,[SELECT Title, Summary, OwnerId FROM HUB_Internal_Use_Only_Core_Message__kav WHERE PublishStatus='Archived' AND Language = 'en_US' limit 5]);
        batch.execute(null,[SELECT Title, Summary, OwnerId FROM HUB_Internal_Use_Only_Core_Message__kav WHERE PublishStatus='Draft' AND Language = 'en_US' limit 5]);
        batch.finish(null);
        Test.stopTest();
    }
}