@isTest
public class TEST_DummyProfileMappingFactory 
{
    /*#CICTemplateTest*/
    private static final Set<String> DEFAULT_PROFILE_NAME_SET = new Set<String>{ ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT, ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_SUPERVISOR, ECICCommonConstants.PROFILE_ECIC_IBERIA_EXTERNAL_RELATIONS, ECICCommonConstants.PROFILE_SYSTEM_ADMIN };
    
    public static final List<Profiles_Mapping__c> DEFAULT_PROFILE_MAPPING_LIST = null;
    
    /**
     *  This map should help us solve TWO issues:
     *      1.) Automatic translation of Profile Names
     *      2.) Minimizing inserts during unit testing.
     **/
    public static final Map<String, Id> MOCK_PROFILE_ID_BY_PROFILE_UNTRANSLATED_NAME_MAP = new Map<String, Id>
    {   
        /*#CICTemplateTest - Start*/
        ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_AGENT         => 'a0E000000000001',
        ECICCommonConstants.PROFILE_ECIC_IBERIA_INFOLINE_SUPERVISOR    => 'a0E000000000002',
        ECICCommonConstants.PROFILE_ECIC_IBERIA_EXTERNAL_RELATIONS     => 'a0E000000000003',
        ECICCommonConstants.PROFILE_SYSTEM_ADMIN                       => 'a0E000000000004',
        ECICCommonConstants.PROFILE_ECIC_IBERIA_COCA_COLA_QUALITY      => 'a0E000000000005'
        /*#CICTemplateTest - End*/
    }; 

    public class Config
    {
        public String name = null;
        public Id     id   = null;
        
        public config(String name, Id id) 
        {
            this.name = name;
            this.id   = id;
        }
    }

    public static Profiles_Mapping__c create (Config config, TEST_DummyInsertModeEnum insertMode)
    {
        Profiles_Mapping__c dummyProfileMapping = new Profiles_Mapping__c ();
                            dummyProfileMapping.name  = config.name;
                            dummyProfileMapping.id__c = config.id; 
        
        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  {                                         TEST_MockHelper.mockInsert  ( dummyProfileMapping  );   }   
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  { System.runAs(ECICRunUserTestHelper.SETUP_DATA_CREATION_USER) { insert dummyProfileMapping;    } }

                            return dummyProfileMapping;
    }

    public static Profiles_Mapping__c create (String name, Id id, TEST_DummyInsertModeEnum insertMode)  { return create (new Config(name, id), insertMode);                     }
    public static Profiles_Mapping__c create (String name, Id id)                                       { return create (new Config(name, id), TEST_DummyInsertModeEnum.NONE);  }


    // --------------------------------------------------------------------------------------------------------------------------------------------------
    
    public static List<Profiles_Mapping__c> createList(Set<String> profileNameSet, TEST_DummyInsertModeEnum insertMode)
    {
        
        List<Profiles_Mapping__c> profileMappingList = new List<Profiles_Mapping__c >();
        for (String profileName : profileNameSet)
        {
              Profile profile = SEPProfileCache.get(profileName);
              profileMappingList.add(create(profile.name, profile.id, TEST_DummyInsertModeEnum.NONE));
        }

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  {                                         TEST_MockHelper.mockInsert  ( profileMappingList  );   }   
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  { System.runAs(ECICRunUserTestHelper.SETUP_DATA_CREATION_USER) { insert profileMappingList;    } }

                           return profileMappingList;
    }
    
    public static List<Profiles_Mapping__c> createDefaultList(TEST_DummyInsertModeEnum insertMode)
    {
        return createList(DEFAULT_PROFILE_NAME_SET, insertMode);
    }

    // ---------------------------------------------------------------------------------------------------------------------------

    public static void setMockProfileId (String userLastName, String profileName)
    {
         TEST_MockHelper.setMockString(userLastName, 'profileId', MOCK_PROFILE_ID_BY_PROFILE_UNTRANSLATED_NAME_MAP.get(profileName));
    }
    
}