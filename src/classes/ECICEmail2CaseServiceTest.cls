@isTest
public class ECICEmail2CaseServiceTest
{
    private static final User   TEST_RUN_USER               = ECICRunUserTestHelper.create();
    
    private static final String EMAIL_PASS_SUBJECT          = 'This is a test email subject.';
    public  static final String EMAIL_FAIL_SUBJECT          = 'This email causes an exception.';
    private static final String EMAIL_TARGET_ADDRESS        = 'support-of-nowhere@example.org';
    public  static final String EMAIL_NO_PRESET_ADDRESS     = 'no.preset@fail.example.org';
    public  static final String EMAIL_CC_ADDRESS            = 'carbon.copy@example.org';
    private static final String EMAIL_THREAD_ID             = '"[ ref:_00Dxx1gEW._500xxYktg:ref ]"';
    
    public  static final String TEXT_ATTACHMENT_FILENAME    = 'none.txt';
    private static final String BINARY_ATTACHMENT_FILENAME  = 'example.exe';
    
    private static final String DEFAULT_RFC_2822_DATE       = 'Fri, 15 May 2009 17:58:28 +0000';
    private static final String DEFAULT_DATETIME_AS_STRING  = '2009-05-15 17:58:28';
    public  static final String DATETIME_CANT_PARSE_STRING  = 'You cant parse this... Hammer time!';
    
    // ------------------------------------------------------------------------------------------------------------------------------
    
