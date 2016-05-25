global class ECICClosedTrendsTracker implements Schedulable     
{
    @testVisible private Datetime toDatetime = null;

    // ---------------------------------------------------------------------------------------------------------------------

    global void execute(SchedulableContext schedulableContext) { findClosedTrends(); }
    
    public void findClosedTrends() { findClosedTrends(Datetime.newInstance(system.today(), Time.newInstance(0,0,0,0))); }
    
    public void findClosedTrends(Datetime toDatetime) 
    {
    	this.toDatetime = toDateTime;
    	
        List<Closed_Trend__c> definitionClosedTrendList = ECICClosedTrendDao.selectDefinitionClosedTrendList();
        if (definitionClosedTrendList.isEmpty()) { return; }
        
        List<Case>                       selectedCaseList         = ECICCaseDao.selectCaseList(definitionClosedTrendList);
        Map<Closed_Trend__c, List<Case>> caseListByClosedTrendMap = buildCaseListByClosedTrendMap(definitionClosedTrendList, selectedCaseList);
        
        //<parent_def_closed_trend_id, new_coll_closed_trend>
        Map<Id, Closed_Trend__c> newCollectionClosedTrendByParentDefinitationClosedTrendIdMap = buildNewCollectionClosedTrendByParentDefinitationClosedTrendIdMap(caseListByClosedTrendMap);
                          insert newCollectionClosedTrendByParentDefinitationClosedTrendIdMap.values();
        
        insertClosedTrendCaseListAndNotify(caseListByClosedTrendMap, newCollectionClosedTrendByParentDefinitationClosedTrendIdMap);
    }

    // ---------------------------------------------------------------------------------------------------------------------
    

    @testVisible private Map<Closed_Trend__c, List<Case>> buildCaseListByClosedTrendMap(List<Closed_trend__c> definitionClosedTrendList, List<Case> queryResultCaseList)
    {
        Map<Closed_Trend__c, List<Case>> caseListByClosedTrendMap = new Map<Closed_Trend__c, List<Case>>();
        for (Case currentCase : queryResultCaseList) 
        {
        	caseListByClosedTrendMap.putAll(buildCaseListByClosedTrendMap(definitionClosedTrendList, currentCase));
        }
        return caseListByClosedTrendMap;
    }
    
    @testVisible private Map<Closed_Trend__c, List<Case>> buildCaseListByClosedTrendMap(List<Closed_trend__c> definitionClosedTrendList, Case currentCase)
    {
        Map<Closed_Trend__c, List<Case>> caseListByClosedTrendMap = new Map<Closed_Trend__c, List<Case>>();
        for (Closed_Trend__c closedTrend : definitionClosedTrendList ) 
        {
            caseListByClosedTrendMap.putAll(buildCaseListByClosedTrendMap(closedTrend, currentCase));        
        }
        return caseListByClosedTrendMap;
    }

    @testVisible private Map<Closed_Trend__c, List<Case>> buildCaseListByClosedTrendMap(Closed_Trend__c closedTrend, Case currentCase)
    {
        Map<Closed_Trend__c, List<Case>> caseListByClosedTrendMap = new Map<Closed_Trend__c, List<Case>>();
        
        if (ECICClosedTrendHelper.isMatched(currentCase, closedTrend) && ECICClosedTrendHelper.isCaseBetweenClosedTrendDates(currentCase, closedTrend, this.toDatetime)) 
        {
            if (!caseListByClosedTrendMap.containsKey(closedTrend)) { caseListByClosedTrendMap.put(closedTrend, new List<Case>()); } 
            caseListByClosedTrendMap.get(closedTrend).add(currentCase);            
        }
        
        return caseListByClosedTrendMap;
    }

    // ---------------------------------------------------------------------------------------------------------------------

    @testVisible private Map<Id, Closed_Trend__c> buildNewCollectionClosedTrendByParentDefinitationClosedTrendIdMap(Map<Closed_Trend__c, List<Case>> caseListByClosedTrendMap)
    {
    	//<parent_def_closed_trend_id, new_coll_closed_trend>
        Map<Id, Closed_Trend__c> newCollectionClosedTrendByParentDefinitationClosedTrendIdMap = new Map<Id, Closed_Trend__c>();
        
        for (Closed_Trend__c closedTrend : caseListByClosedTrendMap.keySet()) 
        {
            List<Case> childCaseList = caseListByClosedTrendMap.get(closedTrend);
            
            if (closedTrend.threshold__c <= childCaseList.size()) { mapNewCollectionClosedTrendClones(closedTrend, newCollectionClosedTrendByParentDefinitationClosedTrendIdMap); }
            else                                                  { caseListByClosedTrendMap.remove(closedTrend); }
        }
        return newCollectionClosedTrendByParentDefinitationClosedTrendIdMap;
    }
    
    @testVisible private void mapNewCollectionClosedTrendClones(Closed_Trend__c closedTrend, Map<Id, Closed_Trend__c> newCollectionClosedTrendByParentDefinitationClosedTrendIdMap)
    {
    	    Date   today              = system.today();
            String min                = String.valueOf(today.addDays(-Integer.valueOf(closedTrend.period__c)));
            String max                = String.valueOf(today.addDays(-1));
            String analyzedPeriod     = String.format(ECICClosedTrendHelper.NAME_PLACEHOLDER, new String[]{min, ' - ', max});
            Closed_Trend__c clonedClosedTrend = ECICClosedTrendHelper.createClosedTrendClone(closedTrend, analyzedPeriod); 
            newCollectionClosedTrendByParentDefinitationClosedTrendIdMap.put(closedTrend.id, clonedClosedTrend); 
    }

    // ---------------------------------------------------------------------------------------------------------------------
    
    @testVisible private void insertClosedTrendCaseListAndNotify( Map<Closed_Trend__c, List<Case>> caseListByClosedTrendMap, Map<Id, Closed_Trend__c> newCollectionClosedTrendByParentDefinitationClosedTrendIdMap )
    {
        List<Closed_Trend_Case__c> closedTrendCaseList = new List<Closed_Trend_Case__c>();
        Map<sObject, Set<Id>>      recipientByIdSetMap = new Map<sObject, Set<Id>>();        
        Set<Id>                    allrecipientIdSet   = new Set<Id>();
        
        for (Closed_Trend__c closedTrend : caseListByClosedTrendMap.keySet()) 
        {
            List<Case>      childCaseList     = caseListByClosedTrendMap.get(closedTrend); 
            Closed_Trend__c clonedClosedTrend = newCollectionClosedTrendByParentDefinitationClosedTrendIdMap.get(closedTrend.id); 
            closedTrendCaseList.addAll (ECICClosedTrendHelper.createClosedTrendCaseList(childCaseList, clonedClosedTrend)); 

            Set<Id> idSet = SEPEmailSendHelper.getRecipients(childCaseList, closedTrend.recipients__c);
            if ((idSet != null) && (!idSet.isEmpty())) { allrecipientIdSet.addAll(idSet); }
            recipientByIdSetMap.put(clonedClosedTrend, idSet); 
        }
        
        insert closedTrendCaseList;
        SEPEmailSendHelper.sendMails(SEPEmailSendHelper.collectRecipientsAddressesAndCreateMails(recipientByIdSetMap, allrecipientIdSet, General_Settings__c.getInstance().Closed_Trends_Template_Id__c));
    }
}