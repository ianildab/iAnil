@isTest

private class testBatchDeleteConversation{
    
    static testMethod void BatchDelete(){
        
        List<sf4twitter__Twitter_Conversation__c> listConv = new List<sf4twitter__Twitter_Conversation__c>();
        sf4twitter__Twitter_Conversation__c convInst = new sf4twitter__Twitter_Conversation__c();
        
        /*listConv = [Select Id,Delete_Flag__c FROM sf4twitter__Twitter_Conversation__c WHERE Delete_Flag__c = True LIMIT 1];*/
        
        convInst.sf4twitter__TwitterID__c = 'test01';
        //convInst.Delete_Flag__c = True;
        Insert convInst;
        
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        String jobId = System.schedule('test_Schedule', CRON_EXP, new ScheduleBatchDeleteConversation() );   
        Test.stopTest();
   
    }


}