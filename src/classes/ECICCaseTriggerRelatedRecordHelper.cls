public class ECICCaseTriggerRelatedRecordHelper      
{
    public static void populateCaches (SEPTriggerTypeEnum triggerType, List<Case> currentCaseList, Set<String> countryCodeSet, Map<ID, Case> oldCaseByIdMap)
    {
		// Determine Case Trigger Strategies required
		 	/**
		 	 * We do NOT need to check Strategies which ONLY require the USER Cache 
		 	 * because that will (must) ALWAYS be invoked BEFORE ECICCaseTriggerHandlerHelper.doMandatoryStrategies().
		 	 **/ 
	        Boolean requiresECICCaseCancelNotModifiedTasksStrategy	= requiresStrategy ('ECICCaseCancelNotModifiedTasksStrategy', 	triggerType, countryCodeSet);
			Boolean requiresECICCaseCopyProductDetailsStrategy   	= requiresStrategy ('ECICCaseCopyProductDetailsStrategy',   	triggerType, countryCodeSet);
			Boolean requiresECICCaseEmailMessageCreatorStrategy  	= requiresStrategy ('ECICCaseEmailMessageCreatorStrategy', 		triggerType, countryCodeSet); 
			Boolean requiresECICCaseQComplaintPOSSetterStrategy  	= requiresStrategy ('ECICCaseQComplaintPOSSetterStrategy', 		triggerType, countryCodeSet);
			Boolean requiresECICCaseQComplBottlerNameSetterStrategy = requiresStrategy ('ECICCaseQComplBottlerNameSetterStrategy', 	triggerType, countryCodeSet);
			Boolean requiresECICCaseQComplBottlerUserSetterStrategy = requiresStrategy ('ECICCaseQComplBottlerUserSetterStrategy', 	triggerType, countryCodeSet);
	        Boolean requiresECICCaseTaskAssignmentStrategy	 		= requiresStrategy ('ECICCaseTaskAssignmentStrategy',  			triggerType, countryCodeSet);
	        Boolean requiresECICCaseTasksOnCancelValidationStrategy	= requiresStrategy ('ECICCaseTasksOnCancelValidationStrategy', 	triggerType, countryCodeSet);
	        Boolean requiresECICCaseTasksOnCloseValidationStrategy	= requiresStrategy ('ECICCaseTasksOnCloseValidationStrategy',  	triggerType, countryCodeSet);
			Boolean requiresECICCaseValidateProdlineStrategy	 	= requiresStrategy ('ECICCaseValidateProdlineStrategy', 		triggerType, countryCodeSet);
			Boolean requiresECICCaseAccountAndContactSetterStrategy  = requiresStrategy ('ECICCaseAccountAndContactSetterStrategy', triggerType, countryCodeSet);
			Boolean requiresECICCaseProductionCodeProcessingStrategy = requiresStrategy ('ECICCaseProductionCodeProcessingStrategy', triggerType, countryCodeSet);
			Boolean requiresECICCaseProductMergeStrategy             = requiresStrategy ('ECICCaseProductMergeStrategy',             triggerType, countryCodeSet);
			Boolean requiresECICCaseProductSplitStrategy             = requiresStrategy ('ECICCaseProductSplitStrategy',             triggerType, countryCodeSet);
			Boolean requiresECICCaseBeveragePackageCountryValidStr   = requiresStrategy ('ECICCaseBeveragePackageCountryValidStr',   triggerType, countryCodeSet);

		// Determine SObject Caches required
	        Boolean requiresAccountCache 	    = (requiresECICCaseQComplaintPOSSetterStrategy || requiresECICCaseQComplBottlerNameSetterStrategy);
	        Boolean requiresBottlerAccounts	    = requiresECICCaseQComplBottlerNameSetterStrategy; 	// Subset of AccountCache; doesn't have own cache.	

			Boolean requiresActionPlanItemCache = requiresECICCaseTaskAssignmentStrategy;        
	        Boolean requiresContactCache 	    = requiresECICCaseEmailMessageCreatorStrategy;
	        Boolean requiresEmailMessageCache   = requiresECICCaseEmailMessageCreatorStrategy;
	        Boolean requiresProductCache 	    = requiresECICCaseCopyProductDetailsStrategy || requiresECICCaseProductionCodeProcessingStrategy
	                                              || requiresECICCaseProductMergeStrategy    || requiresECICCaseProductSplitStrategy;
	        Boolean requiresProdlineCache 	    = requiresECICCaseValidateProdlineStrategy || requiresECICCaseProductionCodeProcessingStrategy;
	        
			Boolean requiresPlantCache		    = requiresBottlerAccounts								// If we require the Bottler Accounts from the AccountCache, this is required regardless of other required strategies.
	        									  || requiresECICCaseQComplBottlerNameSetterStrategy || requiresECICCaseQComplBottlerUserSetterStrategy;

	        Boolean requiresRegionCache 	    = requiresBottlerAccounts								// If we require the Bottler Accounts from the AccountCache, this is required regardless of other required strategies. 
	        									  || requiresECICCaseQComplBottlerNameSetterStrategy || requiresECICCaseQComplBottlerUserSetterStrategy;

			Boolean requiresTaskCache   	    = requiresECICCaseCancelNotModifiedTasksStrategy  	 || requiresECICCaseTaskAssignmentStrategy 
												  || requiresECICCaseTasksOnCancelValidationStrategy || requiresECICCaseTasksOnCloseValidationStrategy;
			Boolean requiresAccountAndConactCache  = requiresECICCaseAccountAndContactSetterStrategy;
			Boolean requiresBeverageCache            = requiresECICCaseProductMergeStrategy || requiresECICCaseProductSplitStrategy || requiresECICCaseBeveragePackageCountryValidStr;
			Boolean requiresPackageCache             = requiresECICCaseProductMergeStrategy || requiresECICCaseProductSplitStrategy || requiresECICCaseBeveragePackageCountryValidStr;

		// Populate, as per requirements
			/**
			 * BottlerAccounts do not have their own Cache, but rather will be collected with other Accounts.
			 * PlantCache and RegionCache must be built before AccountCache to provide data required for BottlerAccount collection.
			 **/
			if (requiresPlantCache) 	     { ECICCaseTriggerPlantCache.populate 		 	();					}	// PlantCache must be populated before RegionCache 
			if (requiresRegionCache) 	     { ECICCaseTriggerRegionCache.populate 		 	();					}   // RegionCache must be populated before AccountCache
	        if (requiresAccountCache) 	     { ECICCaseTriggerAccountCache.populate 	 	(currentCaseList, oldCaseByIdMap); 	}

	        if (requiresActionPlanItemCache) { ECICCaseTriggerActionPlanItemCache.populate  (currentCaseList);					}	// ActionPlanItemCache must be populated before TaskCache
	        if (requiresTaskCache)   	     { ECICCaseTriggerTaskCache.populate	 		(currentCaseList);					}	// TaskCache must be before ActionPlanCache

	        if (requiresContactCache || requiresAccountAndConactCache) 	     { ECICCaseTriggerContactCache.populate 		 (currentCaseList); 	  			} 
	        if (requiresEmailMessageCache)   { ECICCaseTriggerEmailMessageCache.populate 	 (currentCaseList); 				} 
	        if (requiresProductCache) 	     { ECICCaseTriggerProductCache.populate 		 (currentCaseList); 				} 
	        if (requiresProdlineCache) 	     { ECICCaseTriggerProductionLineCache.populate   (currentCaseList); 	  		    }
	        if (requiresAccountAndConactCache) { ECICCaseTriggerAccountAndContactCache.populate (currentCaseList);              }
	        if (requiresBeverageCache)         { ECICCaseTriggerBeverageCache.populate         (currentCaseList);              }
	        if (requiresPackageCache)          { ECICCaseTriggerPackageCache.populate          (currentCaseList);              }
	        
	        								// ECICCaseTriggerUserCache.populate (currentCaseList) will (must) ALWAYS be invoked BEFORE ECICCaseTriggerHandlerHelper.doMandatoryStrategies(). 
    }

    public static void performDMLs (SEPTriggerTypeEnum triggerType, List<Case> currentCaseList, Set<String> countryCodeSet)
    {
		// Determine Case Trigger Strategies required
	        Boolean requiresECICCaseEmailMessageCreatorStrategy 	= requiresStrategy ('ECICCaseEmailMessageCreatorStrategy', 	   triggerType, countryCodeSet);
	        Boolean requiresECICCaseQComplBottlerUserSetterStrategy	= requiresStrategy ('ECICCaseQComplBottlerUserSetterStrategy', triggerType, countryCodeSet);
	        Boolean requiresECICCaseTaskAssignmentStrategy	 		= requiresStrategy ('ECICCaseTaskAssignmentStrategy',  			triggerType, countryCodeSet);
	        Boolean requiresECICCaseCancelNotModifiedTasksStrategy	= requiresStrategy ('ECICCaseCancelNotModifiedTasksStrategy',  triggerType, countryCodeSet);
	        Boolean requiresECICCaseAccountAndContactSetterStrategy  = requiresStrategy ('ECICCaseAccountAndContactSetterStrategy', triggerType, countryCodeSet);

		// Determine Cache Actions required
	        Boolean requiresEmailMessageInsertions 	= requiresECICCaseEmailMessageCreatorStrategy;
	        Boolean requiresEmailMessagesSent		= requiresECICCaseQComplBottlerUserSetterStrategy;
	        Boolean requiresTaskInsertions	 		= requiresECICCaseTaskAssignmentStrategy;
	        Boolean requiresTaskDeletions	 		= requiresECICCaseTaskAssignmentStrategy || requiresECICCaseCancelNotModifiedTasksStrategy;
	        Boolean requiresContactUpdates          = requiresECICCaseAccountAndContactSetterStrategy;

		// Do, as per requirements
	        if (requiresEmailMessageInsertions) { ECICCaseTriggerEmailMessageCache.doInsertions();  }   
	        if (requiresEmailMessagesSent) 		{ ECICCaseTriggerEmailMessageCache.doSend();  		}
 			if (requiresTaskInsertions)			{ ECICCaseTriggerTaskCache.doInsertions();			}   
	        if (requiresTaskDeletions) 			{ ECICCaseTriggerTaskCache.doDeletions();  			}  
	        if (requiresContactUpdates)         { ECICCaseTriggerAccountAndContactCache.doUpdates(); }
    }

    @testVisible private static Boolean requiresStrategy (String strategyName, SEPTriggerTypeEnum triggerType, Set<String> countryCodeSet)
    {
        return ECICCaseTriggerStrategyFactory.isStrategyRequired(strategyName, triggerType, countryCodeSet);
    }
 }