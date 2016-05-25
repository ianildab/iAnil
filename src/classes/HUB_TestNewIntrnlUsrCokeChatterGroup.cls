@isTest
private class HUB_TestNewIntrnlUsrCokeChatterGroup {
    
    @isTest public static void testCokeUser() {

        User testUser = new User();
        testUser.Username= 'test_Userab2014@coca-cola.com';
        testUser.Email = 'testuserab123@coca-cola.com';
        testUser.Lastname = 'user123';
        testUser.Firstname = 'test1';
        testUser.Alias = 'testabc1';
        testUser.CommunityNickname = '12346';
        testUser.ProfileId = [SELECT id,name from Profile where name = 'Standard User'].id;

        testUser.TimeZoneSidKey = 'GMT';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';

        System.debug ( JSON.serializePretty( testUser ) );

        insert testUser;
    }
    
    @isTest public static void testNonCokeUser() {
        User testUser = new User();

        testUser.Username= 'testUser_20147@gmail.com';
        testUser.Email = 'testuser1@gmail.com';
        testUser.Lastname = 'user2';
        testUser.Firstname = 'test2';
        testUser.Alias = 'test2345';
        testUser.CommunityNickname = '12346';
        testUser.ProfileId = [SELECT id,name from Profile where name = 'Standard User'].id;

        testUser.TimeZoneSidKey = 'GMT';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';

        System.debug ( JSON.serializePretty( testUser ) );

        insert testUser;
    }
    
}