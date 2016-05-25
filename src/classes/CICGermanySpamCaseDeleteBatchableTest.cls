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
private class CICGermanySpamCaseDeleteBatchableTest {

    static testmethod void test() {
        // The query used by the batch job.
        List<Group> caseQueue = [SELECT id, Name, DeveloperName, type FROM Group where DeveloperName = 'Germany_Spam' and type = 'Queue' LIMIT 1];
            String queueId = caseQueue.size() != 0 ? caseQueue[0].id : null;
            String query = 'SELECT id, accountId, contactId FROM case where Country_Code__c = \'DE\' AND ownerId = \'' + queueId + '\'';

       // Create some test cases to be deleted
       //   by the batch job.
       
       Case[] deleteCases = new List<Case>();
       for (Integer i=0;i<3;i++) {
           Case c= new Case(
               
             ownerId = queueId,
               Description ='Some description',
               Subject = 'Some Subject');
               
           deleteCases.add(c);
       }
       insert deleteCases;

       Test.startTest();
       CICGermanySpamCaseDeleteBatchable clean = new CICGermanySpamCaseDeleteBatchable();
       Database.executeBatch(clean);
       Test.stopTest();

       // Verify cases got deleted 
       Integer i = [SELECT COUNT() FROM Case where Country_Code__c = 'DE' AND ownerId =: queueId];
       System.assertEquals(i, 0);
    }
}