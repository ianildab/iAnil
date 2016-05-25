@isTest //comment this whole class since we are not using the related strategy.
private class ECICCaseRecordTypeChangeStrategyTest {/*comment block 1 start
    private static final Map<String,User>     TEST_RUN_USER_MAP      = ECICRunUserTestHelper.createMap(new List<String>
                                                              {
                                                                  ECICCommonConstants.PROFILE_SYSTEM_ADMIN,                    // Only this one should be able to bipass
                                                                ECICCommonConstants.PROFILE_ECIC_INFOLINE_AGENT,
                                                                ECICCommonConstants.PROFILE_ECIC_ADMINISTRATOR,
                                                                ECICCommonConstants.PROFILE_ECIC_INFOLINE_SUPERVISOR,
                                                                ECICCommonConstants.PROFILE_ECIC_COCA_COLA_QUALITY,
                                                                ECICCommonConstants.PROFILE_ECIC_BOTTLER_QUALITY,
                                                                ECICCommonConstants.PROFILE_ECIC_EXTERNAL_RELATIONS,
                                                                ECICCommonConstants.PROFILE_ECIC_SUPPORT,
                                                                ECICCommonConstants.PROFILE_CRM_DATA_LOADER
                                                               });
    private static final User TEST_RUN_ADMIN                               = TEST_RUN_USER_MAP.get (ECICCommonConstants.PROFILE_SYSTEM_ADMIN);
    private static final Map<Id,RecordType> CASE_RECORD_TYPE_MAP           = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);
    private static ECICCaseRecordTypeChangeStrategy dummyStrategy          = new ECICCaseRecordTypeChangeStrategy();
    private static Integer countryCodeCount                                = 0;
    
    private static void getTypeInsertTest (String userProfile, String targetCaseRecordTypeName, Boolean isEmptyCaseType, Boolean isEmptyRecordType) {
        User testRunUser    = TEST_RUN_USER_MAP.get(userProfile);
        TEST_DummyCaseConfig caseConfig                 = new TEST_DummyCaseConfig();
                             caseConfig.type            = (isEmptyCaseType) ? null : targetCaseRecordTypeName;
                             caseConfig.recordTypeId    = (isEmptyRecordType) ? TEST_ConfigHelper.INTENTIONAL_NULL : Schema.Sobjecttype.Case.RecordTypeInfosByName.get(targetCaseRecordTypeName).RecordTypeId;
        
        Case dummyCase              = TEST_DummyGenericCaseFactory.create (caseConfig, TEST_DummyInsertModeEnum.NONE);
        
        if (targetCaseRecordTypeName == 'Quality Complaint') {
            Id qualityComplaintRecordTypeId     = Schema.SObjectType.Case.RecordTypeInfosByName.get(targetCaseRecordTypeName).RecordTypeId;
            TEST_DummyCountrySpecificSettingsFactory.create (new TEST_DummyCountrySpecificSettingsFactory.Config(dummyCase.Country_Code__c, qualityComplaintRecordTypeId), TEST_DummyInsertModeEnum.REAL); 
        }
        
        Boolean strategyResult = null;
        System.runAs(testRunUser) {
            Test.startTest();
            {
                strategyResult = dummyStrategy.OnBeforeInsert(new List<Case>{ dummyCase });
            }
            Test.stopTest();
        }
        
        System.assertEquals (true, strategyResult);
        if (!isEmptyCaseType) {
            assertRecordType (userProfile, dummyCase, targetCaseRecordTypeName);
        }
    }
    
    // Tests for non Admin profile
    private static testMethod void    profile_ecic_bottler_quality_ComplimentGettypeinserttest1()          {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_ECIC_BOTTLER_QUALITY,      'Compliment', true, true  );  }
    private static testMethod void    profile_ecic_bottler_quality_ComplimentGettypeinserttest2()          {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_ECIC_BOTTLER_QUALITY,      'Compliment', false, false );  }
    private static testMethod void    profile_ecic_bottler_quality_ComplimentGettypeinserttest3()          {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_ECIC_BOTTLER_QUALITY,      'Compliment', true, false  );  }
    private static testMethod void    profile_ecic_bottler_quality_ComplimentGettypeinserttest4()          {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_ECIC_BOTTLER_QUALITY,      'Compliment', false, true  );  }
    
    private static testMethod void    profile_ecic_bottler_quality_QualityComplaintGettypeinserttest1()    {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_ECIC_BOTTLER_QUALITY,      'Quality Complaint', true, true );  }
    private static testMethod void    profile_ecic_bottler_quality_QualityComplaintGettypeinserttest2()    {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_ECIC_BOTTLER_QUALITY,      'Quality Complaint', false, false );  }
    private static testMethod void    profile_ecic_bottler_quality_QualityComplaintGettypeinserttest3()    {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_ECIC_BOTTLER_QUALITY,      'Quality Complaint', true, false );  }
    private static testMethod void    profile_ecic_bottler_quality_QualityComplaintGettypeinserttest4()    {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_ECIC_BOTTLER_QUALITY,      'Quality Complaint', false, true );  }
    
    
    // Tests for Admin profile
    private static testMethod void    profile_system_admin_ComplimentGettypeinserttest1()                   {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_SYSTEM_ADMIN,      'Compliment', true, true  );  }
    private static testMethod void    profile_system_admin_ComplimentGettypeinserttest2()                   {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_SYSTEM_ADMIN,      'Compliment', false, false );  }
    private static testMethod void    profile_system_admin_ComplimentGettypeinserttest3()                   {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_SYSTEM_ADMIN,      'Compliment', true, false  );  }
    private static testMethod void    profile_system_admin_ComplimentGettypeinserttest4()                   {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_SYSTEM_ADMIN,      'Compliment', false, true  );  }
    
    private static testMethod void    profile_system_admin_QualityComplaintGettypeinserttest1()             {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_SYSTEM_ADMIN,      'Quality Complaint', true, true  );  }
    private static testMethod void    profile_system_admin_QualityComplaintGettypeinserttest2()             {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_SYSTEM_ADMIN,      'Quality Complaint', false, false );  }
    private static testMethod void    profile_system_admin_QualityComplaintGettypeinserttest3()             {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_SYSTEM_ADMIN,      'Quality Complaint', true, false  );  }
    private static testMethod void    profile_system_admin_QualityComplaintGettypeinserttest4()             {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_SYSTEM_ADMIN,      'Quality Complaint', false, true  );  }
                
    // ------------------------------------------------------------------------------------------------------
    
    private static void skipStrategyForAdminProfileTest (String caseTypeName, String caseRecordTypeName) {
        Id caseRecordTypeId = Schema.Sobjecttype.Case.RecordTypeInfosByName.get(caseRecordTypeName).RecordTypeId;
        TEST_DummyCaseConfig caseConfig                 = new TEST_DummyCaseConfig();
                             caseConfig.type            = caseTypeName;
                             caseConfig.recordTypeId    = caseRecordTypeId;
        
        Case dummyCase              = TEST_DummyGenericCaseFactory.create (caseConfig, TEST_DummyInsertModeEnum.NONE);
        
        Boolean strategyResult = null;
        System.runAs(TEST_RUN_ADMIN) {
            Test.startTest();
            {
                strategyResult = dummyStrategy.OnBeforeInsert(new List<Case>{ dummyCase });
            }
            Test.stopTest();
        }
        
        System.assertEquals (true, strategyResult);
        System.assertEquals (caseRecordTypeId, dummyCase.recordTypeId);
        System.assertEquals (CASE_RECORD_TYPE_MAP.get(dummyCase.recordTypeId).Name, dummyCase.Record_Type_Name__c);
    }
    
    private static testMethod void    skipStrategyForAdminProfileTypeEqualsRecordTypeTest()       {   skipStrategyForAdminProfileTest( 'Quality Complaint', 'Quality Complaint' );  }
    private static testMethod void    skipStrategyForAdminProfileTypeNotEqualsRecordTypeTest()    {   skipStrategyForAdminProfileTest( 'Quality Complaint', 'Inquiry' );  }
    comment block 1 end*/
    
