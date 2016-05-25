public /*with sharing*/ class ECICRegionTriggerHandler extends SEPTriggerHandlerAbstract {

    public ECICRegionTriggerHandler(boolean isTriggerExecuting) {
       super(isTriggerExecuting);
    }

    public override void OnBeforeInsert(List<sObject> newValues) {
        ECICUtils.resolveOwner(newValues, null, true);
        ECICUtils.resolveCountryCode(newValues, null, true);
    }
    
    public override void OnBeforeUpdate(List<sObject> oldValues, List<sObject> newValues, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        ECICUtils.resolveOwner(newValues, oldValuesMap, false);
        ECICUtils.resolveCountryCode(newValues, oldValuesMap, false);
    }
    
    public override void OnAfterUpdate(List<sObject> oldValues, List<sObject> newValues, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        processAfterUpdate((List<Region__c>)newValues, (Map<ID, Region__c>)oldValuesMap);
	}
	
	private void processAfterUpdate(List<Region__c> newRegions, Map<ID, Region__c> oldRegionsMap) {
		Map<ID, Region__c> updatedRegions = filterBottlerUpdatedRegions(newRegions, oldRegionsMap);

		if (! updatedRegions.isEmpty()) {
			updateCaseBottlersAndDistributorsByRegion(updatedRegions);
		}
	}
	
	@TestVisible
	private Map<ID, Region__c> filterBottlerUpdatedRegions(List<Region__c> newRegions, Map<ID, Region__c> oldRegionsMap) {
		Map<ID, Region__c> result = new Map<ID, Region__c>();
		Set<ID> oldActiveBottlerUsers = filterActiveBottlerUsersInRegions(oldRegionsMap.values());
		
		for (Region__c newRegion : newRegions) {
			Region__c oldRegion = oldRegionsMap.get(newRegion.id);
			
			for (String bottlerField : ECICCommonConstants.BOTTLER_FIELDS) {
				ID newBottlerUserId = (ID)newRegion.get(bottlerField);
				ID oldBottlerUserId = (ID)oldRegion.get(bottlerField);
				
				if (newBottlerUserId != oldBottlerUserId // user changed
					&& (newBottlerUserId != null		 // user not cleared
						|| oldActiveBottlerUsers.contains(oldBottlerUserId) ) // user cleared by hand on Region page // NOTE: cleared also happens on user deactivation but the SEPUserTrigger takes care of clearing the Case RUL fields
					&& ! result.containsKey(newRegion.id)) {

					// user (ID) changed in bottler field
					result.put(newRegion.id, newRegion);
				}
			}
		}
		
		return result;
	}
	
	@TestVisible
	private Set<ID> filterActiveBottlerUsersInRegions(List<Region__c> regions) {
		Set<ID> result = new Set<ID>();
		Set<ID> checkUserIds = new Set<ID>();


		for (Region__c region : regions) {
			for (String bottlerField : ECICCommonConstants.BOTTLER_FIELDS) {
				ID bottlerUserId = (ID)region.get(bottlerField);
				
				if (bottlerUserId != null) {
					checkUserIds.add(bottlerUserId);
				}
			}
		}
		
		if (! checkUserIds.isEmpty()) {
			result = ECICUserDao.filterActiveUsers(checkUserIds);
		}
		
 		return result;
	}
    
    @TestVisible
	private static void updateCaseBottlersAndDistributorsByRegion(Map<ID, Region__c> regions) {
		List<Case> cases = ECICCaseDao.findNotClosedByRegionOrPlantRegion(regions.keySet());

		for (Case currentCase : cases) 
		{
        	// NOTE: to avoid validation exception on this field
        	if (ECICCaseQualityComplaintRecordTypeHelper.isQualityComplaint(currentCase.RecordTypeID))
        	{
            	currentCase.No_Quality_Status_Change__c = true;
        	}

            Id plantRegionId = currentCase.Plant__r.Region__c;
            Id purchaseRegionId = currentCase.Region_of_Purchase__c;

			for (String regionUserField : ECICCommonConstants.REGION_USER_FIELDS) {
				//ID regionUserId = (ID)currentCase.get(regionUserField);
				ID useRegionId = regionUserField.startsWith('Distributor') ? purchaseRegionId : plantRegionId;
				
				if (useRegionId != null) {
					String useRegionField = regionUserField.equals('Bottler_Quality_Owner__c') ? 'Bottler_Quality__c' : regionUserField.replace('Distributor', 'Bottler');
					Region__c useRegion = regions.get(useRegionId);
					
					if (useRegion != null) { // NOTE: just for sure, would not be necessary though
						ID newUserId = (ID) useRegion.get(useRegionField);
						currentCase.put(regionUserField, newUserId);
					}

				} else {
					System.debug(LoggingLevel.WARN, 'Case ['+currentCase.id+'] plant/purchase region is not set!');
				}
				
			}
		}
		
		update cases;
	}
}