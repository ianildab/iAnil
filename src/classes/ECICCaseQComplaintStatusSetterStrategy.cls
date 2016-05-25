/**
 * Set Case.quality_status__c to 'New' at insert/update on quality cases
 */
public class ECICCaseQComplaintStatusSetterStrategy extends ECICCaseProcessingStrategyAbstract {

    public override boolean OnBeforeInsert(List<sObject> newValues) 
    {
        setCaseQualityStatusToNew((List<Case>)newValues, null);
        return true;
    }

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        setCaseQualityStatusToNew(((Map<ID, Case>)newValuesMap).values(), (Map<ID, Case>)oldValuesMap);
        return true;
    }

    @testVisible private void setCaseQualityStatusToNew(List<Case> newCaseList, Map<ID, Case> oldCaseByIdMap) 
    {
    	for (Case currentCase : newCaseList) 
    	{
            if (statusRequiresReset (currentCase, oldCaseByIdMap))
    		{
    		currentCase.quality_status__c = ECICCommonConstants.QUALITY_STATUS_NEW_COMPLAINT;    
        }           
    }
}
    
    @testVisible private Boolean statusRequiresReset (Case currentCase, Map<Id, Case> oldCaseByIdMap)
    {
        Set<String> closedStatusSet  = new Set<String>{ ECICCommonConstants.STATUS_CLOSED, ECICCommonConstants.STATUS_CANCELLED };
        
    	return        ( ECICCaseQualityComplaintRecordTypeHelper.isQualityComplaint(currentCase.recordTypeID)          ) 
                   && ( (oldCaseByIdMap == null) || ( currentCase.reason != oldCaseByIdMap.get(currentCase.id).reason) )
                   && ( !(closedStatusSet.contains(currentCase.status))                                                ) 
                   && ( currentCase.quality_status__c == null                                                          );
    }
}