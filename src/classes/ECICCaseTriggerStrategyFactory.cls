public class ECICCaseTriggerStrategyFactory 
{
    private final static Map<String, List<SEPTriggerHandlerStrategy>> CASE_TRIGGER_STRATEGY_CACHE;
    private final static Map<String, Set<String>>					  STRATEGY_REQUIRED_FOR_COUNTRY_TRIGGERS_MAP = new Map<String, Set<String>>(); 

    private final static Map<SEPTriggerTypeEnum, Set<String>>		  COUNTRY_CODE_SET_BY_TRIGGER_TYPE_MAP = new Map<SEPTriggerTypeEnum, Set<String>>
    {
    	SEPTriggerTypeEnum.BEFORE_INSERT 	=> new Set<String>(),
    	SEPTriggerTypeEnum.AFTER_INSERT 	=> new Set<String>(),
    	SEPTriggerTypeEnum.BEFORE_UPDATE 	=> new Set<String>(),
    	SEPTriggerTypeEnum.AFTER_UPDATE 	=> new Set<String>(),
    	SEPTriggerTypeEnum.BEFORE_DELETE 	=> new Set<String>(),
    	SEPTriggerTypeEnum.AFTER_DELETE 	=> new Set<String>(),
    	SEPTriggerTypeEnum.AFTER_UNDELETE 	=> new Set<String>()
    };
    
    
    @testVisible private static List<String> errorLogList = new List<String>();
    
    static
    {
    	if (CASE_TRIGGER_STRATEGY_CACHE == null) 
    	{ 
    		CASE_TRIGGER_STRATEGY_CACHE = createCaseTriggerStrategyMap(); 
    	}

		if (!errorLogList.isEmpty())
		{
			throw new ECICCaseTriggerStrategyConfigException (errorLogList); 
		} 

    }

    public static List<SEPTriggerHandlerStrategy> getStrategyList(SEPTriggerTypeEnum triggerType, String countryCode) 
    {
		return CASE_TRIGGER_STRATEGY_CACHE.get( countryCode + triggerType.name() ); 							// Return the value
	}
	
	public static Set<String> getCountryCodeTriggerSet()
	{
		return CASE_TRIGGER_STRATEGY_CACHE.keySet();
	}
	
	public static Set<String> getCountryCodeSet(SEPTriggerTypeEnum triggerType)
	{
		return COUNTRY_CODE_SET_BY_TRIGGER_TYPE_MAP.get(triggerType);
	}

	public static Set<String> getCountryCodeSet()
	{
		Set<String> completeCountryCodeSet = new Set<String>();
		for (Set<String> countryCodeSet : COUNTRY_CODE_SET_BY_TRIGGER_TYPE_MAP.values())
		{
			completeCountryCodeSet.addAll(countryCodeSet); 
		}
	    return completeCountryCodeSet;
	}
	
	
	public static Boolean hasStrategyChain (SEPTriggerTypeEnum triggerType, String countryCode)
	{
		return getCountryCodeSet(triggerType).contains(countryCode);
	}
	
	public static Boolean hasStrategyChain (String countryCode)
	{
		return getCountryCodeSet().contains(countryCode);
	}
	
	public static Boolean isStrategyRequired (String strategyName, SEPTriggerTypeEnum triggerType, Set<String> countryCodeSet)
	{
		Boolean countryCodeSetIncludesOther = false;
		for (String countryCode : countryCodeSet)
		{
			if  (!hasStrategyChain(countryCode)) { countryCodeSetIncludesOther =  true; }
			String uniqueKey   = countryCode + triggerType.name();
			if (
					   (STRATEGY_REQUIRED_FOR_COUNTRY_TRIGGERS_MAP.containsKey(strategyName))
					&& (STRATEGY_REQUIRED_FOR_COUNTRY_TRIGGERS_MAP.get(strategyName).contains(uniqueKey))
			   ) 
			{ 
				return true; 
			}
		}
		
		if  ((countryCodeSetIncludesOther)  &&  (isStrategyRequiredByDefault (strategyName, triggerType)) ) { return true; }

		return false;
	}
	
	private static Boolean isStrategyRequiredByDefault (String strategyName, SEPTriggerTypeEnum triggerType)
	{
		List<SEPTriggerHandlerStrategy> strategyChainList = ECICCaseTriggerHandlerHelper.selectStrategyChainList(triggerType, 'OTHER');
		for (SEPTriggerHandlerStrategy strategy : strategyChainList)
		{
			if (getClassName(strategy) == strategyName) { return true; }
		}
		return false;
	}
	
	
	@testVisible private static Map<String, List<SEPTriggerHandlerStrategy>> createCaseTriggerStrategyMap ()
	{
		List<SEPTriggerHandlerStrategy> triggerHandlerStrategyList = new List<SEPTriggerHandlerStrategy>();
		List<Case_Trigger_Strategy_Configuration__c> completeStrategyConfigurationList = Case_Trigger_Strategy_Configuration__c.getAll().values(); 
		Map<String, Map<Integer, Case_Trigger_Strategy_Configuration__c>> strategyConfigurationByRankByCountryTriggerTypeMap = createStrategyConfigurationByRankByCountryTriggerTypeMap(completeStrategyConfigurationList);
		return convertConfigMapToStrategyListMap (strategyConfigurationByRankByCountryTriggerTypeMap);
	}
		
	@testVisible private static Map<String, Map<Integer, Case_Trigger_Strategy_Configuration__c>> createStrategyConfigurationByRankByCountryTriggerTypeMap (List<Case_Trigger_Strategy_Configuration__c> completeStrategyConfigurationList)
	{
		Map<String, Map<Integer, Case_Trigger_Strategy_Configuration__c>> strategyConfigurationByRankByCountryTriggerTypeMap = new Map<String, Map<Integer, Case_Trigger_Strategy_Configuration__c>>();
		for (Case_Trigger_Strategy_Configuration__c config : completeStrategyConfigurationList)
		{
			for (Integer triggerTypeEnum=0; triggerTypeEnum < SEPTriggerTypeEnum.values().size(); triggerTypeEnum++)
			{
				SEPTriggerTypeEnum triggerType 		= SEPTriggerTypeEnum.values()[triggerTypeEnum];
				String			   triggerTypeName 	= triggerType.name();
				String triggerTypeField = 'Execute_' + triggerTypeName + '__c';
				if ((Boolean) config.get(triggerTypeField))
				{
					String countryCode = config.country_code__c;
					String uniqueKey   = countryCode + triggerTypeName;
					if (!strategyConfigurationByRankByCountryTriggerTypeMap.keySet().contains(uniqueKey)) 
					{ 
						strategyConfigurationByRankByCountryTriggerTypeMap.put(uniqueKey, new Map<Integer, Case_Trigger_Strategy_Configuration__c>()); 
					}
					COUNTRY_CODE_SET_BY_TRIGGER_TYPE_MAP.get(triggerType).add(countryCode);
					mapStrategyConfigurationByRank (strategyConfigurationByRankByCountryTriggerTypeMap, config, uniqueKey, countryCode, triggerTypeName);
					
					if (!STRATEGY_REQUIRED_FOR_COUNTRY_TRIGGERS_MAP.containsKey(config.Strategy_Apex_Class_Name__c))
					{
							STRATEGY_REQUIRED_FOR_COUNTRY_TRIGGERS_MAP.put (config.Strategy_Apex_Class_Name__c, new Set<String>()); 
					}
					STRATEGY_REQUIRED_FOR_COUNTRY_TRIGGERS_MAP.get(config.Strategy_Apex_Class_Name__c).add(uniquekey);
				}
			}			
		}
		return 	strategyConfigurationByRankByCountryTriggerTypeMap;
	}
		
	@testVisible private static void mapStrategyConfigurationByRank (
				Map<String, Map<Integer, Case_Trigger_Strategy_Configuration__c>> strategyConfigurationByRankByCountryTriggerTypeMap,
				Case_Trigger_Strategy_Configuration__c config, String uniqueKey, String countryCode, String triggerTypeName
			)
	{
		Map<Integer, Case_Trigger_Strategy_Configuration__c> strategyConfigurationByRankMap = strategyConfigurationByRankByCountryTriggerTypeMap.get(uniqueKey);
		Integer 											 configRank 					= (Integer) config.rank__c;		
		
		if (!strategyConfigurationByRankMap.keySet().contains(configRank))
		{
			strategyConfigurationByRankMap.put(configRank, config);
		}
		else
		{
			addError(
						  'Country code "' 					  + countryCode 									+ '"'
						+ ' with trigger type "' 			  + triggerTypeName 								+ '"' 
						+ ' has multiple instances of rank "' + configRank 										+ '"'
						+ ' including both "'                 + strategyConfigurationByRankMap.get(configRank) 	+ '"'
						+ ' and "' 							  + config 											+ '".'
					); 
		}
	}
	
	@testVisible private static Map<String, List<SEPTriggerHandlerStrategy>> convertConfigMapToStrategyListMap (Map<String, Map<Integer, Case_Trigger_Strategy_Configuration__c>> strategyConfigurationByRankByCountryTriggerTypeMap)
	{
		Map<String, List<SEPTriggerHandlerStrategy>> strategyListMap = new Map<String, List<SEPTriggerHandlerStrategy>>();
		
		for (String countryCodeTriggerTypeKey : strategyConfigurationByRankByCountryTriggerTypeMap.keySet())
		{
			List<SEPTriggerHandlerStrategy> countryCodeTriggerTypeStrategyList = new List<SEPTriggerHandlerStrategy>(); 
			
			Map<Integer, Case_Trigger_Strategy_Configuration__c> strategyConfigurationByRank = strategyConfigurationByRankByCountryTriggerTypeMap.get(countryCodeTriggerTypeKey);
			
			List<Integer> rankList = new List<Integer>(strategyConfigurationByRank.keySet());
						  rankList.sort(); 
			for (Integer rank : rankList)
			{
				countryCodeTriggerTypeStrategyList.add(convertStrategy(strategyConfigurationByRank, countryCodeTriggerTypeKey, rank));
			}
			strategyListMap.put (countryCodeTriggerTypeKey, countryCodeTriggerTypeStrategyList);
		}
		return strategyListMap;
	}
	
	@testVisible private static SEPTriggerHandlerStrategy convertStrategy(Map<Integer, Case_Trigger_Strategy_Configuration__c> strategyConfigurationByRank, String countryCodeTriggerTypeKey, Integer rank)
	{
		String strategyName = strategyConfigurationByRank.get(rank).Strategy_Apex_Class_Name__c;
		Type 						namedType = Type.forName(strategyName);
		
		if (namedType != null)
		{
			return (SEPTriggerHandlerStrategy) namedType.newInstance();
		}
		else
		{
			addError(
						  'Country code "' 					  + countryCodeTriggerTypeKey.left(2) 										+ '"'
						+ ' with trigger type "' 			  + countryCodeTriggerTypeKey.right(countryCodeTriggerTypeKey.length() - 2) + '"' 
						+ ' with rank "' 					  + rank 																	+ '"' 
						+ ' contains invalid strategy name "' + strategyName 															+ '".'
					);
		}

		return null;
	}
	
	@testVisible private static void addError(String errorMessage)
	{
			errorLogList.add(errorMessage);
			System.debug(LoggingLevel.ERROR, '!!!!!!!!! ' + errorMessage);
	}
	
	private static String getClassName (SEPTriggerHandlerStrategy strategyClass)
	{
		return String.valueOf(strategyClass).split(':')[0];
	}
	
}