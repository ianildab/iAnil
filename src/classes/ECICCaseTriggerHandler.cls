/**
 *  TODO:  Create and implement Strategies to replace: 
 *          1. ECICActionPlanHelper
 *          2. ECICLinkCaseAndOpenAlertsHandler
 *          3. ECICTrendTracker
 **/
   
public class ECICCaseTriggerHandler extends SEPTriggerHandlerAbstract 
{
    public ECICCaseTriggerHandler (boolean isTriggerExecuting){ super(isTriggerExecuting); }
    
    public override void OnBeforeInsert(List<sObject> newValues) 
    {
        if (!executeStrategyChain(SEPTriggerTypeEnum.BEFORE_INSERT, (List<Case>)newValues, null, null)) { return; }
        
        // TODO: Consider integrating ECICCaseTriggerTaskCache.cls with invoked ActionPlanHelper method.
        ECICActionPlanHelper.process(newValues, null);
        ECICTrendTracker.onBefore((List<Case>)newValues, null, null, null);
    }

    public override void OnAfterInsert(List<sObject> newValues, Map<ID, sObject> newValuesMap) 
    {
        // TODO: Consider integrating ECICCaseTriggerTaskCache.cls with invoked ActionPlanHelper method.
        ECICActionPlanHelper.processAPTasksOnCaseInsert((List<Case>) newValues);

        // TODO: Consider implementing a Cache for Open_Alert_Case__c to integrate with invoked ECICLinkCaseAndOpenAlertsHandler method.
        ECICLinkCaseAndOpenAlertsHandler.linkCasesAndOpenAlerts(newValues, newValuesMap.keySet());   
        
        if (!executeStrategyChain(SEPTriggerTypeEnum.AFTER_INSERT, (List<Case>) newValues, null, (Map<ID, Case>) newValuesMap)) { return; }
        ECICTrendTracker.onAfter((List<Case>) newValues, null, (Map<ID, Case>) newValuesMap, null);
    }
        
    public override void OnBeforeUpdate(List<sObject> oldValues, List<sObject> newValues, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) 
    {
        if (! executeStrategyChain(SEPTriggerTypeEnum.BEFORE_UPDATE, (List<Case>) newValues, (Map<ID, Case>)oldValuesMap, (Map<ID, Case>)newValuesMap) ) { return; }

        // TODO: Consider integrating ECICCaseTriggerTaskCache.cls with invoked ActionPlanHelper method.
        ECICActionPlanHelper.process((List<Case>) newValues, (Map<ID, Case>)oldValuesMap);
        ECICTrendTracker.onBefore((List<Case>) newValues, (List<Case>) oldValues, (Map<ID, Case>)newValuesMap, (Map<ID, Case>)oldValuesMap);
    }
    
    public override void OnAfterUpdate(List<sObject> oldValues, List<sObject> newValues, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) 
    {
        // TODO: Consider implementing a Cache for Open_Alert_Case__c to integrate with invoked ECICLinkCaseAndOpenAlertsHandler method.
        ECICLinkCaseAndOpenAlertsHandler.linkCasesAndOpenAlerts(newValues, newValuesMap.keySet());    

        executeStrategyChain(SEPTriggerTypeEnum.AFTER_UPDATE, (List<Case>) newValues, (Map<ID, Case>)oldValuesMap, (Map<ID, Case>)newValuesMap);
        ECICTrendTracker.onAfter((List<Case>) newValues, (List<Case>) oldValues, (Map<ID, Case>)newValuesMap, (Map<ID, Case>)oldValuesMap);
    }
    
    public override void OnBeforeDelete(List<sObject> oldValues, Map<ID, sObject> oldValuesMap) 
    {
        /*
            Intentionally putting oldValues parameters into newCase parameters because otherwise, 
            in order to handle country strategies correctly,
            we need to create conditional logic which ultimately will have the same effect.
         */
        executeStrategyChain(SEPTriggerTypeEnum.BEFORE_DELETE, (List<Case>) oldValues, (Map<ID, Case>) oldValuesMap, null);  
    }

    public override void OnAfterDelete(List<sObject> oldValues, Map<ID, sObject> oldValuesMap) 
    {
        /*
            Intentionally putting oldValues parameters into newCase parameters because otherwise, 
            in order to handle country strategies correctly,
            we need to create conditional logic which ultimately will have the same effect.
         */
        executeStrategyChain(SEPTriggerTypeEnum.AFTER_DELETE, (List<Case>) oldValues, (Map<ID, Case>) oldValuesMap, null);
    }

    public override void OnAfterUndelete(List<sObject> newValues, Map<ID, sObject> newValuesMap) 
    {
        executeStrategyChain(SEPTriggerTypeEnum.AFTER_UNDELETE, (List<Case>) newValues, null, (Map<ID, Case>) newValuesMap);
    }

    //----------------------------------------------------------------------------------------------------------------------------------
    
    // "New" values are herein called "current" for the sake of Delete triggers whose old values are the "current" ones which need to be processed.
    @testVisible private boolean executeStrategyChain(SEPTriggerTypeEnum triggerType, List<Case> currentCaseList, Map<ID, Case> oldCaseByIdMap, Map<ID, Case> newCaseByIdMap) 
    {
        Map<ID, Case> currentCaseByIdMap = ((new Set<SEPTriggerTypeEnum>{SEPTriggerTypeEnum.BEFORE_DELETE, SEPTriggerTypeEnum.AFTER_DELETE}).contains(triggerType))
                            ? oldCaseByIdMap
                            : newCaseByIdMap;
        
        if ((new Set<SEPTriggerTypeEnum>{SEPTriggerTypeEnum.BEFORE_INSERT, SEPTriggerTypeEnum.BEFORE_UPDATE}).contains(triggerType))
        {
            ECICCaseTriggerUserCache.populate (currentCaseList);    
        }
        
        Boolean successExecution = ECICCaseTriggerHandlerHelper.doMandatoryStrategies(triggerType, currentCaseList, oldCaseByIdMap, currentCaseByIdMap) ; 
        if (! successExecution) { return false; } // break on failed execution
        
        return ECICCaseTriggerHandlerHelper.doCountrySpecificStrategies(triggerType, currentCaseList, oldCaseByIdMap, currentCaseByIdMap);
    }
    
}