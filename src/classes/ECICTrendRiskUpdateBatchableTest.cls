@isTest
public class ECICTrendRiskUpdateBatchableTest 
{
    private static final User TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();

    private static testMethod void buildTrendIdSetTest()              
    { 
    	Trend__c dummyTrend = TEST_DummyTrendFactory.create(TEST_DummyInsertModeEnum.MOCK);
    	
    	Set<Id> resultTrendIdSet = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
            	resultTrendIdSet = ECICTrendRiskUpdateBatchable.buildTrendIdSet(new List<Trend__c>{ dummyTrend });
            }
            Test.stopTest();
        }
        
        System.assert (resultTrendIdSet.contains(dummyTrend.id));
    }
    
    //-------------------------------------------------------------------------------------------------

    private static testMethod void buildCaseListByTrendIdMapTest()    
    { 
        Trend__c dummyTrend = TEST_DummyTrendFactory.create(TEST_DummyInsertModeEnum.MOCK);
        
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.trendId = dummyTrend.id;
        Case dummyCase = TEST_DummyFastQualityComplaintCaseFactry.create (caseConfig, TEST_DummyInsertModeEnum.MOCK);
                         
        Map<Id, List<Case>> resultCaseListByTrendIdMap = null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                resultCaseListByTrendIdMap = ECICTrendRiskUpdateBatchable.buildCaseListByTrendIdMap(new Set<Id>{ dummyTrend.id }, new List<Case>{ dummyCase });
            }
            Test.stopTest();
        }
        
        System.assert (resultCaseListByTrendIdMap.containsKey(dummyTrend.id));
        System.assertEquals (dummyCase, resultCaseListByTrendIdMap.get(dummyTrend.id)[0]);
    }
    
    //-------------------------------------------------------------------------------------------------

    private static testMethod void noTrendCaseListUpdateTest()            
    { 
        Trend__c dummyTrend = TEST_DummyTrendFactory.create(TEST_DummyInsertModeEnum.MOCK);
        
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.trendId = dummyTrend.id;
        Case dummyCase = TEST_DummyFastQualityComplaintCaseFactry.create (caseConfig, TEST_DummyInsertModeEnum.MOCK);

        List<Case> resultUpdateCaseList     = new List<Case>();
        Set<Id>    resultDeleteTrendIdSet   = new Set<Id>();
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICTrendRiskUpdateBatchable.noTrendCaseListUpdate(new List<Case>{ dummyCase }, resultUpdateCaseList, dummyTrend.id, resultDeleteTrendIdSet);
            }
            Test.stopTest();
        }
        
        System.assert (resultDeleteTrendIdSet.contains(dummyTrend.id));
        System.assertEquals (dummyCase, resultUpdateCaseList[0]);
        System.assertEquals (null,      resultUpdateCaseList[0].trend__c);
    }
    
    //-------------------------------------------------------------------------------------------------

    private static void potentialTrendCaseListUpdateTest(Boolean hasThirdComplaint)     
    { 
        Trend__c dummyTrend = TEST_DummyTrendFactory.create(TEST_DummyInsertModeEnum.MOCK);
        
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.trendId        = dummyTrend.id;
                             caseConfig.thirdComplaint = hasThirdComplaint;
        Case dummyCase = TEST_DummyFastQualityComplaintCaseFactry.create (caseConfig, TEST_DummyInsertModeEnum.MOCK);

        List<Case> resultUpdateCaseList     = new List<Case>();
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICTrendRiskUpdateBatchable.potentialTrendCaseListUpdate(new List<Case>{ dummyCase }, resultUpdateCaseList);
            }
            Test.stopTest();
        }
        
        System.assertEquals ((hasThirdComplaint) ? 1 : 0, resultUpdateCaseList.size());
        if (hasThirdComplaint)
        {
            System.assertEquals (dummyCase, resultUpdateCaseList[0]);
            System.assertEquals (false,     resultUpdateCaseList[0].The3rdComplaint__c);
        }
    }

    private static testMethod void thirdComplaintPotentialTrendCaseListUpdateTest() { potentialTrendCaseListUpdateTest(true ); }
    private static testMethod void otherComplaintPotentialTrendCaseListUpdateTest() { potentialTrendCaseListUpdateTest(false); }
    
    //-------------------------------------------------------------------------------------------------

    private static void riskTrendCaseListUpdateTest(Boolean hasThirdComplaint)  
    { 
        Trend__c dummyTrend = TEST_DummyTrendFactory.create(TEST_DummyInsertModeEnum.MOCK);
        
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.trendId        = dummyTrend.id;
                             caseConfig.thirdComplaint = hasThirdComplaint;
        Case dummyCase = TEST_DummyFastQualityComplaintCaseFactry.create (caseConfig, TEST_DummyInsertModeEnum.MOCK);

        List<Case> resultUpdateCaseList     = new List<Case>();
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICTrendRiskUpdateBatchable.riskTrendCaseListUpdate(new List<Case>{ dummyCase }, resultUpdateCaseList);
            }
            Test.stopTest();
        }
        
        System.assertEquals ((!hasThirdComplaint) ? 1 : 0, resultUpdateCaseList.size());
        if (!hasThirdComplaint)
        {
            System.assertEquals (dummyCase, resultUpdateCaseList[0]);
            System.assertEquals (true,      resultUpdateCaseList[0].The3rdComplaint__c);
        }
    }

    private static testMethod void hasNoThirdComplaintRiskTrendCaseListUpdateTest() { riskTrendCaseListUpdateTest(false); }
    private static testMethod void hasThirdComplaintRiskTrendCaseListUpdateTest()   { riskTrendCaseListUpdateTest(true ); }

    //-------------------------------------------------------------------------------------------------

    private static void caseListUpdateTest(Integer dummyCaseListSize)                   
    { 
        Trend__c dummyTrend = TEST_DummyTrendFactory.create(TEST_DummyInsertModeEnum.MOCK);
        
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.trendId        = dummyTrend.id;
                             caseConfig.thirdComplaint = (dummyCaseListSize < 3);                  
        List<Case> dummyCaseList = TEST_DummyFastQualityComplaintCaseFactry.createList (dummyCaseListSize, caseConfig, TEST_DummyInsertModeEnum.MOCK);

        List<Case> resultUpdateCaseList     = new List<Case>();
        Set<Id>    resultDeleteTrendIdSet   = new Set<Id>();
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest();
            {
                ECICTrendRiskUpdateBatchable.caseListUpdate (dummyTrend.id, dummyCaseList, resultUpdateCaseList, resultDeleteTrendIdSet);
            }
            Test.stopTest();
        }

        Integer expectedUpdateCaseListSize = (dummyCaseListSize < 3) ? dummyCaseListSize : 1;
        System.assertEquals (expectedUpdateCaseListSize, resultUpdateCaseList.size());
        
        Integer expectedDeleteTrendIdSetSize = (dummyCaseListSize < 2) ? 1 : 0;
        System.assertEquals (expectedDeleteTrendIdSetSize, resultDeleteTrendIdSet.size());
    }
    
    private static void zeroCaseListUpdateTest()  { caseListUpdateTest(0); }                   
    private static void oneCaseListUpdateTest()   { caseListUpdateTest(1); }                   
    private static void twoCaseListUpdateTest()   { caseListUpdateTest(2); }                   
    private static void threeCaseListUpdateTest() { caseListUpdateTest(3); }                   
    
    //-------------------------------------------------------------------------------------------------

    private static void executeTest(Boolean trendRequiresDelete, Boolean isBatchableTest)                          
    {
    	Integer dummyCaseListSize = (trendRequiresDelete) ? 1 : 2;

    	TEST_DummyTrendFactory.Config trendConfig = new TEST_DummyTrendFactory.Config();
    	                              trendConfig.recheckPotentialRisk = true;
        Trend__c dummyTrend = TEST_DummyTrendFactory.create(trendConfig, TEST_DummyInsertModeEnum.REAL);
        
        TEST_DummyCaseConfig caseConfig = new TEST_DummyCaseConfig();
                             caseConfig.trendId        = dummyTrend.id;
                             caseConfig.thirdComplaint = true;                  
        List<Case> dummyCaseList = TEST_DummyFastQualityComplaintCaseFactry.createList (dummyCaseListSize, caseConfig, TEST_DummyInsertModeEnum.REAL);
    
        ECICTrendRiskUpdateBatchable updateBatchable = (isBatchableTest) ? new ECICTrendRiskUpdateBatchable() : null;
        System.runAs(TEST_RUN_USER)
        {
            Test.startTest(); 
            {
                if (isBatchableTest) { Database.executeBatch(updateBatchable);                                  }            
                else                 { ECICTrendRiskUpdateBatchable.execute (new List<Trend__c>{ dummyTrend }); }
            }
            Test.stopTest();
        }
        
        List<Trend__c> resultTrendList = [SELECT id, recheck_potential_risk__c FROM Trend__c WHERE id = : dummyTrend.id];
        System.assertEquals((trendRequiresDelete) ? 0 : 1, resultTrendList.size());
        
        if (!trendRequiresDelete)
        {
        	List<Case> resultCaseList = [SELECT id, the3rdComplaint__c FROM Case WHERE id IN :dummyCaseList];
        	for (Case resultCase : resultCaseList) { System.assert(!resultCase.the3rdComplaint__c); }
        }
    }
    
    private static testMethod void privateRequiresUpdateExecuteTest()    { executeTest(false, false); }                          
    private static testMethod void privateRequiresDeleteExecuteTest()    { executeTest(true , false); }                          
    private static testMethod void batachableRequiresUpdateExecuteTest() { executeTest(false, true ); }                          
    private static testMethod void batachableRequiresDeleteExecuteTest() { executeTest(true , true ); }                          
}