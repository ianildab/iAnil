/*
Author : Aditya Bansod,Capgemini
Date : 1st June,2015
Purpose - Scheduler Class to execute the batch class to update trends to inactive if latest case association is more than 14 days.
*/

global class CICActiveTrendUpdateBatchableSchedular implements Schedulable{
    
    global void execute(SchedulableContext Sc){
        try{
            CICActiveTrendUpdateBatchable updateTrendsBatch = new CICActiveTrendUpdateBatchable();
            Database.executeBatch(updateTrendsBatch);
        }
        
        catch(exception ex){
             System.debug('ERROR: ' + ex.getMessage() + '\nStack Trace:\n' + ex.getStackTraceString());
        }
    }

}