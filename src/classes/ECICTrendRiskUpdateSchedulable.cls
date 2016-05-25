global class ECICTrendRiskUpdateSchedulable implements Schedulable 
{  
    @testVisible private static final String JOB_NAME = 'TREND_RISK_UPDATE_BATCH_JOB';
    
    global void execute (SchedulableContext schedulableContext)
    {
        ECICTrendRiskUpdateBatchable updateBatchable = new ECICTrendRiskUpdateBatchable();
              database.executeBatch (updateBatchable);
                         
        SEPScheduleHelper.deleteJob(JOB_NAME);                                 
    }
    
    public static void scheduleJob() 
    { 
    	SEPScheduleHelper.scheduleJob(JOB_NAME, new ECICTrendRiskUpdateSchedulable()); 
    }   
}