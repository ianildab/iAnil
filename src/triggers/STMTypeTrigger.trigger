trigger STMTypeTrigger on STMG_Type__c (before insert, before update, after insert, after update, before delete) {
    STMTypeTriggerHandler STMHandler = new STMTypeTriggerHandler(Trigger.isExecuting);
    
    if(Trigger.isInsert && Trigger.isBefore){
        STMHandler.OnBeforeInsert(Trigger.new);
    }else if(Trigger.isUpdate && Trigger.isBefore){
        STMHandler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
    } else if (Trigger.isInsert && Trigger.isAfter) {
        STMHandler.OnAfterInsert(Trigger.new);
    } else if (Trigger.isUpdate && Trigger.isAfter) {
        STMHandler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
    } else if (Trigger.isDelete && Trigger.isBefore) {
        STMHandler.onAfterDelete(Trigger.old, Trigger.oldMap);
    }
}