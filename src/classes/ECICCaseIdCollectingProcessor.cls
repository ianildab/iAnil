public class ECICCaseIdCollectingProcessor extends ECICCaseTaskProcessorAbstract    
{
    public Set<Id> caseIdSet = new Set<Id>();

    public override void process(Task task) 
    {
        caseIdSet.add(task.whatId);
    }

    public static Set<Id> buildCaseIdSet(Task[] newTaskArray, Map<Id, Task> oldTaskByIdMap) 
    {
        ECICCaseIdCollectingProcessor processor = new ECICCaseIdCollectingProcessor();
                                      processor.iterateOnCaseTasks(newTaskArray, oldTaskByIdMap);
                               return processor.caseIdSet;
    }    
}