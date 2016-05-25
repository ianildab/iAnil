global class ECICGlobalUpdateJob implements Database.batchable<sObject>{
	/**
	 * GlobalUpdateJob is a sfdc batchable database job for updating fields on selected group of object
	 * 
	 * using:
	 * 		 type a following code in sfdc developer console
	 * 		 Database.executeBatch(new ECICGlobalUpdateJob(
	 * 														YOU_QUERY_FOR_SELECT_OBJECT_FOR_UPDATE, 
	 * 														List<String> Names of fields to update,
	 * 														List<String> Values which would write to fields 
	 * 														),  <optional parameter SCOPE. This parameter specifies
	 *														the number of records that should be passed into the execute method.> );
	 * sample:
	 * 		List<String> fieldsToUpdate = new String[]{'Name', 'Description', 'AnyCustomField__c'};
	 * 		List<String> valueForUpdate = new String[]{'New Name', 'New Description', 'New Value for custom field'};
	 * 		Database.executeBatch(new ECICGlobalUpdateJob( 'SELECT Name, Description, AnyCusstomField__c FROM Case WHERE Country__c = 'US'',
	 * 														fieldsToUpdate,valueForUpdate), 200);
	 *  This job will update 200 records of Cases which was selected with query and will update fields:
	 *  	Name = 'New Name'
	 *  	Description = 'New DEscription'
	 *  	AnyCustomField__c = New Value for custom field
	 * 
	 * If you need to using boolean value write it as a string ( true == 'true' and false == 'false').
	 */
		  
	private List<String> updValues;
	private String currentQuery;
	private List<Boolean> boolValues;
	private List<String> fieldsToUpdate;
		   
	global ECICGlobalUpdateJob(String query, List<String> fieldsToUpdate, List<String> updValues){
		if(fieldsToUpdate.size() == updValues.size()){
			this.updValues = new String[updValues.size()];
			this.fieldsToUpdate = new String[updValues.size()];
            this.boolValues = new Boolean[updValues.size()];
		    this.currentQuery = query;
		    for(Integer i = 0; i < fieldsToUpdate.size();i++){
		    	if(updValues[i].equals('true')){ 
		    		this.boolValues[i] = true;
				}else if (updValues[i].equals('false')){
				    this.boolValues[i] = false;       	
				}else{
				    this.updValues[i] = updValues[i];
				}
				this.fieldsToUpdate[i] = fieldsToUpdate[i];
		    }
		}
	}
		   
	global Database.QueryLocator start(Database.BatchableContext BC){
		return getAllQueryLocator(currentQuery);
	}
    
	global void execute(Database.BatchableContext info, List<sObject> scope){
		List<sObject>  objectToUpdate = new List<sObject>();
        for(sObject sO: scope){ 
        	for(Integer i = 0; i < fieldsToUpdate.size();i++){ 
        		if(this.boolValues[i] != null){
        			sO.put(this.fieldsToUpdate[i], this.boolValues[i]);
        		}else{
        			sO.put(this.fieldsToUpdate[i], this.updValues[i]);
        		}
        	}
        	objectToUpdate.add(sO);
        }
        try{
        	update objectToUpdate;
        }catch(DMLException e){
        	System.debug(e);
        }
    }
	global void finish(Database.BatchableContext info){     

	}  		   
		   
	private Database.QueryLocator getAllQueryLocator(String query){
		return Database.getQueryLocator(query);
	}
}