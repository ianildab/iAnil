@isTest
public class ECICClosedTrendsTrackerTestHelper  
{
    // # Ecic Template Test     
    public static final Id      QUALITY_COMPLAINT_CASE_RECORDTYPE_ID = TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME );
    public static final Id      INQUIRY_CASE_RECORDTYPE_ID           = TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(ECICCommonConstants.INQUIRY_IBERIA_DEVNAME );

    public static final String  DUMMY_COUNTRY_CODE                   = ECICCommonConstants.COUNTRY_CODE_DEFAULT;
    public static final String  DUMMY_ADDITIONAL_TO                  = 'additionalTo@dummy.example.com';
    public static final String  DUMMY_CASE_REASON                    = ECICCommonConstants.QUALITY_COMPLAINT_REASON_PACKAGE;
    public static final String  DUMMY_PLANT_ID                       = TEST_DummyPlantFactory.getDefaultPlantId(TEST_DummyInsertModeEnum.REAL);
    public static final String  DUMMY_PRODUCT_TYPE                   = ECICCommonConstants.PRODUCT_TYPE_DEFAULT;
    public static final String  DUMMY_PRODUCT_DESCRIPTION            = ECICCommonConstants.PRODUCT_DESCRIPTION_DEFAULT;
    public static final Integer DUMMY_PERIOD                         = TEST_DummyClosedTrendFactory.DEFAULT_PERIOD;
    public static final Integer DUMMY_THRESHOLD                      = TEST_DummyClosedTrendFactory.DEFAULT_THRESHOLD;
    
    public static List<TEST_DummyCaseConfig> createCaseConfigList(String reason, Id plantId)
    {
        List<TEST_DummyCaseConfig> dummyCaseConfigList = new List<TEST_DummyCaseConfig>();
                                     dummyCaseConfigList.add(createCaseConfig(reason, plantId, ECICCommonConstants.STATUS_NEW,       false));
                                     dummyCaseConfigList.add(createCaseConfig(reason, plantId, ECICCommonConstants.STATUS_CANCELLED, false));
                                     dummyCaseConfigList.add(createCaseConfig(reason, plantId, ECICCommonConstants.STATUS_OPEN,      false));
                                     dummyCaseConfigList.add(createCaseConfig(reason, plantId, ECICCommonConstants.STATUS_NEW,       true));
                                     dummyCaseConfigList.add(createCaseConfig(reason, plantId, ECICCommonConstants.STATUS_CANCELLED, true));
                                     dummyCaseConfigList.add(createCaseConfig(reason, plantId, ECICCommonConstants.STATUS_OPEN,      true));
                              return dummyCaseConfigList;
    }
    
    public static TEST_DummyCaseConfig createCaseConfig(String reason, Id plantId, String status, Boolean isQualityCase)
    {
        TEST_DummyCaseConfig dummyCaseConfig = new TEST_DummyCaseConfig();
                               dummyCaseConfig.recordTypeId = (isQualityCase) ? QUALITY_COMPLAINT_CASE_RECORDTYPE_ID : INQUIRY_CASE_RECORDTYPE_ID;
                               dummyCaseConfig.reason       = reason;
                               dummyCaseConfig.plantId      = plantId;
                               dummyCaseConfig.status       = status;
                               if(isQualityCase){
                                    dummyCaseConfig.productionCode = 'mv1111'; //#CICTemplateTest
                                    dummyCaseConfig.productId = TEST_DummyProductFactory.getDefaultProductId(TEST_DummyInsertModeEnum.REAL);//#CICTemplateTest
                                    dummyCaseConfig.productionLineId = TEST_DummyProductionLineFactory.create(TEST_DummyInsertModeEnum.REAL).id;//#CICTemplateTest
                                    dummyCaseConfig.bottlerAccountId = TEST_DummyAccountFactory.getDefaultBottlerAccountId(TEST_DummyInsertModeEnum.REAL);//#CICTemplateTest
                                    dummyCaseConfig.regionOfPurchaseId = TEST_DummyRegionFactory.getDefaultRegionId(TEST_DummyInsertModeEnum.REAL);//#CICTemplateTest
                               }
                        return dummyCaseConfig;
    }

    public static Case createCase(String countryCode, Date createdDate)
    {
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.countryCode  = countryCode;
                             caseConfig.plantId     = DUMMY_PLANT_ID;
                             caseConfig.reason      = DUMMY_CASE_REASON;
                             caseConfig.createdDate = createdDate; 
        Case dummyCase = TEST_DummyInquiryCaseFactory.create (caseConfig, TEST_DummyInsertModeEnum.NONE);
        
            TEST_MockHelper.setMockString(dummyCase, 'product.type',        DUMMY_PRODUCT_TYPE);                             
            TEST_MockHelper.setMockString(dummyCase, 'product.description', DUMMY_PRODUCT_DESCRIPTION);
        
        return dummyCase;
        
    }

    public static Case createCase() { return createCase(DUMMY_COUNTRY_CODE, null); }

    public static Case createCase(Boolean isDataMatched, Boolean isBetween, Datetime toDatetime, Integer period)
    {
        Integer caseCreatedDateModifier = (!isBetween) ? period + 1 : -1;
        return createCase(
                           ((isDataMatched) ? ECICClosedTrendsTrackerTestHelper.DUMMY_COUNTRY_CODE : 'O1'),
                           convertToDate (toDatetime.addDays(caseCreatedDateModifier))
                         );
    }

    public static Map<Id, Case> createCaseMap( 
                                                     String firstClosedTrendReason,  String firstClosedTrendPlantId,
                                                     String secondClosedTrendReason, String secondClosedTrendPlantId
                                                    )
    {
        String thirdClosedTrendReason   = firstClosedTrendReason;
        String thirdClosedTrendPlantId  = secondClosedTrendPlantId;

        String fourthClosedTrendReason  = secondClosedTrendReason;
        String fourthClosedTrendPlantId = firstClosedTrendPlantId;



        List<TEST_DummyCaseConfig> dummyCaseConfigList = new List<TEST_DummyCaseConfig>();
                                     dummyCaseConfigList.addAll(createCaseConfigList(firstClosedTrendReason,  firstClosedTrendPlantId));
                                     dummyCaseConfigList.addAll(createCaseConfigList(secondClosedTrendReason, secondClosedTrendPlantId));
                                     dummyCaseConfigList.addAll(createCaseConfigList(thirdClosedTrendReason,  thirdClosedTrendPlantId));
                                     dummyCaseConfigList.addAll(createCaseConfigList(fourthClosedTrendReason, fourthClosedTrendPlantId));

        // Creates 24 (4 x 6) Cases                                    
        return new Map<Id, Case>(TEST_DummyGenericCaseFactory.createList(dummyCaseConfigList, TEST_DummyInsertModeEnum.REAL));    
    }



  // ------------------------------------------------------------------------------------------------
  
    public static Closed_Trend__c createClosedTrend(Boolean isDefinition, Boolean isActive, Boolean hasReason, Boolean hasPlantId, Boolean hasProductType, Boolean hasProductDescription, TEST_DummyInsertModeEnum insertMode)
    {
        TEST_DummyClosedTrendFactory.Config config = new TEST_DummyClosedTrendFactory.Config();
                                            config.recordTypeId       = (isDefinition)            ? ECICClosedTrendHelper.CLOSED_TREND_DEFINITION_RT_ID : ECICClosedTrendHelper.CLOSED_TREND_COLLECTION_RT_ID;
                                            config.caseReason         = ((hasReason)              ? DUMMY_CASE_REASON                                   : TEST_ConfigHelper.INTENTIONAL_NULL);
                                            config.plantId            = ((hasPlantId)             ? DUMMY_PLANT_ID                                      : TEST_ConfigHelper.INTENTIONAL_NULL);
                                            config.productType        = ((hasProductType)         ? DUMMY_PRODUCT_TYPE                                  : TEST_ConfigHelper.INTENTIONAL_NULL);
                                            config.productDescription = ((hasProductDescription)  ? DUMMY_PRODUCT_DESCRIPTION                           : TEST_ConfigHelper.INTENTIONAL_NULL);

                                            config.countryCode        = DUMMY_COUNTRY_CODE;
                                            config.additionalTo       = DUMMY_ADDITIONAL_TO;
                                            config.period             = DUMMY_PERIOD;
                                            config.threshold          = DUMMY_THRESHOLD;

                                            config.isActive           = (isActive);
        return TEST_DummyClosedTrendFactory.create(config, insertMode);
    }
   
    public static Closed_Trend__c createClosedTrend(Integer period, TEST_DummyInsertModeEnum insertMode)
    {
        TEST_DummyClosedTrendFactory.Config closedTrendConfig = new TEST_DummyClosedTrendFactory.Config();
                                            closedTrendConfig.countryCodeString = ECICClosedTrendsTrackerTestHelper.DUMMY_COUNTRY_CODE + ';';
                                            closedTrendConfig.plantId     = ECICClosedTrendsTrackerTestHelper.DUMMY_PLANT_ID;
                                            closedTrendConfig.caseReason         = ECICClosedTrendsTrackerTestHelper.DUMMY_CASE_REASON;
                                            closedTrendConfig.productType        = ECICClosedTrendsTrackerTestHelper.DUMMY_PRODUCT_TYPE;
                                            closedTrendConfig.productDescription = ECICClosedTrendsTrackerTestHelper.DUMMY_PRODUCT_DESCRIPTION;
                                            closedTrendConfig.period      = period;
        return TEST_DummyClosedTrendFactory.create(closedTrendConfig, insertMode);
    }
   
    public static Closed_Trend__c createClosedTrend(Integer period) { return createClosedTrend(period, TEST_DummyInsertModeEnum.NONE); }

    public static Closed_Trend__c createClosedTrend(Boolean isDefinition, Boolean isActive, TEST_DummyInsertModeEnum insertMode)
    {
        return createClosedTrend (isDefinition, isActive, true, true, true, true, insertMode);
    }

    public static Map<String, Closed_Trend__c> createClosedTrendPairMap()
    {
        Closed_Trend__c dummyDefinitionClosedTrend = TEST_DummyClosedTrendFactory.create(ECICClosedTrendHelper.CLOSED_TREND_DEFINITION_RT_ID, TEST_DummyInsertModeEnum.NONE);
        
        Closed_Trend__c dummyCollectionClosedTrend = dummyDefinitionClosedTrend.clone(false);
                        dummyCollectionClosedTrend.RecordTypeId = ECICClosedTrendHelper.CLOSED_TREND_COLLECTION_RT_ID;
        
        insert new List<Closed_Trend__c>{ dummyDefinitionClosedTrend, dummyCollectionClosedTrend };
        
        return new Map<String, Closed_Trend__c>
        {
            'definition' => dummyDefinitionClosedTrend,
            'collection' => dummyCollectionClosedTrend
        };
    }

    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    public static Map<String, SObject> createClosedTrendCasePair(Datetime dummyToDateTime, Boolean isClosedTrendDefinition)
    {
        String   dummyCaseReason = ECICClosedTrendsTrackerTestHelper.DUMMY_CASE_REASON;
        Id       dummyPlantId    = ECICClosedTrendsTrackerTestHelper.DUMMY_PLANT_ID;

        TEST_DummyClosedTrendFactory.Config config = new TEST_DummyClosedTrendFactory.Config();
                                            config.recordTypeId       = (isClosedTrendDefinition)       ? ECICClosedTrendHelper.CLOSED_TREND_DEFINITION_RT_ID : ECICClosedTrendHelper.CLOSED_TREND_COLLECTION_RT_ID;
                                            config.caseReason         = dummyCaseReason;
                                            config.plantId            = dummyPlantId;
                                            config.productType        = TEST_ConfigHelper.INTENTIONAL_NULL;
                                            config.productDescription = TEST_ConfigHelper.INTENTIONAL_NULL;

                                            config.countryCode        = ECICClosedTrendsTrackerTestHelper.DUMMY_COUNTRY_CODE;
                                            config.additionalTo       = ECICClosedTrendsTrackerTestHelper.DUMMY_ADDITIONAL_TO;
                                            config.period             = 7;
                                            config.threshold          = 1;

                                            config.isActive           = true;
        Closed_Trend__c dummyDefinitionClosedTrend = TEST_DummyClosedTrendFactory.create(config, TEST_DummyInsertModeEnum.REAL);

        TEST_DummyCaseConfig caseConfig = ECICClosedTrendsTrackerTestHelper.createCaseConfig(dummyCaseReason, dummyPlantId, ECICCommonConstants.STATUS_OPEN, true);
                             caseConfig.createdDate = ECICClosedTrendsTrackerTestHelper.convertToDate (dummyToDateTime.addDays(-2));
        Case dummyCase = TEST_DummyGenericCaseFactory.create(caseConfig, TEST_DummyInsertModeEnum.REAL);    
        
        return new Map<String, SObject>
                {  
                    'closedTrend' => dummyDefinitionClosedTrend,
                    'case'       => dummyCase
                };
    } 

  // ------------------------------------------------------------------------------------------------

    public static void assertClosedTrendClone(Closed_Trend__c dummyOriginalClosedTrend, Closed_Trend__c resultClosedTrend, String dummyAnalyzedPeriod)
    {
        System.assertEquals (ECICClosedTrendHelper.CLOSED_TREND_COLLECTION_RT_ID,           resultClosedTrend.RecordTypeId);
        System.assertEquals (dummyOriginalClosedTrend.country_code__c,                      resultClosedTrend.country_code__c);
        System.assertEquals (dummyOriginalClosedTrend.subject__c,                           resultClosedTrend.subject__c);
        System.assertEquals (dummyOriginalClosedTrend.additional_to__c,                     resultClosedTrend.additional_to__c);
        System.assertEquals (dummyAnalyzedPeriod,                                           resultClosedTrend.analyzed_period__c);
        System.assertEquals (dummyOriginalClosedTrend.name + '   ' + dummyAnalyzedPeriod,   resultClosedTrend.name);
    }

    public static void assertClosedTrendClone(Closed_Trend__c dummyOriginalClosedTrend, Closed_Trend__c resultClosedTrend, Integer period)
    {
        Date            toDate              = convertToDate(System.today());
        String          minDateString       = String.valueOf(toDate.addDays(-period));
        String          maxDateString       = String.valueOf(toDate.addDays(-1));
        String          dummyAnalyzedPeriod = minDateString + '  -  ' + maxDateString;
        assertClosedTrendClone(dummyOriginalClosedTrend, resultClosedTrend, dummyAnalyzedPeriod); 
    }

    public static void assertCollectionClosedTrendByDefinitionClosedTrendIdMap (Closed_Trend__c dummyOriginalClosedTrend, Integer period, Map<Id, Closed_Trend__c> dummyNewCollectionClosedTrendByParentDefinitationClosedTrendIdMap)
    {
        System.assert (dummyNewCollectionClosedTrendByParentDefinitationClosedTrendIdMap.containsKey(dummyOriginalClosedTrend.id));

        Closed_Trend__c resultClosedTrend   = dummyNewCollectionClosedTrendByParentDefinitationClosedTrendIdMap.get(dummyOriginalClosedTrend.id);
        assertClosedTrendClone(dummyOriginalClosedTrend, resultClosedTrend, period); 
    }

    public static void assertCondition (List<String> resultWhereConditionList, Boolean conditionExpected, String closedTrendFieldName, String targetValue)
    {
        String expectedWhereCondition = buildWhereCondition (closedTrendFieldName, targetValue);
        
        Boolean hasCondition = false;
        for (String resultWhereCondition : resultWhereConditionList) 
        { 
            hasCondition |= (resultWhereCondition == expectedWhereCondition);
            if (hasCondition) { break; } 
        }
        
        System.assertEquals (conditionExpected, hasCondition);
    }

  // ------------------------------------------------------------------------------------------------

    public static String buildWhereCondition (String closedTrendFieldName, String targetValue)
    {
        return ECICClosedTrendHelper.CASE_FIELD_BY_CLOSED_TREND_FIELDS_MAP.get(closedTrendFieldName) + ' = \'' + targetValue + '\'';
    }

    public static String buildCriteria (String reason, String plantId) 
    { 
        String reasonWhereCondition  = buildWhereCondition ('case_reason__c', reason);
        String plantIdWhereCondition = buildWhereCondition ('plant__c',       plantId);
        
        return ('(' + reasonWhereCondition + ' AND ' + plantIdWhereCondition + ')'); 
    }
    
  // ------------------------------------------------------------------------------------------------

    public static Integer totalTrue (List<Boolean> valueList)
    {
        Integer sum = 0;
        for (Boolean value : valueList) { sum += convertToBinary(value); }
        return sum;
    }

    public static Integer convertToBinary (Boolean value) { return (value) ? 1 : 0; }
    
    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    public static Date convertToDate (Datetime originalDatetime) 
    {
        return Date.newInstance(originalDatetime.year(), originalDatetime.month(), originalDatetime.day());
    }
  
  
}