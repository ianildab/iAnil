@isTest
private class ECICCaseDispatherHelperTest {
    public  static final User            TEST_RUN_USER                      = ECICRunUserTestHelper.create();
    public  static final Map<String,Id>  CASE_RECORD_TYPE_ID_BY_NAME_MAP    = SEPRecordTypesCache.GetRecordTypeIdsByDeveloperNameMap(Case.SObjectType);
    private static final String          DUMMY_COUNTRY_CODE                 = 'T0';
    private static final String          DUMMY_EXTRA_COUNTRY_CODE           = 'X0';
    /*#CICTemplateTest - Start*/
    private static final String          DUMMY_CASE_RT_DEV_NAME             = ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME;
    private static final String          DUMMY_EXTRA_CASE_RT_DEV_NAME       = ECICCommonConstants.INQUIRY_IBERIA_DEVNAME;
    /*#CICTemplateTest - End*/
    private static void isRecordTypeAvailableTest( Boolean targetRecordTypeInEnabledCountry,  Boolean countryHasExtraEnabledRecordTypes, Boolean userHasExtraEnabledCountries ) {
        assignRecordTypeForTestUser(targetRecordTypeInEnabledCountry, countryHasExtraEnabledRecordTypes, userHasExtraEnabledCountries);
        
        String resultString = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                resultString = ECICCaseDispatherHelper.isRecordTypeAvailable (TEST_RUN_USER.Id, CASE_RECORD_TYPE_ID_BY_NAME_MAP.get(DUMMY_CASE_RT_DEV_NAME));
            }
            Test.stopTest();
        }
        
        if (!targetRecordTypeInEnabledCountry && !userHasExtraEnabledCountries) { System.assertEquals ( Label.Case_NoEnabledCountries_Error,    resultString    ); }
        else if (!targetRecordTypeInEnabledCountry)                             { System.assertEquals ( Label.Case_RecordType_Error,            resultString    ); }
        else                                                                    { System.assertEquals ( '',                                     resultString    ); }
    }
    
    // --------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    private static testMethod void nothingEnabledIsRecordTypeAvailableTest()                                            { isRecordTypeAvailableTest( false, false,  false   ); }
    private static testMethod void countryHasExtraRTEnabledIsRecordTypeAvailableTest()                                  { isRecordTypeAvailableTest( false, true,   false   ); }
    private static testMethod void countryHasExtraRTEnabledUserExtraEnabledCountryIsRecordTypeAvailableTest()           { isRecordTypeAvailableTest( false, true,   true    ); }
    private static testMethod void userExtraEnabledCountryIsRecordTypeAvailableTest()                                   { isRecordTypeAvailableTest( false, false,  true    ); }
    private static testMethod void targetEnabledIsRecordTypeAvailableTest()                                             { isRecordTypeAvailableTest( true,  false,  false   ); }
    private static testMethod void targetEnabledUserExtraEnabledCountryIsRecordTypeAvailableTest()                      { isRecordTypeAvailableTest( true,  false,  true    ); }
    private static testMethod void targetEnabledcountryExtraRTEnabledIsRecordTypeAvailableTest()                        { isRecordTypeAvailableTest( true,  true,   false   ); }
    private static testMethod void targetEnabledcountryExtraRTEnabledUserExtraEnabledCountryIsRecordTypeAvailableTest() { isRecordTypeAvailableTest( true,  true,   true    ); }
    
    //---------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    private static void assignRecordTypeForTestUser(Boolean targetRecordTypeInEnabledCountry, Boolean countryHasExtraEnabledRecordTypes, Boolean userHasExtraEnabledCountries) {
        TEST_RUN_USER.enabled_countries__c = '';
        List<TEST_DummyCountrySpecificSettingsFactory.Config> countrySettingConfigList = new List<TEST_DummyCountrySpecificSettingsFactory.Config>();
        
        if (targetRecordTypeInEnabledCountry) {
            TEST_RUN_USER.enabled_countries__c  += (targetRecordTypeInEnabledCountry ? DUMMY_COUNTRY_CODE +';' : '');
            countrySettingConfigList.add(createCountrySpecificSetting(DUMMY_COUNTRY_CODE, 
                                                                targetRecordTypeInEnabledCountry,   DUMMY_CASE_RT_DEV_NAME,
                                                                countryHasExtraEnabledRecordTypes,  DUMMY_EXTRA_CASE_RT_DEV_NAME));
        }
        
        if (userHasExtraEnabledCountries) {
            TEST_RUN_USER.enabled_countries__c += DUMMY_EXTRA_COUNTRY_CODE + ';';
            countrySettingConfigList.add(createCountrySpecificSetting(DUMMY_EXTRA_COUNTRY_CODE, 
                                                                false,      DUMMY_CASE_RT_DEV_NAME,
                                                                true,       DUMMY_EXTRA_CASE_RT_DEV_NAME));
        }
        
        TEST_DummyCountrySpecificSettingsFactory.createList(countrySettingConfigList, true);
        update      TEST_RUN_USER;
    }
    
    private static TEST_DummyCountrySpecificSettingsFactory.Config createCountrySpecificSetting(String dummyCountryCode, 
                                                                        Boolean hasTargetRecordType, String targetRecordTypeDevName,
                                                                        Boolean hasExtraRecordType,  String extraRecordTypeDevName) {
        
        TEST_DummyCountrySpecificSettingsFactory.Config dummyConfig = new TEST_DummyCountrySpecificSettingsFactory.Config();
                                                        dummyConfig.countryCode             = dummyCountryCode;                                                        
                                                        dummyConfig.allowedCaseRecordTypes  =  ( (hasTargetRecordType) ? targetRecordTypeDevName+';' : '' ) 
                                                                                             + ( (hasExtraRecordType)  ? extraRecordTypeDevName+';'  : '' );
        return dummyConfig;
    }
    
    private static testMethod void noRecordTypeErrorTest() {
        TEST_RUN_USER.enabled_countries__c = DUMMY_COUNTRY_CODE;
        update      TEST_RUN_USER;
        
        String resultString = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                resultString = ECICCaseDispatherHelper.isRecordTypeAvailable (TEST_RUN_USER.Id, CASE_RECORD_TYPE_ID_BY_NAME_MAP.get(DUMMY_CASE_RT_DEV_NAME));
            }
            Test.stopTest();
        }
        
        System.assertEquals ( Label.Case_NoRecordType_Error, resultString );
    }
}