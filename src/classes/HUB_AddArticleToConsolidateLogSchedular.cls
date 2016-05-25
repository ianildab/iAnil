global class HUB_AddArticleToConsolidateLogSchedular implements Schedulable {
  
  global void execute(SchedulableContext SC){
  	HUB_AddArticleToConsolidateLog objClass = new HUB_AddArticleToConsolidateLog();
  	objClass.AddToConsolidatedLog();  	
  } 
  
   	 
  public static void start(){
    HUB_AddArticleToConsolidateLogSchedular m = new HUB_AddArticleToConsolidateLogSchedular();
    String seconds = '0'; 
    String minutes = '0'; 
    String hours = '*';  
    String dayOfMonth = '*'; 
    String month = '*'; 
    String dayOfWeek = '?';
    String year = '*';
    
    String sch = seconds + ' ' + minutes + ' ' + hours + ' ' + dayOfMonth + ' ' + month + ' ' + dayOfWeek + ' ' + year;
    
    try{
      system.schedule('Adding Article to Consolidated log hourly Schedular', sch, m);
      system.debug('>>>>>>>>>>>>>>>>>> SUCCESS');
    }catch(Exception e){
      system.debug('>>>>>>>>>>>>>>>>>> ERROR: ' + e.getMessage());
    
    }
  }
	
	
}