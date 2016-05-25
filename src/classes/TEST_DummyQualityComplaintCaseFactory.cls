@isTest
public class TEST_DummyQualityComplaintCaseFactory 
{
    public static final Account            DEFAULT_BOTTLER_ACCOUNT                       = null;  
    public static final Account            DEFAULT_PACKAGE_SUPPLIER_ACCOUNT              = null;  
    public static final Account            DEFAULT_POINT_OF_SALE_ACCOUNT                 = null;  
    public static final Account            DEFAULT_POINT_OF_SALE_KEY_ACCOUNT             = null;  

    public static final Plant__c           DEFAULT_PLANT                                 = null;
    public static final Product__c         DEFAULT_PRODUCT                               = null;
    public static final Production_Line__c DEFAULT_PRODUCTION_LINE                       = null;

    // NOTE: Default Users for Regions are created and assigned using ECICCaseTaskAssignmentStrategy, with "Original Shift" values.
    public static final Region__c          DEFAULT_REGION_OF_BOTTLER                     = null;    // Value Needed for Plant           
    public static final Region__c          DEFAULT_REGION_OF_DISTRIBUTOR                 = null;    

    static
    {
        if (DEFAULT_REGION_OF_BOTTLER == null)  // If one is null, we can assume these will all be null!
        {
            Map<String, Region__c> defaultRegionMap = TEST_DummyRegionFactory.createDefaultRegionMap();
                Region__c defaultBottlerRegion      = defaultRegionMap.get('Bottler');
                Region__c defaultDistributorRegion  = defaultRegionMap.get('Distributor');
 
            Map <String, Account> caseRequiredAccountMap = TEST_DummyAccountFactory.createCaseAccountMap(defaultBottlerRegion, true); 
                DEFAULT_BOTTLER_ACCOUNT             = caseRequiredAccountMap.get('bottler');  
                DEFAULT_PACKAGE_SUPPLIER_ACCOUNT    = caseRequiredAccountMap.get('packageSupplier');  
                DEFAULT_POINT_OF_SALE_ACCOUNT       = caseRequiredAccountMap.get('pointOfSale');  
                DEFAULT_POINT_OF_SALE_KEY_ACCOUNT   = caseRequiredAccountMap.get('pointOfSaleKey');  
                
            TEST_DummyRegionFactory.addBottlerAccount(new List<Region__c>{ defaultBottlerRegion, defaultDistributorRegion }, DEFAULT_BOTTLER_ACCOUNT.id);
                DEFAULT_REGION_OF_BOTTLER           = defaultBottlerRegion;                 // Value Needed for Plant   
                DEFAULT_REGION_OF_DISTRIBUTOR       = defaultDistributorRegion; 
                
            DEFAULT_PLANT               = TEST_DummyPlantFactory.create(DEFAULT_BOTTLER_ACCOUNT.id, DEFAULT_REGION_OF_BOTTLER.id, true);
            DEFAULT_PRODUCTION_LINE     = TEST_DummyProductionLineFactory.create(DEFAULT_PLANT.id, true);
            DEFAULT_PRODUCT             = TEST_DummyProductFactory.create(true);
        }       
    }
    
    public static Case create (TEST_DummyCaseConfig config, TEST_DummyInsertModeEnum insertMode)  
    { 
        setCaseTypeDefaults(config);
        return TEST_DummyGenericCaseFactory.create(config, insertMode);
    }
    
    public static Case create (TEST_DummyInsertModeEnum insertMode) { return create (new TEST_DummyCaseConfig(), insertMode);                   }
    public static Case create ()                                    { return create (new TEST_DummyCaseConfig(), TEST_DummyInsertModeEnum.NONE); }

    // -------------------------------------------------------------------------------------

    public static List<Case> createList(Integer numberOfCases, TEST_DummyCaseConfig config, TEST_DummyInsertModeEnum insertMode)
    {
        setCaseTypeDefaults(config);
        return TEST_DummyGenericCaseFactory.createList(numberOfCases, config, insertMode);
    }
    
    public static List<Case> createList(List<TEST_DummyCaseConfig> configList, TEST_DummyInsertModeEnum insertMode)
    {
        for (TEST_DummyCaseConfig config : configList) { setCaseTypeDefaults(config); }
        return TEST_DummyGenericCaseFactory.createList(configList, insertMode);
    }

    // -------------------------------------------------------------------------------------

    public static void setCaseTypeDefaults (TEST_DummyCaseConfig config)
    {
        config.recordTypeId             = TEST_ConfigHelper.chooseValue(config.recordTypeId,                (Id) TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME)); //#CICTemplateTest
        config.reason                   = TEST_ConfigHelper.chooseValue(config.reason,                      ECICCommonConstants.QUALITY_COMPLAINT_REASON_PRODUCTS);

        config.bottlerAccountId         = TEST_ConfigHelper.chooseValue(config.bottlerAccountId,            (Id) DEFAULT_BOTTLER_ACCOUNT.id);
        config.packageSupplierAccountId = TEST_ConfigHelper.chooseValue(config.packageSupplierAccountId,    (Id) DEFAULT_PACKAGE_SUPPLIER_ACCOUNT.id);
        config.plantId                  = TEST_ConfigHelper.chooseValue(config.plantId,                     (Id) DEFAULT_PLANT.id);
        config.pointOfSaleAccountId     = TEST_ConfigHelper.chooseValue(config.pointOfSaleAccountId,        (Id) DEFAULT_POINT_OF_SALE_ACCOUNT.id);
        config.pointOfSaleKeyAccountId  = TEST_ConfigHelper.chooseValue(config.pointOfSaleKeyAccountId,     (Id) DEFAULT_POINT_OF_SALE_KEY_ACCOUNT.id);
        config.productId                = TEST_ConfigHelper.chooseValue(config.productId,                   (Id) DEFAULT_PRODUCT.id);
        config.productionLineId         = TEST_ConfigHelper.chooseValue(config.productionLineId,            (Id) DEFAULT_PRODUCTION_LINE.id);
        config.regionOfPurchaseId       = TEST_ConfigHelper.chooseValue(config.regionOfPurchaseId,          (Id) DEFAULT_REGION_OF_DISTRIBUTOR.id);

        config.bbeDate                  = TEST_ConfigHelper.chooseValue(config.bbeDate,                     System.today());
        config.infolineStatus           = TEST_ConfigHelper.chooseValue(config.infolineStatus,              ECICCommonConstants.STATUS_OPEN);
        config.potentialRisk            = TEST_ConfigHelper.chooseValue(config.potentialRisk,               'No Risk');
        config.processType              = TEST_ConfigHelper.chooseValue(config.processType,                 'TIPO 2.5');
        config.productionCode           = TEST_ConfigHelper.chooseValue(config.productionCode,              ECICCommonConstants.TEST_PRODUCTION_LINE_NAME);
        config.packageBatch             = TEST_ConfigHelper.chooseValue(config.packageBatch,                'test');
        config.qualityStatus            = TEST_ConfigHelper.chooseValue(config.qualityStatus,               'New complaint');
        config.riskType                 = TEST_ConfigHelper.chooseValue(config.riskType,                    '');                // Intentional non-null!
    }
}