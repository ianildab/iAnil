trigger HUB_SaveCaseCommentOnLog on CaseComment (after insert,after update) {

    if (SEPTriggerHandlerInvoker.skipTriggerInvocation()) { return; }
    public Id recordTypeId=[Select ID,DeveloperName From RecordType Where DeveloperName='HUB_Issue_Tracker'].id;
    List <CaseComment> allCaseComments = trigger.new;
    public Id caseRecordTypeId = [Select id, recordTypeId from Case where id =: allCaseComments[0].ParentId].recordTypeId;
    if(recordTypeId != caseRecordTypeId){
        return;
    }
    if(trigger.isInsert)
    {
    if(!HUB_Validator_cls.hasAlreadyDone()){    
    HUB_ConsolidatedLogHelper log = new HUB_ConsolidatedLogHelper();
    log.insertCaseCommentConsolidatedLog(Trigger.new);
    HUB_Validator_cls.setAlreadyDone();
    }
    }
    
    if(trigger.isUpdate)
    {
    if(!HUB_Validator_cls.hasAlreadyDone()){    
    HUB_ConsolidatedLogHelper log = new HUB_ConsolidatedLogHelper();
    log.insertCaseCommentConsolidatedLog(Trigger.new);
    HUB_Validator_cls.setAlreadyDone();
    }
    
    }
}