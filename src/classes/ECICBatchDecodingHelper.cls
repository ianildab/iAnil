/**
*    ECIC-23:
*    As Infoline Agent (user) I want to enter the production code on a case record. Based on the entered value 
*    the production date and BBE date (and Plant and Line) must be given automatically in the application. 
*    If the production code isn't or can't be given properly there should be the possibility to fill all the fields manually. 
*
*/
public class ECICBatchDecodingHelper {
    private static final Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);
        
    public static void processProdCodeDecoding(Case c) {  
        new ProductionCodeHandler(c).process();     
    }
    
    //TODO: multiple decoding algorithm support
    public class ProductionCodeHandler {
        
        private Case c;
        private Integer shelfLife;
        private String unit;
        String developerName ;
        public ProductionCodeHandler (Case c) {
            this.c = c;
        }
       
        private void process() { 
            String batch = c.Production_Code__c; 
            developerName = RECORD_TYPES_BY_ID_MAP.get(c.RecordTypeID).DeveloperName; 
            
            if (batch == null) {
                return ;
            }
          
            
         if(developerName.contains(ECICCommonConstants.IBERIA_REGION)){ 
                if (c.Production_Code__c.length() > 1) {
                    String plantCode = c.Production_Code__c.substring(0,2);                                                                // Production Code requires at least 2 characters.
                    processPlantInfo(plantCode);
                } 
                
                if (c.Product__c == null && c.BBE_Date__c == null) {
                    return ;
                }
    
                calculateShelfLife ();
                // as per TASK0679810- Remove Production date calculation for Iberia
                //c.Production_Date__c = (c.Production_Code__c.length() > 2) ? processProductionDateWithPrefDate() : calculateBaseDate();     // If more than 2 characters, it contains a "pref date"; otherwise that needs to be calculated...
        }
        else if (c.Production_Code__c.length() > 2 && developerName.contains(ECICCommonConstants.GERMANY_REGION)) {
                String plantCode = c.Production_Code__c.substring(0,3);                                                                // Production Code requires at least 3 characters.
                processPlantInfo(plantCode);
            }
        }
        
        /**
        *    Define shelf life
        */
        public void calculateShelfLife () {
            Product__c pr = ECICCaseTriggerProductCache.getProductByIdMap().get(c.Product__c);

            if(pr == null) {
                System.debug('Product not found: ' + c.Product__c);
                return;
            }

            shelfLife = Integer.valueOf(pr.Shelf_Life__c);
            System.debug('Shelf life = ' + shelfLife);
            
            unit = pr.Unit__c;
            System.debug('Unit = ' + unit);
        }

        /**
        *    Calculate base date: baseDate = case.getBbeDate() - shelfLife;
        */
        public Date calculateBaseDate () {
            if (shelfLife != null && c.BBE_Date__c != null && unit != null) { 
                Date prefDate = c.BBE_Date__c;//preferred date of consumtion

                if (unit == 'Day') {
                    return prefDate.addDays(-shelfLife);
                }
                else if (unit == 'Month') {
                    return prefDate.addMonths(-shelfLife);
                }
            }

            return null;
        }

        /**
        *    Search in the table the code with the two first/three characters for Iberia/Germany from the batch, and then obtain the bottler and plant.
        */
           private void processPlantInfo(String plantCode) {
            Production_Line__c[] prodLines = ECICCaseTriggerProductionLineCache.getProductionLineByPlantCodeMap().get(plantCode.toLowerCase());
            
            if( developerName.contains(ECICCommonConstants.IBERIA_REGION) && (prodLines == null || prodLines.isEmpty())){
                c.Production_Line__c = null;
                c.Plant__c = null;
                c.Bottler__c = null;
                return;
                
                } 
                else if(developerName.contains(ECICCommonConstants.GERMANY_REGION) && (prodLines == null || prodLines.isEmpty())) {
                 c.Plant__c = null;
                 c.Bottler__c = null;
                 return;
                }
            
           if( developerName.contains(ECICCommonConstants.IBERIA_REGION)) { 
            c.Production_Line__c = prodLines[0].Id;
            c.Plant__c = prodLines[0].Plant__r.Id;
            c.Bottler__c = prodLines[0].Plant__r.Bottler__c;
            
            } else if(developerName.contains(ECICCommonConstants.GERMANY_REGION)){
            
                c.Plant__c = prodLines[0].Plant__r.Id;
                c.Bottler__c = prodLines[0].Plant__r.Bottler__c;
            }
        }

        /**
        *    If this calculation mode is not 1, we search of the bestbefore of the product, packaging and size from the database table INT_PROD_ENV_TAM (id_producto, id_envase, id_tamano, bestbefore). 
        *    If exists, we obtain the character (first position of bestbefore) and digits (rest of characters of bestbefore). Also, we obtain the symbol of the batch (third position of the batch) and with it we obtain the day related to this symbol with the database table SIMBOLO_LOTE (simbolo, dia).
        *    If this day is not 0 and is different to the day of the preferred date of consumption, we update the the day of the preferred date of consumption with this new day. Once done this checking:
        *    If the character of the bestbefore is 'd', the production date is the result of the preferred date of consumption subtracting so many days of the value of the digits of bestbefore.
        *    If the character of the bestbefore is 'm', the production date is the result of the preferred date of consumption subtracting so many months of the value of the digits of bestbefore.
        */
        private Date processProductionDateWithPrefDate() { 
            Date result = null;
            Date bestBeforeDate = c.BBE_Date__c; //preferred date of consumtion

            if (bestBeforeDate != null) {
                if (unit != null && shelfLife != null) {
                
                    Map<String, PC_Day_Symbol_ESN__c> daySymbolMapping = PC_Day_Symbol_ESN__c.getAll();
                    String productionCodeDaySymbol = c.Production_Code__c.substring(2,3).toUpperCase();                 // Match the 3rd character to PC_Day_Symbol_ESN__c to get more data...
                    PC_Day_Symbol_ESN__c productionCodeDaySymbolMapping = daySymbolMapping.get(productionCodeDaySymbol);
                    Integer productionDay = null;

                    if (productionCodeDaySymbolMapping != null) {
                        try {
                            productionDay = Integer.valueOf(productionCodeDaySymbolMapping.Day__c);
                        } catch (Exception e) {
                            System.debug(LoggingLevel.ERROR, 'Failed to convert mapping day [' + productionCodeDaySymbolMapping.Day__c + '] to integer: ' + e);
                            productionDay = null;
                        }
                    } else {
                        System.debug(LoggingLevel.WARN, 'No value found for day symbol: ' + productionCodeDaySymbol);
                    }
                    
                    if (productionDay != null
                        && productionDay != 0) {
                        
                        if (unit == 'Day') {
                            result = bestBeforeDate.addDays(-shelfLife);
                        }
                        else if (unit == 'Month') {
                            result = bestBeforeDate.addMonths(-shelfLife);
                        }
                        
                        if (result != null) {
                            Integer daysInMonth = Date.daysInMonth(result.Year(), result.Month());
                            result = Date.newInstance(result.Year(), result.Month(), ((productionDay <= daysInMonth) ? productionDay : daysInMonth));                
                        }
                    } else {
                        System.debug(LoggingLevel.ERROR, 'Mapped production day value is invalid.');
                    }
                } else {
                    System.debug('Unit or shelf life value is null. Defaulting to BBE Date.');
                    result = bestBeforeDate;
                }
            }

            return result;
        }
    }
}