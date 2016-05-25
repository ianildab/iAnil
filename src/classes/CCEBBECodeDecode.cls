/**
Author : Aditya Bansod,Capgemini
Date : 12th May,2015
Purpose - This class is used for BBE Date code decoding and hence calculate the production date.
*/
public class CCEBBECodeDecode{
  
  private static Map<String, CCE_Production_Code_Decode__c> plants = CCE_Production_Code_Decode__c.getAll();
  private static Map<String, Plant__c> plantsbyName = ECICCaseTriggerRegionCache.getPlantByNameMap();
  private static Map<Id, Production_Line__c> lineByIdMap = ECICCaseTriggerRegionCache.getLineByIdMap();
  private static Map<Id, CCE_Product__c> unknownProduct = ECICCaseTriggerRegionCache.getUnknownProductByIdMap();
  private static String[] productionWeekPosition;
  private static String[] productionWeekDayPosition;
  private static String[] BBEDayPosition;
  private static String[] BBEMonthPosition;
  private static String[] BBEYearPosition;
  private static String[] BBELegPosition;
  private static String[] ProductionDayPosition;
  private static String productionWeek;
  private static String productionWeekDay;
  private static String BBEDay;
  private static String BBEMonth;
  private static String BBEYear;
  private static String BBELeg;
  private static Boolean otherDateFormat = false; 
  private static Boolean otherDateFormatGB = false;   
  private static Integer BBEYearValue;
  private static Integer BBEMonthValue;
              
  
 
