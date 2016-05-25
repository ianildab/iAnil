public class ECICCompetitorProductTriggerHandler extends SEPTriggerHandlerAbstract
{
    public ECICCompetitorProductTriggerHandler(boolean isTriggerExecuting) { super(isTriggerExecuting); }

    public override void onBeforeInsert(List<sObject> newValueSObjectList) 
    {
        processBefore((Competitor_Product__c[])newValueSObjectList);
    }

    public override void onBeforeUpdate(List<sObject> oldValueSObjectList, List<sObject> newValueSObjectList, Map<Id, sObject> oldValueSObjectByIdMap, Map<Id, sObject> newValueSObjectByIdMap) 
    {
        processBefore((Competitor_Product__c[])newValueSObjectList);
    }
    
    @testVisible private static void processBefore(List<Competitor_Product__c> newCompetitorProductList)
    {
		for (Competitor_Product__c product : newCompetitorProductList)                   
		{
		        String ownerID          = product.OwnerId;
		        product.Owner_Lookup__c = ownerID.startsWith('005') ? product.OwnerId : null;
        }
        
        //Country Code calculation (?)
    }
}