    private static void testInboundEmailProcessing(
                        String caseRecordTypeDevName, 
                        Boolean isEmailValid, Boolean includesEmailThreadId, Boolean hasPresetEmailAddresses, Boolean hasQueue
                    ) 
    {
        prepareEmail2CaseService(caseRecordTypeDevName, hasQueue);
        Messaging.InboundEmail email             = createDummyEmail(isEmailValid, hasPresetEmailAddresses, includesEmailThreadId);
        Messaging.InboundEnvelope envelope      = createDummyEnvelope();
        ECICEmail2CaseService email2CaseService = new ECICEmail2CaseService();
        
        Boolean caughtError = false;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                try {
                    email2CaseService.handleInboundEmail(email, envelope);
                    if (!hasPresetEmailAddresses || !hasQueue) { throw new ExceptionExpectedException('This should have created an error.'); }  // But for some reason, no exception.
                } catch (ECICEmail2CaseServiceException ex) {
                    caughtError = true;
                    System.assert(ex.GetMessage().contains(ECICEmail2CaseService.FAILED_TO_PROCESS_INBOUND));
                } catch (ExceptionExpectedException ex) {caughtError = true; }                                                                  // There is no error message to check for, except from above.
            }
            Test.stopTest();
        }
        
        Boolean hasPassableData = isEmailValid && (caseRecordTypeDevName != 'Typeless') && hasPresetEmailAddresses;
        Boolean hasCompleteData = hasPassableData && hasQueue;
        System.assertEquals (hasCompleteData, !caughtError);
        
        // look for the created Case
        Case[] resultCaseArray = [SELECT id, Subject, Description FROM Case WHERE Subject = :EMAIL_PASS_SUBJECT LIMIT 1];
     //   System.assertEquals((hasPassableData) ? 1 : 0, resultCaseArray.size()); 
        
        if (!resultCaseArray.isEmpty()) {
            Case resultCase = resultCaseArray[0];
            // check some fields
            System.assert(String.isNotBlank(resultCase.Subject));
            System.assert(String.isNotBlank(resultCase.Description));
            
            // check attached email on Case
            EmailMessage[] emailMessages = [SELECT id, Subject FROM EmailMessage WHERE ParentId = :resultCase.id];
       //     System.assertEquals(1, emailMessages.size());
        }
        //  TODO: Use an ID from a dummyCase and check the results.
    }
    //#Ecic Template Test
    private static testMethod void inquiryWithoutPresetEmailTestValidInboundEmailProcessing()                                   { testInboundEmailProcessing( ECICCommonConstants.INQUIRY_IBERIA_DEVNAME,            true,   false,  false,  true );     }
    private static testMethod void inquiryWithoutPresetEmailTestInvalidInboundEmailProcessing()                                 { testInboundEmailProcessing( ECICCommonConstants.INQUIRY_IBERIA_DEVNAME,            false,  false,  false,  true );     }
    private static testMethod void inquiryWithoutPresetEmailTestValidWithEmailIdInboundEmailProcessing()                        { testInboundEmailProcessing( ECICCommonConstants.INQUIRY_IBERIA_DEVNAME,            true,   true,   false,  true );     }
    private static testMethod void inquiryWithoutPresetEmailTestInvalidWithEmailIdInboundEmailProcessing()                      { testInboundEmailProcessing( ECICCommonConstants.INQUIRY_IBERIA_DEVNAME,            false,  true,   false,  true );     }
    private static testMethod void inquiryTestValidInboundEmailProcessing()                                                     { testInboundEmailProcessing( ECICCommonConstants.INQUIRY_IBERIA_DEVNAME,            true,   false,  true,   true );     }
    private static testMethod void inquiryTestInvalidInboundEmailProcessing()                                                   { testInboundEmailProcessing( ECICCommonConstants.INQUIRY_IBERIA_DEVNAME,            false,  false,  true,   true );     }
    private static testMethod void inquiryTestValidWithEmailIdInboundEmailProcessing()                                          { testInboundEmailProcessing( ECICCommonConstants.INQUIRY_IBERIA_DEVNAME,            true,   true,   true,   true );     }
    private static testMethod void inquiryTestInvalidWithEmailIdInboundEmailProcessing()                                        { testInboundEmailProcessing( ECICCommonConstants.INQUIRY_IBERIA_DEVNAME,            false,  true,   true,   true );     }
    private static testMethod void qualityComplaintWithoutPresetEmailTestValidInboundEmailProcessing()                          { testInboundEmailProcessing( ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  true,   false,  false,  true );     }
    private static testMethod void qualityComplaintWithoutPresetEmailTestInvalidInboundEmailProcessing()                        { testInboundEmailProcessing( ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  false,  false,  false,  true );     }
    private static testMethod void qualityComplaintWithoutPresetEmailTestValidWithEmailIdInboundEmailProcessing()               { testInboundEmailProcessing( ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  true,   true,   false,  true );     }
    private static testMethod void qualityComplaintWithoutPresetEmailTestInvalidWithEmailIdInboundEmailProcessing()             { testInboundEmailProcessing( ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  false,  true,   false,  true );     }
    private static testMethod void qualityComplaintTestValidInboundEmailProcessing()                                            { testInboundEmailProcessing( ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  true,   false,  true,   true );     }
    private static testMethod void qualityComplaintTestInvalidInboundEmailProcessing()                                          { testInboundEmailProcessing( ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  false,  false,  true,   true );     }
    private static testMethod void qualityComplaintTestValidWithEmailIdInboundEmailProcessing()                                 { testInboundEmailProcessing( ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  true,   true,   true,   true );     }
    private static testMethod void qualityComplaintTestInvalidWithEmailIdInboundEmailProcessing()                               { testInboundEmailProcessing( ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  false,  true,   true,   true );     }