  public static void decodeBBEDateandPopulateProductionDate(CCE_Production_Code_Decode__c prodCodeSetting, Case newCase){
  
      String productionCode = newCase.Production_Code__c;
    // ---------- Added By --- Sagar Madkaikar --- For supporting multiple BBEDate formats--------- 
      if(prodCodeSetting.Other_Date_Format__c==true)
      {
          
          if(newCase.Text_BBE_Date__c.length() != prodCodeSetting.BBE_Code_Length__c && newCase.Text_BBE_Date__c.length() != prodCodeSetting.BBE_Code_Length_2__c)
          {
              newCase.addError(System.Label.CCE_Invalid_BBE_Date_Code);
              return;
          }

          otherDateFormatGB = true;
          if(newCase.Text_BBE_Date__c.length()==prodCodeSetting.BBE_Code_Length__c)
          {
              populateBBEDatePositionsBasic(prodCodeSetting);   // existing flow
          }
          else if(newCase.Text_BBE_Date__c.length()==6 && prodCodeSetting.BBE_Leg_Position__c ==  null)
          {
              otherDateFormat = true;
              populateBBEDatePositionsForOtherDate(prodCodeSetting); // flow for other date format
            
          }
          else if((prodCodeSetting.BBE_Code_Length__c == 8 && prodCodeSetting.BBE_Code_Length_2__c == 6)||(prodCodeSetting.BBE_Code_Length__c == 7 && prodCodeSetting.BBE_Code_Length_2__c == 5))
          {
              newCase.Text_BBE_Date__c = '28'+newCase.Text_BBE_Date__c;
              populateBBEDatePositionsBasic(prodCodeSetting);
          }
          else if((prodCodeSetting.BBE_Code_Length__c == 6 && prodCodeSetting.BBE_Code_Length_2__c == 8)||(prodCodeSetting.BBE_Code_Length__c == 5 && prodCodeSetting.BBE_Code_Length_2__c == 7))
          {
              String checkInt = newCase.Text_BBE_Date__c.subString(0,2);
              if(!checkInt.isNumeric())
              {
                  newCase.addError(System.Label.CCE_Invalid_BBE_Date_Code);
                  return;
              }
              populateBBEDatePositionsForOtherDate(prodCodeSetting);
          }
          else
          {
              newCase.addError(System.Label.CCE_Invalid_BBE_Date_Code);
          }
          
          
          

      }
      else
      {
          if(newCase.Text_BBE_Date__c.length() != prodCodeSetting.BBE_Code_Length__c ){         
             newCase.addError(System.Label.CCE_Invalid_BBE_Date_Code);
              return;
          }
          populateBBEDatePositionsBasic(prodCodeSetting); // existing flow                
      }    

      
      
     //---------------------------------------------- 
          
      if(unknownProduct.containsKey(newCase.CCE_Product__c)){
          return;
      }
      else
      {
        try
        {          
            productionWeek = productionWeekPosition.size() != 0 ? newCase.Production_Code__c.substring(Integer.ValueOf(productionWeekPosition[0])-1, Integer.ValueOf(productionWeekPosition[productionWeekPosition.size()-1])) : '';
              
            productionWeekDay = productionWeekDayPosition.size() != 0 ? newCase.Production_Code__c.substring(Integer.ValueOf(productionWeekDayPosition[0])-1, Integer.ValueOf(productionWeekDayPosition[productionWeekDayPosition.size()-1])) : '';
        
            BBEDay = BBEDayPosition.size() != 0 ? newCase.Text_BBE_Date__c.substring(Integer.ValueOf(BBEDayPosition[0])-1, Integer.ValueOf(BBEDayPosition[BBEDayPosition.size()-1])) : '';
              
            BBEMonth = BBEMonthPosition.size() != 0 ? newCase.Text_BBE_Date__c.substring(Integer.ValueOf(BBEMonthPosition[0])-1, Integer.ValueOf(BBEMonthPosition[BBEMonthPosition.size()-1])) : '';
              
            BBEYear = BBEYearPosition.size() != 0 ? newCase.Text_BBE_Date__c.substring(Integer.ValueOf(BBEYearPosition[0])-1, Integer.ValueOf(BBEYearPosition[BBEYearPosition.size()-1])) : '';
              
            BBELeg = BBELegPosition.size() != 0 ? newCase.Text_BBE_Date__c.substring(Integer.ValueOf(BBELegPosition[0])-1, Integer.ValueOf(BBELegPosition[BBELegPosition.size()-1])) : '';
              
            BBEYear = BBEYear.length() == 2 ? '20' + BBEYear : BBEYear;
            
            if(!BBEYear.isNumeric()){
                newCase.addError(System.Label.CCE_Invalid_BBE_Date_Code);
                return;
              }
            
            BBEYearValue = Integer.valueOf(BBEYear);
             // ---------- Added By --- Sagar Madkaikar -- For supporting multiple BBEDate formats---------  
            if(otherDateFormat)
            {
                // other date format code will go here
                 if(BBEMonthPosition.size() > 0 && BBEMonthPosition.size() != 2 && !BBEMonth.isNumeric()){
                 newCase.addError(System.Label.CCE_Invalid_BBE_Date_Code);
                 return;
              }
              
            
                BBEMonthValue = Integer.valueOf(BBEMonth);
                
                if(BBEMonthValue <= 0 || BBEMonthValue>12)
                {  
                    newCase.addError(System.Label.CCE_Invalid_BBE_Date_Code);
                    return;
                }   
            }
            else
            {

              if(BBEMonthPosition.size() > 0 && BBEMonthPosition.size() != 3 && !BBEMonth.isNumeric()){
                 newCase.addError(System.Label.CCE_Invalid_BBE_Date_Code);
                 return;
              }
              
              BBEMonthValue = BBEMonthPosition.size() != 0 ? BBEMonthPosition.size() == 3 ? getMonth(BBEMonth,newCase) : Integer.valueOf(BBEMonth) : null;
            }
            //---------------------------------------
              String bbeCodeProductionDay = ProductionDayPosition.size() != 0 ? newCase.Text_BBE_Date__c.substring(Integer.ValueOf(ProductionDayPosition[0])-1, Integer.ValueOf(ProductionDayPosition[ProductionDayPosition.size()-1])) : '';
              
              if(BBEMonthValue == null){
                  newCase.addError(System.Label.CCE_Invalid_BBE_Date_Code);
                  return;
              }
              
              Integer numberOfDays = Date.daysInMonth(BBEYearValue, BBEMonthValue);
              
              Integer BBEDayValue = !String.isBlank(BBEDay) ? Integer.valueOf(BBEDay) : 28;
              
              Date BBEDate = Date.newInstance(BBEYearValue, BBEMonthValue, BBEDayValue);
              
              if(newCase.Shelf_Life_In_Days__c != null){
                    DateTime productionDate = BBEDate.addDays(Integer.ValueOf(newCase.Shelf_Life_In_Days__c) * -1);
                    
                    newCase.Production_Date__c = productionDate.date();
                    
                    newCase.Production_DayNWEN__c = productionDate != null ? String.valueOf(productionDate.dayOfYear()) : '';
                    
                    
                    if(CCEProductionCodeDecoding.isInsert)
                        newCase.Days_Remaining_NWEN__c = String.valueOf(System.today().daysBetween(BBEDate) +1);
                    
                    else
                        newCase.Days_Remaining_NWEN__c = String.valueOf(newCase.createddate.date().daysBetween(BBEDate) +1);
              }
              else{
              
                  Decimal productShelfLife = newCase.Shelf_Life_Product__c != null ? Decimal.ValueOf(newCase.Shelf_Life_Product__c) : 0;
                  
                  Integer shelfLife = Integer.valueOf(productShelfLife) * -1;
                  
                  Decimal remainingDays = productShelfLife + shelfLife;
                  
                  Integer shelfLifeRemainingDays = Integer.valueOf(remainingDays * 30);
                  
                  Date productionMonthandYear = BBEDate.addMonths(shelfLife);
                  
                  productionMonthandYear = productionMonthandYear.addDays(shelfLifeRemainingDays * -1);
                  
                  Integer productionYear = productionMonthandYear.year();
                  
                  DateTime dummyProdDatewithYear = DateTime.newInstance(productionYear, 1,1);
                  
                  String weekDay = dummyProdDatewithYear.format('EEEE');
                  
                  Integer daysinFirstWeek = getDaysinFirstWeek(weekDay);
                  
                  if(daysinFirstWeek == null){
                      newCase.addError(System.Label.CCE_Invalid_BBE_Date_Code);
                      return;
                  }
        
                  Integer productionDay =  !String.isBlank(productionWeek) && !String.isBlank(productionWeekDay) ? Integer.valueOf(productionWeek) == 1 ? daysinFirstWeek : (daysinFirstWeek + Integer.valueOf(productionWeekDay) + ((Integer.valueOf(productionWeek) - 2)*7) ) : 0;
                  
                  productionDay = productionDay == 0 && !String.isBlank(bbeCodeProductionDay) ?Integer.valueOf(bbeCodeProductionDay) : productionDay;
                  
                  newCase.Production_DayNWEN__c = newCase.Production_DayNWEN__c == null ? productionDay != 0 ? String.valueOf(productionDay) : '' : newCase.Production_DayNWEN__c;
                  
                  if(String.isBlank(newCase.Production_DayNWEN__c)){
                      return;
                  }
                 if(!newCase.Production_DayNWEN__c.isNumeric()){
                    newCase.addError(System.Label.CCE_Invalid_Production_Code +' CCEBBECodeDecode');
                    return;
                 }
                 
                  DateTime productionDate = dummyProdDatewithYear.addDays(Integer.ValueOf(newCase.Production_DayNWEN__c) - 1);
                  
                  newCase.Production_Leg__c = !String.isBlank(BBELeg) ? BBELeg : newCase.Production_Leg__c;
                  
                  newCase.Production_Date__c = productionDate.date();
                  
                  if(productionDate.date() != null){
                      
                      Integer calculatedMonth = productionDate.date().addMonths(Integer.valueOf(productShelfLife)).addDays(shelfLifeRemainingDays).month();
                      if(calculatedMonth != BBEMonthValue){
                          newCase.addError(System.Label.CCE_Invalid_BBE_Date);
                          return;
                      }
                      
                  }
                  
                  if(CCEProductionCodeDecoding.isInsert)
                    newCase.Days_Remaining_NWEN__c = String.valueOf(System.today().daysBetween(BBEDate) +1);
                    
                  else
                    newCase.Days_Remaining_NWEN__c = String.valueOf(newCase.createddate.date().daysBetween(BBEDate) +1);
                  
                }
          }
          catch(Exception ex){
            System.debug(ex.getMessage());
            //newCase.addError(ex.getMessage());
            //
            newCase.addError(ex.getMessage()+'\n'+ex.getStackTraceString());
          }
      }
  }
  
