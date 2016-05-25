/* Google Translate API */

public class HUB_TranslateUtil{
    
    public static String TRANSLATE_URI = '';
    public static String DETECT_URI = '';
    public static String APIKey = '';
    public static String targetLanguage='en';
    
    
   
    
    public static String googleTranslateText(String sourceLanguage,String sourceText)
    {
        
        TRANSLATE_URI = HUB_Google_Translate_API_Config__c.getInstance().Translate_URI__c;
        DETECT_URI = HUB_Google_Translate_API_Config__c.getInstance().Detect_URI__c;
        APIKey= HUB_Google_Translate_API_Config__c.getInstance().API_Key__c;
        
        String output;
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        string sourceTextEncode=EncodingUtil.urlEncode(sourceText,'UTF-8');
        
        String endpoint=TRANSLATE_URI + 'key=' + APIKey + '&source='+ sourceLanguage + '&target=' + targetLanguage + '&q=' + sourceTextEncode;
        System.debug('****'+endpoint);
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        
        if(!Test.isRunningTest()){
            res = http.send(req);
        }else{
            res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{ "data": {  "translations": [   {    "translatedText": "This is awesome text to test."   }  ] }}');
        }

        System.debug('RESPONSE BODY: ' +res.getBody());
        System.debug('RESPONSE: ' +res.toString());
        System.debug('STATUS:'+res.getStatus());
        System.debug('STATUS_CODE:'+res.getStatusCode());
        //parse the JSON
        JSONParser parser = JSON.createParser(res.getBody());
        while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                    String fieldName = parser.getText();
                    parser.nextToken();
                    if(fieldName == 'translatedText') {
                        output = parser.getText();
                        break;
                    } 
                }// end of if
        } // end of while


        return output;
        
    
    } // end of method
    
    public static String googleDetectTextLanguage(String sourceText){
        
        TRANSLATE_URI = HUB_Google_Translate_API_Config__c.getInstance().Translate_URI__c;
        DETECT_URI = HUB_Google_Translate_API_Config__c.getInstance().Detect_URI__c;
        APIKey= HUB_Google_Translate_API_Config__c.getInstance().API_Key__c;
        
        String output;
        
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        string sourceTextEncode=EncodingUtil.urlEncode(sourceText,'UTF-8');
        
        String endpoint=DETECT_URI + 'key=' + APIKey  + '&q=' + sourceTextEncode;
        System.debug('****'+endpoint);
        req.setEndpoint(endpoint);
        req.setMethod('GET');
         req.setHeader('content-type', 'application/x-www-form-urlencoded');
        
        
        if(!Test.isRunningTest()){
            res = http.send(req);
        }else{
            res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('{"data": {  "detections": [   [    {     "language": "el",     "isReliable": false,     "confidence": 0.05579675    }   ]  ] }}');
        }
        
        
        System.debug('RESPONSE BODY: ' +res.getBody());
        System.debug('RESPONSE: ' +res.toString());
        System.debug('STATUS:'+res.getStatus());
        System.debug('STATUS_CODE:'+res.getStatusCode());
        
        JSONParser parser = JSON.createParser(res.getBody());
        while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                    String fieldName = parser.getText();
                    parser.nextToken();
                    if(fieldName == 'language') {
                        output = parser.getText();
                        break;
                    } 
                }// end of if
        } // end of while
        
        return output;
    
    } // end of method


} // end of classfkey