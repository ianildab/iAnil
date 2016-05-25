@isTest
private class ECICCaseTypeSetterStrategyTest {
    private static final User TEST_RUN_USER                          = ECICRunUserTestHelper.create();
    private static ECICCaseTypeSetterStrategy dummyStrategy          = new ECICCaseTypeSetterStrategy();
    
    private static void getTypeTest (String targetCaseRecordTypeName) {
        Id recordTypeId =  Schema.Sobjecttype.Case.RecordTypeInfosByName.get(targetCaseRecordTypeName).RecordTypeId;
        
        String resultTypeName = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                resultTypeName = ECICCaseTypeSetterStrategy.getType(recordTypeId);
            }
            Test.stopTest();
        }
        
   //     System.assertEquals (getExpectedTypeName(targetCaseRecordTypeName), resultTypeName);
    }
    
    private static String getExpectedTypeName(String recordTypeName) {
        return (recordTypeName == 'Quality Complaint Iberia')
                    ?   'Quality Complaint Iberia'
                    :   recordTypeName;
    }
   // # Ecic Template test
    private static testMethod void inquiryGetTypeTest()                     { getTypeTest (ECICCommonConstants.INQUIRY_IBERIA_RTNAME);                       }
    private static testMethod void jokeGetTypeTest()                        { getTypeTest (ECICCommonConstants.USELESS_IBERIA_RTNAME);                }
    private static testMethod void nonQualityComplaintGetTypeTest()         { getTypeTest (ECICCommonConstants.NON_QUALITY_COMPLAINT_IBERIA_RTNAME);         }
    private static testMethod void qualityComplaintGetTypeTest()            { getTypeTest (ECICCommonConstants.QUALITY_COMPLAINT_IBERIA  );             }
  //  private static testMethod void simplifiedQualityComplaintGetTypeTest()  { getTypeTest ('Simplified Quality Complaint');  }
    private static testMethod void thanksGetTypeTest()                      { getTypeTest (ECICCommonConstants.COMPLIMENT_IBERIA_RTNAME);                        }
//    private static testMethod void spamGetTypeTest()                        { getTypeTest ('Spam Iberia');                          }
   // end of ecic  
    private static void startegyTest (Boolean isInsertTest, String targetCaseRecordTypeName) {
        TEST_DummyCaseConfig caseConfig                 = new TEST_DummyCaseConfig();
                             caseConfig.recordTypeId =  Schema.Sobjecttype.Case.RecordTypeInfosByName.get(targetCaseRecordTypeName).RecordTypeId;
        					 system.debug('sssssssssssssssssssssss'+caseConfig.recordTypeId);
        					 
        Case dummyCase = TEST_DummyGenericCaseFactory.create (caseConfig, TEST_DummyInsertModeEnum.MOCK);
        system.debug('dummyCase'+dummyCase);
        Boolean strategyResult = null;
        System.runAs(TEST_RUN_USER) {
            Test.startTest();
            {
                if (isInsertTest) {
                    strategyResult = dummyStrategy.OnBeforeInsert(new List<Case> { dummyCase });
                } else {
                    strategyResult = dummyStrategy.OnBeforeUpdate(new Map<ID, Case> { dummyCase.Id => dummyCase },
                                                                  new Map<ID, Case> { dummyCase.Id => dummyCase });
                }
            }
            Test.stopTest();
        }
        
        System.assertEquals (true, strategyResult);
        assertRecordType (dummyCase, targetCaseRecordTypeName);
    }
    
    private static void assertRecordType (Case resultCase, String recordTypeName) {
   //     System.assertEquals (getExpectedTypeName(recordTypeName), resultCase.type);
    }
     // # Ecic Template test
    private static testMethod void nonQualityComplaintGetTypeInsertTest()           { startegyTest (true, ECICCommonConstants.NON_QUALITY_COMPLAINT_IBERIA_RTNAME);          }
    private static testMethod void qualityComplaintGetTypeInsertTest()              { startegyTest (true, ECICCommonConstants.QUALITY_COMPLAINT_IBERIA );              }
  //  private static testMethod void simplifiedQualityComplaintGetTypeInsertTest()    { startegyTest (true, 'Simplified Quality Complaint');   }
    private static testMethod void inquiryGetTypeInsertTest()                       { startegyTest (true, ECICCommonConstants.INQUIRY_IBERIA_RTNAME);                        }
    private static testMethod void jokeGetTypeInsertTest()                          { startegyTest (true, ECICCommonConstants.USELESS_IBERIA_RTNAME);                 }
    private static testMethod void thanksGetTypeInsertTest()                        { startegyTest (true,ECICCommonConstants.COMPLIMENT_IBERIA_RTNAME);                         }
 //   private static testMethod void spamGetTypeInsertTest()                          { startegyTest (true, 'Spam Iberia');                           }
    
    private static testMethod void nonQualityComplaintGetTypeUpdateTest()           { startegyTest (false,ECICCommonConstants.NON_QUALITY_COMPLAINT_IBERIA_RTNAME);         }
    private static testMethod void qualityComplaintGetTypeUpdateTest()              { startegyTest (false, ECICCommonConstants.QUALITY_COMPLAINT_IBERIA );             }
 //   private static testMethod void simplifiedQualityComplaintGetTypeUpdateTest()    { startegyTest (false, 'Simplified Quality Complaint Iberia');  }
    private static testMethod void inquiryGetTypeUpdateTest()                       { startegyTest (false, ECICCommonConstants.INQUIRY_IBERIA_RTNAME);                       }
   private static testMethod void jokeGetTypeUpdateTest()                          { startegyTest (false, ECICCommonConstants.USELESS_IBERIA_RTNAME);                }
	  private static testMethod void thanksGetTypeUpdateTest()                        { startegyTest (false, ECICCommonConstants.COMPLIMENT_IBERIA_RTNAME);                        }
 //   private static testMethod void spamGetTypeUpdateTest()                          { startegyTest (false, 'Spam Iberia');                          }
   // end of ecic  
}