    private static Integer getMonth(String month,Case newCase){
        if(month.equalsIgnoreCase('JAN')){
            return 1;
        }else if(month.equalsIgnoreCase('FEB')){
            return 2;
        }else if(month.equalsIgnoreCase('MAR')){
            return 3;
        }else if(month.equalsIgnoreCase('APR')){
            return 4;
        }else if(month.equalsIgnoreCase('MAY')){
            return 5;
        }else if(month.equalsIgnoreCase('JUN')){
            return 6;
        }else if(month.equalsIgnoreCase('JUL')){
            return 7;
        }else if(month.equalsIgnoreCase('AUG')){
            return 8;
        }else if(month.equalsIgnoreCase('SEP')){
            return 9;
        }else if(month.equalsIgnoreCase('OCT')){
            return 10;
        }else if(month.equalsIgnoreCase('NOV')){
            return 11;
        }else if(month.equalsIgnoreCase('DEC')){
            return 12;
        }else{
            newCase.addError(System.Label.CCE_Invalid_BBE_Date_Code);
            return null;
        }
    }
    
    private static Integer getDaysinFirstWeek(String weekDay){
        if(weekDay.equalsIgnoreCase('Sunday')){
            return 7;
        }else if(weekDay.equalsIgnoreCase('Monday')){
            return 6;
        }else if(weekDay.equalsIgnoreCase('Tuesday')){
            return 5;
        }else if(weekDay.equalsIgnoreCase('Wednesday')){
            return 4;
        }else if(weekDay.equalsIgnoreCase('Thursday')){
            return 3;
        }else if(weekDay.equalsIgnoreCase('Friday')){
            return 2;
        }else if(weekDay.equalsIgnoreCase('Saturday')){
            return 1;
        }else {
            return null;
        }
        
    }
    
