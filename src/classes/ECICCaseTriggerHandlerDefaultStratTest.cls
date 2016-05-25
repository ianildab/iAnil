/**
 * NOTE: ECICCaseTriggerHandlerDefaultStrategies contains NO methods to test.
 *
 * In the medium to long term, it may be changed to a test class or completely deleted.
 *
 * In the short term, only "process tests" should fail if this class is modified.
 * Any process tests which do fail, might be improved by explicitly listing the Strategies which they require to pass.
 *
 * This class just exists to make sure its contents have coverage, however it also provides regression testing 
 * against any modifications to the ON_BEFORE_UPSERT_MANDATORY_STRATEGY_CHAIN_START, which contains essential
 * prerequisits for many other strategies.
 *
 **/
@isTest
private class ECICCaseTriggerHandlerDefaultStratTest 
{
     private static testMethod void mandatoryListTest()
     {
        List<SEPTriggerHandlerStrategy> onBeforeUpsertMandatoryStrategyChain = ECICCaseTriggerHandlerDefaultStrategies.ON_BEFORE_UPSERT_MANDATORY_STRATEGY_CHAIN_START;
        
        // We check this because these Strategies are prerequisites for most processing which may follow.
        System.assert (isStrategyRequired('ECICCaseCountryCodeSetterStrategy', onBeforeUpsertMandatoryStrategyChain));
        //System.assert (isStrategyRequired('ECICCaseCountryCodeValidatorStrategy', onBeforeUpsertMandatoryStrategyChain));
        //System.assert (isStrategyRequired('ECICCaseRecordTypeChangeStrategy', onBeforeUpsertMandatoryStrategyChain));
        System.assert (isStrategyRequired('ECICCaseTypeSetterStrategy', onBeforeUpsertMandatoryStrategyChain));
     }

    private static Boolean isStrategyRequired (String strategyName, List<SEPTriggerHandlerStrategy> strategyChainList)
    {
        for (SEPTriggerHandlerStrategy strategy : strategyChainList)
        {
            if (getClassName(strategy) == strategyName) { return true; }
        }
        return false;
    }

    private static String getClassName (SEPTriggerHandlerStrategy strategyClass)
    {
        return String.valueOf(strategyClass).split(':')[0];
    }

	 private static testMethod void defaultListsTest()
     {
        List<SEPTriggerHandlerStrategy> defaultBeforeInsertStrategyChain   = ECICCaseTriggerHandlerDefaultStrategies.DEFAULT_BEFORE_INSERT_STRATEGY_CHAIN;
        List<SEPTriggerHandlerStrategy> defaultAfterInsertStrategyChain    = ECICCaseTriggerHandlerDefaultStrategies.DEFAULT_AFTER_INSERT_STRATEGY_CHAIN;
        List<SEPTriggerHandlerStrategy> defaultBeforeUpdateStrategyChain   = ECICCaseTriggerHandlerDefaultStrategies.DEFAULT_BEFORE_UPDATE_STRATEGY_CHAIN;
        List<SEPTriggerHandlerStrategy> defaultAfterUpdateStrategyChain    = ECICCaseTriggerHandlerDefaultStrategies.DEFAULT_AFTER_UPDATE_STRATEGY_CHAIN;
        List<SEPTriggerHandlerStrategy> defaultBeforeDeleteStrategyChain   = ECICCaseTriggerHandlerDefaultStrategies.DEFAULT_BEFORE_DELETE_STRATEGY_CHAIN;
        List<SEPTriggerHandlerStrategy> defaultAfterDeleteStrategyChain    = ECICCaseTriggerHandlerDefaultStrategies.DEFAULT_AFTER_DELETE_STRATEGY_CHAIN;
        List<SEPTriggerHandlerStrategy> defaultAfterUndeleteStrategyChain  = ECICCaseTriggerHandlerDefaultStrategies.DEFAULT_AFTER_UNDELETE_STRATEGY_CHAIN;
        
     } 

}