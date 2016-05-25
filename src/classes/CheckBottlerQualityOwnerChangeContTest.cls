@isTest
public class CheckBottlerQualityOwnerChangeContTest {
    static testMethod void testBottlerQualityOwner(){
        Action_Plan__c act1 = new Action_Plan__c();
        act1.Name = 'Quality Complaint Action Plan1';
        act1.Active__c = True;
        act1.Rank__c = 144;
        act1.Country_Code__c = 'ES';
        insert act1;
        
        Action_Plan_Item__c actplanitem = new Action_Plan_Item__c();
        actplanitem.Name = 'Check Assignee Bottler';
        actplanitem.Active__c = True;
        actplanitem.Assignee__c ='Bottler_Quality_Owner__c';
        actplanitem.Action_Plan__c = act1.Id;
        actplanitem.Mode__c ='key';
        actplanitem.Priority__c = 'Normal';
        actplanitem.Task_Number__c = 20;
        insert actplanitem;
        
      
        
        Case c1 = new Case();
        c1.Reason ='Product Quality';
        c1.Category_Level3__c ='CARBONATION';
        C1.Category_Level4__c = 'Product flat on opening';
        c1.Origin = 'Phone';
        c1.Status = 'Open';
        c1.Potential_Risk__c = 'No Risk';
        c1.Priority = 'Medium';
        c1.Production_Code__c = 'B51111';
        c1.Action_Plan__c = act1.Id;
        c1.Description ='Test';
        insert c1;
        
        User u =[select id from user where isactive = :true limit 1];
        
        Task t1 = new Task();
        t1.subject = 'Check Assignee Bottler';
        t1.Status = 'In Progress';
        t1.Priority = 'Normal';
        t1.OwnerId = u.Id;
        t1.WhatId = c1.Id;
        insert t1;
        
       
        
        c1.Bottler_Quality_Owner__c = u.id;
        update c1;
        }
        }