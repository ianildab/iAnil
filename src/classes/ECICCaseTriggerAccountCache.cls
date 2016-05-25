public class ECICCaseTriggerAccountCache 
{
	@testVisible private static Map<Id, Account> regionAccountByIdCache = new Map<Id, Account>(); 
	public  static Map<Id, Account> getRegionAccountByIdMap() { return regionAccountByIdCache; }
	
	@testVisible private static Map<Id, Account> bottlerAccountByIdCache = new Map<Id, Account>(); 
	public  static Map<Id, Account> getBottlerAccountByByIdMap() { return bottlerAccountByIdCache; }
	
	public static void populate (List<Case> currentCaseList, Map<ID, Case> oldCaseByIdMap)
	{
		Set<Id> regionAccountIdSet 	= selectRegionAccountIdSet  (currentCaseList, oldCaseByIdMap);
		Set<Id> bottlerAccountIdSet = selectBottlerAccountIdSet (currentCaseList);
		
		Map<Id, Account> accountByIdMap = new Map<Id,Account>([
																		SELECT Name, Region__c, Parent.Name 
																		FROM Account 
																		WHERE (
																			   (id IN :regionAccountIdSet)
																	        OR (id IN :bottlerAccountIdSet)
																	      )
																	]);
																	
		regionAccountByIdCache.putAll(  buildAccountIdCache (accountByIdMap, regionAccountIdSet)  );
		bottlerAccountByIdCache.putAll( buildAccountIdCache (accountByIdMap, bottlerAccountIdSet) );
	}
	
	@testVisible private static Map<Id, Account> buildAccountIdCache (Map<Id, Account> completeAccountByIdMap, Set<Id> accountIdSet)
	{
		Map<Id, Account> partialAccountByIdMap = new Map<Id, Account>();
		for (Id accountId : accountIdSet)
		{
			if (completeAccountByIdMap.containsKey(accountId)) { partialAccountByIdMap.put(accountId, completeAccountByIdMap.get(accountId)); }
		}
		return partialAccountByIdMap;
	}
    
    @testVisible private static Set<Id> selectRegionAccountIdSet (List<Case> currentCaseList, Map<ID, Case> oldCaseByIdMap) 
    {
    	Set<Id> regionAccountIdSet = new Set<Id>();
        for (Case currentCase : currentCaseList) 
        {
            regionAccountIdSet.add(currentCase.Point_of_Sale__c);
            regionAccountIdSet.add(currentCase.PoS_Key_Account__c);

            Case oldCase = ECICCaseQComplBottlerNameSetterStrategy.selectOldCase (oldCaseByIdMap, currentCase.Id);
            if (oldCase != null) { regionAccountIdSet.add(oldCase.PoS_Key_Account__c); }
        }
    	return regionAccountIdSet;
    }

	// TODO: Optimize this: we shouldn't need so much data.
	// @see CIC-1114
    @testVisible private static Set<Id> selectBottlerAccountIdSet (List<Case> currentCaseList) 
    {
    	Set<Id> bottlerAccountIdSet = new Set<Id>();
    	
        addBottlerToIdSet(bottlerAccountIdSet, currentCaseList);
    	addBottlerToIdSet(bottlerAccountIdSet, ECICCaseTriggerRegionCache.getRegionByIdMap().values());
        addBottlerToIdSet(bottlerAccountIdSet, ECICCaseTriggerPlantCache.getPlantIdMap().values());

    	return bottlerAccountIdSet;
    }
    
    @testVisible private static void addBottlerToIdSet(Set<Id> idSet, List<SObject> sobjectList)
    {
        if ((sobjectList != null) && (!sobjectList.isEmpty()))
        {
            for (SObject currentSObject : sobjectList)  
            { 
            	Id bottlerId = null;
            	
            	/** FIXME: Workaround for seemingly nonsensical assertion that field has not been queried. This could be dangerous!!!! **/
            	try { bottlerId = (currentSObject != null) ? (Id) currentSObject.get('bottler__c') : null; }
            	catch (SObjectException e)
            	{
            		// Intential capture
            		System.debug (LoggingLevel.WARN, '!!!!!!!!!!!!!!!! Bottler not queried for : ' + currentSObject);
            	}
            	
                if (bottlerId != null) {  idSet.add(bottlerId); }
            } 
        }
    }
}