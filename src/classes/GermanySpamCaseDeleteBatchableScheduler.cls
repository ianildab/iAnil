/*
Author : Aditya Bansod,Capgemini
Date : 7th May,2015
Purpose - Scheduler Class to execute the batch class for auto delete of Germany Spam Cases
*/

global class GermanySpamCaseDeleteBatchableScheduler implements Schedulable{
    
    global void execute(SchedulableContext Sc){
        try{
            CICGermanySpamCaseDeleteBatchable spamDeleteBatch = new CICGermanySpamCaseDeleteBatchable();
            Database.executeBatch(spamDeleteBatch);
        }
        
        catch(exception ex){
             System.debug('ERROR: ' + ex.getMessage() + '\nStack Trace:\n' + ex.getStackTraceString());
        }
    }

}