@isTest
public class SABUCaseTrendTest{
    private static List<Case> testCases=new List<Case>();
    private static List<Case> testCasesUp=new List<Case>();
    private static List<Account> testAccounts=new List<Account>();
    private static List<Case> testCasesOld = new List<Case>();
    private static List<Plant__c> testPlant = new List<Plant__c>();
    private static List<Production_Line__c> testPL = new List<Production_Line__c>(); 
    private static string countryCode = 'ZA';
    private static List<CCE_Product__c> testProduct = new List<CCE_Product__c>();
    private static final Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);
    private static string recordTypeCase;
    private static List<CCE_Production_Code_Decode__c> testCodeSettings = new List<CCE_Production_Code_Decode__c>();
    private static CCE_Trend__c trendInsert = new CCE_Trend__c();
    
    static TestMethod void insertTrend()
    {
            
            
            
       CCE_Production_Code_Decode__c calleBlancos = new CCE_Production_Code_Decode__c(name = 'CB1');
            calleBlancos.Plant__c = 'Bloemfontein';
            calleBlancos.LCBU_Plant_Code__c = 'CB';
            calleBlancos.BBE_Code_Length__c = 7;
            calleBlancos.BBE_Day_Position__c = '1,2';
            calleBlancos.BBE_Month_Position__c = '3,4,5';
            calleBlancos.BBE_Year_Position__c = '6,7';
            //calleBlancos.Day_Position__c = '1,2,3';
            calleBlancos.Is_Co_Packers__c = FALSE;
            calleBlancos.Line_Position__c = '3';
            //gent.Leg_Position__c = '7';
            calleBlancos.Plant_Position__c = '1,2';
            calleBlancos.Production_Line__c = '1';
            calleBlancos.Prod_Code_Length__c = 8;
            calleBlancos.Time_Position__c = '4,5,6,7,8';
        	calleBlancos.Plant_Identifier__c = 'CB1';
            calleBlancos.Business_Unit__c = 'SABU' ;          
            testCodeSettings.add(calleBlancos);
          
            database.insert(testCodeSettings);
             
            //need to call  insertCaseCheck
            Region__c testRegion = new Region__c(name= 'testRegion', Country_Code__c = 'ZA');
            insert testRegion;
            
            
            
            
            testAccounts = TestDataUtility.createAccount(1);
            testAccounts[0].type='Bottler';
            testAccounts[0].Shipping_Country__c='South Africa';
            testAccounts[0].shipping_administrativearea__c = 'testRegion';
            Database.insert(testAccounts);
            
            testPlant = TestDataUtility.createPlant(countryCode,1);
            testPlant[0].Name = 'Bloemfontein';
            testPlant[0].active__c = true;
            testPlant[0].LCBU_Plant_Code__c = 'CB';
            Database.Insert(testPlant);
            
            Production_Line__c pl = new Production_Line__c(Name = '1');
    
            pl.Active__c = True;
            pl.Plant__c = testPlant[0].Id;
            pl.Country_Code__c = countryCode ;
            pl.Pack__c = 'PET';
            pl.Content__c = '2.00L';
            
            testPL.add(pl);
            Database.insert(testPL);
            
            CCE_Product__c pr = new CCE_Product__c();
           
            pr.Active__c = True;
            pr.Brand__c = 'Coca-Cola	';
            pr.Country_Code__c = countryCode;
            pr.Flavour__c = 'Cola';
            pr.Packaging__c = 'PET';
            pr.Size__c = '2.00L';
            pr.Shelf_Life_In_Days__c = 98.0; // hereeeee
            testProduct.add(pr);
            Database.insert(testProduct);
        
            City__c cty = new City__c(Name='Harare1');
            Database.insert(cty);
            
            
            recordTypeCase = schema.SObjectType.Case.getRecordTypeInfosByName().get('Quality Complaint SABU').getRecordTypeId();
            
            
            
            testCases = TestDataUtility.createCase(testAccounts[0].id,5);
            testCases[0].reason = 'Product Quality';
            testCases[0].Category_Level3__c = 'CARBONATION';
            testCases[0].Country_Code__c = countryCode; 
            testCases[0].CCE_Product__c = testProduct[0].Id;
            //testCases[0].Production_Line__c = testPL[0].Id;
            testCases[0].RecordTypeId = recordTypeCase;
            testCases[0].Text_BBE_Date__c = '15DEC16';
            //testCases[0].production_date__c = date.ValueOf('2016-04-30');
            testCases[0].Production_Code__c = 'CB111:45';
            testCases[0].Status = 'New';
            testCases[0].Description = 'test';       
           // testCases[0].LCBU_Plant_code__c = 'CB';
            testCases[0].City__c =cty.Id;
            testCasesUp.add(testCases[0]);
        
            
            testCases[1].reason = 'Product Quality';
            testCases[1].Category_Level3__c = 'CARBONATION';
            testCases[1].Country_Code__c = countryCode;
            testCases[1].CCE_Product__c = testProduct[0].Id;
            //testCases[1].Production_Line__c = testPL[0].Id;
            testCases[1].RecordTypeId = recordTypeCase;       
            testCases[1].Status = 'New';
            testCases[1].Description = 'test';
            testCases[1].Text_BBE_Date__c = '15DEC16';
            //testCases[1].production_date__c = date.ValueOf('2016-04-30');
            testCases[1].Production_Code__c = 'CB111:45';
            //testCases[1].LCBU_Plant_code__c = 'CB';
            testCases[1].City__c =cty.Id;
               
            testCasesUp.add(testCases[1]);
            
            testCases[2].reason = 'Product Quality';
            testCases[2].Category_Level3__c = 'CARBONATION';
            testCases[2].Country_Code__c = countryCode;
            testCases[2].CCE_Product__c = testProduct[0].Id;
            //testCases[2].Production_Line__c = testPL[0].Id;
            testCases[2].RecordTypeId = recordTypeCase;
            testCases[2].Status = 'Open';
            testCases[2].Description = 'test';
            testCases[2].Text_BBE_Date__c = '15DEC16';
            testCases[2].Production_Code__c = 'CB111:45';  
            //testCases[2].LCBU_Plant_code__c = 'CB';
            testCases[2].City__c =cty.Id;         
        
             testCasesUp.add(testCases[2]);
            //database.insert(testCases[2]);
            
            
           
            //database.insert(testCases[3]);
            
            database.Insert(testCasesUp);
           
            //testCases[2].production_date__c = date.ValueOf('2016-04-30');
            //testCasesUp.add(testCases[2]);
            
            //database.insert(testCases);
            system.debug(testCases + 'testCasesnowCheck');
            /*testCases[0].Status = 'Open';
            testCases[1].Status = 'Open';
            testCases[2].Status = 'Open';
            database.update(testCases);*/
        	
       }
    	
        
        static TestMethod void insertOnlyTrend(){
            insertTrend();
            trendInsert = new CCE_Trend__c(name = 'test');
            trendInsert.Status__c= 'Cancelled';
            trendInsert.Plant__c = testPlant[0].Id;
            trendInsert.Country_Code__c = countryCode;
            trendInsert.Production_Date__c = testCases[0].Production_Date__c;
            trendInsert.Production_Day__c = testCases[0].Production_DayNWEN__c;
            trendInsert.Production_Line__c = testPL[0].Id;
            trendInsert.Category_Level_3__c = 'CARBONATION';
            trendInsert.Brand__c = 'Coca-Cola';
            trendInsert.Flavour__c = 'Cola';
            trendInsert.Size__c = '2.00L';
            trendInsert.Packaging__c = 'PET';
            trendInsert.No_of_Open_Cases__c = 0;
            trendInsert.No_of_Total_Cases__c = 0;
            database.Insert(trendInsert);
            
   
    }
    static TestMethod void updateCasesTrend(){
        
        insertTrend();
        
        
        testCasesUp[0].Status = 'Open';
        testCasesUp[1].Status = 'Open';
        testCases[2].Status = 'Open';
        database.update(testCasesUp);
        //test.StartTest();
        testCases[2].reason = 'Product Quality';
        testCases[2].Category_Level3__c = 'CARBONATION';
        testCases[2].Country_Code__c = countryCode;
        testCases[2].CCE_Product__c = testProduct[0].Id;
        //testCases[2].Production_Line__c = testPL[0].Id;
        testCases[2].RecordTypeId = recordTypeCase;
        testCases[2].Status = 'Open';
        testCases[2].Description = 'test';
        testCases[2].Text_BBE_Date__c = '15DEC16';
        testCases[2].Production_Code__c = 'CB111:45';  
        testCases[2].LCBU_Plant_code__c = 'CB';
        test.StartTest();
        //database.insert(testCases[2]);
        database.update(testCases[2]);
        /* testCases[3].Status = 'Open';
        Database.Update(testCases[3]);*/
        
        testCases[0].Status = 'Cancelled';
        database.Update(testCases[0]);
        test.StopTest();
        //testCases[2].Channel_of_Answer__c = 'Phone';
        //testCases[2].Status = 'Closed';
        //database.Update(testCases[2]);
        testCases[1].Category_Level3__c = 'Injury';
        database.Update(testCases[1]);
        //CCECaseTrend.RemoveCaseFromTrend(new List<Id> {testCases[2].Id});
       // test.StopTest();
        
            }
            
            
        static TestMethod void updateCasesTrend2(){
        
            insertOnlyTrend();
            testCases[3].reason = 'Product Quality';
            testCases[3].Category_Level3__c = 'CARBONATION';
            testCases[3].Country_Code__c = countryCode;
            testCases[3].CCE_Product__c = testProduct[0].Id;
            //testCases[2].Production_Line__c = testPL[0].Id;
            testCases[3].RecordTypeId = recordTypeCase;
            testCases[3].Status = 'New';
            testCases[3].Description = 'test';
            testCases[3].Text_BBE_Date__c = '15DEC16';
            testCases[3].Production_Code__c = 'CB111:45';  
            testCases[3].LCBU_Plant_code__c = 'CB';
            testCases[3].CCE_Trend__c = trendInsert.Id;
            
            
        
            test.StartTest();
            database.insert(testCases[3]);
            testCases[3].Status = 'Open';
            database.Update(testCases[3]);
            test.StopTest();
        
        }
        
        static TestMethod void updateCasesStatus(){        
        
            //updateCasesTrend();
            /*insertTrend();
            testCases[0].Status = 'Cancelled';
            Test.StartTest();
            database.Update(testCases[0]);
            Test.StopTest();
            */
            
        insertTrend();
        testCasesUp[0].Status = 'Open';
        testCasesUp[1].Status = 'Open';
        testCases[4].Status = 'Open';
        database.update(testCasesUp);
        test.StartTest();
        testCases[4].reason = 'Product Quality';
        testCases[4].Category_Level3__c = 'CARBONATION';
        testCases[4].Country_Code__c = countryCode;
        testCases[4].CCE_Product__c = testProduct[0].Id;
        //testCases[2].Production_Line__c = testPL[0].Id;
        testCases[4].RecordTypeId = recordTypeCase;
        testCases[4].Status = 'Open';
        testCases[4].Description = 'test';
        testCases[4].Text_BBE_Date__c = '15DEC16';
        testCases[4].Production_Code__c = 'CB111:45';  
        testCases[4].LCBU_Plant_code__c = 'CB';
            
        
            
        database.insert(testCases[4]);
        testCases[4].Channel_of_Answer__c = 'Phone';
        testCases[4].Status = 'Closed';
        database.Update(testCases[4]);
        SABUCaseTrend.RemoveCaseFromTrend(new List<Id> {testCases[4].Id});
        //testCases[4].Category_Level3__c = 'Injury';
        //Database.Update(testCases[4]);
        test.stopTest();
         
        }
    
}