    // ------------------------------------------------------------------------------------------------------
    
    /* OLD TESTS
    private static testMethod void    profile_system_adminInquiryGettypeinserttest()                            {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_SYSTEM_ADMIN,         'Inquiry'                 );  }
    private static testMethod void    profile_system_adminJokeUselessGettypeinserttest()                        {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_SYSTEM_ADMIN,         'Useless'          );  }
    private static testMethod void    profile_system_adminNonQualityComplaintGettypeinserttest()                {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_SYSTEM_ADMIN,         'Non-Quality Complaint'   );  }
    private static testMethod void    profile_system_adminQualityComplaintGettypeinserttest()                   {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_SYSTEM_ADMIN,         'Quality Complaint'       );  }
    private static testMethod void    profile_system_adminThanksGettypeinserttest()                             {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_SYSTEM_ADMIN,         'Compliment'                  );  }
    private static testMethod void    profile_system_adminSpamGettypeinserttest()                               {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_SYSTEM_ADMIN,         'Spam'                  );  }
    private static testMethod void    profile_system_adminComplaintGettypeinserttest()                          {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_SYSTEM_ADMIN,         'Simplified Quality Complaint' );  }
    
    private static testMethod void    profile_crm_data_loaderInquiryGettypeinserttest()                         {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_CRM_DATA_LOADER,      'Inquiry'                 );  }
    private static testMethod void    profile_crm_data_loaderJokeUselessGettypeinserttest()                     {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_CRM_DATA_LOADER,      'Useless'          );  }
    private static testMethod void    profile_crm_data_loaderNonQualityComplaintGettypeinserttest()             {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_CRM_DATA_LOADER,      'Non-Quality Complaint'   );  }
    private static testMethod void    profile_crm_data_loaderQualityComplaintGettypeinserttest()                {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_CRM_DATA_LOADER,      'Quality Complaint'       );  }
    private static testMethod void    profile_crm_data_loaderThanksGettypeinserttest()                          {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_CRM_DATA_LOADER,      'Compliment'                  );  }
    
    private static testMethod void    profile_ecic_administratorInquiryGettypeinserttest()                      {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_ECIC_ADMINISTRATOR,   'Inquiry'                 );  }
    private static testMethod void    profile_ecic_administratorJokeUselessGettypeinserttest()                  {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_ECIC_ADMINISTRATOR,   'Useless'          );  }
    private static testMethod void    profile_ecic_administratorNonQualityComplaintGettypeinserttest()          {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_ECIC_ADMINISTRATOR,   'Non-Quality Complaint'   );  }
    private static testMethod void    profile_ecic_administratorQualityComplaintGettypeinserttest()             {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_ECIC_ADMINISTRATOR,   'Quality Complaint'       );  }
    private static testMethod void    profile_ecic_administratorThanksGettypeinserttest()                       {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_ECIC_ADMINISTRATOR,   'Compliment'                  );  }
    
    private static testMethod void    profile_ecic_bottler_qualityInquiryGettypeinserttest()                    {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_ECIC_BOTTLER_QUALITY,      'Inquiry'               );  }
    private static testMethod void    profile_ecic_bottler_qualityJokeUselessGettypeinserttest()                {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_ECIC_BOTTLER_QUALITY,      'Useless'        );  }
    private static testMethod void    profile_ecic_bottler_qualityNonQualityComplaintGettypeinserttest()        {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_ECIC_BOTTLER_QUALITY,      'Non-Quality Complaint' );  }
    private static testMethod void    profile_ecic_bottler_qualityQualityComplaintGettypeinserttest()           {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_ECIC_BOTTLER_QUALITY,      'Quality Complaint'     );  }
    private static testMethod void    profile_ecic_bottler_qualityThanksGettypeinserttest()                     {   getTypeInsertTest   (    ECICCommonConstants.PROFILE_ECIC_BOTTLER_QUALITY,      'Compliment'                );  }
    
    private static testMethod void    profile_ecic_coca_cola_qualityInquiryGettypeinserttest()                  {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_COCA_COLA_QUALITY,    'Inquiry'               );  }
    private static testMethod void    profile_ecic_coca_cola_qualityJokeUselessGettypeinserttest()              {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_COCA_COLA_QUALITY,    'Useless'        );  }
    private static testMethod void    profile_ecic_coca_cola_qualityNonQualityComplaintGettypeinserttest()      {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_COCA_COLA_QUALITY,    'Non-Quality Complaint' );  }
    private static testMethod void    profile_ecic_coca_cola_qualityQualityComplaintGettypeinserttest()         {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_COCA_COLA_QUALITY,    'Quality Complaint'     );  }
    private static testMethod void    profile_ecic_coca_cola_qualityThanksGettypeinserttest()                   {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_COCA_COLA_QUALITY,    'Compliment'                );  }
    
    private static testMethod void    profile_ecic_external_relationsInquiryGettypeinserttest()                 {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_EXTERNAL_RELATIONS,   'Inquiry'               );  }
    private static testMethod void    profile_ecic_external_relationsJokeUselessGettypeinserttest()             {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_EXTERNAL_RELATIONS,   'Useless'        );  }
    private static testMethod void    profile_ecic_external_relationsNonQualityComplaintGettypeinserttest()     {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_EXTERNAL_RELATIONS,   'Non-Quality Complaint' );  }
    private static testMethod void    profile_ecic_external_relationsQualityComplaintGettypeinserttest()        {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_EXTERNAL_RELATIONS,   'Quality Complaint'     );  }
    private static testMethod void    profile_ecic_external_relationsThanksGettypeinserttest()                  {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_EXTERNAL_RELATIONS,   'Compliment'                );  }
    
    private static testMethod void    profile_ecic_infoline_agentInquiryGettypeinserttest()                     {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_INFOLINE_AGENT,       'Inquiry'               );  }
    private static testMethod void    profile_ecic_infoline_agentJokeUselessGettypeinserttest()                 {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_INFOLINE_AGENT,       'Useless'        );  }
    private static testMethod void    profile_ecic_infoline_agentNonQualityComplaintGettypeinserttest()         {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_INFOLINE_AGENT,       'Non-Quality Complaint' );  }
    private static testMethod void    profile_ecic_infoline_agentQualityComplaintGettypeinserttest()            {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_INFOLINE_AGENT,       'Quality Complaint'     );  }
    private static testMethod void    profile_ecic_infoline_agentThanksGettypeinserttest()                      {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_INFOLINE_AGENT,       'Compliment'                );  }
    
    private static testMethod void    profile_ecic_infoline_supervisorInquiryGettypeinserttest()                {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_INFOLINE_SUPERVISOR,  'Inquiry'               );  }
    private static testMethod void    profile_ecic_infoline_supervisorJokeUselessGettypeinserttest()            {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_INFOLINE_SUPERVISOR,  'Useless'        );  }
    private static testMethod void    profile_ecic_infoline_supervisorNonQualityComplaintGettypeinserttest()    {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_INFOLINE_SUPERVISOR,  'Non-Quality Complaint' );  }
    private static testMethod void    profile_ecic_infoline_supervisorQualityComplaintGettypeinserttest()       {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_INFOLINE_SUPERVISOR,  'Quality Complaint'     );  }
    private static testMethod void    profile_ecic_infoline_supervisorThanksGettypeinserttest()                 {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_INFOLINE_SUPERVISOR,  'Compliment'                );  }
    
    private static testMethod void    profile_ecic_supportInquiryGettypeinserttest()                            {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_SUPPORT,              'Inquiry'               );  }
    private static testMethod void    profile_ecic_supportJokeUselessGettypeinserttest()                        {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_SUPPORT,              'Useless'        );  }
    private static testMethod void    profile_ecic_supportNonQualityComplaintGettypeinserttest()                {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_SUPPORT,              'Non-Quality Complaint' );  }
    private static testMethod void    profile_ecic_supportQualityComplaintGettypeinserttest()                   {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_SUPPORT,              'Quality Complaint'     );  }
    private static testMethod void    profile_ecic_supportThanksGettypeinserttest()                             {   getTypeInsertTest    (    ECICCommonConstants.PROFILE_ECIC_SUPPORT,              'Compliment'                );  }
    
    // -------------------------------------------------------------------------------------------------------------------
    
    private static void sysomosHBrecordTypeSetTest(String targetTypeValue, Boolean isSimplifiedQualityComplaintCountryTest) {
        String dummyCountryCode             = '' + ++countryCodeCount;
        Id qualityComplaintRecordTypeId     = Schema.SObjectType.Case.RecordTypeInfosByName.get( ( (isSimplifiedQualityComplaintCountryTest) ? 'Simplified ' : '') + 'Quality Complaint' ).RecordTypeId;
        TEST_DummyCountrySpecificSettingsFactory.create (new TEST_DummyCountrySpecificSettingsFactory.Config(dummyCountryCode, qualityComplaintRecordTypeId), true); 
        
        TEST_DummyCaseConfig caseConfig                          = new TEST_DummyCaseConfig();
                                      caseConfig.recordTypeId    = Schema.Sobjecttype.Case.RecordTypeInfosByName.get((targetTypeValue != 'Inquiry' ? 'Inquiry' : 'Compliment')).RecordTypeId;
                                      caseConfig.type            = targetTypeValue;
                                      caseConfig.countryCode     = dummyCountryCode;
                                      caseConfig.sysomosHbWebUrl = 'http://sysomosHbWebUrl.example.com/dummy';
        Case dummyCase = TEST_DummyGenericCaseFactory.create (caseConfig, TEST_DummyInsertModeEnum.NONE);
        
        Boolean strategyResult = null;
        System.runAs(TEST_RUN_ADMIN) {
            Test.startTest();
            {
                strategyResult = dummyStrategy.OnBeforeInsert(new List<Case>{ dummyCase });
            }
            Test.stopTest();
        }
        
        System.assertEquals (true, strategyResult);
        assertRecordType (ECICCommonConstants.PROFILE_SYSTEM_ADMIN, dummyCase, targetTypeValue);
    }
    
    private static testMethod void inquirySimplifiedCountrySysomosHBrecordTypeSetTest()                         { sysomosHBrecordTypeSetTest ('Inquiry',                        true);  }
    private static testMethod void inquiryNonSimplifiedCountrySysomosHBrecordTypeSetTest()                      { sysomosHBrecordTypeSetTest ('Inquiry',                        false); }
    
    private static testMethod void jokeSimplifiedCountrySysomosHBrecordTypeSetTest()                            { sysomosHBrecordTypeSetTest ('Useless',                        true);  }
    private static testMethod void jokeNonSimplifiedCountrySysomosHBrecordTypeSetTest()                         { sysomosHBrecordTypeSetTest ('Useless',                        false); }
    
    private static testMethod void thanksSimplifiedCountrySysomosHBrecordTypeSetTest()                          { sysomosHBrecordTypeSetTest ('Compliment',                     true);  }
    private static testMethod void thanksNonSimplifiedCountrySysomosHBrecordTypeSetTest()                       { sysomosHBrecordTypeSetTest ('Compliment',                     false); }
    
    private static testMethod void qualityComplaintSimplifiedCountrySysomosHBrecordTypeSetTest()                { sysomosHBrecordTypeSetTest ('Quality Complaint',              true);  }
    private static testMethod void qualityComplaintNonSimplifiedCountrySysomosHBrecordTypeSetTest()             { sysomosHBrecordTypeSetTest ('Quality Complaint',              false); }
    
    private static testMethod void nonQualityComplaintSimplifiedCountrySysomosHBrecordTypeSetTest()             { sysomosHBrecordTypeSetTest ('Non-Quality Complaint',          true);  }
    private static testMethod void nonQualityComplaintNonSimplifiedCountrySysomosHBrecordTypeSetTest()          { sysomosHBrecordTypeSetTest ('Non-Quality Complaint',          false); }
    
    private static testMethod void spamSimplifiedCountrySysomosHBrecordTypeSetTest()                            { sysomosHBrecordTypeSetTest ('Spam',                           true);  }
    private static testMethod void spamNonSimplifiedCountrySysomosHBrecordTypeSetTest()                         { sysomosHBrecordTypeSetTest ('Spam',                           false); }
    
    private static testMethod void simplifiedQualityComplaintSimplifiedCountrySysomosHBrecordTypeSetTest()      { sysomosHBrecordTypeSetTest ('Simplified Quality Complaint',   true);  }
    private static testMethod void simplifiedQualityComplaintNonSimplifiedCountrySysomosHBrecordTypeSetTest()   { sysomosHBrecordTypeSetTest ('Simplified Quality Complaint',   false); }
    
    // -------------------------------------------------------------------------------------------------------------------
    
    private static void webRecordTypeSetTest(String targetTypeValue, Boolean isSimplifiedQualityComplaintCountryTest) {
        String dummyCountryCode             = '' + ++countryCodeCount;
        Id qualityComplaintRecordTypeId     = Schema.SObjectType.Case.RecordTypeInfosByName.get( ( (isSimplifiedQualityComplaintCountryTest) ? 'Simplified ' : '') + 'Quality Complaint' ).RecordTypeId;
        TEST_DummyCountrySpecificSettingsFactory.create (new TEST_DummyCountrySpecificSettingsFactory.Config(dummyCountryCode, qualityComplaintRecordTypeId), true);
        
        TEST_DummyCaseConfig caseConfig                         = new TEST_DummyCaseConfig();
                                      caseConfig.recordTypeId   = Schema.Sobjecttype.Case.RecordTypeInfosByName.get((targetTypeValue != 'Inquiry' ? 'Inquiry' : 'Compliment')).RecordTypeId;
                                      caseConfig.type           = targetTypeValue;
                                      caseConfig.countryCode    = dummyCountryCode; 
                                      caseConfig.origin         = 'Web';
        
        Case dummyCase = TEST_DummyGenericCaseFactory.create (caseConfig, TEST_DummyInsertModeEnum.NONE);
        
        Boolean strategyResult = null;
        System.runAs(TEST_RUN_ADMIN) {
            Test.startTest();
            {
                strategyResult = dummyStrategy.OnBeforeInsert(new List<Case>{ dummyCase });
            }
            Test.stopTest();
        }
        
        System.assertEquals (true, strategyResult);
        assertRecordType    (ECICCommonConstants.PROFILE_SYSTEM_ADMIN, dummyCase, targetTypeValue);
    }
    
    private static testMethod void inquirySimplifiedCountryWebRecordTypeSetTest()                   { webRecordTypeSetTest ('Inquiry',                  true);      }
    private static testMethod void inquiryNonSimplifiedCountryWebRecordTypeSetTest()                { webRecordTypeSetTest ('Inquiry',                  false);     }
    private static testMethod void jokeSimplifiedCountryWebRecordTypeSetTest()                      { webRecordTypeSetTest ('Useless',           true);      }
    private static testMethod void jokeNonSimplifiedCountryWebRecordTypeSetTest()                   { webRecordTypeSetTest ('Useless',           false);     }
    private static testMethod void thanksSimplifiedCountryWebRecordTypeSetTest()                    { webRecordTypeSetTest ('Compliment',                   true);      }
    private static testMethod void thanksNonSimplifiedCountryWebRecordTypeSetTest()                 { webRecordTypeSetTest ('Compliment',                   false);     }
    private static testMethod void qualityComplaintSimplifiedCountryWebRecordTypeSetTest()          { webRecordTypeSetTest ('Quality Complaint',        true);      }
    private static testMethod void qualityComplaintNonSimplifiedCountryWebRecordTypeSetTest()       { webRecordTypeSetTest ('Quality Complaint',        false);     }
    private static testMethod void nonQualityComplaintSimplifiedCountryWebRecordTypeSetTest()       { webRecordTypeSetTest ('Non-Quality Complaint',    true);      }
    private static testMethod void nonQualityComplaintNonSimplifiedCountryWebRecordTypeSetTest()    { webRecordTypeSetTest ('Non-Quality Complaint',    false);     }
    */
    // -------------------------------------------------------------------------------------------------------------------
    /* comment block 2 start
    private static void getTypeUpdateTest (String targetCaseRecordTypeName, Boolean hadDifferentOldValue) {
        String startCaseRecordTypeName = (hadDifferentOldValue)
                                            ? ( (targetCaseRecordTypeName == 'Inquiry') ? 'Compliment' : 'Inquiry' )
                                            : targetCaseRecordTypeName;
        
        getTypeUpdateTest (targetCaseRecordTypeName, startCaseRecordTypeName);
    }
    
    private static void getTypeUpdateTest (String targetCaseRecordTypeName, String startCaseRecordTypeName) {
        Boolean hadDifferentOldValue    = (targetCaseRecordTypeName !=  startCaseRecordTypeName);
        Boolean needsClear              = (
                                               (startCaseRecordTypeName == 'Quality Complaint')
                                            && (targetCaseRecordTypeName != 'Quality Complaint')
                                         );
        
        TEST_DummyCaseConfig caseConfig                 = new TEST_DummyCaseConfig();
                             caseConfig.recordTypeId    =  Schema.Sobjecttype.Case.RecordTypeInfosByName.get(startCaseRecordTypeName).RecordTypeId;
        
        Case dummyOldCase = TEST_DummyGenericCaseFactory.create (caseConfig, TEST_DummyInsertModeEnum.MOCK);
        System.runAs(TEST_RUN_ADMIN) { dummyStrategy.OnBeforeInsert(new List<Case>{ dummyOldCase }); }
        assertRecordType (dummyOldCase, startCaseRecordTypeName);
        
        Case dummyNewCase = dummyOldCase.clone(true, true);
        dummyNewCase.recordTypeId   = Schema.Sobjecttype.Case.RecordTypeInfosByName.get(targetCaseRecordTypeName).RecordTypeId;
        
        Boolean strategyResult = null;
        System.runAs(TEST_RUN_ADMIN) {
            Test.startTest();
            {
                strategyResult = dummyStrategy.OnBeforeUpdate(new Map<ID, Case>{ dummyOldCase.Id => dummyOldCase },
                                                              new Map<ID, Case>{ dummyNewCase.Id => dummyNewCase });
            }
            Test.stopTest();
        }
        
        System.assertEquals (true, strategyResult);
        assertRecordType (dummyNewCase, targetCaseRecordTypeName);
        if (needsClear) { assertCaseClear  (dummyNewCase, true); }
    }
    
    private static testMethod void inquiryChangeGetTypeUpdateTest()                 { getTypeUpdateTest ('Inquiry',                     true);      }
    private static testMethod void inquiryNoChangeGetTypeUpdateTest()               { getTypeUpdateTest ('Inquiry',                     false);     }
    private static testMethod void qualityToInquiryTypeChangeTest()                 { qualityToNonQualityTypeChangeTest('Inquiry');                 }
    
    private static testMethod void jokeChangeGetTypeUpdateTest()                    { getTypeUpdateTest ('Useless',              true);      }
    private static testMethod void jokeNoChangeGetTypeUpdateTest()                  { getTypeUpdateTest ('Useless',              false);     }
    private static testMethod void qualityToJokeTypeChangeTest()                    { qualityToNonQualityTypeChangeTest('Useless');          }
    
    private static testMethod void nonQualityComplaintChangeGetTypeUpdateTest()     { getTypeUpdateTest ('Non-Quality Complaint',       true);      }
    private static testMethod void nonQualityComplaintNoChangeGetTypeUpdateTest()   { getTypeUpdateTest ('Non-Quality Complaint',       false);     }
    private static testMethod void qualityToNonQualityTypeChangeTest()              { qualityToNonQualityTypeChangeTest('Non-Quality Complaint');   }
    
    private static testMethod void qualityComplaintChangeGetTypeUpdateTest()        { getTypeUpdateTest ('Quality Complaint',           true);      }
    private static testMethod void qualityComplaintNoChangeGetTypeUpdateTest()      { getTypeUpdateTest ('Quality Complaint',           false);     }
    
    private static testMethod void thanksChangeGetTypeUpdateTest()                  { getTypeUpdateTest ('Compliment',                      true);      }
    private static testMethod void thanksNoChangeGetTypeUpdateTest()                { getTypeUpdateTest ('Compliment',                      false);     }
    private static testMethod void qualityToThanksTypeChangeTest()                  { qualityToNonQualityTypeChangeTest('Compliment');                  }
    
    private static testMethod void clearCaseQualityFieldsTest() {
        Case dummyCase = TEST_DummyFastQualityComplaintCaseFactry.create();
        
        Boolean strategyResult = null;
        System.runAs(TEST_RUN_ADMIN) {
            Test.startTest();
            {
                dummyStrategy.clearCaseQualityFields(dummyCase);
            }
            Test.stopTest();
        }
        
        assertCaseClear (dummyCase, false);
    }
    
    private static void qualityToNonQualityTypeChangeTest(String targetCaseRecordTypeName) {
        getTypeUpdateTest (targetCaseRecordTypeName, 'Quality Complaint');
    }
    
    private static testMethod void addCaseErrorTest() {
        Case dummyCase = TEST_DummyFastQualityComplaintCaseFactry.create();
        dummyCase.recordTypeId = null;
        
        Boolean strategyResult = null;
        System.runAs(TEST_RUN_ADMIN) {
            Test.startTest();
            {
                strategyResult = dummyStrategy.OnBeforeInsert(new List<Case>{ dummyCase });
            }
            Test.stopTest();
        }
        
        System.assertEquals (true, strategyResult);
        System.assert(getCaseErrorMessage(dummyCase) != null);
    }
    
    private static String getCaseErrorMessage(Case errCase) {
        Database.SaveResult sr = Database.insert(errCase, false);
        String errMessage = null;
        if (!sr.isSuccess()) {
            for (Database.Error err : sr.getErrors()) {
                errMessage += err.getMessage();
            }
        }
        
        return errMessage;
    }
    
    // -------------------------------------------------------------------------------------------------------------------
    
    private static void assertRecordType (String userProfile, Case resultCase, String testTypeName) {
        Id expectedRecordTypeId = (
                  (userProfile != ECICCommonConstants.PROFILE_SYSTEM_ADMIN)
                  && (ECICCaseQualityComplaintRecordTypeHelper.isQualityComplaint(testTypeName))
              ) 
                  // This is not the best test because we are using the same method here to check as during the actual test phase,
                  // so if one is wrong, both are likely to be wrong (although something else could potentially go wrong in-between);
                  // (So we should be sure to test this method thoroughly so we know it can be trusted.)
              ? (Id) ECICCaseQualityComplaintRecordTypeHelper.getCountrySpecificRecordTypeId (resultCase.country_code__c)
              : Schema.SObjectType.Case.RecordTypeInfosByName.get(testTypeName).RecordTypeId;
          
          System.assertEquals (expectedRecordTypeId, resultCase.recordTypeId);
          System.assertEquals (CASE_RECORD_TYPE_MAP.get(expectedRecordTypeId).name, resultCase.Record_Type_Name__c);
    }
    
    private static void assertRecordType (Case dummyCase, String typeName) { assertRecordType (ECICCommonConstants.PROFILE_SYSTEM_ADMIN,  dummyCase, typeName); }
    
    private static void assertCaseClear (Case dummyCase, Boolean isContextTest) {
        assertProductInformationFieldsClear (dummyCase, isContextTest);                  //clear Product Information
        assertCaseConsumerSampleInformationFieldsClear (dummyCase, isContextTest);     //clear Consumer Sample Information
        assertCaseECIC2237FieldsClear (dummyCase, isContextTest);                       //ECIC-2237--26/06/2012
        assertCaseQualityInformationFieldsClear (dummyCase, isContextTest);              //clear Quality Information
        assertCaseQualityReportFieldsClear (dummyCase, isContextTest);                  //clear Quality Report
        assertCaseConsumerSampleAnalysisFieldsClear (dummyCase, isContextTest);         //clear Consumer Sample Analysis
        assertCaseHiddenFieldsClear (dummyCase, isContextTest);                         //clear hidden fields
    }
    
    private static void assertProductInformationFieldsClear (Case dummyCase, Boolean isContextTest) {
        System.assertEquals (null, dummyCase.Production_date__c );
        if (!isContextTest) {
            System.assertEquals (null, dummyCase.bbe_date__c );
            System.assertEquals (null, dummyCase.production_code__c );
            System.assertEquals (null, dummyCase.production_line__c );
            System.assertEquals (null, dummyCase.plant__c );
            System.assertEquals (null, dummyCase.bottler__c );
        }
    }
    
    private static void assertCaseConsumerSampleInformationFieldsClear (Case dummyCase, Boolean isContextTest) {
        System.assertEquals (false, dummyCase.Content_Available__c );
        System.assertEquals (false, dummyCase.Sample_Collected__c );
        System.assertEquals (null,  dummyCase.Sample_Collector__c );
        System.assertEquals (false, dummyCase.Package_Available__c );
        System.assertEquals (false, dummyCase.Package_Closed__c );
        System.assertEquals (false, dummyCase.Damage__c );
        System.assertEquals (null,  dummyCase.Date_of_Purchase__c );
        System.assertEquals (null,  dummyCase.Place_of_Purchase__c );
        System.assertEquals (null,  dummyCase.Sample_Comments__c );
        System.assertEquals (null,  dummyCase.No_of_Packages__c );
        System.assertEquals (null,  dummyCase.Sample_Collection_Date__c );
        System.assertEquals (null,  dummyCase.Sample_Arrival_Date__c );
        if (!isContextTest) {
            System.assertEquals (null, dummyCase.Region_of_Purchase__c );
            System.assertEquals (null, dummyCase.Point_Of_Sale__c );
            System.assertEquals (null, dummyCase.PoS_Key_Account__c );
        }
    }
    
    private static void assertCaseECIC2237FieldsClear (Case dummyCase, Boolean isContextTest) {
        System.assertEquals (null, dummyCase.Bottler_External_Relations__c  );
        System.assertEquals (null, dummyCase.Bottler_Quality_Owner__c );
        System.assertEquals (null, dummyCase.Distributor_Quality_Manager__c );
        System.assertEquals (null, dummyCase.Distributor_Quality__c );
        System.assertEquals (null, dummyCase.Distributor_External_Relations__c );
        System.assertEquals (null, dummyCase.bottler_name__c );
        System.assertEquals (null, dummyCase.region_bottler_name__c );
    }
    
    private static void assertCaseQualityInformationFieldsClear (Case dummyCase, Boolean isContextTest) {
        System.assertEquals (null,  dummyCase.Quality_Case_Owner__c );
        System.assertEquals (null,  dummyCase.Bottler_Quality_Manager__c );
        System.assertEquals (null,  dummyCase.Closure_Supplier__c );
        System.assertEquals (null,  dummyCase.Trend__c );
        System.assertEquals (false, dummyCase.Communicate_to_Infoline__c );
        System.assertEquals (null,  dummyCase.Technical_Notes__c );
        System.assertEquals (null,  dummyCase.Closure_Batch__c );
        if (!isContextTest) {
            System.assertEquals (null,  dummyCase.Package_Batch__c );
            System.assertEquals (null,  dummyCase.Quality_Status__c );
            System.assertEquals (false, dummyCase.No_Quality_Status_Change__c );  
            System.assertEquals (null,  dummyCase.Package_Supplier__c );
        }
     }
    
    private static void assertCaseQualityReportFieldsClear (Case dummyCase, Boolean isContextTest) {
        System.assertEquals (null,  dummyCase.Date_of_the_report__c );
        System.assertEquals (null,  dummyCase.Comments_of_analyst_lab_manager__c );
        System.assertEquals (null,  dummyCase.Quality_Technical_Reason__c );
        System.assertEquals (null,  dummyCase.Root_Cause_Identification__c );
        System.assertEquals (null,  dummyCase.Cause_of_Complaint__c );
        System.assertEquals (false, dummyCase.Food_Safety_toxicological__c );
        System.assertEquals (null,  dummyCase.Food_Safety_Toxicological_txt__c );
        System.assertEquals (null,  dummyCase.Comments_of_analyst_labmgr_full__c );
        if (!isContextTest) { System.assertEquals (null, dummyCase.Process_Type__c ); }
    }
    
    private static void assertCaseConsumerSampleAnalysisFieldsClear (Case dummyCase, Boolean isContextTest) {
        System.assertEquals (null,  dummyCase.Laboratory_of_Analysis__c );
        System.assertEquals (null,  dummyCase.Lab_Reception_Date__c );
        System.assertEquals (null,  dummyCase.No_of_Open_Samples__c );
        System.assertEquals (null,  dummyCase.No_of_Closed_Samples__c );
        System.assertEquals (false, dummyCase.Retention_Sample__c );
        System.assertEquals (null,  dummyCase.Retention_Sample_Txt__c );
        System.assertEquals (null,  dummyCase.Shipment_Time__c );
        System.assertEquals (false, dummyCase.Appearance_of_Package__c );
        System.assertEquals (null,  dummyCase.Appearance_of_Package_Txt__c );
        System.assertEquals (false, dummyCase.Appearance_of_Product__c );
        System.assertEquals (null,  dummyCase.Appearance_of_Product_Txt__c );
        System.assertEquals (false, dummyCase.Sensory_Evaluation__c );
        System.assertEquals (null,  dummyCase.Sensory_Evaluation_Txt__c );
        System.assertEquals (false, dummyCase.Chemical_Analysis__c );
        System.assertEquals (null,  dummyCase.Chemical_Analysis_Txt__c );
        System.assertEquals (false, dummyCase.Physical_Analysis__c );
        System.assertEquals (null,  dummyCase.Physical_Analysis_Txt__c );
        System.assertEquals (false, dummyCase.Microbiological_Analysis__c );
        System.assertEquals (null,  dummyCase.Microbiological_Analysis_Txt__c );
        System.assertEquals (false, dummyCase.Health_Risk__c );
        System.assertEquals (null,  dummyCase.Health_Risk_Txt__c );
    }
    
    private static void assertCaseHiddenFieldsClear (Case dummyCase, Boolean isContextTest) {
        System.assertEquals (null, dummyCase.Action_Plan__c );
        System.assertEquals (null, dummyCase.Quality_Case_Owner__c );
        System.assertEquals (null, dummyCase.Quality_Admin_Assistant__c );
        System.assertEquals (null, dummyCase.Consumer_Complaint_Manager__c );
        System.assertEquals (null, dummyCase.trend_mark__c );
    }
    comment block 2 end*/
}