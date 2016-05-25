trigger STMIssueScoreTrigger on STMIssueScore__c (before insert, before update, after insert, after update) {
   
    if (trigger.isBefore) {
        String issueScoresId;
        STMIssueScore__c old;
        Map<Id, String> issueScoresByIssue = STMIssueScoreTriggerHandler.sortIssueScoresByIssues(Trigger.new);
        
        
        for (STMIssueScore__c issueScore: Trigger.new) {
            old  = Trigger.isInsert ? null : Trigger.oldMap.get(issueScore.Id);
            
            if (Trigger.isInsert || (Trigger.isUpdate && old != null && (old.Contact__c != issueScore.Contact__c))) {
                if ( issueScoresByIssue.containsKey(issueScore.Issue__c)) {
                    issueScoresId =  issueScoresByIssue.get(issueScore.Issue__c);
                    if (issueScoresId.contains(((String)issueScore.Contact__c).substring(3))) {
                        issueScore.addError(System.label.Selected_Contact_Alreade_Linked);
                    }
                }
            }
        }
        
    } else if (trigger.isAfter) {
        
        STMIssueScoreTriggerHandler.issueScoresHistoryTracker(Trigger.new);
    
    }
}