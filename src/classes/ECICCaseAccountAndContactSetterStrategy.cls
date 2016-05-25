public class ECICCaseAccountAndContactSetterStrategy extends ECICCaseProcessingStrategyAbstract {

    public override boolean OnBeforeInsert(List<sObject> newSObjectValueList) 
    {
      try { setAccountAndContactOnEmailAndWebCases((List<Case>)newSObjectValueList); }
        catch (Exception ex)
        {
            System.debug(LoggingLevel.WARN, '!!!!!!! Exception: ' + ex.getMessage() + '\nException stack trace:\n' + ex.getStackTraceString());
        }
        return true;
    }

    /**
     *  Needs to be reworked to use alternative identifier
     *  @see CIC-689
   **/
    @testVisible private void setAccountAndContactOnEmailAndWebCases(Case[] newCaseArray) 
    {
        Map<String, Case> emailAndWebCaseIdentStringMap = buildEmailAndWebCaseIdentStringMap (newCaseArray);
        setAccountAndContactOnCases(emailAndWebCaseIdentStringMap);
    }
    
    public static Map<String, Case> buildEmailAndWebCaseIdentStringMap (List<Case> newCaseList)
    {
        Map<String, Case> emailAndWebCaseIdentStringMap = new Map<String, Case>();
        for (Case currentCase : newCaseList)                                                                     // Filter for Qualified Cases, those being either 
        {
            if ( (currentCase.Origin == 'Email' && String.isNotBlank(currentCase.SuppliedEmail))                  // 1. From Email AND including a SuppliedEmail address; or 
                    || (currentCase.Origin == 'Web')) {                                                           // 2. From the Web.
                    	
                if(currentCase.SuppliedPhone == '+34') {
				       currentCase.SuppliedPhone = '';
				}  

                String mapIdentifier = (ECICMapHelper.createMapIdentifier(currentCase, false));                   // Create identifier for lack of an SFDC Id
                emailAndWebCaseIdentStringMap.put(mapIdentifier, currentCase);                                    // Put Case in a map, keyed by identifier.
                
                if ((Test.isRunningTest()) && (currentCase.subject == 'Throws Exception Test')) 
                {
                  TEST_MockHelper.setMockBoolean(currentCase, 'doThrowExceptionTest', true);                     // Used for testing exceptions; only change to true for one possible but unlikely subject, and then only if Test.isRunningTest();
            }
        }
        }
        return emailAndWebCaseIdentStringMap;
    }
    
    private void setAccountAndContactOnCases(Map<String, Case> caseIdentStringMap) {
        if (! caseIdentStringMap.isEmpty()) {
            try 
            {
                 Boolean doThrowExceptionTest = Test.isRunningTest() && doExceptionTest(caseIdentStringMap);
                   if (Test.isRunningTest() && doThrowExceptionTest) 
                   { 
                         throw new ECICEmail2CaseServiceException();   // Exception type is arbitrary; we just want to check the results of catching something.             
        }
                   else 
                   {
                        ECICSObjectAccountCollections.setNewCICAccountsOnCases(caseIdentStringMap);                   // Qualified Cases are sent to ECICSObjectAccountCollections to set Account and Contact Values.
                   }
            } 
            catch (Exception ex) { notifySupportAboutCaseProcessingError(ex, caseIdentStringMap.values()); }
        }
    }
    
    private Boolean doExceptionTest (Map<String, Case> caseIdentStringMap)
    {
      for (String key : caseIdentStringMap.keySet())
      {
        if (TEST_MockHelper.getMockBoolean(key, 'doThrowExceptionTest')) { return true; }
      }
      return false;
    }

    @testVisible private void notifySupportAboutCaseProcessingError(Exception ex, Case[] cases) 
    {
      String message = 'Error occured on processing cases.\n\nError: '+ex.getMessage()+ '\n\nCases: '+cases;
      String addressee = General_Settings__c.getInstance().supportEmail__c;
      if (String.isNotBlank(addressee)) 
      {
            String subject = '[CaseTriggerHandler] ERRORS on Case processing';
            ECICCaseTriggerEmailMessageCache.addEmailMessageToSendList (new List<String>{addressee}, subject, message);
      } 
    }
        }