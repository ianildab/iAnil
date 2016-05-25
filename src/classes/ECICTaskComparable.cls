// @see http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_list_sorting_sobject.htm
global class ECICTaskComparable implements Comparable
{
	public static final Integer IS_GREATER =  1;  
	public static final Integer IS_LESSER  = -1;  
	public static final Integer IS_EQUAL   =  0;  

	public Task task;
	
	public ECICTaskComparable (Task task) { this.task = task; }				// Constructor
	
	global Integer compareTo(Object compareTo)											// "Object" must be ECICTaskComparable, not Task
	{
		Decimal compareNumber = ((ECICTaskComparable) compareTo).task.Task_Number__c;	// Compare opportunities based on Task.Task_Number__c
		
		return (this.task.Task_Number__c > compareNumber)
				? IS_GREATER																		// Returns +1 if THIS is greater than compared.
				: (
					(this.task.Task_Number__c < compareNumber)
					? IS_LESSER																// Returns -1 if THIS is less than compared.
					: IS_EQUAL																	// Returns  0 if both elements are EQUAL.
				   );
	}
	
	public static Task selectFirstOpenTask(List<Task> taskList)
	{
   		List<ECICTaskComparable> taskCompareList = new List<ECICTaskComparable>();
		for (Task task :taskList)  
		{ 
			ECICTaskComparable taskComparable    = new ECICTaskComparable(task);
			taskCompareList.add(taskComparable);  
		}
		
		taskCompareList.sort();
		return taskCompareList[0].task;
	}
	
	
}