@isTest
public class TEST_DummyTrendFactory 
{
	public class Config
	{
        public Id      productId        = null;
        public Id      productionLineId = null;
	        public String  countryCode  = null;
        public Integer caseCount	= null;
        public Integer closedCaseCount  = null;
        public Date    bbeDate          = null;
        public Date	   createdDate  = null;
	    public Boolean recheckPotentialRisk = null;
	        
	        public Config(){}
	    public Config(Date createdDate) { this.createdDate = createdDate; }
	}
	
    public static Trend__c create(Config config, TEST_DummyInsertModeEnum insertMode)
    {
        Trend__c dummyTrend = new Trend__c();
				 dummyTrend.country_code__c  = TEST_ConfigHelper.chooseValue(config.countryCode,   ECICCommonConstants.COUNTRY_CODE_DEFAULT);
                 dummyTrend.Product__c         = TEST_ConfigHelper.chooseValue(config.productId,        (Id) null);
                 dummyTrend.Production_Line__c = TEST_ConfigHelper.chooseValue(config.productionLineId, (Id) null);
				 dummyTrend.caseCount__c  	 = TEST_ConfigHelper.chooseValue(config.caseCount,     0);
                 dummyTrend.closedCaseCount__c = TEST_ConfigHelper.chooseValue(config.closedCaseCount,  0);
                 dummyTrend.BBE_Date__c        = TEST_ConfigHelper.chooseValue(config.bbeDate,          null);
				 dummyTrend.createdDate		 = TEST_ConfigHelper.chooseValue(config.createdDate,   null);
                 dummyTrend.recheck_potential_risk__c   = TEST_ConfigHelper.chooseValue(config.recheckPotentialRisk,   false);
		
		if 			(insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert ( dummyTrend ); } 
		else if 	(insertMode	== TEST_DummyInsertModeEnum.REAL)  { 					 insert   dummyTrend;   }

        		 return dummyTrend;
    }

	public static Trend__c create (TEST_DummyInsertModeEnum insertMode) { return create (new Config(), insertMode); 				   }
	public static Trend__c create () 				  				    { return create (new Config(), TEST_DummyInsertModeEnum.NONE); }
	
	// -----------------------------------------------------------------------------------------
	
	public static List<Trend__c> createList(Integer numberOfTrends, Config config, TEST_DummyInsertModeEnum insertMode)
	{
		List<Trend__c> dummyTrendList = new List<Trend__c>();
		for (Integer i=1; i<=numberOfTrends; i++) { dummyTrendList.add(create(config, TEST_DummyInsertModeEnum.NONE)); }

		if 			(insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyTrendList ); } 
		else if 	(insertMode	== TEST_DummyInsertModeEnum.REAL)  { 					 insert    dummyTrendList;   }

		return dummyTrendList;
	}
	
	public static List<Trend__c> createList(List<config> configList, TEST_DummyInsertModeEnum insertMode)
	{
		List<Trend__c> dummyTrendList = new List<Trend__c>();
		for (Config config : configList) { dummyTrendList.add(create(config, TEST_DummyInsertModeEnum.NONE)); }

		if 			(insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyTrendList ); } 
		else if 	(insertMode	== TEST_DummyInsertModeEnum.REAL)  { 					 insert    dummyTrendList;   }

		return dummyTrendList;
	}
	
	// -----------------------------------------------------------------------------------------
	
	// @depreciated : Use create (Config config, TEST_DummyInsertModeEnum insertMode)
	public static Trend__c createDummy (Config config, Boolean insertNow)    { return create (config, 	   convert(insertNow));            }

	// @depreciated : Use create (TEST_DummyInsertModeEnum insertMode)
	public static Trend__c createDummy (Boolean insertNow) 					 { return create (new Config(), convert(insertNow));            }

	private static TEST_DummyInsertModeEnum convert (Boolean insertNow)
	{
		return (insertNow) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE;
	}
}