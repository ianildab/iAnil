public class SMSProvider {
    //List of custom settings
  //Network Source Address Number ranges:
  
  @TestVisible
  private static String OPERATOR_NUMBER;
  
  private static String COUNTRY_CODE; //= '27';
  private static string businessUnit; // Ex.SABU
  
  private static String NODE; //= 'colaHTTP';
  private static String USERNAME; //= 'colaHTTP';
  private static String PASSWORD; //= 'Zqs2Zkh6';
  private static String TRANSFORM; //= 'SUBMIT_SM';
  
  private static Integer HTTP_SUCCESS_CODE = 200;
  private static String SUCCESS_CODE = '0x0';
  // LIMITS
  /* 1 sms = 1 callouts; 10 callouts per transaction allowed; 10 future calls allowed (1 future call = 1 transaction);
     So, we can send only 100 SMSes - (Limit of # of callouts/# of callouts per SMS) * # of future calls 
     P.S. all numbers in this comment are counted at the moment when functionallity was implemented. Limits can change with time - so code
     is generic. */
  private static Integer CALLOUTS_PER_SMS_SEND = 1;
  private static Integer TOTAL_SEND_SMS_LIMIT;
  private static Integer SMS_PER_FUTURE_CALL;
  
  private static String endpoint;
  private static String contentType;
  private static String operation;
  private static Boolean EnableSendSMS;
  private static Boolean logStatus;
  
  public SMSProvider(string strBusinessUnit)
  {
      businessUnit = strBusinessUnit;
      System.debug('@@businessUnit: ' +businessUnit);
      
       TOTAL_SEND_SMS_LIMIT = (Limits.getLimitCallouts()/CALLOUTS_PER_SMS_SEND) * Limits.getLimitFutureCalls();
       SMS_PER_FUTURE_CALL = Limits.getLimitCallouts()/CALLOUTS_PER_SMS_SEND;    
  }

  /* Send list of SMS by ids.
     1. One SMS = 1 callouts (send SMS and query status), so 10 SMSes per one future invocation
     2. No more than 10 future calls are allowed per transaction
     3. So, we can send only 100 SMSes - (Limit of # of callouts/# of callouts per SMS) * # of future calls
     P.S. all numbers in this comment are counted at the moment when functionallity was implemented. Limits can change with time - so code
     is generic. 
     Considering statements above.... */
  public void sendSMSListByIds(List<Id> ids) {
    if (ids == null || ids.isEmpty()) {
      // nothing to do with empty list.
      return;
    }

    // otherwise handle ids - split to portions
    Integer smsToSendCount = ids.size() < TOTAL_SEND_SMS_LIMIT ? ids.size() : TOTAL_SEND_SMS_LIMIT;
    List<List<Id>> portions = new List<List<Id>>();
    List<Id> portion = new List<Id>();
    for (Integer i = 0; i < smsToSendCount; i++) {
      portion.add(ids.get(i));
      if (portion.size() == SMS_PER_FUTURE_CALL) {
        portions.add(portion);
        portion = new List<Id>();
      }
      // last portion, maybe not full (i.e. size < SMS_PER_FUTURE_CALL)
      else if (i == smsToSendCount - 1) {
        portions.add(portion);
      }
    }

    // send portions using future method
    for (List<Id> idsPortion : portions) {
      sendSMSList(idsPortion, businessUnit);
    }

  }

  // send list of SMS
  @future(callout=true)
  private static void sendSMSList(List<Id> idsPortion, string strBusinessUnit) {      
      List<Service_Settings__c> lstServiceSetting = [SELECT Business_Unit__c,Content_Type__c,
                                     CountryCode__c,Endpoint__c,Id,Name,NODE__c,
                                     Operation__c,PASSWORD__c,TRANSFORM__c,USERNAME__c, LogStatus__c 
                                     FROM Service_Settings__c WHERE Business_Unit__c = :strBusinessUnit];
      
      If(lstServiceSetting <> null && lstServiceSetting.size() > 0)
      {      
          Service_Settings__c serviceSetting = lstServiceSetting[0];
          NODE = serviceSetting.NODE__c;
          USERNAME = serviceSetting.USERNAME__c;
          PASSWORD = serviceSetting.PASSWORD__c;
          TRANSFORM = serviceSetting.TRANSFORM__c;
          endpoint = serviceSetting.Endpoint__c;
          contentType = serviceSetting.Content_Type__c;
          operation = serviceSetting.Operation__c;
          COUNTRY_CODE = serviceSetting.CountryCode__c;
          logStatus = serviceSetting.LogStatus__c;
      }   
      
       System.debug('****NODE****'+NODE+'******USERNAME****'+USERNAME+'****PASSWORD*****'+PASSWORD+'****TRANSFORM****'+TRANSFORM);
       System.debug('****endpoint****'+endpoint+'******contentType****'+contentType+'****operation*****'+operation+'****COUNTRY_CODE****'+COUNTRY_CODE
                   +'****EnableSendSMS****'+EnableSendSMS);
  
      List<SMS__c> smsListPortion = [SELECT Id, Mobile__c, Message__c, Return_SMS_ID__c, System_Exception_Message__c
      FROM SMS__c WHERE Id IN :idsPortion];
    
      Iterator<SMS__c> smsIterator = smsListPortion.iterator();
      while (smsIterator.hasNext()) {
        sendSMS(smsIterator.next());
      }
    
      update smsListPortion;
  }

  // send a single SMS
  private static void sendSMS(SMS__c sms) {
    try {
      // prepare send endpoint
      SendSMSService.SmsServiceBasicEndpoint sendEndpoint = new SendSMSService.SmsServiceBasicEndpoint();

      // construct SMS
      SendSMSService.SendSmsInput sendSmsInput = new SendSMSService.SendSmsInput();
      sendSmsInput.Node = NODE;
      sendSmsInput.Username = USERNAME;
      sendSmsInput.Password = PASSWORD;
      sendSmsInput.Transform = TRANSFORM;
      sms.Mobile__c = prepareMobilePhone(sms.Mobile__c);
      sendSmsInput.RecipientNumber = sms.Mobile__c;
      sendSmsInput.OperatorNumber = selectOperatorNumber(sms.Mobile__c);
      sendSmsInput.Message = sms.Message__c;

      // send SMS
      sendEndpoint.endpoint = endpoint;
      sendEndpoint.operation = operation;
      sendEndpoint.contentType = contentType;      
      
      Datetime dtStartTime = Datetime.Now();
      SendSMSService.SendSmsOutput sendSMSOutput = sendEndpoint.SendSms(sendSmsInput);
      Datetime dtEndTime = Datetime.Now();
      string serviceStatus = 'Success';

      if (sendSMSOutput.HTTPStatusCode == HTTP_SUCCESS_CODE) {
        // handle response
        if (sendSMSOutput.CommandStatus == SUCCESS_CODE) {
            // Success
            sms.Return_SMS_ID__c = sendSMSOutput.MessageId;
            sms.Status__c = 'Sent';
        } else {
            // Not Success
            serviceStatus = 'Failed';
            sms.Return_SMS_ID__c = sendSMSOutput.MessageId;
            sms.System_Exception_Message__c = 'SMS command status: ' + sendSMSOutput.CommandStatus;
        }
      } else {
        // Not Success
        sms.System_Exception_Message__c = 'HTTP status code: ' + sendSMSOutput.HTTPStatusCode + ' ' + sendSMSOutput.HTTPStatus;
      }
      
      If(logStatus)
      {
         sms.CalloutTime__c = dtEndTime.getTime() - dtStartTime.getTime();
         sms.Request_Body__c = JSON.serializepretty(sendSmsInput);
         sms.Response_Body__c = JSON.serializepretty(sendSMSOutput);
      }
    }
    catch (Exception e) {
      String exceptionMessage = e.getTypeName() + ':' + e.getMessage();
      sms.System_Exception_Message__c = 'Exception while sending: ' + exceptionMessage + '; Exception stack trace: ' + e.getStackTraceString();
    } 
  }

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
  
  @TestVisible
  public static String selectOperatorNumber(String mobilePhone) {
    String phoneNumber;
    
    Mobile_Operator__c mobileOperator = Mobile_Operator__c.getInstance(mobilePhone.left(4));
    if(mobileOperator != null)
          phoneNumber = mobileOperator.Value__C;
    else
    {
        mobileOperator = Mobile_Operator__c.getInstance(mobilePhone.left(5));
        if(mobileOperator != null)
            phoneNumber = mobileOperator.Value__C;
    }  
    
    return phoneNumber;
  }

}