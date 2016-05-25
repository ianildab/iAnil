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
@isTest
private class HUB_PublishedArticleNotifySummaryTest1 {

    static testMethod void myUnitTest() {
        Test.startTest();
        HUB_Approved_External_Messaging__kav a1 = new HUB_Approved_External_Messaging__kav(
            Title = 'test Article1',
            Summary = 'test from Article',
            URLName = 'test1A'
        );
         HUB_Approved_External_Messaging__kav a2 = new HUB_Approved_External_Messaging__kav(
            Title = 'test Article2',
            Summary = 'test from Article',
            URLName = 'test2A'
        );
         HUB_Approved_External_Messaging__kav a3 = new HUB_Approved_External_Messaging__kav(
            Title = 'test Article3',
            Summary = 'test from Article',
            URLName = 'test3A'
        );
         HUB_Approved_External_Messaging__kav a4 = new HUB_Approved_External_Messaging__kav(
            Title = 'test Article4',
            Summary = 'test from Article',
            URLName = 'test4A'
        );
         HUB_Approved_External_Messaging__kav a5 = new HUB_Approved_External_Messaging__kav(
           Title = 'test Article5',
            Summary = 'test from Article',
            URLName = 'test5A'
         );
        List<HUB_Approved_External_Messaging__kav> lstArticles= new List<HUB_Approved_External_Messaging__kav>();
        lstArticles.add(a1);
         lstArticles.add(a2);
         lstArticles.add(a3);
         lstArticles.add(a4);
         lstArticles.add(a5);
        insert lstArticles;
        HUB_PublishedArticleNotificationSummary1 batch = new HUB_PublishedArticleNotificationSummary1();
        batch = new HUB_PublishedArticleNotificationSummary1('xxxx');
        
        
        batch.setAsBatch(false);
        batch.start(null);
        batch.execute(null,[SELECT Title, LastModifiedBy.name, LastPublishedDate, Summary, OwnerId FROM HUB_Approved_External_Messaging__kav WHERE PublishStatus='Online' AND Language = 'en_US' limit 5]);
        batch.execute(null,[SELECT Title, LastModifiedBy.name, LastPublishedDate, Summary, OwnerId FROM HUB_Approved_External_Messaging__kav WHERE PublishStatus='Archived' AND Language = 'en_US' limit 5]);
        batch.execute(null,[SELECT Title, LastModifiedBy.name, LastPublishedDate, Summary, OwnerId FROM HUB_Approved_External_Messaging__kav WHERE PublishStatus='Draft' AND Language = 'en_US' limit 5]);        
        batch.execute(null);        
        batch.finish(null);
        Test.stopTest();
    }
}