/**
 * Set field on quality complaint cases:
 *
 * Case.bottler_name__c by Case.bottler__c
 * Case.region_bottler_name__c by Case.region_of_purchase__c
 *
 */
public class ECICCaseQComplBottlerNameSetterStrategy extends ECICCaseProcessingStrategyAbstract {

    public override boolean OnBeforeInsert(List<sObject> newValues) {
        Case[] qualityComplaints = filterQualityComplaintCases((List<Case>)newValues);
        execute(null, qualityComplaints);

        return true;
    }

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        Case[] qualityComplaints = filterQualityComplaintCases((List<Case>)newValuesMap.values());
        execute((Map<ID, Case>)oldValuesMap, qualityComplaints);

        return true;
    }
    
    @testVisible private void execute(Map<ID, Case> oldCaseByIdMap, List<Case> newCasesList) 
    {
        List<Case> caseNeedsBottlerNameChangeList = buildCaseChangeList (oldCaseByIdMap, newCasesList, 'bottler__c',            'bottler_name__c'       );
        if (!caseNeedsBottlerNameChangeList.isEmpty()) { setBottlerNames(caseNeedsBottlerNameChangeList);      }
        
        List<Case> caseNeedsRegionNameChangeList  = buildCaseChangeList (oldCaseByIdMap, newCasesList, 'region_of_purchase__c', 'region_bottler_name__c');
        if (!caseNeedsRegionNameChangeList.isEmpty())  { setRegionBottlerNames(caseNeedsRegionNameChangeList); }
    }

    @testVisible private static List<Case> buildCaseChangeList (Map<ID, Case> oldCaseByIdMap, List<Case> newCasesList, String idField, String nameField)
    {
        List<Case> caseNeedsChangeList = new List<Case>();
        for (Case newCase : newCasesList) 
        {
        	Case oldCase = selectOldCase (oldCaseByIdMap, newCase.Id); 
            if (needsNameChange (newCase, oldCase, idField, nameField))        { caseNeedsChangeList.add(newCase); }
        }
        return caseNeedsChangeList;
    }

    @testVisible private static void setBottlerNames(List<Case> caseNeedsBottlerNameChangeList)
        {
            Map<Id, Account> bottlerbyIdMap = ECICCaseTriggerAccountCache.getBottlerAccountByByIdMap();
            for (Case currentCase : caseNeedsBottlerNameChangeList) 
            {
        	Account bottlerAccount = bottlerbyIdMap.get(currentCase.bottler__c);
        	if ( (bottlerAccount != null) && (bottlerAccount.Name != null) )
        	{
        		currentCase.bottler_name__c = bottlerAccount.Name.toUpperCase();
        	}
        	else
        	{
        		System.debug (LoggingLevel.ERROR, '!!!!!! Bottler Name can not be set for Case ' + ECICMapHelper.createMapIdentifier((SObject) currentCase, true) 
        		                                      + ' because Account ' + currentCase.bottler__c 
        		                                      + ' is not in the ECICCaseTriggerAccountCache.bottlerAccountByIdCache.');
        	}
        }
    }

    
    @testVisible private static void setRegionBottlerNames(List<Case> caseNeedsRegionNameChangeList)
        {
            Map<Id, Region__c> regionByIdMap = ECICCaseTriggerRegionCache.getRegionByIdMap();
            for (Case currentCase : caseNeedsRegionNameChangeList) 
            {
        	Region__c regionOfPurchase = regionByIdMap.get(currentCase.region_of_purchase__c);
            if ( (regionOfPurchase != null) && (regionOfPurchase.Bottler__r != null) && (regionOfPurchase.Bottler__r.Name != null) )
            {
                currentCase.region_bottler_name__c = regionOfPurchase.Bottler__r.Name.toUpperCase();
            }
            else
            {
                System.debug (LoggingLevel.ERROR, '!!!!!! Region Name can not be set for Case ' + ECICMapHelper.createMapIdentifier((SObject) currentCase, true) 
                                                      + ' because Region ' + currentCase.region_of_purchase__c 
                                                      + ' is not in the ECICCaseTriggerRegionCache.regionByIdCache.');
        }
    }
}
    
    public static Boolean needsNameChange (Case newCase, Case oldCase, String idField, String nameField)
    {
    	return  ( 
    				   (newCase.get(idField) != null) 
    				&& ( 
    						(newCase.get(nameField) == null) 
    					 || ( (oldCase != null) && (newCase.get(idField) != oldCase.get(idField)) ) 
    				   ) 
    			);
    }
    
	public static Case selectOldCase (Map<ID, Case> oldCaseByIdMap, Id currentCaseId)
	{
        return (oldCaseByIdMap != null) 
        		? oldCaseByIdMap.get(currentCaseId) 
        		: null;
	}
    
    
}