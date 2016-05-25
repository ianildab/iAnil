public class ECICActionPlanHelper {
    @testVisible private static final String DELIMITER = ';';
    private static final String TASK_EMAIL_TEMPLATE_ID = General_Settings__c.getInstance().Task_Notification_Template_ID__c;
    private static Messaging.SingleEmailMessage mail;

    public static final String KEY = 'Key';
    public static final String CONDITIONAL = 'Conditional';
    public static final String OPTIONAL = 'Optional';
    public static final String DISPOSABLE = 'Disposable';
    public static final String QUALS = 'equals';
    public static final String NOT_QUALS = 'not equals';    
    public static boolean AP_CREATION_HASRUN = false;
    public static boolean APT_CREATION_HASRUN = false;
    
    public static boolean needsAp (Case c) {
        return (c.Status != 'New') && (c.Status != 'Closed') && (c.Status != 'Cancelled');  // returns true unless Status is "New", "Closed", or "Cancelled"
    } 
    
    /**
     *    Check if new plan needs to be assigned
     */
    public static boolean needChangeAp(Case currentCase, Case oldCase) 
    {
        // when to check if new plan needs to be assigned
        return      (oldCase != null)                                                       // return TRUE if there WAS an old Case
                 && (oldCase.Action_Plan__c != null)                                        //          AND the old Case HAD an Action Plan
                 && (                                                                       //          AND the value of
                            (oldCase.Origin != currentCase.Origin)                          //                          Origin
                         || (oldCase.reason != currentCase.reason)                          //                      OR  Reason
                         || (oldCase.category_level3__c != currentCase.category_level3__c)  //                      OR  Cat Level 3
                         || (oldCase.category_level4__c != currentCase.category_level4__c)  //                      OR  Cat Level 4
                    );                                                                      //              .... has changed.
    }
    
    /**
     *    Check if it is the first assignment of an action plan
     */
    public static boolean firstAp(Case currentCase, Case oldCase)       //  currentCase value never used!?!  
    {
        return (
                       (oldCase == null)                                // return TRUE if old case didn't exist,
                    || (oldCase.status == 'New')                        //             OR old case had a new status,
                    || (oldCase.Action_Plan__c == null)                 //             OR old case doesn't have an action plan.
                ); 
    }
    
    /**
     *    This is a shortcut. This leaves "old" action plan in place if valid, even if a higher ranking AP is available
     */
    public static boolean isApValid(Case c) {
        Action_Plan__c ap = ECICActionPlanCache.getInstance().getActionPlanById(c.Action_Plan__c );
        if (ap == null) 
        {
            System.debug (Logginglevel.INFO, '**** No Action Plan retrieved: Returning FALSE');
            return false;           // No further testing required if Case has no Action Plan, which is effectively NOT VALID.
        }
        
        boolean apCaseChannelIsEmpty                   = ECICUtils.isEmpty(ap.Case_Channel__c);
        boolean apCaseChannelIsNotEmpty                = !apCaseChannelIsEmpty;
        boolean caseOriginIsEmpty                      = ECICUtils.isEmpty(c.origin);
        boolean caseOriginIsNotEmpty                   = !caseOriginIsEmpty;
        boolean bothChannelsEmpty                      = apCaseChannelIsEmpty && caseOriginIsEmpty;
        boolean apCaseChannelContainsCaseOrigin        = caseOriginIsNotEmpty && apCaseChannelIsNotEmpty && caseOriginIsNotEmpty && ((ap.Case_Channel__c + ';').contains(c.origin + ';'));
        boolean apCaseChannelDoesNotContainCaseOrigin  = !apCaseChannelContainsCaseOrigin;
        
        boolean apCaseReasonIsEmpty                    = ECICUtils.isEmpty(ap.Case_Reason__c);
        boolean apCaseReasonIsNotEmpty                 = !apCaseReasonIsEmpty;
        boolean caseReasonIsEmpty                      = ECICUtils.isEmpty(c.reason); 
        boolean caseReasonIsNotEmpty                   = !caseReasonIsEmpty;
        boolean bothReasonsEmpty                       = apCaseReasonIsEmpty && caseReasonIsEmpty;
        boolean apCaseReasonContainsCaseReason         = apCaseReasonIsNotEmpty && caseReasonIsNotEmpty && ((ap.Case_Reason__c+';').contains(c.reason+';'));

        boolean apCaseCategoryLevel3IsEmpty            = ECICUtils.isEmpty(ap.Category_Level3__c);
        boolean apCaseCategoryLevel3IsNotEmpty         = !apCaseCategoryLevel3IsEmpty;
        boolean caseCategoryLevel3IsEmpty              = ECICUtils.isEmpty(c.Category_Level3__c);
        boolean caseCategoryLevel3IsNotEmpty           = !caseCategoryLevel3IsEmpty;
        boolean bothCategoryLevel3Empty                = apCaseCategoryLevel3IsEmpty && caseCategoryLevel3IsEmpty;
        boolean apCaseCL3ContainsCaseCL3               = caseCategoryLevel3IsNotEmpty && apCaseCategoryLevel3IsNotEmpty && ((ap.Category_Level3__c+';').contains(c.Category_Level3__c+';'));

        boolean apCaseCategoryLevel4IsEmpty            = ECICUtils.isEmpty(ap.Category_Level4__c);
        boolean apCaseCategoryLevel4IsNotEmpty         = !apCaseCategoryLevel4IsEmpty;
        boolean caseCategoryLevel4IsEmpty              = ECICUtils.isEmpty(c.Category_Level4__c);
        boolean caseCategoryLevel4IsNotEmpty           = !caseCategoryLevel4IsEmpty;
        boolean bothCategoryLevel4Empty                = apCaseCategoryLevel4IsEmpty && caseCategoryLevel4IsEmpty;
        boolean apCaseCL4ContainsCaseCL4               = caseCategoryLevel4IsNotEmpty && apCaseCategoryLevel4IsNotEmpty && ((ap.Category_Level4__c+';').contains(c.Category_Level4__c+';'));

        
        if (  apCaseChannelIsNotEmpty && apCaseChannelDoesNotContainCaseOrigin ) 
        { 
            return false; 
        }
        else if ( apCaseChannelContainsCaseOrigin && apCaseReasonIsEmpty && apCaseCategoryLevel3IsEmpty && apCaseCategoryLevel4IsEmpty) 
        { 
            return true; // only channel was filled for Action Plan, and (as per above conditional) it matches 
        }  

        // no need to check categorization above, as we dont care about cat level dependency
        else if ( apCaseChannelContainsCaseOrigin && (  apCaseReasonContainsCaseReason  || apCaseCL3ContainsCaseCL3 || apCaseCL4ContainsCaseCL4 )) 
        { 
            return true; 
        }
        
        return false; // Default, if none of the above true conditions are met.
    }
    
    /**
     *    Compares case's data with AP matching options and returns the ID of first AP that satisfies them
     */
    public static ID getActionPlanID (Case c) {
        List<String> keys = ECICUtils.createCategoryKeys(c);
        return ECICActionPlanCache.getInstance().getActionPlanID(keys);
    }
    
    /**
     *    Create case task for key, conditional, optional action plan items
     */
    public static List<Task> fireAllAPTasksCreation(Case c) {
        List<Action_Plan_Item__c> items = ECICActionPlanCache.getInstance().getActionPlanItems(c.Action_plan__c);
        system.debug(c.Action_plan__c);
        system.debug(items);
        
        if (items == null || items.isEmpty()) {
            return null;
        }
        
        return fireAPTasksCreation(c, items);
    }
    
    /**
     *    Create case task for optional action plan items
     */
    public static List<Task> fireAPTasksCreation(Case targetCase) {
        List<Action_Plan_Item__c> actionPlanItemList = ECICActionPlanCache.getInstance().getActionPlanItems(targetCase.Action_plan__c);
        if (actionPlanItemList == null || actionPlanItemList.isEmpty()) { return null; }
        
        Map<ID, Task> excludedTaskIdMap = new Map<ID, Task>();
        for (Task t : [select ID, Template_Id__c, isModified__c from Task where WhatID = :targetCase.id]) 
        {
            excludedTaskIdMap.put(t.Template_Id__c, t);
        }
        
        List<Action_Plan_Item__c> includedActionPlanItemList = new List<Action_Plan_Item__c>();
        List<Task> invalidTaskList = new List<Task>();
        for (Action_Plan_Item__c actionPlanItem : actionPlanItemList ) 
        {
            ID actionPlanItemId = actionPlanItem.ID;
            if (!excludedTaskIdMap.containsKey(actionPlanItemId)) 
            {
                if (actionPlanItem.Mode__c == OPTIONAL || actionPlanItem.Mode__c == DISPOSABLE) 
                {
                    includedActionPlanItemList.add(actionPlanItem);
                }
            }
            else if (actionPlanItem.Mode__c == DISPOSABLE) 
            {
                Task targetTask = excludedTaskIdMap.get(actionPlanItem.id);
                boolean isModified = boolean.valueOf(targetTask.isModified__c);
                if (!isModified  && !checkTaskConditions(targetCase, actionPlanItem)) 
                {
                    invalidTaskList.add(targetTask);
        }
            }
        }
        
        if (!invalidTaskList.isEmpty()) 
        {
            delete invalidTaskList;
        }
        
        return fireAPTasksCreation(targetCase, includedActionPlanItemList);
    }
    
    /**
     *    Create case tasks for specified set of action plan items
     */
    public static List<Task> fireAPTasksCreation(Case targetCase, List<Action_Plan_Item__c>  actionPlanItemList) 
    {
        List<Task> taskList = new List<Task>();
        for (Action_Plan_Item__c actionPlanItem : actionPlanItemList) 
        {
            Task targetTask = null;
            if (
                    (actionPlanItem.Mode__c == KEY)
                        ||
                    (
                        ((new Set<String>{CONDITIONAL, OPTIONAL, DISPOSABLE}).contains(actionPlanItem.Mode__c))
                            &&
                        (checkTaskConditions(targetCase, actionPlanItem))       
                    )
               ) 
            {
                targetTask = addTaskByTemplate(targetCase, actionPlanItem);
            }
            if (targetTask != null) { taskList.add(targetTask); }
        }
        
        return taskList;
    }
    
    /**
     *    Calculate count of AP tasks that should be added to inserted case with attached AP
     */
    public static Integer evaluateAPTasksCount(Case c) {
        List<Action_Plan_Item__c> items = ECICActionPlanCache.getInstance().getActionPlanItems(c.Action_plan__c);
        
        if (items == null || items.isEmpty()) {
            return 0;
        }
        
        Integer count = 0;
        String pendingTaskOwner;
        
        for (Action_Plan_Item__c item : items) {
            if (item.Mode__c == KEY) {
                count ++;
                if (pendingTaskOwner == null) {
                    pendingTaskOwner = resolveOwnerId(c, item);
                }
            }
            else if (item.Mode__c == CONDITIONAL || item.Mode__c == OPTIONAL || item.Mode__c == DISPOSABLE) {
                if (checkTaskConditions(c, item)) {
                count ++;
                if (pendingTaskOwner == null) {
                    pendingTaskOwner = resolveOwnerId(c, item);
                }
            }
            }
        }
        
        //define Responsible of the pending task
        if (!items.isEmpty()) {
            c.Next_Open_Task_Reponsible_Lookup__c = pendingTaskOwner ;    
        }
        
        return count;
    }
    
    public static Task addTaskByTemplate(Case c, Action_Plan_Item__c item) {
        String taskOwnerId = resolveOwnerId(c, item) ;
        
        if (taskOwnerId == null) {
            system.debug('Task owner ID is undefinied :' + c + '\n' + item);
            return null;    
        }
        
        Task t = new Task();
        t.Priority = (item.Priority__c == null) ? 'Normal' : item.Priority__c;
        t.Subject = item.Name;
        t.WhatId = c.ID;
        t.Status = 'Not started';
        t.OwnerId = taskOwnerId ;//if task owner is undefined, use case owner
        t.ActivityDate = item.ActivityDate__c;
        t.Template_Id__c = item.id;
        t.Description = item.Description__c;
        t.Task_Number__c = item.Task_Number__c;
        t.International_name__c = item.International_name__c;
        t.Send_Notification_Email__c = item.Send_Notification_Email__c;
        t.IsVisibleInSelfService = True;
        return t;
    }
    
    public static String resolveOwnerId (Case c, Action_Plan_Item__c item) {
        String taskOwnerId = null;
        
        try {
            taskOwnerId = (String) c.get(item.Assignee__c);
        }
        catch (System.SObjectException ex) {
            if (ex.getMessage().contains('Invalid field')) {
                c.addError('In Action Plan \'' + item.Action_Plan__r.Name + '\', task \'' + item.Name +
                        '\', non-existing field \'' + item.Assignee__c + '\' is referenced.');
            }
        }
        
        return (taskOwnerId == null) ? c.OwnerId : taskOwnerId;
    }
    
    public static boolean checkTaskConditions(Case targetCase, Action_Plan_Item__c actionPlanItem) 
    {
        List<AP_Task_Condition__c> apTaskConditionList = ECICActionPlanCache.getInstance().getConditions(actionPlanItem.id);
        
        boolean isMatched = !apTaskConditionList.isEmpty();
        for (AP_Task_Condition__c apCondition : apTaskConditionList) 
        {
            isMatched &= checkTaskCondition(isMatched, targetCase, actionPlanItem, apCondition);
            if (!isMatched) { return false; }
        }
        
        return isMatched;
    }
    
    @testVisible private static Boolean checkTaskCondition(Boolean isMatched, Case targetCase, Action_Plan_Item__c actionPlanItem, AP_Task_Condition__c apCondition)
    {
        String apConditionString = null;
        try { apConditionString = String.valueOf(targetCase.get(apCondition.Field_Name__c)); }
        catch (System.SObjectException ex) 
        {
            if (ex.getMessage().contains('Invalid field')) 
            {                
                targetCase.addError( 'In Action Plan \'' + actionPlanItem.Action_Plan__r.Name + '\', task \'' + actionPlanItem.Name + '\', non-existing field \'' + apCondition.Field_Name__c + '\' is referenced.' );
            }
            return false;
        }
        
        isMatched &=  (ECICUtils.isEmpty(apCondition.Values__c))
                        ?  ((ECICUtils.isEmpty(apConditionString)) ? (apCondition.Operator__c == QUALS) : (apCondition.Operator__c == NOT_QUALS))
                        :  checkTaskCondition(apCondition, apConditionString);  

        return isMatched;
    }

    @testVisible private static Boolean checkTaskCondition(AP_Task_Condition__c apCondition, String apConditionString)
    {
        String[] valueArray = apCondition.Values__c.split(DELIMITER);   // Multiple allowed values are separated by semicolon
        return (apCondition.Operator__c == QUALS)
                        ? checkTaskConditionEquals (valueArray, apConditionString)
                        : (
                            (apCondition.Operator__c == NOT_QUALS)
                                ?   checkTaskConditionNotEquals (valueArray, apConditionString)
                                :   false
                            ); 
    }
    
    @testVisible private static Boolean checkTaskConditionEquals (String[] valueArray, String apConditionString)
    {
        if (valueArray.isEmpty()) { return ((apConditionString == '') || (apConditionString == null)); }  // Original code would have simply returned false, regardless; but this makes more sense.
        for (String value : valueArray ) 
        {
            value             = value.trim();
            Boolean isMatched = (apConditionString == value);
            if (isMatched) { return true; } 
        }
        return false;
    }
    
    @testVisible private static Boolean checkTaskConditionNotEquals (String[] valueArray, String apConditionString)
    {
        if (valueArray.isEmpty()) 
        {
            Boolean apConditionStringNull        = (apConditionString == null);
            Boolean apConditionStringEmpty       = (apConditionString == '');
            Boolean apConditionStringNullOrEmpty = apConditionStringNull || apConditionStringEmpty;
            return (!apConditionStringNullOrEmpty); 
        }  // Original code would have simply returned false, regardless; but this makes more sense.
        Boolean isNotMatched = true;
        for (String value : valueArray) 
        {
            value = value.trim();
            isNotMatched &= (apConditionString != value);
        }
        return isNotMatched;
    }
    
    
    /**
     *    Removed unclosed, non-manual tasks. Modified or manual taks are to be kept
     */
    public static void fireActionPlanRemoved(Case c) {
        delete [select ID from task where whatId = :c.id and Template_id__c != null and isModified__c = 'false'];
    }
    
    /**
     *    Assign matched Action Plan to current case
     */
    public static List<Task> process(Case c, Case old) {
        //define matched AP
        if (needsAp(c))  {
            if (firstAp(c, old)) {
                c.Action_plan__c = getActionPlanID(c);
                
                if (c.Action_plan__c != null) {
                    if(c.id != null) {
                        return  fireAllAPTasksCreation(c);
                    }
                }
            }
            else if (needChangeAp(c, old)) {
                if (!isApValid(c)) {
                    fireActionPlanRemoved(c);
                    c.Action_plan__c = getActionPlanID(c);
                    
                    if (c.Action_plan__c != null) {
                        return fireAllAPTasksCreation(c);
                    }
                }                    
            }           
            else  if(old == NULL || old.status != 'Closed'){
                return fireAPTasksCreation(c);
            }
        }
        
        return null;
    }
    
    public static void process(List<Case> newCases, Map<Id, Case> oldMap) {
        if (AP_CREATION_HASRUN) {//this is used to avoid execution after workflow have run
            return ;
        }
        
        List<Task> allTasks = new List<Task>();
        //TODO: for loop remove
        for (Case c : newCases) {
            //Case old = Trigger.isInsert ? null : oldMap.get(c.ID);
            Case old = (oldMap == null) ? null : oldMap.get(c.ID);
            
            //run AP linking for inserted/updated cases and AP task creation only for updated case(skip inserted because there is no case id in trigger.isBefore) 
            List<Task> tasks = process(c, old);
            //if (Trigger.isUpdate && tasks!= null && !tasks.isEmpty()) {
            if (old != null && tasks!= null && !tasks.isEmpty()) {
                allTasks.addAll(tasks);
                //define Responsible of the pending task
                c.Next_Open_Task_Reponsible_Lookup__c = tasks[0].OwnerId;
            }
        }
        
        if (!allTasks.isEmpty()) {
            try{
                insert allTasks;
                sendNotificationEmail(allTasks);
            }catch(DMLException ex){
                for (Case c : newCases) { 
                    if (ex.getMessage().contains('id value of incorrect type: 00G')) {
                        c.addError('The queue can be Owner of Case only when status is New.');
                    }else{
                        c.addError(ex);
                    }
                }
            }
        }

        AP_CREATION_HASRUN = true;
    }
    
    /**
     *    Run Case Tasks creation if Action Plan is defined for the first time on just inserted Case
     */
    public static List<Task> processAPTasksOnCaseInsert(Case c, Case old) {
        if (c.Action_plan__c != null && firstAp(c, old) ) {
            return fireAllAPTasksCreation(c);
        }
        
        return null;
    }
    
    public static void processAPTasksOnCaseInsert(List<Case> newCases) {
        if (APT_CREATION_HASRUN ) {
            return ;
        }
        
        List<Task> allTasks = new List<Task>();
        
        for (Case c : newcases) {//do this way because there is no id for just inserted case in Trigger.isBefore, so we link tasks to cases in Trigger.isAfter
            List<Task> tasks = processAPTasksOnCaseInsert(c, null);
            if (tasks!= null && !tasks.isEmpty()) {
                allTasks.addAll(tasks);
            }
        }
        
        if (!allTasks.isEmpty()) {
            insert allTasks;
            sendNotificationEmail(allTasks);
        }
        
        APT_CREATION_HASRUN = true;
    }
    
    /** ECIC-2476 
     * Sending email notification to task's owner in a case when Action Plan item for this task has a Send_Notification_Email__c == true
     * 
     * We can't to add an email alert to task's workflow and can't to use next scenario:
     *      1. trigger copies field to task (activity) from AP item
     *      2. WF reads tasks field and send email elert
     *  It's a system limitation.
     * */
    private static void sendNotificationEmail(List<Task> allTasks){

        for(Task t: allTasks){
            if(t.Send_Notification_Email__c  && ((String)(t.OwnerId)).startsWith('005') ){
                Messaging.reserveSingleEmailCapacity(1);
                mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(t.OwnerID);
                mail.saveAsActivity = false;
                mail.setTemplateID(TASK_EMAIL_TEMPLATE_ID);
                mail.setWhatID(t.Id);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
    }
}