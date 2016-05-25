public with sharing class HUB_SuggestedArtcleAreaController {
    
    public Case objCase {get;set;}
    public String collegeBestPracticeString {get;set;}
    public String collegeArtcileString {get;set;}
    public String collegeCasesString {get;set;}
    public string URLForPage {get;set;}
    public string searchString {get;set;}
    public string caseSubject {get;set;}
    public string caseDescription {get;set;}
    public boolean refreshPage {get;set;}
    public boolean maxLimitMsg {get;set;}
    public boolean ShowArticletable {get;set;}
    public boolean ShowBPtable {get;set;}
    public boolean ShowCasetable {get;set;}
    
    public String parentCaseId {get; set;}
    
    public List<suggestedArticleWraaper> articleList {get; set;}
    public List<suggestedBestPractice> bestpracticeList {get; set;}
    public List<suggestedCases> casesList {get; set;}
    
    
    public final static String hub_CaseRecordType = 'HUB_Issue_Tracker';
    
    public HUB_SuggestedArtcleAreaController(ApexPages.StandardController controller) {
        objCase = [Select id, Description, Subject, parentId from case WHERE id =: ApexPages.currentPage().getParameters().get('id')]; 
        caseSubject = objCase.Subject;
        parentCaseId = objCase.parentId;
        if(objCase.Description.length() > 254){
            caseDescription = objCase.Description.substring(0,254);
        }else{
            caseDescription = objCase.Description;
        }
        
        
        URLForPage = ApexPages.currentPage().getUrl();
        system.debug(controller.view().getUrl()+'URLForPage++');
        getBestPracticeAllreadyAttached();
        getArticlesAllreadyAttached();
        getCasesAllreadyAttached();
        getKnowledgeArticleVersion(searchString);
        getBestpractice(searchString);
        getCases(searchString);
    }

    // getting the list Suggested Articles
    public List<suggestedArticleWraaper> getKnowledgeArticleVersion(string searchString) {
        articleList = new List<suggestedArticleWraaper>();
        list<KnowledgeArticleVersion> lstArticle = new list<KnowledgeArticleVersion>();
        String publish = 'Online';
        string lang = 'en_US';
        List<HUB_Article_Types__c> ghubArticleTypes = HUB_Article_Types__c.getAll().values();
        List<String> ghubArticleTypesList = New List<String>();
        for(HUB_Article_Types__c article:ghubArticleTypes ){
            ghubArticleTypesList.add(article.Article_Name__c);
        }
      
        if(!String.isEmpty(searchString)){
            string searchValue = searchString+'*';
            string sosl = 'FIND :searchValue IN ALL FIELDS RETURNING KnowledgeArticleVersion (Id, title,KnowledgeArticleId where PublishStatus=:publish and Language =: lang AND ArticleType IN: ghubArticleTypesList) LIMIT 100';
            system.debug(sosl+'sosl++++--');
            List<List<KnowledgeArticleVersion>> searchList = search.query(sosl);
            lstArticle = ((List<KnowledgeArticleVersion>)searchList[0]);
            for(KnowledgeArticleVersion c: lstArticle) {
                articleList.add(new suggestedArticleWraaper(c));
            }
        }else{
            string casesubjectSearch = caseSubject+'*';
            string sosl = 'FIND :casesubjectSearch IN ALL FIELDS RETURNING KnowledgeArticleVersion (Id, title,KnowledgeArticleId where PublishStatus=:publish and Language =: lang AND ArticleType IN: ghubArticleTypesList) LIMIT 100';
            List<List<KnowledgeArticleVersion>> searchList = search.query(sosl);
            lstArticle = ((List<KnowledgeArticleVersion>)searchList[0]);
            for(KnowledgeArticleVersion c: lstArticle) {
                articleList.add(new suggestedArticleWraaper(c));
            }
        }
        if(articleList.size() > 99){
            maxLimitMsg =  true;
        }
        if(articleList.size() > 0 ){
            ShowArticletable = true;
        }else{
            ShowArticletable = false;
        }
        return articleList;
    }
    
    // getting the list Best Practices
    public List<suggestedBestPractice> getBestpractice(string searchString) {
        bestpracticeList = new List<suggestedBestPractice>();
        list<HUB_Best_Practices__c> lstBestpractice = new list<HUB_Best_Practices__c>();
        if(!String.isEmpty(searchString)){
            string soql = 'select id, Title__c,Description__c from HUB_Best_Practices__c where Title__c LIKE \'%' + String.escapeSingleQuotes(searchString) +'%\' or ShortDescription__c like \'%' + String.escapeSingleQuotes(searchString) +'%\' ORDER BY LastModifiedDate DESC LIMIT 100';
            lstBestpractice = Database.query(soql);
            for(HUB_Best_Practices__c c: lstBestpractice) {
                bestpracticeList.add(new suggestedBestPractice(c));
            }
        }else{
             //Code Changes from SOQL to SOSL, April 3rd 2015
            string casesubjectSearch = caseSubject.replace(' ', ' OR ');
            string sosl = 'FIND :casesubjectSearch IN ALL FIELDS RETURNING HUB_Best_Practices__c(id, Title__c,Description__c ORDER BY LastModifiedDate DESC) LIMIT 100';
            List<List<HUB_Best_Practices__c>> searchList = search.query(sosl);
            lstBestpractice =((List<HUB_Best_Practices__c>)searchList[0]);
            for(HUB_Best_Practices__c c: lstBestpractice) {
                bestpracticeList.add(new suggestedBestPractice(c));
            }
            /*
            //SOQL Code
            string soql = 'select id, Title__c,Description__c from HUB_Best_Practices__c where Title__c LIKE \'%' + String.escapeSingleQuotes(caseSubject) +'%\' or ShortDescription__c like \'%' + String.escapeSingleQuotes(caseDescription) +'%\' ORDER BY LastModifiedDate DESC LIMIT 100';
            for(HUB_Best_Practices__c c: Database.query(soql)) {
                bestpracticeList.add(new suggestedBestPractice(c));
            }*/
        }
        if(bestpracticeList.size() > 99){
            maxLimitMsg =  true;
        }
        if(bestpracticeList.size() > 0){
            ShowBPtable = true;
        }else{
            ShowBPtable = false;
        }   
        return bestpracticeList;
    }
    
    // getting the list cases
    public List<suggestedCases> getCases(string searchString) {
        list<case> lstCase = new list<case>();
        string recordtype = ECICCaseTriggerRegionCache.getRecordType(ECICCommonConstants.CASE_RECORDTYPE_BY_DEVELOPERNAME,hub_CaseRecordType).Values()[0].Id;
        //[Select Id From RecordType WHERE SobjectType='case' and DeveloperName = :hub_CaseRecordType][0].Id;
        casesList = new List<suggestedCases>();
        String parentIdWhereClause = parentCaseId != null ?  'AND Id <> \''+ parentCaseId +'\'': '';
        if(!String.isEmpty(searchString)){
            string soql = 'select id,CaseNumber, Subject from case where (Subject LIKE \'%' + String.escapeSingleQuotes(searchString) +'%\' or HUB_DescriptionSearch__c LIKE \'%' + String.escapeSingleQuotes(searchString) + '%\') and RecordTypeId =:recordtype '+String.escapeSingleQuotes(parentIdWhereClause) + ' ORDER BY LastModifiedDate DESC LIMIT 100';
            lstCase = Database.query(soql);
            for(case c: lstCase) {
                if(c.Id != objCase.Id){
                    casesList.add(new suggestedCases(c));
                }
            }
        }else{
            //Code Changes from SOQL to SOSL. : April 3rd 2015
            string casesubjectSearch = caseSubject.replace(' ', ' OR ');
            string sosl = 'FIND :casesubjectSearch IN ALL FIELDS RETURNING Case(id,CaseNumber, Subject where RecordTypeId =:recordtype '+String.escapeSingleQuotes(parentIdWhereClause)+' ORDER BY LastModifiedDate DESC) LIMIT 100';
            List<List<case>> searchList = search.query(sosl);
            lstCase =((List<Case>)searchList[0]);
            for(Case c: lstCase) {
                if(c.Id != objCase.Id){
                    casesList.add(new suggestedCases(c));
                }
            }
            
            /* 
            //SOQL Code
            string soql = 'select id,CaseNumber, Subject from case where (Subject LIKE \'%' + String.escapeSingleQuotes(caseSubject) +'%\' or HUB_DescriptionSearch__c LIKE \'%' + String.escapeSingleQuotes(caseDescription) + '%\') and RecordTypeId =:recordtype ORDER BY LastModifiedDate DESC LIMIT 100';
            for(case c:  Database.query(soql)) {
                if(c.Id != objCase.Id){
                    casesList.add(new suggestedCases(c));
                }
            }*/
           
        }
        if(casesList.size() > 99){
            maxLimitMsg =  true;
        }
        if(casesList.size() > 0){
            ShowCasetable = true;
        }else{
            ShowCasetable = false;
        }   
        return casesList;
    }
    
    
    
        
    //method to attach to a article
    public PageReference attachArticle() {
        List<KnowledgeArticleVersion> knwArticle= new List<KnowledgeArticleVersion>();
        for(suggestedArticleWraaper cCon: articleList) {
          if(cCon.selected == true) {
                knwArticle.add(cCon.con);
            }
        }
        
        if(knwArticle.size() < 1){
            refreshPage =  false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please select at least one Article to proceed');
            ApexPages.addMessage(myMsg);    
        }else{
            List<CaseArticle> knwArticleToInsert= new List<CaseArticle>();
            for(KnowledgeArticleVersion Ka: knwArticle) {
                CaseArticle ca = new CaseArticle();
                ca.KnowledgeArticleId = Ka.KnowledgeArticleId;
                ca.caseid=objCase.id;
                knwArticleToInsert.add(ca);
                
            }
            refreshPage =  true;
            upsert knwArticleToInsert;
        }
        
        return null;
    }
    
    //method to attach to best practice
    public PageReference attachBP() {
        List<HUB_Best_Practices__c> bp= new List<HUB_Best_Practices__c>();
        for(suggestedBestPractice cCon: bestpracticeList) {
          if(cCon.selected == true) {
                bp.add(cCon.con);
            }
        }
        
        if(bp.size() < 1){
            refreshPage =  false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please select at least one Best Practice to proceed');
            ApexPages.addMessage(myMsg);
            
        }else{
            List<HUB_Case_Best_Practice_Association__c> bpToInsert= new List<HUB_Case_Best_Practice_Association__c>();
            for(HUB_Best_Practices__c objBP: bp) {
                HUB_Case_Best_Practice_Association__c objBPCase = new HUB_Case_Best_Practice_Association__c();
                objBPCase.Case_BestPractice__c=objCase.id;
                objBPCase.Best_Practices_Cases__c = objBP.Id;
                bpToInsert.add(objBPCase);
                
            }
            refreshPage =  true;
            upsert bpToInsert;
        } 
        
        return null;
    }
    
    //method to attach to case
    public PageReference attachCase() {
        List<case> lstCase= new List<case>();
        for(suggestedCases cCon: casesList) {
          if(cCon.selected == true) {
                lstCase.add(cCon.con);
            }
        }
        if(lstCase.size() < 1){
            refreshPage =  false;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Please select at least one Case to proceed');
            ApexPages.addMessage(myMsg);    
        }else{
            List<case> caseToinsert= new List<case>();
            for(case obj: lstCase) {
                obj.ParentId = objCase.Id;
                caseToinsert.add(obj);
            }
            refreshPage =  true;
            update caseToinsert;
        }
        
        return null;
    }
    
    
    // method to get the Best practices already attached
    public String getBestPracticeAllreadyAttached(){
        collegeBestPracticeString = '';
        list<HUB_Case_Best_Practice_Association__c> lstBP = [SELECT Id,Best_Practices_Cases__c,Case_BestPractice__c FROM 
                                HUB_Case_Best_Practice_Association__c where Case_BestPractice__c =:objCase.Id];

        if(lstBP.size() > 0){
            for(HUB_Case_Best_Practice_Association__c obj : lstBP){
                collegeBestPracticeString += (collegeBestPracticeString==''?'':',')+obj.Best_Practices_Cases__c;
            }
        }
        return collegeBestPracticeString;
    }
    
    // method to get Artciles already attached
    public String getArticlesAllreadyAttached(){
        collegeArtcileString = '';
        list<CaseArticle> lstArticle = [SELECT Id,CaseId,KnowledgeArticleId FROM 
                                CaseArticle where CaseId =:objCase.Id];
        
        if(lstArticle.size() > 0){
            for(CaseArticle obj : lstArticle){
                collegeArtcileString += (collegeArtcileString==''?'':',')+obj.KnowledgeArticleId;
            }
        }
        return collegeArtcileString;
    }
    
    // method to get cases already attached
    public String getCasesAllreadyAttached(){ 
        list<case> lstCase = [SELECT Id FROM 
                                case where ParentId =:objCase.Id];
        
        if(lstCase.size() > 0){
            for(case obj : lstCase){
                collegeCasesString += (collegeCasesString==''?'':',')+obj.Id;
            }
        }
        return collegeCasesString;
    }
    
    public void SearchContents(){
        maxLimitMsg = false;
        if(!String.isEmpty(searchString)){
            try{
                if(searchString.length() > 1){
                getBestpractice(searchString);
                getCases(searchString);
                getKnowledgeArticleVersion(searchString);
                }else{
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Your search term must have 2 or more characters');
                    ApexPages.addMessage(myMsg);
                }
            }catch (exception e){
 
            }
        }
    }
    
    
    
    public class suggestedArticleWraaper {
        public KnowledgeArticleVersion con {get; set;}
        public Boolean selected {get; set;}

        public suggestedArticleWraaper(KnowledgeArticleVersion c) {
            con = c;
            selected = false;
        }

    }
    
    public class suggestedBestPractice {
        public HUB_Best_Practices__c con {get; set;}
        public Boolean selected {get; set;}
        
        public suggestedBestPractice(HUB_Best_Practices__c c) {
            con = c;
            selected = false;
        }

    }
    
     public class suggestedCases {
        public case con {get; set;}
        public Boolean selected {get; set;}

        public suggestedCases(case c) {
            con = c;
            selected = false;
        }

    }
    
   public void createUser() {
   List<User> userList=[select FirstName,LastName,Username,HUB_Country__c,LastLoginDate from User where id=:UserInfo.getUserId()];
  
   List<HUB_Profiles__c> profileList = HUB_Profiles__c.getAll().values();
   List<String> hubProfiles=new List<String>();
   for(HUB_Profiles__c pf : profileList ){
            hubProfiles.add(pf.Profile_Name__c);
   }
   
  //Integer totalUsers=[Select count() from user where isActive=true and Profile.Name like 'Hub%' ];
   Integer totalUsers=[Select count() from user where isActive=true and Profile.Name In: hubProfiles];
   dateTime lastLoggedIn = userList[0].LastLoginDate;
   system.debug('Totalo'+totalUsers);
   //Integer totalUsersInMarket=[Select count() from user where isActive=true and HUB_Country__c=:userList[0].HUB_Country__c  and (Profile.Name like 'Hub%' or usertype = 'PowerPartner')];
   Integer totalUsersInMarket=[Select count() from user where isActive=true and HUB_Country__c=:userList[0].HUB_Country__c  and Profile.Name In: hubProfiles];
   system.debug('Marketo'+totalUsersInMarket);
   List<HUB_User_Login_History__c> toInsert=new List<HUB_User_Login_History__c>();
   List<HUB_User_Login_History__c> userHistory=[select First_Name__c,Last_Name__c,Username__c,Hub_Market__c from HUB_User_Login_History__c where CreatedById=:UserInfo.getUserId() and Last_Logged_in_Time__c =:lastLoggedIn];
   if(userHistory.size()==0){
        for(User us: userList){
           HUB_User_Login_History__c hist=new HUB_User_Login_History__c();
           hist.First_Name__c=us.FirstName;
           hist.Last_Name__c=us.LastName;
           hist.Username__c=us.Username;
           hist.User__c=UserInfo.getUserId();
           hist.Total_Active_Users__c=totalUsers;
           hist.Total_Active_Users_in_Market__c=totalUsersInMarket;
           hist.Hub_Market__c=us.HUB_Country__c;
           hist.Session_ID__c=UserInfo.getSessionId();
           hist.Last_Logged_in_Time__c = us.LastLoginDate;
           toInsert.add(hist);
        }
   }
   else{
       toInsert.clear();
   }
    system.debug('toInsert User Login'+toInsert);
    if(toInsert.size()>0){
      insert toInsert;
    }
    
    }
   
    
    
}