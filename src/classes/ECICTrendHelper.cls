public class ECICTrendHelper 
{
	public static final String      KEY_DELIMITER             = '_';

    @testVisible private static final String      TREND_KEY 	            = 'trend_key__c';
	
    @testVisible private static final Set<Id>     QUALITY_COMPLAINT_ID_SET  = ECICCaseQualityComplaintRecordTypeHelper.QUALITY_COMPLAINT_ID_SET;
    @testVisible private static final Set<String> UNTRACKED_CASE_STATUS_SET = new Set<String>{ECICCommonConstants.STATUS_NEW, ECICCommonConstants.STATUS_CANCELLED};

    // -------------------------------------------------------------------------------------------------------------------

    public static Boolean isResetTrendAttributesRequired(Case oldCase, Case newCase)
    {
        return ( 
                        (oldCase != null)
                    &&  (newCase.trend__c != null ) 
                    &&  (isTripletChanged(newCase, oldCase))
               );    
    }
    
    public static Boolean isTrendRemoved(Case oldCase, Case newCase)
    {
        Boolean isTrendRemoved = (oldCase != null) && (newCase.Trend__c == oldCase.Trend__c); 
        if     (isTrendRemoved) { ECICTrendMap.trendWithUpdateIdSet.add(oldCase.Trend__c); }  
        return  isTrendRemoved;
    }
    
    public static Boolean isNewTrendKeyRequired(Case oldCase, Case newCase)
    {
        return (
                       (QUALITY_COMPLAINT_ID_SET.contains(newCase.RecordTypeID))                                // Process only 'Quality Complaints'
                    && (!UNTRACKED_CASE_STATUS_SET.contains(newCase.status))                                    // ... which are not 'New' or 'Cancelled'
                    && (newCase.Trend__c == null )                                                              // If trend case is closed then update active case count on trend object
                    && (isTripletComplete (newCase))                                                            // If triplet is incomplete, don't initiate trend tracking
                    && (
                             (oldCase == null) 
                          || isTripletChanged(newCase, oldCase)                                                 // Skip situation when triplet is not changed, 
                          || (newCase.status != oldCase.status)                                                 // ... unless status changed.
                          || (oldcase.trend__c != null)                                                         // or unless we just got kicked out of a trend, and looking for a new one
	    		                              )
    		                              );
    	}
    	
    /**
     * Expected Result should be true IF
     *          1. Any of the triplet has been changed to NULL, AND
     *          2. The value was NOT null before
     **/
    public static Boolean isTripletCleared(Case newCase, Case oldCase) 
    {
        Boolean isProductIdCleared        = isFieldCleared (newCase.Product__c,         oldCase.Product__c);
        Boolean isProductionLineIdCleared = isFieldCleared (newCase.Production_Line__c, oldCase.Production_Line__c);
        Boolean isBbeDateCleared          = isFieldCleared (newCase.BBE_Date__c,        oldCase.BBE_Date__c);
        return (isProductIdCleared || isProductionLineIdCleared || isBbeDateCleared );
    }

    private static Boolean isFieldCleared (Date newValue,   Date oldValue)   { return ((newValue == null) && (oldValue != null)); }
    private static Boolean isFieldCleared (String newValue, String oldValue) { return ((newValue == null) && (oldValue != null)); }
    
    public static boolean isTripletChanged(Case newCase, Case oldCase) 
    {
        if (oldCase == null) { return true; }

        Boolean prodChanged     = (newCase.Product__c         != oldCase.Product__c         );
        Boolean prodLineChanged = (newCase.Production_Line__c != oldCase.Production_Line__c );
        Boolean bbeChanged      = (newCase.BBE_Date__c        != oldCase.BBE_Date__c        );

        return (prodChanged || prodLineChanged || bbeChanged);
    }
    
    public static Boolean isTripletComplete (Case currentCase)
    {
        return          (currentCase.bbe_date__c        != null)
                    &&  (currentCase.Product__c         != null)
                    &&  (currentCase.Production_LIne__c != null); 
        
    }
    
    //----------------------------------------------------------------------------------------------

    /**
     *    Create Trend with for defined triplet BBE Date - Production Line - Product
     */
    public static Trend__c createTrend(Date bbe, Id prodLineId, Id prodId, String cntrCode) 
    {
        Trend__c trend = new Trend__c();
		         trend.BBE_Date__c = bbe;
		         trend.Product__c = prodID;
		         trend.Production_line__c = prodLineId;
		         trend.Country_code__c = cntrCode;
		         trend.CaseCount__c = 0;
                 trend.Recheck_Potential_Risk__c = true;
          return trend;
    }

	// -----------------------------------------------------------------------------------------------------------------    
    
    public static String getTrendKey(Date bbe, String prodLineId, String prodId, String cntrCode) {
        return cntrCode + '_' + String.valueOf(bbe) + '_' + prodLineId.substring(0,15) + '_' +  prodId.substring(0,15);
    }

   	// -----------------------------------------------------------------------------------------------------------------    
    
    public static void attachTrendsToCases(List<Case> caseList, Map<String, Trend__c> trendByCaseIdentifierMap)
    {
    	Map <Id, Integer> pendingCaseCountByTrendIdMap = new Map <Id, Integer>();
    	for (Trend__c trend : trendByCaseIdentifierMap.values())
    	{
    		pendingCaseCountByTrendIdMap.put(
	    		                              trend.id,
	    		                              (
	    		                                  (!pendingCaseCountByTrendIdMap.containsKey(trend.id))
	    		                                      ? 1
	    		                                      : (pendingCaseCountByTrendIdMap.get(trend.id) + 1)
	    		                              )
    		                              );
    	}
    	
        for (Case currentCase : caseList) 
        {
        	String caseIdentifier = ECICMapHelper.createMapIdentifier(currentCase, true);
            Trend__c trend = trendByCaseIdentifierMap.get(caseIdentifier);
            if ( (trend != null) && ( trend.CaseCount__c + pendingCaseCountByTrendIdMap.get(trend.id) )  > 1) 
            {
                attachTrendToCase(currentCase, trend);
            }
        }
    }
    
    /**
     *    Link case and matched trend
     */
    public static void attachTrendToCase(Case currentCase, Trend__c trend) 
    {
        currentCase.trend__c      = trend.id;
        currentCase.trend__r      = trend;
        currentCase.trend_mark__c = (trend.createdDate != null) ? trend.createdDate : System.now();

        trend.CaseCount__c += 1;
        
        if (trend.CaseCount__c == 3)       // We only want setting and notification on the 3rd, and NOT also on latter occurances.
        {
        	setRiskAttributes(currentCase);
        }
    }

    // ------------------------------------------------------------------------------------------------------

    public static void setRiskAttributes(Case currentCase) 
    {
            currentCase.The3rdComplaint__c = true;
            currentCase.priority 		   = 'High';  
            currentCase.risk_type__c 	   = '3rd Complaint';
            currentCase.Potential_Risk__c  = 'High Risk'; // value assumed.  Previously Potential_Risk = true; true could also mean 'Medium Risk'.
        }

    // -------------------------------------------------------------------------------------------------------------------
    
    /**
     *    Clear trend attribute values
     */
    public static void resetTrendAttributes(Case currentCase) 
    {
        resetRiskAttributes(currentCase);
        currentCase.trend_key__c  = null;
        currentCase.trend_mark__c = null;
        currentCase.trend__c      = null;
        currentCase.No_Quality_Status_Change__c = true;
    }

    public static void resetRiskAttributes(Case currentCase)                                                // We don't revert 'Priority' here because inclusion within Trend has no implication. 
    {
        currentCase.The3rdComplaint__c = false;
        if (currentCase.Risk_Type__c == '3rd Complaint') 
        {  
        	currentCase.Risk_Type__c      = null;                                                    // We don't want to change other risk types, such as 'Blackmail'.
        if (currentCase.Risk_Type__c == null)            {  currentCase.Potential_Risk__c = 'No Risk'; }    // If there is still a risk, we don't want to reduce
    }
    }
    
    /**
     *    Remove trend link for specified cases
     */
     public static void unlinkTrendCases(Id[] caseIdArray) 
     { 
         List<Case> caseList = new List<Case>();  
         for (Id caseId : caseIdArray) 
         {
		             Case currentCase = new Case(id = caseId);
		                  currentCase.trend__c                    = null;
		                  currentCase.No_Quality_Status_Change__c = true;
             caseList.add(currentCase);
         }
         update caseList;
     }

    // ------------------------------------------------------------------------------------------------------
    
    /**
    *    Group Objects by Key
    */
    public static void groupObjectsByTrendKey(List<SObject> sObjectList, Map<String, List<sObject>> groupedSObjectListByTrendKeyMap) 
    {
        for (SObject currentSObject : sObjectList) 
        {
        	groupObjectByTrendKey(currentSObject,  groupedSObjectListByTrendKeyMap);
        }
	}
        
    public static void groupObjectByTrendKey(SObject currentSObject, Map<String, List<sObject>> groupedSObjectListByTrendKeyMap)
  	{
        String key = (String) currentSObject.get(TREND_KEY);
        if ((key != null) && (!ECICUtils.isEmpty(key)))
        {
        	if (!groupedSObjectListByTrendKeyMap.containsKey(key))
        	{
        		groupedSObjectListByTrendKeyMap.put(key, new List<sObject>());
        	}
        	groupedSObjectListByTrendKeyMap.get(key).add(currentSObject);
        }
  	}

    public static Map<String, List<Case>> buildGroupedCaseListsByTrendKeyMap (List<List<Case>> caseListList)
    {
        Map<String, List<Case>> groupedCaseListByTrendKeyMap = new Map<String, List<Case>>();
        if ((caseListList != null) && (!caseListList.isEmpty()))
        {
        for (List<Case> caseList : caseListList)
        {
	        	if ((caseList != null) && (!caseList.isEmpty()))
        	{
        		ECICTrendHelper.groupObjectsByTrendKey (caseList, groupedCaseListByTrendKeyMap);
        	}
        } 
        }
    	return groupedCaseListByTrendKeyMap;
    }

    // -------------------------------------------------------------------------------------------------------------------
    
    public static void upsertTrends(Set<Id> trendWithUpdateIdSet, List<Trend__c> newTrendList)
    {
        /** 
         * This insert now incorporates is a "quick" and "safe" fix for updating Trend Case potential risk and deleting obsolete Trends.
         * 
         *  To limit impact on existing code, this code is just quickly determining which Trends are being insert and updated by setting
         *  trend.recheck_potential_risk__c = true
         *
         *  ... and then scheduling ECICTrendRiskUpdateSchedulable to check the Case counts and update Cases and Trends accordingly.
         * 
         *  A better solution might do that work within this trend tracker.
         *
     **/

        List<Trend__c> trendsToUpsertList = new List<Trend__c>();
        if (!trendWithUpdateIdSet.isEmpty())
        {
	         for (Id trendId : trendWithUpdateIdSet) 
	         { 
	           	 Trend__c trend = new Trend__c(id = trendId);
	                   	  trend.recheck_potential_risk__c = true; 
	             trendsToUpsertList.add(trend);
	         }
        }

        if ((newTrendList != null) && (!newTrendList.isEmpty())) { trendsToUpsertList.addAll(newTrendList); }
        
        if (!trendsToUpsertList.isEmpty())    
        { 
            upsert trendsToUpsertList; 
            ECICTrendRiskUpdateSchedulable.scheduleJob();                                 
        }
    }
}