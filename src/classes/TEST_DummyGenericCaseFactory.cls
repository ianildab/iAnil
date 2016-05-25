@isTest 
public class TEST_DummyGenericCaseFactory                   // SFDC does not allow/support abstract/virtual test classes.  :-(
{
    public static final Map<String, Id>    CASE_RECORD_TYPE_IDS_BY_NAME_MAP = SEPRecordTypesCache.getRecordTypeIdsByDeveloperNameMap(Case.SObjectType); 

    // Default related object records for generic cases (static, final values) -------------------------------------------------------------------------------------
    public static final String                       DEFAULT_COUNTRY_CODE             = ECICCommonConstants.COUNTRY_CODE_DEFAULT; // Arbitrary, fictional country, to avoid environmental conflicts.
    public static final Country_Specific_Settings__c DEFAULT_COUNTRY_SPECIFIC_SETTING = null;

    private static final User TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();

    // NOTE: We can't use Id for this because Cases won't have a value for Id when we set this.
    public static  Map<String, Map<SEPTriggerTypeEnum, List<SEPTriggerHandlerStrategy>>> strategyListMapByTriggerTypeByStringIdMap = new Map<String, Map<SEPTriggerTypeEnum, List<SEPTriggerHandlerStrategy>>>();

    public static Id defaultCaseId      = null;

    static
    {
        if (Country_Specific_Settings__c.getValues(DEFAULT_COUNTRY_CODE) == null)
        {
            System.runAs(TEST_RUN_USER)
            {
                DEFAULT_COUNTRY_SPECIFIC_SETTING = TEST_DummyCountrySpecificSettingsFactory.create(new TEST_DummyCountrySpecificSettingsFactory.Config(DEFAULT_COUNTRY_CODE), true);
            }
        }
    }

    // -------------------------------------------------------------------------------------
    
    public static Case create (TEST_DummyCaseConfig config, TEST_DummyInsertModeEnum insertMode)
    {
        preconfigureRequiredIds(config, insertMode);
        
        Case   dummyCase = new Case();
        setCountry                  (dummyCase, config);
        setGenericValues            (dummyCase, config);
        setQualityComplaintValues   (dummyCase, config);
        setUserLookups              (dummyCase, config);    // This may overwrite any previously assigned (potentially conflicting!) values
        
        // Because the dummy Case has no proper id yet, we need to wait until some other combination of values have been populated so we can find these again later.
        if (config.strategyListMapByTriggerType != null) { setCustomCaseStrategies (dummyCase, config); }

        setMockValues               (dummyCase, config);

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  (        dummyCase );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  { System.runAs(TEST_RUN_USER) { insert dummyCase;  } }
                
        return dummyCase;
    }
    
    public static Case create (TEST_DummyInsertModeEnum insertMode) { return create (new TEST_DummyCaseConfig(), insertMode); }
    public static Case create ()                                    { return create (new TEST_DummyCaseConfig(), TEST_DummyInsertModeEnum.NONE); }

    // -------------------------------------------------------------------------------------

    public static List<Case> createList(Integer numberOfCases, TEST_DummyCaseConfig config, TEST_DummyInsertModeEnum insertMode)
    {
        List<Case> dummyCaseList = new List<Case>();
        for (Integer i=1; i<=numberOfCases; i++) { dummyCaseList.add(create(config, TEST_DummyInsertModeEnum.DML_LATER)); }

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  (        dummyCaseList );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  { System.runAs(TEST_RUN_USER) { insert dummyCaseList;  } }

        return dummyCaseList;
    }
    
    public static List<Case> createList(List<TEST_DummyCaseConfig> configList, TEST_DummyInsertModeEnum insertMode)
    {
        List<Case> dummyCaseList = new List<Case>();
        for (TEST_DummyCaseConfig config : configList) { dummyCaseList.add(create(config, TEST_DummyInsertModeEnum.DML_LATER)); }

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  (        dummyCaseList );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  { System.runAs(TEST_RUN_USER) { insert dummyCaseList;  } }

        return dummyCaseList;
    }
    
    // -------------------------------------------------------------------------------------

    private static void preconfigureRequiredIds (TEST_DummyCaseConfig config, TEST_DummyInsertModeEnum insertMode)
    {
        Boolean hasProductionCode         = (config.productionCode != null);
        Boolean isQualityComplaint = (config.recordTypeId == TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME)); //#CICTemplateTest 
        
        Boolean isBottlerAccountRequired  = isQualityComplaint;
        Boolean isPlantRequired           = isQualityComplaint || hasProductionCode;
        Boolean isPoSKeyAccountRequired   = isQualityComplaint;
        Boolean isPoSAccountRequired      = isQualityComplaint; 
        Boolean isProductRequired         = isQualityComplaint; 

