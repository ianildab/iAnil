/*This class used for decoding production code entered by the user and populate case field based on the decoding logic only for NWEN Quality Complaint
 *Created By: Balmukund Jangir
 *Created On: 11/05/2015
 */


public class CCEProductionCodeDecoding {
    
    private static Map<String, CCE_Production_Code_Decode__c> plants = new Map<String, CCE_Production_Code_Decode__c>();
    //private static Map<Id, CCE_Production_Code_Decode__c> plantsByPlantIdentifier = ECICCaseTriggerRegionCache.plantByPlantIdentifier();
    private static Map<String, Plant__c> plantsbyName = ECICCaseTriggerRegionCache.getPlantByNameMap();
    private static Map<String, Plant__c> plantsbyCode = ECICCaseTriggerRegionCache.getPlantByCodeMap();
    private static Map<Id, Production_Line__c> lineByIdMap = ECICCaseTriggerRegionCache.getLineByIdMap();
    private static Map<Id, CCE_Product__c> unknownProduct = ECICCaseTriggerRegionCache.getUnknownProductByIdMap();
    private static Map<Id, Plant__c> unknownPlant = ECICCaseTriggerRegionCache.getUnknownPlantByIdMap();
    private static Map<Id, Plant__c> allPlant = ECICCaseTriggerRegionCache.getPlantByIdMap();
    private static final Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);
    private static final List<Group> nwenGruops = ECICCaseTriggerRegionCache.getNWENGroups();
    private static Map<Id, CCE_Product__c> cceProducts = ECICCaseTriggerRegionCache.getActiveCCEProductByIdMap();
    //private static String developerNameRT;
    private static List<CCE_Product__Share> cceProductSharing = new List<CCE_Product__Share>();
    public static boolean isInsert = true;
    //Before Insert of Case
    public static void populateProductionCodeBeforeInsert(List<Case> newValues){
        
       
        
        for(Case caseObj:newValues){
            String developerNameRT = RECORD_TYPES_BY_ID_MAP.get(caseObj.RecordTypeID).DeveloperName;
            String caseBU = getCaseBU(developerNameRT);
            
            
            if(caseObj.Production_Code__c != null && (developerNameRT == ECICCommonConstants.NWEN_QUALITY_COMPLAINT_DEVNAME || developerNameRT == ECICCommonConstants.LCBU_QUALITY_COMPLAINT_DEVNAME || developerNameRT == ECICCommonConstants.SABU_QUALITY_COMPLAINT_DEVNAME)){
                if(caseObj.Production_Code__c != null)
                readProductionCode(caseObj.Production_Code__c, caseObj,caseBU);
            }
            
            if(developerNameRT == ECICCommonConstants.NWEN_QUALITY_COMPLAINT_DEVNAME || developerNameRT == ECICCommonConstants.LCBU_QUALITY_COMPLAINT_DEVNAME || developerNameRT == ECICCommonConstants.SABU_QUALITY_COMPLAINT_DEVNAME){
                populateLaboratoryOfAnalysis(caseObj);
            }
        }
         
        //Inserting sharing of CCE Product
        if(cceProductSharing.size() > 0 && TriggerContextUtility.isInserted()){
            
            insert cceProductSharing;
            TriggerContextUtility.setIsInserted();
            
        }
        
     //Updating City of case from consumer's city for SABU quality Case
        ECICSABUFunctionalUtility.updateCaseCityFromConsumerCity(newValues,null); 
        
        ECICSABUFunctionalUtility.populateBottlerFromPlant(newValues,null);
           
    }
    
    //Before Update of Case
    public static void populateProductionCodeBeforeUpdate(List<Case> newValues,Map<ID,Case> oldValuesMap){
        
       List<Case> oldValues = oldValuesMap.values();
        
        for(Integer i = 0; i < newValues.size(); i++){
            
            Case caseObjNew = newValues.get(i);
            Case caseObjOld = oldValues.get(i);
            
            String developerNameRT = RECORD_TYPES_BY_ID_MAP.get(caseObjNew.RecordTypeID).DeveloperName;
            
            String caseBU = getCaseBU(developerNameRT);
            
            //Checking if product or production code has been updated then only produciton code decoding logic will run
            if(developerNameRT == ECICCommonConstants.NWEN_QUALITY_COMPLAINT_DEVNAME || developerNameRT == ECICCommonConstants.LCBU_QUALITY_COMPLAINT_DEVNAME || developerNameRT == ECICCommonConstants.SABU_QUALITY_COMPLAINT_DEVNAME){
                //if Produciton Code is changed then stting blank fields which were set at first
                
                
                if(caseObjNew.Production_Code__c != null && ((caseObjNew.Production_Code__c != caseObjOld.Production_Code__c) || caseObjNew.CCE_Product__c != caseObjOld.CCE_Product__c || caseObjNew.Text_BBE_Date__c != caseObjOld.Text_BBE_Date__c)){
                    if(caseObjNew.Production_Code__c != null)
                        blankPolulatedFields(caseObjNew);
                        isInsert = false;
                        readProductionCode(caseObjNew.Production_Code__c, caseObjNew,caseBU);
            
                }else if(caseObjNew.Production_Code__c == null && caseObjOld.Production_Code__c != null){
                    blankPolulatedFields(caseObjNew); 
                }
                
                populateLaboratoryOfAnalysis(caseObjNew);
            }
            
           
            
            
        }
        
        //Inserting sharing of CCE Product
        if(cceProductSharing.size() > 0 && TriggerContextUtility.isInserted()){
            insert cceProductSharing;
            TriggerContextUtility.setIsInserted();
        }
         //Updating City of case from consumer's city for SABU quality Case
        ECICSABUFunctionalUtility.updateCaseCityFromConsumerCity(newValues,oldValuesMap);
        
        //Update bottler from Plant
        ECICSABUFunctionalUtility.populateBottlerFromPlant(newValues,null);
    }
    
   
    //Reading all the required values from custom setting record to decode production code
    public static void readProductionCode(String producitonCode,Case newCase,String caseBU){
        
        if(unknownProduct.containsKey(newCase.CCE_Product__c) && newCase.CCE_Product__c != null && 'Unknown'.equalsIgnoreCase(producitonCode))
            return;
            
        CCE_Production_Code_Decode__c  plantObj;
        
        //To get Wild Plant
        if(producitonCode.startsWith('L') && producitonCode.length() == 13){
            plantObj =  plants.get('Wild13');           
        }else if(producitonCode.length() == 7 && producitonCode == newCase.Text_BBE_Date__c ){
            plantObj =  plants.get('Wild7');
        }else{ //If plant is other then Wild
            plantObj = getPlantFromProductionCode(producitonCode,caseBU);
        }
        
               
        
        Integer ProdCodeLength = producitonCode.length();
        
        if(newCase.CCE_Product__c == null){
            newCase.addError(System.Label.CCE_Product_Mandatory);
            return;
        }
        if(newCase.Text_BBE_Date__c == null){
            newCase.addError(System.Label.CCE_BBE_Date_Mandatory);
            return;
        }
            
        
        if(plantObj == null || (plantObj != null && ProdCodeLength != plantObj.Prod_Code_Length__c)){
            newCase.addError(System.Label.CCE_Invalid_Production_Code);
            return;
        }else {
                    
            String[] prodTime;
            String[] days;
            String dayOfYear;
            String productionTime;
            String leg = '';
            String productYear = '';
            
            if(plantObj.Time_Position__c != null){
                prodTime = plantObj.Time_Position__c.split(',');
            }
            
            if(plantObj.Day_Position__c != null){
                
                days =  plantObj.Day_Position__c.split(',');
                
            }
            
            if(days != null){
                dayOfYear = producitonCode.substring(integer.ValueOf(days[0])-1, integer.ValueOf(days[days.size()-1]));
                
            }
            
            
             if((dayOfYear != null && !dayOfYear.isNumeric())){
                newCase.addError(System.Label.CCE_Invalid_Production_Code);
                return;
             }
            
            Integer day;
            
            if(dayOfYear != null){
                day = Integer.valueOf(dayOfYear);
                            
                if(day < 1 || day > 366){
                    newCase.addError(System.Label.CCE_Invalid_Production_Code);
                    return;
                }
            }
            
            if(prodTime != null){
                productionTime = producitonCode.substring(integer.ValueOf(prodTime[0])-1, integer.ValueOf(prodTime[prodTime.size()-1]));
                boolean isValid = isValidTime(productionTime,plantObj);
                if(!isValid){
                    newCase.addError(System.Label.CCE_Invalid_Production_Time);
                    return;
                }
            }
            
            
            //If leg position mentioned in custom setting record then populate Leg pn case     
            if(plantObj.Leg_Position__c != null){
                Integer legPosition = Integer.valueOf(plantObj.Leg_Position__c);
                leg = producitonCode.substring(legPosition-1,legPosition); 
            }    
            
            if(plantObj.Production_Year_Position__c != null){       
                String[] prodYear = plantObj.Production_Year_Position__c.split(',');                
                productYear = producitonCode.substring(integer.ValueOf(prodYear[0])-1, integer.ValueOf(prodYear[prodYear.size()-1]));
                system.debug('productYear = '+productYear);
            }
            
            if(plantObj.Time_Position__c == null)
                newCase.Production_Time__c = '';
            
            
        newCase.Production_DayNWEN__c = dayOfYear;
        populatePlantandLine(plantObj ,newCase,leg,productionTime);
        }
        
        if(plantObj != null){
            CCEBBECodeDecode.decodeBBEDateandPopulateProductionDate(plantObj, newCase);
        }
        //}
    }
    
     //Returning custom setting record of corrosponding plant from produciton code
    public static CCE_Production_Code_Decode__c getPlantFromProductionCode(String producitonCode,String caseBU){      
        plantByPlantIdentifier(caseBU) ;
        String plantName = '';
        Boolean foundPlant = false;
        for (String key : plants.keySet()) {
            System.debug('key='+key);
            CCE_Production_Code_Decode__c custObj = plants.get(key);
            
            if(custObj != null && producitonCode != null){
                if(((producitonCode.containsIgnoreCase(key) && custObj.Name_Start_From__c == False) || (producitonCode.startsWith(key) && custObj.Name_Start_From__c == True)) && producitonCode.length() == custObj.Prod_Code_Length__c && custObj.Business_Unit__c == caseBU){
                    
                    System.debug('Plant='+key);
                    plantName = key;
                    foundPlant = true;
                    break;
                    
                }else if(producitonCode.containsIgnoreCase(':') && custObj.Business_Unit__c == caseBU && custObj.Colon_Position__c != null && producitonCode.indexOf(':') == Integer.valueOf(custObj.Colon_Position__c)-1 && producitonCode.length() == custObj.Prod_Code_Length__c){
                    
                    plantName = key;
                    foundPlant = true;
                    break;
                }
            }
        }
        
        if( producitonCode.length() == 10 && !foundPlant && producitonCode.isNumeric()){
            plantName = 'Telemark';
        }
        
        CCE_Production_Code_Decode__c planObj = plants.get(plantName);
        return planObj;
    }
    
    
    //Populating plant, produciton line, production days etc fields on Case
    private static void populatePlantandLine(CCE_Production_Code_Decode__c plantObj1,Case newCase,String leg,String prodTime){
        
        String lineName;
        Plant__c plantObj;
        String developerNameRT = RECORD_TYPES_BY_ID_MAP.get(newCase.RecordTypeID).DeveloperName;
        
        if(developerNameRT == ECICCommonConstants.LCBU_QUALITY_COMPLAINT_DEVNAME || developerNameRT == ECICCommonConstants.SABU_QUALITY_COMPLAINT_DEVNAME){
            plantObj = plantsbyCode.get(plantObj1.LCBU_Plant_Code__c);
        
        }if(developerNameRT == ECICCommonConstants.NWEN_QUALITY_COMPLAINT_DEVNAME){
            plantObj = plantsbyName.get(plantObj1.Plant__c);
        
        }
        
        //Plant__c plantObj = plantsbyName.get(plantObj1.Plant__c);
        
        //For Wild Co-Packers plant
        if(plantObj1.Plant__c == 'Wild' && newCase.Production_Code__c.length() != 8){
            
            lineName = newCase.Text_BBE_Date__c.substring(newCase.Text_BBE_Date__c.length()-1,newCase.Text_BBE_Date__c.length());
            plantObj1.Production_Line__c = lineName;
        }else{ //Other then Wild Co-Packers plant
            
            lineName = plantObj1.Production_Line__c;
        }
       // newCase.addError('Plant='+lineName +'plantObj '+plantObj );
        
       /* CCE_Product__c productOnCase = cceProducts.get(newCase.CCE_Product__c);
        CCE_Product__c newProduct;
        Id productId;
        //Checking if associated product's country code is same as country of Plant, if not same then will associate product of the country of corrosponding plant
        if(plantObj != null && plantObj.Country_Code__c != productOnCase.Country_Code__c){
            for(Id key:cceProducts.keySet()){
                CCE_Product__c mapProduct = cceProducts.get(key);
                if(mapProduct.Name == productOnCase.Name && mapProduct.Country_Code__c == plantObj.Country_Code__c && mapProduct.Packaging__c == productOnCase.Packaging__c && mapProduct.Size__c == productOnCase.Size__c){
                    newProduct = mapProduct;
                    productId = mapProduct.id;
                    break;
                }
            }
        }
        
        if(newProduct != null){
            
            for(Group grup:nwenGruops){
                
                CCE_Product__Share productSharing = new CCE_Product__Share();
                productSharing.AccessLevel = 'Read';
                productSharing.RowCause = 'Manual';
                productSharing.UserOrGroupId = grup.id;
                productSharing.ParentId = productId;
                cceProductSharing.add(productSharing);
            }
            newCase.CCE_Product__c = productId;
        }*/
                
        Id plantId;
        Id lineId;
        
        if(plantObj != null)
            plantId = plantObj.id;
            
        List<Production_Line__c> matchingLines = new List<Production_Line__c>();
        
        //Creating a list of production line corrosponding to the plant taken from production code
        for(Id key:lineByIdMap.keySet()){
            
            Production_Line__c line = lineByIdMap.get(key);
            
            if(line.Plant__c == plantId && line.Name == lineName){
                
                matchingLines.add(line);
            }
        }
        
       
        boolean isValidLine = false;
        
        //checking if size and packaging of product matching with any of the production line corrosponding to the Plant, if matching then
        //boolean variable setting as true
        for(Production_Line__c proLine: matchingLines){
           
            lineId = proLine.Id;
            if(newCase.Size_Product__c == proLine.Content__c && newCase.Packaging__c == proLine.Pack__c){
                isValidLine = true;
                break;
            }
        }
        //Line pack validation only for NWEN quality complaint
        if(developerNameRT == ECICCommonConstants.NWEN_QUALITY_COMPLAINT_DEVNAME || developerNameRT == ECICCommonConstants.SABU_QUALITY_COMPLAINT_DEVNAME){               
            if(plantObj1.Production_Line__c !=null && !unknownProduct.containsKey(newCase.CCE_Product__c) && !isValidLine){
                    newCase.addError(System.Label.CCE_Prod_Code_Product_Missmatch);
                    return;
             }
        }
       
        if(plantId != null)
            newCase.Plant__c = plantId;
            newCase.LCBU_Plant_code__c = plantObj.LCBU_Plant_Code__c;
            newCase.Bottler__c = plantObj.bottler__c;
            //newCase.Laboratory_of_Analysis_NWEN__c = plantObj1.Plant__c;
        if(lineId != null)
            newCase.Production_Line__c = lineId;
        if(leg != null)
            newCase.Production_Leg__c = leg;
        if(prodTime != null)
            newCase.Production_Time__c = prodTime;
        
        
    }
   
   //This method clear value of all the fileds which were populated in produciton code decoding if produciton code is blank. 
   private static void blankPolulatedFields(Case caseObj){
        
        caseObj.Production_Line__c = null;
        caseObj.Production_Leg__c = null;
        caseObj.Production_Time__c = null;
        caseObj.Production_DayNWEN__c = null;
        caseObj.Production_Date__c = null;
        caseObj.Days_Remaining_NWEN__c = null;
   }
   
   //Checking format of production time 
   private static boolean isValidTime(String prodTime,CCE_Production_Code_Decode__c  plantObj){
    
        boolean isValid = true;
        Integer timeLength;
        Integer hr;
        Integer min;
        
        if(plantObj.Time_Length__c != null)
            timeLength = Integer.ValueOf(plantObj.Time_Length__c);
        
        if(timeLength != null){
            if(timeLength == 5){
                if(prodTime.substring(2,3) != ':'){
                    return false;
                }
                String[] timeStr = prodTime.split(':');
                if(timeStr[0].isNumeric() && timeStr[1].isNumeric()){
                    hr = Integer.ValueOf(timeStr[0]);   
                    min = Integer.ValueOf(timeStr[1]);  
                                        
                }else{
                    return false;
                }
            }
            
            if(timeLength == 4){
                if(!prodTime.isNumeric())
                    return false;
                
                hr = Integer.ValueOf(prodTime.substring(0,2));  
                min = Integer.ValueOf(prodTime.substring(2,4)); 
            }
            
            if(hr > 23 || min > 59){
                return false;
            }   
        }
   
        return isValid;     
   } 
   
   //Populate Laboratory of analysis as per plant and if plant is Unknown then blank out this field
   private static void populateLaboratoryOfAnalysis(Case caseObj){
   
       if(caseObj.Plant__c != null && !unknownPlant.containsKey(caseObj.Plant__c)){
           caseObj.Laboratory_of_Analysis_NWEN__c  = allPlant.get(caseObj.Plant__c).Name;
       }else if(!'Central Qesh'.equals(caseObj.Laboratory_of_Analysis_NWEN__c)) {
           caseObj.Laboratory_of_Analysis_NWEN__c = null;
       }
       
       if(caseObj.Plant__c != null)
           caseObj.Plant_Name__c = allPlant.get(caseObj.Plant__c).Name;
   
   
   }
   //This method gets Business unit of the case to get produciton code for the corrosponding business unit
   private static String getCaseBU(String developerName){
       String caseBU = '';
        if(developerName.contains(ECICCommonConstants.LCBU_Region)){
            caseBU = ECICCommonConstants.LCBU_Region;
            
        }else if(developerName.contains(ECICCommonConstants.NWEN_Region)){
            caseBU = ECICCommonConstants.NWEN_Region;
            
        }else if(developerName.contains(ECICCommonConstants.SABU_Region)){
            caseBU = ECICCommonConstants.SABU_Region;
            
        }
       return caseBU;
   }
   public static void plantByPlantIdentifier(String caseBu){
       Map<String, CCE_Production_Code_Decode__c> plants1 = CCE_Production_Code_Decode__c.getAll();
        Map<String, CCE_Production_Code_Decode__c> plantIdentifiers = new Map<String, CCE_Production_Code_Decode__c>();
       //    Map<Id, CCE_Production_Code_Decode__c> plantIdentifiers = plants.get(key)// new Map<Id, CCE_Production_Code_Decode__c>([select id, Name, Plant_Identifier__c From CCE_Production_Code_Decode__c where Business_Unit__c = : caseBu ]);
            
       set<String> s = new set<String>();
       s=plants1.keySet();
         
       
       for(String temp: s ){
                if(plants1.get(temp).Business_Unit__c == caseBu){
                    plants.put(plants1.get(temp).Plant_Identifier__c, plants1.get(temp));  
                    
                }
                
            }
      // Map<String, CCE_Production_Code_Decode__c> plants = plantIdentifiers;
           // return plantIdentifiers;
    }

}