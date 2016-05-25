@isTest
public class CCEConcentratedPartNameInsertCheckTest {
    
    static testmethod void addPartNameTest()
    { 
        try
        {
            List<Account> lstAccount = TestDataUtility.createAccount(1);
            insert lstAccount;
            List<Case> lstcase = TestDataUtility.createCase(lstAccount[0].Id,1);
            insert lstCase;
            Case c = LstCase[0];
            LIST<Concentrate_Part_Number__c> cList = new List<Concentrate_Part_Number__c>();
           	
            clist.add(PartNameInsertCheckTestUtility.createTestDataPartNumber('Part 1',c));            
           	clist.add(PartNameInsertCheckTestUtility.createTestDataPartNumber('Part 5',c));
            clist.add(PartNameInsertCheckTestUtility.createTestDataPartNumber('Part 2',c));
            clist.add(PartNameInsertCheckTestUtility.createTestDataPartNumber('Parttest',c));
   
            insert cList;
        }
        catch(Exception e)
        {
            Boolean expectedException =  e.getMessage().contains(System.Label.PartNameError) ? true : false;
			System.AssertEquals(expectedException, true);
            
        }
        
    }

}