@isTest(SeeAllData=true)
private class HUB_CaseSummaryDailyEuropetest {

    static testMethod void myUnitTest() {
        Test.startTest();
        HUB_CaseSummaryDailyEurope batch = new HUB_CaseSummaryDailyEurope ();
        batch = new HUB_CaseSummaryDailyEurope ('xxxx');
        batch.setAsBatch(false);
        batch.start(null);
        batch.execute(null,[SELECT id, Subject, Description, Createdby.Name, CaseNumber, Status, CreatedDate, LastModifiedDate,HUB_Risk__c, HUB_Risk_type__c, (SELECT Region__c FROM Impacted_Regions__r) FROM Case WHERE Id IN (SELECT Case__c FROM HUB_Impacted_Region__c WHERE Region__c = 'Pacific')]);       
        batch.execute(null);        
        batch.finish(null);
        Test.stopTest();
    }
}