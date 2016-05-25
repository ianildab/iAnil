public class ECICCaseQComplBottlerUserSetterStrategy extends ECICCaseProcessingStrategyAbstract 
{
    @testVisible private final Set<Id>      ACTIVE_BOTTLER_USER_ID_SET = getActiveBottlerUserIdSet();
    @testVisible private Map<Id, Region__c> bottlerRegionByIdMap       = null;
    
    private static Set<Id> getActiveBottlerUserIdSet()
    {
        Set<Id> activeBottlerUserIdSet = ECICCaseTriggerUserCache.getBottlerUserByIdMap().keySet();
        return activeBottlerUserIdSet;
    }

    @testVisible private Map<Id, Set<id>> incorrectBottlerLookupIdSetByRegionIdMap = new Map<Id, Set<Id>>();

    public override boolean OnBeforeInsert(List<sObject> newValues) 
    {
        Case[] qualityComplaints = filterQualityComplaintCases((List<Case>)newValues);
        execute(qualityComplaints);
        return true;
    }

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) 
    {
        Case[] qualityComplaints = filterQualityComplaintCases((List<Case>)newValuesMap.values());
        execute(qualityComplaints);
        return true;
    }
    
    @testVisible private void execute(Case[] casesList) 
    {
        bottlerRegionByIdMap   = buildBottlerRegionByIdMap();
        
        List<Case> qualityCasesForBottlerSpecificationList = buildQualityCasesForBottlerSpecificationList(casesList);
        if (! qualityCasesForBottlerSpecificationList.isEmpty() ) { specifyBottlers(qualityCasesForBottlerSpecificationList);  }
    }
    
    @testVisible private List<Case> buildQualityCasesForBottlerSpecificationList(List<Case> casesList)
    {
    	Set<String> immutableStatusSet = new Set<String>{ECICCommonConstants.STATUS_NEW, ECICCommonConstants.STATUS_CLOSED, ECICCommonConstants.STATUS_CANCELLED};
    	
        List<Case> qualityCasesForBottlerSpecificationList = new List<Case>();
        for (Case currentCase : casesList) 
        {
            if (!immutableStatusSet.contains(currentCase.status)) { qualityCasesForBottlerSpecificationList.add(currentCase); }
        }
        return qualityCasesForBottlerSpecificationList;
    }

    @testVisible private void specifyBottlers(List<Case> caseList) 
    {
        if ((bottlerRegionByIdMap != null) && (!bottlerRegionByIdMap.isEmpty())) 
        {
            for (Case currentCase : caseList)  { specifyBottlers (currentCase); }
            if(!incorrectBottlerLookupIdSetByRegionIdMap.isEmpty() ) {  processIncorrectBottlerLookupIds(); }
        }
    }
    
    @testVisible private void specifyBottlers (Case currentCase)
    {
        setCaseFields (currentCase, bottlerRegionByIdMap.get(currentCase.Plant__c),              'Bottler');
        setCaseFields (currentCase, bottlerRegionByIdMap.get(currentCase.Region_of_Purchase__c), 'Distributor');
    }
    
    @testVisible private Map<ID, Region__c> buildBottlerRegionByIdMap()
    {
        Map<ID, Region__c> bottlerRegionByIdMap = ECICCaseTriggerRegionCache.getRegionByIdMap();
        List<Plant__c> 	   plantList      = ECICCaseTriggerPlantCache.getPlantIdMap().values();
        if (!plantList.isEmpty()) { for (Plant__c plant : plantList) { bottlerRegionByIdMap.put(plant.id, plant.region__r); } }
        return  bottlerRegionByIdMap;
    }
    
    @testVisible private void processIncorrectBottlerLookupIds()
            {
                String mailAlert = System.label.User_Lookup_Alert + '\n\n';
                for(Id id: incorrectBottlerLookupIdSetByRegionIdMap.keySet())
                {
            System.debug( Logginglevel.WARN , 'Incorrect users in following region:'+id+', users:'+ incorrectBottlerLookupIdSetByRegionIdMap.get(id));
                    mailAlert += System.label.region + ' id:' + id + ', ' + System.label.users + ' : ' + incorrectBottlerLookupIdSetByRegionIdMap.get(id) + '\n\n';
                }
        ECICCaseTriggerEmailMessageCache.addEmailMessageToSendList( General_Settings__c.getInstance().supportEmail__c, System.label.User_Lookup_Alert_Subject, mailAlert );
            }

	@testVisible private void setCaseFields (Case currentCase, Region__c region, String fieldPrefix)
	{
    	if (region != null) 
        {
        	Boolean correctLookUp = checkBottlerInRegionIdMap(region); 
            currentCase.put (fieldPrefix + '_Quality' + ((fieldPrefix=='Bottler')?'_Owner':'')+'__c', (correctLookUp) ? region.Bottler_Quality__c			 : null);
            currentCase.put (fieldPrefix + '_Quality_Manager__c', 									  (correctLookUp) ? region.Bottler_Quality_Manager__c	 : null);
            currentCase.put (fieldPrefix + '_External_Relations__c', 								  (correctLookUp) ? region.Bottler_External_Relations__c : null);
        }
	}

	@testVisible private Boolean checkBottlerInRegionIdMap(Region__c region)
	{
        Boolean correctLookUp = false; 
        if (!incorrectBottlerLookupIdSetByRegionIdMap.containsKey(region.id)) 
        {
            Set<ID> inactiveUserIdSet = fetchInactiveUsers(new ID[]{region.Bottler_Quality__c, region.Bottler_Quality_Manager__c, region.Bottler_External_Relations__c});                    
            if (!inactiveUserIdSet.isEmpty())  { incorrectBottlerLookupIdSetByRegionIdMap.put(region.Id, inactiveUserIdSet); }
            else                               { correctLookUp = true;                                                       }
        }
        return correctLookup;
}

    @testVisible private Set<ID> fetchInactiveUsers(List<Id> regionUserIdList) 
    {
        Set<ID> inactiveUserIdSet = new Set<ID>();
        for(Id regionUserId: regionUserIdList)
        {
            if(regionUserId != null && !ACTIVE_BOTTLER_USER_ID_SET.contains( regionUserId )) { inactiveUserIdSet.add(regionUserId); }
        }
        return inactiveUserIdSet ;
    }
}