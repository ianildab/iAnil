/*
Author : Aditya Bansod,Capgemini
Date : 7th May,2015
Purpose - Batch Class to auto delete Germany Spam Cases.
*/
global class CICGermanySpamCaseDeleteBatchable implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<Group> caseQueue = [SELECT id, Name, DeveloperName, type FROM Group where DeveloperName = 'Germany_Spam' and type = 'Queue' LIMIT 1];
        String queueId = caseQueue.size() != 0 ? caseQueue[0].id : null;
        String caseQuery = 'SELECT id, accountId, contactId FROM case where Country_Code__c = \'DE\' AND ownerId = \'' + queueId + '\'';
        return Database.getQueryLocator(caseQuery);
    }
    
    global void execute(Database.BatchableContext BC,List<Case> listCasesDelete){
        Database.delete(listCasesDelete, false);
    }
    
    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = 
               [SELECT Id, Status, MethodName, NumberOfErrors, JobItemsProcessed,
                TotalJobItems, CreatedBy.Email
                FROM AsyncApexJob WHERE Id =
                :BC.getJobId()];
       General_Settings__c gs = General_Settings__c.getInstance();
       try{
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {gs.supportEmail__c};
       List<String> ccAddresses = new List<String>();
       List<Germany_Spam_Cases_Cleanup_Notify__c> deNotifyList = Germany_Spam_Cases_Cleanup_Notify__c.getAll().Values();
       for(Germany_Spam_Cases_Cleanup_Notify__c de : deNotifyList){
           ccAddresses.add(de.Email_Address__c);
       }
       mail.setToAddresses(toAddresses);
       mail.setCCAddresses(ccAddresses);
       mail.setSubject('Germany Spam Cases Clean up Status: ' + a.Status);
       String plainTextBody = 'The batch Apex job (job Id: ' + BC.getJobId() + ') for Germany Spam Cases Deletion has been processed ' + a.JobItemsProcessed  +
                              ' batches with '+ a.NumberOfErrors + ' failures.';
       mail.setPlainTextBody(plainTextBody);
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       }
       catch(Exception ex ){
           System.debug('ERROR: ' + ex.getMessage() + '\nStack Trace:\n' + ex.getStackTraceString());
       }
    }
}