public with sharing class STMStakeholderMappingController {
    private static String currentIssueId;
    
    public static String currentIssueName{get;set;}
    public Map<String, List<Id>> shkhldrsByScores;
    public List<Contact> stakeholdersWithSameScore{get;set;}
    public List<STMIssueScore__c> IssueScores;
    public Boolean multiStkhListViewWasActivated{get;set;}
  
    public STMStakeholderMappingController(ApexPages.StandardController controller) {

        List<id> tmpIds = new List<Id>();
        String tmpKey = '';
        
        
        currentIssueId = (String)controller.getId();
        currentIssueName = (String)(((STMIssue__c)(controller.getRecord())).Name); 
        
        IssueScores = [SELECT Id,
                              Contact__c,
                              Contact__r.Name,
                              Account__c,
                              Account__r.Name,
                              AttitudeScore__c,
                              InfluenceScore__c
                      FROM STMIssueScore__c
                      WHERE Issue__c =:currentIssueId];
        
        Map<String, List<Id>> tmpShkhldrsByScores = new Map<String, List<Id>>(); 
        
        for (STMIssueScore__c issueScore:issueScores) {
            
            tmpKey = String.valueOf(issueScore.AttitudeScore__c) + String.valueOf(issueScore.InfluenceScore__c);
            tmpKey = STMStakeholderHelper.scoreNormalizer(tmpKey);
            System.debug('map tmpKey after normalization on apex:' + tmpKey);
            if (tmpShkhldrsByScores.containsKey(tmpKey)) {
                tmpIds = tmpShkhldrsByScores.get(tmpKey);
                tmpIds.add(issueScore.Contact__c);
                System.debug('tmpIds ==' + tmpIds);
                tmpShkhldrsByScores.put(tmpKey, tmpIds);
            } else {
                tmpIds = new List<Id>();
                tmpIds.add(issueScore.Contact__c);
                System.debug('tmpIds ==' + tmpIds);
                tmpShkhldrsByScores.put(tmpKey, tmpIds);
            }       
        }

        shkhldrsByScores = tmpShkhldrsByScores; 
        
    } 
 
    public void disbleMultiStkhListViewWasActivated() {
            multiStkhListViewWasActivated = false;
    }
    
    @RemoteAction
    public static STM2Stakeholder[] loadStakeholdersByIssue(String issueId,
                                                            String amountOfDisplayesIssues,
                                                            String minInfluenceScore,
                                                            String mimAttitudeScore) {
        if (issueId != null && issueId != '') {
            if (currentIssueId != null && currentIssueId  != '') {
                issueId = currentIssueId; 
            }
            List<Account> businessAccounts = new List<Account>();
            List<STMIssueScore__c> IssueScores = new List<STMIssueScore__c>();
            List<STM2Stakeholder> result = new List<STM2Stakeholder>();
            List<Id> selectedAccounts = new List<Id>();
            List<Id> relatedToIssueScoreContacts = new List<Id>();
            
            String soql = 'SELECT Id,Contact__c,Contact__r.Name,Account__c,Account__r.Name,AttitudeScore__c,InfluenceScore__c' +
             ' FROM STMIssueScore__c WHERE Issue__c =:issueId';
            if (minInfluenceScore != '' && minInfluenceScore != null && decimal.valueOf(minInfluenceScore) <= 5.0 && decimal.valueOf(minInfluenceScore) >= 1.0) 
                soql += ' AND InfluenceScore__c >= ' + minInfluenceScore;
            if (mimAttitudeScore != '' && mimAttitudeScore != null && decimal.valueOf(mimAttitudeScore) <= 5.0 && decimal.valueOf(mimAttitudeScore) >= 1.0) 
                soql += ' AND AttitudeScore__c >= ' + mimAttitudeScore;
         /*   if (position != '' & position != null) 
                soql += ' AND Position__c = ' + position;*/
            if (amountOfDisplayesIssues != '' & amountOfDisplayesIssues != null)  
                soql += ' LIMIT '+amountOfDisplayesIssues;
            
            IssueScores = Database.query(soql);
            
            for (STMIssueScore__c issueScore:issueScores) {
                if ( issueScore.Account__c != null ) {
                    selectedAccounts.add(issueScore.Account__c);
                }
                if ( issueScore.contact__c != null ) {
                    relatedToIssueScoreContacts.add( issueScore.contact__c );
                }

            }
          
            for (STMIssueScore__c issueScore: IssueScores ) {
                    result.add(new STM2Stakeholder(issueScore));
            }
            return result;
        } else {
            return null; 
        }
    }
    
    public PageReference showStakeholdersWithSameScore() {
        multiStkhListViewWasActivated = true;
        String score ='';
        score += Apexpages.currentPage().getParameters().get('score');
        score = STMStakeholderHelper.scoreNormalizer(score);
        System.debug( Logginglevel.INFO , 'map key after normalization on JS' + score );
        System.debug('shkhldrsByScores'+shkhldrsByScores);
        
        
        for (String key: shkhldrsByScores.keySet()) {
            System.debug( Logginglevel.INFO , key+ ':' + shkhldrsByScores.get(key));
        }
        
        
        System.debug(shkhldrsByScores.get(score));
        if (shkhldrsByScores.get(score) != null && shkhldrsByScores.get(score).size() > 0 ) {
            stakeholdersWithSameScore = [SELECT Id, firstName, lastName
                                     FROM Contact WHERE Id in:shkhldrsByScores.get(score)];
        }
        System.debug(stakeholdersWithSameScore);
        return null;
    }
       
    public class STM2Stakeholder{
        public Decimal influenceScore;
        public Decimal attitudeScore;
        public String accountName;
        public String Id;
        public Boolean hasSomeStakeholders;
        
        public STM2Stakeholder(Decimal influenceScore,
                Decimal attitudeScore,
                String accountName,
                String Id) {
            this.influenceScore    = influenceScore;
            this.attitudeScore     = attitudeScore;
            this.accountName       = accountName;
            this.Id                = Id;
        }
        
        public STM2Stakeholder(STMIssueScore__c issueScore) {
            if (issueScore.Account__c != null) {
                this.accountName    = issueScore.Account__r.Name;
                this.Id             = issueScore.Account__c;
            } else {
                this.accountName   = issueScore.Contact__r.Name;
                this.Id            = issueScore.Contact__c;
            }
            this.influenceScore = issueScore.InfluenceScore__c;
            this.attitudeScore  = issueScore.AttitudeScore__c;
            

/*            String tmpKey = String.valueOf(issueScore.AttitudeScore__c) + String.valueOf(issueScore.InfluenceScore__c);
            tmpKey = STMStakeholderHelper.scoreNormalizer(tmpKey);  
            this.hasSomeStakeholders = ((shkhldrsByScores.get(tmpKey)).size() > 1 );*/
        }
    }
}