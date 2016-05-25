@isTest
public class ECICRegionTestHelper 
{
  private static List<Region__c> existingRegionList = [SELECT id, Name FROM Region__c];
	
  public static void confirmShippingRegion (String shippingState)
  {
	if ((shippingState != null) && (shippingState != '') && !regionExists(shippingState))
	{
		createRegion(shippingState);
	}
  }
  
  private static Boolean regionExists(String shippingState)
  {
  	for (Region__c region : existingRegionList)
  	{
  		if (region.Name == shippingState) { return true; }
  	}
  	return false;
  }

  public static Region__c createRegion (String shippingState)
  {
  	Region__c shippingRegion = new Region__c (name = shippingState);
  	insert shippingRegion;
   
  	existingRegionList.add(shippingRegion);
  	
  	   return shippingRegion;
  }
    

    

}