@isTest
public class TEST_DummyActionPlanFactory 
{
    public class Config
    {
        public String  name              = null;
        public String  uniqueName        = null;
        public String  internationalName = null;
        public String  countryCode       = null;
        public String  caseChannel       = null;
        public String  caseReason        = null;
        public String  categoryLevel3    = null;
        public String  categoryLevel4    = null;
        public Integer rank              = null;
        public Boolean isActive          = null;
        
        public Config(){}

        public Config(String caseChannel, String caseReason, String categoryLevel3, String categoryLevel4)
        {
            this.caseChannel    = caseChannel;
            this.caseReason     = caseReason;
            this.categoryLevel3 = categoryLevel3;
            this.categoryLevel4 = categoryLevel4;
        }

        public Config(String caseChannel, String caseReason, String categoryLevel3, String categoryLevel4, String countryCode)
        {
            this (caseChannel, caseReason, categoryLevel3, categoryLevel4);
            this.countryCode = countryCode;        	
        }
    }
    
    public static Action_Plan__c create (Config config, TEST_DummyInsertModeEnum insertMode)
    { 
        Test_UniqueHelper unique = new Test_UniqueHelper('Dummy Action Plan');
        
        Action_Plan__c dummyActionPlan = new Action_Plan__c();
                       dummyActionPlan.name                  = TEST_ConfigHelper.chooseValue(config.name,              unique.uniqueString);
                       dummyActionPlan.unique_name__c        = TEST_ConfigHelper.chooseValue(config.uniqueName,        unique.uniqueString);
                       dummyActionPlan.international_name__c = TEST_ConfigHelper.chooseValue(config.internationalName, unique.uniqueString);
                       dummyActionPlan.country_code__c       = TEST_ConfigHelper.chooseValue(config.countryCode,       ECICCommonConstants.COUNTRY_CODE_DEFAULT);
                       
                       dummyActionPlan.case_channel__c       = TEST_ConfigHelper.chooseValue(config.caseChannel,       'Phone');
                       dummyActionPlan.case_reason__c        = TEST_ConfigHelper.chooseValue(config.caseReason,        'Product info');
                       dummyActionPlan.category_level3__c    = TEST_ConfigHelper.chooseValue(config.categoryLevel3,    'Formula - Ingredients');
                       dummyActionPlan.category_level4__c    = TEST_ConfigHelper.chooseValue(config.categoryLevel4,    'Vitamines');
                       
                       dummyActionPlan.rank__c               = TEST_ConfigHelper.chooseValue(config.rank,              unique.uniqueInt);
                       dummyActionPlan.active__c             = TEST_ConfigHelper.chooseValue(config.isActive,          true);
                       
         
        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyActionPlan );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyActionPlan;    }

        return dummyActionPlan;
    }
    
    public static Action_Plan__c create (TEST_DummyInsertModeEnum insertMode) { return create ( new Config(), insertMode );                        }
    public static Action_Plan__c create ()                                    { return create ( new Config(), TEST_DummyInsertModeEnum.NONE     ); }

    public static Action_Plan__c create (String caseChannel, String caseReason, String categoryLevel3, String categoryLevel4, TEST_DummyInsertModeEnum insertMode) 
    { 
    	return create ( new Config(caseChannel, caseReason, categoryLevel3, categoryLevel4), insertMode );                        
    }

    public static Action_Plan__c create (String caseChannel, String caseReason, String categoryLevel3, String categoryLevel4, String countryCode, TEST_DummyInsertModeEnum insertMode) 
    { 
        return create ( new Config(caseChannel, caseReason, categoryLevel3, categoryLevel4, countryCode), insertMode );                        
    }
    
    // ---------------------------------------------------------------------------------------------------

    public static Action_Plan__c createWithItems (TEST_DummyCaseConfig caseConfig)
    {
        Config actionPlanConfig = new Config();
               actionPlanConfig.countryCode = caseConfig.countryCode;
        Action_Plan__c dummyActionPlan = create (actionPlanConfig, TEST_DummyInsertModeEnum.REAL);
        
        caseConfig.actionPlanId = dummyActionPlan.id;  
        TEST_DummyActionPlanItemFactory.createList(caseConfig, TEST_DummyInsertModeEnum.REAL);
        return dummyActionPlan;  
    }
    
    public static Action_Plan__c createEmpty (TEST_DummyInsertModeEnum insertMode) 
    {
    	return create ( new Config(TEST_ConfigHelper.INTENTIONAL_NULL, TEST_ConfigHelper.INTENTIONAL_NULL, TEST_ConfigHelper.INTENTIONAL_NULL, TEST_ConfigHelper.INTENTIONAL_NULL), insertMode );  
    }
    
    // ------------------------------------------------------------------------------------------------------------------------------------
    
    public static List<Action_Plan__c> createList (Integer quantity, Config config, TEST_DummyInsertModeEnum insertMode)
    {
        List<Action_Plan__c> dummyActionPlanList = new List<Action_Plan__c>();

        for (Integer i=1; i<=quantity; i++)
        {
            dummyActionPlanList.add(create(config, TEST_DummyInsertModeEnum.NONE));
        } 

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  ( dummyActionPlanList );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  {                     insert    dummyActionPlanList;    }

        return dummyActionPlanList;
    }

    public static List<Action_Plan__c> createList (Integer quantity, TEST_DummyInsertModeEnum insertMode) { return createList (quantity, new Config(), insertMode); }
    
}