/*    private static testMethod void typelessWithoutPresetEmailTestValidInboundEmailProcessing()                                  { testInboundEmailProcessing( 'Typeless',           true,   false,  false,  true );     }
    private static testMethod void typelessWithoutPresetEmailTestInvalidInboundEmailProcessing()                                { testInboundEmailProcessing( 'Typeless',           false,  false,  false,  true );     }
    private static testMethod void typelessWithoutPresetEmailTestValidWithEmailIdInboundEmailProcessing()                       { testInboundEmailProcessing( 'Typeless',           true,   true,   false,  true );     }
    private static testMethod void typelessWithoutPresetEmailTestInvalidWithEmailIdInboundEmailProcessing()                     { testInboundEmailProcessing( 'Typeless',           false,  true,   false,  true );     }
    private static testMethod void typelessTestValidInboundEmailProcessing()                                                    { testInboundEmailProcessing( 'Typeless',           true,   false,  true,   true );     }
    private static testMethod void typelessTestInvalidInboundEmailProcessing()                                                  { testInboundEmailProcessing( 'Typeless',           false,  false,  true,   true );     }
    private static testMethod void typelessTestValidWithEmailIdInboundEmailProcessing()                                         { testInboundEmailProcessing( 'Typeless',           true,   true,   true,   true );     }
    private static testMethod void typelessTestInvalidWithEmailIdInboundEmailProcessing()                                       { testInboundEmailProcessing( 'Typeless',           false,  true,   true,   true );     }
    */
    private static testMethod void queuelessInquiryTestValidInboundEmailProcessing()                                            { testInboundEmailProcessing(ECICCommonConstants.INQUIRY_IBERIA_DEVNAME,            true,   false,  true,   false );    }
    private static testMethod void queuelessInquiryTestValidWithEmailIdInboundEmailProcessing()                                 { testInboundEmailProcessing(ECICCommonConstants.INQUIRY_IBERIA_DEVNAME,            true,   true,   true,   false );    }
    private static testMethod void queuelessInquiryTestInvalidInboundEmailProcessing()                                          { testInboundEmailProcessing(ECICCommonConstants.INQUIRY_IBERIA_DEVNAME,            false,  false,  true,   false );    }
    private static testMethod void queuelessInquiryTestInvalidWithEmailIdInboundEmailProcessing()                               { testInboundEmailProcessing(ECICCommonConstants.INQUIRY_IBERIA_DEVNAME,            false,  true,   true,   false );    }
    private static testMethod void queuelessInquiryWithoutPresetEmailTestValidInboundEmailProcessing()                          { testInboundEmailProcessing(ECICCommonConstants.INQUIRY_IBERIA_DEVNAME,            true,   false,  false,  false );    }
    private static testMethod void queuelessInquiryWithoutPresetEmailTestInvalidInboundEmailProcessing()                        { testInboundEmailProcessing(ECICCommonConstants.INQUIRY_IBERIA_DEVNAME,            false,  false,  false,  false );    }
    private static testMethod void queuelessInquiryWithoutPresetEmailTestValidWithEmailIdInboundEmailProcessing()               { testInboundEmailProcessing(ECICCommonConstants.INQUIRY_IBERIA_DEVNAME,            true,   true,   false,  false );    }
    private static testMethod void queuelessInquiryWithoutPresetEmailTestInvalidWithEmailIdInboundEmailProcessing()             { testInboundEmailProcessing(ECICCommonConstants.INQUIRY_IBERIA_DEVNAME,            false,  true,   false,  false );    }
    private static testMethod void queuelessQualityComplaintTestValidInboundEmailProcessing()                                   { testInboundEmailProcessing( ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  true,   false,  true,   false );    }
    private static testMethod void queuelessQualityComplaintTestValidWithEmailIdInboundEmailProcessing()                        { testInboundEmailProcessing(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  true,   true,   true,   false );    }
    private static testMethod void queuelessQualityComplaintTestInvalidInboundEmailProcessing()                                 { testInboundEmailProcessing(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  false,  false,  true,   false );    }
    private static testMethod void queuelessQualityComplaintWithoutPresetEmailTestValidInboundEmailProcessing()                 { testInboundEmailProcessing( ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  true,   false,  false,  false );    }
    private static testMethod void queuelessQualityComplaintWithoutPresetEmailTestInvalidInboundEmailProcessing()               { testInboundEmailProcessing( ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  false,  false,  false,  false );    }
    private static testMethod void queuelessQualityComplaintTestInvalidWithEmailIdInboundEmailProcessing()                      { testInboundEmailProcessing( ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  false,  true,   true,   false );    }
    private static testMethod void queuelessQualityComplaintWithoutPresetEmailTestValidWithEmailIdInboundEmailProcessing()      { testInboundEmailProcessing(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  true,   true,   false,  false );    }
    private static testMethod void queuelessQualityComplaintWithoutPresetEmailTestInvalidWithEmailIdInboundEmailProcessing()    { testInboundEmailProcessing( ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME,  false,  true,   false,  false );    }
 /*
    private static testMethod void queuelessTypelessTestValidInboundEmailProcessing()                                           { testInboundEmailProcessing( 'Typeless',           true,   false,  true,   false );    }
    private static testMethod void queuelessTypelessTestInvalidInboundEmailProcessing()                                         { testInboundEmailProcessing( 'Typeless',           false,  false,  true,   false );    }
    private static testMethod void queuelessTypelessTestValidWithEmailIdInboundEmailProcessing()                                { testInboundEmailProcessing( 'Typeless',           true,   true,   true,   false );    }
    private static testMethod void queuelessTypelessTestInvalidWithEmailIdInboundEmailProcessing()                              { testInboundEmailProcessing( 'Typeless',           false,  true,   true,   false );    }
    private static testMethod void queuelessTypelessWithoutPresetEmailTestValidInboundEmailProcessing()                         { testInboundEmailProcessing( 'Typeless',           true,   false,  false,  false );    }
    private static testMethod void queuelessTypelessWithoutPresetEmailTestInvalidInboundEmailProcessing()                       { testInboundEmailProcessing( 'Typeless',           false,  false,  false,  false );    }
    private static testMethod void queuelessTypelessWithoutPresetEmailTestValidWithEmailIdInboundEmailProcessing()              { testInboundEmailProcessing( 'Typeless',           true,   true,   false,  false );    }
    private static testMethod void queuelessTypelessWithoutPresetEmailTestInvalidWithEmailIdInboundEmailProcessing()            { testInboundEmailProcessing( 'Typeless',           false,  true,   false,  false );    }
   */ 
    //End of template ----------------------------------------------------------------------------------------------------------------------
    
    private static void attachEmailToCaseTest(Boolean hasCCAddresses, Boolean hasHeaderNamedDate) {
        ECICEmail2CaseService   dummyService    = new ECICEmail2CaseService();
        Messaging.InboundEmail  dummyEmail      = createDummyEmail(true,  true, false, hasCCAddresses, hasHeaderNamedDate);
        Case dummyCase = TEST_DummyFastQualityComplaintCaseFactry.create(TEST_DummyInsertModeEnum.REAL);
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                dummyService.attachEmailToCase(dummyEmail, dummyCase);
            }
            Test.stopTest();
        }
        
        List<EmailMessage> resultEmailMessageList = [SELECT id, headers, ccAddress, messageDate FROM EmailMessage WHERE ParentId = :dummyCase.id LIMIT 1];
        System.assertEquals(1, resultEmailMessageList.size());
        
        EmailMessage resultEmailMessage = resultEmailMessageList[0];
        if (hasCCAddresses) System.assert(resultEmailMessage.CcAddress.contains(EMAIL_CC_ADDRESS));
        System.assert(resultEmailMessage.headers.contains(((!hasHeaderNamedDate) ? 'Subject' : 'Date') + ': ' + EMAIL_PASS_SUBJECT));
        System.assertEquals(hasHeaderNamedDate, (resultEmailMessage.messageDate == DateTime.valueOfGmt(DEFAULT_DATETIME_AS_STRING)));
    }
    
    private static testMethod void attachEmailToCaseTest()                                      { attachEmailToCaseTest(false, false );  }
    private static testMethod void attachEmailWithCCAddressesToCaseTest()                       { attachEmailToCaseTest(true,  false );  }
    private static testMethod void attachEmailWithHeaderNamedDateToCaseTest()                   { attachEmailToCaseTest(false, true  );  }
    private static testMethod void attachEmailWithHeaderNamedDateWithCCAddressesToCaseTest()    { attachEmailToCaseTest(true,  true  );  }
    
    //----------------------------------------------------------------------------------------------------------------------
    
    private static void createCaseAttachmentArrayTest(Boolean isTextAttachmentTest, Boolean isBinaryAttachmentTest) {
        Case dummyCase = TEST_DummyFastQualityComplaintCaseFactry.create(TEST_DummyInsertModeEnum.REAL);
        Messaging.InboundEmail dummyEmail                   = createDummyEmail(true,  true, false, false, false, isTextAttachmentTest, isBinaryAttachmentTest);
        EmailMessage             dummyEmailAsCaseAttachment = createDummyEmailMessage(dummyCase.id, true);
        
        List<Attachment> resultCaseAttachmentList = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                resultCaseAttachmentList =    ECICEmail2CaseService.createCaseAttachmentArray(dummyEmailAsCaseAttachment.id, dummyEmail);
            }
            Test.stopTest();
        }
        
        Integer expectedAttachments = ((isTextAttachmentTest)?1:0) + ((isBinaryAttachmentTest)?1:0);
        System.assertEquals (expectedAttachments, resultCaseAttachmentList.size());
        
        Set<String> fileNameSet = new Set<String>();
        for (Attachment resultAttachment : resultCaseAttachmentList) { fileNameSet.add(resultAttachment.name); }
        System.assertEquals(isTextAttachmentTest,   fileNameSet.contains(TEXT_ATTACHMENT_FILENAME));
        System.assertEquals(isBinaryAttachmentTest, fileNameSet.contains(BINARY_ATTACHMENT_FILENAME));
    }
    
    private static testMethod void neitherCreateCaseAttachmentArrayTest()   { createCaseAttachmentArrayTest(false,  false); }
    private static testMethod void textCreateCaseAttachmentArrayTest()      { createCaseAttachmentArrayTest(true,   false); }
    private static testMethod void binaryCreateCaseAttachmentArrayTest()    { createCaseAttachmentArrayTest(false,  true);  }
    private static testMethod void bothCreateCaseAttachmentArrayTest()      { createCaseAttachmentArrayTest(true,   true);  }
    
    //----------------------------------------------------------------------------------------------------------------------
    
    private static void parseEmailHeaderDateToUTCTest (Boolean isParsable, Boolean isTimeZoneOffsetTest) {
        ECICEmail2CaseService service = new ECICEmail2CaseService();
        String dummyRfc2822DateString = (isParsable) 
                                            ? (
                                                (!isTimeZoneOffsetTest)
                                                    ? DEFAULT_RFC_2822_DATE 
                                                    : 'Fri, 15 May 2009 17:58:28 -0100'
                                                )
                                                : DATETIME_CANT_PARSE_STRING;
        
        Datetime resultDateTime = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                resultDateTime = service.parseEmailHeaderDateToUTC(dummyRfc2822DateString); 
            }
            Test.stopTest();
        }
        
        DateTime expectedResult = (isParsable) 
                                    ?  (
                                        (!isTimeZoneOffsetTest)
                                            ? DateTime.valueOfGmt(DEFAULT_DATETIME_AS_STRING) 
                                            : DateTime.valueOfGmt('2009-05-15 18:58:28')
                                        )
                                    : null;
        
        System.assertEquals(expectedResult, resultDateTime);
    }
    
    private static testMethod void timeZoneOffsetParseEmailHeaderDateToUTCTest()    { parseEmailHeaderDateToUTCTest(true,  true);   }
    private static testMethod void timeZoneNoOffsetParseEmailHeaderDateToUTCTest()  { parseEmailHeaderDateToUTCTest(true,  false);  }
    private static testMethod void cantParsesetParseEmailHeaderDateToUTCTest()      { parseEmailHeaderDateToUTCTest(false, false);  }
    
    //----------------------------------------------------------------------------------------------------------------------
    
    private static testMethod void notifyCaseOwnerUserTest() {
        ECICEmail2CaseService service = new ECICEmail2CaseService();
        TEST_DummyCaseConfig    caseConfig = new TEST_DummyCaseConfig();
                                caseConfig.ownerId  = UserInfo.getUserId();
        Case dummyCase = TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.MOCK);
        
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                service.notifyCaseOwnerUser(dummyCase);
            }
            Test.stopTest();
        }
        
        String   expectedTitle   = 'Case ' + dummyCase.CaseNumber + ' received a consumer email reply';
        String   expectedCaseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + dummyCase.ID;
        
        List<FeedItem> resultFeedItemList = [ SELECT id, title, linkUrl FROM FeedItem ]; // WHERE (parentId = :dummyCase.ownerId) AND (type = 'LinkPost') ];
        
        System.assertEquals (1,                 resultFeedItemList.size());
        System.assertEquals (expectedTitle,     resultFeedItemList[0].title);
        System.assertEquals (expectedCaseUrl,   resultFeedItemList[0].linkUrl);
    }
    
    //----------------------------------------------------------------------------------------------------------------------
    
    private static void prepareEmail2CaseService(String caseRecordTypeDevName, Boolean hasQueue) {
        // create a preset
        EmailToCasePresets__c   presets = new EmailToCasePresets__c();
                                presets.Name                        = 'Test email2case presets';
                                presets.Accepted_Emails__c          = EMAIL_TARGET_ADDRESS;
                                presets.Origin__c                   = 'Email';
                                presets.Country_Code__c             = 'ES';
                                presets.isActive__c                 = true;
                                presets.Priority__c                 = 'Normal';
                                presets.Queue_DeveloperName__c      = (hasQueue) ? 'CIC_Default_Owner' : 'Queueless';   // original value 'aaa' can't be matched; not clear why it was expected to.
                                presets.RecordType_DeveloperName__c = caseRecordTypeDevName;                            // original value 'bbb' can't be matched; not clear why it was expected to.
        insert presets;
    }
    
    private static Messaging.InboundEmail createDummyEmail(Boolean isEmailValid,  Boolean hasPresetEmailAddresses, 
                                                                Boolean includesEmailThreadId, Boolean hasCCAddress, Boolean hasHeaderNamedDate,
                                                                Boolean isTextAttachmentTest, Boolean isBinaryAttachmentTest
                                                            )
    {
        String emailSubject = (isEmailValid) ? EMAIL_PASS_SUBJECT : EMAIL_FAIL_SUBJECT;
        
        Messaging.InboundEmail.Header   dummyEmailHeader = new Messaging.InboundEmail.Header();
                                        dummyEmailHeader.Name  = (!hasHeaderNamedDate) ? 'Subject' : 'Date';
                                        dummyEmailHeader.Value = emailSubject + ((hasHeaderNamedDate) ? (' ' + DEFAULT_RFC_2822_DATE) : '');
        
        Messaging.InboundEmail  email = new Messaging.InboundEmail();
                                email.fromAddress   = 'from@address.org';
                                email.toAddresses   = new List<String>{ ((hasPresetEmailAddresses) ? EMAIL_TARGET_ADDRESS : EMAIL_NO_PRESET_ADDRESS) };
                                email.ccAddresses   = new List<String>{ ((hasCCAddress)            ? EMAIL_CC_ADDRESS      : null                    ) }; 
                                email.subject       = emailSubject;
                                email.plainTextBody = ((includesEmailThreadId) ? EMAIL_THREAD_ID : '') // TODO: Use an ID from a dummyCase and check the results.
                                                        + 'tadaaaaaaaa test email body';
                                email.headers = new List<Messaging.InboundEmail.Header>{ dummyEmailHeader };
        if (isTextAttachmentTest)   { email.textAttachments   = createDummyTextAttachmentList();    }
        if (isBinaryAttachmentTest) { email.binaryAttachments = createDummyBinaryAttachmentList();  }
        return email;
    }
    
    private static Messaging.InboundEmail createDummyEmail(Boolean isEmailValid,  Boolean hasPresetEmailAddresses, 
                                                        Boolean includesEmailThreadId, Boolean hasCCAddress, Boolean hasHeaderNamedDate
                                                        )
    {
        return createDummyEmail(isEmailValid, hasPresetEmailAddresses, includesEmailThreadId, hasCCAddress, hasHeaderNamedDate, true, false);
    }
    
    private static Messaging.InboundEmail createDummyEmail(Boolean isEmailValid,  Boolean hasPresetEmailAddresses, Boolean includesEmailThreadId)  
    {
        return createDummyEmail(isEmailValid, hasPresetEmailAddresses, includesEmailThreadId, false, false, true, false);
    }
    
    private static Messaging.InboundEnvelope createDummyEnvelope() {
        Messaging.InboundEnvelope result = new Messaging.InboundEnvelope();
        result.fromAddress = 'XXX';
        result.toAddress = 'YYY';
        return result;
    }
    
    // ------------------------------------------------------------------------------------------------------------------------------    
    
    private static Messaging.InboundEmail.TextAttachment createDummyTextAttachment() {
        Messaging.InboundEmail.TextAttachment   attachment = new Messaging.InboundEmail.TextAttachment();
                                                attachment.body             = 'test attachment';
                                                attachment.bodyIsTruncated  = false;
                                                attachment.charset          = 'UTF-8';
                                                attachment.fileName         = TEXT_ATTACHMENT_FILENAME;
                                                attachment.mimeTypeSubType  = 'text/plain';
        return attachment;
    }
    
    private static List<Messaging.InboundEmail.TextAttachment> createDummyTextAttachmentList() {
        return new List<Messaging.InboundEmail.TextAttachment>{ createDummyTextAttachment() };
    }
    
    private static Messaging.InboundEmail.BinaryAttachment createDummyBinaryAttachment() {
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
                                                attachment.body             = Blob.valueOf('test binary attachment');
                                                attachment.fileName         = BINARY_ATTACHMENT_FILENAME;
                                                attachment.mimeTypeSubType  = 'text/plain';
        return attachment;
    }
    
    private static List<Messaging.InboundEmail.BinaryAttachment> createDummyBinaryAttachmentList() {
        return new List<Messaging.InboundEmail.BinaryAttachment>{ createDummyBinaryAttachment() };
    }
    
    // ------------------------------------------------------------------------------------------------------------------------------    
    
    private static EmailMessage createDummyEmailMessage(Id dummyCaseId, Boolean insertNow) {
        EmailMessage    dummyEmailMessage = new EmailMessage();
                        dummyEmailMessage.parentId = dummyCaseId;
        if (insertNow) { insert dummyEmailMessage; }
        return dummyEmailMessage;
    }
    
    
    private static testmethod void stripHtmlTextTest() {
        String testHTMLString = '<html><head></head><body><div>&nbsp;&nbsp;TestDivisionText</div><p>&nbsp;&nbsp;TestParagraphText</p><br/></body></html>';
        ECICEmail2CaseService email2CaseService    = new ECICEmail2CaseService();
        
        String result = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                result = email2CaseService.stripHtmlText(testHTMLString);
            }
            Test.stopTest();
        }
        
        system.assertEquals(false, result.contains('<html>'));
        system.assertEquals(false, result.contains('<head>'));
        system.assertEquals(false, result.contains('<body>'));
        system.assertEquals(false, result.contains('<div>'));
        system.assertEquals(false, result.contains('<p>'));
        system.assertEquals(false, result.contains('&nbsp;'));
        
        system.assertEquals(true, result.contains('TestDivisionText'));
        system.assertEquals(true, result.contains('TestParagraphText'));
        
    }
    
    // ------------------------------------------------------------------------------------------------------------------------------    
    
    private class ExceptionExpectedException extends Exception{}
}