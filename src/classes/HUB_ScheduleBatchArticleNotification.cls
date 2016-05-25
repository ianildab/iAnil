global class HUB_ScheduleBatchArticleNotification implements Schedulable
{
	global void execute(SchedulableContext SC)
	{
		HUB_Batch_Article_Notification batch = new HUB_Batch_Article_Notification();
		database.executeBatch(batch);
	}
}