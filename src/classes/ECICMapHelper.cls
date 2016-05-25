public class ECICMapHelper
{
    public static Map<String, SObject> castIdMapToStringMap (Map<ID, SObject> idMap)
    {
    	Map<String, SObject> stringMap = new Map<String, SObject>();
    	for (Id keyId : idMap.keySet()) { stringMap.put ((String) keyId, idMap.get(keyId) ); }
    	return stringMap;
    }
    
    public static Map<String, Case> castIdMapToStringMap (Map<ID, Case> idMap)
    {
    	Map<String, Case> stringMap = new Map<String, Case>();
    	for (Id keyId : idMap.keySet()) { stringMap.put ((String) keyId, idMap.get(keyId) ); }
    	return stringMap;
    }

    public static Map<String, Contact> castIdMapToStringMap (Map<ID, Contact> idMap)
    {
    	Map<String, Contact> stringMap = new Map<String, Contact>();
    	for (Id keyId : idMap.keySet()) { stringMap.put ((String) keyId, idMap.get(keyId) ); }
    	return stringMap;
    }

    public static Map<String, ID> castIdMapToStringMap (Map<ID, ID> idMap)
    {
    	Map<String, ID> stringMap = new Map<String, ID>();
    	for (Id keyId : idMap.keySet()) { stringMap.put ((String) keyId, idMap.get(keyId) ); }
    	return stringMap;
    }

	public static Map<Id, Case> castObjectMapToCaseMap (Map<Id, SObject> sObjectIdMap)
    {
    	Map<Id, Case> caseIdMap = new Map<Id, Case>();
    	for (Id keyId : sObjectIdMap.keySet()) { caseIdMap.put (keyId, (Case) sObjectIdMap.get(keyId) ); }
    	return caseIdMap;
    }

    public static Map<Id, SObject> castStringMapToIdMap (Map<String, SObject> stringMap)
    {
    	Map<Id, SObject> idMap = new Map<Id, SObject>();
    	for (String key : stringMap.keySet()) { idMap.put ((Id) key, stringMap.get(key) ); }
    	return idMap;
    }

    public static Map<Id, UserRole> castStringMapToIdMap (Map<String, UserRole> stringMap)
    {
    	Map<Id, UserRole> idMap = new Map<Id, UserRole>();
    	for (String key : stringMap.keySet()) { idMap.put ((Id) key, stringMap.get(key) ); }
    	return idMap;
    }

    public static Map<Id, Profile> castStringMapToIdMap (Map<String, Profile> stringMap)
    {
    	Map<Id, Profile> idMap = new Map<Id, Profile>();
    	for (String key : stringMap.keySet()) { idMap.put ((Id) key, stringMap.get(key) ); }
    	return idMap;
    }

	// -----------------------------------------------------------------------------------------------------------------------
	
	/**
	 * This function is used to create unique identifiers for sObjects which may not already have an SFDC Id.
	 * (e.g. because it hasn't been inserted yet.)
	 *
	 * Only "stable" values should be used so the calculation can be repeated with the same result.
	 * (e.g. first to put a record in a map and [possibly much] later to retrieve it.) 
	 **/  	
	public static String createMapIdentifier (SObject currentSobject, Boolean useNonNullId)
	{
		if (useNonNullId)
	{
			// If sObject already has an id, we can/should use it, and it alone (unless we can't)
		if (currentSObject.get('id') != null) { return (String) currentSObject.get('id'); } 
		}

		if (currentSObject.getSObjectType() == Case.SObjectType)     { return createMapIdentifier ((Case) currentSobject);     }
        if (currentSObject.getSObjectType() == Open_Alert__c.SObjectType)   { return createMapIdentifier ((Open_Alert__c) currentSobject); }
        if (currentSObject.getSObjectType() == Task.SObjectType)     { return createMapIdentifier ((Task)     currentSobject); }
		if (currentSObject.getSObjectType() == Trend__c.SObjectType) { return createMapIdentifier ((Trend__c) currentSobject); }

		// TODO: Modify this code to create unique Ids for more SObjects, which will usually have different fields.
		throw new MapIdentifierUndefinedException('No map identifier has been defined for : ' + currentSObject.getSObjectType());
	}

	public static String createMapIdentifier (SObject currentSobject)
	{
		return createMapIdentifier (currentSobject, true);
	}

	public static String createMapIdentifier (Case currentCase)
	{
			return 'Case' 
   				+ (String) currentCase.get ('Origin')
				+ (String) currentCase.get ('suppliedEmail')
				+ (String) currentCase.get ('subject');
	}

    public static String createMapIdentifier (Open_Alert__c currentOpenAlert)
    {
            return 'Open Alert' 
                + (String) currentOpenAlert.get ('name')
                + (String) currentOpenAlert.get ('country_code__c')
                + (String) currentOpenAlert.get ('case_type__c')
                + (String) currentOpenAlert.get ('case_reason__c')
                + (String) currentOpenAlert.get ('category_level3__c')
                + (String) currentOpenAlert.get ('category_level4__c')
                + getDatePartString (currentOpenAlert, 'start_date__c')
                + getDatePartString (currentOpenAlert, 'end_date__c');
    }

	public static String createMapIdentifier (Trend__c currentTrend)
	{
			return 'Trend' 
   				+ (String) currentTrend.get ('country_code__c')
				+ (String) currentTrend.get ('bbe_Date__c')
				+ (String) currentTrend.get ('production_line__c')
				+ (String) currentTrend.get ('product__c');
	}

    public static String createMapIdentifier (Task currentTask)
    {
            return 'Task' 
                + (String) currentTask.get ('whatId')
                + (String) currentTask.get ('template_id__c')
                + (String) currentTask.get ('subject')
                + getDatePartString (currentTask, 'activityDate');
    }

    @testVisible private static String getDatePartString (SObject currentSObject, String fieldName)
    {
        return (currentSObject.get (fieldName) != null) 
                   ? ((Datetime) currentSObject.get (fieldName)).format('yyyy/mm/dd') 
                   : (fieldName + '=NULL');
    }

	private class MapIdentifierUndefinedException extends Exception {}
}