        if (config.ownerId == null)                                                   { config.ownerId      = config.ownerUserId;                                     } // If ownerId has no value, will overwrite with value from ownerUserId (which might still be blank).
        if ((config.bottlerAccountId == null)           && (isBottlerAccountRequired))    { config.bottlerAccountId         = TEST_DummyAccountFactory.getDefaultBottlerAccountId(insertMode);        } // Required by validation rule.
        if ((config.pointOfSaleKeyAccountId == null)    && (isPoSKeyAccountRequired))     { config.pointOfSaleKeyAccountId  = TEST_DummyAccountFactory.getDefaultPointOfSaleKeyAccountId(insertMode); } // Required by validation rule.
        if ((config.pointOfSaleAccountId == null)       && (isPoSAccountRequired))        { config.pointOfSaleAccountId     = TEST_DummyAccountFactory.getDefaultPointOfSaleAccountId(insertMode);    } // Required by validation rule.
        if ((config.plantId == null)                    && (isPlantRequired))             { config.plantId                  = TEST_DummyPlantFactory.getDefaultPlantId(insertMode);                   } // Required by validation rule.
        if ((config.productId == null)                  && (isProductRequired))           { config.productId                = TEST_DummyProductFactory.getDefaultProductId(insertMode);               } // Required by validation rule.
        
