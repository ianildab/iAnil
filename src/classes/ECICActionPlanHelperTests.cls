/**
* @author       Brian Kessler (Brian_Kessler@epam.com)
* @date         2013 May 27
* @description  This class is comtains unit tests for ECICActionPlanHelper.cls
*               All tests are runnung as a System Administrator (unless ECICRunUserTestHelper.create() has been modified).
*
*
* KNOWN LIMITATION:
*       
*  Expected values assume 2017 May 27 implementation of ECICActionPlanHelper.cls is already correct.
*  However, these testMethods may still be valued for SFDC coverage and regression testing.
*
*/

@isTest
private class ECICActionPlanHelperTests 
{
    public static  final User                       TEST_RUN_USER           = ECICRunUserTestHelper.create();  
    public static  final ECICCaseRegionTestHelper   CASE_REGION_TEST_HELPER;
    public static  final ECICCaseAccountTestHelper  CASE_ACCOUNT_TEST_HELPER;
    private static final Plant__c                   DUMMY_BOTTLER_PLANT;
    private static final Production_Line__c         DUMMY_PRODUCTION_LINE;

    private static final Integer                    NO_MATCHING_VALUE = 0;
    private static final Integer                    VALUE_IS_EMPTY    = -1;
    private static final Integer                    VALUE_IS_NULL     = -2;

    static 
    {
        System.runAs(TEST_RUN_USER) // Using runAs to run "pretests" in a separate context, thereby hoping to alieve pressure on the governor limits.
        {
            CASE_REGION_TEST_HELPER     = new ECICCaseRegionTestHelper ();
            CASE_ACCOUNT_TEST_HELPER    = new ECICCaseAccountTestHelper(CASE_REGION_TEST_HELPER);
            DUMMY_BOTTLER_PLANT         = createDummyBottlerPlant();
            DUMMY_PRODUCTION_LINE       = createDummyProductionLine();
        }
    }

    private static Plant__c createDummyBottlerPlant()
    {
        Plant__c dummyPlant = ECICTestHelper.createPlant();
                 dummyPlant.region__c = CASE_REGION_TEST_HELPER.DUMMY_BOTTLER_REGION.Id;
        insert   dummyPlant;
        return   dummyPlant;
    }

    private static Production_Line__c createDummyProductionLine()
    {
        Production_Line__c dummyProductionLine = ECICTestHelper.createProductionLine(DUMMY_BOTTLER_PLANT, 'Dummy Production Line');
        insert             dummyProductionLine;
        return             dummyProductionLine;
    }

    // --- Test getActionPlanID (Case c) -------------------------------------------------------------------------------------------

    static testmethod void getActionPlanIDTest() 
    {
        System.runAs(TEST_RUN_USER) 
        {
//            Action_Plan__c dummyActionPlan = ECICActionPlanTestHelper.createDummyActionPlan(true);
 Action_Plan__c dummyActionPlan = ECICActionPlanTestHelper.createDummyActionPlan('Phone','Sponsoring','Commercial Proposals','',true);              
              Case dummyCase = ECICCaseTestHelper.createDummyCase(new ECICCaseTestHelper.CaseConfig(dummyActionPlan));

                 dummyCase.Origin = 'Phone';
                 dummyCase.Country_Code__c = 'UK';
                 dummyCase.Category_Level4__c = '';
                 dummyCase.Category_Level3__c = 'Commercial proposals';
                 dummyCase.Reason = 'Sponsoring';
                 
            
            Id actionPlanId;
            Test.startTest();
            {
                actionPlanId = ECICActionPlanHelper.getActionPlanID(dummyCase);
            }
            Test.stopTest();
            
            // After adding the above values to fields of the default created dummyCase, the following assert works as intended.
            // ... but it isn't currently clear why those fields should be required, or if any might be safely dropped.
            System.assertEquals(dummyActionPlan.id, actionPlanId);
        }

    }

    // --- Test ECICActionPlanHelper.needsAp (Case c) -------------------------------------------------------------------------------------------

    static void needsApTest(String status, Boolean expectedValue) 
    {
        ECICTestHelper.initTestEnvironment(ECICTestHelper.MASTER_DATA_INSERTION_MODE_SINGLE);

        System.runAs(TEST_RUN_USER) 
        {
            Case dummyCase = ECICCaseTestHelper.createDummyCase(new ECICCaseTestHelper.CaseConfig(status));
            Boolean needsAp;
            
            Test.startTest();
            {
                needsAp = ECICActionPlanHelper.needsAp(dummyCase);
            }
            Test.stopTest();
            
            System.assertEquals(expectedValue, needsAp);
        }
    }

    static testMethod void newStatusNeedsApTestTest()                   { needsApTest('New'                   , false); }
/*    static testMethod void openStatusNeedsApTestTest()                  { needsApTest('Open'                  , true);  }
    static testMethod void escalatedStatusNeedsApTestTest()             { needsApTest('Escalated'             , true);  }
    static testMethod void pendingOnImcrStatusNeedsApTestTest()         { needsApTest('Pending on Quality'    , true);  }
    static testMethod void pendingOnQualityStatusNeedsApTestTest()      { needsApTest('Pending on IMCR'       , true);  }
    static testMethod void pendingOnOtherDeptStatusNeedsApTestTest()    { needsApTest('Pending on other Dept' , true);  }
    static testMethod void cancellednewStatusNeedsApTestTest()          { needsApTest('Cancelled'             , false); }
    static testMethod void closednewStatusNeedsApTestTest()             { needsApTest('Closed'                , false); } */


    // --- Test ECICActionPlanHelper.needChangeAp(Case currentCase, Case oldCase)   -------------------------------------------------------------------------------------------


    static void needChangeApTest(Case oldCase, Case currentCase, Boolean expectedValue) 
    {
        System.runAs(TEST_RUN_USER) 
        {
            Boolean needChangeAp;
            
            Test.startTest();
            {
                needChangeAp = ECICActionPlanHelper.needChangeAp(currentCase, oldCase);
            }
            Test.stopTest();
            
            System.assertEquals(expectedValue, needChangeAp);
        }
    }
    
    static testmethod void noOldNeedChangeApTest()
    {
            Case oldCase     = null;
            Case currentCase = ECICCaseTestHelper.createDummyCase(new ECICCaseTestHelper.CaseConfig());
            needChangeApTest (oldCase, currentCase, false);
    } 
    
    static testmethod void noOldActionPlanNeedChangeApTest()
    {
            Case oldCase     = ECICCaseTestHelper.createDummyCase(new ECICCaseTestHelper.CaseConfig());
                 oldCase.Action_Plan__c = null;
                 
            Case currentCase = ECICCaseTestHelper.createDummyCase(new ECICCaseTestHelper.CaseConfig());
            
            needChangeApTest (oldCase, currentCase, false);
    } 
    
    static testmethod void OldActionPlanButSameQualitiesNeedChangeApTest()
    {
            Case oldCase     = ECICCaseTestHelper.createDummyCase(new ECICCaseTestHelper.CaseConfig(ECICActionPlanTestHelper.createDummyActionPlan(true)));
            Case currentCase = ECICCaseTestHelper.createDummyCase(new ECICCaseTestHelper.CaseConfig());
            needChangeApTest (oldCase, currentCase, false);
    } 

