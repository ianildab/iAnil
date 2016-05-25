public with sharing class STMAddStakeholdersController {
 private final String CURRENT_ISSUE_ID = ApexPages.currentPage().getParameters().get('Id');
private static String soql = 'SELECT id,firstname, lastname, account.name, Name, IsPersonAccount, account.IsPersonAccount FROM contact WHERE account.name != null'
                        + ' AND IsPersonAccount = false AND STMActive__c = true AND Id NOT IN (SELECT Contact__c FROM STMIssueScore__c WHERE Issue__c =:CURRENT_ISSUE_ID AND Contact__c != null)';
    
    public String searchSoql;
    public String currentIssueId {get;set;}
    public Integer size{get{
                        if (size == null) {
                            size = 10;
                        }
                        return size;
                        }set;}
    public Integer noOfRecords{get; set;}
    public List<Contact> contacts {
        get {
           contacts = (List<contact>) contactSet.getRecords();
           return contacts; 
        }
        set;
    }
    

    public ApexPages.StandardSetController contactSet {
          
        get {
            if(contactSet == null) {
                System.debug(loggingLevel.INFO, 'INFO: contactSet == null');
                size = 10;
                contactSet = new ApexPages.StandardSetController(Database.getQueryLocator(soql));
                contactSet.setPageSize(size);
                noOfRecords = contactSet.getResultSize();
            }
            return contactSet;
        }
        set;
    }
    
    public PageReference runSearch() {
          String firstName = Apexpages.currentPage().getParameters().get('firstname');
          String lastName = Apexpages.currentPage().getParameters().get('lastname');
          String accountName = Apexpages.currentPage().getParameters().get('accountName'); 
        searchSoql = 'SELECT id, firstname, lastname, account.name, IsPersonAccount, account.IsPersonAccount, Name FROM Contact' +
        ' WHERE account.name != null AND STMActive__c = true  AND Id NOT IN (SELECT Contact__c FROM STMIssueScore__c WHERE Issue__c =:CURRENT_ISSUE_ID AND Contact__c != null)';
        if (!String.isEmpty(firstName))
            searchSoql += ' AND firstname LIKE \''+String.escapeSingleQuotes(firstName)+'%\'';
        if (!String.isEmpty(lastName))
            searchSoql += ' AND lastname LIKE \''+String.escapeSingleQuotes(lastName)+'%\'';
        if (!String.isEmpty(accountName))
            searchSoql += ' AND account.name LIKE \''+String.escapeSingleQuotes(accountName)+'%\'';
            
            search();
            return null;
    
    }
    
    public void search() {
        contactSet = new ApexPages.StandardSetController(Database.getQueryLocator(searchSoql));
        noOfRecords = contactSet.getResultSize();
        contactSet.setPageSize(size);
    }

    @RemoteAction
    public static void addStakeholders(String contactIds, String issueId ) {
        List<String> ids = contactIds.split(':',-1);
        System.debug( Logginglevel.INFO , 'ids == ' + ids );
        List<Contact> contactToUpdate = [SELECT id FROM Contact WHERE id IN:ids];
        System.debug( Logginglevel.INFO , 'contactToUpdate == ' + contactToUpdate );
        STMStakeholderHelper.insertIssueScores(contactToUpdate, issueId);
    }

    public Boolean hasNext {
        get {
            return contactSet.getHasNext();
        }
        set;
    }
    
    public Boolean hasPrevious {
        get {
            return contactSet.getHasPrevious();
        }
        set;
    }
 
    public Integer pageNumber {
        get {
            return contactSet.getPageNumber();
        }
        set;
    }
 
    public void first() {
        contactSet.first();
    }
 
    public void last() {
        contactSet.last();
    }
 
    public void previous() {
        contactSet.previous();
    }
 
    public void next() {
        contactSet.next();
    }
    
}