        if ((config.userLookupFieldsToTestList != null) && (config.actionPlanId == null)) { config.actionPlanId             = TEST_DummyActionPlanFactory.createWithItems(config).id;                 }
    }
    
    private static void setCountry (Case dummyCase, TEST_DummyCaseConfig config)
    {
        config.countryCode = TEST_ConfigHelper.chooseValue(config.countryCode,  DEFAULT_COUNTRY_CODE);  // Arbitrary, fictional country

        if (Country_Specific_Settings__c.getValues(config.countryCode) == null)
        {
            TEST_DummyCountrySpecificSettingsFactory.create(new TEST_DummyCountrySpecificSettingsFactory.Config(config.countryCode), true); // This should only execute for non-default countries.
        }
        
       dummyCase.Country_Code__c                    = config.countryCode;
    } 
    
    private static void setGenericValues (Case dummyCase, TEST_DummyCaseConfig config)
    {
        TEST_UniqueHelper unique = new TEST_UniqueHelper(ECICCommonConstants.CASE_SUBJECT);
        
        // Category / Classification Values
            dummyCase.recordTypeId                       = TEST_ConfigHelper.chooseValue(config.recordTypeId,                      (Id) CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(ECICCommonConstants.INQUIRY_IBERIA_DEVNAME)); //#CICTemplateTest 
            dummyCase.type                               = TEST_ConfigHelper.chooseValue(config.type,                              null);                                   // a.k.a. "category level 1"
            dummyCase.reason                             = TEST_ConfigHelper.chooseValue(config.reason,                            ECICCommonConstants.INQUIRY_REASON);     // a.k.a. "category level 2"
            dummyCase.category_level3__c                  = TEST_ConfigHelper.chooseValue(config.categoryLevel3,                    null);
            dummyCase.category_level4__c                  = TEST_ConfigHelper.chooseValue(config.categoryLevel4,                    null);

        // Required lookup values
            if (config.ownerId != null) { dummyCase.OwnerId = config.ownerId; }         // We don't want to set OwnerId to null if none is specified; nor do we wish to give a specific value.

        // General Values
            dummyCase.description                        = TEST_ConfigHelper.chooseValue(config.description,                       unique.uniqueString + ' Description');
            dummyCase.origin                             = TEST_ConfigHelper.chooseValue(config.origin,                            ECICCommonConstants.CASE_ORIGIN);
            dummyCase.priority                           = TEST_ConfigHelper.chooseValue(config.priority,                          ECICCommonConstants.CASE_PRIORITY);
            dummyCase.status                             = TEST_ConfigHelper.chooseValue(config.status,                            ECICCommonConstants.STATUS_NEW);
            dummyCase.subject                            = TEST_ConfigHelper.chooseValue(config.subject,                           unique.uniqueString + ' Subject');

        // Booleans which must be set, even if not Quality Complaint
            dummyCase.imcr_issue__c                      = TEST_ConfigHelper.chooseValue(config.imcrIssue,                         false);
            dummyCase.no_quality_status_change__c        = TEST_ConfigHelper.chooseValue(config.noQualityStatusChange,             true);
            dummyCase.sample_collected__c                = TEST_ConfigHelper.chooseValue(config.sampleCollected,                   false);
            dummyCase.the3rdComplaint__c                 = TEST_ConfigHelper.chooseValue(config.thirdComplaint,                    false); 

        // General Values Values which default to null or empty
            dummyCase.AccountId                           = TEST_ConfigHelper.chooseValue(config.accountId,                         (Id) null);
            dummyCase.Action_Plan__c                     = TEST_ConfigHelper.chooseValue(config.actionPlanId,                      (Id) null);
            dummyCase.ContactId                          = TEST_ConfigHelper.chooseValue(config.contactId,                         (Id) null);
            dummyCase.Next_Open_Task_Reponsible_Lookup__c = TEST_ConfigHelper.chooseValue(config.nextOpenTaskResponsibleUserId,     (Id) null);
            dummyCase.channel_of_answer__c               = TEST_ConfigHelper.chooseValue(config.channelOfAnswer,                   null);
            dummyCase.createdDate                        = TEST_ConfigHelper.chooseValue(config.createdDate,                       null);
            dummyCase.No_of_Packs__c                         = TEST_ConfigHelper.chooseValue(config.numberOfPacks,                 null);
            dummyCase.SuppliedEmail                      = TEST_ConfigHelper.chooseValue(config.suppliedEmail,                     null);
            dummyCase.sysomosHB__web_url__c              = TEST_ConfigHelper.chooseValue(config.sysomosHbWebUrl,                   null);
    }
    
    // If non-null, these values will be populated for all Record Types, but should normaly only be used for Quality Complaints
    private static void setQualityComplaintValues (Case dummyCase, TEST_DummyCaseConfig config)
    {
        // Quality Complaint Values (To use default values, create Case with TEST_DummyQualityComplaintCaseFactory)         
            dummyCase.bottler__c                         = TEST_ConfigHelper.chooseValue(config.bottlerAccountId,                  (Id) null);
            dummyCase.package_supplier__c                = TEST_ConfigHelper.chooseValue(config.packageSupplierAccountId,          (Id) null);
            
            dummyCase.plant__c                           = TEST_ConfigHelper.chooseValue(config.plantId,                           (Id) null);
            dummyCase.Point_of_Sale__c                   = TEST_ConfigHelper.chooseValue(config.pointOfSaleAccountId,              (Id) null);
            dummyCase.PoS_Key_Account__c                 = TEST_ConfigHelper.chooseValue(config.pointOfSaleKeyAccountId,           (Id) null);
            dummyCase.product__c                         = TEST_ConfigHelper.chooseValue(config.productId,                         (Id) null);
            dummyCase.Beverage__c                        = TEST_ConfigHelper.chooseValue(config.beverageId,                        (Id) null);
            dummyCase.Package__c                         = TEST_ConfigHelper.chooseValue(config.packageId,                         (Id) null);
            dummyCase.production_line__c                 = TEST_ConfigHelper.chooseValue(config.productionLineId,                  (Id) null);
            dummyCase.region_of_purchase__c              = TEST_ConfigHelper.chooseValue(config.regionOfPurchaseId,                (Id) null);
            dummyCase.trend__c                           = TEST_ConfigHelper.chooseValue(config.trendId,                           (Id) null);
            
            dummyCase.bbe_date__c                        = TEST_ConfigHelper.chooseValue(config.bbeDate,                           null);
            dummyCase.infoline_status__c                 = TEST_ConfigHelper.chooseValue(config.infolineStatus,                    null);
            dummyCase.potential_risk__c                  = TEST_ConfigHelper.chooseValue(config.potentialRisk,                     null);
            dummyCase.process_type__c                    = TEST_ConfigHelper.chooseValue(config.processType,                       null);
            dummyCase.production_code__c                 = TEST_ConfigHelper.chooseValue(config.productionCode,                    null);
            dummyCase.package_batch__c                   = TEST_ConfigHelper.chooseValue(config.packageBatch,                      null);
            dummyCase.quality_status__c                  = TEST_ConfigHelper.chooseValue(config.qualityStatus,                     null);
            dummyCase.risk_type__c                       = TEST_ConfigHelper.chooseValue(config.riskType,                          null);
            dummyCase.trend_key__c                       = TEST_ConfigHelper.chooseValue(config.trendKey,                          null);
            dummyCase.trend_mark__c                      = TEST_ConfigHelper.chooseValue(config.trendMark,                         null);
            
        // Quality Complaint Values which default to null or empty
            dummyCase.Bottler_External_Relations__c      = TEST_ConfigHelper.chooseValue(config.bottlerExternalRelationsUserId,    (Id) null);
            dummyCase.Bottler_Quality_Manager__c         = TEST_ConfigHelper.chooseValue(config.bottlerQualityManagerUserId,       (Id) null);
            dummyCase.Bottler_Quality_Owner__c           = TEST_ConfigHelper.chooseValue(config.bottlerQualityOwnerUserId,         (Id) null);
            dummyCase.Distributor_External_Relations__c  = TEST_ConfigHelper.chooseValue(config.distributorEternalRelationsUserId, (Id) null);
            dummyCase.Distributor_Quality__c             = TEST_ConfigHelper.chooseValue(config.distributorQualityUserId,          (Id) null);
            dummyCase.Distributor_Quality_Manager__c     = TEST_ConfigHelper.chooseValue(config.distributorQualityManagerUserId,   (Id) null);
            dummyCase.Quality_Admin_Assistant__c         = TEST_ConfigHelper.chooseValue(config.qualityAdminAssistantUserId,       (Id) null);
            dummyCase.Quality_Case_Owner__c              = TEST_ConfigHelper.chooseValue(config.qualityCaseOwnerUserId,            (Id) null);
            dummyCase.Quality_Manager__c                 = TEST_ConfigHelper.chooseValue(config.qualityManagerUserId,              (Id) null);
            dummyCase.Service_Manager__c                 = TEST_ConfigHelper.chooseValue(config.serviceManagerUserId,              (Id) null);

            dummyCase.Bottler_Name__c                    = TEST_ConfigHelper.chooseValue(config.bottlerName,                       null);
            dummyCase.region_bottler_name__c             = TEST_ConfigHelper.chooseValue(config.regionBottlerName,                 null);
            dummyCase.Place_of_Purchase__c               = TEST_ConfigHelper.chooseValue(config.placeOfPurchase,                   null);
            dummyCase.Comments_of_analyst_lab_manager__c = TEST_ConfigHelper.chooseValue(config.analystLabManagerComments,         null);
            dummyCase.Product_Unit_Price__c              = TEST_ConfigHelper.chooseValue(config.productUnitPrice,                  null);
            dummyCase.Value_of_Vouchers__c               = TEST_ConfigHelper.chooseValue(config.voucherValue,                      null);
    }

    private static void setUserLookups (Case dummyCase, TEST_DummyCaseConfig config)
    {
        if ((config.userLookupFieldsToTestList != null) && (config.assignedUserByFieldNameMap != null))
        {
            for (String userLookupField : config.userLookupFieldsToTestList) 
            { 
                dummyCase.put(userLookupField, config.assignedUserByFieldNameMap.get(userLookupField).id); 
            }
        }
    }

    private static void setMockValues (Case dummyCase, TEST_DummyCaseConfig config)
    {
        TEST_MockHelper.setMockBoolean(dummyCase, 'skipStrategies', config.skipStrategies);
    }

    private static void setCustomCaseStrategies (Case dummyCase, TEST_DummyCaseConfig config)
    {
        String dummyCaseStringIdentifier = ECICMapHelper.createMapIdentifier(dummyCase, false);     
        strategyListMapByTriggerTypeByStringIdMap.put(dummyCaseStringIdentifier, config.strategyListMapByTriggerType);
        config.skipStrategies = false; 
    }

    public static Boolean useCustomCaseStrategies (Case dummyCase)
    {
        String dummyCaseStringIdentifier = ECICMapHelper.createMapIdentifier(dummyCase, false);
        return (strategyListMapByTriggerTypeByStringIdMap.containsKey(dummyCaseStringIdentifier));
    }

    public static List<SEPTriggerHandlerStrategy> getCustomCaseStrategies (Case dummyCase, SEPTriggerTypeEnum triggerType)
    {
        String dummyCaseStringIdentifier = ECICMapHelper.createMapIdentifier(dummyCase, false);
        if (!strategyListMapByTriggerTypeByStringIdMap.containsKey(dummyCaseStringIdentifier)) { return null; }
        return strategyListMapByTriggerTypeByStringIdMap.get(dummyCaseStringIdentifier).get(triggerType);
    }

    // --------------------------------------------------------------------------------------------------------------------------------------

    public static Id getDefaultCaseId (TEST_DummyInsertModeEnum insertMode)
    {
        if      (defaultCaseId != null)                       { return defaultCaseId;      }
        else if (!((new Set<TEST_DummyInsertModeEnum>{ TEST_DummyInsertModeEnum.REAL, TEST_DummyInsertModeEnum.DML_LATER})).contains(insertMode))
        { 
            return '50011000001FTZs';  
        }

        Case   dummyCase = create(TEST_DummyInsertModeEnum.REAL);
               defaultCaseId = dummyCase.id;
        return defaultCaseId;
    }


}