    static void CaseOriginNeedChangeApTest(String oldOrigin, String currentOrigin)
    {
            Case oldCase     = ECICCaseTestHelper.createDummyCase(new ECICCaseTestHelper.CaseConfig(ECICActionPlanTestHelper.createDummyActionPlan(true)));
                 oldCase.origin         = oldOrigin;
                 
            Case currentCase = ECICCaseTestHelper.createDummyCase(new ECICCaseTestHelper.CaseConfig());
                 currentCase.origin     = currentOrigin;
            
            needChangeApTest (oldCase, currentCase, (oldOrigin != currentOrigin));
    } 
    
    static testmethod void CaseOriginPhoneNoChangeNeedChangeApTest()           { CaseOriginNeedChangeApTest ('Phone', 'Phone'); }
/***    static testmethod void CaseOriginPhone2EmailNeedChangeApTest()             { CaseOriginNeedChangeApTest ('Phone', 'Email'); }
    static testmethod void CaseOriginPhone2WebNeedChangeApTest()               { CaseOriginNeedChangeApTest ('Phone', 'Web'); }
    static testmethod void CaseOriginPhone2FacebookNeedChangeApTest()          { CaseOriginNeedChangeApTest ('Phone', 'Facebook'); }
    static testmethod void CaseOriginPhone2TwitterNeedChangeApTest()           { CaseOriginNeedChangeApTest ('Phone', 'Twitter'); }
    static testmethod void CaseOriginPhone2GoogleNeedChangeApTest()            { CaseOriginNeedChangeApTest ('Phone', 'Google'); }
    static testmethod void CaseOriginPhone2ChatNeedChangeApTest()              { CaseOriginNeedChangeApTest ('Phone', 'Chat'); }
    static testmethod void CaseOriginPhone2PortalNeedChangeApTest()            { CaseOriginNeedChangeApTest ('Phone', 'Portal'); }
    static testmethod void CaseOriginPhone2ExternalRelationsNeedChangeApTest() { CaseOriginNeedChangeApTest ('Phone', 'External Relations'); }
    static testmethod void CaseOriginPhone2CommercialDeptNeedChangeApTest()    { CaseOriginNeedChangeApTest ('Phone', 'Commercial Dept.'); }

    static testmethod void CaseOriginEmailNoChangeNeedChangeApTest()           { CaseOriginNeedChangeApTest ('Email', 'Email'); }
    static testmethod void CaseOriginEmail2PhoneNeedChangeApTest()             { CaseOriginNeedChangeApTest ('Email', 'Phone'); }
    static testmethod void CaseOriginEmail2WebNeedChangeApTest()               { CaseOriginNeedChangeApTest ('Email', 'Web'); }
    static testmethod void CaseOriginEmail2FacebookNeedChangeApTest()          { CaseOriginNeedChangeApTest ('Email', 'Facebook'); }
    static testmethod void CaseOriginEmail2TwitterNeedChangeApTest()           { CaseOriginNeedChangeApTest ('Email', 'Twitter'); }
    static testmethod void CaseOriginEmail2GoogleNeedChangeApTest()            { CaseOriginNeedChangeApTest ('Email', 'Google'); }
    static testmethod void CaseOriginEmail2ChatNeedChangeApTest()              { CaseOriginNeedChangeApTest ('Email', 'Chat'); }
    static testmethod void CaseOriginEmail2PortalNeedChangeApTest()            { CaseOriginNeedChangeApTest ('Email', 'Portal'); }
    static testmethod void CaseOriginEmail2ExternalRelationsNeedChangeApTest() { CaseOriginNeedChangeApTest ('Email', 'External Relations'); }
    static testmethod void CaseOriginEmail2CommercialDeptNeedChangeApTest()    { CaseOriginNeedChangeApTest ('Email', 'Commercial Dept.'); }

    static testmethod void CaseOriginWebNoChangeNeedChangeApTest()             { CaseOriginNeedChangeApTest ('Web', 'Web'); }
    static testmethod void CaseOriginWeb2PhoneNeedChangeApTest()               { CaseOriginNeedChangeApTest ('Web', 'Phone'); }
    static testmethod void CaseOriginWeb2EmailNeedChangeApTest()               { CaseOriginNeedChangeApTest ('Web', 'Email'); }
    static testmethod void CaseOriginWeb2FacebookNeedChangeApTest()            { CaseOriginNeedChangeApTest ('Web', 'Facebook'); }
    static testmethod void CaseOriginWeb2TwitterNeedChangeApTest()             { CaseOriginNeedChangeApTest ('Web', 'Twitter'); }
    static testmethod void CaseOriginWeb2GoogleNeedChangeApTest()              { CaseOriginNeedChangeApTest ('Web', 'Google'); }
    static testmethod void CaseOriginWeb2ChatNeedChangeApTest()                { CaseOriginNeedChangeApTest ('Web', 'Chat'); }
    static testmethod void CaseOriginWeb2PortalNeedChangeApTest()              { CaseOriginNeedChangeApTest ('Web', 'Portal'); }
    static testmethod void CaseOriginWeb2ExternalRelationsNeedChangeApTest()   { CaseOriginNeedChangeApTest ('Web', 'External Relations'); }
    static testmethod void CaseOriginWeb2CommercialDeptNeedChangeApTest()      { CaseOriginNeedChangeApTest ('Web', 'Commercial Dept.'); }

    static testmethod void CaseOriginFacebookNoChangeNeedChangeApTest()            { CaseOriginNeedChangeApTest ('Facebook', 'Facebook'); }
    static testmethod void CaseOriginFacebook2PhoneNeedChangeApTest()              { CaseOriginNeedChangeApTest ('Facebook', 'Phone'); }
    static testmethod void CaseOriginFacebook2EmailNeedChangeApTest()              { CaseOriginNeedChangeApTest ('Facebook', 'Email'); }
    static testmethod void CaseOriginFacebook2WebNeedChangeApTest()                { CaseOriginNeedChangeApTest ('Facebook', 'Web'); }
    static testmethod void CaseOriginFacebook2TwitterNeedChangeApTest()            { CaseOriginNeedChangeApTest ('Facebook', 'Twitter'); }
    static testmethod void CaseOriginFacebook2GoogleNeedChangeApTest()             { CaseOriginNeedChangeApTest ('Facebook', 'Google'); }
    static testmethod void CaseOriginFacebook2ChatNeedChangeApTest()               { CaseOriginNeedChangeApTest ('Facebook', 'Chat'); }
    static testmethod void CaseOriginFacebook2PortalNeedChangeApTest()             { CaseOriginNeedChangeApTest ('Facebook', 'Portal'); }
    static testmethod void CaseOriginFacebook2ExternalRelationsNeedChangeApTest()  { CaseOriginNeedChangeApTest ('Facebook', 'External Relations'); }
    static testmethod void CaseOriginFacebook2CommercialDeptNeedChangeApTest()     { CaseOriginNeedChangeApTest ('Facebook', 'Commercial Dept.'); }

    static testmethod void CaseOriginTwitterNoChangeNeedChangeApTest()             { CaseOriginNeedChangeApTest ('Twitter', 'Twitter'); }
    static testmethod void CaseOriginTwitter2PhoneNeedChangeApTest()               { CaseOriginNeedChangeApTest ('Twitter', 'Phone'); }
    static testmethod void CaseOriginTwitter2EmailNeedChangeApTest()               { CaseOriginNeedChangeApTest ('Twitter', 'Email'); }
    static testmethod void CaseOriginTwitter2WebNeedChangeApTest()                 { CaseOriginNeedChangeApTest ('Twitter', 'Web'); }
    static testmethod void CaseOriginTwitter2FacebookNeedChangeApTest()            { CaseOriginNeedChangeApTest ('Twitter', 'Facebook'); }
    static testmethod void CaseOriginTwitter2GoogleNeedChangeApTest()              { CaseOriginNeedChangeApTest ('Twitter', 'Google'); }
    static testmethod void CaseOriginTwitter2ChatNeedChangeApTest()                { CaseOriginNeedChangeApTest ('Twitter', 'Chat'); }
    static testmethod void CaseOriginTwitter2PortalNeedChangeApTest()              { CaseOriginNeedChangeApTest ('Twitter', 'Portal'); }
    static testmethod void CaseOriginTwitter2ExternalRelationsNeedChangeApTest()   { CaseOriginNeedChangeApTest ('Twitter', 'External Relations'); }
    static testmethod void CaseOriginTwitter2CommercialDeptNeedChangeApTest()      { CaseOriginNeedChangeApTest ('Twitter', 'Commercial Dept.'); }

    static testmethod void CaseOriginGoogleNoChangeNeedChangeApTest()              { CaseOriginNeedChangeApTest ('Google', 'Google'); }
    static testmethod void CaseOriginGoogle2PhoneNeedChangeApTest()                { CaseOriginNeedChangeApTest ('Google', 'Phone'); }
    static testmethod void CaseOriginGoogle2EmailNeedChangeApTest()                { CaseOriginNeedChangeApTest ('Google', 'Email'); }
    static testmethod void CaseOriginGoogle2WebNeedChangeApTest()                  { CaseOriginNeedChangeApTest ('Google', 'Web'); }
    static testmethod void CaseOriginGoogle2FacebookNeedChangeApTest()             { CaseOriginNeedChangeApTest ('Google', 'Facebook'); }
    static testmethod void CaseOriginGoogle2TwitterNeedChangeApTest()              { CaseOriginNeedChangeApTest ('Google', 'Twitter'); }
    static testmethod void CaseOriginGoogle2ChatNeedChangeApTest()                 { CaseOriginNeedChangeApTest ('Google', 'Chat'); }
    static testmethod void CaseOriginGoogle2PortalNeedChangeApTest()               { CaseOriginNeedChangeApTest ('Google', 'Portal'); }
    static testmethod void CaseOriginGoogle2ExternalRelationsNeedChangeApTest()    { CaseOriginNeedChangeApTest ('Google', 'External Relations'); }
    static testmethod void CaseOriginGoogle2CommercialDeptNeedChangeApTest()       { CaseOriginNeedChangeApTest ('Google', 'Commercial Dept.'); }

    static testmethod void CaseOriginChatNoChangeNeedChangeApTest()            { CaseOriginNeedChangeApTest ('Chat', 'Chat'); }
    static testmethod void CaseOriginChat2PhoneNeedChangeApTest()              { CaseOriginNeedChangeApTest ('Chat', 'Phone'); }
    static testmethod void CaseOriginChat2EmailNeedChangeApTest()              { CaseOriginNeedChangeApTest ('Chat', 'Email'); }
    static testmethod void CaseOriginChat2WebNeedChangeApTest()                { CaseOriginNeedChangeApTest ('Chat', 'Web'); }
    static testmethod void CaseOriginChat2FacebookNeedChangeApTest()           { CaseOriginNeedChangeApTest ('Chat', 'Facebook'); }
    static testmethod void CaseOriginChat2TwitterNeedChangeApTest()            { CaseOriginNeedChangeApTest ('Chat', 'Twitter'); }
    static testmethod void CaseOriginChat2GoogleNeedChangeApTest()             { CaseOriginNeedChangeApTest ('Chat', 'Google'); }
    static testmethod void CaseOriginChat2PortalNeedChangeApTest()             { CaseOriginNeedChangeApTest ('Chat', 'Portal'); }
    static testmethod void CaseOriginChat2ExternalRelationsNeedChangeApTest()  { CaseOriginNeedChangeApTest ('Chat', 'External Relations'); }
    static testmethod void CaseOriginChat2CommercialDeptNeedChangeApTest()     { CaseOriginNeedChangeApTest ('Chat', 'Commercial Dept.'); }

    static testmethod void CaseOriginPortalNoChangeNeedChangeApTest()            { CaseOriginNeedChangeApTest ('Portal', 'Portal'); }
    static testmethod void CaseOriginPortal2PhoneNeedChangeApTest()              { CaseOriginNeedChangeApTest ('Portal', 'Phone'); }
    static testmethod void CaseOriginPortal2EmailNeedChangeApTest()              { CaseOriginNeedChangeApTest ('Portal', 'Email'); }
    static testmethod void CaseOriginPortal2WebNeedChangeApTest()                { CaseOriginNeedChangeApTest ('Portal', 'Web'); }
    static testmethod void CaseOriginPortal2FacebookNeedChangeApTest()           { CaseOriginNeedChangeApTest ('Portal', 'Facebook'); }
    static testmethod void CaseOriginPortal2TwitterNeedChangeApTest()            { CaseOriginNeedChangeApTest ('Portal', 'Twitter'); }
    static testmethod void CaseOriginPortal2GoogleNeedChangeApTest()             { CaseOriginNeedChangeApTest ('Portal', 'Google'); }
    static testmethod void CaseOriginPortal2ChatNeedChangeApTest()               { CaseOriginNeedChangeApTest ('Portal', 'Chat'); }
    static testmethod void CaseOriginPortal2ExternalRelationsNeedChangeApTest()  { CaseOriginNeedChangeApTest ('Portal', 'External Relations'); }
    static testmethod void CaseOriginPortal2CommercialDeptNeedChangeApTest()     { CaseOriginNeedChangeApTest ('Portal', 'Commercial Dept.'); }

    static testmethod void CaseOriginExternalRelationsNoChangeNeedChangeApTest()            { CaseOriginNeedChangeApTest ('External Relations', 'External Relations'); }
    static testmethod void CaseOriginExternalRelations2PhoneNeedChangeApTest()              { CaseOriginNeedChangeApTest ('External Relations', 'Phone'); }
    static testmethod void CaseOriginExternalRelations2EmailNeedChangeApTest()              { CaseOriginNeedChangeApTest ('External Relations', 'Email'); }
    static testmethod void CaseOriginExternalRelations2WebNeedChangeApTest()                { CaseOriginNeedChangeApTest ('External Relations', 'Web'); }
    static testmethod void CaseOriginExternalRelations2FacebookNeedChangeApTest()           { CaseOriginNeedChangeApTest ('External Relations', 'Facebook'); }
    static testmethod void CaseOriginExternalRelations2TwitterNeedChangeApTest()            { CaseOriginNeedChangeApTest ('External Relations', 'Twitter'); }
    static testmethod void CaseOriginExternalRelations2GoogleNeedChangeApTest()             { CaseOriginNeedChangeApTest ('External Relations', 'Google'); }
    static testmethod void CaseOriginExternalRelations2ChatNeedChangeApTest()               { CaseOriginNeedChangeApTest ('External Relations', 'Chat'); }
    static testmethod void CaseOriginExternalRelations2PortalNeedChangeApTest()             { CaseOriginNeedChangeApTest ('External Relations', 'Portal'); }
    static testmethod void CaseOriginExternalRelations2CommercialDeptNeedChangeApTest()     { CaseOriginNeedChangeApTest ('External Relations', 'Commercial Dept.'); }

    static testmethod void CaseOriginCommercialDeptNoChangeNeedChangeApTest()               { CaseOriginNeedChangeApTest ('Commercial Dept.', 'Commercial Dept.'); }
    static testmethod void CaseOriginCommercialDept2PhoneNeedChangeApTest()                 { CaseOriginNeedChangeApTest ('Commercial Dept.', 'Phone'); }
    static testmethod void CaseOriginCommercialDept2EmailNeedChangeApTest()                 { CaseOriginNeedChangeApTest ('Commercial Dept.', 'Email'); }
    static testmethod void CaseOriginCommercialDept2WebNeedChangeApTest()                   { CaseOriginNeedChangeApTest ('Commercial Dept.', 'Web'); }
    static testmethod void CaseOriginCommercialDept2FacebookNeedChangeApTest()              { CaseOriginNeedChangeApTest ('Commercial Dept.', 'Facebook'); }
    static testmethod void CaseOriginCommercialDept2TwitterNeedChangeApTest()               { CaseOriginNeedChangeApTest ('Commercial Dept.', 'Twitter'); }
    static testmethod void CaseOriginCommercialDept2GoogleNeedChangeApTest()                { CaseOriginNeedChangeApTest ('Commercial Dept.', 'Google'); }
    static testmethod void CaseOriginCommercialDept2ChatNeedChangeApTest()                  { CaseOriginNeedChangeApTest ('Commercial Dept.', 'Chat'); }
    static testmethod void CaseOriginCommercialDept2PortalNeedChangeApTest()                { CaseOriginNeedChangeApTest ('Commercial Dept.', 'Portal'); }
    static testmethod void CaseOriginCommercialDept2CommercialDeptNeedChangeApTest()        { CaseOriginNeedChangeApTest ('Commercial Dept.', 'External Relations'); } */

