@isTest
public class ECICCaseAccountTestHelper 
{
	public final Account DUMMY_POINT_OF_SALE_ACCOUNT;
	public final Account DUMMY_POINT_OF_SALE_KEY_ACCOUNT;
	public final Account DUMMY_SUPPLIER_ACCOUNT;
	public final Account DUMMY_BOTTLER_ACCOUNT;
	
	public ECICCaseAccountTestHelper (ECICCaseRegionTestHelper caseRegionTestHelper)
	{
			// We only want/need to create each of these Accounts once, and all at the same time, to reduce SOQL consumptions
			List<Account> dummyAccountList = new List<Account>();
						  dummyAccountList.add(ECICAccountTestHelper.createPointOfSale());
						  dummyAccountList.add(ECICAccountTestHelper.createPoSKeyAccount());
						  dummyAccountList.add(ECICAccountTestHelper.createSupplier());
						  dummyAccountList.add(createDummyBottlerAccount(caseRegionTestHelper));
			insert 		  dummyAccountList;

			DUMMY_POINT_OF_SALE_ACCOUNT 	= dummyAccountList[0]; 
			DUMMY_POINT_OF_SALE_KEY_ACCOUNT = dummyAccountList[1];
			DUMMY_SUPPLIER_ACCOUNT			= dummyAccountList[2];
			DUMMY_BOTTLER_ACCOUNT			= dummyAccountList[3];
	}

	private static Account createDummyBottlerAccount (ECICCaseRegionTestHelper caseRegionTestHelper)
	{
		Account dummyBottler = ECICAccountTestHelper.createBottler();
			    dummyBottler.shippingState = caseRegionTestHelper.DUMMY_BOTTLER_REGION.Name; 
			    dummyBottler.region__c 	   = caseRegionTestHelper.DUMMY_BOTTLER_REGION.Id;
		 return dummyBottler;
	}
	


}