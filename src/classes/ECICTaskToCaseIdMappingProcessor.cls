public class ECICTaskToCaseIdMappingProcessor extends ECICCaseTaskProcessorAbstract    
{
    public Map<Task, Id> taskByCaseIdMap = new Map<Task, Id>(); // Is this safe?  Better to map against taskId or some string to represent it.
    @testVisible private static String CASE_CLOSED_ERROR_MESSAGE  = 'You cannot edit or add task to a closed case. Please reopen the case.';
    @testVisible private static String CASE_MISSING_ERROR_MESSAGE = 'You cannot edit or add task without a valid case.';

    public override void process(Task task) 
    {
        taskByCaseIdMap.put(task, task.whatId);
    }

    /*
     * Filter Case tasks where the Case status is not 'Closed'
     */
    public static Task[] filterNonClosedCaseTasks(Task[] newTaskArray, Map<Id, Task> oldTaskByIdMap) 
    {
        ECICTaskToCaseIdMappingProcessor processor = new ECICTaskToCaseIdMappingProcessor();
                                         processor.iterateOnCaseTasks(newTaskArray, oldTaskByIdMap);

        return (! processor.taskByCaseIdMap.isEmpty())
                        ? processor.buildNonClosedTaskList (ECICCaseDao.findByIds(processor.taskByCaseIdMap.values()))
                        : new List<Task>();
    }

    @testVisible private List<Task> buildNonClosedTaskList(Map<Id, Case> caseByIdMap)
    {
        List<Task> nonClosedTaskList = new List<Task>();
        for (Task task : this.taskByCaseIdMap.keySet()) 
        {
            Case    currentCase  = ((task != null) && (task.whatId != null)) ? caseByIdMap.get(task.whatId) : null;
            Boolean isCaseClosed = ((currentCase != null) && (currentCase.Status == ECICCommonConstants.STATUS_CLOSED));

            if      (currentCase == null) { SEPErrorHelper.addError( task, CASE_MISSING_ERROR_MESSAGE, false ); }
            else if (isCaseClosed)        { SEPErrorHelper.addError( task, CASE_CLOSED_ERROR_MESSAGE,  false ); } 
            else                          { nonClosedTaskList.add(   task                                    ); } 
        }
        return nonClosedTaskList;
    }
}