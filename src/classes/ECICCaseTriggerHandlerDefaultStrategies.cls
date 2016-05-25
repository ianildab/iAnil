public class ECICCaseTriggerHandlerDefaultStrategies 
{
    public static final List<SEPTriggerHandlerStrategy> ON_BEFORE_UPSERT_MANDATORY_STRATEGY_CHAIN_START = new List<SEPTriggerHandlerStrategy>
    {
        //#RecordType   
        // Country Code is Set
            new ECICCaseCountryCodeSetterStrategy(), 
        //    new ECICCaseCountryCodeValidatorStrategy(),
        // Record Type is Set
            //new ECICCaseRecordTypeChangeStrategy(),
            new ECICCaseTypeSetterStrategy()
    };

    public static final List<SEPTriggerHandlerStrategy> DEFAULT_BEFORE_INSERT_STRATEGY_CHAIN = new List<SEPTriggerHandlerStrategy>
    {
        // Validations are executed
            new ECICCaseValidateProdlineStrategy(),
            new ECICCaseChannelChangeValidationStrategy(),
            new ECICCaseQComplSampleCollValidatorStrat(),
        // Other business logic
            new ECICCaseCopyProductDetailsStrategy(),
            new ECICCaseAccountAndContactSetterStrategy(),
            new ECICCaseMulSetterStrategy(),
            new ECICCaseQComplaintStatusSetterStrategy(),
            new ECICCaseQualityStatusClosingStrategy(),
            new ECICCaseQualityCloseDateSetterStrategy(),
            new ECICCaseInfolineCloseDateSetterStrategy(),
            new ECICCaseQComplaintReopenStrategy(),
            new ECICCaseComplaintEscalationStrategy(),
            new ECICCaseHighPriorityIfHighRiskStrategy(),
            new ECICCaseInfolineStatusSetterStrategy(),
            new ECICCaseProductionCodeProcessingStrategy(),
            new ECICCaseQComplQualTechReasonsSetterStrat(),
            new ECICCaseQComplAnalysisLabSetterStrategy(),
            new ECICCaseQComplBottlerUserSetterStrategy(),
            new ECICCaseOwnerLookupSetterStrategy(),
            new ECICCaseComplaintVoucherStrategy(),
            new ECICCaseQComplBottlerNameSetterStrategy(),
            new ECICCaseQComplaintPOSSetterStrategy(),
            new ECICCaseNoQualityStatusChangeStrategy()
    };
        
    public static final List<SEPTriggerHandlerStrategy> DEFAULT_AFTER_INSERT_STRATEGY_CHAIN = new List<SEPTriggerHandlerStrategy>
    {
            new ECICCaseEmailMessageCreatorStrategy()   
    };

    public static final List<SEPTriggerHandlerStrategy> DEFAULT_BEFORE_UPDATE_STRATEGY_CHAIN = new List<SEPTriggerHandlerStrategy>
    {
        // Validations are executed
            new ECICCaseValidateProdlineStrategy(),
            new ECICCaseTasksOnCancelValidationStrategy(),
            new ECICCaseTasksOnCloseValidationStrategy(),
            new ECICCaseChannelChangeValidationStrategy(),
            new ECICCaseQComplSampleCollValidatorStrat(),
            new ECICCaseStatusValidationStrategy(),
        // Other business logic
            new ECICCaseCancelNotModifiedTasksStrategy(),
            new ECICCaseCopyProductDetailsStrategy(),
            new ECICCaseAccountAndContactSetterStrategy(),
            new ECICCaseMulSetterStrategy(),
            new ECICCaseQComplaintStatusSetterStrategy(),
            new ECICCaseReportDateSetterStrategy(),
            new ECICCaseQualityStatusClosingStrategy(),
            new ECICCaseQualityCloseDateSetterStrategy(),
            new ECICCaseInfolineCloseDateSetterStrategy(),
            new ECICCaseQComplaintReopenStrategy(),                
            new ECICCaseComplaintEscalationStrategy(),
            new ECICCaseHighPriorityIfHighRiskStrategy(),        
            new ECICCaseInfolineStatusSetterStrategy(),        
            new ECICCaseProductionCodeProcessingStrategy(),
            new ECICCaseTrendCleanupStrategy(),
            new ECICCaseQComplQualTechReasonsSetterStrat(),
            new ECICCaseQComplAnalysisLabSetterStrategy(),
            new ECICCaseQComplBottlerUserSetterStrategy(),        
            new ECICCasePreviousOwnerSetterStrategy(),
            new ECICCaseTaskAssignmentStrategy(),       // Bottler* and Distributor* fields may have been updated, check if action plan tasks should be reassigned
            new ECICCaseOwnerLookupSetterStrategy(),
            new ECICCaseComplaintVoucherStrategy(),
            new ECICCaseQComplBottlerNameSetterStrategy(),
            new ECICCaseQComplaintPOSSetterStrategy(),
            new ECICCaseNoQualityStatusChangeStrategy()    
    };
    
    public static final List<SEPTriggerHandlerStrategy> DEFAULT_AFTER_UPDATE_STRATEGY_CHAIN = new List<SEPTriggerHandlerStrategy>
    {
        
    };
    
    public static final List<SEPTriggerHandlerStrategy> DEFAULT_BEFORE_DELETE_STRATEGY_CHAIN = new List<SEPTriggerHandlerStrategy>
    {
        
    };
    
    public static final List<SEPTriggerHandlerStrategy> DEFAULT_AFTER_DELETE_STRATEGY_CHAIN = new List<SEPTriggerHandlerStrategy>
    {
        
    };
    
    public static final List<SEPTriggerHandlerStrategy> DEFAULT_AFTER_UNDELETE_STRATEGY_CHAIN = new List<SEPTriggerHandlerStrategy>
    {
        
    };


}