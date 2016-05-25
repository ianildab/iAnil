/** 
 *    ECIC-61 Trend tracking
 *
 * 	DEFINITION:
 *  Triplet: The combination of three Case fields:
 *				1. Product__c
 *				2. Production_Line__c
 *				3. BBE_Date__c
 **/
public class ECICTrendTracker 
{
    public static void onBefore(List<Case> newCaseList, List<Case> oldCaseList,  Map<ID, Case> newCaseByIdMap, Map<ID, Case> oldCaseByIdMap) 
    {
        Set<String> trendKeySet = new Set<String>();
        for (Case newCase : newCaseList) 
        {
          Case oldCase = ((newCase.id != null) && (oldCaseByIdMap != null) && (oldCaseByIdMap.containsKey(newCase.id)))? oldCaseByIdMap.get(newCase.id) : null;

			//delete trend link if one of the triplet values was cleared
			Boolean isResetTrendAttributesRequired = ECICTrendHelper.isResetTrendAttributesRequired(oldCase, newCase);
			if (isResetTrendAttributesRequired)  
			{ 
				ECICTrendHelper.resetTrendAttributes(newCase); 
			}
			else if (ECICTrendHelper.isTrendRemoved(oldCase, newCase))             
			{ 
				ECICTrendHelper.resetRiskAttributes(newCase);  
			}

            Boolean isNewTrendKeyRequired = ECICTrendHelper.isNewTrendKeyRequired(oldCase, newCase); 
      		if (isNewTrendKeyRequired)
      		{
	            newCase.trend_Key__c = ECICTrendHelper.getTrendKey(newCase.BBE_date__c, newCase.Production_Line__c, newCase.Product__c, newCase.country_code__c);
            trendKeySet.add(newCase.trend_Key__c); 
        }
        }
        if (!trendKeySet.isEmpty()) { processUnresolvedTrends(trendKeySet, newCaseList, newCaseByIdMap); }	// invokes SOQL (2x) and DML (2x)
    }
        
    
    @testVisible private static void processUnresolvedTrends(Set<String> trendKeySet, List<Case> newCaseList, Map<Id, Case> newCaseByIdMap)
    {
            List<Trend__c> trendList = selectTrendList(trendKeySet);									// invokes SOQL
            Map<String, List<Trend__C>> trendListByKeyMap = new Map<String, List<Trend__C>>();
            ECICTrendHelper.groupObjectsByTrendKey(trendList, trendListByKeyMap);

            Set<Id> caseIdSet = (newCaseByIdMap == null) ? (new Set<Id>()) : (newCaseByIdMap.keySet());
            List<Case> otherTrendCaseList = selectOtherTrendCaseList (caseIdSet, trendKeySet);					// invokes SOQL to select Cases not from Trigger

            Map<String, List<Case>> groupedCaseListByTrendKeyMap = ECICTrendHelper.buildGroupedCaseListsByTrendKeyMap(
                                                                         new List<List<Case>>{ newCaseList, otherTrendCaseList } 
                                                                      );
            
        if  (   (groupedCaseListByTrendKeyMap != null) && (!groupedCaseListByTrendKeyMap.isEmpty()) ) 
        {
            ECICTrendMap newTrendMaps = new ECICTrendMap(groupedCaseListByTrendKeyMap, trendListByKeyMap);
                         newTrendMaps.upsertTrends();
            			 newTrendMaps.attachTrendToCasesToCases();											    // invokes DML
        }
        else if (!ECICTrendMap.trendWithUpdateIdSet.isEmpty()) { ECICTrendHelper.upsertTrends(ECICTrendMap.trendWithUpdateIdSet, null); }

            if (!otherTrendCaseList.isEmpty()) { updateOtherTrendCaseList(otherTrendCaseList); }                // invokes DML to update Cases not from Trigger
    }

    // -----------------------------------------------------------------------------------------------------------------

	@testVisible private static List<Trend__c> selectTrendList(Set<String> trendKeySet)
	{
		return  [
					SELECT id, trend_key__c, createdDate, caseCount__c 
					FROM Trend__c 
	            	WHERE (trend_key__c IN :trendKeySet) 
	            	ORDER BY createdDate ASC
                                         ];
	} 

	@testVisible private static List<Case> selectOtherTrendCaseList (Set<Id> caseIdSet, Set<String> trendKeySet)
	{
		return [
					 SELECT id, trend_key__c, trend_mark__c 
					 FROM Case 
                     WHERE (id NOT IN :caseIdSet)  
                        AND (status != :ECICCommonConstants.STATUS_CANCELLED)
                        AND (trend_key__c in :trendKeySet) 
                        AND (trend__c = null)
                 ];
	}
	
    @testVisible private static void updateOtherTrendCaseList(List<Case> caseList)
    {
    	for (Case currentCase : caseList)  { currentCase.No_Quality_Status_Change__c = true; }
        update caseList;
    }
	
    // ------------------------------------------------------------------------------------------------------
    
    public static void onAfter(List<Case> newCaseList, List<Case> oldCaseList,  Map<ID, Case> newCaseByIdMap, Map<ID, Case> oldCaseByIdMap)
    {
        Set<Id> trendIdSet = new Set<Id>();
        for (Case newCase : newCaseByIdMap.values()) 
    {
          Case oldCase = ((newCase.id != null) && (oldCaseByIdMap != null) && (oldCaseByIdMap.containsKey(newCase.id)))? oldCaseByIdMap.get(newCase.id) : null;

        	if (  (oldCase != null) && (oldCase.trend__c != null)  )  { trendIdSet.add(oldCase.trend__c);  }
            if (                        newCase.trend__c != null   )  { trendIdSet.add(newCase.trend__c);  }
        }
        if (!trendIdSet.isEmpty()) { recountTrends (trendIdSet); }
    }
 
	@testVisible private static void recountTrends (Set<Id> trendIdSet)
        	{
		ECICTrendRecount trendRecount = new ECICTrendRecount(trendIdSet);							// invokes SOQL
    					 trendRecount.updateTrends();												// invokes DML
	}
        }