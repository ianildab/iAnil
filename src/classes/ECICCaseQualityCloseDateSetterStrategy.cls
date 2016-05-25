/**
 *    ECIC-2092: Quality Closed date is the date when the Quality Status is set to Closed
 */
public class ECICCaseQualityCloseDateSetterStrategy extends ECICCaseProcessingStrategyAbstract 
{

    public override boolean OnBeforeInsert(List<sObject> newValues) 
    {
    	execute ((List<Case>)newValues, null);
        return true;
    }

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) 
    {
        execute ((List<Case>)(newValuesMap.values()), (Map<ID, Case>)oldValuesMap);
        return true;
    }
    
    @testVisible private void execute (List<Case> newCaseList, Map<Id, Case> oldCaseByIdMap)
    {
        for (Case newCase : newCaseList) 
        {
        	Case oldCase = (oldCaseByIdMap != null) ? oldCaseByIdMap.get(newCase.id) : null;
            if (
                    (newCase.quality_status__c == ECICCommonConstants.STATUS_CLOSED) 
                 && ((oldCase == null) || (newCase.quality_status__c != oldCase.quality_status__c))
               )
            {
                newCase.Quality_Close_Date__c = system.today();        
            }
        }
    }
}