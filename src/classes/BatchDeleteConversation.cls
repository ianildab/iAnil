/*
Author - Poornima Padki,Capgemini
Date - 22th Oct,2014
Purpose - Batch Class for auto delete of Conversation Records
*/

global class BatchDeleteConversation implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
    String queryConv = '';
        if(Test.isRunningTest()){
            queryConv = 'SELECT Id, Name,sf4twitter__Case__c,sf4twitter__Account__c,sf4twitter__Contact__c FROM sf4twitter__Twitter_Conversation__c WHERE sf4twitter__Case__c = Null AND sf4twitter__Account__c = Null AND sf4twitter__Contact__c = Null LIMIT 1';            
        }
        else{
            queryConv = 'SELECT Id, Name,sf4twitter__Case__c,sf4twitter__Account__c,sf4twitter__Contact__c FROM sf4twitter__Twitter_Conversation__c WHERE Delete_Flag__c = True AND sf4twitter__Case__c = Null AND sf4twitter__Account__c = Null AND sf4twitter__Contact__c = Null';
        }
        return Database.getQueryLocator(queryConv);
    
    }
    
    global void execute(Database.BatchableContext BC,List<sf4twitter__Twitter_Conversation__c> listConv){
        List<sf4twitter__Twitter_Conversation__c> listChild = [SELECT Id,Name,sf4twitter__Parent__c FROM sf4twitter__Twitter_Conversation__c WHERE sf4twitter__Parent__c IN: listCONV];
        //Set<sf4twitter__Twitter_Conversation__c> setChild = new Set<sf4twitter__Twitter_Conversation__c>([SELECT Id,Name FROM sf4twitter__Twitter_Conversation__c WHERE sf4twitter__Parent__c IN: listCONV]);
        Set<Id> parentSet = new Set<Id>();
        List<sf4twitter__Twitter_Conversation__c> delList = new List<sf4twitter__Twitter_Conversation__c>();
        for(sf4twitter__Twitter_Conversation__c chConv:listChild){
            parentSet.add(chConv.sf4twitter__Parent__c);
        }
        for(sf4twitter__Twitter_Conversation__c delConv:listConv){
            if(parentSet.contains(delConv.Id)){
                //sf4twitter__Twitter_Conversation__c removed = listConv.remove(delConv);
                boolean SetParent = true;
            }
            else{
                delList.add(delConv);
            }    
        }
        if(delList.size() > 0){
            delete delList;
            DataBase.emptyRecycleBin(delList);
        }
    
    }
    
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = 
               [SELECT Id, Status, MethodName, NumberOfErrors, JobItemsProcessed,
                TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob WHERE Id =
                :BC.getJobId()];
                          
       // Send an email to the Apex job's submitter        //   notifying of job completion. 
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {'pawel.marszalek@capgemini.com'};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Conversation Clean Up Status: ' + a.Status);
       mail.setPlainTextBody
       ('The batch Apex job for Conversation Deletion has processed ' + a.JobItemsProcessed  +
       ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

    
    }



}