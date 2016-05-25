/*
Created By: Vikesh Gajula
Created On: 26/04/2016
Description: This class is used to log the details of error occured during execution of code.
*/

public class ErrorLogHelper
{
    public static void LogError(string requestData, string errorDescription)
    {
        try
        {
            Error_Log__c objError = new Error_Log__c();
            objError.RequestData__c = requestData;
            objError.Error_Description__c = errorDescription;
            insert objError;
        }
        catch(Exception ex)
        {
            System.debug('Error logging failed: ' + ex.getMessage());
        }
    }
}