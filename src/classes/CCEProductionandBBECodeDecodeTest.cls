@isTest
public class CCEProductionandBBECodeDecodeTest{
    private static List<Case> testCases = new List<Case>();
    private static Map<Id,Case> testCasesMap = new Map<Id,Case>();
    private static List<Case> newTestCases = new List<Case>();
    private static List<Plant__c> testPlants = new List<Plant__c>();
    private static List<CCE_Product__c> testProducts = new List<CCE_Product__c>();
    private static List<Production_Line__c> testProductionLines = new List<Production_Line__c>();
    private static List<CCE_Production_Code_Decode__c> testCodeSettings = new List<CCE_Production_Code_Decode__c>();
    private static RecordType qualityRT = [SELECT id, name from RecordType where developerName = 'Quality_Complaint_NWEN'];
    
    private static void createTestData(){
        CCE_Production_Code_Decode__c antwerp = new CCE_Production_Code_Decode__c(name = 'AN1');
        antwerp.Plant__c = 'Antwerp';
        antwerp.BBE_Code_Length__c = 7;
        antwerp.BBE_Day_Position__c = '1,2';
        antwerp.BBE_Month_Position__c = '3,4,5';
        antwerp.BBE_Year_Position__c = '6,7';
        antwerp.Day_Position__c = '1,2,3';
        antwerp.Is_Co_Packers__c = FALSE;
        antwerp.Line_Position__c = '6';
        antwerp.Plant_Position__c = '4,5';
        antwerp.Production_Line__c = '1';
        antwerp.Prod_Code_Length__c = 11;
        antwerp.Time_Position__c = '7,8,9,10,11';
        antwerp.Plant_Identifier__c = 'AN1';
        antwerp.Business_Unit__c = 'NWEN' ;
        testCodeSettings.add(antwerp);
        
        CCE_Production_Code_Decode__c Mack = new CCE_Production_Code_Decode__c(name = 'Mack');
        Mack.Plant__c = 'Mack';
        Mack.BBE_Code_Length__c = 7;
        Mack.BBE_Day_Position__c = '1,2';
        Mack.BBE_Month_Position__c = '3,4,5';
        Mack.BBE_Year_Position__c = '6,7';
        Mack.Colon_Position__c = '3';
        Mack.Is_Co_Packers__c = TRUE;
        Mack.Prod_Code_Length__c = 8;
        Mack.Time_Position__c = '1,2,3,4,5';
        Mack.Week_Day_Number_Position__c = '6';
        Mack.Week_Number_Position__c = '7,8';
        Mack.Plant_Identifier__c = 'Mack';
        Mack.Business_Unit__c = 'NWEN' ;
        testCodeSettings.add(mack);
        
        Database.insert(testCodeSettings);
        
        CCE_Product__c testProduct1 = new CCE_Product__c(name = 'testProduct1');
        testProduct1.active__c = TRUE;
        testProduct1.shelf_life__c = 9;
        testProduct1.Country_Code__c = 'BE';
        testProduct1.Packaging__c = 'RGB';
        testProduct1.Size__c = '200ml';
        testProducts.add(testProduct1);
        
        CCE_Product__c testProduct2 = new CCE_Product__c(name = 'testProduct2');
        testProduct2.active__c = TRUE;
        testProduct2.shelf_life__c = 9;
        testProduct2.Country_Code__c = 'BE';
        testProduct2.Packaging__c = 'PET';
        testProduct2.Size__c = '500ml';
        testProducts.add(testProduct2);
        
        CCE_Product__c testProduct3 = new CCE_Product__c(name = 'Unknown');
        testProduct3.active__c = TRUE;
        testProduct3.Country_Code__c = 'BE';
        testProducts.add(testProduct3);
        
        CCE_Product__c testProduct4 = new CCE_Product__c(name = 'testProduct1');
        testProduct4.active__c = TRUE;
        testProduct4.shelf_life__c = 9;
        testProduct4.Country_Code__c = 'FR';
        testProduct4.Packaging__c = 'RGB';
        testProduct4.Size__c = '200ml';
        testProducts.add(testProduct4);
        
        Database.insert(testProducts);
        
        Plant__c testPlant1 = new Plant__c(name = 'Antwerp');
        testPlant1.Active__c = TRUE;
        testPlant1.Country_Code__c = 'BE';
        testPlant1.CCE_Bottler__c = 'Coca-Cola Enterprises';
        testPlants.add(testPlant1);
        
        Plant__c testPlant2 = new Plant__c(name = 'Mack');
        testPlant2.Active__c = TRUE;
        testPlant2.Country_Code__c = 'BE';
        testPlant2.CCE_Bottler__c = 'co-packer';
        testPlants.add(testPlant2);
        
        Plant__c testPlant3 = new Plant__c(name = 'Unknown');
        testPlant3.Active__c = TRUE;
        testPlant3.Country_Code__c = 'BE';
        testPlants.add(testPlant3);
        
        Database.insert(testPlants);
        
        Production_Line__c testLine1 = new Production_Line__c(name = '1');
        testLine1.Active__c = TRUE;
        testLine1.Country_Code__c = 'BE';
        testLine1.Content__c = 'RGB';
        testLine1.Pack__c = '200ml';
        testLine1.Plant__c = testPlant1.id;
        testProductionLines.add(testLine1);
        
        Production_Line__c testLine2 = new Production_Line__c(name = '2');
        testLine2.Active__c = TRUE;
        testLine2.Country_Code__c = 'BE';
        testLine2.Content__c = 'PET';
        testLine2.Pack__c = '500ml';
        testLine2.Plant__c = testPlant2.id;
        testProductionLines.add(testLine2);
        
        Database.insert(testProductionLines);
        
        testCases = TestDataUtility.createCase(null, 4);
        testCases[0].recordTypeId = qualityRT.id;
        testCases[0].country_Code__c = 'BE';
        testCases[0].CCE_Product__c = testProduct1.id;
        testCases[0].Production_Code__c = '123AN112:12';
        testCases[0].Text_BBE_Date__c = '13oct15';
        testCases[0].id = '50011000003bCb9';
        
        testCases[1].recordTypeId = qualityRT.id;
        testCases[1].country_Code__c = 'BE';
        testCases[1].CCE_Product__c = testProduct2.id;
        testCases[1].Production_Code__c = '19:36140';
        testCases[1].Text_BBE_Date__c = '12JUL15';
        testCases[1].id = '50011000003bVb9';
        
        testCases[2].recordTypeId = qualityRT.id;
        testCases[2].country_Code__c = 'BE';
        testCases[2].CCE_Product__c = testProduct3.id;
        testCases[2].Plant__c = testPlant3.id;
        testCases[2].id = '50011000003bGb9';
        
        testCases[3].recordTypeId = qualityRT.id;
        testCases[3].country_Code__c = 'BE';
        testCases[3].CCE_Product__c = testProduct1.id;
        testCases[3].Production_Code__c = '123AN112:12';
        testCases[3].Text_BBE_Date__c = '13AUG15';
        testCases[3].id = '50011000003bXb9';
        
        newTestCases = TestDataUtility.createCase(null, 4);
        newTestCases[0].recordTypeId = qualityRT.id;
        newTestCases[0].country_Code__c = 'BE';
        newTestCases[0].CCE_Product__c = testProduct1.id;
        newTestCases[0].Production_Code__c = '123AN112:33';
        newTestCases[0].Text_BBE_Date__c = '13oct15';
        newTestCases[0].id = '50011000003bCb9';
        
        newTestCases[1].recordTypeId = qualityRT.id;
        newTestCases[1].country_Code__c = 'BE';
        newTestCases[1].CCE_Product__c = testProduct2.id;
        newTestCases[1].Production_Code__c = '123GB112:33';
        newTestCases[1].Text_BBE_Date__c = '12JUL15';
        newTestCases[1].id = '50011000003bVb9';
        
        newTestCases[2].recordTypeId = qualityRT.id;
        newTestCases[2].country_Code__c = 'BE';
        newTestCases[2].CCE_Product__c = testProduct4.id;
        newTestCases[2].Production_Code__c = '123AN112:33';
        newTestCases[2].Text_BBE_Date__c = '13Nov15';
        newTestCases[2].id = '50011000003bGb9';
        
        newTestCases[3].recordTypeId = qualityRT.id;
        newTestCases[3].country_Code__c = 'BE';
        newTestCases[3].CCE_Product__c = testProduct1.id;
        newTestCases[3].Production_Code__c = null;
        newTestCases[3].id = '50011000003bXb9';
        
        for(Case cs:testCases){
            testCasesMap.put(cs.id,cs);
        
        }
        
    }
    
    static testMethod void productionandBBECodeDecodeTest(){
        createTestData();
        System.debug('*********'+ECICCaseTriggerRegionCache.getActiveCCEProductByIdMap());
        System.debug('*********'+testProducts[0]+testProducts[1]);
        CCEProductionCodeDecoding.populateProductionCodeBeforeInsert(testCases);
        CCEProductionCodeDecoding.populateProductionCodeBeforeUpdate(testCases,testCasesMap);
        
        
        CCEProductionCodeDecoding.populateProductionCodeBeforeUpdate(newTestCases,testCasesMap);
    }
}