@isTest
public class TEST_DummyCaseTrigStrategyConfigFactory 
{	
  	public  static final String  			DEFAULT_COUNTRY 	  	= 'ES';
  	public  static final String  			DEFAULT_STRATEGY_NAME 	= 'ECICCaseTriggerHandlerTestStrategy';
  	public  static final Integer 			DEFAULT_RANK 			= 1;
  	public  static final SEPTriggerTypeEnum DEFAULT_TRIGGER_TYPE	= SEPTriggerTypeEnum.BEFORE_INSERT;

    public static final List<String> 		DEFAULT_STRATEGY_CHAIN = new List<String>
    {
            'ECICCaseValidateProdlineStrategy', 
 			'ECICCaseChannelChangeValidationStrategy', 
 			'ECICCaseQComplSampleCollValidatorStrat', 
            'ECICCaseCopyProductDetailsStrategy', 
            'ECICCaseAccountAndContactSetterStrategy', 
            'ECICCaseMulSetterStrategy', 
            'ECICCaseQComplaintStatusSetterStrategy', 
            'ECICCaseQualityStatusClosingStrategy', 
            'ECICCaseQualityCloseDateSetterStrategy', 
            'ECICCaseInfolineCloseDateSetterStrategy', 
            'ECICCaseComplaintEscalationStrategy', 
            'ECICCaseHighPriorityIfHighRiskStrategy', 
            'ECICCaseInfolineStatusSetterStrategy', 
            'ECICCaseProductionCodeProcessingStrategy', 
            'ECICCaseQComplQualTechReasonsSetterStrat', 
            'ECICCaseQComplAnalysisLabSetterStrategy', 
            'ECICCaseQComplBottlerUserSetterStrategy', 
            'ECICCaseOwnerLookupSetterStrategy', 
            'ECICCaseComplaintVoucherStrategy', 
            'ECICCaseQComplBottlerNameSetterStrategy', 
            'ECICCaseQComplaintPOSSetterStrategy', 
            'ECICCaseNoQualityStatusChangeStrategy'
    };

  	private static final User TEST_RUN_USER   = ECICRunUserTestHelper.create();

	public class Config
	{
		public String  name 					= null;
		public String  strategyApexClassName 	= null;
		public String  countryCode			 	= null;
		public Integer rank						= null;
		public Boolean isActive					= null;
		public Boolean executeBeforeInsert		= null;
		public Boolean executeAfterInsert		= null;
		public Boolean executeBeforeUpdate		= null;
		public Boolean executeAfterUpdate		= null;
		public Boolean executeBeforeDelete		= null;
		public Boolean executeAfterDelete		= null;
		public Boolean executeAfterUndelete		= null;
		
		public Config() 							  { setDefaultTriggerType(); }
		public Config(SEPTriggerTypeEnum triggerType) { this.setTriggerType (triggerType); }

		public Config(String countryCode, String strategyApexClassName, SEPTriggerTypeEnum triggerType) 
		{
			this (triggerType);
			this.countryCode 			= countryCode;
			this.strategyApexClassName	= strategyApexClassName;
		}
		
		private Boolean noTriggerTypeSet()
		{
			return (!(
							this.executeBeforeInsert || this.executeAfterInsert
						||  this.executeBeforeUpdate || this.executeAfterUpdate
						|| this.executeBeforeDelete  || this.executeAfterDelete
						|| 								this.executeAfterUndelete
					));
		}
		
		private void setTriggerType (SEPTriggerTypeEnum triggerType)
		{
			//Only one of these can be true; so only one will be set to true.
			this.executeBeforeInsert  = (triggerType == SEPTriggerTypeEnum.BEFORE_INSERT); 
			this.executeAfterInsert   = (triggerType == SEPTriggerTypeEnum.AFTER_INSERT);
			this.executeBeforeUpdate  = (triggerType == SEPTriggerTypeEnum.BEFORE_UPDATE);
			this.executeAfterUpdate   = (triggerType == SEPTriggerTypeEnum.AFTER_UPDATE);
			this.executeBeforeDelete  = (triggerType == SEPTriggerTypeEnum.BEFORE_DELETE);
			this.executeAfterDelete   = (triggerType == SEPTriggerTypeEnum.AFTER_DELETE);
			this.executeAfterUndelete = (triggerType == SEPTriggerTypeEnum.AFTER_UNDELETE);
		}
		
		private void setDefaultTriggerType() { setTriggerType (DEFAULT_TRIGGER_TYPE); }
	}

