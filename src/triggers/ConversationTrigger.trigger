trigger ConversationTrigger on sf4twitter__Twitter_Conversation__c(after update) {
    Map<string,id> maprecordtype=new map<string,id>();
    Map<Id,sf4twitter__Twitter_Conversation__c> mapconversation = new Map<Id,sf4twitter__Twitter_Conversation__c>();
    list<Case> cslist=new list<Case>();
        if(Trigger.IsAfter && Trigger.IsUpdate){
            list<RecordType> lstrecordtype=[select DeveloperName,Id,Name from RecordType where SobjectType='case'];
             for(RecordType RT:lstrecordtype)
                {
                maprecordtype.put(RT.DeveloperName,RT.id);
                }
             for(sf4twitter__Twitter_Conversation__c c:trigger.new){          
                if(c.sf4twitter__Case__c != null){
                  mapconversation.put(c.Id,c);
                }
                   
            }
          }
          system.debug('## mapconversation'+ mapconversation);
          for(sf4twitter__Twitter_Conversation__c c:mapconversation.values())
          {
              case cs=new case(id=c.sf4twitter__Case__c);
              cs.Country_code__c = c.Country_Code__c;
              cs.RecordTypeId=maprecordtype.get(Country_Code_Case_Type__c.getValues(c.Country_Code__c).Record_Type__c);
              cs.Reason = '';
              cslist.add(cs);
          }
              system.debug('#cslist' + cslist.size());
        if(!cslist.Isempty())
                  {
                     update cslist;
                 }
}