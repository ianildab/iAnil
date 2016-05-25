/*
Author - Amit Ghadage
Date - 1st April,2016
Purpose - This class used for updating case city and on creation of case from Account when
SABU_Use_Cons_Account_Phys_Address__c is checked
 */

public class ECICSABUFunctionalUtility 
{
    private static String developerName = '';
    private static final Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);
    private static final Map<String, Id> RECORD_TYPES_BY_DEVELOPERNAME_MAP = SEPRecordTypesCache.getRecordTypeIdsByDeveloperNameMap(Case.SObjectType);
    
    private static Map<Id, Plant__c> plantByIdMap = ECICCaseTriggerRegionCache.getPlantByIdMap();
    
    public static void updateCaseCityFromConsumerCity(List<Case> insertCase, Map<ID,Case> upDateCase)
    {
       
        // List<Case> UpdatedCityCaseList = new List<case>();
        Set<ID> accountIdSet  = new Set<ID>();
      //  Set<ID> cityIdSet = new Set<Id>();
        Map<ID, Plant__c> plantMap = ECICCaseTriggerRegionCache.getPlantByIdMap() ;
       /* for(Plant__c p : [SELECT Id, Name,
                          SABU_Add_Sample_Collector__c FROM Plant__c])
        {
            plantMap.put(p.Id, p);
        } */
        
      //  Map<Id,Geo_Mapping__c> geoMappingByCityMap =  ECICCaseTriggerRegionCache.getgeoMappingByCityMap();
        Map<ID,Account> caseIdToAccountMap = new Map<ID,Account>();
        
        for(Case c: insertCase)
        {
            accountIdSet.add(c.AccountId);
           // cityIdSet.add(c.City__c);
        }
        
        
        Map<ID,Account> accountMap = new  Map<ID,Account>();
        
        for(Account a : [Select Id,City__C, PersonMobilePhone, Shipping_Streetname1__c,shipping_postalCode__c, Shipping_Country__c   from Account where ID in :accountIdSet])
        {
            accountMap.put(a.ID, a);
           // cityIdSet.add(a.City__c);
        }
        
        Map<ID,String> cityIdToNameMap = new Map<Id, String>();
        Map<String, City__c> CityNameToCityMap = new Map<String, City__c>();
        for(City__c c : [Select Id, Name from City__c])
        {
            cityIdToNameMap.put(c.Id, c.Name);
            CityNameToCityMap.put(c.Name.toUpperCase(), c);
        } 
        System.debug('CityNameToCityMap.put(c.Name, c);'+CityNameToCityMap.get('LUSAKA'));
         System.debug('Map Size'+CityNameToCityMap.size());
        for(Case c : insertCase)
        {
            caseIdToAccountMap.put(c.id,accountMap.get(c.AccountId));
        }
        
       
//       if(upDateCase == null)
  //     {
           for(Case updateCity:insertCase)
           {
               
             if(updateCity.AccountId != null)
             {
                 
                if(updateCity.SABU_Use_Cons_Account_Phys_Address__c  == true && RECORD_TYPES_BY_ID_MAP.get(updateCity.recordTypeId).DeveloperName ==ECICCommonConstants.SABU_QUALITY_COMPLAINT_DEVNAME)
                {
                        //if(plantMap.get(updateCity.Plant__c).SABU_Add_Sample_Collector__c == 'From Geo Mapping')
                       
                    if(upDateCase == null || upDateCase.get(updateCity.id).SABU_Use_Cons_Account_Phys_Address__c == FALSE){
                        
                    
                        updateCity.City__c = caseIdToAccountMap.get(updateCity.Id).City__C;
        
                        
                        String address = '';
                       
                        if( caseIdToAccountMap.get(updateCity.Id).Shipping_Streetname1__c != null&&
                            caseIdToAccountMap.get(updateCity.Id).shipping_postalCode__c ==null &&
                            caseIdToAccountMap.get(updateCity.Id).Shipping_Country__c == null)
                            address += (String)caseIdToAccountMap.get(updateCity.Id).Shipping_Streetname1__c;
                        else
                            if(caseIdToAccountMap.get(updateCity.Id).Shipping_Streetname1__c != null)
                            address += (String)caseIdToAccountMap.get(updateCity.Id).Shipping_Streetname1__c+', ';
                        
                        if(caseIdToAccountMap.get(updateCity.Id).shipping_postalCode__c !=null &&
                           caseIdToAccountMap.get(updateCity.Id).Shipping_Country__c == null)
                           address += (String)caseIdToAccountMap.get(updateCity.Id).shipping_postalCode__c;
                        else
                            if(caseIdToAccountMap.get(updateCity.Id).shipping_postalCode__c !=null)
                             address += (String)caseIdToAccountMap.get(updateCity.Id).shipping_postalCode__c+', ';
                        
                        if(caseIdToAccountMap.get(updateCity.Id).Shipping_Country__c != null)
                        address += (String)caseIdToAccountMap.get(updateCity.Id).Shipping_Country__c;
                    
                        updateCity.Address__c = address;
                    
                        updateCity.SABU_Contact_Phone__c = caseIdToAccountMap.get(updateCity.Id).PersonMobilePhone;
                    
                }
             }
                            if(updateCity.Plant__c != null && plantMap.get(updateCity.Plant__c).SABU_Add_Sample_Collector__c == 'From Case Team')
                        {
                            String temp = plantMap.get(updateCity.Plant__c).Name.toUpperCase();
                            System.debug('temp'+temp);
                            if(CityNameToCityMap.get(temp) != null)
                            updateCity.City__c = CityNameToCityMap.get(temp).Id;
                            updateCity.SABU_Geo_Mapping__c = null;
                        }
                        
              updateCity.SABU_City_Name__c = cityIdToNameMap.get(updateCity.City__c);
             }
                 /*   if(updateCity.Plant__c != null && plantMap.get(updateCity.Plant__c).SABU_Add_Sample_Collector__c == 'From Geo Mapping' && updateCity.City__c != null)
                        {
                            updateCity.SABU_Geo_Mapping__c = geoMappingByCityMap.get(updateCity.City__c).Id;
                        }*/
           }
     //  }
       /* else
        {
            
           for(Case updateCity: insertCase)
           {
             if(updateCity.AccountId != null && updateCity.SABU_Use_Cons_Account_Phys_Address__c == TRUE)
             {
                if(updateCity.SABU_Use_Cons_Account_Phys_Address__c  != upDateCase.get(updateCity.id).SABU_Use_Cons_Account_Phys_Address__c && RECORD_TYPES_BY_ID_MAP.get(updateCity.recordTypeId).DeveloperName ==ECICCommonConstants.SABU_QUALITY_COMPLAINT_DEVNAME)
                {
                    //if(plantMap.get(updateCity.Plant__c).SABU_Add_Sample_Collector__c == 'From Geo Mapping')
                        updateCity.City__c = caseIdToAccountMap.get(updateCity.Id).City__C;     
                        String address = '';
                        System.debug('****'+ caseIdToAccountMap.get(updateCity.Id).shipping_postalCode__c);
                        if( caseIdToAccountMap.get(updateCity.Id).Shipping_Streetname1__c != null&&
                            caseIdToAccountMap.get(updateCity.Id).shipping_postalCode__c ==null &&
                            caseIdToAccountMap.get(updateCity.Id).Shipping_Country__c == null
                          )
                            address += (String)caseIdToAccountMap.get(updateCity.Id).Shipping_Streetname1__c;
                    
                        else
                            if(caseIdToAccountMap.get(updateCity.Id).Shipping_Streetname1__c != null)
                            address += (String)caseIdToAccountMap.get(updateCity.Id).Shipping_Streetname1__c+', ';
                        
                        if(caseIdToAccountMap.get(updateCity.Id).shipping_postalCode__c !=null &&
                           caseIdToAccountMap.get(updateCity.Id).Shipping_Country__c == null)
                           address += (String)caseIdToAccountMap.get(updateCity.Id).shipping_postalCode__c;
                    
                        else
                            if(caseIdToAccountMap.get(updateCity.Id).shipping_postalCode__c !=null)
                             address += (String)caseIdToAccountMap.get(updateCity.Id).shipping_postalCode__c+', ';
                        
                        if(caseIdToAccountMap.get(updateCity.Id).Shipping_Country__c != null)
                        address += (String)caseIdToAccountMap.get(updateCity.Id).Shipping_Country__c;
                        
                        updateCity.Address__c = address;
                    
                        updateCity.SABU_Contact_Phone__c = caseIdToAccountMap.get(updateCity.Id).PersonMobilePhone;
                }
             }
               
               if(updateCity.Plant__c != null && plantMap.get(updateCity.Plant__c).SABU_Add_Sample_Collector__c == 'From Case Team')
                        {
                            String temp = plantMap.get(updateCity.Plant__c).Name.toUpperCase();
                            System.debug('temp'+temp);
                           if(CityNameToCityMap.get(temp) != null)
                            updateCity.City__c = CityNameToCityMap.get(temp).Id;
                        }
               updateCity.SABU_City_Name__c = cityIdToNameMap.get(updateCity.City__c);
           }
        }*/
    }
    
    public static void updateCaseCityFromConsumerCity(Map<Id,Account> updateCaseCityBasedOnAccount, List<Account> oldvalues)
    {
       
       List<Case> caseList = [Select id,city__c,SABU_Use_Cons_Account_Phys_Address__c,AccountID,recordtypeId
                              from Case where AccountId = :updateCaseCityBasedOnAccount.keySet() AND 
                              recordtypeId =:RECORD_TYPES_BY_DEVELOPERNAME_MAP.get(ECICCommonConstants.SABU_QUALITY_COMPLAINT_DEVNAME) AND 
                             SABU_Use_Cons_Account_Phys_Address__c = TRUE AND
                             status != 'Cancelled' AND status != 'Closed'];
        /* This code will execute only if accounts mobile, shipping street 1, shipping postalcode, shipping country
         * will be changed*/
        
        Boolean decideToExecute = FALSE;
        for(Account oldAccounts : oldvalues)
        {
            if(oldAccounts.City__c != updateCaseCityBasedOnAccount.get(oldAccounts.Id).City__c ||
              oldAccounts.Shipping_Streetname1__c !=  updateCaseCityBasedOnAccount.get(oldAccounts.Id).Shipping_Streetname1__c ||
              oldAccounts.shipping_postalCode__c != updateCaseCityBasedOnAccount.get(oldAccounts.Id).shipping_postalCode__c ||
              oldAccounts.Shipping_Country__c != updateCaseCityBasedOnAccount.get(oldAccounts.Id).Shipping_Country__c  ||
              oldAccounts.PersonMobilePhone != updateCaseCityBasedOnAccount.get(oldAccounts.Id).PersonMobilePhone)
              
                decideToExecute = TRUE;
        }
            
        Map<ID,Account> accountMap = new  Map<ID,Account>();
       
        Set<Id> cityIdSet = new Set<Id>();
        Map<Id,Account> CaseIdToAccountMap = new  Map<Id,Account>();
        
        for(Case c : caseList)
        {
            CaseIdToAccountMap.put(c.Id,updateCaseCityBasedOnAccount.get(c.AccountId));
            cityIdSet.add(c.City__c);
        }
        
         Map<ID,String> cityIdToNameMap = new Map<Id, String>();
        for(City__c c : [Select Id, Name from City__c where Id in :cityIdSet])
            cityIdToNameMap.put(c.Id, c.Name);
        
        List<Case> updatedCases = new List<case>();
        if(decideToExecute)
        {
            
            for(Case c : caseList)
            {
                c.City__c = CaseIdToAccountMap.get(c.Id).City__c;
                
                        String address = '';
                      //  System.debug('****'+ caseIdToAccountMap.get(updateCity.Id).shipping_postalCode__c);
                        if( caseIdToAccountMap.get(c.Id).Shipping_Streetname1__c != null&&
                            caseIdToAccountMap.get(c.Id).shipping_postalCode__c ==null &&
                            caseIdToAccountMap.get(c.Id).Shipping_Country__c == null
                          )
                            address += (String)caseIdToAccountMap.get(c.Id).Shipping_Streetname1__c;
                    
                        else
                            if(caseIdToAccountMap.get(c.Id).Shipping_Streetname1__c != null)
                            address += (String)caseIdToAccountMap.get(c.Id).Shipping_Streetname1__c+', ';
                        
                        if(caseIdToAccountMap.get(c.Id).shipping_postalCode__c !=null &&
                           caseIdToAccountMap.get(c.Id).Shipping_Country__c == null)
                           address += (String)caseIdToAccountMap.get(c.Id).shipping_postalCode__c;
                    
                        else
                            if(caseIdToAccountMap.get(c.Id).shipping_postalCode__c !=null)
                             address += (String)caseIdToAccountMap.get(c.Id).shipping_postalCode__c+', ';
                        
                        if(caseIdToAccountMap.get(c.Id).Shipping_Country__c != null)
                        address += (String)caseIdToAccountMap.get(c.Id).Shipping_Country__c;
                
                c.Address__c = address;
                
                c.SABU_Contact_Phone__c = caseIdToAccountMap.get(c.Id).PersonMobilePhone;
                c.SABU_City_Name__c = cityIdToNameMap.get(c.City__c);
                
                updatedCases.add(c);
            }
        
        //System.debug(' updatedCases'+ updatedCases);
            update updatedCases;
        }
    }
    
    public static void populateBottlerFromPlant(List<Case> newValues,List<Case> oldValues){
        
        if(newValues != null && newValues.size() > 0){
        
        for(Case caseObjNew:newValues){
            if(caseObjNew.Plant__c != null){
                   Plant__c casePlant = plantByIdMap.get(caseObjNew.Plant__c); 
                 if(casePlant != null && casePlant.bottler__c != null){
                     caseObjNew.bottler__c = casePlant.bottler__c;
                 } 
            }
            }
        }
    
    }
    
}