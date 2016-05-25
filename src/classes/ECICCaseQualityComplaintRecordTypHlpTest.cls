@isTest
private class ECICCaseQualityComplaintRecordTypHlpTest 
{
    public  static final User                               TEST_RUN_USER       = ECICRunUserTestHelper.create();
    private static Integer                                  countryCodeCount    = 0;
    private static ECICCaseAccountAndContactSetterStrategy  dummyStrategy       = new ECICCaseAccountAndContactSetterStrategy();
    
    // ----------------------------------------------------------------------------------------------------------------------------
    
    private static void getCountrySpecificRecordTypeIdWebServiceTest(String targetRecordTypeName, Boolean hasValidCountrySetting ) 
    {
        String dummyCountryCode = '' + ++countryCodeCount;
        Id recordTypeId = (targetRecordTypeName != '') ? Schema.SObjectType.Case.RecordTypeInfosByName.get(targetRecordTypeName).RecordTypeId : null;
        if (hasValidCountrySetting) { TEST_DummyCountrySpecificSettingsFactory.create (new TEST_DummyCountrySpecificSettingsFactory.Config(dummyCountryCode, recordTypeId), TEST_DummyInsertModeEnum.REAL); }
        
        String resultIdAsString = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultIdAsString = ECICCaseQualityComplaintRecordTypeHelper.getCountrySpecificRecordTypeId(dummyCountryCode);
            }
            Test.stopTest();
        }
        
        String expectedResult = (hasValidCountrySetting)    ? (String) recordTypeId : 'COUNTRY_QUALITY_COMPLAINT_NOT_SET';
        System.assertEquals(expectedResult, resultIdAsString);
    }
    /*#CICTemplateTest*/
    private static testMethod void getQualityComplaintWebServiceTest()              { getCountrySpecificRecordTypeIdWebServiceTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_RTNAME,             true);  }
    //private static testMethod void getSimplifiedQualityComplaintWebServiceTest()    { getCountrySpecificRecordTypeIdWebServiceTest('Simplified Quality Complaint',  true);  }
    private static testMethod void getNoCountrySettingFailureWebServiceTest()       { getCountrySpecificRecordTypeIdWebServiceTest('',                              false); }
    // Not possible to test Country Settings without Quality Complaint Record Type Id setting because this is not allowed (and can only happen for old settings.) 
    
    private static void getCountrySpecificRecordTypeIdLocalTest(String caseRecordTypeName, Boolean hasValidCountrySetting, Boolean isSimplifiedComplaintCountry) 
    {
        String dummyCountryCode =  'H' + ++countryCodeCount;
        Id caseRecordTypeId     = Schema.SObjectType.Case.RecordTypeInfosByName.get(caseRecordTypeName).RecordTypeId;
        /*#CICTemplateTest*/
        Id qualityRecordTypeId  = Schema.SObjectType.Case.RecordTypeInfosByName.get(isSimplifiedComplaintCountry ? 'Simplified Quality Complaint' : ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_RTNAME).RecordTypeId;
        
        TEST_DummyCaseConfig    caseConfig = new TEST_DummyCaseConfig();
                                caseConfig.recordTypeId = caseRecordTypeId;
                                caseConfig.countryCode  = (hasValidCountrySetting) ? dummyCountryCode : ('N' + ++countryCodeCount); // for the setting to be missing, we need to make this a mismatch!
        Case dummyCase = TEST_DummyGenericCaseFactory.create (caseConfig, TEST_DummyInsertModeEnum.NONE);
        
        if (hasValidCountrySetting) { 
            TEST_DummyCountrySpecificSettingsFactory.create (new TEST_DummyCountrySpecificSettingsFactory.Config(dummyCountryCode, qualityRecordTypeId), TEST_DummyInsertModeEnum.REAL); 
        } else {
            Country_Specific_Settings__c setting = Country_Specific_Settings__c.getValues('N' + countryCodeCount);
            if (setting != null) { delete setting; }
        }
        
        Id  resultId    = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                resultId = ECICCaseQualityComplaintRecordTypeHelper.getCountrySpecificRecordTypeId(dummyCase);
            }
            Test.stopTest();
        }
        
        Id expectedResultId = (!hasValidCountrySetting || !ECICCaseQualityComplaintRecordTypeHelper.QUALITY_COMPLAINT_NAME_SET.contains(caseRecordTypeName))
                                ?    caseRecordTypeId
                                :    qualityRecordTypeId;
        
        System.assertEquals(expectedResultId, resultId);
        if  (!hasValidCountrySetting && ECICCaseQualityComplaintRecordTypeHelper.QUALITY_COMPLAINT_NAME_SET.contains(caseRecordTypeName)) {
            System.assertEquals ( ECICCaseQualityComplaintRecordTypeHelper.QUALITY_COMPLAINT_NAME_SET.contains(caseRecordTypeName),
                                  ECICCaseQualityComplaintRecordTypeHelper.errMessage.contains ('Could not reassign Quality Complaint RecordType for country code ' + dummyCase.Country_Code__c + '.')
                                 );
        }
    }
    /*#CICTemplateTest - Start*/
   // private static testMethod void qualityComplaintValidSimplifiedCountryTest()             { getCountrySpecificRecordTypeIdLocalTest('Quality Complaint',              true,    true); }
   // private static testMethod void simplifiedQualityComplaintValidSimplifiedCountryTest()   { getCountrySpecificRecordTypeIdLocalTest('Simplified Quality Complaint',   true,    true); }    // Because this already simplified but the test method shouldn't change it.
   // private static testMethod void nonQualityComplaintValidSimplifiedCountryTest()          { getCountrySpecificRecordTypeIdLocalTest('Non-Quality Complaint',          true,    true); }
   // private static testMethod void inquiryValidSimplifiedCountryTest()                      { getCountrySpecificRecordTypeIdLocalTest('Inquiry',                        true,    true); }
   // private static testMethod void thanksValidSimplifiedCountryTest()                       { getCountrySpecificRecordTypeIdLocalTest('Compliment',                     true,    true); }
   // private static testMethod void jokeValidSimplifiedCountryTest()                         { getCountrySpecificRecordTypeIdLocalTest('Useless',                        true,    true); }
    
    private static testMethod void qualityComplaintValidComplicatedCountryTest()            { getCountrySpecificRecordTypeIdLocalTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_RTNAME,              true,    false); }
   // private static testMethod void simplifiedQualityComplaintValidComplicatedCountryTest()  { getCountrySpecificRecordTypeIdLocalTest('Simplified Quality Complaint',   true,    false); }    // Because this already simplified but the test method should change it.
    private static testMethod void nonQualityComplaintValidComplicatedCountryTest()         { getCountrySpecificRecordTypeIdLocalTest(ECICCommonConstants.NON_QUALITY_COMPLAINT_IBERIA_RTNAME,          true,    false); }
    private static testMethod void inquiryValidComplicatedCountryTest()                     { getCountrySpecificRecordTypeIdLocalTest(ECICCommonConstants.INQUIRY_IBERIA_RTNAME,                        true,    false); }
    private static testMethod void thanksValidComplicatedCountryTest()                      { getCountrySpecificRecordTypeIdLocalTest(ECICCommonConstants.COMPLIMENT_IBERIA_RTNAME,                     true,    false); }
    private static testMethod void jokeValidComplicatedCountryTest()                        { getCountrySpecificRecordTypeIdLocalTest(ECICCommonConstants.USELESS_IBERIA_RTNAME,                        true,    false); }
    
    private static testMethod void qualityComplaintValidMissingCountryTest()                { getCountrySpecificRecordTypeIdLocalTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_RTNAME,              false,    false); }
   // private static testMethod void simplifiedQualityComplaintValidMissingCountryTest()      { getCountrySpecificRecordTypeIdLocalTest('Simplified Quality Complaint',   false,    false); }    // Because this already simplified but the test method shouldn't change it. 
    private static testMethod void nonQualityComplaintValidMissingCountryTest()             { getCountrySpecificRecordTypeIdLocalTest(ECICCommonConstants.NON_QUALITY_COMPLAINT_IBERIA_RTNAME,          false,    false); }
    private static testMethod void inquiryValidMissingCountryTest()                         { getCountrySpecificRecordTypeIdLocalTest(ECICCommonConstants.INQUIRY_IBERIA_RTNAME,                        false,    false); }
    private static testMethod void thanksValidMissingCountryTest()                          { getCountrySpecificRecordTypeIdLocalTest(ECICCommonConstants.COMPLIMENT_IBERIA_RTNAME,                     false,    false); }
    private static testMethod void jokeValidMissingCountryTest()                            { getCountrySpecificRecordTypeIdLocalTest(ECICCommonConstants.USELESS_IBERIA_RTNAME,                        false,    false); }
    /*#CICTemplateTest - End*/
    private static void isQualityComplaintRecordTypeNameTest(String targetRecordTypeName)
    {
        Boolean result = null;
        System.runAs(TEST_RUN_USER) 
        {
            Test.startTest();
            {
                result = ECICCaseQualityComplaintRecordTypeHelper.isQualityComplaint(targetRecordTypeName);
            }
            Test.stopTest();
        }
        /*#CICTemplateTest*/
        System.assertEquals((new Set<String>{ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_RTNAME, 'Simplified Quality Complaint'}).contains(targetRecordTypeName), result);
    }
    /*#CICTemplateTest - Start*/
    private static testMethod void qualityIsQualityComplaintRecordTypeNameTest()            { isQualityComplaintRecordTypeNameTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_RTNAME); }
    //private static testMethod void simplifiedQualityIsQualityComplaintRecordTypeNameTest()  { isQualityComplaintRecordTypeNameTest('Simplified Quality Complaint'); }
    private static testMethod void nonQualityIsQualityComplaintRecordTypeNameTest()         { isQualityComplaintRecordTypeNameTest(ECICCommonConstants.NON_QUALITY_COMPLAINT_IBERIA_RTNAME); }
    private static testMethod void inquiryIsQualityComplaintRecordTypeNameTest()            { isQualityComplaintRecordTypeNameTest(ECICCommonConstants.INQUIRY_IBERIA_RTNAME); }
    private static testMethod void thanksIsQualityComplaintRecordTypeNameTest()             { isQualityComplaintRecordTypeNameTest(ECICCommonConstants.COMPLIMENT_IBERIA_RTNAME); }
    private static testMethod void jokeIsQualityComplaintRecordTypeNameTest()               { isQualityComplaintRecordTypeNameTest(ECICCommonConstants.USELESS_IBERIA_RTNAME); }
    /*#CICTemplateTest - End*/
    private static void isQualityComplaintRecordTypeIDTest(String targetRecordTypeName)
    {
        Id dummyRecordTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get(targetRecordTypeName).RecordTypeId;
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER) 
        {
            Test.startTest();
            {
                result = ECICCaseQualityComplaintRecordTypeHelper.isQualityComplaint(dummyRecordTypeId);
            }
            Test.stopTest();
        }
        /*#CICTemplateTest*/
        System.assertEquals((new Set<String>{ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_RTNAME, 'Simplified Quality Complaint'}).contains(targetRecordTypeName), result);
    }
    /*#CICTemplateTest - Start*/
    private static testMethod void qualityIsQualityComplaintRecordTypeIDTest()              { isQualityComplaintRecordTypeIDTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_RTNAME); }
    //private static testMethod void simplifiedQualityIsQualityComplaintRecordTypeIDTest()    { isQualityComplaintRecordTypeIDTest('Simplified Quality Complaint'); }
    private static testMethod void nonQualityIsQualityComplaintRecordTypeIDTest()           { isQualityComplaintRecordTypeIDTest(ECICCommonConstants.NON_QUALITY_COMPLAINT_IBERIA_RTNAME); }
    private static testMethod void inquiryIsQualityComplaintRecordTypeIDTest()              { isQualityComplaintRecordTypeIDTest(ECICCommonConstants.INQUIRY_IBERIA_RTNAME); }
    private static testMethod void thanksIsQualityComplaintRecordTypeIDTest()               { isQualityComplaintRecordTypeIDTest(ECICCommonConstants.COMPLIMENT_IBERIA_RTNAME); }
    private static testMethod void jokeIsQualityComplaintRecordTypeIDTest()                 { isQualityComplaintRecordTypeIDTest(ECICCommonConstants.USELESS_IBERIA_RTNAME); }
    /*#CICTemplateTest - End*/
    private static void isQualityComplaintRecordTypeTest(String targetRecordTypeName)
    {
        RecordType dummyRecordType = (SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType)).get(Schema.SObjectType.Case.RecordTypeInfosByName.get(targetRecordTypeName).RecordTypeId);
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER) 
        {
            Test.startTest();
            {
                result = ECICCaseQualityComplaintRecordTypeHelper.isQualityComplaint(dummyRecordType);
            }
            Test.stopTest();
        }
        /*#CICTemplateTest*/
        System.assertEquals((new Set<String>{ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_RTNAME, 'Simplified Quality Complaint'}).contains(targetRecordTypeName), result);
    }
    /*#CICTemplateTest - Start*/
    private static testMethod void qualityIsQualityComplaintRecordTypeTest()            { isQualityComplaintRecordTypeTest(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_RTNAME); }
    //private static testMethod void simplifiedQualityIsQualityComplaintRecordTypeTest()  { isQualityComplaintRecordTypeTest('Simplified Quality Complaint'); }
    private static testMethod void nonQualityIsQualityComplaintRecordTypeTest()         { isQualityComplaintRecordTypeTest(ECICCommonConstants.NON_QUALITY_COMPLAINT_IBERIA_RTNAME); }
    private static testMethod void inquiryIsQualityComplaintRecordTypeTest()            { isQualityComplaintRecordTypeTest(ECICCommonConstants.INQUIRY_IBERIA_RTNAME); }
    private static testMethod void thanksIsQualityComplaintRecordTypeTest()             { isQualityComplaintRecordTypeTest(ECICCommonConstants.COMPLIMENT_IBERIA_RTNAME); }
    private static testMethod void jokeIsQualityComplaintRecordTypeTest()               { isQualityComplaintRecordTypeTest(ECICCommonConstants.USELESS_IBERIA_RTNAME); }
    /*#CICTemplateTest - End*/
}