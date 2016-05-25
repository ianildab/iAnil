public class ECICTrendMap 
{
	@testVisible private Map<String, List<Case>> casesWithNewTrendsListByTrendKeyMap = new Map<String, List<Case>>();
    @testVisible private Map<String, Trend__c>   newTrendByKeyMap 				 = new Map<String, Trend__c>();
    @testVisible private Map<String, List<Case>> caseMayRequireNewTrendByTrendKeyMap    = new Map<String, List<Case>>(); // CaseList should already only have one trendKey, but we are erring on the side of caution.
                 public  static Set<Id>          trendWithUpdateIdSet                = new Set<Id>(); 
    
    public ECICTrendMap(Map<String, List<Case>> groupedCaseListByTrendKeyMap, Map<String, List<Trend__c>> trendListByKeyMap)
    {
        for (String key : groupedCaseListByTrendKeyMap.keySet()) 
        {

            List<Case> caseList = groupedCaseListByTrendKeyMap.get(key);

            if (trendListByKeyMap.containsKey(key)) 
            {
                Map<String, Trend__c> trendByCaseStringIdentifierMap = buildTrendByCaseStringIdentifierMap(caseList, trendListByKeyMap.get(key));

				if (!trendByCaseStringIdentifierMap.isEmpty()) { ECICTrendHelper.attachTrendsToCases(caseList, trendByCaseStringIdentifierMap); }  
            }
            else { addToPotentialTrendMap (key, caseList); }
            
            List<Case> potentTrendCaseList = caseMayRequireNewTrendByTrendKeyMap.get(key);
            if ((potentTrendCaseList != null) && (potentTrendCaseList.size() > 1)) { mapCaseListToTrendKey(key, potentTrendCaseList); }
        }
    }
    
    @testVisible private void addToPotentialTrendMap (String key, List<Case> caseList)
    {
        if (!caseMayRequireNewTrendByTrendKeyMap.containsKey(key))
        {
            caseMayRequireNewTrendByTrendKeyMap.put(key, new List<Case>()); 
        }
        caseMayRequireNewTrendByTrendKeyMap.get(key).addAll(caseList);
    }
    
    @testVisible private void addToPotentialTrendMap (String key, Case currentCase)
    {
    	addToPotentialTrendMap (key, new List<Case>{ currentCase });
    }
    
    
    @testVisible private Map<String, Trend__c> buildTrendByCaseStringIdentifierMap(List<Case> caseList, List<Trend__c> keyTrendList)
	{
        Map<String, Trend__c> trendByCaseStringIdentifierMap = new Map<String, Trend__c>();
        
        for (Case currentCase : caseList) 
        {
			Trend__c resultTrend = selectResultTrend(currentCase, keyTrendList);

			if (resultTrend != null) 
			{ 
            	trendByCaseStringIdentifierMap.put(ECICMapHelper.createMapIdentifier(currentCase, true), resultTrend);
            	trendWithUpdateIdSet.add(resultTrend.id);   
		}
            else                     { addToPotentialTrendMap (currentCase.trend_key__c, currentCase);                                                                  }                     
		}

    	return trendByCaseStringIdentifierMap;
    }

    @testVisible private Trend__c selectResultTrend(Case currentCase, List<Trend__c> keyTrendList)
    {
        if (currentCase.trend_mark__c == null) 					{ return keyTrendList[0]; }

        for (Trend__c trend : keyTrendList) 
        {
            if (currentCase.trend_mark__c < trend.createdDate)  { return trend; }    
        }    
        
        return null;
    }

    // This method is static and the last two parameters are passed to fascilitate unit testing.
    @testVisible private Trend__c mapCaseListToTrendKey(String key, List<Case> caseList)
    {
        String[] paramArray = key.split(ECICTrendHelper.KEY_DELIMITER, 0);                 
        Trend__c trend = ECICTrendHelper.createTrend(Date.valueof(paramArray[1]), paramArray[2], paramArray[3], paramArray[0]); 
        
        this.casesWithNewTrendsListByTrendKeyMap.put(key, caseList);
        this.newTrendByKeyMap.put(key, trend);    

        return trend;
    }

   	// -----------------------------------------------------------------------------------------------------------------
   	
   	public void upsertTrends()
   	{
        ECICTrendHelper.upsertTrends(trendWithUpdateIdSet, this.newTrendByKeyMap.values());
	}

    public void attachTrendToCasesToCases ()
    {
        for (String key : this.newTrendByKeyMap.keySet()) 
        {
            for (Case currentCase : this.casesWithNewTrendsListByTrendKeyMap.get(key)) 
            {
            	ECICTrendHelper.attachTrendToCase(currentCase, this.newTrendByKeyMap.get(key));
            }
        }
    }
}