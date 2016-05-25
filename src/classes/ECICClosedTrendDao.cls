public class ECICClosedTrendDao 
{
    public static List<Closed_Trend__c> selectDefinitionClosedTrendList()
    {
        return [
                    SELECT Name, ownerId, Active__c, country_code__c, Country_code_string__c, Language__c, additional_to__c , 
                        Subject__c, Recipients__c, Period__c, threshold__c, Plant__c, case_reason__c, Type__c, 
                        Product_description__c 
                    FROM Closed_trend__c 
                    WHERE active__c = true
                        AND recordTypeId = :ECICClosedTrendHelper.CLOSED_TREND_DEFINITION_RT_ID
                ];
    }


}