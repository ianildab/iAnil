global class ECICOpenAlertExpirationWarningSched implements Schedulable
{
    global void execute (SchedulableContext schedulableContext)
    {
    	ECICOpenAlertExpirationWarningBatchable warningBatchable = new ECICOpenAlertExpirationWarningBatchable();
                      	 database.executeBatch (warningBatchable);
    }
}