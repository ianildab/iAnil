public class SABU_ReplaceSampleCollector {
    private static List<Sample_Collector__c> sampleCollector = new List<Sample_Collector__c>();
    private static List<CaseTeamMember> caseteammembers = new List<CaseTeamMember>();
    private static List<Case> cases = new List<Case>();
    //private static Map<Id, Id> casesAndCaseTeams;
    
    public static void replaceSampleCollectorAfterInsert(List<SABU_Replace_Sample_Collector__c> newValues){
        SABU_Replace_Sample_Collector__c  replaceSC = newValues.get(0);
        //Sample_Collector__c sampleCollector1 ;
        
        SABU_Replace_Sample_Collector__c u = [select User_To_Be_Replaced__r.Enabled_Countries__c ,User_Who_Will_Replace__r.Country_Code__c from SABU_Replace_Sample_Collector__c where id = : replaceSC.Id];        
        List<Sample_Collector__c> sampleC = [select id, name,User__r.Id ,User__r.Name, User__r.Country_Code__c , User__r.IsPortalEnabled, User__r.ContactId from Sample_Collector__c where User__r.Id = : replaceSC.User_To_Be_Replaced__c]; 
        //System.debug('**'+ u);
        if(sampleC.size() == 0){
            replaceSC.addError('There is no sample collector present with this User.');
        }
        else{
        	for(Sample_Collector__c sc : sampleC )
        	{
                if( (u.User_To_Be_Replaced__r.Enabled_Countries__c != null) ||(u.User_Who_Will_Replace__r.Country_Code__c != null ) && (u.User_To_Be_Replaced__r.Enabled_Countries__c).Contains(u.User_Who_Will_Replace__r.Country_Code__c )){
                	sc.User__c = replaceSC.User_Who_Will_Replace__c;
            		sampleCollector.add(sc);      
                }   
                else{
                    
                    replaceSC.addError('User should be from same Business Unit');
                }
        	}
        }     
        update sampleCollector;  
        
    }
}