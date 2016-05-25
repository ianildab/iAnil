public class ECICCaseTriggerProductionLineCache 
{
    /**
     * 
     *  We are not using "final" with these caches because we wish to avoid race conditions.
     *
     *  Likewise, these get will return more data than required, but the logic to filter this will be too convoluted.
     *
     *  However, the surplus data is expected to be harmless.
     *
     **/
                 
    @testVisible private static Map<Id, Set<Id>> productionLineIdSetByPlantIdCache = new Map<Id, Set<Id>>();  
    public  static Map<Id, Set<Id>> getProductionLineIdSetByPlantIdMap() { return productionLineIdSetByPlantIdCache; }
    
    @testVisible private static Map<String, Production_Line__c[]> productionLineByPlantCodeCache = new Map<String, Production_Line__c[]>();
    public  static Map<String, Production_Line__c[]> getProductionLineByPlantCodeMap() { return productionLineByPlantCodeCache; }
    
    private static final Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);

    public static void populate (List<Case> currentCaseList)
    {
        Set<Id> plantIdSet = new Set<Id>();
        Set<String> plantCodeSet = new Set<String>();
        String developerName;
        for (Case currentCase : currentCaseList) {
        
          developerName= RECORD_TYPES_BY_ID_MAP.get(currentCase.RecordTypeID).DeveloperName; 
            if (currentCase.plant__c != null) { plantIdSet.add (currentCase.plant__c); }
            
            if (currentCase.Production_Code__c != null && currentCase.Production_Code__c.length() > 2 && developerName.contains(ECICCommonConstants.GERMANY_REGION)) {
                plantCodeSet.add(currentCase.Production_Code__c.substring(0,3));
            }
            else if(currentCase.Production_Code__c != null && currentCase.Production_Code__c.length() > 1 &&  developerName.contains(ECICCommonConstants.IBERIA_REGION) ) {
                 plantCodeSet.add(currentCase.Production_Code__c.substring(0,2));
            }
        }
        
        Map<Id, Production_Line__c> productionLineByIdMap = new Map<Id, Production_Line__c>([
                                                                                                SELECT Id, Name, Plant__c, Plant__r.Id, Plant__r.Bottler__c
                                                                                                FROM Production_Line__c
                                                                                                WHERE Plant__c IN :plantIdSet OR
                                                                                                      Name IN: plantCodeSet
                                                                                            ]);

        Map<Id, Set<Id>> productionLineIdSetByPlantIdMap = new Map<Id, Set<Id>>();
        Map<String, Production_Line__c[]> productionLineMap = new Map<String, Production_Line__c[]>(); 
        String prodLineCode = null;
        for (Production_Line__c productionLine: productionLineByIdMap.values()) 
        {
            Set<Id> productionLineIdSet = null;
            if (!productionLineIdSetByPlantIdMap.containsKey(productionLine.Plant__c)) 
            {
                 productionLineIdSetByPlantIdMap.put(productionLine.Plant__c, new Set<Id>());
            }
            productionLineIdSetByPlantIdMap.get(productionLine.Plant__c).add(productionLine.Id);
            
           if(developerName.contains(ECICCommonConstants.IBERIA_REGION)){
               prodLineCode = productionLine.Name.substring(0, 2).toLowerCase();
           } else if(developerName.contains(ECICCommonConstants.GERMANY_REGION)){
               prodLineCode = productionLine.Name.substring(0, 3).toLowerCase();
           }
           
          
            if (!productionLineMap.containsKey(prodLineCode)) {
                productionLineMap.put(prodLineCode, new List<Production_Line__c>());
            }
            productionLineMap.get(prodLineCode).add(productionLine);
        }
        productionLineIdSetByPlantIdCache.putAll(productionLineIdSetByPlantIdMap);
        productionLineByPlantCodeCache.putAll(productionLineMap);
    }

}