@isTest
public class HUB_ContentConsolidatedLogTest {
    static testMethod void myUnitTest(){
        Test.StartTest();
        RecordType rt = [select id,Name ,DeveloperName from RecordType where SobjectType='Case' and DeveloperName='HUB_Issue_Tracker' Limit 1];
        
        Case cs=new Case(Subject='Test Class 3',Description='Test Class',HUB_Risk__c='Green',HUB_Category__c='Business',
                     HUB_Issue__c='Addiction',Origin='Call Center',Priority='Medium',Status='Monitor',HUB_Velocity__c='Medium',
                     HUB_Impact__c='Brand',HUB_Brand__c='Sprite',HUB_Channel__c='Traditional Media',HUB_Region__c='Global'
                         ,HUB_Business_Unit__c='Global',HUB_Country__c='',recordTypeId=rt.id);
        
          
        insert cs; 
        
        HUB_Contents__c  c = new HUB_Contents__c ();
        c.Title__c = 'sample content';
        c.Description__c = 'test description';
        c.contentType__c = 'Campaign';
        c.URL__c='www.google.com';
        c.Source__c='DMX';
        c.Date__c=Date.today();
        c.End_Date__c=Date.today().addDays(10);
        insert c;
        
        HUB_Related_Content__c obj = new HUB_Related_Content__c ();
        obj.case__c = cs.Id;
        obj.Content__c = c.id;
        insert obj;
        
    }

}