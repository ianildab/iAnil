@isTest
public class ECICSABUFunctionalUtilityTest {
    //Create Data for test
  		private static final Map<String, Id> RECORD_TYPES_BY_DEVELOPERNAME_MAP = SEPRecordTypesCache.getRecordTypeIdsByDeveloperNameMap(Case.SObjectType);
  
    @isTest static public void testUpdateCaseCityFromConsumerCity()
     {
        
         City__c c = new City__c(Name = 'Durban', CountryCode__c ='ZA');
         insert c;
         
      	Account bottler = new Account(Name = 'Delta', Type = 'Bottler');
         insert bottler;
         Account  a = new Account(LastName = 'Amit', Country_Code__c = 'ZA', PersonMobilePhone='1234567890', City__c =c.Id,
                                 Shipping_Streetname1__c = 'ABC', shipping_postalCode__c = '452134', Shipping_Country__c = 'South Africa');
         insert a;
         Plant__c p = new Plant__c(Name = 'ABC', LCBU_Plant_Code__c = 'ab',Active__c = TRUE,SABU_Add_Sample_Collector__c = 'From Case Team',bottler__c = bottler.Id);
       	insert p;
         
         List<case>  caseList = new List<case>();
        // String recordtypeId  = ECICCommonConstants.SABU_QUALITY_COMPLAINT_RT_ID;
         for(Integer i = 0; i < 5; i++)
         {
             Case cs = new Case(Reason = 'Product Quality', Category_Level3__c = 'DIRTY CONTAINER',
                               Category_Level4__c = 'Glue', Priority = 'Medium',
                               RecordTypeId= RECORD_TYPES_BY_DEVELOPERNAME_MAP.get(ECICCommonConstants.SABU_QUALITY_COMPLAINT_DEVNAME), SABU_Use_Cons_Account_Phys_Address__c = TRUE,
                               Status = 'New', AccountId = a.Id);
             
              Case cs1 = new Case(Reason = 'Product Quality', Category_Level3__c = 'DIRTY CONTAINER',
                               Category_Level4__c = 'Glue', Priority = 'Medium',
                               RecordTypeId= RECORD_TYPES_BY_DEVELOPERNAME_MAP.get(ECICCommonConstants.SABU_QUALITY_COMPLAINT_DEVNAME), SABU_Use_Cons_Account_Phys_Address__c = TRUE,
                               Status = 'New', AccountId = a.Id, plant__C = p.id);
             caseList.add(cs);
              caseList.add(cs1);
         }
         
         
          Case uncheckedCase = new Case(Reason = 'Product Quality', Category_Level3__c = 'Carbonation',
                               Category_Level4__c = 'Gushes / Overcarbonation', Priority = 'Medium',
                               RecordTypeId= RECORD_TYPES_BY_DEVELOPERNAME_MAP.get(ECICCommonConstants.SABU_QUALITY_COMPLAINT_DEVNAME), SABU_Use_Cons_Account_Phys_Address__c = FALSE,
                               Status = 'New', AccountId = a.Id);
         caseList.add(uncheckedCase);
          insert caseList;
         //  uncheckedCase.SABU_Use_Cons_Account_Phys_Address__c = TRUE;
        // update uncheckedCase;
       // caseList.remove(11);
		Map<Id, case>  caseMap = new Map<Id, case>();
         for(Case cas : caseList)
         {
             caseMap.put(cas.Id, cas);
         }
         
     Test.startTest();
        List<case> insertedCase = [Select Id,AccountId,bottler__c, City__c, SABU_Use_Cons_Account_Phys_Address__c from Case where Id in : caseMap.keySet()];
    		for(Case cases : insertedCase)
            {
                if(cases.SABU_Use_Cons_Account_Phys_Address__c == TRUE)
             	System.assertEquals(a.City__c, cases.City__C);
                if(cases.bottler__c != null) 
                System.assertEquals(cases.bottler__c, bottler.Id);
                
            }
         Test.stopTest();
        
    /*       	City__c city2 = new City__C(Name = 'Pretoria', CountryCode__c ='ZA'); 
         insert city2;
        
         a.City__c = city2.Id;
         update a;
           List<case> updatedCases = [Select Id,AccountId,City__c from Case where Id in : caseMap.keySet()];
        for(Case updateCase : updatedCases)
            System.assertEquals(a.City__c, updateCase.City__C);
          Test.stopTest();*/
       
 		
      }
    @isTest static public void testUpdateCaseCityFromConsumerCity2()
    {
        
      //  City__c c = new City__c(Name = 'Durban', CountryCode__c ='ZA');
        // insert c;
         
      	 Account  a = new Account(LastName = 'Amit', Country_Code__c = 'ZA', PersonMobilePhone='1234567890',
                                 Shipping_Streetname1__c = 'ABC', shipping_postalCode__c = '452134', Shipping_Country__c = 'South Africa');
         insert a;
        // Plant__c p = new Plant__c(Name = 'ABC', LCBU_Plant_Code__c = 'ab',Active__c = TRUE);
        // insert p;
         
         List<case>  caseList = new List<case>();
        // String recordtypeId  = ECICCommonConstants.SABU_QUALITY_COMPLAINT_RT_ID;
         for(Integer i = 0; i < 5; i++)
         {
             Case cs = new Case(Reason = 'Product Quality', Category_Level3__c = 'DIRTY CONTAINER',
                               Category_Level4__c = 'Glue', Priority = 'Medium',
                               RecordTypeId= RECORD_TYPES_BY_DEVELOPERNAME_MAP.get(ECICCommonConstants.SABU_QUALITY_COMPLAINT_DEVNAME), SABU_Use_Cons_Account_Phys_Address__c = TRUE,
                               Status = 'New', AccountId = a.Id);
             caseList.add(cs);
         }
        
         
       	insert caseList;
         Test.startTest();
        a.Shipping_Streetname1__c = 'PQR';
        update a;
        
        Test.stopTest();
    }
    
    
}