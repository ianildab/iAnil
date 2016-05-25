Global class HUB_Batch_Article_Notification implements Database.Batchable<sObject>,Database.Stateful

{
    Map<Id, List<HUB_Approved_External_Messaging__kav>> userArticleMap {get; set;}
    List<HUB_Approved_External_Messaging__kav> pastDueArticles {get; set;}
    
    global HUB_Batch_Article_Notification()
    {
        //Map to maintain user id and their articles
        userArticleMap = new Map<Id, List<HUB_Approved_External_Messaging__kav>>();
    
        //All Users of the Issue Tracker
        List<User> issueTracker = new List<User>();
        issueTracker = [SELECT id, name, email FROM User WHERE UserRole.Name = 'Issue Tracker Analyst'];
    
        //All User Ids of Issue Tracker
        List<Id> issueTrackerIds = new List<Id>();
        for(User usr : issueTracker)
        {
            issueTrackerIds.add(usr.Id);
        }
        
        //All articles past due
        pastDueArticles = new list <HUB_Approved_External_Messaging__kav>();
        if (!Test.isRunningTest()) {
        pastDueArticles = [SELECT Title, KnowledgeArticleId, OwnerId FROM HUB_Approved_External_Messaging__kav
                            WHERE PublishStatus = 'Online' AND Language = 'en_US' AND LastPublishedDate = LAST_MONTH]; 
        }
        else{
            pastDueArticles = [SELECT Title, KnowledgeArticleId, OwnerId FROM HUB_Approved_External_Messaging__kav
                            WHERE PublishStatus = 'Online' AND Language = 'en_US' ]; 
        }     
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //Create map of issue tracker Ids and their articles
        for(HUB_Approved_External_Messaging__kav ka : pastDueArticles)
        {
            if(userArticleMap.containskey(ka.OwnerId))
            {
                //Get list of articles and add the new articles
                List<HUB_Approved_External_Messaging__kav> tempList = userArticleMap.get(ka.OwnerId);
                //Add refreshed article in map
                userArticleMap.put(ka.OwnerId, tempList);
            }
            else
            {
                //Create list of articles
                userArticleMap.put(ka.OwnerId, new List<HUB_Approved_External_Messaging__kav>{ka});
            }
        }
        //batch on all issue tracker users
        String query = 'SELECT id, name, email FROM User WHERE UserRole.Name = \'Issue Tracker Analyst\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext BC, List<sObject> scope)
    {
        for(sObject s :scope)
        {
            //Type cast sObject in user Object
            User usr = (User)s;
            
            //If any Articles are past due (currently set to yesterday, prod will be every 6 months) then email will be sent
            if(userArticleMap.containsKey(usr.Id))
            {
                //Fetching all articles past due by user
                List<HUB_Approved_External_Messaging__kav> allArticleOfUser = userArticleMap.get(usr.Id);
                
                String body = ' ';
                //Creating tables for articles
                body = BodyFormat(allArticleOfUser);
                
                //Sending mail
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                //Set user email in mail to address
                String [] toAddresses = new String[] {usr.email};
                
                //Assign Addresses
                mail.setToAddresses(toAddresses);
                
                //Assign Email Subject
                mail.setSubject('Attention Articles are past due');
                
                //Body of email
                mail.setHtmlBody('Hello ' + usr.Name + ', Following are the articles that have not been touched in the last 6 months: ' +
                body + ' Thank you'); 
                
                //Sending Email
               if (!Test.isRunningTest()) {    
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
               } 
            }
        }
    }
    
    public String BodyFormat (List<HUB_Approved_External_Messaging__kav> lst)
    {
        String str = ' ';
        for (HUB_Approved_External_Messaging__kav k : lst)
        {
            str += '<tr><td>' + k.Title + '</td>'+'<td>'+ k.KnowledgeArticleId + '</td>'+'</tr>';
        }   
        str = str.replace('null', '');
        String finalStr = ' ';
        finalStr = '<table border ="1"> <td> Title </td> <td> KnowledgeArticleId </td>' + str + '</table>';
        return finalStr;
    }
    global void finish(Database.BatchableContext BC)
    {
   // Get the ID of the AsyncApexJob representing this batch job   
   // from Database.BatchableContext.   
   // Query the AsyncApexJob object to retrieve the current job's information.
   AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                   TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
   // Send an email to the Apex job's submitter notifying of job completion.
   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   String[] toAddresses = new String[] {a.CreatedBy.Email};
   mail.setToAddresses(toAddresses);
   mail.setSubject('Apex Sharing Recalculation ' + a.Status);
   mail.setPlainTextBody
   ('The batch Apex job processed ' + a.TotalJobItems +
   ' batches with '+ a.NumberOfErrors + ' failures.');
   if (!Test.isRunningTest()) {    
   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }   
    }
}