global with sharing class ECICGeneralController {
    private static final String COMMON_EMAIL_FOLDER = 'English_Email_Templates';
    private static final String EMAIL_TEMPLATE_FOLDER_SUFFIX = '_Email_Templates';

    public ECICGeneralController(ApexPages.StandardController controller) {

    }

    public String getBaseUrl() {
        return ApexPages.currentPage().getHeaders().get('Host');// URL.getSalesforceBaseUrl().toExternalForm();
    }

    /**
    *    Resolve appropriate email template based on preferred language.
    *    ECIC-64:
    *    When a user communicates with customer/consumer the language of the email/letter is driven 
    *    by language of the contact and some fields of the mail are predefined (signature, etc.). 
    */
    WebService static String resolveEmail (String tmpltName, String lang) { 
        
        Id fId = getFolderIdByLang(lang);
        tmpltName = tmpltName + '_%';
        
        List<EmailTemplate> templates = [SELECT Id FROM EmailTemplate WHERE DeveloperName LIKE :tmpltName AND folderId = :fId LIMIT 1];
        return (!templates.isEmpty()) ? templates[0].Id : null;
    }
    
    private static String resolveFolderNameByLang (String lang) {
        return (String.isEmpty(lang)) ? COMMON_EMAIL_FOLDER : lang + EMAIL_TEMPLATE_FOLDER_SUFFIX;
    }
    
    private static Id getFolderIdByLang(String lang) {
        String fName = resolveFolderNameByLang(lang); 
        Folder[] fids = [SELECT Id FROM Folder WHERE DeveloperName = :fName LIMIT 1];
        if (fids.isEmpty()) {
            fids = [SELECT Id FROM Folder WHERE DeveloperName = :COMMON_EMAIL_FOLDER LIMIT 1];
        }
        
        return (!fids.isEmpty()) ? fids[0].Id : null;
    }
    
    WebService static String resolveTemplateId (String tmpltName) {
        List<EmailTemplate> templates = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :tmpltName];
        return templates.size() > 0 ? templates[0].Id : null;
    }
    
    WebService static void unlinkTrendCases(Id[] ids) {
        ECICTrendHelper.unlinkTrendCases(ids);
    }
}