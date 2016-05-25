public with sharing class HUB_CaseReportsController {
    public String userMarketFilter{get;set;} 
    public Date fromDate{get;set;}
    public Date toDate{get;set;}   
    public Integer totalLoginsAll{get;set;}
    public Integer totalUsersAll{get;set;}
    public Integer totalInActiveUsersAll{get;set;}
    public Integer totalActiveUsersAll{get;set;}
    public Set<Id> uniqueUsers{get;set;}
    public Set<Id> caseCreatedUsers{get;set;}
    public Set<Id> contributionToCaseUsers{get;set;}
   
    
    public Decimal percentageOfUsersWhoReadCases{get;set;}
    public Decimal percentageOfUsersWhoCreateCases{get;set;}
    public Decimal percentageOfUsersWhoContributeToCases{get;set;}
    public Decimal percentageOfUsersInactive{get;set;}
    public Decimal percentageOfUsersActive{get;set;}
    public List<Id> communityUsers{get;set;}
    public List<Id> consoleUsers{get;set;}
    public List<User> userDetailList{get;set;}
    public Map<Id,Integer> mapForTotalLogins{get;set;}
    public Map<Id,Integer> mapForCasesCreated{get;set;}
    public Map<Id,Integer> mapForContributionsToCases{get;set;}
    private String sortDirection = 'ASC';
    private String sortExp = 'name';
    public Boolean showUserDetail{get;set;}
    public HUB_CaseReportsController(ApexPages.StandardController controller) {
       uniqueUsers=new Set<Id>();
       caseCreatedUsers=new Set<Id>();
       contributionToCaseUsers=new Set<Id>();
       userDetailList=new List<User>();
       showUserDetail=false;
       mapForTotalLogins=new Map<Id,Integer>();
       mapForCasesCreated=new Map<Id,Integer>();
       mapForContributionsToCases=new Map<Id,Integer>();
    }
    public String sortExpression{
     get
     {
        return sortExp;
     }
     set
     {
       //if the column is clicked on then switch between Ascending and Descending modes
       if (value == sortExp)
         sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
       else
         sortDirection = 'ASC';
       sortExp = value;
     }
   }

     public String getSortDirection(){
            //if no column is selected 
            if (sortExpression == null || sortExpression == '')
              return 'ASC';
            else
             return sortDirection;
         }

     public void setSortDirection(String value){  
       sortDirection = value;
     }
  
   public List<User> getuserDetailList() {
       return userDetailList;
   }
    
    /*Getting the Hub Country(User Market) value from User Object.*/
    public List<SelectOption> getUserMarkets()
    {
      List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult=User.HUB_Country__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues(); 
       options.add(new SelectOption('','All'));
       for( Schema.PicklistEntry f : ple)
       {
          
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    } 
    
    /*Method call when Run Report Button is clicked*/
    public void showResults(){
     system.debug('date 111'+fromDate );
     system.debug('date 222'+toDate );
     Integer noOfDays;
     uniqueUsers.clear();
     userDetailList.clear();
     
     if(fromDate!=null && toDate!=null){
          noOfDays=fromDate.daysBetween(toDate);
          if(noOfDays<0){
             /*Error message if To Date is smaller than From Date*/
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'To Date cannot be smaller than From Date'));
            }
     }
     
     String query=null;
     String queryTotalLogins=null;
     String queryForTotalUsers=null;
     String queryFortotalInactiveUsers=null;
     String queryFortotalActiveUsers=null;
     
     query = 'select User__c from HUB_User_Login_History__c where Id !=null and User__r.HUB_Is_Hub_User__c=true' ; 
     queryTotalLogins= 'select User__c from HUB_User_Login_History__c where Id !=null and User__r.HUB_Is_Hub_User__c=true' ; 
     queryForTotalUsers='select Id,UserType from User where HUB_Is_Hub_User__c=true'; 
     queryFortotalInactiveUsers='select Id from User where  HUB_Is_Hub_User__c=true';
     queryFortotalActiveUsers='select Id,User__c from HUB_User_Login_History__c where User__r.isActive=true and User__r.HUB_Is_Hub_User__c=true';
     if(userMarketFilter!=null){
                            query+= ' and Hub_Market__c=:userMarketFilter ';
                            queryTotalLogins+= ' and User__r.HUB_Country__c=:userMarketFilter ';
                            queryForTotalUsers+= ' and HUB_Country__c  =:userMarketFilter ';
                            queryFortotalInactiveUsers+= ' and HUB_Country__c  =:userMarketFilter ';
                            queryFortotalActiveUsers+= ' and User__r.HUB_Country__c  =:userMarketFilter ';
                       } 
     if(fromDate!=null){
                            query+= ' and DAY_ONLY(createdDate)>=:fromDate ';
                            queryTotalLogins+= ' and DAY_ONLY(createdDate)>=:fromDate ';
                            queryFortotalActiveUsers+= '  and DAY_ONLY(createdDate)>=:fromDate ';
                           // queryFortotalInactiveUsers 
                       } 
     if(toDate!=null){
                            query+= ' and DAY_ONLY(createdDate)<=:toDate ';
                            queryTotalLogins+= ' and DAY_ONLY(createdDate)<=:toDate ';
                            queryFortotalActiveUsers+= ' and DAY_ONLY(createdDate)<=:toDate ';
                       } 
     
    /*Fetch The unique Users who had logged In as per filter criteria*/
     for(HUB_User_Login_History__c hist:  Database.query(query)){
           uniqueUsers.add(hist.User__c);
         }
         
     
     /*Sort Functionality --Generic expressio can be used for all fields*/
     string sortFullExp = sortExpression  + ' ' + sortDirection;
     if(uniqueUsers.size()>0){
     
         userDetailList=Database.query('Select id,Name,HUB_Country__c,LastLoginDate from User where id in:uniqueUsers and HUB_Is_Hub_User__c=true  order by ' + sortFullExp);
         for(Id usr: uniqueUsers){
            //Initial Map formation to avoid error. These values are overriden below if the Key Value is same.
            mapForTotalLogins.put(usr,0);
            mapForCasesCreated.put(usr,0);
            mapForContributionsToCases.put(usr,0);
         }
         
     }
     
     /******User Details based on Selected Market Only**/
     

     List<sObject> sobjList=new List<sObject>();
      sobjList= Database.query(queryTotalLogins);
      totalLoginsAll=0;
      if(sobjList.size()>0){
         totalLoginsAll=sobjList.size(); //Total Logins based on Filter
      }
      
       communityUsers=new List<Id>();   //Users who logged in Community 
       consoleUsers=new List<Id>();     // Users who logged in from not Community
     
      for(User usr: Database.query(queryForTotalUsers)){
         if(usr.UserType=='PowerPartner'){
               communityUsers.add(usr.id);
             }
             else{
               consoleUsers.add(usr.id);
             }
      }
      totalUsersAll=communityUsers.size()+ consoleUsers.size();  //Total Users- Combination of Community and non-Community Users
      system.debug(totalUsersAll+'totalUsersAll++++');
      
    
      
     
      
      
     /*Code to fetch Active Users based on selected Market*/ 
     List<HUB_User_Login_History__c> totalActiveUsersList=new List<HUB_User_Login_History__c>();
      
      set<Id> duplciate = new set<Id>();             
      for( HUB_User_Login_History__c obj: Database.query(queryFortotalActiveUsers)){
        if(duplciate.add(obj.User__c)){
                                totalActiveUsersList.add(obj);
                    }
      }            
      totalActiveUsersAll=0;
      percentageOfUsersActive=0;
      if(totalActiveUsersList.size()>0){
         totalActiveUsersAll=totalActiveUsersList.size();
         Decimal toRound=((Double)(totalActiveUsersAll*100)/totalUsersAll);
         percentageOfUsersActive=toRound.setScale(1, RoundingMode.HALF_EVEN);
      }
      
       /*Code to fetch Inactive Users based on selected Market*/
     /* List<User> totalInactiveUsersList=new List<User>();
      totalInactiveUsersList= Database.query(queryFortotalInactiveUsers);
      totalInActiveUsersAll=0;
      percentageOfUsersInactive=0;
      if(totalInactiveUsersList.size()>0){
         totalInActiveUsersAll=totalInactiveUsersList.size();
         Decimal toRound=((Double)(totalInActiveUsersAll *100)/totalUsersAll);
         percentageOfUsersInactive=toRound.setScale(1, RoundingMode.HALF_EVEN);
      }
      */
      
      totalInActiveUsersAll = totalUsersAll - totalActiveUsersAll;
      Decimal toRound1=((Double)(totalInActiveUsersAll *100)/totalUsersAll);
      percentageOfUsersInactive=toRound1.setScale(1, RoundingMode.HALF_EVEN);
      
      showUserDetail=true;
      
      /****************************************************/
       
    
        
        
      if(uniqueUsers.size()>0){
      system.debug('Unique Logged in User:'+uniqueUsers);
      system.debug('Unique Logged in User Size:'+uniqueUsers.size());
          
          caseCreatedUsers.clear();
          contributionToCaseUsers.clear();
          
         
          String queryCaseCreated=null;
          String queryCaseCreatedCount=null;
          String queryTotalLoginCount=null;
          String querycontributionToCase=null;
          String queryCaseContributionCount=null;
          
          //Id recordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Topic Tracker').getRecordTypeId();
          Map<String,Id> RecordtypeMap= new Map<String,Id>();
          //for(RecordType rt: [SELECT DeveloperName,Id FROM RecordType WHERE SObjectType='Case'])
          for(RecordType rt :  ECICCaseTriggerRegionCache.getRecordType(ECICCommonConstants.RECORDTYPE_BY_SOBJECT_TYPE,'Case').Values())
          {
              
              RecordtypeMap.put(rt.DeveloperName,rt.id);
          }
		  Id recordTypeId=RecordtypeMap.get('HUB_Issue_Tracker');
		  
          queryCaseCreated='select id,CreatedbyId,createdDate from Case where RecordTypeId=:recordTypeId and CreatedbyId IN:uniqueUsers';
          queryCaseCreatedCount='select count(Id),createdbyId  from case where createdbyId IN:uniqueUsers';
          queryTotalLoginCount='select count(User__c),CreatedbyId from HUB_User_Login_History__c where CreatedbyId in:uniqueUsers';
          queryCaseContributionCount='select count(Id),createdbyId from HUB_Consolidated_Log__c where createdbyId IN:uniqueUsers';
          querycontributionToCase='select id,CreatedbyId,createdDate from HUB_Consolidated_Log__c where Case__c!=null and CreatedbyId IN:uniqueUsers';
         
          if(userMarketFilter!=null){
                            
                            queryCaseCreated+= ' and HUB_Country__c=:userMarketFilter ';
                            queryCaseCreatedCount+= ' and HUB_Country__c=:userMarketFilter ';
                            queryCaseContributionCount+= ' and Case__r.HUB_Country__c=:userMarketFilter and  Createdby.HUB_Country__c=:userMarketFilter ';
                            queryTotalLoginCount+=' and Createdby.HUB_Country__c=:userMarketFilter';
                            querycontributionToCase+=' and Case__r.HUB_Country__c=:userMarketFilter and Createdby.HUB_Country__c=:userMarketFilter';
                            
                       } 
          if(fromDate!=null){
                            
                            queryCaseCreated+= ' and DAY_ONLY(createdDate)>=:fromDate ';
                            queryCaseCreatedCount+= ' and DAY_ONLY(createdDate)>=:fromDate';
                            queryCaseContributionCount+= ' and DAY_ONLY(createdDate)>=:fromDate';
                            queryTotalLoginCount+= ' and DAY_ONLY(createdDate)>=:fromDate';
                            querycontributionToCase+=' and DAY_ONLY(createdDate)>=:fromDate';
                            
                       } 
          if(toDate!=null){
                           
                            queryCaseCreated+=' and DAY_ONLY(createdDate)<=:toDate ';
                            queryCaseCreatedCount+= ' and DAY_ONLY(createdDate)<=:toDate';
                            queryCaseContributionCount+= ' and DAY_ONLY(createdDate)<=:toDate';
                            queryTotalLoginCount+=' and DAY_ONLY(createdDate)<=:toDate';
                            querycontributionToCase+=' and DAY_ONLY(createdDate)<=:toDate';
                           
                       } 
          queryCaseCreatedCount+= ' group by CreatedbyId ';     
          queryCaseContributionCount+= ' group by CreatedbyId ';  
          queryTotalLoginCount+= ' group by CreatedbyId ';            
         
         /*Code to fetch Users who contributed to Case*/
         for(HUB_Consolidated_Log__c log:  Database.query(querycontributionToCase)){
           system.debug('loglist values'+log);
           contributionToCaseUsers.add(log.CreatedbyId);
             
         }
         
         system.debug('Case contribution:'+contributionToCaseUsers);
         system.debug('Case contributionSize:'+contributionToCaseUsers.size());
         
         
         
         
         
         /* Code to Fetch Users who created Case*/
         for(Case cs:  Database.query(queryCaseCreated)){
           caseCreatedUsers.add(cs.CreatedbyId);
         }
         system.debug('Case creation:'+caseCreatedUsers);
         system.debug('Case creation Size:'+caseCreatedUsers.size());
         
         
         //Map formation to show Number of Logins For a particular User based on Filter Criteria
         for(AggregateResult ar: Database.query(queryTotalLoginCount)){
            mapForTotalLogins.put((Id)ar.get('CreatedbyId'),(Integer)ar.get('expr0'));
           
         }
         
         
         //Map formation to show Number of Cases Created by a particular User based on Filter Criteria
         for(AggregateResult ar: Database.query(queryCaseCreatedCount)){
            mapForCasesCreated.put((Id)ar.get('CreatedbyId'),(Integer)ar.get('expr0'));
            
         }
         
         
         //Map formation to show Number of Contributions to Case by a particular User based on Filter Criteria
         for(AggregateResult ar: Database.query(queryCaseContributionCount)){
            mapForContributionsToCases.put((Id)ar.get('CreatedbyId'),(Integer)ar.get('expr0'));
            
         } 
          
          
           if(caseCreatedUsers.size()==0){
              percentageOfUsersWhoCreateCases=0;
           }
           if(contributionToCaseUsers.size()==0){
              percentageOfUsersWhoContributeToCases=0;
           }
           
          
             doCalculations();
           
        }
        else{
            percentageOfUsersWhoReadCases=0;
            percentageOfUsersWhoCreateCases=0;
            percentageOfUsersWhoContributeToCases=0;
        }
        
    }
    
    public void doCalculations(){
    Integer caseReadCount=0;
    Integer caseCreatedCount=0;
    Integer caseContributionCount=0;
    percentageOfUsersWhoCreateCases=0.0;
    
       
       /*Calculation for Created Cases*/
       if(caseCreatedUsers.size()>0){
          caseCreatedCount=caseCreatedUsers.size();
          Decimal toround=(((Double)caseCreatedCount*100)/totalActiveUsersAll);
          percentageOfUsersWhoCreateCases=toRound.setScale(1, RoundingMode.HALF_EVEN);
       }

       if(uniqueUsers.size()>0 && caseCreatedUsers.size()>0){
          caseContributionCount=showContributionCount(caseCreatedUsers,uniqueUsers);
       }
       
       Decimal toround=(((Double)caseContributionCount*100)/totalActiveUsersAll);
       percentageOfUsersWhoContributeToCases=toRound.setScale(1, RoundingMode.HALF_EVEN);
       
       /*Calculation for Read Cases*/
       percentageOfUsersWhoReadCases=100-(percentageOfUsersWhoContributeToCases + percentageOfUsersWhoCreateCases);
       percentageOfUsersWhoReadCases = percentageOfUsersWhoReadCases.setScale(1, RoundingMode.HALF_EVEN);
       
    }
    
    public Integer showContributionCount(set<Id> caseCreatedUsers, set<Id> uniqueUsers){
          
          Set<Id> contributionToCaseUsers1 = new set<Id>();
          String queryCaseContributionCount=null;
          queryCaseContributionCount='select createdbyId from HUB_Consolidated_Log__c where createdbyId IN:uniqueUsers and createdbyId NOT IN:caseCreatedUsers and Createdby.HUB_Is_Hub_User__c = true';

          if(userMarketFilter!=null){
                            queryCaseContributionCount+= ' and Case__r.HUB_Country__c=:userMarketFilter and  Createdby.HUB_Country__c=:userMarketFilter ';
                       } 
          if(fromDate!=null){
                            queryCaseContributionCount+= ' and DAY_ONLY(createdDate)>=:fromDate';
                       } 
          if(toDate!=null){
                            queryCaseContributionCount+= ' and DAY_ONLY(createdDate)<=:toDate';
                       }    
          
          
          for(HUB_Consolidated_Log__c log:  Database.query(queryCaseContributionCount)){
           contributionToCaseUsers1.add(log.CreatedbyId);  
         }
        
        return contributionToCaseUsers1.size();
    }
    

   
}