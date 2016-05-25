public Class HUB_TriggerCaseListSeparate{
    public static List<Case> hubCases = new List<Case>();
    public static List<Case> nonHubCases = new List<Case>();
    private static String hubRecordTypeId;
    
    public static void identifyAndDivideCases(List<Case> allTriggerCases){
        getHubRecordTypeId();
        if(allTriggerCases == null){
            return;
        }
        for(Case currentCase : allTriggerCases){
            if(!String.isBlank(hubRecordTypeId) && hubRecordTypeId.equals(currentCase.recordTypeId)){
                hubCases.add(currentCase);
            }
            else{
                nonHubCases.add(currentCase);
            }
        }
    }
    
    
    private static void getHubRecordTypeId(){
        RecordType hubRecordType =  ECICCaseTriggerRegionCache.getRecordType(ECICCommonConstants.RECORDTYPE_BY_DEVELOPERNAME_EQUAL,'Issue_Tracker').Values();
        // [SELECT id FROM RecordType WHERE developerName = 'Issue_Tracker'];
        hubRecordTypeId = hubRecordType != null ? hubRecordType.id : '';
    }
}