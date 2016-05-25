public class ECICPromotionTriggerHandler extends SEPTriggerHandlerAbstract
{
    public ECICPromotionTriggerHandler(boolean isTriggerExecuting) { super(isTriggerExecuting); }

    public override void onBeforeInsert(List<sObject> newValueSObjectList) 
    {
        processBefore((List<Promotion__c>)newValueSObjectList);
    }

    public override void onBeforeUpdate(List<sObject> oldValueSObjectList, List<sObject> newValueSObjectList, Map<Id, sObject> oldValueSObjectByIdMap, Map<Id, sObject> newValueSObjectByIdMap) 
    {
        processBefore((List<Promotion__c>)newValueSObjectList);
    }
    
    @testVisible private static void processBefore(List<Promotion__c> newPromotionList)
    {
	    Set<Id> ownerUserIdSet = getBlankCountryOwnerUserIdSet(newPromotionList);
	    if (! ownerUserIdSet.isEmpty()) { setCountryCodes(newPromotionList, ownerUserIdSet); }  //Country Code calculation 
    }
    
    @testVisible private static Set<Id> getBlankCountryOwnerUserIdSet(List<Promotion__c> newPromotionList)
    {
        Set<Id> ownerUserIdSet = new Set<Id>();
        for (Promotion__c promotion : newPromotionList) 
        {
        	Id ownerUserId = getBlankCountryOwnerUserId (promotion);
        	if (ownerUserId != null) { ownerUserIdSet.add(ownerUserId); }
        }
        return ownerUserIdSet;
    }

    @testVisible private static Id getBlankCountryOwnerUserId (Promotion__c promotion)
    {
        String promotionOwnerId   = (String)promotion.OwnerId;
        promotion.Owner_Lookup__c = (promotionOwnerId.startsWith('005')) ? promotion.OwnerId         : null; 
        return ((String.isBlank(promotion.Country_Code__c)))             ? promotion.Owner_Lookup__c : null;
    }

    @testVisible private static void setCountryCodes(List<Promotion__c> newPromotionList, Set<Id> ownerUserIdSet)
    {
        Map<Id, User> ownerUserByIdMap = new Map<Id, User>([SELECT id, Country_Code__c FROM User WHERE id IN :ownerUserIdSet]);
        if (! ownerUserByIdMap.isEmpty()) { setCountryCodes(newPromotionList, ownerUserByIdMap); }
    }

    @testVisible private static void setCountryCodes(List<Promotion__c> newPromotionList, Map<Id, User> ownerUserByIdMap)
    {
        for (Promotion__c promotion : newPromotionList) 
        { 
	        if ((String.isBlank(promotion.Country_Code__c) && ownerUserByIdMap.containsKey(promotion.ownerId))) 
	        {
	            User ownerUser = ownerUserByIdMap.get(promotion.ownerId);
	            promotion.Country_Code__c = ownerUser.Country_Code__c;
	        }
        }
    }
}