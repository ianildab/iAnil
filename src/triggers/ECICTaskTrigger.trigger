/**
*    ECIC-77 - ECIC-T327 scope:
*    2. (OPTIONAL): 
*    2a. Create Trigger on Tasks that updates Case Record with count of not completed tasks 
*/
trigger ECICTaskTrigger on Task ( before insert, before update, after insert, after update, after delete) {
	if(trigger.isBefore)
    {
        if(trigger.isInsert)
        {
            ECICUpdateProductTaskAssignee.changeBottlerExternalRelations(Trigger.new);
        }
    }
	if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) {
		return;
	}
	
	SEPTriggerHandlerInvoker.invoke(new ECICTaskTriggerHandler(Trigger.isExecuting));
}