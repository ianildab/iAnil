public  class ECICRecordTypeDao 
{
    public static RecordType findByDeveloperName(String name) {
    	return getFirstResult(ECICCaseTriggerRegionCache.getRecordType(ECICCommonConstants.RECORDTYPE_BY_DEVELOPERNAME_EQUAL,name).Values());
       // return getFirstResult([SELECT id FROM RecordType WHERE developerName = :name]);
    }
    
    private static RecordType getFirstResult(RecordType[] resultList) {
        return (! resultList.isEmpty()) ? resultList.get(0) : null;
    }
    
    public static List<Recordtype> findRecordTypesByRegion(String name){
        String nameFilter = '%' + name + '%';
        return ECICCaseTriggerRegionCache.getRecordType(ECICCommonConstants.RECORDTYPE_BY_DEVELOPERNAME_CONTAINS,nameFilter).Values();
        //return [SELECT DeveloperName,Id FROM RecordType WHERE DeveloperName LIKE : nameFilter ];
    }
}