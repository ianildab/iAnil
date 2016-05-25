/*
This class is used for polulating Beverage on Germnay Quality complaint if case is created from Web
*/

public class ECICCaseTriggerPopulateBeverageWeb2Case{

    private static Set<String> products = new Set<String>();
    private static List<Beverage__c> beverageList = new List<Beverage__c>();

  public static void populateBeverageBeforeInsert(List<Case> newValues,List<Case> oldValues){
      
      for(Case  cases:newValues){
          if(cases.Country_Code__c == 'DE' && cases.Origin == 'Web' && cases.Supplied_Product_DE__c != null && cases.Supplied_Product_DE__c != '')
              products.add(cases.Supplied_Product_DE__c);
      }
      populateBeverage(products);
      
      for(Case  cases:newValues){
          if(cases.Country_Code__c == 'DE' && cases.Origin == 'Web' && cases.Supplied_Product_DE__c != null && cases.Supplied_Product_DE__c != ''){
              for(Beverage__c beverage:beverageList ){
                  if(cases.Supplied_Product_DE__c.equalsIgnoreCase(beverage.Name)){
                      cases.Beverage__c = beverage.id;
                  
                  }
              
              }
             
          }
      }
  
  }  


  Private static void populateBeverage(Set<String> productList){
     
        if(productList !=null && productList.size() > 0){   
             beverageList = [SELECT Id,Name FROM Beverage__c WHERE Name IN: productList and Country_Code__c = 'DE'];
             
           
        }
    }
}