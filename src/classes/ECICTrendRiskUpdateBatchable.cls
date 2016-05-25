global class ECICTrendRiskUpdateBatchable implements Database.Batchable<SObject>
{
    global final String BATCHABLE_QUERY =       ' SELECT id ' 
                                              + ' FROM Trend__c ' 
                                              + ' WHERE recheck_potential_risk__c = true ';
    
    global Database.QueryLocator start(Database.BatchableContext batchableContext) { return Database.getQueryLocator(BATCHABLE_QUERY);  }
    
    global void execute(Database.BatchableContext batchableContext, List<SObject> sObjectList) { execute (sObjectList); }
    
    @testVisible private static void execute(List<Trend__c> trendList) 
    {
        Set<Id>             trendIdSet           = buildTrendIdSet (trendList);
        List<Case>          caseList             = [SELECT id, trend__c, potential_risk__c, risk_type__c, The3rdComplaint__c FROM Case WHERE trend__c IN :trendIdSet];
        Map<Id, List<Case>> caseListByTrendIdMap = buildCaseListByTrendIdMap(trendIdSet, caseList);

        List<Case> updateCaseList   = new List<Case>();
        Set<Id>    deleteTrendIdSet = new Set<Id>();
        for (Id trendId : caseListByTrendIdMap.keySet()) { caseListUpdate (trendId, caseListByTrendIdMap.get(trendId), updateCaseList, deleteTrendIdSet); }
        update updateCaseList;

        List<Trend__c> updateTrendList = new List<Trend__c>();
        List<Trend__c> deleteTrendList = new List<Trend__c>();
        for (Trend__c trend : trendList)
        {
            if (deleteTrendIdSet.contains(trend.id)) { deleteTrendList.add(trend); }
            else
            {
                trend.recheck_potential_risk__c = false; 
                updateTrendList.add(trend); 
            }
        }
        update updateTrendList;
        delete deleteTrendList;
    }

    @testVisible private static void caseListUpdate (Id trendId, List<Case> caseList, List<Case> updateCaseList, Set<Id> deleteTrendIdSet)
    {
            Integer    caseListSize = caseList.size();
            if      (caseListSize <  2) { noTrendCaseListUpdate        (caseList, updateCaseList, trendId, deleteTrendIdSet); }
            else if (caseListSize == 2) { potentialTrendCaseListUpdate (caseList, updateCaseList);                            }
            else                        { riskTrendCaseListUpdate      (caseList, updateCaseList);                            }
    }

    @testVisible private static void noTrendCaseListUpdate (List<Case> caseList, List<Case> updateCaseList, Id trendId, Set<Id> deleteTrendIdSet)
    {
        deleteTrendIdSet.add(trendId);
        if (!caseList.isEmpty()) 
        { 
            for (Case currentCase : caseList) 
            { 
                currentCase.trend__c = null; 
                updateCaseList.add(currentCase);
            }
        }
    }

    @testVisible private static void potentialTrendCaseListUpdate (List<Case> caseList, List<Case> updateCaseList)
    {
        for (Case currentCase : caseList) 
        { 
            if (currentCase.The3rdComplaint__c)
            {
                ECICTrendHelper.resetRiskAttributes(currentCase);
                updateCaseList.add(currentCase);
            }
        }
    }

    @testVisible private static void riskTrendCaseListUpdate (List<Case> caseList, List<Case> updateCaseList)
    {
        Boolean hasRisk = false; 
        for (Case currentCase : caseList) 
        { 
            if (currentCase.The3rdComplaint__c) { hasRisk = true; break; }
        }
        
        if (!hasRisk)
        {
            Case currentCase = caseList[0];      // Which Case is arbitrary, as long as there is one and only one.
            ECICTrendHelper.setRiskAttributes(currentCase);
            updateCaseList.add(currentCase);
        }
    }

    @testVisible private static Set<Id> buildTrendIdSet (List<Trend__c> trendList)
    {
        Set<Id> trendIdSet = new Set<Id>();
        for (Trend__c trend : trendList)  {  trendIdSet.add(trend.id); }
        return trendIdSet;
    }
    
    @testVisible private static Map<Id, List<Case>> buildCaseListByTrendIdMap(Set<Id> trendIdSet, List<Case> caseList)
    {
        Map<Id, List<Case>> caseListByTrendIdMap = new Map<Id, List<Case>>();
        for (Id trendId : trendIdSet) { caseListByTrendIdMap.put(trendId, new List<Case>()); }

        for (Case currentCase : caseList)
        {
            Id trendId = currentCase.trend__c;
            caseListByTrendIdMap.get(trendId).add(currentCase);
        }
        
        return caseListByTrendIdMap;
    }
    
    global void finish(Database.BatchableContext batchableContext) {}
}