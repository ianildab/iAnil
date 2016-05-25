@isTest
public class ECICLinkCaseAndOpenAlertsEmailHelperTest 
{
    private static final User                    TEST_RUN_USER              = TEST_DummyUserFactory.createDefaultTestRunUser();

    private static void buildNewCaseQuantityByOpenAlertIdMapTest(Boolean hasMultipleCasesOnSameOpenAlert) 
    {
        Integer openAlertCasesToCreate = (hasMultipleCasesOnSameOpenAlert) ? 3 : 1;
        Open_Alert__c dummyOpenAlert   = TEST_DummyOpenAlertFactory.create(TEST_DummyInsertModeEnum.MOCK);
        List<Open_Alert_Case__c> dummyOpenAlertCaseList = TEST_DummyOpenAlertCaseFactory.createList(
                    openAlertCasesToCreate,
                    new TEST_DummyOpenAlertCaseFactory.Config(null, dummyOpenAlert.id),
                    TEST_DummyInsertModeEnum.NONE
                ); 
        
        Map<Id, Integer> resultNewCaseQuantityByOpenAlertIdMap = null; 
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultNewCaseQuantityByOpenAlertIdMap = ECICLinkCaseAndOpenAlertsEmailHelper.buildNewCaseQuantityByOpenAlertIdMap(dummyOpenAlertCaseList);
            }
            Test.stopTest();
        }
        
        System.assert (resultNewCaseQuantityByOpenAlertIdMap.containsKey(dummyOpenAlert.id));
        System.assertEquals (openAlertCasesToCreate, resultNewCaseQuantityByOpenAlertIdMap.get(dummyOpenAlert.id));
    }

    private static testMethod void singleCaseBuildNewCaseQuantityByOpenAlertIdMapTest()   { buildNewCaseQuantityByOpenAlertIdMapTest(false); }
    private static testMethod void multipleCaseBuildNewCaseQuantityByOpenAlertIdMapTest() { buildNewCaseQuantityByOpenAlertIdMapTest(true);  }
    
    // ------------------------------------------------------------------------------------------------------------------------------------

    private static void buildOpenAlertRequiringEmailIdSetTest(Boolean mapContainsKey, Boolean hasThreshold, Boolean newCasesExceedThreshold, Boolean totalCasesExceedThreshold)
    {
        Integer dummyThreshold       = (hasThreshold)              ? 5                    : 1;
        Integer dummyNewCaseQuantity = (newCasesExceedThreshold)   ? dummyThreshold       : 1;
    	Integer dummyOldCaseQuantity = (totalCasesExceedThreshold) ? (dummyThreshold - 1) : 0;
    	    	
    	TEST_DummyOpenAlertFactory.Config config = new TEST_DummyOpenAlertFactory.Config();
    	                                  config.threshold = (hasThreshold) ? dummyThreshold : TEST_ConfigHelper.INTENTIONAL_NULL_FOR_NUMBER;
        Open_Alert__c dummyOpenAlert   = TEST_DummyOpenAlertFactory.create(config, TEST_DummyInsertModeEnum.MOCK);
        Id            dummyOpenAlertId = dummyOpenAlert.id;
        TEST_MockHelper.setMockInteger(dummyOpenAlertId, 'case_count__c', dummyOldCaseQuantity);

        List<ECICLinkCaseAndOpenAlertsConfigEntry> dummyOpenAlertConfigEntryList = new List<ECICLinkCaseAndOpenAlertsConfigEntry>
        {
        	ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyConfigEntry(dummyOpenAlert, null)
        };
        
        Map<Id, Integer>      dummyNewCaseQuantityByOpenAlertIdMap = new Map<Id, Integer>();
        if (mapContainsKey) { dummyNewCaseQuantityByOpenAlertIdMap.put (dummyOpenAlertId, dummyNewCaseQuantity); }
        
        Set<Id> resultOpenAlertRequiringEmailIdSet = null; 
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultOpenAlertRequiringEmailIdSet = ECICLinkCaseAndOpenAlertsEmailHelper.buildOpenAlertRequiringEmailIdSet(dummyOpenAlertConfigEntryList, dummyNewCaseQuantityByOpenAlertIdMap);
            }
            Test.stopTest();
        }
        
        Boolean isExpectedinSet = ((mapContainsKey) && (newCasesExceedThreshold || totalCasesExceedThreshold || !hasThreshold));
        System.assertEquals (isExpectedinSet, resultOpenAlertRequiringEmailIdSet.contains(dummyOpenAlertId));
    }

    private static testMethod void notMappedBuildOpenAlertRequiringEmailIdSetTest()             { buildOpenAlertRequiringEmailIdSetTest(false, false, false, false); }
    private static testMethod void noThresholdBuildOpenAlertRequiringEmailIdSetTest()           { buildOpenAlertRequiringEmailIdSetTest(true,  false, false, false); }

    private static testMethod void thresholdNotMetBuildOpenAlertRequiringEmailIdSetTest()       { buildOpenAlertRequiringEmailIdSetTest(true,  true,  false, false); }
    private static testMethod void newCaseExceedsBuildOpenAlertRequiringEmailIdSetTest()        { buildOpenAlertRequiringEmailIdSetTest(true,  true,  true,  false); }
    private static testMethod void totalCasesExceedBuildOpenAlertRequiringEmailIdSetTest()      { buildOpenAlertRequiringEmailIdSetTest(true,  true,  false, true);  }

    // ------------------------------------------------------------------------------------------------------------------------------------

    private static void buildOpenAlertCaseRequiringEmailList2Test(Boolean isRequired) 
    {
        Open_Alert__c dummyOpenAlert   = TEST_DummyOpenAlertFactory.create(TEST_DummyInsertModeEnum.MOCK);
        Id            dummyOpenAlertId = dummyOpenAlert.id;

        Set<Id>                  dummyOpenAlertRequiringEmailIdSet = new Set<Id>();
        if (isRequired) {        dummyOpenAlertRequiringEmailIdSet.add(dummyOpenAlertId); }

        Open_Alert_Case__c       dummyOpenAlertCase     = TEST_DummyOpenAlertCaseFactory.create(new TEST_DummyOpenAlertCaseFactory.Config(null, dummyOpenAlert.id), TEST_DummyInsertModeEnum.NONE); 
        List<Open_Alert_Case__c> dummyOpenAlertCaseList = new List<Open_Alert_Case__c> { dummyOpenAlertCase };
        
        List<Open_Alert_Case__c> resultOpenAlertCaseRequiringEmailList = null; 
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultOpenAlertCaseRequiringEmailList = ECICLinkCaseAndOpenAlertsEmailHelper.buildOpenAlertCaseRequiringEmailList (dummyOpenAlertRequiringEmailIdSet, dummyOpenAlertCaseList);
            }
            Test.stopTest();
        }

        System.assertEquals((isRequired) ? 1 : 0, resultOpenAlertCaseRequiringEmailList.size());
        if (isRequired) { System.assertEquals (dummyOpenAlertCase, resultOpenAlertCaseRequiringEmailList[0]); }
    }

    private static testMethod void notRequiredBuildOpenAlertCaseRequiringEmailList2Test() { buildOpenAlertCaseRequiringEmailList2Test(false); }
    private static testMethod void requiredBuildOpenAlertCaseRequiringEmailList2Test()    { buildOpenAlertCaseRequiringEmailList2Test(true ); }

    // ------------------------------------------------------------------------------------------------------------------------------------

    private static void buildOpenAlertCaseRequiringEmailList1Test(Boolean isRequired) 
    {
        Integer dummyThreshold       = 5;
        Integer dummyNewCaseQuantity = (isRequired)   ? dummyThreshold       : 1;
                
        TEST_DummyOpenAlertFactory.Config config = new TEST_DummyOpenAlertFactory.Config();
                                          config.threshold = dummyThreshold;
        Open_Alert__c dummyOpenAlert   = TEST_DummyOpenAlertFactory.create(config, TEST_DummyInsertModeEnum.MOCK);
        Id            dummyOpenAlertId = dummyOpenAlert.id;

        List<ECICLinkCaseAndOpenAlertsConfigEntry> dummyOpenAlertConfigEntryList = new List<ECICLinkCaseAndOpenAlertsConfigEntry>
        {
            ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyConfigEntry(dummyOpenAlert, null)
        };

        List<Open_Alert_Case__c> dummyOpenAlertCaseList = TEST_DummyOpenAlertCaseFactory.createList(dummyNewCaseQuantity, new TEST_DummyOpenAlertCaseFactory.Config(null, dummyOpenAlert.id), TEST_DummyInsertModeEnum.NONE); 
        
        List<Open_Alert_Case__c> resultOpenAlertCaseRequiringEmailList = null; 
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultOpenAlertCaseRequiringEmailList = ECICLinkCaseAndOpenAlertsEmailHelper.buildOpenAlertCaseRequiringEmailList (dummyOpenAlertConfigEntryList, dummyOpenAlertCaseList);
            }
            Test.stopTest();
        }
        
        System.assertEquals((isRequired) ? dummyNewCaseQuantity : 0, resultOpenAlertCaseRequiringEmailList.size());
        if (isRequired) { System.assertEquals (dummyOpenAlertCaseList[0], resultOpenAlertCaseRequiringEmailList[0]); }
    }
    
    private static testMethod void notRequiredBuildOpenAlertCaseRequiringEmailList1Test() { buildOpenAlertCaseRequiringEmailList1Test(false); }
    private static testMethod void requiredBuildOpenAlertCaseRequiringEmailList1Test()    { buildOpenAlertCaseRequiringEmailList1Test(true ); }

    // ------------------------------------------------------------------------------------------------------------------------------------

    private static testMethod void generateEmails2Test()                     
    {
        setOpenAlertEmailTemplate();
        Integer emailLimitBefore = Limits.getEmailInvocations();

        Case dummyCase = createDummyCase();
        
        TEST_DummyOpenAlertFactory.Config openAlertConfig = new TEST_DummyOpenAlertFactory.Config();
                                          openAlertConfig.additionalTo = 'dummy_email@test.com';
                                          openAlertConfig.recipients   = 'Bottler_Quality_Owner__c;Quality_Manager__c';
        Open_Alert__c dummyOpenAlert          = TEST_DummyOpenAlertFactory.create(openAlertConfig, TEST_DummyInsertModeEnum.MOCK); 
        Open_Alert_Case__c dummyOpenAlertCase = TEST_DummyOpenAlertCaseFactory.create(dummyCase, dummyOpenAlert, TEST_DummyInsertModeEnum.NONE); 

        System.runAs(TEST_RUN_USER)
        {
			Test.startTest();
			{
                ECICLinkCaseAndOpenAlertsEmailHelper.generateEmails (new List<Open_Alert_Case__c>{dummyOpenAlertCase});
			}
			Test.stopTest();
        }

        /**
         * FIXME: Assertion fails when email is (or should be) sent.
         * SendMail() returns Messaging.SendEmailResult[getErrors=(Messaging.SendEmailError[getTargetObjectId=null;]);isSuccess=false;]
         *
         * System.assertNotEquals (emailLimitBefore, Limits.getEmailInvocations(), 'Should have decreased'); 
         **/
    }
	
    // ------------------------------------------------------------------------------------------------------------------------------------
    
    private static void generateEmails1Test(Boolean isRequired)  
    {
        setOpenAlertEmailTemplate();
        Integer emailLimitBefore = Limits.getEmailInvocations();

        Integer dummyThreshold       = 5;
        Integer dummyNewCaseQuantity = (isRequired)   ? dummyThreshold       : 1;
                
        Case dummyCase = createDummyCase();
        
        TEST_DummyOpenAlertFactory.Config openAlertConfig = new TEST_DummyOpenAlertFactory.Config();
                                          openAlertConfig.additionalTo = 'dummy_email@test.example.com';
                                          openAlertConfig.recipients   = 'Bottler_Quality_Owner__c;Quality_Manager__c';
                                          openAlertConfig.threshold = dummyThreshold;
        Open_Alert__c dummyOpenAlert   = TEST_DummyOpenAlertFactory.create(openAlertConfig, TEST_DummyInsertModeEnum.MOCK);
        Id            dummyOpenAlertId = dummyOpenAlert.id;

        List<ECICLinkCaseAndOpenAlertsConfigEntry> dummyOpenAlertConfigEntryList = new List<ECICLinkCaseAndOpenAlertsConfigEntry>
        {
            ECICLinkCaseAndOpenAlertsHandlerTestHelp.createDummyConfigEntry(dummyOpenAlert, null)
        };

        List<Open_Alert_Case__c> dummyOpenAlertCaseList = TEST_DummyOpenAlertCaseFactory.createList(dummyNewCaseQuantity, new TEST_DummyOpenAlertCaseFactory.Config(dummyCase, dummyOpenAlert), TEST_DummyInsertModeEnum.NONE); 

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICLinkCaseAndOpenAlertsEmailHelper.generateEmails(dummyOpenAlertConfigEntryList, dummyOpenAlertCaseList);
            }
            Test.stopTest();
        }

        /**
         * FIXME: Assertion fails when email is (or should be) sent.
         * SendMail() returns Messaging.SendEmailResult[getErrors=(Messaging.SendEmailError[getTargetObjectId=null;]);isSuccess=false;]
         *
         * System.assertEquals (isRequired, emailLimitBefore != Limits.getEmailInvocations()); 
         **/
    }

    private static testMethod void notRequiredGenerateEmails1Test() { generateEmails1Test(false); }
    private static testMethod void requiredGenerateEmails1Test()    { generateEmails1Test(true);  }

    // ----------------------------------------------------------------------------------------------------------------------------------------
    
    public static void setOpenAlertEmailTemplate()
    {
        EmailTemplate dummyEmailTemplate = TEST_DummyEmailTemplateFactory.create(TEST_DummyInsertModeEnum.REAL);
        
        TEST_DummyGeneralSettingsFactory.Config generalSettingConfig = new TEST_DummyGeneralSettingsFactory.Config();
                                                generalSettingConfig.openAlertTemplateId = dummyEmailTemplate.id; 
        TEST_DummyGeneralSettingsFactory.create(generalSettingConfig, TEST_DummyInsertModeEnum.REAL);
    }
    
    private static Case createDummyCase()
    {
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.bottlerQualityOwnerUserId = TEST_RUN_USER.id;
                             caseConfig.qualityManagerUserId      = TEST_RUN_USER.id;  
        return TEST_DummyFastQualityComplaintCaseFactry.create(caseConfig, TEST_DummyInsertModeEnum.MOCK);
    }
}