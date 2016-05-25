/*
Author : Aditya Bansod,Capgemini
Date : 29th May,2015
Purpose - Batch Class to update trends to inactive if latest case association is more than 14 days.
*/
global class CICActiveTrendUpdateBatchable implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        String trendsQuery = 'SELECT id, name, status__c, (SELECT Case.Id, Case.CCE_Trend_Association_Date__c FROM Cases__r) FROM CCE_trend__c WHERE status__c=' + '\'Active\'';
        return Database.getQueryLocator(trendsQuery);
    }
    
    global void execute(Database.BatchableContext BC,List<CCE_Trend__c> trendsList){
        List<CCE_Trend__c> updateTrendsList = new List<CCE_Trend__c>();
        for(CCE_Trend__c trend : trendsList){
            if(isInactivetrend(trend.Cases__r)){
                trend.status__c = 'Inactive';
                updateTrendsList.add(trend);
            }
        }
        Database.update(updateTrendsList, false);
    }
    
    private Boolean isInactiveTrend(List<Case> relatedCases){
        List<Date> casetoTrendDate = new List<Date>();
        for(Case c : relatedCases){
            casetoTrendDate.add(c.CCE_Trend_Association_Date__c);   
             
        } 
        
        casetoTrendDate.sort();
        Integer daysDifference = casetoTrendDate.size()>0 && casetoTrendDate[casetoTrendDate.size()-1] != null ? casetoTrendDate[casetoTrendDate.size()-1].daysBetween(Date.today()) : 0;
        
        if(daysDifference > 14){
            return true;
        }else{
            return false;
        }
    }
    
    global void finish(Database.BatchableContext BC){}
}