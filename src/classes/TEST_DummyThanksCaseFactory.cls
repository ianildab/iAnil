@isTest // Commented whole class since we are not using thanks record type
public class TEST_DummyThanksCaseFactory 
{/*
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
        config.recordTypeId     = TEST_ConfigHelper.chooseValue(config.recordTypeId, (Id) TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get('Thanks'));
        config.reason           = TEST_ConfigHelper.chooseValue(config.reason,       ECICCommonConstants.THANKS_REASON);
    }
*/}