global class ECICOpenAlertCaseUpdateSchedulable implements Schedulable 
{
     @testVisible private static final String JOB_NAME = 'OPEN_ALERT_CASE_UPDATE_BATCH_JOB';
	
    global void execute (SchedulableContext schedulableContext)
    {
        ECICOpenAlertCaseUpdateBatchable updateBatchable = new ECICOpenAlertCaseUpdateBatchable();
                         database.executeBatch (updateBatchable);
                         
        SEPScheduleHelper.deleteJob(JOB_NAME);                                 
    }
    
    public static void scheduleJob() { SEPScheduleHelper.scheduleJob(JOB_NAME, new ECICOpenAlertCaseUpdateSchedulable()); }   
}