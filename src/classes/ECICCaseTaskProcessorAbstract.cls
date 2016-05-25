abstract public class ECICCaseTaskProcessorAbstract implements ECICCaseTaskProcessorInterface
{
    @testVisible private static final String              CASE_OBJECT_ID_PREFIX             = Schema.SObjectType.Case.getKeyPrefix();
	
    public abstract void process(Task task);
    
    public void process (Task newTask, Task oldTask)
    {
    	Boolean isClosedChanged = (
    	                                   (newTask != null) && (oldTask != null)
    	                               &&  (
	    	                                       (oldTask.isClosed != newTask.isClosed) 
	           	                               ||  ( (newTask.id != null) && (Test.isRunningtest()) && (TEST_MockHelper.getMockBoolean(newTask.id, 'isClosedChanged')) )
           	                               )
    	                           );
    	
        if (
                  (oldTask          == null)                // new or deleted task
               || (oldTask.ownerId  != newTask.ownerId)     // an existing Task's owner is updated (counts agains the Case next open task responsible)
               || (isClosedChanged)                    // an existing Task is closed (counts against the number of incomplete tasks)
           )
        {
            this.process(newTask);
        }
    }
    
    public void iterateOnCaseTasks(List<Task> newTaskList, Map<Id, Task> oldTaskByIdMap) 
    {
    	if ((newTaskList != null) && (!newTaskList.isEmpty()))
    	{
	        for (Task newTask : newTaskList) 
	        {
	            if (isCaseRelatedTask(newTask)) 
	            {
	                this.process(newTask, (oldTaskByIdMap != null) ? (oldTaskByIdMap.get(newTask.id)) : (null)); 
	            }
	        }
    	}
    }
    
    @testVisible private boolean isCaseRelatedTask(Task task) 
    {
        return ((task != null) && (task.whatId != null) && (((String)task.whatId).startsWith(CASE_OBJECT_ID_PREFIX)));
    }
}