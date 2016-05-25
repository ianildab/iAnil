@isTest
public class /* with sharing */ CRMEngagementBrandCopyStrategyTest {

    static testMethod void skipTriggerInvocationTest() {
        SEPTriggerHandlerInvoker.pretendTestNotRunning = true;
        General_Settings__c generalSettings = new General_Settings__c();
        generalSettings.skipTriggers__c = true;
        
        String BRAND = Fanta;
        ID accountId = insertAccount();
        Account accountState1 = read(accountId);
        System.assertEquals(null,  accountState1.ET_CRM_Registration_Brand__c);
        System.assertEquals(false, SEPTriggerHandlerInvoker.skipTriggerInvocation());
        upsert generalSettings;
        
        insertEngagement(accountId, REGISTRATION, null);
        Account accountState2 = read(accountId);
        System.assertEquals(null, accountState2.ET_CRM_Registration_Brand__c);
        System.assertEquals(true, SEPTriggerHandlerInvoker.skipTriggerInvocation());
    }
    
    static testMethod void insertRegWithBrand() {
        /* Test if the registration engagement's brand
         * information is copied to the account's field
         *
         * Expected result: The account should have the same brand information
         * contained in the registration engament.
         */
        String BRAND = Fanta;
        
        ID accountId = insertAccount();
        Account accountState1 = read(accountId);
        System.assert(accountState1.ET_CRM_Registration_Brand__c == null, 'Brand was not empty');
        
        insertEngagement(accountId, REGISTRATION, BRAND);
        Account accountState2 = read(accountId);
        System.assertEquals(brandMap.get(Fanta), accountState2.ET_CRM_Registration_Brand__c, 'Brand was not copied correctly');
    }

    static testMethod void insertRegWithoutBrand() {
        /* Test if the registration engagement does not have brand.
         * Expected result; the brand field must be empty on the account object
         */
        ID accountId = insertAccount();
        Account accountState1 = read(accountId);
        System.assert(accountState1.ET_CRM_Registration_Brand__c == null, 'Brand was not empty');
        
        insertEngagement(accountId, REGISTRATION, null);
        Account accountState2 = read(accountId);
        System.assertEquals(null, accountState2.ET_CRM_Registration_Brand__c, 'Empty brand value was expected');
    }
    
    static testMethod void updateRegIdenpotent() {
        /* Test if the registration is inserted with brand
         * and an update comes for the engagement with the same information
         * leaves the brand information.
         * Expected result: The same brand information is shown on the account as before the update.
         */
         String BRAND = MinuteMaid;
         
         ID accountID = insertAccount();
         Account state1 = read(accountId);
         System.assert(state1.ET_CRM_Registration_Brand__c == null, 'Brand was not empty');
         
         ID engId = insertEngagement(accountID, REGISTRATION, BRAND);
         Account state2 = read(accountId);
         System.assertEquals(brandMap.get(BRAND), state2.ET_CRM_Registration_Brand__c, 'Invalid brand was read out');
         
         Engagement__c eng = readEngagement(engId);
         updateEngagement(eng);
         
         Account state3 = read(accountId);
         System.assertEquals(brandMap.get(BRAND), state3.ET_CRM_Registration_Brand__c, 'Brand information was changed');
    }
    
