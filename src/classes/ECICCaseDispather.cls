public with sharing class ECICCaseDispather {
    private ApexPages.StandardController stdController;
    private static final String CASE_PARENT_ACC_ID_PARAM_KEY    = 'def_account_id';
    private static final String CASE_PARENT_CONT_ID_PARAM_KEY   = 'def_contact_id';
    public string redirectUrl {get;set;}
    
    public ECICCaseDispather(ApexPages.StandardController stdController) {
        this.stdController  = stdController;
        redirectUrl         = URL.getSalesforceBaseUrl().toExternalForm();
        redirectUrl         = redirectUrl + '/setup/ui/recordtypeselect.jsp?ent=Case';
    }
    
    public PageReference newcase() {
        PageReference result                = null;
        PageReference selectCaseTypePage    = ApexPages.currentPage();
        String selectedRecordTypeId         = ApexPages.currentPage().getParameters().get('RecordType');
        String currentRetURL                = ApexPages.currentPage().getParameters().get('retURL');
        String current_save_new_url         = ApexPages.currentPage().getParameters().get('save_new_url');
        String checkResult                  = ECICCaseDispatherHelper.isRecordTypeAvailable(UserInfo.getUserId(),selectedRecordTypeId);
        
        if(String.isEmpty(checkResult)) {
            Schema.DescribeSObjectResult describeResult = stdController.getRecord().getSObjectType().getDescribe();
            String url  = '/' + describeResult.getKeyPrefix() + '/e?';
            result      = new PageReference(url); 
            result.getParameters().put('retURL', currentRetURL);
            result.getParameters().put('nooverride', '1');
            result.getParameters().put('RecordType', selectedRecordTypeId);
            result.getParameters().put('ent', 'Case');
            result.setRedirect(true);
            
            // pass acc id param if exists
            String accountId = ApexPages.currentPage().getParameters().get(CASE_PARENT_ACC_ID_PARAM_KEY);
            if (accountId != null && accountId.length() > 0) {
                result.getParameters().put(CASE_PARENT_ACC_ID_PARAM_KEY, accountId);
            }
            
            // pass cont id param if exists
            String contactId = ApexPages.currentPage().getParameters().get(CASE_PARENT_CONT_ID_PARAM_KEY);
            if (contactId != null && contactId.length() > 0) {
                result.getParameters().put(CASE_PARENT_CONT_ID_PARAM_KEY, contactId);
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, checkResult));
            result = null;
        }
        return result;
    }
    
    public pageReference redirectToMain() {
        pageReference pg = new pageReference('/setup/ui/recordtypeselect.jsp?ent=Case&retURL=/500/o&save_new_url=/500/e');
        pg.setredirect(true);
        return pg;
    }
}