    // Okay, I went a little crazy here. :-)

    static void CaseReasonNeedChangeApTest(String oldReason, String currentReason)
    {
            Case oldCase     = ECICCaseTestHelper.createDummyCase(new ECICCaseTestHelper.CaseConfig(ECICActionPlanTestHelper.createDummyActionPlan(true)));
                 oldCase.reason         = oldReason;
                 
            Case currentCase = ECICCaseTestHelper.createDummyCase(new ECICCaseTestHelper.CaseConfig());
                 currentCase.reason     = currentReason;
            
            needChangeApTest (oldCase, currentCase, (oldReason != currentReason));
    } 

    static testmethod void CaseReasonSponsoringNoChangeNeedChangeApTest()                   { CaseReasonNeedChangeApTest ('Sponsoring', 'Sponsoring'); }
/***    static testmethod void CaseReasonSponsoring2CorporateNeedChangeApTest()                 { CaseReasonNeedChangeApTest ('Sponsoring', 'Corporate'); }
    static testmethod void CaseReasonSponsoring2HealthAndNutritionNeedChangeApTest()        { CaseReasonNeedChangeApTest ('Sponsoring', 'Health and Nutrition'); }
    static testmethod void CaseReasonSponsoring2ProductsAndBrandsNeedChangeApTest()         { CaseReasonNeedChangeApTest ('Sponsoring', 'Brand info'); }
    static testmethod void CaseReasonSponsoring2MarketingNeedChangeApTest()                 { CaseReasonNeedChangeApTest ('Sponsoring', 'Product info'); }
    static testmethod void CaseReasonSponsoring2PromotionNeedChangeApTest()                 { CaseReasonNeedChangeApTest ('Sponsoring', 'Promotion'); }
    static testmethod void CaseReasonSponsoring2CommercialAndDistributionNeedChangeApTest() { CaseReasonNeedChangeApTest ('Sponsoring', 'Commercial & Distribution'); }
    static testmethod void CaseReasonSponsoring2ProductsNeedChangeApTest()                  { CaseReasonNeedChangeApTest ('Sponsoring', 'Product Quality'); }
    static testmethod void CaseReasonSponsoring2WrongNumberNeedChangeApTest()               { CaseReasonNeedChangeApTest ('Sponsoring', 'Wrong Number'); }
    static testmethod void CaseReasonSponsoring2InsultsNeedChangeApTest()                   { CaseReasonNeedChangeApTest ('Sponsoring', 'Insults'); }
    static testmethod void CaseReasonSponsoring2HangUpNeedChangeApTest()                    { CaseReasonNeedChangeApTest ('Sponsoring', 'Hang up'); }
    static testmethod void CaseReasonSponsoring2ComplimentNeedChangeApTest()                { CaseReasonNeedChangeApTest ('Sponsoring', 'Compliment'); } */

