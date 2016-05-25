@isTest
// @see http://salesforce.stackexchange.com/questions/15003/scheduled-job-does-not-execute-though-shows-in-gui
public class TEST_ScheduleHelper 
{
    public static String convertDateTimeToCronExpression(datetime thisTime)
    {
        Integer year      = thisTime.year(); 
        Integer month     = thisTime.month(); 
        Integer day       = thisTime.day(); 
        Integer hour      = thisTime.hour(); 
        Integer minute    = thisTime.minute(); 
        Integer second    = thisTime.second(); 
        return second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
    } 

     // This section of code will actually schedule the next execution 1 minute from now because "now" will be in the past and cause an Exception. 
    public static String getNowCronString() { return convertDateTimeToCronExpression(system.now().addMinutes(1)); }
}