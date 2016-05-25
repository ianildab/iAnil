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
@isTest (SeeAllData = true)
private class HUB_UserInfoProcessTest {

    static testMethod void myUnitTest() 
    {
        Profile p = [SELECT id FROM profile WHERE name = 'System Administrator'];
        User u1 = new User (alias = 'Testpr',
        					email = 'automatedtestpro@testcoca-cola.com',
        					emailencodingkey = 'UTF-8',
        					lastname = 'Process',
        					firstname = 'Automated',
        					companyname = 'coca-cola',
        					languagelocalekey = 'en_US',
        					localesidkey = 'en_US',
        					profileid = p.Id,
        					timezonesidkey = 'America/New_York',
        					username = 'A89010@testcoca-cola.com',
        					HUB_Employee_Type__c = '10'
        					);
        					insert u1;
        					
        					
        					System.runAs (u1){
        					u1.lastname = 'Process1';
        					u1.firstname = 'Automated1';
        					update u1;
        					
        User u2 = new User (alias = 'Testpr1',
        					email = 'automatedtestpro1@testcoca-cola.com',
        					emailencodingkey = 'UTF-8',
        					lastname = 'Process',
        					firstname = 'Automated',
        					companyname = 'coca-cola',
        					languagelocalekey = 'en_US',
        					localesidkey = 'en_US',
        					profileid = p.Id,
        					timezonesidkey = 'America/New_York',
        					username = 'A89011@testcoca-cola.com'
        					);
        					insert u2;
    }}
}