    // More permutations easily possible, but probably overkill, on a nuclear scale. 

    static void CaseCatLevel3NeedChangeApTest(String oldCatLevel3, String currentCatLevel3)
    {
            Case oldCase     = ECICCaseTestHelper.createDummyCase(new ECICCaseTestHelper.CaseConfig(ECICActionPlanTestHelper.createDummyActionPlan(true)));
                 oldCase.category_level3__c     = oldCatLevel3;
                 
            Case currentCase = ECICCaseTestHelper.createDummyCase(new ECICCaseTestHelper.CaseConfig());
                 currentCase.category_level3__c = currentCatLevel3;
            
            needChangeApTest (oldCase, currentCase, (oldCatLevel3 != currentCatLevel3));
    } 
    
    static testmethod void CaseCatLevel3CommercialProposalsNoChangeNeedChangeApTest()                 { CaseCatLevel3NeedChangeApTest ('Commercial proposals', 'Commercial proposals'); }
/***    static testmethod void CaseCatLevel3CommercialProposals2RequestGadgetsNeedChangeApTest()          { CaseCatLevel3NeedChangeApTest ('Commercial proposals', 'Request gadgets'); }
    static testmethod void CaseCatLevel3CommercialProposals2RequestCouponsVouchersNeedChangeApTest()  { CaseCatLevel3NeedChangeApTest ('Commercial proposals', 'Request coupons, vouchers'); }
    static testmethod void CaseCatLevel3CommercialProposals2RequestProductsNeedChangeApTest()         { CaseCatLevel3NeedChangeApTest ('Commercial proposals', 'Request products'); }
    static testmethod void CaseCatLevel3CommercialProposals2SchoolFairsNeedChangeApTest()             { CaseCatLevel3NeedChangeApTest ('Commercial proposals', 'School fairs'); }
    static testmethod void CaseCatLevel3CommercialProposals2MiscellaneousSponsoringNeedChangeApTest() { CaseCatLevel3NeedChangeApTest ('Commercial proposals', 'Miscellaneous sponsoring'); }
    static testmethod void CaseCatLevel3CommercialProposals2OrganizationNeedChangeApTest()            { CaseCatLevel3NeedChangeApTest ('Commercial proposals', 'Organization'); } */

    // More permutations easily possible, but probably overkill, on a nuclear scale. 

    static void CaseCatLevel4NeedChangeApTest(String oldCatLevel4, String currentCatLevel4)
    {
            Case oldCase     = ECICCaseTestHelper.createDummyCase(new ECICCaseTestHelper.CaseConfig(ECICActionPlanTestHelper.createDummyActionPlan(true)));
                 oldCase.category_level4__c     = oldCatLevel4;
                 
            Case currentCase = ECICCaseTestHelper.createDummyCase(new ECICCaseTestHelper.CaseConfig());
                 currentCase.category_level4__c = currentCatLevel4;
            
            needChangeApTest (oldCase, currentCase, (oldCatLevel4 != currentCatLevel4));
    } 
    
