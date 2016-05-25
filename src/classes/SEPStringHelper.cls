public class SEPStringHelper 
{
    public static String joinRelatedRecordFields ( String sObjectName,  List<String> fieldNameList, String seperator)
    {
    	sObjectName = sObjectName.replace('__c', '__r');
    	List<String> modifiedFieldNameList = new List<String>();
    	for (String fieldName : fieldNameList)
    	{
    		modifiedFieldNameList.add(sObjectName + '.' + fieldName); 
    	}
    	return String.join (modifiedFieldNameList, seperator);
    }
}