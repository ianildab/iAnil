public with sharing class HUB_ContentController {
    public HUB_Contents__c  objContent {set;get;}
    public string recordId {get;set;}
    public String[] weeks = new String[]{};
    public String frequencyVisibility {get;set;}
    public Map<String,Integer> RecurrenceWeekMask{get;set;}
    public Map<String,String> RecurrenceInstanceMap{get;set;}
    public Boolean ShowDailyEvery {get;set;}
    public Boolean ShowMonthlyOnThe {get;set;}
    public Boolean ShowYearlyOnThe {get;set;}
    //property to set and get weekly options
    public String[] getWeeks() {
        return weeks;
    }
    public void setWeeks(String[] weeks) {
        this.weeks = weeks;
    }
    
    // standard controller
    public HUB_ContentController(ApexPages.StandardController controller) {
        recordId=apexpages.currentpage().getparameters().get('id');
        
        if(recordId != null){
            objContent = [select id, name, Title__c ,contentType__c,Date__c,Description__c, Repeat_Ends__c, Repeat__c , Repeat_Ends_After__c, Repeat_Ends_On__c, Repeat_RepeatEvery__c, 
                            Repeat_RepeatOnWeek__c, Repeat_Repeats__c, Source__c, Repeat_Starts_On__c,Repeat_byOnMonths__c, End_Date__c, URL__c,
                            dailyEveryNDays__c,Daily_Options__c,repeatEndDate__c, monthlyDays__c,monthlyEveryNMonths__c,monthlyEveryNMonths2__c,monthlyNthDay__c,
                            Monthly_Options__c,monthlyWeeks__c,repeatStartDate__c,weeklyEveryNWeeks__c,yearlyDay__c,yearlyMonth__c,yearlyMonth2__c,yearlyNthDay__c,yearlyNthDay2__c,
                            yearlyOptions__c,Frequency__c
                            from HUB_Contents__c  where id=: recordId];
            
            frequencyVisibility =   objContent.Frequency__c;   
            if(objContent.Repeat_RepeatOnWeek__c != null) {           
               weeks = objContent.Repeat_RepeatOnWeek__c.split(';');
            }
            if(objContent.Daily_Options__c == 'Every'){
                ShowDailyEvery = true;
            }
            if(objContent.Monthly_Options__c == 'On the'){
                ShowMonthlyOnThe = true;
            }
            if(objContent.yearlyOptions__c == 'On the'){
                ShowYearlyOnThe = true;
            }
                       
        }else{
            objContent  = new HUB_Contents__c ();
            frequencyVisibility = 'Daily';
            objContent.Daily_Options__c = 'Every Weekday';
            objContent.Monthly_Options__c = 'On day';
            objContent.yearlyOptions__c = 'On every';
            
            weeks.add(system.now().format('EEEE'));
        }
        RecurrenceWeekMask= new Map<String,Integer>(); 
        RecurrenceWeekMask.put('Sunday',1);
        RecurrenceWeekMask.put('Monday',2);
        RecurrenceWeekMask.put('Tuesday',4);
        RecurrenceWeekMask.put('Wednesday',8);
        RecurrenceWeekMask.put('Thursday',16);
        RecurrenceWeekMask.put('Friday',32);
        RecurrenceWeekMask.put('Saturday',64);
        RecurrenceWeekMask.put('day',127);
        
        RecurrenceInstanceMap=new Map<String,String>();
        RecurrenceInstanceMap.put('1st','First'); 
        RecurrenceInstanceMap.put('2nd','Second');
        RecurrenceInstanceMap.put('3rd','Third');
        RecurrenceInstanceMap.put('4th','Fourth');
        RecurrenceInstanceMap.put('last','last');
        
    }
        
        //Method to Get frequency of repeat contents 
        public List<SelectOption> getFrequency(){
                Schema.sObjectType sobject_type = HUB_Contents__c.getSObjectType();
                Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
                Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
                List<Schema.PicklistEntry> pick_list_values = field_map.get('Frequency__c').getDescribe().getPickListValues();
                List<selectOption> options = new List<selectOption>();
                for (Schema.PicklistEntry a : pick_list_values) {
                          options.add(new selectOption(a.getLabel(), a.getValue()));
                  }
                 return options;
         }
       
       // Method to get Daily options picklist values
       public List<SelectOption> getDailyOptions(){
    
            Schema.sObjectType sobject_type = HUB_Contents__c.getSObjectType();
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
            List<Schema.PicklistEntry> pick_list_values = field_map.get('Daily_Options__c').getDescribe().getPickListValues();
            List<selectOption> options = new List<selectOption>();
            for (Schema.PicklistEntry a : pick_list_values) {
                      options.add(new selectOption(a.getLabel(), a.getValue()));
              }
             return options;
       }
       
       // Method to get Monthly options picklist values
       public List<SelectOption> getMonthlyOptions(){
    
            Schema.sObjectType sobject_type = HUB_Contents__c.getSObjectType();
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
            List<Schema.PicklistEntry> pick_list_values = field_map.get('Monthly_Options__c').getDescribe().getPickListValues();
            List<selectOption> options = new List<selectOption>();
            for (Schema.PicklistEntry a : pick_list_values) {
                      options.add(new selectOption(a.getLabel(), a.getValue()));
              }
             return options;
       }
       
       // Method to get Monthly days picklist values
       public List<SelectOption> getMonthlyDays(){
    
            Schema.sObjectType sobject_type = HUB_Contents__c.getSObjectType();
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
            List<Schema.PicklistEntry> pick_list_values = field_map.get('monthlyDays__c').getDescribe().getPickListValues();
            List<selectOption> options = new List<selectOption>();
            for (Schema.PicklistEntry a : pick_list_values) {
                      options.add(new selectOption(a.getLabel(), a.getValue()));
              }
             return options;
       }
       
       // Method to get Monthly weeks picklist values
       public List<SelectOption> getMonthlyWeeks(){
    
            Schema.sObjectType sobject_type = HUB_Contents__c.getSObjectType();
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
            List<Schema.PicklistEntry> pick_list_values = field_map.get('monthlyWeeks__c').getDescribe().getPickListValues();
            List<selectOption> options = new List<selectOption>();
            for (Schema.PicklistEntry a : pick_list_values) {
                      options.add(new selectOption(a.getLabel(), a.getValue()));
              }
             return options;
       }
        // Method to get Yearly Options picklist values
         public List<SelectOption> getYearlyOptions(){
        
                Schema.sObjectType sobject_type = HUB_Contents__c.getSObjectType();
                Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
                Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
                List<Schema.PicklistEntry> pick_list_values = field_map.get('yearlyOptions__c').getDescribe().getPickListValues();
                List<selectOption> options = new List<selectOption>();
                for (Schema.PicklistEntry a : pick_list_values) {
                          options.add(new selectOption(a.getLabel(), a.getValue()));
                  }
                 return options;
           }
       
       
       public List<SelectOption> getMonthlyNthDay(){
    
            Schema.sObjectType sobject_type = HUB_Contents__c.getSObjectType();
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
            List<Schema.PicklistEntry> pick_list_values = field_map.get('monthlyNthDay__c').getDescribe().getPickListValues();
            List<selectOption> options = new List<selectOption>();
            for (Schema.PicklistEntry a : pick_list_values) {
                      options.add(new selectOption(a.getLabel(), a.getValue()));
              }
             return options;
       }
       
       // Method to get Yearly month picklist values
        public List<SelectOption> getYearlyMonth(){
    
            Schema.sObjectType sobject_type = HUB_Contents__c.getSObjectType();
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
            List<Schema.PicklistEntry> pick_list_values = field_map.get('yearlyMonth__c').getDescribe().getPickListValues();
            List<selectOption> options = new List<selectOption>();
            for (Schema.PicklistEntry a : pick_list_values) {
                      options.add(new selectOption(a.getLabel(), a.getValue()));
              }
             return options;
       }
       
       // Method to get Yearly day picklist values
       public List<SelectOption> getYearlyDay(){
    
            Schema.sObjectType sobject_type = HUB_Contents__c.getSObjectType();
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
            List<Schema.PicklistEntry> pick_list_values = field_map.get('yearlyDay__c').getDescribe().getPickListValues();
            List<selectOption> options = new List<selectOption>();
            for (Schema.PicklistEntry a : pick_list_values) {
                      options.add(new selectOption(a.getLabel(), a.getValue()));
              }
             return options;
       }
       
       // Method to get Yearly Nth day1 picklist values
       public List<SelectOption> getYearlyNthDay(){
    
            Schema.sObjectType sobject_type = HUB_Contents__c.getSObjectType();
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
            List<Schema.PicklistEntry> pick_list_values = field_map.get('yearlyNthDay__c').getDescribe().getPickListValues();
            List<selectOption> options = new List<selectOption>();
            for (Schema.PicklistEntry a : pick_list_values) {
                      options.add(new selectOption(a.getLabel(), a.getValue()));
              }
             return options;
       }
       
       // Method to get Yearly Nth day2 picklist values
       public List<SelectOption> getYearlyNthDay2(){
    
            Schema.sObjectType sobject_type = HUB_Contents__c.getSObjectType();
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
            List<Schema.PicklistEntry> pick_list_values = field_map.get('yearlyNthDay2__c').getDescribe().getPickListValues();
            List<selectOption> options = new List<selectOption>();
            for (Schema.PicklistEntry a : pick_list_values) {
                      options.add(new selectOption(a.getLabel(), a.getValue()));
              }
             return options;
       }
       
       // Method to get Yearly month2 picklist values
       public List<SelectOption> getYearlyMonth2(){
    
            Schema.sObjectType sobject_type = HUB_Contents__c.getSObjectType();
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
            List<Schema.PicklistEntry> pick_list_values = field_map.get('yearlyMonth2__c').getDescribe().getPickListValues();
            List<selectOption> options = new List<selectOption>();
            for (Schema.PicklistEntry a : pick_list_values) {
                      options.add(new selectOption(a.getLabel(), a.getValue()));
              }
             return options;
       }
       
    
    // Method to save content and createing events corresponding to the content 
    public Pagereference SaveMethod(){       
        Savepoint sp = Database.setSavepoint();
        try{
            String weeksSelected = '';
            Boolean Start = true;
            if(!weeks.isEmpty() && weeks != null) {           
                for(String Str : weeks) {
                    system.debug('inside for');
                    if(Start) {
                        system.debug('inside start');
                        weeksSelected = Str;
                        Start = false;
                    } else {               
                        weeksSelected = weeksSelected + ';' + Str;
                    }
                }
            }
            
            objContent.Repeat_RepeatOnWeek__c = weeksSelected;
            if(recordId != null){
                update objContent;
            }else{
                 insert objContent;
            }
            
            List<Event> lstEvents = [Select Id From Event where whatId = :objContent.Id];
            delete lstEvents;
            
            HUB_contentPublicCalendar__c pc= HUB_contentPublicCalendar__c.getValues('calendarId'); //public calendar ID from custom settings
            
            // Execute code for recurrence content/ events
            if(objContent.Repeat__c){
                /* Daily Recurrence */
                if(objContent.Frequency__c=='Daily'){
                      if(objContent.Daily_Options__c=='Every Weekday'){
                         Event evt = new Event();
                                evt.IsAllDayEvent = true;
                                evt.ActivityDate = objContent.Date__c;
                                evt.EndDateTime = objContent.Date__c;
                                evt.IsReminderSet = false;
                                evt.Subject = 'HubContentStart';
                                evt.WhatId = objContent.id;
                                evt.IsRecurrence = true;
                                evt.RecurrenceStartDateTime = objContent.repeatStartDate__c;
                                evt.RecurrenceEndDateOnly = objContent.repeatEndDate__c;
                                evt.RecurrenceDayOfWeekMask = 62;
                                evt.RecurrenceType = 'RecursEveryWeekday';
                                insert evt;
                        }
                      if(objContent.Daily_Options__c=='Every'){
                         Decimal xy=objContent.dailyEveryNDays__c;
                          Event evt = new Event();
                                evt.IsAllDayEvent = true;
                                evt.ActivityDate = Date.today();
                                evt.EndDateTime = Date.today();
                                evt.IsReminderSet = false;
                                evt.Subject = 'HubContentStart';
                                evt.WhatId = objContent.id;
                                evt.IsRecurrence = true;
                                evt.RecurrenceInterval =Integer.valueOf(objContent.dailyEveryNDays__c) ;
                                evt.RecurrenceStartDateTime = objContent.repeatStartDate__c;
                                evt.RecurrenceEndDateOnly = objContent.repeatEndDate__c;
                                evt.RecurrenceType = 'RecursDaily';
                       insert evt;
                      }
                }
                
                /* Weekly Recurrence */
                if(objContent.Frequency__c=='Weekly'){
                    Integer aggrWeekMask=0;
                    String[] weekDays= objContent.Repeat_RepeatOnWeek__c.split(';');
                    if(!weekDays.isEmpty() && weekDays!= null){
                     for(String Str : weekDays){
                       aggrWeekMask =aggrWeekMask + RecurrenceWeekMask.get(str);
                     }
                   } 
                  Event evt = new Event();
                        evt.IsAllDayEvent = true;
                        evt.ActivityDate = objContent.Date__c;
                        evt.EndDateTime =objContent.Date__c;
                        evt.IsReminderSet = false;
                        evt.Subject = 'HubContentStart';
                        evt.WhatId = objContent.id;
                        evt.IsRecurrence = true;
                        evt.RecurrenceInterval =Integer.valueOf(objContent.weeklyEveryNWeeks__c) ;
                        evt.RecurrenceDayOfWeekMask = aggrWeekMask ;
                        evt.RecurrenceStartDateTime = objContent.repeatStartDate__c;
                        evt.RecurrenceEndDateOnly = objContent.repeatEndDate__c;
                        evt.RecurrenceType = 'RecursWeekly';
                   insert evt;
                }
                
                /* Monthly Recurrence */
                if(objContent.Frequency__c=='Monthly'){
                    if(objContent.Monthly_Options__c=='On day'){
                      Event evt = new Event();
                            evt.IsAllDayEvent = true;
                            evt.ActivityDate = objContent.Date__c;
                            evt.EndDateTime = objContent.Date__c;
                            evt.IsReminderSet = false;
                            evt.Subject = 'HubContentStart';
                            evt.WhatId = objContent.id;
                            evt.IsRecurrence = true;
                            evt.RecurrenceDayOfMonth=Integer.valueOf(objContent.monthlyDays__c);
                            evt.RecurrenceInterval =Integer.valueOf(objContent.monthlyEveryNMonths__c) ;
                            evt.RecurrenceStartDateTime = objContent.repeatStartDate__c;
                            evt.RecurrenceEndDateOnly = objContent.repeatEndDate__c;
                            evt.RecurrenceType = 'RecursMonthly';
                       insert evt;
                     }
                  if(objContent.Monthly_Options__c=='On the'){
                      Event evt = new Event();
                            evt.IsAllDayEvent = true;
                            evt.ActivityDate = objContent.Date__c;
                            evt.EndDateTime = objContent.Date__c;
                            evt.IsReminderSet = false;
                            evt.Subject = 'HubContentStart';
                            evt.WhatId = objContent.id;
                            evt.IsRecurrence = true;
                            evt.RecurrenceInterval =Integer.valueOf(objContent.monthlyEveryNMonths__c) ;
                            evt.RecurrenceInstance =RecurrenceInstanceMap.get(objContent.monthlyNthDay__c);
                            evt.RecurrenceDayOfWeekMask=RecurrenceWeekMask.get(objContent.monthlyWeeks__c)==null? 0:RecurrenceWeekMask.get(objContent.monthlyWeeks__c);
                            evt.RecurrenceStartDateTime = objContent.repeatStartDate__c;
                            evt.RecurrenceEndDateOnly = objContent.repeatEndDate__c;
                            evt.RecurrenceType = 'RecursMonthlyNth';
                        insert evt;
                  }
                }
                
                 /* Yearly Recurrence */
                if(objContent.Frequency__c=='Yearly'){
                   if(objContent.yearlyOptions__c=='On every'){
                      Event evt = new Event();
                            evt.IsAllDayEvent = true;
                            evt.ActivityDate = objContent.Date__c;
                            evt.EndDateTime = objContent.Date__c;
                            evt.IsReminderSet = false;
                            evt.Subject = 'HubContentStart';
                            evt.WhatId = objContent.id;
                            evt.IsRecurrence = true;
                            evt.RecurrenceDayOfMonth =Integer.valueOf(objContent.yearlyDay__c);
                            evt.RecurrenceMonthOfYear=objContent.yearlyMonth__c;
                            evt.RecurrenceStartDateTime = objContent.repeatStartDate__c;
                            evt.RecurrenceEndDateOnly = objContent.repeatEndDate__c;
                            evt.RecurrenceType = 'RecursYearly';
                        insert evt;
                    }
                    if(objContent.yearlyOptions__c=='On the'){
                      Event evt = new Event();
                            evt.IsAllDayEvent = true;
                            evt.ActivityDate = objContent.Date__c;
                            evt.EndDateTime = objContent.Date__c;
                            evt.IsReminderSet = false;
                            evt.Subject = 'HubContentStart';
                            evt.WhatId = objContent.id;
                            evt.IsRecurrence = true;
                            evt.RecurrenceMonthOfYear=objContent.yearlyMonth2__c;
                            evt.RecurrenceInstance =RecurrenceInstanceMap.get(objContent.yearlyNthDay__c);
                            evt.RecurrenceDayOfWeekMask=RecurrenceWeekMask.get(objContent.yearlyNthDay2__c)==null? 0:RecurrenceWeekMask.get(objContent.yearlyNthDay2__c);
                            evt.RecurrenceStartDateTime = objContent.repeatStartDate__c;
                            evt.RecurrenceEndDateOnly = objContent.repeatEndDate__c;
                            evt.RecurrenceType = 'RecursYearlyNth';
                        insert evt;
                    } 
                }
                
                
                // Update all events end date to match with content end date
                /*
                    Updating an recurracne has following limitaion in Salesfroce :
                    IsRecurrence field is a read-only field when updating records, 
                    so we can’t update this field to ‘false’ while updating the records. 
                    If we are not set IsRecurrence field to false, record can’t  be saved as recurrence events won’t allow to span over 24 hours.
                */
                integer intDays = (objContent.Date__c).daysBetween(objContent.End_Date__c);
                system.debug(intDays+'days differnece ++ ');
                List<Event> lstEventsToUpdate = [Select Id,ActivityDate,EndDateTime From Event where whatId = :objContent.Id];
                List<Event> lstNewEventsToInsert = new list<Event>();
                set<Date> duplciateActivity = new set<Date>();
                
                for(Event objInsertedEvents : lstEventsToUpdate){
                    Event evt = new Event();
                    evt.ActivityDate = objInsertedEvents.ActivityDate;
                    evt.EndDateTime = (objInsertedEvents.ActivityDate).addDays(intDays);
                    evt.IsRecurrence = false;
                    evt.IsAllDayEvent = true;
                    evt.IsReminderSet = false;
                    evt.Subject = 'HubContentStart';
                    evt.WhatId = objContent.id;
                    evt.IsVisibleInSelfService = true;
                    evt.OwnerId = pc.Id__c;  //public calendar ID from custom settings
                    evt.RecordTypeId  = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Nexus Content Events').getRecordTypeId();
                    
                    // code to avoid duplicate Events
                    if(duplciateActivity.add(objInsertedEvents.ActivityDate)){
                                lstNewEventsToInsert.add(evt);
                    }
                }
                
                delete lstEventsToUpdate;   // deleting the recurrance event
                insert lstNewEventsToInsert; // inserting the events with updated end date and IsRecurrence = 'false'
            }
            // execute code for non recurrence Content /events
            else{
                 Event evt = new Event();
                 evt.IsAllDayEvent = true;
                 evt.ActivityDate = objContent.Date__c; // content Start date
                 evt.EndDateTime = objContent.End_Date__c;  // content end date
                 evt.IsReminderSet = false;
                 evt.Subject = 'HubContentStart';
                 evt.WhatId = objContent.id;
                 evt.IsRecurrence = false;
                 evt.IsVisibleInSelfService = true;
                 evt.OwnerId = pc.Id__c;  //public calendar ID from custom settings
                 evt.RecordTypeId  = Schema.SObjectType.Event.getRecordTypeInfosByName().get('Nexus Content Events').getRecordTypeId();
                 insert evt;
            }
            
            
            
            PageReference pageRef = Page.hub_ContentView;
            pageRef.setRedirect(true);
            pageRef.getParameters().put('id',objContent.Id);
            return pageRef;
        }catch(Exception ex){
            Database.rollback(sp);
            if(recordId == null){
                objContent.Id = null;
            }
            frequencyVisibility = objContent.Frequency__c;
            ApexPages.addMessages(ex);
            //objContent.('Must select at least one location : Country or Group or Division.');
            return null;
        }
        
    }
    
    //Method to get repeated weeks
    public List<SelectOption> getRepeatonweeks(){          
            Schema.sObjectType sobject_type = HUB_Contents__c.getSObjectType();
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
            List<Schema.PicklistEntry> pick_list_values = field_map.get('Repeat_RepeatOnWeek__c').getDescribe().getPickListValues();
            List<selectOption> options = new List<selectOption>();
            for (Schema.PicklistEntry a : pick_list_values) {
                      options.add(new selectOption(a.getLabel(),a.getValue()));
              }
             return options;
       }
}