    //New level 4 case categorization according to CIC-515 (Simplified case categorization)
    static testmethod void CaseCatLevel4NationalEventNoChangeNeedChangeApTest()                   { CaseCatLevel4NeedChangeApTest ('National event', 'National event'); }
/***    static testmethod void CaseCatLevel4NationalEvent2CaffeineNeedChangeApTest()                  { CaseCatLevel4NeedChangeApTest ('National event', 'Caffeine'); }
    static testmethod void CaseCatLevel4NationalEvent2EnumberNeedChangeApTest()                   { CaseCatLevel4NeedChangeApTest ('National event', 'E numbers'); }
    static testmethod void CaseCatLevel4NationalEvent2FlavoursColouringNeedChangeApTest()         { CaseCatLevel4NeedChangeApTest ('National event', 'Flavours & Colouring'); }
    static testmethod void CaseCatLevel4NationalEvent2FoodAdditivesNeedChangeApTest()             { CaseCatLevel4NeedChangeApTest ('National event', 'Food additives'); }
    static testmethod void CaseCatLevel4NationalEvent2PhosphoricAcidNeedChangeApTest()            { CaseCatLevel4NeedChangeApTest ('National event', 'Phosphoric acid'); }
    static testmethod void CaseCatLevel4NationalEvent2EnvironmentNeedChangeApTest()               { CaseCatLevel4NeedChangeApTest ('National event', 'Environment'); }
    static testmethod void CaseCatLevel4NationalEvent2LabellingNeedChangeApTest()                 { CaseCatLevel4NeedChangeApTest ('National event', 'Labelling'); }
    static testmethod void CaseCatLevel4NationalEvent2ExpiredProductNeedChangeApTest()            { CaseCatLevel4NeedChangeApTest ('National event', 'Expired Product'); }
    static testmethod void CaseCatLevel4NationalEvent2CorrosionNeedChangeApTest()                 { CaseCatLevel4NeedChangeApTest ('National event', 'Corrosion'); } */
    /*static testmethod void CaseCatLevel4SportsEventsNoChangeNeedChangeApTest()                      { CaseCatLevel4NeedChangeApTest ('Sports events', 'Sports events'); }
    static testmethod void CaseCatLevel4SportsEvents2MusicEventsNeedChangeApTest()                { CaseCatLevel4NeedChangeApTest ('Sports events', 'Music events'); }
    static testmethod void CaseCatLevel4SportsEvents2GeneralCompositionNeedChangeApTest()         { CaseCatLevel4NeedChangeApTest ('Sports events', 'General composition'); }
    static testmethod void CaseCatLevel4SportsEvents2CaloriesNeedChangeApTest()                   { CaseCatLevel4NeedChangeApTest ('Sports events', 'Calories'); }
    static testmethod void CaseCatLevel4SportsEvents2QuantityNeedChangeApTest()                   { CaseCatLevel4NeedChangeApTest ('Sports events', 'Quantity'); }
    static testmethod void CaseCatLevel4SportsEvents2PresenceNeedChangeApTest()                   { CaseCatLevel4NeedChangeApTest ('Sports events', 'Presence'); }
    static testmethod void CaseCatLevel4SportsEvents2FormulaIngredientsNeedChangeApTest()         { CaseCatLevel4NeedChangeApTest ('Sports events', 'Formula - Ingredients'); }
    static testmethod void CaseCatLevel4SportsEvents2PackagingNeedChangeApTest()                  { CaseCatLevel4NeedChangeApTest ('Sports events', 'Packaging'); }
    static testmethod void CaseCatLevel4SportsEvents2SalesPointRtailerNeedChangeApTest()          { CaseCatLevel4NeedChangeApTest ('Sports events', 'Sales point - retailer'); }
    static testmethod void CaseCatLevel4SportsEvents2BestBeforeDateNeedChangeApTest()             { CaseCatLevel4NeedChangeApTest ('Sports events', 'Best Before date'); }*/

    // More permutations easily possible, but probably overkill, on a nuclear scale. 

    // --- Test ECICActionPlanHelper.needChangeAp(Case currentCase, Case oldCase)   -------------------------------------------------------------------------------------------

    static void firstApTest(Case oldCase, Case currentCase, Boolean expectedValue) 
    {
        System.runAs(TEST_RUN_USER) 
        {
            Boolean firstAp;
            
            Test.startTest();
            {
                firstAp = ECICActionPlanHelper.firstAp(currentCase, oldCase);
            }
            Test.stopTest();
            
            System.assertEquals(expectedValue, firstAp);
        }
    }
    
    static testmethod void noOldFirstApTest()       { firstApTest (null, null, true); }  
    static testmethod void newStatusFirstApTest()   { firstApTest (ECICCaseTestHelper.createDummyCase(new ECICCaseTestHelper.CaseConfig('New')), null, true); }
/***    static testmethod void noApFirstApTest()        { firstApTest (ECICCaseTestHelper.createDummyCase(new ECICCaseTestHelper.CaseConfig('Open')), null, true); }
    static testmethod void notFirstApTest()         { firstApTest (ECICCaseTestHelper.createDummyCase(new ECICCaseTestHelper.CaseConfig('Open', ECICActionPlanTestHelper.createDummyActionPlan(true))), null, false); } */
   
   
    // --- Test ECICActionPlanHelper.isApValid(Case c)   -------------------------------------------------------------------------------------------
    
