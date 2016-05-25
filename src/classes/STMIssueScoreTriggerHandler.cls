public with sharing class STMIssueScoreTriggerHandler {
    
    
    /**
     * @author  Pavel_Slepenkov
     * @param   issueScores (Trigger.new) - the list of inserted/updated STMIssueScore__c objects with new values
     * @date    19 Nov 2012
     */
    public static void issueScoresHistoryTracker(List<STMIssueScore__c> issueScores) {

        List<STMIssueScoreHistory__c> issueScoresHistories = new List<STMIssueScoreHistory__c>();
        for (STMIssueScore__c issueScore: issueScores) {
            issueScoresHistories.add(
                new STMIssueScoreHistory__c(
                    AbilityLeadShapePublicOpinion__c = issueScore.AbilityLeadShapePublicOpinion__c,
                    LevelInfluencePolicyMakers__c = issueScore.LevelInfluencePolicyMakers__c,
                    GenerallyRecognizedExperts__c = issueScore.GenerallyRecognizedExperts__c,
                    SizeSupportBaseFollowersAliances__c = issueScore.SizeSupportBaseFollowersAliances__c,
                    AttitudeFoodDrinkIindustry__c = issueScore.AttitudeFoodDrinkIindustry__c,
                    AttitudeCocaCola__c = issueScore.AttitudeCocaCola__c,
                    InterestInIssuesMatterYou__c = issueScore.InterestInIssuesMatterYou__c,
                    AttitudeScore__c = issueScore.AttitudeScore__c,
                    InfluenceScore__c = issueScore.InfluenceScore__c,
                    Contact__c = issueScore.Contact__c,
                    Issue__c = issueScore.Issue__c,
                    IssueScore__c = issueScore.Id,
                    Description__c = issueScore.Description__c,
                    LastIssueScoreModification__c = issueScore.LastModifiedDate
                    )
                );
        }
        
        insert issueScoresHistories;
        
    }
    
    /**
     * @author  Pavel_Slepenkov
     * @param   issueScores (Trigger.new) - the list of inserted/updated STMIssueScore__c objects with new values
     * @date    19 Nov 2012
     */
    public static Map<Id, String> sortIssueScoresByIssues(List<STMIssueScore__c> issueScores) {
        List<id> currentIssuesIds = new List<Id>();
        Map<Id, String> issueScoresByIssue = new Map<Id, String>();
        String tmpIssueScoresId;
        
        for (STMIssueScore__c issueScore: issueScores) {
            currentIssuesIds.add(issueScore.Issue__c);
        }

        for (STMIssueScore__c issueScore: [SELECT Id, Issue__c, Contact__c FROM STMIssueScore__c WHERE Issue__c IN:currentIssuesIds]) {
            if (tmpIssueScoresId != null && tmpIssueScoresId != '') {
                tmpIssueScoresId = '';
            }
            
            if (issueScore.Contact__c != null) {
                if (issueScoresByIssue.containsKey(issueScore.Issue__c)) {
                    tmpIssueScoresId = issueScoresByIssue.get(issueScore.Issue__c);
                    tmpIssueScoresId += ((String)issueScore.Contact__c).substring(3);
                    issueScoresByIssue.remove(issueScore.Issue__c);
                    issueScoresByIssue.put(issueScore.Issue__c, tmpIssueScoresId);
                } else {
                    tmpIssueScoresId = ((String)issueScore.Contact__c).substring(3);
                    issueScoresByIssue.put(issueScore.Issue__c, tmpIssueScoresId);
                } 
            }        
        }
        
        return issueScoresByIssue;
    }
    
}