	public static Case_Trigger_Strategy_Configuration__c create(Config config, TEST_DummyInsertModeEnum insertMode)
	{
		if (config.noTriggerTypeSet()) { config.setDefaultTriggerType(); }

		TEST_UniqueHelper unique = new TEST_UniqueHelper('Case Trigger Strategy');
		Case_Trigger_Strategy_Configuration__c dummyStrategyConfiguration = new Case_Trigger_Strategy_Configuration__c();
											   dummyStrategyConfiguration.name 						  = TEST_ConfigHelper.chooseValue(config.name, 						unique.uniqueString);
											   dummyStrategyConfiguration.Strategy_Apex_Class_Name__c = TEST_ConfigHelper.chooseValue(config.strategyApexClassName, 	DEFAULT_STRATEGY_NAME);
											   dummyStrategyConfiguration.Country_Code__c 			  = TEST_ConfigHelper.chooseValue(config.countryCode, 				DEFAULT_COUNTRY);
											   dummyStrategyConfiguration.Rank__c 					  = TEST_ConfigHelper.chooseValue(config.rank, 						DEFAULT_RANK);
											   dummyStrategyConfiguration.Is_Active__c 				  = TEST_ConfigHelper.chooseValue(config.isActive, 					true);
											   dummyStrategyConfiguration.Execute_Before_Insert__c 	  = TEST_ConfigHelper.chooseValue(config.executeBeforeInsert, 		false);
											   dummyStrategyConfiguration.Execute_After_Insert__c 	  = TEST_ConfigHelper.chooseValue(config.executeAfterInsert, 		false);
											   dummyStrategyConfiguration.Execute_Before_Update__c 	  = TEST_ConfigHelper.chooseValue(config.executeBeforeUpdate, 		false);
											   dummyStrategyConfiguration.Execute_After_Update__c 	  = TEST_ConfigHelper.chooseValue(config.executeAfterUpdate, 		false);
											   dummyStrategyConfiguration.Execute_Before_Delete__c 	  = TEST_ConfigHelper.chooseValue(config.executeBeforeDelete, 		false);
											   dummyStrategyConfiguration.Execute_After_Delete__c 	  = TEST_ConfigHelper.chooseValue(config.executeAfterDelete, 		false);
											   dummyStrategyConfiguration.Execute_After_Undelete__c   = TEST_ConfigHelper.chooseValue(config.executeAfterUndelete, 		false);
											   
        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  (        dummyStrategyConfiguration );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  { System.runAs(TEST_RUN_USER) { insert dummyStrategyConfiguration;  } }

		return dummyStrategyConfiguration;
	}

    public static Case_Trigger_Strategy_Configuration__c create (TEST_DummyInsertModeEnum insertMode) { return create (new Config(), insertMode);                    }
    public static Case_Trigger_Strategy_Configuration__c create ()                                    { return create (new Config(), TEST_DummyInsertModeEnum.NONE); }

    public static Case_Trigger_Strategy_Configuration__c create(SEPTriggerTypeEnum triggerType, TEST_DummyInsertModeEnum insertMode) { return create (new Config(triggerType), insertMode); }

    public static Case_Trigger_Strategy_Configuration__c create(String countryCode, String strategyApexClassName, SEPTriggerTypeEnum triggerType, TEST_DummyInsertModeEnum insertMode)    
    { 
        return create (new Config(countryCode, strategyApexClassName, triggerType), insertMode); 
    }

	
	// ------------------------------------------------------------------------------------------------------------------------------------
	
    public static List<Case_Trigger_Strategy_Configuration__c> createList (List<Config> configList, TEST_DummyInsertModeEnum insertMode)
	{
		List<Case_Trigger_Strategy_Configuration__c> dummyStrategyConfigurationList = new List<Case_Trigger_Strategy_Configuration__c>();

		for (Config config : configList)
		{
            dummyStrategyConfigurationList.add(create(config, TEST_DummyInsertModeEnum.NONE));
		}

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  (        dummyStrategyConfigurationList );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  { System.runAs(TEST_RUN_USER) { insert dummyStrategyConfigurationList;  } }
        
		return dummyStrategyConfigurationList;
	}
	
    public static List<Case_Trigger_Strategy_Configuration__c> createList (Integer numberOfConfigurations, TEST_DummyInsertModeEnum insertMode)
	{
		List<Config> configList = new List<Config>();

		for (Integer i=1; i<=numberOfConfigurations; i++)
		{
			Config config = new Config (DEFAULT_COUNTRY, DEFAULT_STRATEGY_CHAIN[i-1], DEFAULT_TRIGGER_TYPE);
				   config.rank = i;
			configList.add(config);
		}
		
        return createList (configList, insertMode);
	}
	
    public static List<Case_Trigger_Strategy_Configuration__c> createList(Boolean hasRankError, Boolean hasStrategyError, TEST_DummyInsertModeEnum insertMode)
	{
		// Note: If we need a rule not to allow multiple configurations with the same county and triggerType combination to reference the same
		// 		 Strategy, these configurations will need to be revised.
		Config config1 = new Config();
			   config1.rank = 1;
													   
		Config config2 = new Config();
			   config2.rank = (hasRankError) ? 1 : 2;

		Config config3 = new Config();
			   config3.rank = 3;
		if (hasStrategyError) { config3.strategyApexClassName = 'VeryNaughtyNonExistantStrategy'; }

		List<Config> configList = new List<Config> {config1, config2, config3};
        return createList(configList, insertMode);
	}
}