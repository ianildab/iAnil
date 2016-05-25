public class ECICCaseHelper 
{
    public static boolean caseTriggerToRun         = true;
    public static boolean CASE_BEFORETRIGGER_TORUN = true;
    public static boolean CASE_AFTERTRIGGER_TORUN = true;
    
    private static final Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);

    public static final Map<String, Id> CASE_RECORD_TYPE_IDS_BY_NAME_MAP = SEPRecordTypesCache.getRecordTypeIdsByDeveloperNameMap(Case.SObjectType); 
    
    //public static final String QUALITY_COMPLAINT_DEVELOPER_NAME = 'Quality_Complaint';
    //public static final String NON_QUALITY_COMPLAINT_RECORD_TYPE_ID = CaseRecordType__c.getInstance().NON_QUALITY_COMPLAINT_RECORD_TYPE_ID__c;
    //#RecordType
    //Updated by Balmukund, record typed id fetched based on records type's developer name
    public static final String NON_QUALITY_COMPLAINT_RECORD_TYPE_ID = CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get(ECICCommonConstants.NONQUALITY_COMPLAINT_DEVNAME);
   // public static final String INQUIRY_RECORD_TYPE_ID = CaseRecordType__c.getInstance().INQUIRY_RECORD_TYPE_ID__c;
    public static final String QUEUE_ID_START = '00G';

    private static final String USER_OBJECT_ID_PREFIX = Schema.SObjectType.User.getKeyPrefix();
    public static final String GROUP_OBJECT_ID_PREFIX = Schema.SObjectType.Group.getKeyPrefix();

    /*static 
    {
        if(NON_QUALITY_COMPLAINT_RECORD_TYPE_ID == null ) 
        {
          NON_QUALITY_COMPLAINT_RECORD_TYPE_ID = CASE_RECORD_TYPE_IDS_BY_NAME_MAP.get('Non_quality_Complaint');
        }
    }*/
    
    public static boolean isUserId(ID id)   { return id != null && ((String)id).startsWith(USER_OBJECT_ID_PREFIX);  }
    public static boolean isGroupId(ID id)  { return id != null && ((String)id).startsWith(GROUP_OBJECT_ID_PREFIX); }
    public static boolean isQueueId(ID id)  { return id != null && ((String)id).startsWith(QUEUE_ID_START);         }
}