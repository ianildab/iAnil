public class ECICCaseTriggerPlantCache 
{
	@testVisible private static Map<Id, Plant__c> plantByIdCache = new Map<Id, Plant__c>();
	public  static Map<Id, Plant__c> getPlantIdMap() { return plantByIdCache; }
	
	public static void populate()
	{
		Map<Id, Plant__c> plantIdMap = new Map<Id, Plant__c>([
					SELECT id, bottler__c, Region__r.Bottler_Quality__c,  Region__r.Bottler_Quality_Manager__c, Region__r.Bottler_External_Relations__c																	
					FROM Plant__c
																]);
		plantByIdCache.putAll(plantIdMap);
	}
	}