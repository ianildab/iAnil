public class ECICLinkCaseAndOpenAlertsConfigEntry  
{
    public Id id ;
    public sObject obj;
     
    public List<String> args = new List<String>(); 
    public void setArgs(List<String> args) { this.args = args; }
    public List<String> getArgs()          { return args;      }
    
    public ECICLinkCaseAndOpenAlertsConfigEntry (sObject obj) 
    {
        this.obj = obj;
        this.id = obj.id;
    }

    // Must not cast Open_Alert__c to SObject before sending to getConfig() method or method will fail.
    public static List<ECICLinkCaseAndOpenAlertsConfigEntry> getConfigs(List<sObject> sObjectList) 
    {
        List<ECICLinkCaseAndOpenAlertsConfigEntry> objECICLinkCaseAndOpenAlertsConfigEntryList = new List<ECICLinkCaseAndOpenAlertsConfigEntry>();
        Boolean           isOpenAlertList    = (sObjectList.getSObjectType() == Open_Alert__c.sObjectType); //active__c flag exists on Open_Alert__c obj
        
        for (sObject currentSObject : sObjectList) 
        {
            if ( 
                       (!isOpenAlertList)                                                                           // If either this is NOT a list of Open_Alert__c 
                    || (isOpenAlertList && Boolean.valueOf(currentSObject.get(ECICCommonConstants.FIELD_ACTIVE)))   //  ... OR this is a list of Open_Alert AND this record IS active 
               ) 
            {
                ECICLinkCaseAndOpenAlertsConfigEntry objECICLinkCaseAndOpenAlertsConfigEntry = new ECICLinkCaseAndOpenAlertsConfigEntry (currentSObject);
                for (Schema.FieldSetMember field : ECICCommonConstants.OPEN_ALERT_CASE_FIELDS) 
                {
                    objECICLinkCaseAndOpenAlertsConfigEntry.getArgs().add(String.valueOf(currentSObject.get(field.FieldPath)));    
                }
                objECICLinkCaseAndOpenAlertsConfigEntryList.add(objECICLinkCaseAndOpenAlertsConfigEntry);
            }
        }
        
        return objECICLinkCaseAndOpenAlertsConfigEntryList;
    }

}