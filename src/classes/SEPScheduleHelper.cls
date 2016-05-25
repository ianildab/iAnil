public class SEPScheduleHelper 
{
    public static String convertDateTimeToCronExpression(Datetime thisTime)
    {
        Integer year      = thisTime.year(); 
        Integer month     = thisTime.month(); 
        Integer day       = thisTime.day(); 
        Integer hour      = thisTime.hour(); 
        Integer minute    = thisTime.minute(); 
        Integer second    = thisTime.second(); 
        return second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
    } 

    public static String getNowString() { return  convertDateTimeToCronExpression(System.now().addMinutes(1)); }

    public static void scheduleJob(String jobName, Schedulable schedulableClass)  
    {
        if (!(SEPScheduleHelper.isScheduledJob(jobName)))
        {
            try
            {
                System.Schedule ( 
                                    jobName, 
                                    getNowString() + ' ' + jobName,  // We add the jobName to the cronExpress so we can find it again.  See http://salesforce.stackexchange.com/questions/374/linking-crontrigger-sobjects-to-scheduled-jobs-listings  
                                    schedulableClass
                                 );
            }
            catch (AsyncException ex) {}                       // Nothing to do here; this is just a backup if isScheduledBatchJob() fails. 
        }
    }
    
    @testVisible private static Boolean isScheduledJob(String jobName)    
    {
        List<CronTrigger> cronTriggerList = [SELECT id FROM CronTrigger WHERE cronExpression LIKE :('% ' + jobName)];
        return (cronTriggerList.size() > 0); 
    }
    
    public static void deleteJob(String jobName)  
    {
        CronTrigger cronTrigger = [SELECT id FROM CronTrigger WHERE cronExpression LIKE :('% ' + jobName) LIMIT 1];
        System.abortJob(cronTrigger.id);
    }    
     

}