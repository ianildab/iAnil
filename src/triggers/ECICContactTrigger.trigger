trigger ECICContactTrigger on Contact (before insert, before update, after insert, after update ) 
{
	if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) { return; }
	SEPTriggerHandlerInvoker.invoke(new ECICContactTriggerHandler(Trigger.isExecuting));
	}