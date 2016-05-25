@isTest
public class TEST_DummyUserProfileFactory 
{
	public class Config
	{
		Id	photoId = null;
		
		public Config(){}
	}
	
	// -------------------------------------------------------------------------------------------------

	public static User_Profile__c create(Config config, Boolean insertNow)
	{
		TEST_UniqueHelper unique = new TEST_UniqueHelper('Dummy Country Settings');
		
        Id defaultId = '00520000002rses';
        
        User_Profile__c userProfile  =  new User_Profile__c();
                        userProfile.photo_id__c =  TEST_ConfigHelper.chooseValue(config.photoId, defaultId); 
                    
        if (insertNow) { System.runAs(ECICRunUserTestHelper.SETUP_DATA_CREATION_USER) { insert userProfile; } }
	  	return userProfile;
	} 

	public static User_Profile__c create(Boolean insertNow) { return create (new Config(), insertNow); }
	public static User_Profile__c create() 				    { return create (false); }
	
}