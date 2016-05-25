/**
 * This class is contains a unit tests for all triggers of TCCC-STM2. 
 */

@isTest
private class STMGlobalTriggerTest {
    
    private static final Integer AMOUNT_OF_INSERTED_RECORDS     = 200;
    
//----------------------- Issue score tests section --------------------------------------------------------------------
    static testMethod void issueScoreTriggerSmokeTest() {
        STMIssueScore__c issueScore = STMTestHelper.createIssueScore();
        insert issueScore;
    }
    
    static testMethod void insertIncorrectIssueScore() {
        List<STMIssueScore__c> issueScores = new List<STMIssueScore__c>();
        for (Integer i = 0; i < AMOUNT_OF_INSERTED_RECORDS; i++) {
            issueScores.add(STMTestHelper.createIssueScore());
        }
        insert issueScores;
        
        // TODO Need to insert contact issue score witj same contact & issue
    }
    
    static testMethod void verifyIssueScoreHistoryTracking() {
        STMIssueScore__c issueScore = STMTestHelper.createIssueScore();
        insert issueScore;
        issueScore = [SELECT  Id,
                              AbilityLeadShapePublicOpinion__c,
                              LevelInfluencePolicyMakers__c,
                              GenerallyRecognizedExperts__c,
                              SizeSupportBaseFollowersAliances__c,
                              AttitudeFoodDrinkIindustry__c,
                              AttitudeCocaCola__c,
                              InterestInIssuesMatterYou__c,
                              AttitudeScore__c,
                              InfluenceScore__c,
                              Contact__c,
                              Issue__c,
                              Description__c,
                              LastModifiedDate
                       FROM STMIssueScore__c
                       WHERE Id =:issueScore.Id];
        
        
        STMIssueScoreHistory__c issueScoreHistory = [SELECT  Id,
                                                             AbilityLeadShapePublicOpinion__c,
                                                             LevelInfluencePolicyMakers__c,
                                                             GenerallyRecognizedExperts__c,
                                                             SizeSupportBaseFollowersAliances__c,
                                                             AttitudeFoodDrinkIindustry__c,
                                                             AttitudeCocaCola__c,
                                                             InterestInIssuesMatterYou__c,
                                                             AttitudeScore__c,
                                                             InfluenceScore__c,
                                                             Contact__c,
                                                             Issue__c,
                                                             IssueScore__c,
                                                             Description__c,
                                                             LastIssueScoreModification__c
                                                     FROM STMIssueScoreHistory__c
                                                     WHERE IssueScore__c =:issueScore.Id LIMIT 1];
        
        System.assertEquals(issueScore.AbilityLeadShapePublicOpinion__c, issueScoreHistory.AbilityLeadShapePublicOpinion__c);
        System.assertEquals(issueScore.LevelInfluencePolicyMakers__c, issueScoreHistory.LevelInfluencePolicyMakers__c);
        System.assertEquals(issueScore.GenerallyRecognizedExperts__c, issueScoreHistory.GenerallyRecognizedExperts__c);
        System.assertEquals(issueScore.SizeSupportBaseFollowersAliances__c, issueScoreHistory.SizeSupportBaseFollowersAliances__c);
        System.assertEquals(issueScore.AttitudeFoodDrinkIindustry__c, issueScoreHistory.AttitudeFoodDrinkIindustry__c);
        System.assertEquals(issueScore.AttitudeCocaCola__c, issueScoreHistory.AttitudeCocaCola__c);
        System.assertEquals(issueScore.InterestInIssuesMatterYou__c, issueScoreHistory.InterestInIssuesMatterYou__c);
        System.assertEquals(issueScore.AttitudeScore__c, issueScoreHistory.AttitudeScore__c);
        System.assertEquals(issueScore.InfluenceScore__c, issueScoreHistory.InfluenceScore__c);
        System.assertEquals(issueScore.Contact__c, issueScoreHistory.Contact__c);
        System.assertEquals(issueScore.Issue__c, issueScoreHistory.Issue__c);
        System.assertEquals(issueScore.Id, issueScoreHistory.IssueScore__c);
        System.assertEquals(issueScore.Description__c, issueScoreHistory.Description__c);
        System.assertEquals(issueScore.LastModifiedDate, issueScoreHistory.LastIssueScoreModification__c);
    }
    
//----------------------- End of Issue score tests section -------------------------------------------------------------
      
    
   /* static testMethod void verifyStakeholderKeyAutofilling() {
        String specialization = 'Corporate Social Responsibility';
        Contact contact = STMTestHelper.createStkhContact('name', STMTestHelper.getCompany());
        contact.Birthdate = date.today();
        contact.STMStkhSpecializationExpertise__c = specialization;
        String key = 'name_lastname' + '_' + specialization +'_' + String.valueOf(date.today());
        key = key.replace(' ', '_');
        key = key.replace('-', '_');
        key = key.toLowerCase();
        insert contact;
        contact = [SELECT STMStakeholderKey__c FROM Contact WHERE id=:contact.id];
        System.assertEquals(contact.STMStakeholderKey__c, key);
    }*/
}