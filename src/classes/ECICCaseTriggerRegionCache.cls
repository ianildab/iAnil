public class ECICCaseTriggerRegionCache 
{
    @testVisible private static Map<Id, Region__c> regionByIdCache = new Map<Id, Region__c>();
    
    @testVisible private static Map<Id, Plant__c> plantByIdCache = new Map<Id, Plant__c>();
    
    //@testVisible private static Map<String, Plant__c> plantByNameCache = new Map<String, Plant__c>();
    
    public  static Map<Id, Region__c> getRegionByIdMap() { return regionByIdCache; }
     public  static Map<Id,Geo_Mapping__c> geoMappingByCityMap = new Map<Id,Geo_Mapping__c>();    
    public  static Map<Id, Plant__c> getPlantByIdMap() { return plantByIdCache; }
    
    @testVisible public  static Map<Id, CCE_Product__c> unknownProductByIdMap = new Map<Id, CCE_Product__c>(); 
    
    @testVisible public  static Map<Id, CCE_Product__c> productByIdMap = new Map<Id, CCE_Product__c>();
    
  //  public static Map<Id, City__c> getCityByIdMap() { return  CityByIdCache; }
    
    //public  static Map<String, Plant__c> getPlantByNameMap() { return plantByNameCache;}
    
  @testVisible private static Map<Id, RecordType> recordTypeByIdCache = new Map<Id, RecordType>();  
    public static void populate ()
    {
        if(regionByIdCache.size() == 0){ 
        Map<Id, Region__c> regionByIdMap = new Map<Id, Region__c>([
                            SELECT id, bottler__c, bottler__r.name, bottler_quality__c, bottler_quality_manager__c, bottler_external_relations__c  ,Area__c, Name                                                                   
                                                                            FROM Region__c 
                                                                   ]);
                                                                           
         regionByIdCache.putAll(regionByIdMap);
        }
        
        if(plantByIdCache.size() == 0){
                          Map<Id, Plant__c> plantByIdMap = new Map<Id, Plant__c>([
                            SELECT id,CCE_Bottler__c,LCBU_Plant_Code__c,bottler__c, Region__r.name, Region__c, Region__r.bottler_quality__c, SABU_Plant_Region__c , Region__r.Area__c, Name, Country_Code__c, SABU_Add_Sample_Collector__c                                                           
                                                                            FROM Plant__c 
                                                                   ]);
                                                                   
        plantByIdCache.putAll(plantByIdMap);
        }
        
         
    }
    
    public  static Map<String, Plant__c> getPlantByNameMap() {
        
        populate();
        
        Map<Id, Plant__c> plants = getPlantByIdMap();
        
        Map<String, Plant__c> plantsbyName = new Map<String, Plant__c>();
        
        for(Id key: plants.keySet()){
            
            Plant__c plant = plants.get(key);
            //system.debug('plant.Name='+plant.Name);           
            plantsbyName.put(plant.Name,plant);
        }
        
        return plantsbyName;
    }
    
     public  static Map<String, Plant__c> getPlantByCodeMap() {
        
        populate();
        
        Map<Id, Plant__c> plants = getPlantByIdMap();
        
        Map<String, Plant__c> plantsbyCode = new Map<String, Plant__c>();
        
        for(Id key: plants.keySet()){
            
            Plant__c plant = plants.get(key);
            //system.debug('plant.Name='+plant.Name);           
            plantsbyCode.put(plant.LCBU_Plant_Code__c,plant);
        }
        
        return plantsbyCode;
    }
    
    public  static Map<Id, Production_Line__c> getLineByIdMap() {
        
        Map<Id, Production_Line__c> lineByIdMap = new Map<Id, Production_Line__c>([SELECT id, Plant__c, Name,Content__c,Pack__c,Country_code__c FROM Production_Line__c where Active__c = true]);
        
        return lineByIdMap;
    }
    
    public  static Map<Id, CCE_Product__c> getUnknownProductByIdMap() {
        if(unknownProductByIdMap.size() == 0){
        unknownProductByIdMap = new Map<Id, CCE_Product__c>([
                            SELECT id,  Name  FROM CCE_Product__c where Name = 'Unknown'
                                                                   ]);
        }
        return unknownProductByIdMap;
    }
    
    public  static Map<Id, Plant__c> getUnknownPlantByIdMap() {
        
        Map<Id, Plant__C> plantByIdMap = new Map<Id, Plant__c>([
                            SELECT id,  Name  FROM Plant__c where Name = 'Unknown'
                                                                   ]);
        return plantByIdMap;
    }
    
    public  static Map<Id, CCE_Product__c> getActiveCCEProductByIdMap() {
        if(productByIdMap.size() == 0){
        productByIdMap = new Map<Id, CCE_Product__c>([
                            SELECT id,  Name,Country_Code__c,Packaging__c,Size__c  FROM CCE_Product__c where Active__c = true
                                                                   ]);
        }
        return productByIdMap;
    }
    
    public static List<Group> getNWENGroups(){
        List<Group> nwenGruops = [Select g.Type, g.Name, g.Id, g.DeveloperName From Group g where DeveloperName IN ('BELUX_ECIC_ALL','FR_ECIC_ALL','GB_ECIC_ALL')];
        return nwenGruops;
    
   }
    /*public static List<Contact> getMktIntliAnalystContacts(){
        List<Contact> contacts = [Select id, country_code__c,name,Contact_Type__c From Contact where Contact_Type__c = :ECICCommonConstants.MKT_INTELI_ANALYST_ROLE_NAME];
        return contacts;
    
   }*/
    public static List<Contact> getMktIntliAnalystContacts(String caseCountry){
        List<Contact> contacts = [Select id, country_code__c,name,Contact_Type__c From Contact where Contact_Type__c = :ECICCommonConstants.MKT_INTELI_ANALYST_ROLE_NAME and Contact.RecordType.DeveloperName = :ECICCommonConstants.CIC_CONTACT_RT and country_code__c = :caseCountry];
        return contacts;
    
   }
   
    //added by Sagar Madkaikar
    public static List<Case_Team_User__c> getMktIntliAnalystCaseTeamUser(String caseCountry){
        List<Case_Team_User__c > cUser = [Select id,Contact__c,Country_Code__c,Name,Type__c  From Case_Team_User__c  where Type__c = :ECICCommonConstants.MKT_INTELI_ANALYST_ROLE_NAME  and Country_Code__c = :caseCountry];
        return cUser;
    
   }
    
    // added by Amit Ghadage
    public static Map<Id,Geo_Mapping__c> getgeoMappingByCityMap()
    {
        if(geoMappingByCityMap.size() == 0){ 
         
        for(Geo_Mapping__c gm : [SELECT Bottler__c,City__c,Id,Name,Plant__c,
                                 Province__c,Unique_City__c FROM Geo_Mapping__c])
        {
            geoMappingByCityMap.put(gm.City__c, gm);
        }
        }
        return geoMappingByCityMap;
    }
    
    public static Map<Id,RecordType> getRecordType(String callFrom,String extraParam)
    {
    	
    	// ECICCommonConstants RECORDTYPE_BY_DEVELOPERNAME_EQUAL RECORDTYPE_BY_DEVELOPERNAME_CONTAINS RECORDTYPE_BY_SOBJECT_TYPE CASE_RECORDTYPE_BY_DEVELOPERNAME
    	  if(recordTypeByIdCache.size() == 0)
    	  { 
        			recordTypeByIdCache = new Map<Id, RecordType>([
                    Select r.SobjectType, r.NamespacePrefix, r.Name, r.IsPersonType, r.IsActive, r.Id, r.DeveloperName,
                    r.Description From RecordType r]);
                          
    	  }
    	  
    	 /* if(callFrom == 'ECICCaseDispatherHelper' || callFrom == 'HUB_CaseReportsController' || callFrom == 'HUB_CaseTriggerHelper_hubCaseSendRelatedMarketNotification')
    	  {
		    	  Map<Id,RecordType> caseRecordTypeMap = new Map<Id,RecordType>();
		    	  
		    	  for(RecordType rt : recordTypeByIdCache.values())
		    	  {
			    	  	if(rt.SobjectType == 'Case' && rt.isActive == true)
			    	  	caseRecordTypeMap.put(rt.Id,rt);
		    	  }
		    	  
		    	    return caseRecordTypeMap;
    	  }*/
    	  
    	//  if(callFrom == 'ECICRecordTypeDao_findByDeveloperName' ||callFrom == 'HUB_CaseTriggerHelper_hubCaseTriggerListIdentifier'
    	  //		 || callFrom =='HUB_ConsolidatedLogHelper' || callFrom == 'HUB_TriggerCaseListSeparate')
    	  		 if(callFrom == ECICCommonConstants.RECORDTYPE_BY_DEVELOPERNAME_EQUAL )
    	 	 {
	    	  	  Map<Id,RecordType> caseRecordTypeMap = new Map<Id,RecordType>();
	    	  	  for(RecordType rt : recordTypeByIdCache.values())
		    	  {
			    	  	if(rt.developerName == extraParam)
			    	  	caseRecordTypeMap.put(rt.Id,rt);
		    	  }
		    	  
		    	    return caseRecordTypeMap;
    	  	
    	  }
    	  
    	  if(callFrom == ECICCommonConstants.RECORDTYPE_BY_DEVELOPERNAME_CONTAINS )
    	  {
    	  	 Map<Id,RecordType> caseRecordTypeMap = new Map<Id,RecordType>();
    	  	  for(RecordType rt : recordTypeByIdCache.values())
		    	  {
			    	  	if(rt.developerName.Contains(extraParam))
			    	  	caseRecordTypeMap.put(rt.Id,rt);
		    	  }
		    	  
		    	    return caseRecordTypeMap;
    	  	
    	  }
    	  
    	  if(callFrom == ECICCommonConstants.CASE_RECORDTYPE_BY_DEVELOPERNAME)
    	  {
    	  	 Map<Id,RecordType> caseRecordTypeMap = new Map<Id,RecordType>();
    	  	  for(RecordType rt : recordTypeByIdCache.values())
		    	  {
			    	  	if(rt.SobjectType=='Case' && rt.developerName == extraParam)
			    	  	caseRecordTypeMap.put(rt.Id,rt);
		    	  }
		    	  
		    	    return caseRecordTypeMap;
    	  	
    	  }
    	  
    	   if(callFrom == ECICCommonConstants.RECORDTYPE_BY_SOBJECT_TYPE)
    	  {
		    	  Map<Id,RecordType> RecordTypeMap = new Map<Id,RecordType>();
		    	  
		    	  for(RecordType rt : recordTypeByIdCache.values())
		    	  {
			    	  	if(rt.SobjectType == extraParam && rt.isActive == true)
			    	  	RecordTypeMap.put(rt.Id,rt);
		    	  }
		    	  
		    	    return RecordTypeMap;
		    	   
    	  }
    	  
    	     return null;
    	}

    
    }