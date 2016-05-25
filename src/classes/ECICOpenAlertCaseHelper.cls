public class ECICOpenAlertCaseHelper 
{
    public static Open_Alert_Case__c createOpenAlertCase(ECICLinkCaseAndOpenAlertsConfigEntry caseConfig, ECICLinkCaseAndOpenAlertsConfigEntry alertConfig) 
    {
        Case               currentCase = (Case)          caseConfig.obj;
        Open_Alert__c alert = (Open_Alert__c) alertConfig.obj;

        Open_Alert_Case__c linkedCase = new Open_Alert_Case__c ();
                           linkedCase.Case__c       = caseConfig.id ;
                           linkedCase.case__r       = currentCase;
        linkedCase.open_alert__c = alertConfig.id;
        linkedCase.open_alert__r = alert;
                           linkedCase.name          = alert.Name + ' / ' + currentCase.CaseNumber;
        return linkedCase;
    }
    

}