@isTest
public class TEST_DummyTaskFactory 
{
  	private static final User TEST_RUN_USER = TEST_DummyUserFactory.createDefaultTestRunUser();
  	
	public class Config
	{
		public Id		actionPlanItemId = null;	// alias for templateId; will be ignored if templateId != null
		public Id		assignedToId	 = null;	// alias for ownerId; 	 will be ignored if ownerId != null
		public Id		caseId 	   		 = null;	// alias for whatId; 	 will be ignored if whatId != null
		public Id		templateId 		 = null;	// Commonly (always?), at least for Cases, actionPlanItemId
		public Id		whatId 	   		 = null;
		public Id		ownerId	   		 = null;
		public Decimal  taskNumber 		 = null;
		public String	subject			 = null;
		public String   status           = null; 
		public Date		activityDate 	 = null;	
        public Date     createdDate      = null;    
		public Date		dueDate 		 = null;	// alias for activityDate; will be ignored if activityDate != null
	    public Boolean  isModified       = false;	
		
		public Config() {}	
	}
	
	public static Task create (Config config, TEST_DummyInsertModeEnum insertMode)
	{
		// If config values for templateId and/or whatId don't have values, try getting values from their aliases.
			if (config.templateId == null) 	 { config.templateId 	= config.actionPlanItemId; }
			if (config.whatId == null) 	   	 { config.whatId 	    = config.caseId; 		   }
			if (config.ownerId == null) 	 { config.ownerId    	= config.assignedToId;	   }
			if (config.activityDate == null) { config.activityDate  = config.dueDate;	       }
			
			if ((config.isModified) && (config.createdDate == null)) { config.createdDate = System.today().addDays(-2);      }  // Backdates "createdDate" to make it before "lastModifiedDate"
	
		TEST_UniqueHelper unique = new TEST_UniqueHelper('Dummy Task');
		
		Task dummyTask = new Task();
			 dummyTask.ownerId			= TEST_ConfigHelper.chooseValue(config.ownerId,    (Id) TEST_RUN_USER.id);
			 dummyTask.task_number__c	= TEST_ConfigHelper.chooseValue(config.taskNumber, null); 
			 dummyTask.template_id__c	= TEST_ConfigHelper.chooseValue(config.templateId, (Id) null);
			 dummyTask.whatId			= TEST_ConfigHelper.chooseValue(config.whatId, 	   (Id) null);
			 dummyTask.subject			= TEST_ConfigHelper.chooseValue(config.subject,    unique.uniqueString + ' Subject');
             dummyTask.activityDate     = TEST_ConfigHelper.chooseValue(config.activityDate,   System.today());
             dummyTask.createdDate      = TEST_ConfigHelper.chooseValue(config.createdDate,    null);

		if (config.status != null) {  dummyTask.status = config.status; }

		if 			(insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  (        dummyTask );	} 
		else if 	(insertMode	== TEST_DummyInsertModeEnum.REAL)  { System.runAs(TEST_RUN_USER) { insert dummyTask;  } }

						 return dummyTask;
	}
	
	public static Task create (TEST_DummyInsertModeEnum insertMode) { return create (new Config(), insertMode); 				   }
	public static Task create () 				  				    { return create (new Config(), TEST_DummyInsertModeEnum.NONE); }
	
    // -------------------------------------------------------------------------------------------------
	
	// @depreciated : Use create (Config config, TEST_DummyInsertModeEnum insertMode)
	public static Task create (Config config, Boolean insertNow)    { return create (config, 	   convert(insertNow));            }

	// @depreciated : Use create (TEST_DummyInsertModeEnum insertMode)
	public static Task create (Boolean insertNow) 					{ return create (new Config(), convert(insertNow));            }

	private static TEST_DummyInsertModeEnum convert (Boolean insertNow)
	{
		return (insertNow) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE;
	}
}