    // used to populate BBEDate positions arrays when Other_Date_Format__c on custom setting is NOT CHECKED
    private static void populateBBEDatePositionsBasic(CCE_Production_Code_Decode__c prodCodeSetting)
    {
        productionWeekPosition =  prodCodeSetting.Week_Number_Position__c != null ? prodCodeSetting.Week_Number_Position__c.split(',') : new List<String>();
      
        productionWeekDayPosition =  prodCodeSetting.Week_Day_Number_Position__c != null ? prodCodeSetting.Week_Day_Number_Position__c.split(',') : new List<String>();
      
        BBEDayPosition =  prodCodeSetting.BBE_Day_Position__c != null ? prodCodeSetting.BBE_Day_Position__c.split(',') : new List<String>();
      
        BBEMonthPosition =  prodCodeSetting.BBE_Month_Position__c != null ? prodCodeSetting.BBE_Month_Position__c.split(',') : new List<String>();
      
        BBEYearPosition =  prodCodeSetting.BBE_Year_Position__c != null ? prodCodeSetting.BBE_Year_Position__c.split(',') : new List<String>();
      
        BBELegPosition =  prodCodeSetting.BBE_Leg_Position__c != null ? prodCodeSetting.BBE_Leg_Position__c.split(',') : new List<String>();
      
        ProductionDayPosition =  prodCodeSetting.BBE_Code_Production_Day__c != null ? prodCodeSetting.BBE_Code_Production_Day__c.split(',') : new List<String>();

    }
    
    // used to populate BBEDate positions arrays when Other_Date_Format__c on custom setting is CHECKED
    private static void populateBBEDatePositionsForOtherDate(CCE_Production_Code_Decode__c prodCodeSetting)
    {
        productionWeekPosition =  prodCodeSetting.Week_Number_Position__c != null ? prodCodeSetting.Week_Number_Position__c.split(',') : new List<String>();
      
        productionWeekDayPosition =  prodCodeSetting.Week_Day_Number_Position__c != null ? prodCodeSetting.Week_Day_Number_Position__c.split(',') : new List<String>();
      
        BBEDayPosition =  prodCodeSetting.BBE_Day_Position_2__c != null ? prodCodeSetting.BBE_Day_Position_2__c.split(',') : new List<String>();
      
        BBEMonthPosition =  prodCodeSetting.BBE_Month_Position_2__c != null ? prodCodeSetting.BBE_Month_Position_2__c.split(',') : new List<String>();
      
        BBEYearPosition =  prodCodeSetting.BBE_Year_Position_2__c != null ? prodCodeSetting.BBE_Year_Position_2__c.split(',') : new List<String>();
      
        BBELegPosition =  prodCodeSetting.BBE_Leg_Position__c != null ? prodCodeSetting.BBE_Leg_Position_2__c.split(',') : new List<String>();
      
        ProductionDayPosition =  prodCodeSetting.BBE_Code_Production_Day__c != null ? prodCodeSetting.BBE_Code_Production_Day__c.split(',') : new List<String>();

    }
}