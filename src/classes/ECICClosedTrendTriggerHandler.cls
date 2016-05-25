public class ECICClosedTrendTriggerHandler extends SEPTriggerHandlerAbstract 
{
    public ECICClosedTrendTriggerHandler(boolean isTriggerExecuting) { super(isTriggerExecuting); }

    // ---------------------------------------------------------------------------------------------------
    
    public override void OnBeforeInsert(List<sObject> newValueSObjectList) 
    {
        processBefore((Closed_Trend__c[])newValueSObjectList, null);
    }

    public override void OnBeforeUpdate(List<sObject> oldValueSObjectList, List<sObject> newValueSObjectList, Map<Id, sObject> oldValueSObjectByIdMap, Map<Id, sObject> newValueSObjectByIdMap) 
    {
        processBefore((Closed_Trend__c[])newValueSObjectList, (Map<ID, Closed_Trend__c>)oldValueSObjectByIdMap);
    }
    
    // ---------------------------------------------------------------------------------------------------

    @testVisible private void processBefore(List<Closed_Trend__c> newClosedTrendList, Map<Id, Closed_Trend__c> oldClosedTrendByIdMap)
    {
        for (Closed_Trend__c newClosedTrend : newClosedTrendList) 
        {
        	Closed_Trend__c oldClosedTrend = (oldClosedTrendByIdMap != null) ? oldClosedTrendByIdMap.get(newClosedTrend.id) : null;
        	
        	if ((oldClosedTrend == null) || (newClosedTrend.country_code__c != oldClosedTrend.country_code__c))
	        {
	            newClosedTrend.country_code_string__c = newClosedTrend.country_code__c;
	        }
        }
    }
}