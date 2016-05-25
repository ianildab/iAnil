trigger STMAccountTrigger on Account (after insert, after update, before insert, before update) {
    List<Account> personAccounts = new List<Account>();
    for (Account a: Trigger.new) {
        if (a.IsPersonAccount) {
            personAccounts.add(a);
        }
    }

    // processing person accounts
    if (personAccounts.size() > 0) {
        STMContactTriggerHandler STMHandler = new STMContactTriggerHandler(Trigger.isExecuting);
        
        if(Trigger.isInsert && Trigger.isBefore){
            STMHandler.OnBeforeInsert(personAccounts);
        }else if(Trigger.isUpdate && Trigger.isBefore){
            STMHandler.OnBeforeUpdate(Trigger.old, personAccounts, Trigger.newMap);
        } else if (Trigger.isInsert && Trigger.isAfter) {
            STMHandler.OnAfterInsert(personAccounts);
        } else if (Trigger.isUpdate && Trigger.isAfter) {
            STMHandler.OnAfterUpdate(Trigger.old, personAccounts, Trigger.newMap);
        } 
    }
}