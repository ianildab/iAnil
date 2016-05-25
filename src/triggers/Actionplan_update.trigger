trigger Actionplan_update on Action_Plan__c (before insert,before update ) {
    list<Action_plan__c> apList=[select Country_Code__c,Rank__c from Action_plan__c ];
    Map<string,list<Decimal>> mapcheck=new map<string,list<Decimal> >();
    for(Action_plan__c ap:apList){
        if(mapcheck.containsKey(ap.Country_Code__c)) {
            List<Decimal> rank = mapcheck.get(ap.Country_Code__c);
            rank.add(ap.Rank__c);
            mapcheck.put(ap.Country_Code__c,rank); 
        } else {
            mapcheck.put(ap.Country_Code__c,new List<Decimal>{ ap.Rank__c});
        }
            
    }
    system.debug('mapcheck'+mapcheck);
    if(Trigger.isBefore && Trigger.isInsert ){
      for(Action_Plan__c APC : trigger.new)
      {
          APC.Unique_Name__c=APC.Country_Code__c+'_'+APC.name;
          
           system.debug('oooooo88888888'+mapcheck.get(APC.Country_Code__c));
            list<Decimal> Rank=mapcheck.get(APC.Country_Code__c);
             system.debug('ooooooooooooo'+Rank);
              system.debug('APC.Rank__c'+APC.Rank__c);
			  if(Rank!=null){
                  for(decimal decrank:Rank)
                 {if(APC.Rank__c==decrank)
                 APC.addError(System.Label.Action_Plan_trigger_Error);
					}
				 }
       /*   APC.name=APC.name+'('+ APC.Rank__c+')';
          boolean check= Action_plan_handler.validate(APC);
          if(check)
          {
            APC.addError('Rank already given to some other Action Plan');
          }
         
         list<Decimal> Rank=mapcheck.get(APC.Country_Code__c);
         
         if(Rank.contains(APC.Rank__c))
         {
         APC.addError('Rank already given to some other Action Plan');
         }
          */
      }
  }  
    if(Trigger.isBefore && Trigger.isUpdate){
        for(Action_Plan__c APC : Trigger.new){
             APC.Unique_Name__c=APC.Country_Code__c+'_'+APC.name;
            Action_Plan__c beforeUpdate_action_plan = System.Trigger.oldMap.get( APC.Id);
            if(beforeUpdate_action_plan.Country_Code__c!=APC.Country_Code__c || beforeUpdate_action_plan.Rank__c!=APC.Rank__c){
             /*  boolean check= Action_plan_handler.validate(APC);
                  if(check)
                  {
                    APC.addError('Rank already given to some other Action Plan');
                  }
             */
                system.debug('oooooo88888888'+mapcheck.get(APC.Country_Code__c));
            list<Decimal> Rank=mapcheck.get(APC.Country_Code__c);
             system.debug('ooooooooooooo'+Rank);
              system.debug('APC.Rank__c'+APC.Rank__c);
				 if(Rank!=null){
                  for(decimal decrank:Rank)
                 {if(APC.Rank__c==decrank)
                 APC.addError(System.Label.Action_Plan_trigger_Error);
                  }
				 }
             
            }
        }      
    }
}