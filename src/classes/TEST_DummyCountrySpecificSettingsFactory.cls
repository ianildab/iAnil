@isTest
public class TEST_DummyCountrySpecificSettingsFactory 
{
    public static final Integer    DEFAULT_BONUS = 30;
    private static final User      SETUP_DATA_CREATION_USER = TEST_DummyUserFactory.SETUP_DATA_CREATION_USER;
	
	public class Config
	{
            public String  countryCode 					= null;
            public String  hQCity						= null;
            public String  allowedlanguages				= null;
            public String  allowedCaseRecordTypes		= null;
            public String  officialLanguages 			= null;
            public String  defaultLanguage				= null;
            public Integer bonus						= null;
            public String  businessUnit					= null;
            public String  exceptionList				= null;
            public String  qualityComplaintExportRecipients = null;
            public Id 	   qualityComplaintRecordTypeId = null;
            public Id      laboratoryOfAnalysisAccountId = null;
            
           	public Config(){}
           	public Config(String countryCode) { this.countryCode = countryCode; }
           	public Config(String countryCode, String[] countrySpecificSettings)
           	{
           		this(countryCode);
				this.hQCity			 				= countrySpecificSettings[0];
				this.allowedLanguages  				= countrySpecificSettings[1];
				this.officialLanguages 				= countrySpecificSettings[2];
				this.defaultLanguage	 			= countrySpecificSettings[3];
				this.businessUnit		 			= countrySpecificSettings[4];
				this.exceptionList	 				= countrySpecificSettings[5];
           	}
           	public Config(String countryCode, Id qualityComplaintRecordTypeId)
           	{
           		this (countryCode);
           		this.qualityComplaintRecordTypeId	= qualityComplaintRecordTypeId;
           	}
           	public Config(String countryCode, String[] countrySpecificSettings, Id qualityComplaintRecordTypeId)
           	{
           		this (countryCode, countrySpecificSettings);
           		this.qualityComplaintRecordTypeId	= qualityComplaintRecordTypeId;
           	}
	}
	
	// -------------------------------------------------------------------------------------------------

	public static Country_Specific_Settings__c create(Config config, TEST_DummyInsertModeEnum insertMode)
	{
		TEST_UniqueHelper unique = new TEST_UniqueHelper('Dummy Country Settings');
		
        Country_Specific_Settings__c countrySpecSetting  =  new Country_Specific_Settings__c();
						             countrySpecSetting.Name                        		   =   TEST_ConfigHelper.chooseValue(config.countryCode,		  			unique.uniqueString.left(1) + unique.uniqueString.right(1));
						             countrySpecSetting.HQ_City__c                  		   =   TEST_ConfigHelper.chooseValue(config.hQCity,				   			unique.uniqueString.left(5) + unique.uniqueString.right(20) + 'Headquarters');
						             countrySpecSetting.Allowed_Languages__c        		   =   TEST_ConfigHelper.chooseValue(config.allowedLanguages,	   			ECICCommonConstants.ES_LANGUAGE + ';' + ECICCommonConstants.EN_LANGUAGE);
						             countrySpecSetting.Allowed_Case_RecordTypes__c			   =   TEST_ConfigHelper.chooseValue(config.allowedCaseRecordTypes,	   		'');	
						             countrySpecSetting.Official_Languages__c       		   =   TEST_ConfigHelper.chooseValue(config.officialLanguages,				ECICCommonConstants.EN_LANGUAGE);
						             countrySpecSetting.Default_Language__c         		   =   TEST_ConfigHelper.chooseValue(config.defaultLanguage,				ECICCommonConstants.EN_LANGUAGE);
						             countrySpecSetting.Bonus__c                    		   =   TEST_ConfigHelper.chooseValue(config.bonus,						   	DEFAULT_BONUS);
						             countrySpecSetting.Business_Unit__c            		   =   TEST_ConfigHelper.chooseValue(config.businessUnit,		 	 	 	'');
						             countrySpecSetting.Exception_list__c           		   =   TEST_ConfigHelper.chooseValue(config.exceptionList,				   	'');
                                     countrySpecSetting.quality_complaint_export_recipients__c =   TEST_ConfigHelper.chooseValue(config.qualityComplaintExportRecipients, null);
						             countrySpecSetting.quality_complaint_record_type_id__c    =   TEST_ConfigHelper.chooseValue(config.qualityComplaintRecordTypeId, 	(Id) ECICCaseQualityComplaintRecordTypeHelper.DEFAULT_QUALITY_COMPLAINT_ID);
						             countrySpecSetting.Laboratory_of_Analysis__c    	   	   =   TEST_ConfigHelper.chooseValue(config.laboratoryOfAnalysisAccountId, 	(Id) null);

        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  (        countrySpecSetting );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  { System.runAs(SETUP_DATA_CREATION_USER) { insert countrySpecSetting;  } }

							  return countrySpecSetting;
	} 

