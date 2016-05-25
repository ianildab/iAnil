@isTest
public class ECICCaseRegionTestHelper 
{
	public final Region__c DUMMY_BOTTLER_REGION;
	public final Region__c DUMMY_DISTRIBUTOR_REGION;

	public ECICCaseRegionTestHelper ()
	{
		List<Region__c> dummyRegionList = new List<Region__c>(); 
					 dummyRegionList.add(createDummyRegion('Bottler')); 
					 dummyRegionList.add(createDummyRegion('Distributor'));
			  insert dummyRegionList;
		
		DUMMY_BOTTLER_REGION			= dummyRegionList[0];
		DUMMY_DISTRIBUTOR_REGION		= dummyRegionList[1];
	}

	public static Region__c createDummyRegion(String regionType)
	{
		Region__c dummyRegion = ECICTestHelper.createRegion(ECICCommonConstants.TEST_CITY_STATE_AND_REGION);
        return (configDummyRegion(dummyRegion, 'Original', regionType));
	}
	
	public static void updateDummyRegion (Region__c targetRegion, String regionType)
	{
		update (configDummyRegion(targetRegion, 'Replacement', regionType));				  
	}
	
	private static Region__c configDummyRegion (Region__c targetRegion, String shift, String regionType)
	{
			   targetRegion.Bottler_External_Relations__c = ECICCaseTaskUserTestHelper.CASE_TASK_USER_MAP.get( shift + '_' + regionType + '_External_Relations__c' ).id;
			   targetRegion.Bottler_Quality_Manager__c    = ECICCaseTaskUserTestHelper.CASE_TASK_USER_MAP.get( shift + '_' + regionType + '_Quality_Manager__c' ).id;
		 	   targetRegion.Bottler_Quality__c 		      = ECICCaseTaskUserTestHelper.CASE_TASK_USER_MAP.get( shift + '_' + regionType + '_Quality'+ (regionType=='bottler'?'_Owner':'') +'__c' ).id;
		return targetRegion;
	}
}