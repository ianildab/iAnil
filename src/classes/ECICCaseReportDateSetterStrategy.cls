/**
 *    Update the Date of the Report field automatically by the system when the Quality agent starts to give the details of the quality report in the application
 */
public class ECICCaseReportDateSetterStrategy extends ECICCaseProcessingStrategyAbstract 
{
    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) 
    {
    	Map<ID, Case> oldCasesMap = (Map<ID, Case>)oldValuesMap;
    	Map<ID, Case> newCasesMap = (Map<ID, Case>)newValuesMap;

    	for (Case newCase : newCasesMap.values()) 
    	{
    		Case oldCase = oldCasesMap.get(newCase.id);
	        if (
	        		(oldCase.status == ECICCommonConstants.QUALITY_STATUS_PENDING_ON_QUALITY)
	           	 && (newCase.status != oldCase.status                                       )
	           ) 
	           {
	            newCase.Date_of_the_report__c = system.today();
	        }
    	}
    	return true;
    }
}