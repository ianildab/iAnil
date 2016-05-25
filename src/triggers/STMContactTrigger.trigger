trigger STMContactTrigger on Contact (after insert, after update, before insert, before update) {
    STMContactTriggerHandler STMHandler = new STMContactTriggerHandler(Trigger.isExecuting);
    
    if(Trigger.isInsert && Trigger.isBefore){
        STMHandler.OnBeforeInsert(Trigger.new);
    }else if(Trigger.isUpdate && Trigger.isBefore){
        STMHandler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    } else if (Trigger.isInsert && Trigger.isAfter) {
        STMHandler.OnAfterInsert(Trigger.new);
    } else if (Trigger.isUpdate && Trigger.isAfter) {
        STMHandler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    }    
}