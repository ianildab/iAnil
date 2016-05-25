// Helper class to reduce need for looking up record type Ids multiple times.
// @see: http://salesforce.stackexchange.com/questions/11968/what-would-be-the-best-approach-to-get-the-recordtype-id
public class SEPRecordTypesCache 
{
	// Build a local cache so that we don't request this multiple times
	private static Map<Schema.SObjectType,Map<String,Id>> 	  recordTypeIdByDeveloperNameCache = new Map<Schema.SObjectType,Map<String,Id>>();
    private static Map<Schema.SObjectType,Map<String,Id>>     recordTypeIdByNameCache         = new Map<Schema.SObjectType,Map<String,Id>>();
	private static Map<Schema.SObjectType,Map<Id,RecordType>> recordTypesByIdCache			  = new Map<Schema.SObjectType,Map<Id,RecordType>>(); 
	
	// Returns a map of active, user-available RecordType IDs for a given SObjectType,
	// keyed by each RecordType's unique, unchanging DeveloperName 
	public static Map<String, Id> getRecordTypeIdsByDeveloperNameMap( Schema.SObjectType token ) 
	{
	    if (
	    		   (recordTypeIdByDeveloperNameCache == null)
	    		|| (recordTypeIdByDeveloperNameCache.get(token) == null)
	    		|| (recordTypeIdByDeveloperNameCache.get(token).isEmpty())
	       )	
	       { 
	       		buildCaches ( token ); 				// If not, build a map of RecordTypeIds keyed by DeveloperName
	       }										 
	    return recordTypeIdByDeveloperNameCache.get(token);
	}

    public static Map<String, Id> getRecordTypeIdsByNameMap( Schema.SObjectType token ) 
    {
        if (
                   (recordTypeIdByNameCache == null)
                || (recordTypeIdByNameCache.get(token) == null)
                || (recordTypeIdByNameCache.get(token).isEmpty())
           )    
           { 
                buildCaches ( token );              // If not, build a map of RecordTypeIds keyed by DeveloperName
           }                                         
        return recordTypeIdByNameCache.get(token);
	}

	// Returns a map of active, user-available RecordType IDs for a given SObjectType,
	// keyed by each RecordType's unique, unchanging DeveloperName 
	public static Map<Id,RecordType> getRecordTypesByIdMap( Schema.SObjectType token ) 
	{
	    if (
	    		   (recordTypesByIdCache == null)
	    		|| (recordTypesByIdCache.get(token) == null)
	    		|| (recordTypesByIdCache.get(token).isEmpty())
	       )	
	       { 
	       		buildCaches ( token ); 				// If not, build a map of RecordTypeIds keyed by DeveloperName
	       }										 
	    return recordTypesByIdCache.get(token);
	}
	
	private static void buildCaches ( Schema.SObjectType token )
	{
        Map<String, Id>    recordTypeIdByDevNameMap = recordTypeIdByDeveloperNameCache.get(token);                  // Do we already have a result?
        Map<String, Id>    recordTypeIdByNameMap    = recordTypeIdByNameCache.get(token);                  // Do we already have a result?
		Map<Id,RecordType> recordTypeByIdMap 		= recordTypesByIdCache.get(token);	
	    if (recordTypeIdByDevNameMap == null)																	// If not, build a map of RecordTypeIds keyed by DeveloperName 
	    {
	    	recordTypeIdByDevNameMap = new Map<String, Id>();
	    	recordTypeIdByDeveloperNameCache.put(token, recordTypeIdByDevNameMap);

            recordTypeIdByNameMap = new Map<String, Id>();
            recordTypeIdByNameCache.put(token, recordTypeIdByNameMap);
	    	
	    	recordTypeByIdMap		 = new Map<Id,RecordType>();
	    	recordTypesByIdCache.put (token, recordTypeByIdMap);
	    }

	    Schema.DescribeSObjectResult obj = token.getDescribe();										// Get the Describe Result
	    String soql = 'SELECT Id, Name, DeveloperName '											    // Obtain ALL Active Record Types for the given SObjectType token
			        + 'FROM RecordType '
			        + 'WHERE SObjectType = \'' + String.escapeSingleQuotes(obj.getName()) + '\' '	// (We will filter out the Record Types that are unavailable
			        + 'AND IsActive = TRUE';														// to the Running User using Schema information)

	    List<SObject> resultList;
	    try { resultList = Database.query(soql); } 
	    catch (Exception ex) { resultList = new List<SObject>(); }
	    
	    Map<Id,Schema.RecordTypeInfo> recordTypeInfoMap = obj.getRecordTypeInfosByID();				// Obtain the RecordTypeInfos for this SObjectType token
	    
	    for (RecordType recordType : (List<RecordType>) resultList) 								// Loop through all of the Record Types we found,
	    {  																							//      and weed out those that are unavailable to the Running User
			//        if (recordTypeInfoMap.get(recordType.Id).isAvailable()) -- not used because we do NOT want this to be User sensitive. 									 
	        {																						// This RecordType IS available to the running user,
	            recordTypeIdByDevNameMap.put(String.valueOf(recordType.get('DeveloperName')),recordType.Id);	//      so add it to our map of RecordTypeIds by DeveloperName
                recordTypeIdByNameMap.put(String.valueOf(recordType.get('Name')),recordType.Id);    //      so add it to our map of RecordTypeIds by DeveloperName
	            recordTypeByIdMap.put(recordType.Id, recordType);										//      so add it to our map of RecordTypeIds by DeveloperName
	    }
		}
	}
}