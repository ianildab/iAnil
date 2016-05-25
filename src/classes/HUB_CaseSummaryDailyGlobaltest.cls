@isTest(SeeAllData=true)
private class HUB_CaseSummaryDailyGlobaltest {

    static testMethod void myUnitTest() {
        Test.startTest();
        HUB_CaseSummaryDailyGlobal batch = new HUB_CaseSummaryDailyGlobal ();
        batch = new HUB_CaseSummaryDailyGlobal ('xxxx');
        batch.setAsBatch(false);
        batch.start(null);
        batch.execute(null,[SELECT id, Subject, Description, Createdby.Name, CaseNumber, Status, CreatedDate, LastModifiedDate, HUB_Risk__c, HUB_Risk_Type__c, (SELECT Region__c FROM Impacted_Regions__r) FROM Case WHERE Id IN (SELECT Case__c FROM HUB_Impacted_Region__c WHERE Region__c = 'Pacific')]);       
        batch.execute(null);        
        batch.finish(null);
        Test.stopTest();
    }
}