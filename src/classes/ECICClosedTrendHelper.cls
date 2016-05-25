global class ECICClosedTrendHelper  
{
    global static final Map<String,Id>      CLOSED_TREND_RECORD_TYPE_ID_BY_NAME_MAP = SEPRecordTypesCache.GetRecordTypeIdsByDeveloperNameMap(Closed_Trend__c.SObjectType);
    global static final ID                  CLOSED_TREND_DEFINITION_RT_ID           = CLOSED_TREND_RECORD_TYPE_ID_BY_NAME_MAP.get('Definition');
    global static final ID                  CLOSED_TREND_COLLECTION_RT_ID           = CLOSED_TREND_RECORD_TYPE_ID_BY_NAME_MAP.get('Collection');

    public static final String              NAME_PLACEHOLDER                      = '{0} {1} {2}';
    
    public static final Map<String, String> CASE_FIELD_BY_CLOSED_TREND_FIELDS_MAP = new Map<String, String>
        {
            'case_reason__c'            =>  'reason',
            'plant__c'                  =>  'plant__c',
            'type__c'                   =>  'product__r.type__c',
            'product_description__c'    =>  'product__r.product_description__c'
        };

	
    public static Boolean isMatched(Case currentCase, Closed_Trend__c closedTrend) 
    {
        String caseProductType        = ((currentCase.product__r.type__c                != null) || (!Test.isRunningTest())) ? currentCase.product__r.type__c                : TEST_MockHelper.getMockString(currentCase, 'product.type'); 
        String caseProductDescription = ((currentCase.product__r.product_description__c != null) || (!Test.isRunningTest())) ? currentCase.product__r.product_description__c : TEST_MockHelper.getMockString(currentCase, 'product.description'); 
        
        return  (
                       ( closedTrend.country_code_string__c.contains(currentCase.country_code__c)                 )
                    && ( isEqualOrFirstValueIsNull ( closedTrend.plant__c,               currentCase.plant__c   ) )
                    && ( isEqualOrFirstValueIsNull ( closedTrend.case_reason__c,         currentCase.reason     ) )
                    && ( isEqualOrFirstValueIsNull ( closedTrend.type__c,                caseProductType        ) )
                    && ( isEqualOrFirstValueIsNull ( closedTrend.product_description__c, caseProductDescription ) )
                );
    }
    
    public static Boolean isEqualOrFirstValueIsNull (String firstValue, String secondValue) { return ((firstValue == null) || (firstValue == secondValue)); }

    public static Boolean isCaseBetweenClosedTrendDates (Case currentCase, Closed_Trend__c closedTrend, Datetime toDatetime) 
    {
        Datetime fromDatetime = toDatetime.addDays(-Integer.valueOf(closedTrend.period__c));
        return (currentCase.createddate > fromDatetime) && (currentCase.createddate < toDatetime);
    }

    // ---------------------------------------------------------------------------------------------------------------------
    
    // @author       Natallia Bahlai (Natallia_Bahlai@epam.com)
    public static Closed_Trend_Case__c createClosedTrendCase(Case currentCase, Closed_Trend__c closedTrend) 
    {
        Closed_Trend_Case__c closedTrendCase = new Closed_Trend_Case__c();
                             closedTrendCase.case__c         = currentCase.id;
                             closedTrendCase.case__r         = currentCase;
                             closedTrendCase.closed_trend__c = closedTrend.id;
                             closedTrendCase.name            = closedTrend.name + ' / ' + currentCase.casenumber;
                      return closedTrendCase;
    }
    
    public static List<Closed_Trend_Case__c> createClosedTrendCaseList(List<Case> childCaseList, Closed_Trend__c clonedClosedTrend)
    {
        List<Closed_Trend_Case__c> closedTrendCaseList = new List<Closed_Trend_Case__c>();  
        for (Case currentCase : childCaseList)  
        { 
            closedTrendCaseList.add(createClosedTrendcase(currentCase, clonedClosedTrend)); 
        }
        return closedTrendCaseList; 
    }

    public static Closed_Trend__c createClosedTrendClone(Closed_Trend__c closedTrend, String analyzedPeriod)
    {
        Closed_Trend__c clonedClosedTrend = closedTrend.clone(false, true, false, false);
                        clonedClosedTrend.recordtypeId       = ECICClosedTrendHelper.CLOSED_TREND_COLLECTION_RT_ID;
                        clonedClosedTrend.country_code__c    = closedTrend.country_code__c;
                        clonedClosedTrend.subject__c         = closedTrend.subject__c;
                        clonedClosedTrend.additional_to__c   = closedTrend.additional_to__c;
                        clonedClosedTrend.analyzed_period__c = analyzedPeriod ;
                        clonedClosedTrend.name               = String.format(NAME_PLACEHOLDER, new String[]{closedTrend.name, ' ', analyzedPeriod});
                 return clonedClosedTrend;
    }
    

}