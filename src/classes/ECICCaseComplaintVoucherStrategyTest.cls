@isTest
private class ECICCaseComplaintVoucherStrategyTest 
{
    private static final User                             TEST_RUN_USER         = TEST_DummyUserFactory.createDefaultTestRunUser();
    private static final ECICCaseComplaintVoucherStrategy TARGET_STRATEGY       = new ECICCaseComplaintVoucherStrategy();

    private static final Integer                          DEFAULT_BONUS         = TEST_DummyCountrySpecificSettingsFactory.DEFAULT_BONUS;
    private static final String                           DEFAULT_COUNTRY_CODE  = ECICCommonConstants.COUNTRY_CODE_DEFAULT;
    
    static
    {
        createCountrySpecificSettings();
    }
    
    private static void setVaucherValueTest(Boolean hasNumberOfPacks, Boolean hasUnitPrice, Boolean hasCountrySpecificBonus)
    { 
        Integer numberOfPacks = hasNumberOfPacks ? 100  : TEST_ConfigHelper.INTENTIONAL_NULL_FOR_NUMBER;
        Decimal unitPrice     = hasUnitPrice     ? 9.59 : TEST_ConfigHelper.INTENTIONAL_NULL_FOR_NUMBER;
        Case    dummyCase     = createNewCase (numberOfPacks, unitPrice);
        if (!hasCountrySpecificBonus) { dummyCase.Country_Code__c = 'Z9'; } 
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_STRATEGY.setVaucherValue(dummyCase); 
            }
            Test.stopTest();
        } 
        
        if (hasNumberOfPacks && hasUnitPrice) { assertVoucherValue(numberOfPacks, unitPrice, hasCountrySpecificBonus, dummyCase); }
        else                                  { assertNullVouchers(dummyCase);                           }
    }

    private static testMethod void noPackNumberNoPriceNoCountryBonusSetVaucherValueTest()      { setVaucherValueTest(  false, false, false);  }
    private static testMethod void noPackNumberNoPriceHasCountryBonusSetVaucherValueTest()     { setVaucherValueTest(  false, false,  true);  }
    private static testMethod void noPackNumberHasPriceNoCountryBonusSetVaucherValueTest()     { setVaucherValueTest(  false, true,  false);  }
    private static testMethod void noPackNumberHasPriceHasCountryBonusSetVaucherValueTest()    { setVaucherValueTest(  false, true,   true);  }

    private static testMethod void hasPackNumberNoPriceNoCountryBonusSetVaucherValueTest()     { setVaucherValueTest(  true,  false, false);  }
    private static testMethod void hasPackNumberNoPriceHasCountryBonusSetVaucherValueTest()    { setVaucherValueTest(  true,  false,  true);  }
    private static testMethod void hasPackNumberHasPriceNoCountryBonusSetVaucherValueTest()    { setVaucherValueTest(  true,  true,  false);  }
    private static testMethod void hasPackNumberHasPriceHasCountryBonusSetVaucherValueTest()   { setVaucherValueTest(  true,  true,   true);  }


    // ------------------------------------------------------------------------------------------------------------------------------

    private static void setNumberOfVouchersTest(Boolean hasValue)
    {
        Decimal voucherValue =  hasValue ? 406.23  : TEST_ConfigHelper.INTENTIONAL_NULL_FOR_NUMBER;

        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             config.voucherValue = voucherValue;
        Case dummyCase = TEST_DummyInquiryCaseFactory.create (config, TEST_DummyInsertModeEnum.NONE); 

        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_STRATEGY.setNumberOfVouchers(dummyCase);
            }
            Test.stopTest();
        }

        if (hasValue) { assertNumberOfVouchers(voucherValue, dummyCase); }
        else          { assertNullVouchers(dummyCase);                   }  
    }

    private static testMethod void hasValueSetNumberOfVouchersTest()   { setNumberOfVouchersTest(true);  }
    private static testMethod void nullValueSetNumberOfVouchersTest()  { setNumberOfVouchersTest(false); }

    // ------------------------------------------------------------------------------------------------------------------------------

    private static void executeTest(Boolean hasOldCase, Boolean hasChangedNumberOfPacks, Boolean hasChangedUnitPrice) 
    {
        Integer    newNumberOfPacks = 50;
        Decimal    newUnitPrice     = 2.53;
        Case       dummyNewCase     = createNewCase (newNumberOfPacks, newUnitPrice); 
        List<Case> dummyNewCaseList = new List<Case>{ dummyNewCase };
        
        Map<Id, Case> dummyOldCaseByIdMap = null;
        if (hasOldCase)
        {
            Case dummyOldCase   = createOldCase(dummyNewCase, hasChangedNumberOfPacks, hasChangedUnitPrice);
            dummyNewCase.id     = dummyOldCase.id;
            dummyOldCaseByIdMap = new Map<Id, Case> { dummyOldCase.id => dummyOldCase };    
        } 
        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                TARGET_STRATEGY.execute(dummyOldCaseByIdMap, dummyNewCaseList);
            }
            Test.stopTest();
        }

        if (!hasOldCase || hasChangedNumberOfPacks || hasChangedUnitPrice) { assertVoucherValue(newNumberOfPacks, newUnitPrice, true, dummyNewCase, true); }
        else                                                               { assertNullVouchers(dummyNewCase);                                             }  
    }
    
    private static testMethod void noOldExecuteTest()               { executeTest(false, false, false); }
    private static testMethod void hasOldExecuteTest()              { executeTest(true , false, false); }
    private static testMethod void changedPriceExecuteTest()        { executeTest(true , false, true ); }
    private static testMethod void changedPackQuantityExecuteTest() { executeTest(true , true , false); }
    private static testMethod void changedAllExecuteTest()          { executeTest(true , true , true ); }

    // ------------------------------------------------------------------------------------------------------------------------------

    private static void onBeforeMethodTest(Boolean isInsertTest, Boolean isQualityComplaint) 
    {
        Boolean    isUpdateTest = !isInsertTest;
        Integer    newNumberOfPacks = 26;
        Decimal    newUnitPrice     = 1.56;
        Case       dummyNewCase     = createNewCase (newNumberOfPacks, newUnitPrice, isQualityComplaint); 
        
        Case dummyOldCase           =  null;
        if (isUpdateTest)
        {
            dummyOldCase    = createOldCase(dummyNewCase, true, true);
            dummyNewCase.id = dummyOldCase.id;
        } 

        Boolean result = null;        
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                result = (isInsertTest)
                            ? TARGET_STRATEGY.onBeforeInsert(new List<Case>    { dummyNewCase })
                            : TARGET_STRATEGY.onBeforeUpdate(new Map<Id, Case> { dummyOldCase.id => dummyOldCase }, new Map<Id, Case> { dummyNewCase.id => dummyNewCase });
            }
            Test.stopTest();
        }

        System.assert(result);
        if (isQualityComplaint) { assertVoucherValue(newNumberOfPacks, newUnitPrice, true, dummyNewCase, true); }
        else                    { assertNullVouchers(dummyNewCase);                                             }  
    }
    
    private static testMethod void updateInquiryOnBeforeMethodTest()          { onBeforeMethodTest(false, false); }
    private static testMethod void updateQualityComplaintOnBeforeMethodTest() { onBeforeMethodTest(false, true ); }
    private static testMethod void insertInquiryOnBeforeMethodTest()          { onBeforeMethodTest(true , false); }
    private static testMethod void insertQualityComplaintOnBeforeMethodTest() { onBeforeMethodTest(true , true ); }

    // ------------------------------------------------------------------------------------------------------------------------------

    private static Country_Specific_Settings__c createCountrySpecificSettings()
    {
        TEST_DummyCountrySpecificSettingsFactory.Config config = new TEST_DummyCountrySpecificSettingsFactory.Config();
                                                        config.countryCode = DEFAULT_COUNTRY_CODE;
                                                        config.bonus       = DEFAULT_BONUS;
        return TEST_DummyCountrySpecificSettingsFactory.create (config, TEST_DummyInsertModeEnum.REAL);                                                                 
    }

    private static Case createNewCase (Integer numberOfPacks, Decimal unitPrice, Boolean isQualityComplaint)
    {
        TEST_DummyCaseConfig config = new TEST_DummyCaseConfig();
                             /*#CICTemplateTest*/
                             config.recordTypeId     = (isQualityComplaint) ? TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(ECICCommonConstants.QUALITY_COMPLAINT_IBERIA_DEVNAME) : TEST_DummyGenericCaseFactory.CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(ECICCommonConstants.INQUIRY_IBERIA_DEVNAME);
                             config.numberOfPacks    = numberOfPacks;    
                             config.productUnitPrice = unitPrice;
                             config.countryCode      = DEFAULT_COUNTRY_CODE;
        return TEST_DummyGenericCaseFactory.create (config, TEST_DummyInsertModeEnum.NONE); 
    }

    private static Case createNewCase (Integer numberOfPacks, Decimal unitPrice) { return createNewCase (numberOfPacks, unitPrice, false); }

    private static Case createOldCase(Case dummyNewCase, Boolean hasChangedNumberOfPacks, Boolean hasChangedUnitPrice)
    {
        Case dummyOldCase = dummyNewCase.clone(false);
             dummyOldCase.no_of_packs__c        = hasChangedNumberOfPacks ? 35   : dummyNewCase.no_of_packs__c;
             dummyOldCase.product_unit_price__c = hasChangedUnitPrice     ? 1.45 : dummyNewCase.product_unit_price__c;
        TEST_MockHelper.mockInsert(dummyOldCase);
        return dummyOldCase;
    }
    

    // ------------------------------------------------------------------------------------------------------------------------------
    
    private static void assertVoucherValue(Integer numberOfPacks, Decimal unitPrice, Boolean hasCountrySpecificBonus, Case resultCase, Boolean assertNumberOfVouchers)
    {
        Decimal countrySpecificBonus    = (hasCountrySpecificBonus ? ((Decimal) DEFAULT_BONUS/100) : 0);
        Decimal expectedBonusMultiplier = 1 + countrySpecificBonus;
        Double expectedValue = ((numberOfPacks != null) && (unitPrice != null)) ? (Math.ceil (unitPrice * numberOfPacks * expectedBonusMultiplier)) : null;

        System.assertEquals (expectedValue, resultCase.value_of_vouchers__c);
        if (assertNumberOfVouchers)
        {
            assertNumberOfVouchers(expectedValue, resultCase);
        }
    }

    private static void assertVoucherValue(Integer numberOfPacks, Decimal unitPrice, Boolean hasCountrySpecificBonus, Case resultCase) { assertVoucherValue(numberOfPacks, unitPrice, hasCountrySpecificBonus, resultCase, false);  }
    
    private static void assertNumberOfVouchers(Decimal voucherValue, Case resultCase)
    {
        System.assertEquals(Math.mod  ((Integer) voucherValue,2), resultCase.No_1Euro_vouchers__c);
        System.assertEquals(Math.floor((Integer) voucherValue/2), resultCase.No_2Euro_vouchers__c);
    }

    private static void assertNullVouchers(Case resultCase)
    {
            System.assertEquals (null, resultCase.value_of_vouchers__c);       
            System.assertEquals (null, resultCase.No_1Euro_vouchers__c);
            System.assertEquals (null, resultCase.No_2Euro_vouchers__c);
    }
    

}