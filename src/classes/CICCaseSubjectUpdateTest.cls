@isTest
public class CICCaseSubjectUpdateTest {
     private static List<Case> testCases=new List<Case>();
     private static List<Account> testAccounts=new List<Account>();
     private static List<Case> testCasesOld = new List<Case>();
     
     static testMethod void testCaseSubjectUpdation() {
        Region__c testRegion = new Region__c(name= 'testRegion', Country_Code__c = 'ES');
        insert testRegion;
        
        testAccounts = TestDataUtility.createAccount(1);
        testAccounts[0].type='Bottler';
        testAccounts[0].Shipping_Country__c='Spain';
        testAccounts[0].shipping_administrativearea__c = 'testRegion';
        Database.insert(testAccounts);
        
        testCases = TestDataUtility.createCase(testAccounts[0].id, 3);
        testCases[0].reason = 'Product Quality';
        testCases[0].Category_Level3__c = 'CARBONATION';
        testCases[0].Subject = 'test case dummy subject';
        
        testCases[1].Subject = 'test case dummy subject';
        
        testCases[2].reason = 'Product Quality';
        testCases[2].Category_Level3__c = 'CARBONATION';
        
        testCases[0].id = '50011000003bCb9';
        testCases[1].id = '50011000003bVb9';
        testCases[2].id = '50011000003bGf9';
        
        
        //testCasesOld.addAll(testCases);
        CICCaseSubjectUpdate.updateSubjectBeforeInsert(null, testCases);
        
        testCasesOld = TestDataUtility.createCase(testAccounts[0].id, 3);
        testCasesOld[0].reason = 'Product Quality';
        testCasesOld[0].Category_Level3__c = 'CARBONATION';
        testCasesOld[0].Subject = 'test case dummy subject';
        
        testCasesOld[1].Subject = 'test case dummy subject';
        
        testCasesOld[2].reason = 'Product Quality';
        testCasesOld[2].Category_Level3__c = 'CARBONATION';
        
        testCasesOld[0].id = '50011000003bCb9';
        testCasesOld[1].id = '50011000003bVb9';
        testCasesOld[2].id = '50011000003bGf9';
        
        //Database.insert(testCases);
        for(Case c : testCasesOld){
            System.debug('ids***** ' + c.id);
            System.debug('before ***** ' + c.reason);
        }
        
        testCases[0].Subject = 'Product Quality - CARBONATION test case dummy subject';
        testCases[0].reason = 'Corporate (I)';
        testCases[0].Category_Level3__c = 'Interview';
        
        testCases[1].Subject = 'new dummy subject';
        testCases[1].reason = 'Corporate (I)';
        testCases[1].Category_Level3__c = 'Interview';
        testCases[2].subject= null;
        
        for(Case c : testCasesOld){
            System.debug('ids***** ' + c.id);
            System.debug('before ***** ' + c.reason);
        }
        for(Case c : testCases){
            System.debug('ids***** ' + c.id);
            System.debug('after ***** ' + c.reason);
        }
        
        
        CICCaseSubjectUpdate.updateSubjectBeforeUpdate(testCasesOld , testCases);
        
        
     }
}