    static void isApValidTest(Case currentCase, Boolean expectedValue) 
    {
        System.debug (Logginglevel.INFO, '!!!!!!!!!!!!!!!!!!!!! Start Test !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        
        System.runAs(TEST_RUN_USER) 
        {
            Boolean isApValid;
            System.debug (Logginglevel.INFO, '*** isApValid (before Test):               ' + isApValid);
            
            Test.startTest();
            {
                if ( currentCase != null ) {
                    isApValid = ECICActionPlanHelper.isApValid(currentCase);
                }
            }
            Test.stopTest();

        System.debug (Logginglevel.INFO, '*** expectedValue:                             ' + expectedValue);
        System.debug (Logginglevel.INFO, '*** isApValid (after Test):                    ' + isApValid);
            
            System.assertEquals(expectedValue, isApValid);
        }

        System.debug (Logginglevel.INFO, '!!!!!!!!!!!!!!!!!!!!! End Test !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    }
    
    static void ApChannelCaseOriginIsApValidTest(String apChannel, String caseOrigin)
    {
        Case dummyCase = ECICCaseTestHelper.createDummyCase ( caseOrigin, '', '', '', apChannel, '', '', '' ); 
        Boolean expectedReturn = ( (!ECICUtils.isEmpty(caseOrigin)) &&  ((apChannel).contains(caseOrigin)) );
        isApValidTest (dummyCase, expectedReturn);
    } 

    static void ReasonIsApValidTest (String caseReason, String apReason)
    {
        String channel = 'Phone';

        Case dummyCase = ECICCaseTestHelper.createDummyCase ( channel, caseReason, '', '', channel, apReason, '', '' ); 
        Boolean expectedReturn =    (
                                            ( (!ECICUtils.isEmpty(caseReason)) &&  (!ECICUtils.isEmpty(apReason)) && ((apReason).contains(caseReason)) )
                                        ||  (ECICUtils.isEmpty(apReason)) 
                                    );
        isApValidTest (dummyCase, expectedReturn);
    } 

    static void Level3IsApValidTest (String caseLevel3, String apLevel3)
    {
        String channel = 'Phone';

        Case dummyCase = ECICCaseTestHelper.createDummyCase ( channel, '', caseLevel3, '', channel, '', apLevel3, '' ); 
        Boolean expectedReturn =    (
                                            ((!ECICUtils.isEmpty(caseLevel3)) && (!ECICUtils.isEmpty(apLevel3)) && (apLevel3.contains(caseLevel3)) )
                                        ||  (ECICUtils.isEmpty(apLevel3)) 
                                    );
        isApValidTest (dummyCase, expectedReturn);
    } 


    static void Level4IsApValidTest (String caseLevel4, String apLevel4)
    {
        String channel = 'Phone';

        Case dummyCase = ECICCaseTestHelper.createDummyCase ( channel, '', '', caseLevel4, channel, '', '', apLevel4 ); 
        Boolean expectedReturn =    (
                                            ((!ECICUtils.isEmpty(caseLevel4)) && (!ECICUtils.isEmpty(apLevel4)) && (apLevel4.contains(caseLevel4)) )
                                        ||  (ECICUtils.isEmpty(apLevel4)) 
                                    );
        isApValidTest (dummyCase, expectedReturn);
    } 

    static testmethod void noApIsApValidTest() { isApValidTest(ECICCaseTestHelper.createDummyCase(), false); }
    
    static testmethod void NoApChannelPhoneCaseOriginIsApValidTest()                 { ApChannelCaseOriginIsApValidTest('', 'Phone'); }
/***    static testmethod void PhoneApChannelNoCaseOriginIsApValidTest()                 { ApChannelCaseOriginIsApValidTest('Phone', ''); }
    static testmethod void PhoneApChannelPhoneCaseOriginIsApValidTest()              { ApChannelCaseOriginIsApValidTest('Phone', 'Phone'); }
    static testmethod void PhoneApChannelEmailCaseOriginIsApValidTest()              { ApChannelCaseOriginIsApValidTest('Phone', 'Email'); }
    static testmethod void EmailApChannelPhoneCaseOriginIsApValidTest()              { ApChannelCaseOriginIsApValidTest('Email', 'Phone'); }
    static testmethod void FacebookApChannelFacebookCaseOriginIsApValidTest()        { ApChannelCaseOriginIsApValidTest('Facebook', 'Facebook'); }
    static testmethod void FacebookTwitterApChannelFacebookCaseOriginIsApValidTest() { ApChannelCaseOriginIsApValidTest('Facebook;Twitter', 'Facebook'); }
    static testmethod void FacebookTwitterApChannelTwitterCaseOriginIsApValidTest()  { ApChannelCaseOriginIsApValidTest('Facebook;Twitter', 'Twitter'); }
    static testmethod void FacebookTwitterApChannelGoogleCaseOriginIsApValidTest()   { ApChannelCaseOriginIsApValidTest('Facebook;Twitter', 'Google'); }

    static testmethod void NoCaseReasonSponsoringApReasonIsApValidTest()                           { ReasonIsApValidTest ('', 'Sponsoring'); }
    static testmethod void SponsoringCaseReasonNoApReasonIsApValidTest()                           { ReasonIsApValidTest ('Sponsoring', ''); }
    static testmethod void SponsoringCaseReasonSponsoringApReasonIsApValidTest()                   { ReasonIsApValidTest ('Sponsoring', 'Sponsoring'); }
    static testmethod void CorporateCaseReasonSponsoringApReasonIsApValidTest()                    { ReasonIsApValidTest ('Corporate', 'Sponsoring'); }
    static testmethod void SponsoringCaseReasonCorporateApReasonIsApValidTest()                    { ReasonIsApValidTest ('Sponsoring', 'Corporate'); }
    static testmethod void SponsoringCaseReasonSponsoringCorporateApReasonIsApValidTest()          { ReasonIsApValidTest ('Sponsoring', 'Sponsoring;Corporate;'); }
    static testmethod void CorporateCaseReasonSponsoringMusicEventApReasonIsApValidTest()          { ReasonIsApValidTest ('Corporate', 'Sponsoring;Corporate;'); }
    static testmethod void HealthAndNutritionCaseReasonSponsoringMusicEventApReasonIsApValidTest() { ReasonIsApValidTest ('Health and Nutrition', 'Sponsoring;Corporate;'); }

    static testmethod void NoCaseCL3SportsEventApCL3ChannelLevel3IsApValidTest()                                        { Level3IsApValidTest ('', 'Commercial proposals'); }
    static testmethod void CommercialProposalsCaseCL3NoApCL3ChannelLevel3IsApValidTest()                                { Level3IsApValidTest ('Commercial proposals', ''); }
    static testmethod void CommercialProposalsCaseCL3CommercialProposalsApCL3ChannelLevel3IsApValidTest()               { Level3IsApValidTest ('Commercial proposals', 'Commercial proposals'); }
    static testmethod void RequestGadgetsCaseCL3CommercialProposalsApCL3ChannelLevel3IsApValidTest()                    { Level3IsApValidTest ('Request gadgets', 'Commercial proposals'); }
    static testmethod void CommercialProposalsCaseCL3RequestGadgetsApCL3ChannelLevel3IsApValidTest()                    { Level3IsApValidTest ('Commercial proposals', 'Request gadgets'); }
    static testmethod void CommercialProposalsCaseCL3CommercialProposalsRequestGadgetsApCL3ChannelLevel3IsApValidTest() { Level3IsApValidTest ('Commercial proposals', 'Commercial proposals;Request gadgets;'); }
    static testmethod void RequestGadgetsCaseCL3CommercialProposalsMusicEventApCL3ChannelLevel3IsApValidTest()          { Level3IsApValidTest ('Request gadgets', 'Commercial proposals;Request gadgets;'); }
    static testmethod void RequestCouponsVouchersCaseCL3CommercialProposalsMusicEventApCL3ChannelLevel3IsApValidTest()  { Level3IsApValidTest ('Request coupons, vouchers', 'Commercial proposals;Request gadgets;'); }
    
    /*static testmethod void NoCaseCL4SportsEventApCL4ChannelLevel4IsApValidTest()                               { Level4IsApValidTest ('', 'Sports events'); }
    static testmethod void SportsEventsCaseCL4NoApCL4ChannelLevel4IsApValidTest()                            { Level4IsApValidTest ('Sports events', ''); }
    static testmethod void SportsEventsCaseCL4SportsEventsApCL4ChannelLevel4IsApValidTest()                  { Level4IsApValidTest ('Sports events', 'Sports events'); }
    static testmethod void MusicEventsCaseCL4SportsEventsApCL4ChannelLevel4IsApValidTest()                   { Level4IsApValidTest ('Music events', 'Sports events'); }
    static testmethod void SportsEventsCaseCL4MusicEventsApCL4ChannelLevel4IsApValidTest()                   { Level4IsApValidTest ('Sports events', 'Music events'); }
    static testmethod void SportsEventsCaseCL4SportsEventsMusicEventsApCL4ChannelLevel4IsApValidTest()       { Level4IsApValidTest ('Sports events', 'Sports events;Music events;'); }
    static testmethod void MusicEventsCaseCL4SportsEventsMusicEventApCL4ChannelLevel4IsApValidTest()         { Level4IsApValidTest ('Music events', 'Sports events;Music events;'); }
    static testmethod void GeneralCompositionCaseCL4SportsEventsMusicEventApCL4ChannelLevel4IsApValidTest()  { Level4IsApValidTest ('General composition', 'Sports events;Music events;'); }*/
    
    //Level 4 - new values according to CIC-515 (Simplified case categorization)
/***    static testmethod void NoCaseCL4SportsEventApCL4ChannelLevel4IsApValidTest()                             { Level4IsApValidTest ('', 'Aspartame'); }
    static testmethod void SportsEventsCaseCL4NoApCL4ChannelLevel4IsApValidTest()                            { Level4IsApValidTest ('Aspartame', ''); }
    static testmethod void SportsEventsCaseCL4SportsEventsApCL4ChannelLevel4IsApValidTest()                  { Level4IsApValidTest ('Aspartame', 'Aspartame'); }
    static testmethod void MusicEventsCaseCL4SportsEventsApCL4ChannelLevel4IsApValidTest()                   { Level4IsApValidTest ('Cyclamate', 'Aspartame'); }
    static testmethod void SportsEventsCaseCL4MusicEventsApCL4ChannelLevel4IsApValidTest()                   { Level4IsApValidTest ('Aspartame', 'Cyclamate'); }
    static testmethod void SportsEventsCaseCL4SportsEventsMusicEventsApCL4ChannelLevel4IsApValidTest()       { Level4IsApValidTest ('Aspartame', 'Aspartame;Cyclamate;'); }
    static testmethod void MusicEventsCaseCL4SportsEventsMusicEventApCL4ChannelLevel4IsApValidTest()         { Level4IsApValidTest ('Cyclamate', 'Aspartame;Cyclamate;'); }
    static testmethod void GeneralCompositionCaseCL4SportsEventsMusicEventApCL4ChannelLevel4IsApValidTest()  { Level4IsApValidTest ('Saccharine', 'Aspartame;Cyclamate;'); } */
    

    // --- Test fireAllAPTasksCreation(Case c)) -------------------------------------------------------------------------------------------

    static void fireAllAPTasksCreationTest(Integer quantity) 
    {
        System.runAs(TEST_RUN_USER) 
        {
            Action_Plan__c dummyActionPlan = ECICActionPlanTestHelper.createDummyActionPlan(true);
            
            if (quantity > 0)
            {
                ECICActionPlanItemTestHelper.createDummyActionPlanItemList(dummyActionPlan, quantity, true);
            }
            
            Case dummyCase = ECICCaseTestHelper.createDummyCase(new ECICCaseTestHelper.CaseConfig(dummyActionPlan), false);
            
            List<Task> taskList = null;
            Test.startTest();
            {
                taskList = ECICActionPlanHelper.fireAllAPTasksCreation(dummyCase);
            }
            Test.stopTest();
            
            // TODO: Fix test preparation above or assert below (this might be easier to do once tests have been developed for fireAPTasksCreation() ).
            // System.assertEquals (quantity, taskList.size());
        }
    }

    static testmethod void NoItemsFireAllAPTasksCreationTest()  { fireAllAPTasksCreationTest (0); }
/***    static testmethod void OneItemFireAllAPTasksCreationTest()  { fireAllAPTasksCreationTest (1); }
    static testmethod void TenItemsFireAllAPTasksCreationTest() { fireAllAPTasksCreationTest (10); } */

    private static void fireAPTasksCreationTest(String mode)
    {
        Action_Plan__c      dummyActionPlan     = ECICActionPlanTestHelper.createDummyActionPlan(true);
        Action_Plan_Item__c dummyActionPlanItem = ECICActionPlanItemTestHelper.createDummyActionPlanItem(dummyActionPlan, new ECICActionPlanItemTestHelper.ActionPlanItemConfig(mode), true);
        Case                dummyCase           = ECICCaseTestHelper.createDummyCase(new ECICCaseTestHelper.CaseConfig(dummyActionPlan), false);

        List<Task> resultTaskList = null;
        System.runAs(TEST_RUN_USER) 
        {
            Test.startTest();
            {
                resultTaskList = ECICActionPlanHelper.fireAPTasksCreation(dummyCase, (new List<Action_Plan_Item__c> { dummyActionPlanItem }));
            }
            Test.stopTest();
        }
        
        // TODO: Assert somethings
        // This will make more sense after creating unit tests for checkTaskConditions(Case c, Action_Plan_Item__c item)
    }
    
    private static testMethod void fireAPTasksWithKeyItemCreationTest()             { fireAPTasksCreationTest(ECICActionPlanHelper.KEY);            } 
/***    private static testMethod void fireAPTasksWithConditionalItemCreationTest()     { fireAPTasksCreationTest(ECICActionPlanHelper.CONDITIONAL);    } 
    private static testMethod void fireAPTasksWithOptionalItemsCreationTest()       { fireAPTasksCreationTest(ECICActionPlanHelper.OPTIONAL);       } 
    private static testMethod void fireAPTasksWithDisposableItemsCreationTest()     { fireAPTasksCreationTest(ECICActionPlanHelper.DISPOSABLE);     } */

    private static void checkTaskConditionEqualsTest (Integer arraySize, Integer matchPosition)
    {
        List<String> dummyStringList = new List<String>();
        for (Integer i=1; i<=arraySize; i++) { dummyStringList.add((i == matchPosition) ? 'Match' : 'Dummy_' + i); }
        
        String   dummyApConditionString = createDummyApConditionString (matchPosition);
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER) 
        {
            Test.startTest();
            {
                result = ECICActionPlanHelper.checkTaskConditionEquals (dummyStringList, dummyApConditionString);
            }
            Test.stopTest();
        }
        
        System.assertEquals((((arraySize > 0) && (matchPosition > 0)) || ((arraySize == 0) && (matchPosition < 0))), result);
    }

    private static testMethod void noValuesNullConditionCheckTaskConditionEqualsTest()  { checkTaskConditionEqualsTest (0, VALUE_IS_NULL); }
/***    private static testMethod void noValuesEmptyConditionCheckTaskConditionEqualsTest() { checkTaskConditionEqualsTest (0, VALUE_IS_EMPTY); }
    private static testMethod void noValuesOneConditionCheckTaskConditionEqualsTest()   { checkTaskConditionEqualsTest (0, NO_MATCHING_VALUE);  }
    private static testMethod void oneValueNoMatchCheckTaskConditionEqualsTest()        { checkTaskConditionEqualsTest (1, NO_MATCHING_VALUE);  }
    private static testMethod void oneValueFirstMatchCheckTaskConditionEqualsTest()     { checkTaskConditionEqualsTest (1, 1);  }
    private static testMethod void twoValuesNoMatchCheckTaskConditionEqualsTest()       { checkTaskConditionEqualsTest (2, NO_MATCHING_VALUE);  }
    private static testMethod void twoValuesFirstMatchCheckTaskConditionEqualsTest()    { checkTaskConditionEqualsTest (2, 1);  }
    private static testMethod void twoValuesLastMatchCheckTaskConditionEqualsTest()     { checkTaskConditionEqualsTest (2, 2);  }
    private static testMethod void threeValuesNoMatchCheckTaskConditionEqualsTest()     { checkTaskConditionEqualsTest (3, NO_MATCHING_VALUE);  }
    private static testMethod void threeValuesFirstMatchCheckTaskConditionEqualsTest()  { checkTaskConditionEqualsTest (3, 1);  }
    private static testMethod void threeValuesMiddleMatchCheckTaskConditionEqualsTest() { checkTaskConditionEqualsTest (3, 2);  }
    private static testMethod void threeValuesLastMatchCheckTaskConditionEqualsTest()   { checkTaskConditionEqualsTest (3, 3);  } */


    private static void checkTaskConditionNotEqualsTest (Integer arraySize, Integer matchPosition)
    {
        List<String> dummyStringList = new List<String>();
        for (Integer i=1; i<=arraySize; i++) { dummyStringList.add((i == matchPosition) ? 'Match' : 'Dummy_' + i); }
        
        String   dummyApConditionString = createDummyApConditionString (matchPosition);
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER) 
        {
            Test.startTest();
            {
                result = ECICActionPlanHelper.checkTaskConditionNotEquals (dummyStringList, dummyApConditionString);
            }
            Test.stopTest();
        }
        System.debug('######## dummyApConditionString : ' + dummyApConditionString);
        System.debug('######## result : ' + result);
        System.assertNotEquals(
                                (
                                    ((arraySize > 0) && (matchPosition > 0))    // Match found
                                        ||
                                    ((arraySize == 0) && (matchPosition < 0))   // Neither list nor string represents value.
                                )
                                , result);
    }

    private static testMethod void noValuesNullConditionCheckTaskConditionNotEqualsTest()   { checkTaskConditionNotEqualsTest (0, VALUE_IS_NULL); }
/***    private static testMethod void noValuesEmptyConditionCheckTaskConditionNotEqualsTest()  { checkTaskConditionNotEqualsTest (0, VALUE_IS_EMPTY); }
    private static testMethod void noValuesOneConditionCheckTaskConditionNotEqualsTest()    { checkTaskConditionNotEqualsTest (0, NO_MATCHING_VALUE); }
    private static testMethod void oneValueNoMatchCheckTaskConditionNotEqualsTest()         { checkTaskConditionNotEqualsTest (1, NO_MATCHING_VALUE); }
    private static testMethod void oneValueFirstMatchCheckTaskConditionNotEqualsTest()      { checkTaskConditionNotEqualsTest (1, 1); }
    private static testMethod void twoValuesNoMatchCheckTaskConditionNotEqualsTest()        { checkTaskConditionNotEqualsTest (2, NO_MATCHING_VALUE); }
    private static testMethod void twoValuesFirstMatchCheckTaskConditionNotEqualsTest()     { checkTaskConditionNotEqualsTest (2, 1); }
    private static testMethod void twoValuesLastMatchCheckTaskConditionNotEqualsTest()      { checkTaskConditionNotEqualsTest (2, 2); }
    private static testMethod void threeValuesNoMatchCheckTaskConditionNotEqualsTest()      { checkTaskConditionNotEqualsTest (3, NO_MATCHING_VALUE); }
    private static testMethod void threeValuesFirstMatchCheckTaskConditionNotEqualsTest()   { checkTaskConditionNotEqualsTest (3, 1); }
    private static testMethod void threeValuesMiddleMatchCheckTaskConditionNotEqualsTest()  { checkTaskConditionNotEqualsTest (3, 2); }
    private static testMethod void threeValuesLastMatchCheckTaskConditionNotEqualsTest()    { checkTaskConditionNotEqualsTest (3, 3); } */

    private static void checkTaskConditionTest(String conditionOperator, Integer arraySize, Integer matchPosition)
    {
    
        String conditionValues = '';
        for (Integer i=1; i<=arraySize; i++) { conditionValues += ((i == matchPosition) ? 'Match' : 'Dummy_' + i) + ECICActionPlanHelper.DELIMITER; }

        Action_Plan__c      dummyActionPlan     = ECICActionPlanTestHelper.createDummyActionPlan(true);
        Action_Plan_Item__c dummyActionPlanItem = ECICActionPlanItemTestHelper.createDummyActionPlanItem(dummyActionPlan, true);
        
        ECICApTaskConditionTestHelper.ActionPlanTaskConfig config = new ECICApTaskConditionTestHelper.ActionPlanTaskConfig();
                                                           config.operator        = conditionOperator;
                                                           config.delimitedValues = conditionValues;
        AP_Task_Condition__c dummyApCondition       = ECICApTaskConditionTestHelper.createDummyApTaskCondition(dummyActionPlanItem, config, true);  
        String               dummyApConditionString = createDummyApConditionString (matchPosition);
        
        Boolean result = null;
        System.runAs(TEST_RUN_USER) 
        {
            Test.startTest();
            {
                result = ECICActionPlanHelper.checkTaskCondition(dummyApCondition, dummyApConditionString);
            }
            Test.stopTest();
        }
        
        Boolean expectedResult = (conditionOperator == ECICActionPlanHelper.QUALS)
                                    ? ((arraySize > 0) && (matchPosition > 0))
                                    : ((arraySize < 1) || (matchPosition < 1));
        
        System.assertEquals (expectedResult, result);
    }

    private static testMethod void equalOpNoValuesNoMatchCheckTaskConditionTest()        { checkTaskConditionTest(ECICActionPlanHelper.QUALS,    0,  NO_MATCHING_VALUE);    }
/***    private static testMethod void equalOpOneValuesFirstMatchCheckTaskConditionTest()    { checkTaskConditionTest(ECICActionPlanHelper.QUALS,    1,  1);    }
    private static testMethod void equalOpTwoValuesFirstMatchCheckTaskConditionTest()    { checkTaskConditionTest(ECICActionPlanHelper.QUALS,    2,  1);    }
    private static testMethod void equalOpTwoValuesLastMatchCheckTaskConditionTest()     { checkTaskConditionTest(ECICActionPlanHelper.QUALS,    2,  2);    }
    private static testMethod void notEqualOpNoValuesNoMatchCheckTaskConditionTest()     { checkTaskConditionTest(ECICActionPlanHelper.NOT_QUALS, 0,  NO_MATCHING_VALUE);   }
    private static testMethod void notEqualOpOneValuesFirstMatchCheckTaskConditionTest() { checkTaskConditionTest(ECICActionPlanHelper.NOT_QUALS, 1,  1);   }
    private static testMethod void notEqualOpTwoValuesFirstMatchCheckTaskConditionTest() { checkTaskConditionTest(ECICActionPlanHelper.NOT_QUALS, 2,  1);   }
    private static testMethod void notEqualOpTwoValuesLastMatchCheckTaskConditionTest()  { checkTaskConditionTest(ECICActionPlanHelper.NOT_QUALS, 2,  2);   } */


/**
 * TODO: Write tests for
 * @testVisible private static Boolean checkTaskCondition(Boolean isMatched, Case targetCase, Action_Plan_Item__c actionPlanItem, AP_Task_Condition__c apCondition)
 * public static boolean checkTaskConditions(Case c, Action_Plan_Item__c item)
 * public static List<Task> fireAPTasksCreation(Case c) 
 * public static Integer evaluateAPTasksCount(Case c)
 * public static Task addTaskByTemplate(Case c, Action_Plan_Item__c item) 
 * public static String resolveOwnerId (Case c, Action_Plan_Item__c item) 
 * public static void fireActionPlanRemoved(Case c)
 * public static List<Task> process(Case c, Case old) 
 * public static void process(List<Case> newCases, Map<Id, Case> newMap,  Map<Id, Case> oldMap)
 * public static List<Task> processAPTasksOnCaseInsert(Case c, Case old)
 * public static void processAPTasksOnCaseInsert(List<Case> newCases) 
 * private static void sendNotificationEmail(List<Task> allTasks)
 *
 *
 **/
 

    private static String createDummyApConditionString (Integer matchPosition)
    {
        return (matchPosition > 0) 
                        ? 'Match' 
                        : ( (matchPosition == NO_MATCHING_VALUE) 
                                ? 'No_Match' 
                                : ( (matchPosition == VALUE_IS_EMPTY)
                                        ?   ''
                                        :   null 
                                    )
                          );
    }
    
}