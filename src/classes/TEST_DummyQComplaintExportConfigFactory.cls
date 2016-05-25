@isTest
public class TEST_DummyQComplaintExportConfigFactory 
{
    private static final User      SETUP_DATA_CREATION_USER = TEST_DummyUserFactory.SETUP_DATA_CREATION_USER;

    public class Config
    {
    	public String  name              = null;
        public String  sfdcCaseFieldPath = null;
        public Integer exportFieldRank   = null;
        
        public Config(){} 
        
        public Config(Integer exportFieldRank, String sfdcCaseFieldPath)
        {
            this.exportFieldRank   = exportFieldRank;
        	this.sfdcCaseFieldPath = sfdcCaseFieldPath;
        }
    }
    
    public static Quality_Complaint_Export_Configuration__c create(Config config, TEST_DummyInsertModeEnum insertMode)
    {
        TEST_UniqueHelper unique = new TEST_UniqueHelper('Dummy Config');
    	
        Quality_Complaint_Export_Configuration__c exportConfig  =  new Quality_Complaint_Export_Configuration__c();
                                                  exportConfig.name                   =   TEST_ConfigHelper.chooseValue(config.name,              unique.uniqueString);
                                                  exportConfig.SFDC_Case_Fieldpath__c =   TEST_ConfigHelper.chooseValue(config.sfdcCaseFieldPath, 'reason');
                                                  exportConfig.Export_Field_Rank__c   =   TEST_ConfigHelper.chooseValue(config.exportFieldRank,   1);

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  (                   exportConfig );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  { System.runAs(SETUP_DATA_CREATION_USER) { insert exportConfig;  } }

                              return exportConfig;
    } 

    public static Quality_Complaint_Export_Configuration__c create (TEST_DummyInsertModeEnum insertMode) { return create (new Config(), insertMode);                    }
    public static Quality_Complaint_Export_Configuration__c create ()                                    { return create (new Config(), TEST_DummyInsertModeEnum.NONE); }

    // -----------------------------------------------------------------------------------------------------------------------------------------------------------    

    public static List<Quality_Complaint_Export_Configuration__c> createList(List<Config> configList, TEST_DummyInsertModeEnum insertMode)
    {
        List<Quality_Complaint_Export_Configuration__c> dummyExportConfigList = new List<Quality_Complaint_Export_Configuration__c>();
        for (Config config : configList) { dummyExportConfigList.add(create(config, TEST_DummyInsertModeEnum.NONE)); }

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  (                   dummyExportConfigList );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  { System.runAs(SETUP_DATA_CREATION_USER) { insert dummyExportConfigList;  } }

        return dummyExportConfigList;

    }
    
    // -----------------------------------------------------------------------------------------------------------------------------------------------------------    
 
    public static Map<Integer, Quality_Complaint_Export_Configuration__c> createMap (Map<Integer, String> dummyExportFieldByRankMap, TEST_DummyInsertModeEnum insertMode)
    {   
    	List<Config> configList = new List<Config>();
    	for (Integer key : dummyExportFieldByRankMap.keySet()) { configList.add(new Config(key, dummyExportFieldByRankMap.get(key))); }
    	List<Quality_Complaint_Export_Configuration__c> exportConfigList = createList(configList, insertMode);
    	
    	Map<Integer, Quality_Complaint_Export_Configuration__c> exportConfigByRankMap = new Map<Integer, Quality_Complaint_Export_Configuration__c>();
        for(Quality_Complaint_Export_Configuration__c exportConfig : exportConfigList)
        {
            exportConfigByRankMap.put((Integer)exportConfig.Export_Field_Rank__c, exportConfig);
        }
        return exportConfigByRankMap;
    }
}