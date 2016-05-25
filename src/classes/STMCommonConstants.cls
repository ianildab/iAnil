public class STMCommonConstants {
	
	public static Integer DEFAULT_NAME_FIELD_LENGTH = 80;
	
	public static final String COUNTRY_CODE_ES = 'ES';
	public static final String COUNTRY_CODE_BG = 'BG';
	public static final String COUNTRY_CODE_UK = 'UK';
	
	public static final String ROLE_DEFAULT                 = 'STMG_BEL_User';
	public static final String ROLE_STMG_BEL_USER           = 'STMG_BEL_User';
	public static final String ROLE_STMG_ES_USER            = 'STMG_ES_User';
	public static final String ROLE_STMG_PT_USER            = 'STMG_PT_User';
	public static final String ROLE_STMG_ES_B2OL            = 'STMG_ES_B2OL';
	public static final String ROLE_STMG_ES_HEALTH          = 'STMG_ES_Health';
	public static final String ROLE_STMG_ES_ASSETS          = 'STMG_ES_Assets';
	public static final String ROLE_STMG_ES_MEDIA_RELATIONS = 'STMG_ES_Media Relations';
	
	public static final String PROFILE_STMG_CAMPAIGN_MANAGER         = 'STMG_Campaign Manager';
	public static final String PROFILE_STMG_DATABASE_ADMINISTRATOR   = 'STMG_Database Administrator';
	public static final String PROFILE_STMG_REGULAR_USERS_PAC_TEAM   = 'STMG_Regular Users (PAC team)';
	public static final String PROFILE_STMG_SECRETARY                = 'STMG_Secretary';
	public static final String PROFILE_STMG_SUBJECT_MATTER_EXPERT    = 'STMG_Subject Matter Expert';
	public static final String PROFILE_STMG_SYSTEM_ADMINISTRATOR     = 'STMG_System Administrator';
	  
    public static String BUS_ACC_RECTYPE_NAME               = 'STMG_Company';
    public static String PERS_ACC_ACTIVE_RECTYPE_NAME       = 'STMG_Active_Person';
    public static String PERS_ACC_INACTIVE_RECTYPE_NAME     = 'STMG_Inactive_Person';
    //public static String PERS_ACC_INACTIVE_RECTYPE_ID_NAME   = 'STMG_Active_Belgium_Person';
   // public static String STMG_ACTIVE_IBERIA_PERSON_NAME    = 'STMG_Active_Iberia_Person';
    //public static String STMG_INACTIVE_BELGIUM_PERSON_NAME = 'STMG_Inactive_Belgium_Person';
    //public static String STMG_INACTIVE_IBERIA_PERSON_NAME  = 'STMG_Inactive_Iberia_Person';

    public static final String STMG_BUS_ACC_RECTYPE_ID = 
            Schema.SObjectType.Account.getRecordTypeInfosByName().get(BUS_ACC_RECTYPE_NAME).getRecordTypeId();
    
    public static final String PERS_ACC_ACTIVE_RECTYPE_ID = 
           Schema.SObjectType.Account.getRecordTypeInfosByName().get(PERS_ACC_ACTIVE_RECTYPE_NAME).getRecordTypeId();
    
    public static final String PERS_ACC_INACTIVE_RECTYPE_ID = 
           Schema.SObjectType.Account.getRecordTypeInfosByName().get(PERS_ACC_INACTIVE_RECTYPE_NAME).getRecordTypeId();       
    /*
    public static final String STMG_ACTIVE_IBERIA_PERSON = 
           Schema.SObjectType.Account.getRecordTypeInfosByName().get(STMG_ACTIVE_IBERIA_PERSON_NAME).getRecordTypeId();       
   
    public static final String STMG_INACTIVE_BELGIUM_PERSON = 
           Schema.SObjectType.Account.getRecordTypeInfosByName().get(STMG_INACTIVE_BELGIUM_PERSON_NAME).getRecordTypeId();       
    
    public static final String STMG_INACTIVE_IBERIA_PERSON = 
           Schema.SObjectType.Account.getRecordTypeInfosByName().get(STMG_INACTIVE_IBERIA_PERSON_NAME).getRecordTypeId();
    */       
           
}