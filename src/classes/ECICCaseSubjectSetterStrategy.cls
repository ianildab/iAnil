public /*with sharing*/ class ECICCaseSubjectSetterStrategy extends SEPTriggerHandlerStrategyAbstract {// commenting this whole class since we are not using this strategy.
    /* comment block 1 start private static List<String> caseCategoryFields = new List<String>{
                                                        'Category_Level4__c','Category_Level3__c','Reason','Type'};
    private static Map<String, List<Schema.PicklistEntry>> picklistMap = initializePicklistMap();
    
    public override boolean OnBeforeInsert(List<sObject> newValues) {
        execute(null, (List<Case>)newValues);
        
        return true;
    }
    
    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        execute((Map<ID, Case>)oldValuesMap, (List<Case>)newValuesMap.values());
        
        return true;
    }
    
    @testVisible
    private void execute(Map<Id, Case> oldCaseMap, List<Case> casesList) {
        String currentUserLang                          = UserInfo.getLanguage().split('_')[0].toLowerCase();
        
        for (Case currentCase : casesList) {
            Case oldCase                                        = (oldCaseMap != null) ? oldCaseMap.get(currentCase.id) : null;
            Country_Specific_Settings__c countrySettings        = Country_Specific_Settings__c.getValues(currentCase.Country_code__c);
            Set<String> allowedLanguages                        = convertListToSet(countrySettings.Allowed_Languages__c.split(';'));

            // Save original Case.Subject to Case.Description (email2case, web2case only) when the agent assigns the case to himself
            // CIC-1658 - https://tcccdiam.atlassian.net/browse/CIC-1658
            if (   oldCase != null
                && ECICCaseHelper.isQueueId(oldCase.OwnerId)
                && ECICCaseHelper.isUserId(currentCase.OwnerId)
                && (currentCase.Origin == 'Email'
                    || currentCase.Origin == 'Web')) { 
                    
                currentCase.Description = oldCase.Subject + '\n\n' + currentCase.Description;
            }

            // Update Case.Subject if classification changes
            if (   ECICCaseHelper.isUserId(currentCase.OwnerId)
                && allowedLanguages.contains(currentUserLang)
                && (oldCase == null // case is inserted
                    || isAnyCategoryChanged(oldCase, currentCase))) {

                currentCase.subject = getLocalizedLabel(getDeepestCategoryValue(currentCase));
            }
        }
    }
    
    private String getLocalizedLabel(Map<String, String> deepestCategoryValueMap) {
        String returnLabel      = null;
        
        if (!deepestCategoryValueMap.isEmpty()) {
            String fieldName        = new List<String>(deepestCategoryValueMap.keySet()).get(0);
            String picklistValue    = deepestCategoryValueMap.get(fieldName);
            returnLabel             = searchTranslatedValue(fieldName, picklistValue);
        }
        
        return returnLabel;
    }
    
    private String searchTranslatedValue(String fieldName, String picklistValue) {
        String searchResultLabel = null;
        
        for(Schema.PicklistEntry fieldPicklistValue : picklistMap.get(fieldName)) {
            if(fieldPicklistValue.getValue() == picklistValue) {
                searchResultLabel = fieldPicklistValue.getLabel();
                break;
            }
        }
        
        return searchResultLabel;
    }
    
    private Boolean isAnyCategoryChanged(Case oldCase, Case currentCase) {
        Boolean isChanged = false;
        
        for (String fieldAPIName : caseCategoryFields) {
            if((String) currentCase.get(fieldAPIName) != (String) oldCase.get(fieldAPIName)) {
                isChanged = true;
                break;
            }
        }
        
        return isChanged;
    }
    
    private Map<String, String> getDeepestCategoryValue(Case currentCase) {
        Map<String, String> resultMap   = new Map<String, String>();
        
        for (String fieldAPIName : caseCategoryFields) {
            String fieldValue = (String) currentCase.get(fieldAPIName);
            
            if(String.isNotBlank(fieldValue)) {
                resultMap.put(fieldAPIName, fieldValue);
                break;
            }
        }
        
        return resultMap;
    } comment block 1 end*/
    
    /**
     * Because SFDC don't provide any API for access to Translation Workbech via Apex
     * we have to use workaround for getting translated picklist values via Apex Describe Information
     * and PicklistEntry Class.
     */
    /* comment block 2 start private static Map<String, List<Schema.PicklistEntry>> initializePicklistMap() {
        Map<String, List<Schema.PicklistEntry>> picklistEntryMap    = new Map<String, List<Schema.PicklistEntry>>();
        Map<String, Schema.SObjectField> caseFieldsMap              = Schema.SObjectType.Case.fields.getMap();
        
        for (String fieldAPIName : caseCategoryFields) {
            List<Schema.PicklistEntry> pickListValues = caseFieldsMap.get(fieldAPIName).getDescribe().getPicklistValues();
            picklistEntryMap.put(fieldAPIName, pickListValues);
        }
        
        return picklistEntryMap;
    }
    
    private Set<String> convertListToSet(List<String> stringList) {
        Set<String> convertedSet = new Set<String>();
        
        for(String str : stringList) {
            convertedSet.add(str.toLowerCase());
        }
        
        return convertedSet;
    } comment block 2 end */
}