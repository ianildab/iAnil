public class ECICCaseTriggerStrategyConfigException extends Exception  
{
	public String errorMessage     = null;
	
	public ECICCaseTriggerStrategyConfigException (List<String> errorLogList)
	{
		this.errorMessage = 'The Case_Trigger_Strategy_Configuration__c records contain'
							+ (
								 (errorLogList.size() == 1)
								 	? 's the following error'
								 	: ' the following' + errorLogList.size() + 'errors'
							  )
							+ ': ';
		
		for (Integer i=1; i <= errorLogList.size(); i++) 
		{
			this.errorMessage 		+= i + '. ' + errorLogList[i-1];
		}
		
		SEPEmailSendHelper.sendNotificationMail (
					General_Settings__c.getInstance().supportEmail__c, 
					'[Strategy Factory] Case_Trigger_Strategy_Configuration__c Record Errors', 
					this.errorMessage
			);
	}
}