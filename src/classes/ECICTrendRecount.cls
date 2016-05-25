public class ECICTrendRecount 
{
	@testVisible private Set<Id> 			 trendIdSet				 = null;
    @testVisible private Map<Id, Trend__c> 	 closeUpdateTrendByIdMap = null;
	@testVisible private Map<Id, List<Case>> caseByTrendIdMap    = new Map<Id, List<Case>>();
	@testVisible private Map<Id, List<Case>> closedCaseByTrendIdMap  = new Map<Id, List<Case>>();
	@testVisible private List<Trend__c> 	 trendsToUpdateList		 = new List<Trend__c>();
	
	public ECICTrendRecount(Set<Id> trendIdSet)
	{
		this.trendIdSet = trendIdSet;
		selectTrends();
		filterTrendCaseListMapsByClosedStatus();
		doRecount();
	}
	
	@testVisible private void selectTrends()
	{
		closeUpdateTrendByIdMap = new Map<Id, Trend__c>([
														SELECT id, (SELECT id, isClosed, status FROM Cases__r) 
														FROM Trend__c 
									        			WHERE id IN :this.trendIdSet
									        		]);		
	}
	
	@testVisible private void filterTrendCaseListMapsByClosedStatus()
	{
		for (Id trendId : closeUpdateTrendByIdMap.keySet())
		{
			List<Case> caseList   = new List<Case>();
			List<Case> closedCaseList = new List<Case>();
			for (Case trendCase : closeUpdateTrendByIdMap.get(trendId).cases__r)
			{
				caseList.add(trendCase);  
				if (trendCase.status == ECICCommonConstants.STATUS_CLOSED)	{ closedCaseList.add(trendCase); }
				// else (e.g. if cancelled), we ignore to Case.
			}

			caseByTrendIdMap.put  (trendId, caseList);
			closedCaseByTrendIdMap.put(trendId, closedCaseList);
		}
	}
	
	@testVisible private void doRecount()
	{
		Boolean recountRequired = !caseByTrendIdMap.isEmpty();
        if (recountRequired) 
        {
	        for (Id trendId : caseByTrendIdMap.keySet() ) 
	        {
	        	Trend__c trend = closeUpdateTrendByIdMap.get(trendId);
	        			 trend.CaseCount__c       = caseByTrendIdMap.get(trendId).size();
	        			 trend.closedCaseCount__c = closedCaseByTrendIdMap.get(trendId).size();
	        	trendsToUpdateList.add(trend);
	        }
        }
	}
	
	public void updateTrends()
	{
		if (!trendsToUpdateList.isEmpty())
		{
			update trendsToUpdateList;
		}
	}
	
}