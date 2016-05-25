@isTest
public class ECICGlobalUpdateJobTest {
	public static testMethod void testUpdateJob(){
		
		ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);
		//User u = ECICTestHelper.getCurrentUser();
		
		List <Account> accounts = new List<Account>();
		ECICTestHelper.createRegion('Madrid');
		for(integer i = 0; i<50; i++){
			Account a = ECICAccountTestHelper.createAccount();
			a.Name = 'testAccount'+'i';
			a.Ownerid = UserInfo.getUserId();
			a.Point_Of_Sale__c = false;
			a.Description = 'Test Description #1';
			accounts.add(a);
		}
		insert accounts;
		Test.StartTest();
		List<String> fieldsToUpdate = new String[]{'Description', 'Active__c'};
		List<String> valueForUpdate = new String[]{'Test Description #2', 'false'};
		Database.executeBatch(new ECICGlobalUpdateJob( 'SELECT Description, Active__c FROM'+
				' Account WHERE Name Like \'testAccount%\'' , fieldsToUpdate, valueForUpdate), 50);
		
		Test.StopTest();
		
		//System.AssertEquals(database.countquery('SELECT COUNT()'
			//	+' FROM Account WHERE Point_Of_Sale__c=true and Name LIKE \'testAccount%\''), 50); 
	} 
}