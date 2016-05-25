public /* with sharing */ class ECICRegionDao {
	
    public static List<Region__c> findByBottlerFields(Set<ID> ids) {
        String[] conditions = new String[ECICCommonConstants.BOTTLER_FIELDS.size()];
        integer i = 0;
        
        for (String fld : ECICCommonConstants.BOTTLER_FIELDS) {
            conditions[i++] = fld + ' in (\'' + String.join(new List<Id>(ids), '\'' + ECICCommonConstants.COMMA_DEL + '\'') + '\')'
                        + ' or ' + fld + '= null';
        }
        
        String query = ECICCommonConstants.SELECT_REGION + ' where ' + String.join(conditions, ' or ' );   
        system.debug('CIC: case query:' + query);

        return Database.query(query);
    }
    
    public static List<Region__c> findByExtIds(Set<String> extIds) {
    	return [SELECT id, Name, Region_Ext_Id__c FROM Region__c WHERE Region_Ext_Id__c IN :extIds];
    }
}