    static testMethod void updateEmptyRegIdenpotent() {
        /* Test if the registration is inserted with brand
         * and an update comes for the engagement with the same information
         * leaves the brand information.
         * Expected result: The same brand information is shown on the account as before the update.
         */
         String BRAND = null;
         
         ID accountID = insertAccount();
         Account state1 = read(accountId);
         System.assert(state1.ET_CRM_Registration_Brand__c == null, 'Brand was not empty');
         
         ID engId = insertEngagement(accountID, REGISTRATION, BRAND);
         Account state2 = read(accountId);
         System.assertEquals(brandMap.get(BRAND), state2.ET_CRM_Registration_Brand__c, 'Invalid brand was read out');
         
         Engagement__c eng = readEngagement(engId);
         updateEngagement(eng);
         
         Account state3 = read(accountId);
         System.assertEquals(brandMap.get(BRAND), state3.ET_CRM_Registration_Brand__c, 'Brand information was changed');
    }

    
    static testMethod void updateNonRegAndChangeName() {
        /* Test if the registration is inserted with brand
         * and an update comes for the non-engagement with other name, will
         * leaves the brand information.
         * Expected result: The update leaves The brand information untouched.
         */
         String BRAND = MareRosso;
         
         ID accountID = insertAccount();
         Account state1 = read(accountId);
         System.assert(state1.ET_CRM_Registration_Brand__c == null, 'Brand was not empty');
         
         ID engId = insertEngagement(accountID, REGISTRATION, BRAND);
         Account state2 = read(accountId);
         System.assertEquals(brandMap.get(BRAND), state2.ET_CRM_Registration_Brand__c, 'REG: Invalid brand was read out');
         
         ID nonRegId = insertEngagement(accountID, ACTIVATION, null);
         Account state3 = read(accountId);
         System.assertEquals(brandMap.get(BRAND), state3.ET_CRM_Registration_Brand__c, 'LOGIN: Invalid brand was read out');
         
         Engagement__c eng = readEngagement(engId);
         eng.Name = 'newTestEngagement';
         updateEngagement(eng);
         
         Account state4 = read(accountId);
         System.assertEquals(brandMap.get(BRAND), state4.ET_CRM_Registration_Brand__c, 'UPDATE LOGIN: Invalid brand was read out');
    }
    
    static testMethod void updateRegAndClearBrand() {
        /* Test if the registration is inserted with a brand
         * and an update comes for the engagement with no brand, will
         * clear the brand.
         * Expected result: The Brand information will be empty on the account.
         */
        String BRAND = Zico;
        
        ID accountID = insertAccount();
        Account state1 = read(accountId);
        System.assert(state1.ET_CRM_Registration_Brand__c == null, 'Brand was not empty');
        
        ID engId = insertEngagement(accountID, REGISTRATION, BRAND);
        Account state2 = read(accountId);
        System.assertEquals(brandMap.get(BRAND), state2.ET_CRM_Registration_Brand__c, 'Invalid brand was read out');
        
        insertEngagement(accountID, ACTIVATION, null);
        
        Engagement__c eng = readEngagement(engId);
        eng.Brand__c = null;
        updateEngagement(eng);
         
        Account state3 = read(accountId);
        System.assertEquals(null, state3.ET_CRM_Registration_Brand__c, 'Brand information was not changed');
        
    }
    
    static testMethod void updateRegAndChangeBrand() {
        /* Test if the registration is inserted with brand
         * and an update comes for the engagement with other brand, will
         * change the brand.
         * Expected result: The newly arrived brand information is shown on the account.
         */
        String BRAND = Zico;
        String NEW_BRAND = Aquarius;
        
        ID accountID = insertAccount();
        Account state1 = read(accountId);
        System.assert(state1.ET_CRM_Registration_Brand__c == null, 'Brand was not empty');
        
        ID engId = insertEngagement(accountID, REGISTRATION, BRAND);
        Account state2 = read(accountId);
        System.assertEquals(brandMap.get(BRAND), state2.ET_CRM_Registration_Brand__c, 'Invalid brand was read out');
        
        insertEngagement(accountID, ACTIVATION, null);
        
        Engagement__c eng = readEngagement(engId);
        eng.Brand__c = NEW_BRAND;
        updateEngagement(eng);
         
        Account state3 = read(accountId);
        System.assertEquals(brandMap.get(NEW_BRAND), state3.ET_CRM_Registration_Brand__c, 'Brand information was not changed');
         
    }
    
    static testMethod void updateRegAndChangeName() {
        /* Test if the registration is inserted with brand
         * and an update comes for the engagement with other name, will
         * leaves the brand information.
         * Expected result: The original brand information is shown on the account.
         */
        String BRAND = Zico;
        
        ID accountID = insertAccount();
        Account state1 = read(accountId);
        System.assert(state1.ET_CRM_Registration_Brand__c == null, 'Brand was not empty');
        
        ID engId = insertEngagement(accountID, REGISTRATION, BRAND);
        Account state2 = read(accountId);
        System.assertEquals(brandMap.get(BRAND), state2.ET_CRM_Registration_Brand__c, 'Invalid brand was read out');
        
        insertEngagement(accountID, ACTIVATION, null);
        
        Engagement__c eng = readEngagement(engId);
        eng.Name = 'newTestEngagement';
        updateEngagement(eng);
         
        Account state3 = read(accountId);
        System.assertEquals(brandMap.get(BRAND), state3.ET_CRM_Registration_Brand__c, 'Brand information was changed');
         
    }
    
