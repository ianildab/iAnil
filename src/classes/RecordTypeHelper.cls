public class RecordTypeHelper {

  // Specify the value 012000000000000AAA for the master recordTypeId regardless of the object. 
  // This value is returned in the recordTypeInfos for the master record type in the DescribeSObjectResult per SF docs.
  // See http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_describelayout.htm#i1425561 - "Arguments" section.
  public static final String MASTER_REC_TYPE_ID = '012000000000000AAA';

  public static final String CONTACT_BUSINESS_REC_TYPE_API_NAME = 'Business_Contact';
  public static final String CONTACT_EMPLOYEE_REC_TYPE_API_NAME = 'Employee';
  
  public static final String ACCOUNT_CONSUMER_REC_TYPE_API_NAME = 'Consumer';
  public static final String ACCOUNT_POTENTIAL_CONSUMER_REC_TYPE_API_NAME = 'Potential_Consumer';
  
  public static final Map<String,String> CONTACT_RECORD_TYPES;
  public static final Map<String,String> CASE_RECORD_TYPES;
  public static final Map<String,String> ACCOUNT_RECORD_TYPES;
  public static final Map<String,String> PROMOTION_RECORD_TYPES;
  public static final Map<String,String> SMS_RECORD_TYPES;  
  
  public static final String CASE_RT_PRODUCT_COMPLAINTS = 'Product_Complaints';
  public static final String CASE_RT_PROMOTION_COMPLAINTS = 'Promotion_Complaints';

  // SABU
  public static final String CASE_RT_SERVICE_COMPLAINT_SABU = 'Service_Complaint_SABU';
  public static final String CASE_RT_ADVERTISMENT_COMPLAINT_SABU = 'Advertisement_Complaint_SABU';
  public static final String CASE_RT_PRODUCT_COMPLAINT_SABU = 'Product_Complaint_SABU';
  public static final String PROMOTION_SABU_API_NAME = 'Promotion_sabu';
  public static final String CONTACT_BUSINESS_SABU_REC_TYPE_API_NAME = 'Business_Contact_SABU';
  public static final String ACCOUNT_SABU_CONSUMER_REC_TYPE_API_NAME = 'Consumer_SABU';

  // SMS
  public static final String SMS_TR_REC_TYPE_API_NAME = 'CCC_SMS';
  public static final String SMS_SABU_REC_TYPE_API_NAME = 'SABU_SMS';
  
  //email2case
  public static final String CASE_EMAIL2CASE_SABU_REC_TYPE_API_NAME = 'Email_Case_SABU';
  public static final String CASE_EMAIL2CASE_TCCC_REC_TYPE_API_NAME = 'Requests';
    
  static {
    // Query and cache Contact Record Types
    List<RecordType> contactRecordTypes = ECICCaseTriggerRegionCache.getRecordType(ECICCommonConstants.RECORDTYPE_BY_SOBJECT_TYPE,'Contact').Values();
    // [Select DeveloperName, Id From RecordType where sObjectType='Contact' and isActive = true];
    CONTACT_RECORD_TYPES = new Map<String,String>{};
    for(RecordType rt: contactRecordTypes) {
      CONTACT_RECORD_TYPES.put(rt.DeveloperName, rt.Id);
    }

    // Query and cache all Case Record Types
    List<RecordType> caseRecordTypes = ECICCaseTriggerRegionCache.getRecordType(ECICCommonConstants.RECORDTYPE_BY_SOBJECT_TYPE,'Case').Values();
    // [Select DeveloperName, Id From RecordType where sObjectType='Case' and isActive = true];
    CASE_RECORD_TYPES = new Map<String,String>{};
    for(RecordType rt: caseRecordTypes) {
      CASE_RECORD_TYPES.put(rt.DeveloperName, rt.Id);
    }
    
    // Query and cache all Account Record Types
    List<RecordType> accountRecordTypes = ECICCaseTriggerRegionCache.getRecordType(ECICCommonConstants.RECORDTYPE_BY_SOBJECT_TYPE,'Account').Values();
    // [Select DeveloperName, Id From RecordType where sObjectType='Account' and isActive = true];
    ACCOUNT_RECORD_TYPES = new Map<String,String>{};
    for(RecordType rt: accountRecordTypes) {
      ACCOUNT_RECORD_TYPES.put(rt.DeveloperName, rt.Id);
    }
    
    // Query and cache all Promotion Record Types
    List<RecordType> promotionRecordTypes =  ECICCaseTriggerRegionCache.getRecordType(ECICCommonConstants.RECORDTYPE_BY_SOBJECT_TYPE,'Promotion__c').Values();
    // [Select DeveloperName, Id From RecordType where sObjectType='Promotion__c' and isActive = true];
    PROMOTION_RECORD_TYPES = new Map<String,String>{};
    for(RecordType rt: promotionRecordTypes) {
      PROMOTION_RECORD_TYPES.put(rt.DeveloperName, rt.Id);
    }
    
    // Query and cache all SMS Record Types
    List<RecordType> SMSRecordTypes =  ECICCaseTriggerRegionCache.getRecordType(ECICCommonConstants.RECORDTYPE_BY_SOBJECT_TYPE,'SMS__c').Values();
    // [Select DeveloperName, Id From RecordType where sObjectType='SMS__c' and isActive = true];
    SMS_RECORD_TYPES = new Map<String,String>{};
    for(RecordType rt: SMSRecordTypes) {
      SMS_RECORD_TYPES.put(rt.DeveloperName, rt.Id);
    }
  }

  public static String getContactBusinessRecTypeId() {
    return CONTACT_RECORD_TYPES.get(CONTACT_BUSINESS_REC_TYPE_API_NAME);
  }
  
  public static String getContactEmployeeRecTypeId() {
    return CONTACT_RECORD_TYPES.get(CONTACT_EMPLOYEE_REC_TYPE_API_NAME);
  }

  public static String getCaseRecTypeId(String caseRecordTypeName) {
    return CASE_RECORD_TYPES.get(caseRecordTypeName);
  }
  
  public static String getAccountRecordTypeId(String accountRecordTypeName) {
    return ACCOUNT_RECORD_TYPES.get(accountRecordTypeName);
  }
  
  public static String getAccountConsumerRecordTypeId() {
    return ACCOUNT_RECORD_TYPES.get(ACCOUNT_CONSUMER_REC_TYPE_API_NAME);
  }
  
  public static String getAccountPotentialConsumerRecordTypeId() {
    return ACCOUNT_RECORD_TYPES.get(ACCOUNT_POTENTIAL_CONSUMER_REC_TYPE_API_NAME);
  }  
  
  public static String getPromotionSABURecTypeId() {
    return PROMOTION_RECORD_TYPES.get(PROMOTION_SABU_API_NAME);
  }
  
   public static String getSMSRecordTypeId(String smsRecordTypeName) {
    return SMS_RECORD_TYPES.get(smsRecordTypeName);
  }
  
   public static String getAccountSABUConsumerRecTypeId() {
    return ACCOUNT_RECORD_TYPES.get(ACCOUNT_SABU_CONSUMER_REC_TYPE_API_NAME);
  }
  
  public static String getSABUContactBusinessRecTypeId() {
    return CONTACT_RECORD_TYPES.get(CONTACT_BUSINESS_SABU_REC_TYPE_API_NAME);
  }
  
  /*public static void setEmail2CaseCountryCode(Case[] newCases){
      for(Case c: newCases){
          if(c.RecordTypeId == CASE_RECORD_TYPES.get(CASE_EMAIL2CASE_SABU_REC_TYPE_API_NAME)){
              c.CountryCode__c = 'ZA';
              c.CCCSABU_FirstRecordType__c = CASE_EMAIL2CASE_SABU_REC_TYPE_API_NAME; 
          } else if(c.RecordTypeId == CASE_RECORD_TYPES.get(CASE_EMAIL2CASE_TCCC_REC_TYPE_API_NAME)){
              c.CountryCode__c = 'TR';
              c.CCCSABU_FirstRecordType__c = CASE_EMAIL2CASE_TCCC_REC_TYPE_API_NAME;
            } 
      }
  } */
}