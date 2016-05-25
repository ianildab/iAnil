public class SABU_SMS_Helper 
{ 
    private Set<String> CONSUMER_CASE_TYPES_SMS = new Set<String>{};  
    private Set<String> Bottler_CASE_TYPES_SMS = new Set<String>{};  
    private  Map <Id, Account> consumersMap = New Map <Id, Account> {};
    private  Map <Id, String> bottlerPhonesMap = New Map <Id, String> {};
    private  Map <Id, String> ProductId2NameMap = New Map <Id, String> {};
    private  Map <Id, String> accId2ResponsBottler = New Map <Id, String> {};
    private  Map <Id,List<String>> case2recipientIds = New Map <Id,List<String>>();
    private Map<Id, Contact> bottlersMap = new Map<Id, Contact>();
    public static Boolean skipCaseTriggerLogic = false;
    public static final string COUNTRY_CODE = '27';
    
  public static Boolean isEnabledSABUSendSMSSetting() {
    Common_Settings__c setting = Common_Settings__c.getInstance('SABU_EnableSendSMS');
    Boolean enableSendSMS = setting == null ? false : ('true'.equalsIgnoreCase(setting.Value__c));
    return enableSendSMS;
  }

/**************************************************************************************************/    
    public  void sendSABUsmsList(Case[] listCase) {
        try
        {
            If(isEnabledSABUSendSMSSetting())
            {
                fillCaseRecTypes();
                List<Case> consumerSMSsentCases = sendSMSToConsumers(listCase);
                List<Case> bottlersSMSsentCases = sendSMSToBusiness(listCase);
            }
        }
        catch(Exception ex)
        {
            ErrorLogHelper.LogError(String.ValueOf(listCase), ex.getMessage() + ' - ' + ex.getStackTraceString() + ' - Line number: ' + ex.getLineNumber());
        }
    }
/**************************************************************************************************/               
    private  List<Case> sendSMSToConsumers(Case[] listCase){        
        List <Case> consumerCase2SMS = New List<Case>();
        List<Case> checkedCases = New List<Case>();
        Map <Id,Id> case2accId = New Map <Id,Id> ();
        
        try
        {
            case2accId = checkConsumerCases(listCase); 
            System.debug('@@case2accId: ' +case2accId );       
                                           
            List <Account> acc2sms = New List <Account> {};        
            List <Id> accIds = new List <Id> {};
            List <SMS__c> complitSMS = New List<SMS__C>{};
            if(!case2accId.isEmpty()){            
                for (Id currCaseId : case2accId.KeySet() ){
                   accIds.add(case2accId.get(currCaseId));            
                }
                acc2sms = [SELECT Id, Name, PersonMobilePhone, RecordType.Name, Salutation 
                             FROM Account
                            WHERE Id IN :accIds];        
                for(Account currAcc:acc2sms){
                        consumersMap.put(currAcc.Id, currAcc);
                }
                System.debug('@@consumersMap: ' +consumersMap);  
                      
                for(Case currCase:listCase){        
                    if(case2accId.KeySet().contains(currCase.Id)){
                        checkedCases.add(currCase); 
                        if(consumersMap.containsKey(currCase.AccountId) 
                        && String.isNotBlank(consumersMap.get(currCase.AccountId).PersonMobilePhone)
                        && consumersMap.get(currCase.AccountId).RecordType.Name == 'Person' ){
                            consumerCase2SMS.add(currCase);
                        }        
                    }    
                }
                System.debug('@@consumerCase2SMS: ' +consumerCase2SMS); 
                
                if(!consumerCase2SMS.isEmpty()){
                    complitSMS = createSABUSMS2ConsumerList(consumerCase2SMS);
                }
                System.debug('@@complitSMS: ' +complitSMS); 
                
                if(!complitSMS.isEmpty()){
                    //CCC_Cases_Helper_Addon.setListSMS(complitSMS);
                    upsert complitSMS;
                    
                    List<Id> listIdSMS = New List<Id>();
                    for(SMS__c currSMS: complitSMS){
                        if(String.isNotEmpty(currSMS.Mobile__c)){
                            listIdSMS.add(currSMS.Id);
                        }
                    }
                    System.debug('@@listIdSMS: ' +listIdSMS);
                    
                    // call sms webservice
                    //if(!Test.isRunningTest()){
                        SMSProvider objSMSProvider = new SMSProvider('SABU');
                        objSMSProvider.sendSMSListByIds(listIdSMS);
                    //}
                }
            }
        }
        catch(Exception ex)
        {
            ErrorLogHelper.LogError(String.ValueOf(listCase), ex.getMessage() + ' - ' + ex.getStackTraceString() + ' - Line number: ' + ex.getLineNumber());
        }
        return checkedCases;
    } 
/************************************************************************************************************/    
    private  List<Case> sendSMSToBusiness(Case[] listCase){
        List <Case> SMS2ABI = New List<Case>{}; 
        List <Case> SMS2CCF = New List<Case>{};         
        List <Case> SMS2CCSB = New List<Case>{};         
        List <Case> SMS2Canners = New List<Case>{};                 
        List <Case> SMS2PenBev = New List<Case>{};
        List <Case> SMS2Smollan = New List<Case>{};   
        List <SMS__c> complitSMS = New List<SMS__C>{};            
        List <Case> complitSMScases = New List<Case> {};
            
        try
        {
            //fill References
            case2recipientIds = checkBuisnessCases(listCase);
            System.debug('@@case2recipientIds: ' +case2recipientIds);   
                 
            fillAcc2PhonesMap(case2recipientIds);
            
            List<Id> productIds = New List<Id> {}; 
            for(Case currCase:listCase){        
                if(case2recipientIds.KeySet().contains(currCase.Id)){
                    productIds.add(currCase.CCE_Product__c);      
                }   
            } 
            fillProducts2NameMap(productIds);
              
            //select cases by type bottlers
            for(Case currCase : listCase)
            {        
                if(case2recipientIds.KeySet().contains(currCase.Id))
                {                
                    List<string> lstAccountIds = case2recipientIds.get(currCase.Id);
                    for(string strAccountId : lstAccountIds)
                    {
                        If(bottlerPhonesMap.containsKey(strAccountId))
                        {
                            complitSMS.add(createSABUbottlerSMS(currCase, bottlerPhonesMap.get(strAccountId), ID.ValueOf(strAccountId)));
                        }
                    }
                    
                    complitSMScases.add(currCase);
                }   
            }
            System.debug('@@complitSMS: ' +complitSMS);
            System.debug('@@complitSMScases: ' +complitSMScases);
                
            if(!complitSMS.isEmpty())
            {
                //CCC_Cases_Helper_Addon.setListSMS(complitSMS);
                upsert complitSMS;
                
                List<Id> listIdSMS = New List<Id>();
                for(SMS__c currSMS: complitSMS){
                    if(String.isNotEmpty(currSMS.Mobile__c)){
                        listIdSMS.add(currSMS.Id);
                    }
                }
                System.debug('@@listIdSMS: ' +listIdSMS);
                
                // call sms webservice
                //if(!Test.isRunningTest()) {                
                    SMSProvider objSMSProvider = new SMSProvider('SABU');
                    objSMSProvider.sendSMSListByIds(listIdSMS);
                //}        
            }                                    
        }
        catch(Exception ex)
        {
            ErrorLogHelper.LogError(String.ValueOf(listCase), ex.getMessage() + ' - ' + ex.getStackTraceString() + ' - Line number: ' + ex.getLineNumber());
        }
        return complitSMScases;
    }     
/************************************************************************************************************/           
    private  Map <Id,Id> checkConsumerCases(Case[] inCases){
    Map <Id,Id> outMap = New Map <Id,Id> ();
    System.debug('@@inCases: ' +inCases);
    for(Case currCase:inCases){
            System.debug('@@CONSUMER_CASE_TYPES_SMS2: ' +CONSUMER_CASE_TYPES_SMS);
            System.debug('@@currCase.RecordTypeId: ' +currCase.RecordTypeId);
            if(CONSUMER_CASE_TYPES_SMS.contains(currCase.RecordTypeId)  
            && currCase.AccountId != null ){
                outmap.put(currCase.Id,currCase.AccountId);  
                System.debug('@@Case pass');
            }        
        }
        return outMap;         
    }   
/*************************************************************************************************/    
// return map CaseId:accIdList{ResponsibleBottlerCoordinatorId, ResponsibleforSampleCollectionId, ResponsiblePlantLaboratoryQAId, TQSId, ResponsiblePlantQAManagerId, customerId}
    private  Map <Id,List<String>> checkBuisnessCases(Case[] inCases){
        Map <Id,List<String>> outMap = New Map <Id,List<String>> ();
        //String smsCaseType = RecordTypeHelper.CASE_RECORD_TYPES.get('Quality_Complaint_SABU');         
        for(Case currCase:inCases){                  
            //if(currCase.RecordTypeId == smsCaseType){ 
              if(Bottler_CASE_TYPES_SMS.contains(currCase.RecordTypeId)){
                List<String> accRecipients = ECICSABUSampleCollectorContactFetch.fetchSampleCollectors(currCase.Id);
                System.debug('@@accRecipients: ' +accRecipients);
                
                //accRecipients.add(currCase.AccountId);
                If(accRecipients != null && accRecipients.size() > 0)
                    outmap.put(currCase.Id,accRecipients);  
            }        
        } 
        return outMap;         
    }   

/**************************************************************************************************/    
    private  void fillAcc2PhonesMap(Map<Id,List<String>> inCases){
        List <Contact> acc2sms = New List <Contact> {};        
        List <String> searchIds = new List <String> {};               
        for (Id currCaseId : inCases.KeySet() ){
            searchIds.addAll(inCases.get(currCaseId));            
        } 
        acc2sms = [SELECT Id, AccountId, FirstName, LastName, MobilePhone, Account.RecordType.Name, Salutation
                     FROM Contact
                    WHERE Id IN :searchIds]; 
        System.debug('@@acc2sms: ' +acc2sms); 
                                                                                          
        for(Contact currAcc:acc2sms){
            //if(String.isNotBlank(currAcc.PersonMobilePhone) && (currAcc.RecordType.Name == 'Bottler Employee_SABU' || currAcc.CCCSABU_Bottler__c == 'Smollan' )){
            if(String.isNotBlank(currAcc.MobilePhone)){
                bottlerPhonesMap.put(currAcc.Id, currAcc.MobilePhone);
                bottlersMap.put(currAcc.Id, currAcc);
            }
            //accId2ResponsBottler.put(currAcc.Id, currAcc.CCCSABU_Bottler__c);
        } 
        System.debug('@@bottlerPhonesMap: ' +bottlerPhonesMap);
        System.debug('@@consumersMap: ' +consumersMap);                      
        /*for(Account currAcc:acc2sms){
                consumersMap.put(currAcc.Id, currAcc);                
        } */            
    }
/**************************************************************************************************/        
    private  void fillProducts2NameMap(List<Id> inProd){
        List <CCE_Product__c> products = new List <CCE_Product__c> {}; 
        System.debug('@@inProd: ' +inProd);
        
        products = [SELECT Id, Name 
                      FROM CCE_Product__c 
                     WHERE Id IN :inProd];   
                                                                                                               
        for(CCE_Product__c currProd : products){
            ProductId2NameMap.put(currProd.Id, currProd.Name);
        }
        System.debug('@@ProductId2NameMap: ' +ProductId2NameMap);
    }

/**************************************************************************************************/        
    private  List<SMS__c> createSABUSMS2ConsumerList(Case[] listCase){
        List <SMS__c> listSMS = New List<SMS__c>();
        for(Case currCase:listCase){
            listSMS.Add(createSABUConsumerSMS(currCase));
        }
        return listSMS;
    }
           
/**************************************************************************************************/    
    private  SMS__c createSABUConsumerSMS(Case currCase){
        SMS__c currSMS = New SMS__c ();
        currSMS.Case__c = currCase.Id;
        currSMS.Delivered__c = false; 
        String tempMessage = Label.SABU_Message_Consumer;
        System.debug('@@tempMessage: ' +tempMessage);
        currSMS.Message__c =  tempMessage.replace('<CaseID>', currCase.CaseNumber);    
        currSMS.SABU_Recipient__c = currCase.AccountId;
        currSMS.Return_SMS_ID__c = '';
        currSMS.Status__c = 'Not Sent';   
        Long intMobile = Long.ValueOf(consumersMap.Get(currCase.AccountId).PersonMobilePhone);    
        currSMS.Mobile__c = String.ValueOf(intMobile);
        currSMS.Recipient_Full_Name__c = consumersMap.Get(currCase.AccountId).Name;
        System.debug('@@currSMS: ' +currSMS);     
        return currSMS;
    }

/**************************************************************************************************/        
    private  SMS__c createSABUbottlerSMS(Case currCase, String currPhone, Id currRecipient){
// message: A new alert case <case ID> related to <Product> is logged  <Date/Time Created> - <Subject>. Consumer <Account Name>, <Mobile>.    
        SMS__c currSMS = New SMS__c ();
        currSMS.Case__c = currCase.Id;
        currSMS.Delivered__c = false;
        String tempMessage = Label.SABU_Message_Bottler;
        System.debug('@@tempMessage: ' +tempMessage);
        tempMessage = tempMessage.replace('<CaseID>', currCase.CaseNumber);
        tempMessage = tempMessage.replace('<Date/Time Created>', string.valueOfGmt(currCase.CreatedDate));
        tempMessage = tempMessage.replace('<Product>', ProductId2NameMap.get(currCase.CCE_Product__c).left(100));
        tempMessage = tempMessage.replace('<Subject>', currCase.Subject.left(100));
        tempMessage = tempMessage.replace('<TITLE>', consumersMap.Get(currCase.AccountId).Salutation);
        tempMessage = tempMessage.replace('<Account Name>', consumersMap.Get(currCase.AccountId).Name.left(100));
        tempMessage = tempMessage.replace('<Mobile>', consumersMap.Get(currCase.AccountId).PersonMobilePhone);
        currSMS.Message__c = tempMessage;
        
        currSMS.SABU_Recipient__c = bottlersMap.get(currRecipient).AccountId;                           
        currSMS.Return_SMS_ID__c = '';        
        currSMS.Status__c = 'Not Sent';  
        Long intMobile =  Long.ValueOf(currPhone);    
        currSMS.Mobile__c = String.ValueOf(intMobile);
        currSMS.Recipient_Full_Name__c = bottlersMap.get(currRecipient).FirstName + ' ' + bottlersMap.get(currRecipient).LastName;
        System.debug('@@currSMS: ' +currSMS);                                 
        return currSMS;
    }    
/**************************************************************************************************/ 
    private void fillCaseRecTypes(){
// Query and cache possible Case Record Type Ids
         /*List <String> CaseRecordTypeNames = New List<String> {
             'Inquiry_SABU',
             'Non_Quality_Complaint_SABU',
             'Quality_Complaint_SABU' };      
        for(String ctn: CaseRecordTypeNames) {
           CONSUMER_CASE_TYPES_SMS.add(RecordTypeHelper.CASE_RECORD_TYPES.get(ctn));
        }
        System.debug('@@CONSUMER_CASE_TYPES_SMS: ' +CONSUMER_CASE_TYPES_SMS);   
        
        List <String> BottlerCaseRecordTypeNames = New List<String> {
             'Quality_Complaint_SABU' };             
        for(String bctn: BottlerCaseRecordTypeNames) {
           Bottler_CASE_TYPES_SMS.add(RecordTypeHelper.CASE_RECORD_TYPES.get(bctn));
        }
        System.debug('@@Bottler_CASE_TYPES_SMS: ' +Bottler_CASE_TYPES_SMS);*/
        
        Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);
    
        for(Id RecordTypeId : RECORD_TYPES_BY_ID_MAP.KeySet())
        {        
            RecordType objRecord = RECORD_TYPES_BY_ID_MAP.get(RecordTypeId);
            If(objRecord.DeveloperName == ECICCommonConstants.SABU_INQUIRY_DEVNAME || objRecord.DeveloperName == ECICCommonConstants.SABU_Non_Quality_COMPLAINT_DEVNAME || objRecord.DeveloperName == ECICCommonConstants.SABU_QUALITY_COMPLAINT_DEVNAME)
            {            
                CONSUMER_CASE_TYPES_SMS.add(objRecord.Id);
            }
            If(objRecord.DeveloperName == ECICCommonConstants.SABU_QUALITY_COMPLAINT_DEVNAME)
            {
                Bottler_CASE_TYPES_SMS.add(objRecord.Id);
            }
        }
        System.debug('@@CONSUMER_CASE_TYPES_SMS: ' +CONSUMER_CASE_TYPES_SMS);    
        System.debug('@@Bottler_CASE_TYPES_SMS: ' +Bottler_CASE_TYPES_SMS);
    }       
/**************************************************************************************************/     

    // leave only digits and check 
    private static String prepareMobilePhone(String mobilePhone) {
        String phoneNumber;
        if (String.isNotBlank(mobilePhone)) {
          phoneNumber = mobilePhone.replaceAll('[^0-9]+', '');
          if (!phoneNumber.startsWith(COUNTRY_CODE)) {
            phoneNumber = COUNTRY_CODE + phoneNumber;
          }
        }
        return phoneNumber;
    }
}