    static testMethod void updateEmptyBrandReg() {
        /* Test if the registration is inserted with no brand
         * and an update comes for the engagement with a brand, will
         * fill out the brand information.
         * Expected result: The newly arrived brand information is shown on the account.
         */
        String BRAND = null;
        String NEW_BRAND = NordicMist;
        
        ID accountID = insertAccount();
        Account state1 = read(accountId);
        System.assert(state1.ET_CRM_Registration_Brand__c == null, 'Brand was not empty');
        
        ID engId = insertEngagement(accountID, REGISTRATION, BRAND);
        Account state2 = read(accountId);
        System.assertEquals(brandMap.get(BRAND), state2.ET_CRM_Registration_Brand__c, 'Invalid brand was read out');
        
        insertEngagement(accountID, ACTIVATION, null);
        
        Engagement__c eng = readEngagement(engId);
        eng.Brand__c = NEW_BRAND;
        updateEngagement(eng);
         
        Account state3 = read(accountId);
        System.assertEquals(brandMap.get(NEW_BRAND), state3.ET_CRM_Registration_Brand__c, 'Brand information was not changed');
    }
    
    static testMethod void insertNonRegWithBrand() {
        /* Test if the non-registration engagement with brand does not change the
         * brand value for the account.
         */
        String BRAND = Sprite;
        String NEW_BRAND = Fanta;
        
        ID accountId = insertAccount();
        Account accountState1 = read(accountId);
        System.assert(accountState1.ET_CRM_Registration_Brand__c == null, 'Brand was not empty');
        
        insertEngagement(accountId, REGISTRATION, BRAND);
        Account accountState2 = read(accountId);
        System.assertEquals(brandMap.get(BRAND), accountState2.ET_CRM_Registration_Brand__c, 'Brand was not copied correctly');
        
        insertEngagement(accountId, ACTIVATION, NEW_BRAND);
        Account accountState3 = read(accountId);
        System.assertEquals(brandMap.get(BRAND), accountState3.ET_CRM_Registration_Brand__c, 'Brand was not copied correctly');
    }
    
    static testMethod void insertNonRegWithoutBrand() {
        /* Test if the non-registration engagement without brand does not change the
         * brand value for the account.
         */
        String BRAND = Sprite;
        
        ID accountId = insertAccount();
        Account accountState1 = read(accountId);
        System.assert(accountState1.ET_CRM_Registration_Brand__c == null, 'Brand was not empty');
        
        insertEngagement(accountId, REGISTRATION, Sprite);
        Account accountState2 = read(accountId);
        System.assertEquals(brandMap.get(BRAND), accountState2.ET_CRM_Registration_Brand__c, 'Brand was not copied correctly');
        
        insertEngagement(accountId, ACTIVATION, null);
        Account accountState3 = read(accountId);
        System.assertEquals(brandMap.get(BRAND), accountState3.ET_CRM_Registration_Brand__c, 'Brand was not copied correctly');
    }
    
    static testMethod void engamentsInWrongOrder() {
        /* Test if the registration engagement with brand
         * arreves later than the activation engagement for
         * the account.
         *
         * Expected result: The account has the registration
         * brand
         */
        String BRAND = Fanta;
        
        ID accountId = insertAccount();
        Account accountState1 = read(accountId);
        System.assert(accountState1.ET_CRM_Registration_Brand__c == null, 'Brand was not empty');
        
        insertEngagement(accountId, ACTIVATION, Sprite);
        Account accountState2 = read(accountId);
        System.assertEquals(null, accountState2.ET_CRM_Registration_Brand__c, 'The activation brand is copied');
        
        insertEngagement(accountId, REGISTRATION, Fanta);
        Account accountState3 = read(accountId);
        System.assertEquals(brandMap.get(BRAND), accountState3.ET_CRM_Registration_Brand__c, 'Brand was not copied correctly');
    }
    
    /* Helpers */
    
