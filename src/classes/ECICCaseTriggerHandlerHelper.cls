public class ECICCaseTriggerHandlerHelper 
{
    public static Boolean doMandatoryStrategies(SEPTriggerTypeEnum triggerType, List<Case> newCaseList, Map<ID, Case> oldCaseByIdMap, Map<ID, Case> newCaseByIdMap) 
    {
    	Boolean successExecution = true;
    	
		// If test is running, Case was created with TEST_DummyCaseFactory, and configured to skip strategies, just return true.
		// Does not support mixing Cases which should and should not skip strategies.
		if (Test.isRunningTest() && (TEST_MockHelper.getMockBoolean(newCaseList[0], 'skipStrategies')))  { return true; } 
		// else process normally.
    	
        // If we are in a before insert trigger set/validate Case.RecordType, Case.Type and  Case.Country_code__c
        if ((new Set<SEPTriggerTypeEnum>{SEPTriggerTypeEnum.BEFORE_INSERT, SEPTriggerTypeEnum.BEFORE_UPDATE}).contains(triggerType))
        {
        	for (SEPTriggerHandlerStrategy processingStrategy : ECICCaseTriggerHandlerDefaultStrategies.ON_BEFORE_UPSERT_MANDATORY_STRATEGY_CHAIN_START) 
        	{        		
	            if      (triggerType == SEPTriggerTypeEnum.BEFORE_INSERT) { successExecution = processingStrategy.OnBeforeInsert(newCaseList);                 } 
	            else if (triggerType == SEPTriggerTypeEnum.BEFORE_UPDATE) { successExecution = processingStrategy.OnBeforeUpdate(oldCaseByIdMap, newCaseByIdMap); } 
	            
	            if (
	            		(! successExecution) 	
	            		|| ( Test.isRunningTest() && (TEST_MockHelper.getMockBoolean(newCaseList[0], 'doMandatoryStrategiesFailureTest')))
	            	)
	            { 
	            	return false; 																		// break on failed execution
	            } 
        	} 
        }
        
        return successExecution;
    }
    
    public static Boolean doCountrySpecificStrategies(SEPTriggerTypeEnum triggerType, List<Case> currentCaseList, Map<ID, Case> oldCaseByIdMap, Map<ID, Case> currentCaseByIdMap)
    {
		if (Test.isRunningTest() && (TEST_MockHelper.getMockBoolean(currentCaseList[0], 'skipStrategies')))  { return true; } 

    	Boolean successExecution = true;
        // Separate 'new' cases by Country code
		// As noted above, delete triggers *SHOULD* have their data sent to currentCase parameters instead of oldCase parameters, because of this country logic.
        Map<String, List<Case>> 	currentCaseListByCountryCodeMap 	= null; 
        Set<String>					caseCountrySet				    	= null;
		Map<String, Map<Id,Case>>	currentCaseByIdMapByCountryCodeMap	= null;

		try
		{
        							currentCaseListByCountryCodeMap 	= createCaseListByCountryCodeMap(triggerType, currentCaseList); 
        							caseCountrySet				    	= currentCaseListByCountryCodeMap.keySet();
									currentCaseByIdMapByCountryCodeMap	= createCaseByIdMapByCountryCodeMap(triggerType, caseCountrySet, currentCaseByIdMap);
		}
		catch (ECICCaseTriggerStrategyConfigException configException)
		{
			for (Case currentCase : currentCaseList) { currentCase.addError(configException.errorMessage);  }
			return false;
		}
            
        // TODO: Consider moving this invokation to beginning of ECICCaseTriggerHandler.executeStrategyChain() or earlier
        ECICCaseTriggerRelatedRecordHelper.populateCaches (triggerType, currentCaseList, caseCountrySet, oldCaseByIdMap);   
            
        for (String countryCode : caseCountrySet)									// Iterate through the cases by countries
        {
    		List<Case> 		currentCountryCaseList 		= currentCaseListByCountryCodeMap.get(countryCode);
    		Map<Id, Case>	currentCountryCaseByIdMap	= currentCaseByIdMapByCountryCodeMap.get(countryCode);

			List<SEPTriggerHandlerStrategy> strategyChainList = (!Test.isRunningTest())
				/* 
				 * If not test, select normally 					
				 */																	
																	? selectStrategyChainList (triggerType, countryCode)

				/* 	Otherwise use first country Case to select 
				 *	-- doesn't support cases with same country configured to different lists, 
				 *  but that should never happen anyway. 
				 */													  								
																	: selectStrategyChainList (currentCountryCaseList[0], triggerType, countryCode);		 

																	
			if ((strategyChainList != null) && (!strategyChainList.isEmpty()))
			{
        		successExecution = processStrategyChain (triggerType, strategyChainList, currentCountryCaseList, oldCaseByIdMap, currentCountryCaseByIdMap);

			}
        	if (! successExecution) { return false; } // break on failed execution
        }
        
        // TODO: Consider moving this invokation to end of ECICCaseTriggerHandler.executeStrategyChain() or later
        ECICCaseTriggerRelatedRecordHelper.performDMLs (triggerType, currentCaseList, caseCountrySet); 
        
        return true;
    }
    
    public static List<SEPTriggerHandlerStrategy> selectStrategyChainList (SEPTriggerTypeEnum triggerType, String countryCode)
    {
    	// If this would throw a ECICCaseTriggerStrategyConfigException, it should have been caught earlier.
    	if 		(countryCode != 'OTHER') 							{ return ECICCaseTriggerStrategyFactory.getStrategyList(triggerType, countryCode); 	 	}
    	else if (triggerType == SEPTriggerTypeEnum.BEFORE_INSERT)	{ return ECICCaseTriggerHandlerDefaultStrategies.DEFAULT_BEFORE_INSERT_STRATEGY_CHAIN;  }
    	else if (triggerType == SEPTriggerTypeEnum.AFTER_INSERT)	{ return ECICCaseTriggerHandlerDefaultStrategies.DEFAULT_AFTER_INSERT_STRATEGY_CHAIN; 	}
    	else if (triggerType == SEPTriggerTypeEnum.BEFORE_UPDATE)	{ return ECICCaseTriggerHandlerDefaultStrategies.DEFAULT_BEFORE_UPDATE_STRATEGY_CHAIN;  }
    	else if (triggerType == SEPTriggerTypeEnum.AFTER_UPDATE)	{ return ECICCaseTriggerHandlerDefaultStrategies.DEFAULT_AFTER_UPDATE_STRATEGY_CHAIN;   }
    	else if (triggerType == SEPTriggerTypeEnum.BEFORE_DELETE)	{ return ECICCaseTriggerHandlerDefaultStrategies.DEFAULT_BEFORE_DELETE_STRATEGY_CHAIN;  }
    	else if (triggerType == SEPTriggerTypeEnum.AFTER_DELETE)	{ return ECICCaseTriggerHandlerDefaultStrategies.DEFAULT_AFTER_DELETE_STRATEGY_CHAIN;   }
    	else if (triggerType == SEPTriggerTypeEnum.AFTER_UNDELETE)	{ return ECICCaseTriggerHandlerDefaultStrategies.DEFAULT_AFTER_UNDELETE_STRATEGY_CHAIN; }
    	/* This should never happen */								  return null;
    }

    public static List<SEPTriggerHandlerStrategy> selectStrategyChainList (Case currentCase, SEPTriggerTypeEnum triggerType, String countryCode)
    {
		if (Test.isRunningTest())
		{
			if (TEST_MockHelper.getMockBoolean(currentCase, 'skipStrategies')) 
			{ 
				return null; 
			}
			else if (TEST_DummyGenericCaseFactory.useCustomCaseStrategies(currentCase))
			{
				return TEST_DummyGenericCaseFactory.getCustomCaseStrategies(currentCase, triggerType);	
			}	
		}
		
		// if not running test or no value returned yet, disregard caseId and select "normally".
		return selectStrategyChainList (triggerType, countryCode);
    }


    @testVisible private static Map<String, List<Case>> createCaseListByCountryCodeMap(SEPTriggerTypeEnum triggerType, List<Case> newCaseList)
    {
    	Map<String, List<Case>> newCaseListByCountryCodeMap = new Map<String, List<Case>>();
    	if ((newCaseList != null) && (!newCaseList.isEmpty()))
    	{
    	for (Case currentCase : newCaseList)
    	{
    		
    		Boolean countryTriggerTypeHasStrategyChain = null;
			countryTriggerTypeHasStrategyChain = ECICCaseTriggerStrategyFactory.hasStrategyChain(currentCase.Country_Code__c); // This can throw ECICCaseTriggerStrategyConfigException    		
    		
    		String countryCode = countryTriggerTypeHasStrategyChain ? currentCase.Country_Code__c : 'OTHER';     		

    		if (newCaseListByCountryCodeMap.get(countryCode) == null)
    		{
    			newCaseListByCountryCodeMap.put(countryCode, new List<Case>());
    		}
    		newCaseListByCountryCodeMap.get(countryCode).add(currentCase);
    	}
    	}
    	return newCaseListByCountryCodeMap;
    }

    @testVisible private static Map<String, Map<Id, Case>> createCaseByIdMapByCountryCodeMap(SEPTriggerTypeEnum triggerType, Set<String>	caseCountrySet, Map<Id, Case> caseByIdMap) 
    {
    	Map<String, Map<Id, Case>> caseByIdByCountryCodeMap = new Map<String, Map<Id, Case>>();
    	
    	if ((caseByIdMap != null) && (!caseByIdMap.isEmpty())) 
    	{
	    	for (Id currentCaseId : caseByIdMap.keySet())
	    	{
	    		Case currentCase = caseByIdMap.get(currentCaseId);

	    		Boolean countryTriggerTypeHasStrategyChain = null;
	    		countryTriggerTypeHasStrategyChain = ECICCaseTriggerStrategyFactory.hasStrategyChain(currentCase.Country_Code__c); // This can throw ECICCaseTriggerStrategyConfigException

	    		String countryCode = countryTriggerTypeHasStrategyChain ? currentCase.Country_Code__c : 'OTHER';
		    	if (caseByIdByCountryCodeMap.get(countryCode) == null)
	    		{
		    		caseByIdByCountryCodeMap.put(countryCode, new Map<Id, Case>());
		    	}
	    		caseByIdByCountryCodeMap.get(countryCode).put(currentCaseId, currentCase);
	    	}
    	}
    	return caseByIdByCountryCodeMap;
    }
    
    @testVisible private static Boolean processStrategyChain (
    				SEPTriggerTypeEnum triggerType, List<SEPTriggerHandlerStrategy> strategyChainList, 
    				List<Case> currentCaseList, Map<ID, Case> oldCaseByIdMap, Map<ID, Case> currentCaseByIdMap
    			)
    {
        Boolean successExecution = true;
        for (SEPTriggerHandlerStrategy processingStrategy : strategyChainList) 
        {
            if      (triggerType == SEPTriggerTypeEnum.BEFORE_INSERT)  { successExecution = processingStrategy.OnBeforeInsert(currentCaseList);                 } 
            else if (triggerType == SEPTriggerTypeEnum.AFTER_INSERT)   { successExecution = processingStrategy.OnAfterInsert(currentCaseByIdMap);               } 
            else if (triggerType == SEPTriggerTypeEnum.BEFORE_UPDATE)  { successExecution = processingStrategy.OnBeforeUpdate(oldCaseByIdMap, currentCaseByIdMap); } 
            else if (triggerType == SEPTriggerTypeEnum.AFTER_UPDATE)   { successExecution = processingStrategy.OnAfterUpdate(oldCaseByIdMap, currentCaseByIdMap);  }
            else if (triggerType == SEPTriggerTypeEnum.BEFORE_DELETE)  { successExecution = processingStrategy.OnBeforeDelete(currentCaseByIdMap); } 
            else if (triggerType == SEPTriggerTypeEnum.AFTER_DELETE)   { successExecution = processingStrategy.OnAfterDelete(currentCaseByIdMap);  }
            else if (triggerType == SEPTriggerTypeEnum.AFTER_UNDELETE) { successExecution = processingStrategy.OnAfterUndelete(currentCaseByIdMap);  }
            
            if (! successExecution) { return false; } // break on failed execution
        }
        return true;
    }
}