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
@istest (SeeAllData=false)
class HUB_TestScheduleBatchArticleNotification 
{   
    static testmethod void test() 
    {   Test.startTest();   
        // Schedule the test job     
        String timeToRun = '0 0 13 * * ?';      
        String jobId = System.schedule('HUB_ScheduleBatchArticleNotification',      
        timeToRun,          
        new HUB_ScheduleBatchArticleNotification());   
        // Get the information from the CronTrigger API object          
         CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime        
         FROM CronTrigger WHERE id = :jobId];   
         // Verify the expressions are the same           
         System.assertEquals(timeToRun,          
         ct.CronExpression);   
         // Verify the job has not run           
         System.assertEquals(0, ct.TimesTriggered);   
         System.abortJob(jobId);
         Test.stopTest();   
    }
}