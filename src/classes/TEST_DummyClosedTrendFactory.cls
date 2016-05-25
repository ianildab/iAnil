@isTest
public class TEST_DummyClosedTrendFactory 
{
    public static final Integer DEFAULT_PERIOD 	    = 7;
    public static final Integer DEFAULT_THRESHOLD 	= 3;
	
	public class Config
	{
	        public String  additionalTo = null;
	        public String  caseReason   = null;
            public String  countryCode        = null;
            public String  countryCodeString  = null;
            public String  productDescription = null;
            public String  productType        = null;
	        public Id      plantId      = null;
            public Id      recordTypeId       = null;
	        public Integer period	    = null;
	        public Integer threshold    = null;
	        public Boolean isActive		      = null;
	        
            public Config(Id recordTypeId){this.recordTypeId = recordTypeId;}
	        
	        public Config(){}
	}
	
    public static Closed_Trend__c create(Config config, TEST_DummyInsertModeEnum insertMode)
    {
        Closed_Trend__c dummyClosedTrend = new Closed_Trend__c();
                        dummyClosedTrend.RecordTypeId           = TEST_ConfigHelper.chooseValue(config.recordTypeId,          ECICClosedTrendHelper.CLOSED_TREND_DEFINITION_RT_ID);
				        dummyClosedTrend.country_code__c        = TEST_ConfigHelper.chooseValue(config.countryCode,           ECICCommonConstants.COUNTRY_CODE_DEFAULT);
                        dummyClosedTrend.country_code_string__c = TEST_ConfigHelper.chooseValue(config.countryCodeString,     null);
				        dummyClosedTrend.additional_to__c       = TEST_ConfigHelper.chooseValue(config.additionalTo,          'salesforce_spam@spam.example.com');
				        dummyClosedTrend.Case_Reason__c   = TEST_ConfigHelper.chooseValue(config.caseReason,    ECICCommonConstants.QUALITY_COMPLAINT_REASON_PRODUCTS);
                        dummyClosedTrend.product_description__c = TEST_ConfigHelper.chooseValue(config.productDescription,    null);
                        dummyClosedTrend.type__c                = TEST_ConfigHelper.chooseValue(config.productType,           null);
				        dummyClosedTrend.Plant__c         = TEST_ConfigHelper.chooseValue(config.plantId,       TEST_DummyPlantFactory.getDefaultPlantId(insertMode));
				        dummyClosedTrend.Period__c        = TEST_ConfigHelper.chooseValue(config.period, 		DEFAULT_PERIOD);
				        dummyClosedTrend.Threshold__c     = TEST_ConfigHelper.chooseValue(config.threshold,		DEFAULT_THRESHOLD);
				        dummyClosedTrend.active__c 		        = TEST_ConfigHelper.chooseValue(config.isActive,		      true);

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyClosedTrend );    } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyClosedTrend;      }

        		 return dummyClosedTrend;
    }

    public static Closed_Trend__c create (TEST_DummyInsertModeEnum insertMode) { return create ( new Config(), insertMode );                     }
    public static Closed_Trend__c create ()                                    { return create ( new Config(), TEST_DummyInsertModeEnum.NONE     ); }
    
    public static Closed_Trend__c create (Integer period, Integer threshold, TEST_DummyInsertModeEnum insertMode)
    {
		Config config = new Config();
			   config.period 	= period;
			   config.threshold	= threshold;		
        return create (config, insertMode);
    }
    
    public static Closed_Trend__c create (Id recordTypeId, TEST_DummyInsertModeEnum insertMode) { return create (new Config(recordTypeId), insertMode); }
    

    // --------------------------------------------------------------------------------------------------------------------------------------

    public static List<Closed_Trend__c> createList (List<Config> configList, TEST_DummyInsertModeEnum insertMode)
    {
    	List<Closed_Trend__c> dummyClosedTrendList = new List<Closed_Trend__c>();
    	for (Config config : ConfigList) { dummyClosedTrendList.add (create(config, TEST_DummyInsertModeEnum.NONE)); }

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyClosedTrendList );    } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyClosedTrendList;      }

        return dummyClosedTrendList;
    }
    
    // --------------------------------------------------------------------------------------------------------------------------------------

    // @depreciated : Use create (Config config, TEST_DummyInsertModeEnum insertMode)
    public static Closed_Trend__c createDummy (Config config, Boolean insertNow)                     { return create (config,     convert(insertNow));        }

    // @depreciated : Use create (TEST_DummyInsertModeEnum insertMode)
    public static Closed_Trend__c createDummy (Boolean insertNow)                                    { return create (new Config(), convert(insertNow));      }

    // @depreciated : Use create (Integer period, Integer threshold, TEST_DummyInsertModeEnum insertMode)
    public static Closed_Trend__c createDummy(Integer period, Integer threshold, Boolean insertNow)  { return create (period, threshold, convert(insertNow)); }

    private static TEST_DummyInsertModeEnum convert (Boolean insertNow)
    {
        return (insertNow) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE;
    }
    
}