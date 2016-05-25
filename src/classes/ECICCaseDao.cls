public class ECICCaseDao 
{
    public static final Set<String> UNEXPORTED_STATUS_SET = new Set<String> { ECICCommonConstants.STATUS_NEW, ECICCommonConstants.STATUS_CANCELLED }; 
    
    public static Case findById(Id id) { return (Case) getFirstResult([SELECT id, CaseNumber, OwnerId, Status, Country_Code__c FROM Case WHERE id = :id LIMIT 1]); }
    
    @testVisible private static final Decimal CRISEXPORTLIMIT = (!Test.isRunningTest())
                                                                        ? General_Settings__c.getInstance().CRISExportLimit__c
                                                                        : 100;
    
    public static Map<Id, Case> findByIds(List<Id> idList) 
    {
        return new Map<Id, Case>([
                                    SELECT id, Status, IsClosed, Next_Open_Task_Reponsible_Lookup__c, RecordTypeId
                                    FROM Case 
                                    WHERE id IN :idList
                                ]);
    }
    
    /**
     * Search for user IDs in Cases' mapped user fields.
     */
    public static List<Case> findNotClosedByRegionAndMappedUserFields(Set<Id> userIdSet) 
    {
        Set<String>  caseFieldSet  = new Set<String>(ECICCommonConstants.USER_FIELDS);                  // Creates Set of Strings containing field names for Case User Lookup fields from common constants.
                     caseFieldSet.addAll(ECICCommonConstants.REGION_USER_FIELDS);                       // ... Then adds the fields for the Regional Users.

        List<String> conditionList = buildConditionList(userIdSet, caseFieldSet);                       // Creates a list of conditions for matching any of the collected fields against the submitted User Ids.
        
        // prepend ECICCommonConstants.SELECT_CASE width additional fields to query
        String query = ECICCommonConstants.SELECT_CASE.replaceFirst('select', 'select RecordTypeId, ')  // Creates a Case SOQL query from the above conditions; also including that the Case should be opened.
                        + ' where IsClosed = false'
                        + '     AND (' + String.join(conditionList, ' OR ') + ')';
        
        return Database.query(query);                                                                    // Returns selected Cases.
    }

    @testVisible private static List<String> buildConditionList(Set<Id> userIdSet, Set<String> caseFieldSet)
    {
        String commaDelimitedIdSetString = String.join(new List<Id>(userIdSet), '\'' + ECICCommonConstants.COMMA_DEL + '\'');
        
        List<String> conditionList = new List<String>();
        for (String field : caseFieldSet) 
        {
            conditionList.add( field + ' IN (\'' + commaDelimitedIdSetString + '\')' + ' OR ' + field + ' = null');
        }
        
        return conditionList;
    }

    /**
     * Search for Cases where region bottler and distributor fields need to be updated.
     */
    public static List<Case> findNotClosedByRegionOrPlantRegion(Set<Id> regionIdSet) 
    {
        Set<String> notOpenStatusSet = new Set<String>{ ECICCommonConstants.STATUS_NEW, ECICCommonConstants.STATUS_CANCELLED, ECICCommonConstants.STATUS_CLOSED }; 
        
        return [
                    SELECT id, region_of_purchase__c, plant__r.region__c,  
                        Bottler_External_Relations__c, Bottler_Quality_Manager__c, Bottler_Quality_Owner__c,
                        Distributor_External_Relations__c, Distributor_Quality__c, Distributor_Quality_Manager__c,
                        No_Quality_Status_Change__c,
                        RecordTypeId
                    FROM Case
                    WHERE   (       status NOT            IN :notOpenStatusSet )
                        AND (
                                   (Region_of_Purchase__c IN :regionIdSet)
                                OR (Plant__r.Region__c    IN :regionIdSet)
                            )
              ];
    }

    @testVisible private static SObject getFirstResult(SObject[] resultList) 
    { 
        return ((resultList != null) && (! resultList.isEmpty())) 
                   ? (resultList.get(0)) 
                   : (null); 
    }
    
    // ----------------------------------------------------------------------------------------------------------------------------------
    
    public static List<Case> selectCaseList(List<Closed_trend__c> definitionClosedTrendList) { return selectCaseList(buildCriteriaList(definitionClosedTrendList)); }
    
    @testVisible private static List<Case> selectCaseList(List<String> criteriaList)
    {
       return Database.query('SELECT country_code__c, reason, plant__c, createddate, casenumber, '
                            + ' product__c, product__r.type__c, product__r.product_description__c, ' 
                            + String.join(ECICCommonConstants.REGION_USER_FIELDS, ECICCommonConstants.COMMA_DEL) + ECICCommonConstants.COMMA_DEL
                            + String.join(ECICCommonConstants.USER_FIELDS, ECICCommonConstants.COMMA_DEL)
                        + ' FROM Case '
                        + ' WHERE recordTypeId IN ' + ECICCaseQualityComplaintRecordTypeHelper.QUALITY_COMPLAINT_SOQL_ID_SET  
                            + ' AND status NOT in (\'' + ECICCommonConstants.STATUS_NEW + '\', \'' + ECICCommonConstants.STATUS_CANCELLED + '\')'
                            + ' AND (' + String.join(criteriaList, ' OR ') + ')');    
    }

    @testVisible private static List<String> buildCriteriaList(List<Closed_trend__c> definitionClosedTrendList)
    {
        List<String> criteriaList = new List<String>();
        for (Closed_trend__c closedTrend : definitionClosedTrendList ) 
        {
            List<String> whereConditionList = buildWhereConditionList(closedTrend);
            criteriaList.add('(' + String.join(whereConditionList, ' AND ') + ')');
        }
        return criteriaList;      
    }
    
    @testVisible private static List<String> buildWhereConditionList(Closed_trend__c closedTrend)
    {
        List<String> whereConditionList = new List<String>();
        for (String caseField : ECICClosedTrendHelper.CASE_FIELD_BY_CLOSED_TREND_FIELDS_MAP.keySet()) 
        {
            String value = (String) closedTrend.get(caseField);

            if (String.isNotEmpty(value)) { whereConditionList.add(ECICClosedTrendHelper.CASE_FIELD_BY_CLOSED_TREND_FIELDS_MAP.get(caseField) + ' = \'' + value + '\''); }
        }
        return whereConditionList;
    }

    // ---------------------------------------------------------------------------------------------------------------------
    
    public static Map<String, List<Case>> selectRecentQualityComplaintCaseListByCountryCodeMap (List<String> caseFieldNameList, Set<String> countryCodeSet)
    {
        List<Case> caseList = selectRecentQualityComplaintCaseList(caseFieldNameList, countryCodeSet);
        
        Map<String, List<Case>> selectCaseListByCountryCodeMap = new Map<String, List<Case>>();
        for (Case currentCase : caseList)
        {
            String currentCountryCode = currentCase.country_code__c;
            if (!selectCaseListByCountryCodeMap.containsKey(currentCountryCode)) 
            { 
                selectCaseListByCountryCodeMap.put(currentCountryCode, new List<Case>()); 
            }
            selectCaseListByCountryCodeMap.get(currentCountryCode).add(currentCase);
        }
        
        return  selectCaseListByCountryCodeMap;
    } 
    
    @testVisible private static List<Case> selectRecentQualityComplaintCaseList(List<String> caseFieldNameList, Set<String> countryCodeSet)
    {
        Set<String> requiredFieldSet = new Set<String> 
        { 
            'id', 'account.id', 'account.account_ext_id__c', 'account.shipping_municipality__c',  'category_level3__c', 'category_level4__c', 
            'country_code__c', 'potential_risk__c', 'priority', 'region_of_purchase__r.name', 'risk_type__c' 
        };
        for (String fieldName : caseFieldNameList) { requiredFieldSet.add(fieldName.toLowerCase()); } // This removes duplicates from the list, which may be desired for export but is not allowed as such in SOQL query.
        
        Set<Id>     qualityComplaintRecordTypeIdSet = ECICCaseQualityComplaintRecordTypeHelper.QUALITY_COMPLAINT_ID_SET;

        String   queryString   = 'SELECT '
                                    + String.join(new List<String>(requiredFieldSet), ECICCommonConstants.COMMA_DEL)    // ... but then we must make the set iterable [again]
                              + ' FROM Case '
                              + ' WHERE country_code__c IN :countryCodeSet '  
                                    + ' AND recordTypeId    IN :qualityComplaintRecordTypeIdSet'
                                    + ' AND status NOT   IN :UNEXPORTED_STATUS_SET  '
                                    + ' AND ((legacy_info3__c = null) OR (legacy_info3__c = \'\'))'
                                    + ' ORDER BY CreatedDate LIMIT ' + String.valueOf(CRISEXPORTLIMIT.intValue()); // Can be set in Custom Settings -> General Settings -> CRISExportLimit

        return Database.query(queryString);
    }  
    
}