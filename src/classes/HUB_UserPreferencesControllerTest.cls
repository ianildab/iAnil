@isTest
public with sharing class HUB_UserPreferencesControllerTest {
	static testMethod void myUnitTest() {
		User u = new User();
		ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(u);
        HUB_UserPreferencesController objClass = new HUB_UserPreferencesController(sc);
        objClass.savePreferences();
        objClass.cancel();
	}

}