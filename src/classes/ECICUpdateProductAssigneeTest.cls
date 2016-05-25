@isTest
public class ECICUpdateProductAssigneeTest {
public static List<Plant__c> plantList = new List<Plant__c>();
private static final Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Account.SObjectType);
    
static testMethod void eCICUpdateProductAssignee()
{
  plantList = TestDataUtility.createPlant('ES',1) ;
  insert plantList;  
    
  
  User u =[select id from user where isactive = :true limit 1];
    
  Region__c reg1 = new Region__c();
  reg1.Name ='Barcelona';
  reg1.Country_Code__c = 'ES';
  reg1.Plant__c = plantList.get(0).Id;
  reg1.Bottler_External_Relations__c = u.Id;
  reg1.Bottler_Quality__c = u.Id;
  insert reg1;  
    
  Account acc = new Account();
  acc.firstName = 'testf';
  acc.lastName = 'testl';
  acc.Shipping_Municipality__c ='Sevilla' ; 
  acc.Country_Code__c = 'ES' ;
  acc.shipping_administrativearea__c ='Sevilla';
  acc.Shipping_Country__c ='Spain'; 
  acc.Shipping_Streetname1__c='Sevilla';
  acc.RecordTypeId = [Select Id From RecordType Where SobjectType = 'Account' and Name = 'Person'].Id;
  insert acc;
 
 
 Case c1 = new Case();
        c1.Reason ='Product Quality';
        c1.Category_Level3__c ='CARBONATION';
        C1.Category_Level4__c = 'Product flat on opening';
        c1.Origin = 'Phone';
        c1.Status = 'Open';
        c1.Potential_Risk__c = 'No Risk';
        c1.Priority = 'Medium';
        c1.Production_Code__c = 'B51111';
        c1.Description ='Test';
       
        c1.AccountId =  acc.Id;
        c1.Region_of_Purchase__c = reg1.Id;
        c1.Type_of_Gift__c ='Product';
        c1.Gift_Compensation__c = True;
        c1.Sample_Collected__c = True;
        
        c1.PoS_Key_Account__c = acc.Id;
        insert c1;  
    
    Task t1 = new Task();
        t1.subject = 'Enviar producto a los consumidores';
        t1.Status = 'In Progress';
        t1.Priority = 'Normal';
        t1.OwnerId = u.Id;
        t1.WhatId = c1.Id;
        insert t1;
     }
}