@isTest 
public class TEST_DummyFastQualityComplaintCaseFactry 
{
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