    /* Insert a CRM related account to the database 
     * Produces the ID of the inserted account
     */
    private static ID insertAccount() {
        Account account = new Account(
            LastName='testAccount',
            Salutation='Mr',
            FirstName='test',
            PersonBirthdate=date.newInstance(2008, 12, 1),
            PersonEmail='test@email.com',
            PersonHasOptedOutOfEmail=FALSE,
            BillingStreet='test',
            ShippingStreet='test',
            PersonMailingStreet='test',
            PersonOtherStreet='test',
            Fax='12345',
            Phone='123456',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678',
            PersonOtherPhone='123456789',
            Screen_Name__pc='test',
            sf4twitter__Fcbk_User_Id__pc='test',
            sf4twitter__Twitter_User_Id__pc='test',
            Identity_Card_Number__pc='test',
            Website='test' );
        insert account;
        return account.id;
    }
    
    /* Read the CRM related from the database for the given ID
     */
    private static Account read(ID accountId) {
        Account account;
        account = [
            SELECT
                id,
                Activation_Date__pc,
                Consumer_Status__pc,
                Salutation,
                FirstName,
                LastName,
                PersonBirthdate,
                PersonEmail,
                PersonHasOptedOutOfEmail,
                BillingStreet,
                ShippingStreet,
                PersonMailingStreet,
                PersonOtherStreet,
                Fax,
                Phone,
                PersonHomePhone,
                PersonMobilePhone,
                PersonOtherPhone,
                Screen_Name__pc,
                sf4twitter__Fcbk_User_Id__pc,
                sf4twitter__Twitter_User_Id__pc,
                Identity_Card_Number__pc,
                Website ,
                ET_CRM_Registration_Brand__c
            FROM Account
            WHERE Id =:accountId
        ];
        return account;
    }
    
    /* Insert an engagement with interaction and 
     * Produces the ID of the inserted engagement.
     */
    private static ID insertEngagement(ID accountId, String i, String brand) {
        Engagement__c engagement = new Engagement__c(
            Name='testEngagement',
            Consumer__c = accountId,
            Brand__c = brand,
            Interaction__c=i
        );
        insert engagement;
        return engagement.Id;
    }
    
    private static Engagement__c readEngagement(ID engagementId) {
        Engagement__c e = [
            SELECT
                Name,
                Consumer__c,
                Brand__c,
                Interaction__c
            FROM Engagement__c
            WHERE Id =: engagementId
        ];
        return e;
    }
    
    private static void updateEngagement(Engagement__c e) {
        update e;
    }

    /* Constants */
    
    /* Interactions */
    private static final String REGISTRATION = 'Register';
    private static final String ACTIVATION   = 'Activate Account';
    
    /* Brands */
    private static final String ClassicCoke= 'Classic Coke';
    private static final String Fanta      = 'Fanta';
    private static final String NordicMist = 'Nordic Mist';
    private static final String Sprite     = 'Sprite';
    private static final String Fioravanti = 'Fioravanti';
    private static final String Powerade   = 'Powerade';
    private static final String Aquarius   = 'Aquarius';
    private static final String LimonYNada = 'Limon&Nada';
    private static final String MinuteMaid = 'Minute Maid';
    private static final String Aquabona   = 'Aquabona';
    private static final String Nestea     = 'Nestea';
    private static final String Burn       = 'Burn';
    private static final String Zico       = 'Zico';
    private static final String DietCoke   = 'Diet Coke';
    private static final String CokeZero   = 'Coke Zero';
    private static final String MareRosso  = 'Mare Rosso';
    private static final String Schuss     = 'Schuss';
    
    private static Map<String, String> brandMap = new Map<String, String>();
    
    static {
        brandMap.put(ClassicCoke,'Classic Coke');
        brandMap.put(Fanta,'Fanta');
        brandMap.put(NordicMist,'Nordic Mist');
        brandMap.put(Sprite,'Sprite');
        brandMap.put(Fioravanti,'Fioravanti');
        brandMap.put(Powerade,'Powerade');
        brandMap.put(Aquarius,'Aquarius');
        brandMap.put(LimonYNada,'Limon&Nada');
        brandMap.put(MinuteMaid,'Minute Maid');
        brandMap.put(Aquabona,'Aquabona');
        brandMap.put(Nestea,'Nestea');
        brandMap.put(Burn,'Burn');
        brandMap.put(Zico,'Zico');
        brandMap.put(DietCoke,'Diet Coke');
        brandMap.put(CokeZero,'Coke Zero');
        brandMap.put(MareRosso,'Mare Rosso');
        brandMap.put(Schuss,'Schuss');
    }
    
}