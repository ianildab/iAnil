@isTest
public class TEST_DummyNonQualityComplaintCaseFactory 
{ 
    public static Case create (TEST_DummyCaseConfig config, TEST_DummyInsertModeEnum insertMode)
    {
        setCaseTypeDefaults(config);
        return TEST_DummyGenericCaseFactory.create(config, insertMode);
    }
    
    public static Case create (TEST_DummyInsertModeEnum insertMode) { return create (new TEST_DummyCaseConfig(), insertMode);                           }
    public static Case create ()                                        { return create (new TEST_DummyCaseConfig(), TEST_DummyInsertModeEnum.NONE); }

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
        config.recordTypeId     = TEST_ConfigHelper.chooseValue(config.recordTypeId, (Id) TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(ECICCommonConstants.NON_QUALITY_COMPLAINT_IBERIA_DEVNAME)); //#CICTemplateTest
        config.reason           = TEST_ConfigHelper.chooseValue(config.reason,       ECICCommonConstants.NON_QUALITY_COMPLAINT_REASON);
    }
}