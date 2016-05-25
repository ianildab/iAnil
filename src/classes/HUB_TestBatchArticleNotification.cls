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
    private class HUB_TestBatchArticleNotification
    {
        static testMethod void HUB_TestBatchArticleNotification()   
        {  
           			
            Profile usrprofile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
            UserRole usrRole=[SELECT Id FROM UserRole WHERE Name='HUB Issue Tracker Analyst'];
	        User testUser = new User(Alias = 'standt', Email='Test_user@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = usrprofile.Id, userroleid = usrRole.id,
            TimeZoneSidKey='America/Los_Angeles', UserName='Test_user@testorg.com',UserPermissionsKnowledgeUser=true);
			
            insert testUser;
            
            system.runAs(testUser){
                HUB_Approved_External_Messaging__kav testArticle= new HUB_Approved_External_Messaging__kav(Title = 'TestTitle', UrlName = 'TestTitle',Language = 'en_US');
                insert testArticle;
                
                HUB_Approved_External_Messaging__kav testArticleID = [Select KnowledgeArticleId from HUB_Approved_External_Messaging__kav where ID = :testArticle.Id];
                KbManagement.PublishingService.publishArticle(testArticleID.KnowledgeArticleId, true); 
                
                HUB_Batch_Article_Notification ban = new HUB_Batch_Article_Notification();                
                Test.startTest();        
                Database.executeBatch(ban, 2000);        
                Test.stopTest();
            }
        }
        
        public static void createTestUser(){
            
          
            
        }
    }