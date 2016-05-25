@isTest
global class CCCSABU_SendSMSServiceMockImpl implements HttpCalloutMock {
    
    public static final String TEST_MESSAGE_ID = 'testMessageId';
    public static final String COMMAND_STATUS = '0x0';
    
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('http://196.11.240.180:8080/mtnusa/client.jsp', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        Dom.Document doc = new Dom.Document();
        Dom.XmlNode usarsp = doc.createRootElement('usarsp', null, null);
        Dom.XmlNode datablock = usarsp.addChildElement('datablock', null, null);
        datablock.addChildElement('commandStatus', null, null).addTextNode(COMMAND_STATUS);
        datablock.addChildElement('sequenceNumber', null, null).addTextNode('sequenceNumber');
        datablock.addChildElement('messageId', null, null).addTextNode(TEST_MESSAGE_ID);
        res.setBody(doc.toXmlString());
        res.setStatusCode(200);
        return res;
    }
    
}