@isTest
public class LCBUCaseTrendTest{
    private static List<Case> testCases=new List<Case>();
    private static List<Case> testCasesUp=new List<Case>();
    private static List<Account> testAccounts=new List<Account>();
    private static List<Case> testCasesOld = new List<Case>();
    private static List<Plant__c> testPlant = new List<Plant__c>();
    private static List<Production_Line__c> testPL = new List<Production_Line__c>(); 
    private static string countryCode = 'CR';
    private static List<CCE_Product__c> testProduct = new List<CCE_Product__c>();
    private static final Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);
    private static string recordTypeCase;
    private static List<CCE_Production_Code_Decode__c> testCodeSettings = new List<CCE_Production_Code_Decode__c>();
    private static CCE_Trend__c trendInsert = new CCE_Trend__c();
    
    static TestMethod void insertTrend()
    {
            
            
            CCE_Production_Code_Decode__c calleBlancos = new CCE_Production_Code_Decode__c(name = 'L1SJ');
            calleBlancos.Plant__c = 'FEMSA Calle Blancos';
            calleBlancos.LCBU_Plant_Code__c = 'SJ';
        	calleBlancos.Business_Unit__c = 'LCBU';
            calleBlancos.BBE_Code_Length__c = 7;
            calleBlancos.BBE_Day_Position__c = '1,2';
            calleBlancos.BBE_Month_Position__c = '3,4,5';
            calleBlancos.BBE_Year_Position__c = '6,7';
            //calleBlancos.Day_Position__c = '1,2,3';
            calleBlancos.Is_Co_Packers__c = FALSE;
            calleBlancos.Line_Position__c = '1,2';
            //gent.Leg_Position__c = '7';
            calleBlancos.Plant_Position__c = '3,4';
            calleBlancos.Production_Line__c = 'L1';
            calleBlancos.Prod_Code_Length__c = 8;
            calleBlancos.Time_Position__c = '5,6,7,8';
        	calleBlancos.Plant_Identifier__c = 'L1SJ';
            testCodeSettings.add(calleBlancos);
          
            database.insert(testCodeSettings);
             
            //need to call  insertCaseCheck
            Region__c testRegion = new Region__c(name= 'testRegion', Country_Code__c = 'CR');
            insert testRegion;
            
            
            
            
            testAccounts = TestDataUtility.createAccount(1);
            testAccounts[0].type='Bottler';
            testAccounts[0].Shipping_Country__c='Costa Rica';
            testAccounts[0].shipping_administrativearea__c = 'testRegion';
            Database.insert(testAccounts);
            
            testPlant = TestDataUtility.createPlant(countryCode,1);
            testPlant[0].Name = 'FEMSA Calle Blancos';
            testPlant[0].active__c = true;
            testPlant[0].LCBU_Plant_Code__c = 'SJ';
            Database.Insert(testPlant);
            
            Production_Line__c pl = new Production_Line__c(Name = 'L1');
    
            pl.Active__c = True;
            pl.Plant__c = testPlant[0].Id;
            pl.Country_Code__c = countryCode ;
            pl.Pack__c = 'PET';
            pl.Content__c = '200ml';
            
            testPL.add(pl);
            Database.insert(testPL);
            
            CCE_Product__c pr = new CCE_Product__c();
           
            pr.Active__c = True;
            pr.LCBU_Brand__c = 'Coca-Cola light';
            pr.Country_Code__c = countryCode;
            pr.LCBU_Flavour__c = 'Cola';
            pr.LCBU_Packaging__c = 'Jug';
            pr.LCBU_Size__c = '200ml';
            pr.Shelf_Life_In_Days__c = 18.0; // hereeeee
            testProduct.add(pr);
            Database.insert(testProduct);
            
            
            
            
            recordTypeCase = schema.SObjectType.Case.getRecordTypeInfosByName().get('Quality Complaint LCBU').getRecordTypeId();
            
            
            
            testCases = TestDataUtility.createCase(testAccounts[0].id,5);
            testCases[0].reason = 'Product Quality';
            testCases[0].Category_Level3__c = 'CARBONATION';
            testCases[0].Country_Code__c = countryCode; 
            testCases[0].CCE_Product__c = testProduct[0].Id;
            //testCases[0].Production_Line__c = testPL[0].Id;
            testCases[0].RecordTypeId = recordTypeCase;
            testCases[0].Text_BBE_Date__c = '15DEC15';
            //testCases[0].production_date__c = date.ValueOf('2016-04-30');
            testCases[0].Production_Code__c = 'L1SJ1430';
            testCases[0].Status = 'New';
            testCases[0].Description = 'test';    
      		testCases[0].Subject = 'test';
            testCases[0].LCBU_Plant_code__c = 'SJ';
            testCasesUp.add(testCases[0]);
            
            testCases[1].reason = 'Product Quality';
            testCases[1].Category_Level3__c = 'CARBONATION';
            testCases[1].Country_Code__c = countryCode;
            testCases[1].CCE_Product__c = testProduct[0].Id;
            //testCases[1].Production_Line__c = testPL[0].Id;
            testCases[1].RecordTypeId = recordTypeCase;       
            testCases[1].Status = 'New';
            testCases[1].Description = 'test';
            testCases[1].Text_BBE_Date__c = '15DEC15';
            //testCases[1].production_date__c = date.ValueOf('2016-04-30');
            testCases[1].Production_Code__c = 'L1SJ1430';
            testCases[1].Subject = 'test';
        	testCases[1].LCBU_Plant_code__c = 'SJ';
            testCasesUp.add(testCases[1]);
            
             testCases[2].reason = 'Product Quality';
            testCases[2].Category_Level3__c = 'CARBONATION';
            testCases[2].Country_Code__c = countryCode;
            testCases[2].CCE_Product__c = testProduct[0].Id;
            //testCases[2].Production_Line__c = testPL[0].Id;
            testCases[2].RecordTypeId = recordTypeCase;
            testCases[2].Status = 'Open';
            testCases[2].Description = 'test';
            testCases[2].Text_BBE_Date__c = '15DEC15';
            testCases[2].Production_Code__c = 'L1SJ1430';  
        	testCases[2].Subject = 'test';
            testCases[2].LCBU_Plant_code__c = 'SJ';
             //testCasesUp.add(testCases[2]);
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
            trendInsert.Brand__c = 'Coca-Cola light';
            trendInsert.Flavour__c = 'Cola';
            trendInsert.Size__c = '1 Liter';
            trendInsert.Packaging__c = 'Jug';
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
        testCases[2].Text_BBE_Date__c = '15DEC15';
        testCases[2].Production_Code__c = 'L1SJ1430';  
        testCases[2].Subject = 'test';
        testCases[2].LCBU_Plant_code__c = 'SJ';
        test.StartTest();
        database.insert(testCases[2]);
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
            testCases[3].Text_BBE_Date__c = '15DEC15';
            testCases[3].Production_Code__c = 'L1SJ1430';
            testCases[3].Subject = 'test';
            testCases[3].LCBU_Plant_code__c = 'SJ';
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
        testCases[4].Text_BBE_Date__c = '15DEC15';
        testCases[4].Production_Code__c = 'L1SJ1430';  
        testCases[4].Subject = 'test';
        testCases[4].LCBU_Plant_code__c = 'SJ';
        
        database.insert(testCases[4]);
        testCases[4].Channel_of_Answer__c = 'Phone';
        testCases[4].Status = 'Closed';
        database.Update(testCases[4]);
        LCBUCaseTrend.RemoveCaseFromTrend(new List<Id> {testCases[4].Id});
        //testCases[4].Category_Level3__c = 'Injury';
        //Database.Update(testCases[4]);
        test.stopTest();
        }
}