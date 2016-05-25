public with sharing class STMIssueEvolutionMapController {
    private static String currentIssueScoreId;
    public List<STMIssueScoreHistory__c> IssueScoreHistories;
    public Date currentDate;
    public Date dateFrameEnd;
    
    
    public STMIssueEvolutionMapController(ApexPages.StandardController controller) {
        currentIssueScoreId = (String)controller.getId();
        
        IssueScoreHistories = [SELECT Id,
                                      AttitudeScore__c,
                                      InfluenceScore__c,
                                      IssueScore__c,
                                      LastIssueScoreModification__c
                      FROM STMIssueScoreHistory__c
                      WHERE IssueScore__c =:currentIssueScoreId];
    } 
    
    @RemoteAction
    public static IssueScoreHistory[] loadIssueScoreHistories(String issueScoreId) {
        if (issueScoreId != null && issueScoreId != '') {
            if (currentIssueScoreId != null && currentIssueScoreId  != '') {
                issueScoreId = currentIssueScoreId; 
            }
            List<Account> businessAccounts = new List<Account>();
            List<STMIssueScoreHistory__c> IssueScoreHistories = new List<STMIssueScoreHistory__c>();
            List<IssueScoreHistory> result = new List<IssueScoreHistory>();
            
            String soql = 'SELECT Id, AttitudeScore__c, InfluenceScore__c, IssueScore__c, LastIssueScoreModification__c' +
                          ' FROM STMIssueScoreHistory__c WHERE IssueScore__c =:issueScoreId';
            IssueScoreHistories = Database.query(soql);
          
            for (STMIssueScoreHistory__c issueScoreHistory: IssueScoreHistories ) {
                result.add(new IssueScoreHistory(issueScoreHistory));
            }
            return result;
        } else {
            return null; 
        }
    }
    
    public class IssueScoreHistory {
        public Decimal influenceScore;
        public Decimal attitudeScore;
        public DateTime LastIssueScoreModification;
        
        public IssueScoreHistory(STMIssueScoreHistory__c issueScoreHistory) {
            this.influenceScore = IssueScoreHistory.InfluenceScore__c;
            this.attitudeScore = IssueScoreHistory.AttitudeScore__c;
            this.LastIssueScoreModification = IssueScoreHistory.LastIssueScoreModification__c;
        }
    }
    
}