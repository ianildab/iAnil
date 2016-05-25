/*
Author - Poornima Padki,Capgemini
Date - 22nd Oct,2014
Purpose - Scheduler Class to execute the batch class for auto delete of Conversation Records
*/

global class ScheduleBatchDeleteConversation implements Schedulable{
    
    global void execute(SchedulableContext Sc){
        try{
            BatchDeleteConversation bdc = new BatchDeleteConversation();
            Database.executeBatch(bdc);
        }
        
        catch(exception e){
            system.debug('error----->'+e.getmessage());
        }
    }

}