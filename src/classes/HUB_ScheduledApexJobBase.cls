/*** Author,email : Aldrin Rasdas , arasdas@coca-cola.com
* Date Create : May 28, 2013
* Description : An abstract class where mosf of the scheduled apex used in hub notification is based
*
* REVISION HISTORY
*
* Author,email :
* Date Revised :
* Description :
*
*
* FOR HUB 1.2
*/
public abstract class HUB_ScheduledApexJobBase {
        
    private List<HUB_JobLog__c> logs;
    private HUB_JobLog__c log;
        
    public HUB_ScheduledApexJobBase(String jobCode) {
        this.logs = [select Job_Code__c, First_Run__c,Last_Run__c from HUB_JobLog__c where Job_Code__c=:jobCode limit 1];
        if (logs.size()>0) {
            log = logs[0];
        }
        if (this.log==null) {
            this.log = new HUB_JobLog__c();
            log.Job_Code__c = jobCode;
            log.First_Run__c = System.now();
            log.Last_Run__c = System.now().addDays(-7); //go back 7days
        }
                
    }
    
    public Datetime lastRun {get {return log.Last_Run__c;}}
    public Datetime firstRun {get {return log.First_Run__c;}}
        
    protected void finalize() {
        log.Last_Run__c = System.now();
        upsert this.log;
    }
    
}