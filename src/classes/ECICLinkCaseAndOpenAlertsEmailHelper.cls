public class ECICLinkCaseAndOpenAlertsEmailHelper 
{
    public static List<Open_Alert_Case__c> buildOpenAlertCaseRequiringEmailList (List<ECICLinkCaseAndOpenAlertsConfigEntry> openAlertConfigEntryList, List<Open_Alert_Case__c> openAlertLinkedCaseList)
    {
        Map<Id, Integer> caseQuantityByOpenAlertIdMap = buildNewCaseQuantityByOpenAlertIdMap(openAlertLinkedCaseList);
        Set<Id> openAlertRequiringEmailIdSet = buildOpenAlertRequiringEmailIdSet(openAlertConfigEntryList, caseQuantityByOpenAlertIdMap);
        return buildOpenAlertCaseRequiringEmailList(openAlertRequiringEmailIdSet, openAlertLinkedCaseList);
    }
    
    @testvisible private static List<Open_Alert_Case__c> buildOpenAlertCaseRequiringEmailList (Set<Id> openAlertRequiringEmailIdSet, List<Open_Alert_Case__c> openAlertLinkedCaseList)
    {
        List<Open_Alert_Case__c> openAlertCaseRequiringEmailList = new List<Open_Alert_Case__c>();
        for (Open_Alert_Case__c openAlertCase : openAlertLinkedCaseList)
        {
            if (openAlertRequiringEmailIdSet.contains(openAlertCase.open_alert__c))
            {
                openAlertCaseRequiringEmailList.add(openAlertCase);
            }
        }
        return openAlertCaseRequiringEmailList;
    }

    @testVisible private static Map<Id, Integer> buildNewCaseQuantityByOpenAlertIdMap(List<Open_Alert_Case__c> openAlertLinkedCaseList)
    {
        Map<Id, Integer> caseQuantityByOpenAlertIdMap = new Map<Id, Integer>();
        for (Open_Alert_Case__c openAlertCase : openAlertLinkedCaseList)
        {
            Id openAlertId = openAlertCase.Open_Alert__c;
            caseQuantityByOpenAlertIdMap.put (
                                                openAlertId, 
                                                (
                                                    (!caseQuantityByOpenAlertIdMap.containsKey(openAlertId)) 
                                                        ? (1) 
                                                        : (caseQuantityByOpenAlertIdMap.get(openAlertId) + 1)
                                                 ) 
                                             );
        }
        return caseQuantityByOpenAlertIdMap;
    }
    
    @testVisible private static Set<Id> buildOpenAlertRequiringEmailIdSet(List<ECICLinkCaseAndOpenAlertsConfigEntry> openAlertConfigEntryList, Map<Id, Integer> caseQuantityByOpenAlertIdMap)
    {
        Set<Id> openAlertRequiringEmailIdSet = new Set<Id>();
        for (ECICLinkCaseAndOpenAlertsConfigEntry openAlertConfigEntry : openAlertConfigEntryList)
        {
            if (caseQuantityByOpenAlertIdMap.containsKey(openAlertConfigEntry.id))
            {
                Open_Alert__c openAlert  = (Open_Alert__c) openAlertConfigEntry.obj;
                Integer       oldCaseCount = ( (openAlert.case_count__c != null) || (!Test.isRunningTest()) )
                                                    ? ( (Integer) openAlert.case_count__c )
                                                    : (
                                                        ( (TEST_MockHelper.getMockInteger(openAlert.id, 'case_count__c') != null) )
                                                            ? TEST_MockHelper.getMockInteger(openAlert.id, 'case_count__c')
                                                            : 0
                                                      );
                Integer       totalCases   = caseQuantityByOpenAlertIdMap.get(openAlert.id) + oldCaseCount;
                Integer       threshold  = (openAlert.threshold__c != null) ? (Integer) openAlert.threshold__c : 1;
                if (totalCases >= threshold)
                {
                    openAlertRequiringEmailIdSet.add(openAlert.id);
                }
            }
        }
        return openAlertRequiringEmailIdSet;
    }
	
	// --------------------------------------------------------------------------------------------------------------------------------------

    public static void generateEmails(List<ECICLinkCaseAndOpenAlertsConfigEntry> openAlertConfigEntryList, List<Open_Alert_Case__c> openAlertLinkedCaseList)
    {
            List<Open_Alert_Case__c> openAlertCaseRequiringEmailList = ECICLinkCaseAndOpenAlertsEmailHelper.buildOpenAlertCaseRequiringEmailList (openAlertConfigEntryList, openAlertLinkedCaseList);
            if (!openAlertCaseRequiringEmailList.isEmpty())
            { 
                generateEmails(openAlertCaseRequiringEmailList); 
            } 
    } 
	
    public static void generateEmails(List<Open_Alert_Case__c> caseAlertList) 
    {
        Map<sObject, Set<Id>> recipientUserIdSetByOpenAlertMap = new Map<sObject, Set<ID>>();
        Set<Id>               allrecipientUserIdSet = new Set<Id>();
        for (Open_Alert_Case__c caseAlert : caseAlertList) 
        {
            Open_Alert__c openAlert = caseAlert.open_alert__r;
            String        recipients = (openAlert != null) ? openAlert.Recipients__c : null;
                        
            if (String.isNotEmpty(recipients )) 
            {
                String[] toArray = recipients.split(ECICCommonConstants.SEMICOLON);
                for (String recipient : toArray) 
                {
                    Case currentCase = caseAlert.case__r;
                    Id   userId      = (ID) currentCase.get(recipient); 

                    if (userId != null) 
                    {
                        if (recipientUserIdSetByOpenAlertMap.containsKey(openAlert)) { recipientUserIdSetByOpenAlertMap.get(openAlert).add(userId);          }
                        else                                                         { recipientUserIdSetByOpenAlertMap.put(openAlert, new Set<ID>{userId}); } 
                        
                        allrecipientUserIdSet.add(userId);
                    }
                }   
                    }
            
            if (!recipientUserIdSetByOpenAlertMap.containsKey(openAlert)) 
            { 
            	recipientUserIdSetByOpenAlertMap.put(openAlert, null); 
            }
         }
            
        if (!recipientUserIdSetByOpenAlertMap.isEmpty())
        {
            SEPEmailSendHelper.sendMails(SEPEmailSendHelper.collectRecipientsAddressesAndCreateMails(
        	                                           recipientUserIdSetByOpenAlertMap, 
        	                                           allrecipientUserIdSet, 
        	                                           General_Settings__c.getInstance().Open_Alert_Template_Id__c
                                                   ) );
        }
        }
    }