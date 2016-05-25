global class ECICOpenAlertExpirationWarningBatchable implements Database.Batchable<SObject>, Database.Stateful  
{
    global final String BATCHABLE_QUERY =       ' SELECT id, ownerId, end_date__c ' 
                                              + ' FROM Open_Alert__c ' 
                                              + ' WHERE active__c = \'true\' '
                                              + '     AND end_date__c <= :EXPIRING_DATE ';
    
    private final Id EMAIL_TEMPLATE_ID          = Id.valueOf(General_Settings__c.getInstance().Open_Alert_Expiration_Template_Id__c);
    private Set<Id> ownerIdSet;
    @testVisible private static Integer emailLimit;
    
    @testVisible private static final Integer DAYS_TIL_EXPIRATION = 0;
    private static final Date    EXPIRING_DATE       = System.today().addDays(DAYS_TIL_EXPIRATION);
    
    global Database.QueryLocator start(Database.BatchableContext batchableContext) {
        ownerIdSet = new Set<Id>();
        return Database.getQueryLocator(BATCHABLE_QUERY); 
    }
    
    global void execute(Database.BatchableContext batchableContext, List<SObject> sObjectList) { execute (sObjectList); }
    
    @testVisible private void execute(List<Open_Alert__c> openAlertList) {
        for (Open_Alert__c openAlert : openAlertList) {
            ownerIdSet.add(openAlert.ownerId);
        }
        
    }
    
    global void finish(Database.BatchableContext batchableContext) {
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        ECICOpenAlertNotificationCache.populate(ownerIdSet);
        
        for (Id ownerId : ownerIdSet) {
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setTemplateId(EMAIL_TEMPLATE_ID);
            msg.setTargetObjectId(ownerId);
            msg.setSaveAsActivity(false);
            
            messageList.add(msg);
        }
        
        Messaging.sendEmail(messageList);
        emailLimit = Limits.getEmailInvocations();
    }
}