    public static Country_Specific_Settings__c create (TEST_DummyInsertModeEnum insertMode) { return create (new Config(), insertMode);                    }
    public static Country_Specific_Settings__c create ()                                    { return create (new Config(), TEST_DummyInsertModeEnum.NONE); }
	
	// -------------------------------------------------------------------------------------------------

    public static List<Country_Specific_Settings__c> createList (List<Config> configList, TEST_DummyInsertModeEnum insertMode)
	{
        List<Country_Specific_Settings__c> countrySpecSettingList = new List<Country_Specific_Settings__c>();
        
        for(Config config : configList)  { countrySpecSettingList.add(create (config, false)); }
        
        if          (insertMode == TEST_DummyInsertModeEnum.MOCK)  { TEST_MockHelper.mockInsert  (        countrySpecSettingList );  } 
        else if     (insertMode == TEST_DummyInsertModeEnum.REAL)  { System.runAs(SETUP_DATA_CREATION_USER) { insert countrySpecSettingList;  } }

        				 return countrySpecSettingList;
	}

    public static List<Country_Specific_Settings__c> createList(Map<String,String[]> countrySpecSetValuesByCountry, TEST_DummyInsertModeEnum insertMode)
	{
    	List<Config> configList = new List<Config>();
        for(String country: countrySpecSetValuesByCountry.keySet()) 
        {
        	configList.add(new Config(country, countrySpecSetValuesByCountry.get(country)));
        }
    	return createList (configList, insertMode);
    }

    public static List<Country_Specific_Settings__c> createList(Map<String,String[]> countrySpecSetValuesByCountry) { return createList(countrySpecSetValuesByCountry, TEST_DummyInsertModeEnum.NONE); }    
	
	// ---------------------------------------------------------------------------------------------------------------------------------------------------

	public static List<Country_Specific_Settings__c> setupDummyCountrySpecificSettings(String currentUserCountryCode)
    {
        Map<String,String[]> countrySpecSetValuesByCountry = new Map<String,String[]>
        {
            'ES'    => new String[]{'Madrid', ECICCommonConstants.ES_LANGUAGE + ';' + ECICCommonConstants.EN_LANGUAGE, ECICCommonConstants.ES_LANGUAGE, ECICCommonConstants.ES_LANGUAGE, 'IB', 'de;del;en;y;i;de la;de las;de los;'},
            'PT'    => new String[]{'Lisbon', ECICCommonConstants.PT_LANGUAGE,                                         ECICCommonConstants.PT_LANGUAGE, ECICCommonConstants.PT_LANGUAGE, 'IB', 'da;de;do;das;dos;'                 },
            'UK'    => new String[]{'London', ECICCommonConstants.EN_LANGUAGE,                                         ECICCommonConstants.EN_LANGUAGE, ECICCommonConstants.EN_LANGUAGE, '',   ''                                  }
        };
        if ((currentUserCountryCode != null) &&(!(countrySpecSetValuesByCountry.keySet()).contains(currentUserCountryCode))) 
        {   
            countrySpecSetValuesByCountry.put(currentUserCountryCode, new String[]{'London', ECICCommonConstants.EN_LANGUAGE,    ECICCommonConstants.EN_LANGUAGE, ECICCommonConstants.EN_LANGUAGE, '', ''});
        }
        return createList (countrySpecSetValuesByCountry, TEST_DummyInsertModeEnum.REAL);
    }
	
	public static List<Country_Specific_Settings__c> setupDummyCountrySpecificSettings()
    {
    	return setupDummyCountrySpecificSettings(null);
    }
		
    // -------------------------------------------------------------------------------------------------
    
    // @depreciated : Use create (Config config, TEST_DummyInsertModeEnum insertMode)
    public static Country_Specific_Settings__c create (Config config, Boolean insertNow)    { return create (config,       convert(insertNow));            }

    // @depreciated : Use create (TEST_DummyInsertModeEnum insertMode)
    public static Country_Specific_Settings__c create (Boolean insertNow)                   { return create (new Config(), convert(insertNow));            }

    // @depreciated : Use createList (List<Config> configList, TEST_DummyInsertModeEnum insertMode)
    public static List<Country_Specific_Settings__c> createList (List<Config> configList, Boolean insertNow) { return createList (configList, convert(insertNow));  }

    // @depreciated : Use createList (Map<String,String[]> countrySpecSetValuesByCountry, TEST_DummyInsertModeEnum insertMode)
    public static List<Country_Specific_Settings__c> createList(Map<String,String[]> countrySpecSetValuesByCountry, Boolean insertNow) { return createList (countrySpecSetValuesByCountry, convert(insertNow));  }
    
    private static TEST_DummyInsertModeEnum convert (Boolean insertNow)
    {
        return (insertNow) ? TEST_DummyInsertModeEnum.REAL : TEST_DummyInsertModeEnum.NONE;
    }

		
}