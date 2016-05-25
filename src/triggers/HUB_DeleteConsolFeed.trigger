trigger HUB_DeleteConsolFeed on HUB_Consolidated_Log__c (after insert) {

if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) { return; }
Public set<Id> st = new set<Id>();
if(!HUB_Validator_cls.hasAlreadyDone()){  

    //write your code here            
    
for(HUB_Consolidated_Log__c t :Trigger.new)
{
st.add(t.Id);
}
if(st.size()>0)
{
HUB_ConsolidatedLogHelper h = new HUB_ConsolidatedLogHelper();
HUB_ConsolidatedLogHelper.DeletefeedConsol(st);
}
HUB_Validator_cls.setAlreadyDone();
}
if(Trigger.isInsert)
{
    if(Trigger.isAfter)
    {
    HUBNotifyCaseTeam.notifyCaseTeamOnInsert(Trigger.new);
    }
}


}