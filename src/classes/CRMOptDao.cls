public /* with sharing */ class CRMOptDao {

    // Collect all the Opts with the associated ids from the given set
    public static Map<String, Opt__c> findByUniqueName(Set<String> optUniqueNames)
    {
        Map<String, Opt__c> result = new Map<String, Opt__c>();
        
        List<Opt__c> opts = [SELECT Id, Opt_Unique_Name__c, Generated_3Digit_Number__c FROM Opt__c WHERE Opt_Unique_Name__c IN :optUniqueNames];
        for(Opt__c o : opts) {
            result.put(o.Opt_Unique_Name__c, o);
        }
        
        return result;
    }

}