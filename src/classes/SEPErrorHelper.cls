public class SEPErrorHelper 
{
	public static void addError (SObject currentSObject, String message, Boolean addToLog)
	{
		currentSObject.addError(message);
		if (addToLog) { System.debug (LoggingLevel.ERROR, '!!!!!!!!! ' + message); }
		
		if (Test.isRunningTest())
		{
			// NOTE: ECICMapHelper.createMapIdentifier currently only fully supports Case, Trend and Task!!!
			TEST_MockHelper.setMockString(currentSObject, 'error', message);
		}
	}

    public static void logErrors(String sObjectName, String contextMessage, List<Database.SaveResult> dataBaseSaveResultList, LoggingLevel loggingLevel)
    {
        String errorMessage = '';
        for (Database.SaveResult saveResult : dataBaseSaveResultList) 
        {
            if (! saveResult.isSuccess()) 
            {
                errorMessage += sObjectName + ' ['+saveResult.getId()+'] Errors: ';
                for (Database.Error error : saveResult.getErrors()) { errorMessage += error.getMessage() + ' '; }
            }
        }
        
        if (errorMessage.length() > 0) { System.debug(loggingLevel, '!!!!!!!!! ' + contextMessage + ': '+errorMessage); }
    }

	
	public static void logErrors(String sObjectName, String contextMessage, List<Database.SaveResult> dataBaseSaveResultList)
	{
		logErrors (sObjectName, contextMessage, dataBaseSaveResultList, LoggingLevel.ERROR);
	}
}