public class SendSMSService {
    //  Example HTTP2SMS SMS Submission:
    //  http://196.11.240.180:8080/mtnusa/client.jsp?command=
    //  <usareq NODE="colaHTTP" USERNAME="colaHTTP" PASSWORD="Zqs2Zkh6" TRANSFORM="SUBMIT_SM">
    //      <command>
    //          <submit_sm>
    //              <a_number>278393001780576</a_number>
    //              <b_number>27891234567</b_number>
    //              <service_type/>
    //              <message>Test</message>
    //              <registered_delivery/>
    //          </submit_sm>
    //      </command>
    //  </usareq>
    
    public class RequestException extends Exception {}
    
    public class SendSmsInput {
        public String Node;
        public String Username;
        public String Password;
        public String Transform;
        public String OperatorNumber;
        public String RecipientNumber;
        public String Message;
        public Dom.Document getDomDocument() {
            Dom.Document doc = new Dom.Document();
            try {
                Dom.XmlNode usareq = doc.createRootElement('usareq', null, null);
                usareq.setAttribute('NODE', this.Node);
                usareq.setAttribute('USERNAME', this.Username);
                usareq.setAttribute('PASSWORD', this.Password);
                usareq.setAttribute('TRANSFORM', this.Transform);
                Dom.XmlNode command  = usareq.addChildElement('command', null, null);
                Dom.XmlNode submit_sm  = command.addChildElement('submit_sm', null, null);
                submit_sm.addChildElement('a_number', null, null).addTextNode(this.OperatorNumber);
                submit_sm.addChildElement('service_type', null, null);
                submit_sm.addChildElement('message', null, null).addTextNode(this.Message);
                submit_sm.addChildElement('registered_delivery', null, null);
                submit_sm.addChildElement('b_number', null, null).addTextNode(this.RecipientNumber);
            } catch (Exception e){
                if (this.OperatorNumber == null) {
                    throw new RequestException('Not found operator number! (Prefix mobile number '+ this.RecipientNumber + ' doesn\'t belong to no one operators.)', e  );
                }
                throw new RequestException('Exception in HTTP Request body. Body: ' + doc, e);
            }
            return doc;
        }
    }
    public class SmsServiceBasicEndpoint {
        public String endpoint;
        public String operation;
        public String contentType;
        public SendSMSService.SendSmsOutput SendSms(SendSMSService.SendSmsInput value) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(this.endpoint);
            req.setHeader('Content-Type', this.contentType);
            req.setMethod(this.operation);
            req.setBody('command=' + value.getDomDocument().toXmlString());
            Http http = new Http();
            
            Common_Settings__c settingFakeResponse = Common_Settings__c.getInstance('SMSFakeResponse');
            Boolean SendFakeResponse = settingFakeResponse == null ? false : ('true'.equalsIgnoreCase(settingFakeResponse.Value__c));
            
            HTTPResponse response;
            If(!SendFakeResponse)            
                response = http.send(req);            
            else
                response = fakeHttpResponse();
            
            return new SendSMSService.SendSmsOutput(response);
        }
        
        private HTTPResponse fakeHttpResponse()
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            Dom.Document doc = new Dom.Document();
            Dom.XmlNode usarsp = doc.createRootElement('usarsp', null, null);
            Dom.XmlNode datablock = usarsp.addChildElement('datablock', null, null);
            
            Common_Settings__c setting = Common_Settings__c.getInstance('SMSFakeResponseSuccess');
            Boolean SendSuccess = setting == null ? true : ('true'.equalsIgnoreCase(setting.Value__c));
            If(SendSuccess)
            {
                List<SMS__c> lstSMS = [Select Return_SMS_ID__c from SMS__c where Return_SMS_ID__c <> null order by CreatedDate desc Limit 1];
                Integer messageId = 1;
                If(lstSMS != null && lstSMS.size() > 0)
                {
                    If(lstSMS[0].Return_SMS_ID__c.isNumeric())
                    {
                        messageId = Integer.ValueOf(lstSMS[0].Return_SMS_ID__c) + 1;
                    }
                }
                datablock.addChildElement('commandStatus', null, null).addTextNode('0x0');
                datablock.addChildElement('messageId', null, null).addTextNode(String.ValueOf(messageId));
            }
            else
            {
                datablock.addChildElement('commandStatus', null, null).addTextNode('Service failed.');
                datablock.addChildElement('messageId', null, null).addTextNode('');
            }
            
            datablock.addChildElement('sequenceNumber', null, null).addTextNode('sequenceNumber');
            res.setBody(doc.toXmlString());
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class ResponseException extends Exception {}
    
    // Response example:
    //  <usarsp COMMAND="submit_sm" INSTANCE="iwsusa2" NODE="colaHTTP" REQ_ID="1369630518053_117429347" RESPONSE_TIME="135" TRANSFORM="SUBMIT_SM" USERNAME="colaHTTP">
    //      <datablock NAME="SMPP RESPONSE DATA">
    //          <commandStatus>0x0</commandStatus> 
    //          <sequenceNumber>99369084</sequenceNumber> 
    //          <messageId>471A7368</messageId> 
    //      </datablock>
    //  </usarsp>
    public class SendSmsOutput {
        public Integer HTTPStatusCode;
        public String HTTPStatus;
        public String CommandStatus;
        public String SequenceNumber;
        public String MessageId;
        public SendSmsOutput(HTTPResponse response) {
            this.HTTPStatusCode = response.getStatusCode();
            this.HTTPStatus = response.getStatus();
            if (HTTPStatusCode == 200) {
                try {
                    Dom.Document doc = response.getBodyDocument();
                    Dom.XmlNode usarsp = doc.getRootElement();
                    Dom.XmlNode datablock = usarsp.getChildElement('datablock', null);
                    this.CommandStatus = datablock.getChildElement('commandStatus', null).getText();
                    this.SequenceNumber = datablock.getChildElement('sequenceNumber', null).getText();
                    this.MessageId = datablock.getChildElement('messageId', null).getText();
                } catch (Exception e){
                    throw new ResponseException('Exception in HTTP Responce body. Body: ' + response.getBody(), e);
                }
            }
        }
    }
}