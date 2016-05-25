public class ECICLinkCaseAndOpenAlertsMatchable  
{
    public List<String> args; 
 
    public ECICLinkCaseAndOpenAlertsMatchable (List<String> args) { this.args = args; }
        
    public boolean matchTo(List<String> queryArgs) 
    {
        if (queryArgs == null || queryArgs.isEmpty()) { return false; }
        
        boolean isMatched = true;
        integer i = 0;
        do 
        { 
            isMatched &= ((this.args[i] == queryArgs[i]) || (queryArgs[i] == null)); 
        } 
        while (isMatched && (++i < this.args.size()) && (i < queryArgs.size()));
        return isMatched;
    }

    public static Map<String, List<Open_Alert_Case__c>> matchOpenAlertsAndCases(List<ECICLinkCaseAndOpenAlertsConfigEntry> caseConfigEntryList, List<ECICLinkCaseAndOpenAlertsConfigEntry> openAlertConfigEntryList, Map<String, ID> openAlertCaseLinksMap)
    {
        List<Open_Alert_Case__c> openAlertLinkedCaseList         = new List<Open_Alert_Case__c>();
        List<Open_Alert_Case__c> toDeleteOpenAlertLinkedCaseList = new List<Open_Alert_Case__c>();

        for (ECICLinkCaseAndOpenAlertsConfigEntry caseConfigEntry : caseConfigEntryList)                                       // for each Case ConfigEntry in the parameter-list...
        {
        	ECICLinkCaseAndOpenAlertsMatchable matchable   = new ECICLinkCaseAndOpenAlertsMatchable (caseConfigEntry.args);    // 1. Create new Matchable from configEntry
            Case      currentCase = (Case) caseConfigEntry.obj;                                                                // 2. Get current Case from configEntry
            
            for (ECICLinkCaseAndOpenAlertsConfigEntry openAlertConfigEntry : openAlertConfigEntryList )                        // 3. for each Open Alert ConfigEntry in the parameter-list...
            {  
                String          linkKey                 = caseConfigEntry.id + '_' + openAlertConfigEntry.id;                      //        i.   Create Key
                Open_Alert__c   openAlert               = (Open_Alert__c) openAlertConfigEntry.obj;                            //        ii.  Get current Open Alert from configEntry
                Boolean         isCountryCodeMatched    = isCountryCodeMatched(openAlert, currentCase);
                
                if (isCountryCodeMatched)                                                                                      //        iii. If country code matches....
                {
                    Boolean isMatched = matchable.matchTo(openAlertConfigEntry.args) && matchCreationDate(currentCase.CreatedDate, openAlert.Start_Date__c, openAlert.End_Date__c);
                
                    if ((!openAlertCaseLinksMap.containsKey(linkKey)) && (isMatched))                                          //               1. If link doesn't exist but there is a match,
                    {
                        openAlertLinkedCaseList.add(ECICOpenAlertCaseHelper.createOpenAlertCase(caseConfigEntry, openAlertConfigEntry ));  //           ... Create the link.
                    }
                    else if((openAlertCaseLinksMap.containsKey(linkKey)) && (!isMatched))                                       //              2. If the link exists but there is no match,
                    {
                        toDeleteOpenAlertLinkedCaseList.add(new Open_Alert_Case__c (id = openAlertCaseLinksMap.get(linkKey)));  //                  ... Destroy the link.
                    }
                }
            }
        }

        Map<String, List<Open_Alert_Case__c>> matchedOpenAlertCaseListMap = new Map<String, List<Open_Alert_Case__c>>();                    // Creates a map of lists to return.
                                              matchedOpenAlertCaseListMap.put ('openAlertLinkedCaseList', openAlertLinkedCaseList); 
                                              matchedOpenAlertCaseListMap.put ('toDeleteOpenAlertLinkedCaseList',    toDeleteOpenAlertLinkedCaseList);
                                       return matchedOpenAlertCaseListMap;                                                  // Updates to openAlertCaseLinksMap are also "returned" because it was passed by reference, not as copy. 
        
    }

    public static Boolean isCountryCodeMatched(Open_Alert__c openAlert, Case currentCase) 
    { 
        String  alertCountryCode        = (String) openAlert.get('Country_Code_String__c');  
        String  caseCountryCode         = (String) currentCase.get('Country_code__c');
        
        Boolean isAlertCountryCodeNull = (alertCountryCode == null);
        Boolean isCaseCountryCodeNull  = (caseCountryCode  == null);
        Boolean isCountryCodeEverNull  = isAlertCountryCodeNull || isCaseCountryCodeNull;
        Boolean doesAlertCountryCodeContainCaseCountryCode = !isCountryCodeEverNull && (alertCountryCode.contains(caseCountryCode));
        
        return doesAlertCountryCodeContainCaseCountryCode;
    }

    public static boolean matchCreationDate(Datetime caseCreationDate, Date startDate, Date endDate) 
    {
        Datetime startTime = (startDate == null) ? null : Datetime.newInstance(startDate.year(), startDate.month(), startDate.day());
        Datetime endTime   = (endDate   == null) ? null : Datetime.newInstance(endDate.year(),   endDate.month(),    endDate.day()).addDays(1);
        
        boolean isBetween = true;
        if      ((startDate == null) && (endDate == null)) { isBetween = true;                                                         }
        else if (startDate  == null)                       { isBetween = caseCreationDate <= endTime;                                  }
        else if (endDate    == null)                       { isBetween = caseCreationDate >= startTime;                                }
        else                                               { isBetween = startTime <= caseCreationDate && caseCreationDate <= endTime; }
            
        return isBetween;
    }  
}