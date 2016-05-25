@isTest
public class TEST_DummyClosedTrendCaseFactory 
{
	public class Config
	{
	        public Id  	   caseId  			  = null;
	        public Id      closedTrendId	  = null;
	        
	        public Config(){}
	        public Config(Id caseId, Id closedTrendId){ this.caseId = caseId; this.closedTrendId = closedTrendId;}
	}
	
    public static Closed_Trend_Case__c createDummy(Config config, Boolean insertNow)
    {
        Closed_Trend_Case__c dummyClosedTrendCase = new Closed_Trend_Case__c();
				        dummyClosedTrendCase.case__c  		  = TEST_ConfigHelper.chooseValue(config.caseId,   		ECICCaseTestHelper.createDummyCase(true).id);
				        dummyClosedTrendCase.closed_trend__c  = TEST_ConfigHelper.chooseValue(config.closedTrendId, TEST_DummyClosedTrendFactory.createDummy(true).id);
		if (insertNow) { insert dummyClosedTrendCase; }
        		 return dummyClosedTrendCase;
    }

    public static Closed_Trend_Case__c createDummy(Boolean insertNow) { return createDummy(new Config(), insertNow); }
    public static Closed_Trend_Case__c createDummy() { return createDummy(new Config(), false); }

    public static Closed_Trend_Case__c createDummy(Id caseId, Id closedTrendId, Boolean insertNow) { return createDummy(new Config(caseId, closedTrendId), insertNow); }

}