trigger ECICAccountTrigger on Account (before insert, before update, after insert, after update) 
{
	if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) { return; }
	SEPTriggerHandlerInvoker.invoke(new ECICAccountTriggerHandler(Trigger.isExecuting));
}