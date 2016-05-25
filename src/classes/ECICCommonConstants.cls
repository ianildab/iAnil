/**
* @author           Pavel Slepenkov (Pavel_Slepenkov@epam.com)
* @description      Class is used for holding all constants of ECIC App, which is used in apex code.
*                   Class may be used as a extension for VisualForce pages.
*/
global class ECICCommonConstants {
    
    global static String CASE_QUILITY_COMPLAINT_RT_ID     = '01220000000JMHl';
    global static String CASE_NON_QUILITY_COMPLAINT_RT_ID = '01220000000JMHk';
    global static String CASE_INQUIRY_RT_ID               = '01220000000JLzS';
    global static String CASE_JOKE_RT_ID                  = '01220000000JLzT';
    global static String CASE_THANKS_RT_ID                = '01220000000JM2P';
    global static String ACCOUNT_BUSINESS_RT_ID           = '01220000000JLzQ';   
    global static String ACCOUNT_PERSON_RT_ID             = '01220000000JM5E';
    global static String PROFILE_CRM_DATA_LOADER_ID       = '00e20000001PCiuAAG';
    global static String SABU_QUALITY_COMPLAINT_RT_ID     = '0128E000000CoUe';
    global static String SABU_SAMPLE_COLLECTOR_ROLE_ID    = '0B78E0000008OLx';
    //global static String SABU_Quality_Coordinator_ROLE_ID = '0B78E0000008OM2';

    /**
    * @author       Pavel Slepenkov (Pavel_Slepenkov@epam.com)
    * @date         04 Feb 2013
    * @description  This class was added as extension for ECICWeb2Case page, for reading Case Record Type Ids
    */
    public ECICCommonConstants(ApexPages.StandardController controller) {
    }
    
    global static final Integer AMOUNT_OF_TESTED_INSTANCE = 20;
    global static final Integer DEFAULT_NAME_FIELD_LENGTH = 80;
    
    global static final Schema.FieldSetMember[] OPEN_ALERT_CASE_FIELDS = sObjectType.Open_Alert__c.FieldSets.Params.getFields();
    
    // List of ECIC profiles
    global static final String PROFILE_SYSTEM_ADMIN             = 'System Administrator';
    global static final String PROFILE_ECIC_INFOLINE_AGENT      = 'ECIC_Infoline Agent';
    global static final String PROFILE_ECIC_ADMINISTRATOR       = 'ECIC_Administrator';
    global static final String PROFILE_ECIC_INFOLINE_SUPERVISOR = 'ECIC_Infoline Supervisor';
    global static final String PROFILE_ECIC_COCA_COLA_QUALITY   = 'ECIC_Coca-Cola Quality';
    global static final String PROFILE_ECIC_BOTTLER_QUALITY     = 'ECIC_Bottler Quality';
    global static final String PROFILE_ECIC_EXTERNAL_RELATIONS  = 'ECIC_External Relations';
    global static final String PROFILE_ECIC_SUPPORT             = 'ECIC_Support';
    global static final String PROFILE_CRM_DATA_LOADER          = 'CRM Data Loader';
    //#Profile
    //Add new constants related to new profiles- by Balmukund
    global static final String PROFILE_ECIC_IBERIA_INFOLINE_AGENT      = 'ECIC Iberia Infoline Agent';
    global static final String PROFILE_ECIC_IBERIA_INFOLINE_SUPERVISOR = 'ECIC Iberia Infoline Supervisor';
    global static final String PROFILE_ECIC_NWEN_INFOLINE_AGENT      = 'ECIC NWEN Infoline Agent';
    global static final String PROFILE_ECIC_NWEN_INFOLINE_SUPERVISOR = 'ECIC NWEN Infoline Supervisor';
    global static final String PROFILE_ECIC_GERMANY_INFOLINE_AGENT      = 'ECIC Germany Infoline Agent';
    global static final String PROFILE_ECIC_GERMANY_INFOLINE_SUPERVISOR = 'ECIC Germany Infoline Supervisor';
    global static final String PROFILE_ECIC_COMMON_INFOLINE_AGENT      = 'ECIC Common Infoline Agent';
    global static final String PROFILE_ECIC_COMMON_INFOLINE_SUPERVISOR = 'ECIC Common Infoline Supervisor';
    global static final String PROFILE_ECIC_SABU_INFOLINE = 'ECIC SABU Infoline';
 
    global static final String PROFILE_ECIC_IBERIA_COCA_COLA_QUALITY   = 'ECIC Iberia Coca-Cola Quality';
    global static final String PROFILE_ECIC_IBERIA_BOTTLER_QUALITY     = 'ECIC Iberia Bottler Quailty';
    global static final String PROFILE_ECIC_IBERIA_EXTERNAL_RELATIONS  = 'ECIC Iberia External Relation';
    
    global static final String PROFILE_ECIC_CSE_AGENT     = 'ECIC CSE SM AGENT';
    global static final String PROFILE_ECIC_CSE_SUPERVISOR  = 'ECIC CSE SM SUPERVISOR';
    
    
    //List of ECIC roles
    global static final String ROLE_DEFAULT = 'Coca_Cola_Europe';
    global static final String ROLE_CIC_IBERIA_SERVICE_MANAGER                      = 'CIC_Iberia_Service_Manager';
    global static final String ROLE_COCA_COLA_EUROPE                                = 'Coca_Cola_Europe';
    global static final String ROLE_IBERIA_BOTTLER_EXTERNALS                        = 'Iberia_Bottler_External_Relations';    
    global static final String ROLE_IBERIA_BOTTLER_QUALITY                          = 'Iberia_Bottler_Quality';
    global static final String ROLE_IBERIA_BOTTLER_QUALITY_MANAGER                  = 'Iberia_Bottler_Quality_Manager';
    global static final String ROLE_ES_COCA_COLA                                    = 'ES_Coca_Cola';
    global static final String ROLE_IBERIA_CONSUMER_QUALITY_COMPLAINTS_MANAGER      = 'Iberia_Consumer_Quality_Complaints_Manager';
    global static final String ROLE_ES_INFOLINE_AGENT                               = 'ES_Infoline_Agent';
    global static final String ROLE_PT_INFOLINE_AGENT                               = 'PT_Infoline_Agent';
    global static final String ROLE_IBERIA_INFOLINE_SUPERVISOR                      = 'Iberia_Infoline_Supervisor';
    global static final String ROLE_IBERIA_QUALITY_ADMINISTRATIVE_ASSISTANT         = 'Iberia_Quality_Administrative_Assistant';
    global static final String ROLE_IBERIA_QUALITY_AGENT                            = 'Iberia_Quality_Agent';
    global static final String ROLE_IBERIA_QUALITY_MANAGER                          = 'Iberia_Quality_Manager';

    //List of ECIC Case Statuses
    global static final String STATUS_NEW                 = 'New';
    global static final String STATUS_OPEN                = 'Open';
    global static final String STATUS_ESCALATED           = 'Escalated';
    global static final String STATUS_CANCELLED           = 'Cancelled';
    global static final String STATUS_CLOSED              = 'Closed';
    global static final String STATUS_RESOLVED            = 'Resolved';
    global static final String STATUS_REOPENED            = 'Reopened';
    
    global static final String FIELD_ACTIVE               = 'Active__c';
    
    global static final String QUALITY_STATUS_PENDING_ON_QUALITY              = 'Pending on Quality';
    global static final String QUALITY_STATUS_NEW_COMPLAINT = 'New complaint';

    global static final String ACCOUNT_NAME                                       = 'Test_Account_Name';
    global static final String ACCOUNT_BUSINESS_NAME                              = 'Test Company';
    global static final String ACCOUNT_PERSON_FIRST_NAME                          = 'firstName';
    global static final String ACCOUNT_PERSON_LAST_NAME                           = 'lastName';
    global static final String ACCOUNT_TYPE_DEFAULT                               = 'Customer';
    global static final String ACCOUNT_TYPE_BOTTLER                               = 'Bottler';
    global static final String ACCOUNT_TYPE_LABORATORY                            = 'Laboratory';
    global static final String ACCOUNT_TYPE_POSKEYACCOUNT                         = 'Key Account';
    global static final String ACCOUNT_TYPE_SUPPLIER                              = 'Supplier';
    global static final String ACCOUNT_TRADE_CHANNEL                              = 'All Other';
    global static final String BUSINESS_ACCOUNT_NAME                              = 'Test_Account_Name';
    global static final String CASE_CHANNEL_OF_ANSWER                             = 'Phone';
    global static final String CASE_ORIGIN                                        = 'Phone';
    global static final String CASE_ORIGIN_PHONE                                  = 'Phone';
    global static final String CASE_ORIGIN_FACEBOOK                               = 'Facebook';
    global static final String CASE_ORIGIN_EMAIL                                  = 'Email';
    global static final String CASE_ORIGIN_COMMERCIAL_DEPT                        = 'Commercial Dept.';
    global static final String CASE_PRIORITY                                      = 'High';
    global static final String CASE_SUBJECT                                       = 'Test Case Subject';
    global static final String CONTACT_FIRSTNAME                                  = 'Test_FirstName';
    global static final String CONTACT_LASTNAME                                   = 'Test_LastName';
    global static final String COUNTRY_CODE_DEFAULT                               = 'ES'; // Arbitrary, fictional country to avoid environmental conflicts.
    global static final String COUNTRY_CODE_SPAIN                                 = 'ES';
    global static final String COUNTRY_CODE_US                                    = 'US';
    global static final String COUNTRY_CODE_UK                                    = 'UK';
    global static final String COUNTRY_CODE_PT                                    = 'PT';
    global static final String COUNTRY_CODE_FR                                    = 'FR';
    global static final String COUNTRY_CODE_GB                                    = 'GB';
    global static final String COUNTRY_CODE_NO                                    = 'NO';
    global static final String COUNTRY_CODE_SE                                    = 'SE';
   // global static final String COUNTRY_CODE_PT                                    = 'PT';
  //  global static final String COUNTRY_CODE_PT                                    = 'PT';
    global static final String EMAIL                                              = 'tester@test.test';
    global static final String TEST_USER_EMAIL                                    = 'test.tccc.cic@test.test';
    global static final String EN_LANGUAGE                                        = 'en';
    global static final String ES_LANGUAGE                                        = 'es';
    global static final String PT_LANGUAGE                                        = 'pt_PT';
    global static final String INQUIRY                                            = 'Inquiry';
    global static final String INQUIRY_REASON                                     = 'Sponsoring';
    global static final String JOKE_USELESS                                       = 'Useless';
    global static final String JOKE_USELESS_REASON                                = 'Wrong Number';
    global static final String QUALITY_COMPLAINT                                  = 'Quality Complaint';
    global static final String NON_QUALITY_COMPLAINT                              = 'Non-Quality Complaint';
    global static final String NON_QUALITY_COMPLAINT_REASON                       = 'Brand Info';
    global static final String PHONE                                              = '1234567890';
    global static final String CASE_CATEGORY_LEVEL_3_PACKAGE_QUALITY_LABEL        = 'Label';
    global static final String CASE_CATEGORY_LEVEL_4_PACKAGE_QUALITY_LABEL        = 'Missing';
    global static final String CASE_CATEGORY_LEVEL_3_PACKAGE_QUALITY_FILL_LEVEL              = 'Fill control';
    global static final String CASE_CATEGORY_LEVEL_4_PACKAGE_QUALITY_FILL_LEVEL              = 'Short filled';
    global static final String CASE_CATEGORY_LEVEL_3_PRODUCT_QUALITY_CARBONATION             = 'Carbonation';
    global static final String CASE_CATEGORY_LEVEL_4_PRODUCT_QUALITY_CARBONATION             = 'Product flat on opening';
    global static final String CASE_CATEGORY_LEVEL_3_PRODUCT_QUALITY_FOREIGN_MATTER          = 'Foreign Matter';
    global static final String CASE_CATEGORY_LEVEL_4_PRODUCT_QUALITY_FOREIGN_MATTER          = 'Metal like';

    global static final String QUALITY_COMPLAINT_REASON_PRODUCTS                  = 'Product Quality';
    global static final String QUALITY_COMPLAINT_REASON_PACKAGE                   = 'Package Quality';
    global static final String TEST_CITY_STATE_AND_REGION                         = 'Madrid';
    global static final String TEST_COMPETITOR_PRODUCT                            = 'Test Competitor Product';
    global static final String TEST_COUNTRY                                       = 'Spain';
    global static final String TEST_PLANT                                         = 'Test Plant';
    global static final String TEST_POSTAL_CODE                                   = '220000';
    global static final String TEST_PRODUCTION_LINE_NAME                          = 'F8';
    global static final String TEST_PROMOTION                                     = 'Test Promotion';
    global static final String TEST_REGION_NAME_2                                 = 'Madrid_1';
    global static final String TEST_STREET                                        = 'street';
    global static final String  SABU_From_Geo_Mappings                            = 'From Geo Mapping';
        global static final String[] ACTION_PLAN_PARAM_1 = new String[]{'testAPName',
        'testUniqueName'+(Math.random()).format(),
        '5',
        COUNTRY_CODE_SPAIN,
        CASE_ORIGIN_PHONE,
        QUALITY_COMPLAINT_REASON_PRODUCTS,
        CASE_CATEGORY_LEVEL_3_PRODUCT_QUALITY_CARBONATION,
        CASE_CATEGORY_LEVEL_4_PRODUCT_QUALITY_CARBONATION};

    global static final String PLANT_NAME_DEFAULT  = 'Test Plant';
    
    
    global static final Integer PRODUCT_SHELF_LIFE_DEFAULT = 10;
    global static final String PRODUCT_NAME_DEFAULT        = 'Coca-Cola';
    global static final String PRODUCT_FLAVOUR_DEFAULT     = 'Coca-Cola';
    global static final String PRODUCT_UNIT_DAY            = 'Day';
    global static final String PRODUCT_UNIT_MONTH          = 'Month';
    global static final String PRODUCT_UNIT_DEFAULT        = PRODUCT_UNIT_DAY;
    global static final String PRODUCT_TYPE_DEFAULT        = 'Coke brands';
    global static final String PRODUCT_SIZE_DEFAULT        = '250ml';
    global static final String PRODUCT_PACKAGING_DEFAULT   = 'CAN';
    global static final String PRODUCT_PRIMARY_CONTAINER_DEFAULT        = '1-Ltr Glass Btl Nr';
    global static final String PRODUCT_PRIMARY_CONTAINER_CODE_DEFAULT   = '1DU';
    global static final String PRODUCT_DESCRIPTION_DEFAULT              = 'Aquabona';
    global static final String PRODUCT_PACKAGE_TYPE_DEFAULT             = 'Can';
    global static final Decimal PRODUCT_UNIT_PRICE_DEFAULT = 2.5;
    
    global static final String BEVERAGE_BRAND_DEFAULT               = 'Burn';
    global static final String BEVERAGE_FLAVOUR_DEFAULT             = 'Burn';
    global static final String BEVERAGE_FLAVOUR_CODE_DEFAULT        = 'A4G';
    global static final String BEVERAGE_TYPE_DEFAULT                = 'Energy Drinks';
    global static final String BEVERAGE_TYPE_CODE_DEFAULT           = '40';
    global static final String BEVERAGE_PRODUCT_DESCRIPTION_DEFAULT = 'Aquabona';

    global static final String REGION_1_NAME                                      = 'Madrid';
    global static final String REGION_2_NAME                                      = 'Madrid_1';
    global static final String THANKS                                             = 'Compliment';
    global static final String THANKS_REASON                                      = 'Compliment';
    
    //Added by Balmukund Case RecordType's Developer name
    global static final String INQUIRY_DEVNAME                  =   'Inquiry';
    global static final String QUALITY_COMPLAINT_DEVNAME        =   'Quality_Complaint';
    global static final String NONQUALITY_COMPLAINT_DEVNAME     =   'Non_Quality_Complaint';
    global static final String NWEN_QUALITY_COMPLAINT_DEVNAME   =   'Quality_Complaint_NWEN';
    global static final String LCBU_QUALITY_COMPLAINT_DEVNAME   =   'Quality_Complaint_LCBU';
    global static final String SABU_QUALITY_COMPLAINT_DEVNAME   =   'Quality_Complaint_SABU';
    global static final String SABU_INQUIRY_DEVNAME   =   'Inquiry_SABU';
    global static final String SABU_Non_Quality_COMPLAINT_DEVNAME   =   'Non_Quality_Complaint_SABU';
    global static final String COMMENT_DEVNAME                  =   'Comment';
    global static final String COMPLIMENT_DEVNAME               =   'Compliment';
    global static final String SPAM_DEVNAME                     =   'Spam';
    global static final String USELESS_DEVNAME                  =   'Useless';
  // # Ecic Template Test
    global static final String INQUIRY_Iberia           =   'Inquiry Iberia';
    global static final String INQUIRY_IBERIA_DEVNAME               =   'Inquiry_Iberia';
    global static final String QUALITY_COMPLAINT_IBERIA_DEVNAME     =   'Quality_Complaint_Iberia';
    global static final String NON_QUALITY_COMPLAINT_IBERIA_DEVNAME =   'Non_Quality_Complaint_Iberia';    
    global static final String COMPLIMENT_IBERIA_DEVNAME            =   'Compliment_Iberia';
    global static final String COMMENT_IBERIA_DEVNAME               =   'Comment_Iberia';
    global static final String USELESS_IBERIA_DEVNAME               =   'Useless_Iberia';
    global static final String HUB_DEVNAME                          =   'HUB_Issue_Tracker';
    
    global static final String INQUIRY_IBERIA_RTNAME               =   'Inquiry Iberia';
    global static final String QUALITY_COMPLAINT_IBERIA_RTNAME     =   'Quality Complaint Iberia';
    global static final String QUALITY_COMPLAINT_NWEN_RTNAME       =   'Quality Complaint NWEN';
    global static final String NON_QUALITY_COMPLAINT_IBERIA_RTNAME =   'Non-Quality Complaint Iberia';    
    global static final String COMPLIMENT_IBERIA_RTNAME            =   'Compliment Iberia';
    global static final String COMMENT_IBERIA_RTNAME               =   'Comment Iberia';
    global static final String USELESS_IBERIA_RTNAME               =   'Useless Iberia';
    
    //Case Team Constants
    global static final String CIC_CONTACT_RT                          = 'CIC_Contact'; 
    global static final String CASE_TEAM_IBERIA                         = 'Case Team Iberia';
    global static final String QUALITY_COMPLAINT_IBERIA                 = 'Quality Complaint Iberia';
    global static final String QUALITY_COMPLAINT_SPAIN                  = 'Quality Complaint Spain';
    global static final String QUALITY_COMPLAINT_PORTUGAL               = 'Quality Complaint Portugal';
    global static final String QUALITY_COMPLAINT_GERMANY                = 'Quality Complaint Germany';
    global static final String CASE_TEAM_FR_NWEN                        = 'Case Team FR NWEN';
    global static final String QUALITY_COMPLAINT_FR_NWEN                = 'Quality Complaint FR NWEN';
    global static final String CASE_TEAM_CSE                            = 'Case Team CSE';
    global static final String CASE_TEAM_GERMANY                        = 'Case Team Germany';
    global static final String CASE_TEAM_CENTRAL_QESH                   = 'CCE Central QESH NWEN';
    global static final String CASE_TEAM_CENTRAL_SABU                   = 'SABU Central Team';
    
    global static final String CASE_TEAM                                = 'Case Team';
    global static final String QUALITY_COMPLAINT_CASETEAM               = 'Quality Complaint';
    global static final String POTENTIAL_RISK_IBERIA_CASETEAM           = 'Case Team Potential Risk Iberia';
    global static final String CENTRO_IBERIA_CASETEAM                   = 'Case Team CENTRO Iberia';
    global static final String ESTE_IBERIA_CASETEAM                     = 'Case Team ESTE Iberia';
    global static final String NORTE_IBERIA_CASETEAM                    = 'Case Team NORTE Iberia';
    global static final String PORTUGAL_IBERIA_CASETEAM                 = 'Case Team PORTUGAL Iberia';
    global static final String IBERIAN_PLANT                            = 'Iberian Plant';
    global static final String SUR_IBERIA_CASETEAM                      = 'Case Team SUR Iberia';
    global static final String MKT_INTELI_ANALYST_ROLE_NAME             = 'Market Intelligence Analyst';
    global static final String CCE_CO_PACKER_QESH_NWEN                  = 'CCE Co-Packer QESH NWEN';
    
     //HUB Case Team Constants   
    global static final String HUB_GLOBAL_COKE_BRAND_TEAM                    = 'HUB Global Coke Brand Team';
    global static final String HUB_GLOBAL_DIET_COKE_BRAND_TEAM               = 'HUB Global Diet Coke Brand Team';
    global static final String HUB_FIFA_CHARTER_TEAM                         = 'HUB FIFA Charter team';
    global static final String HUB_GLOBAL_SRA_TEAM                           = 'HUB Global SRA Team';
    global static final String HUB_GLOBAL_FANTA_BRAND_TEAM                   = 'Hub Global Fanta Brand Team';
    global static final String HUB_GLOBAL_SPRITE_BRAND_TEAM                  = 'Hub Global Sprite Brand Team';
    global static final String HUB_GLOBAL_POWERADE_BRAND_TEAM                = 'Hub Global Powerade Brand Team';
    global static final String HUB_GLOBAL_COKE_ZERO_BRAND_TEAM               = 'Hub Global Coke Zero Brand Team';
    global static final String HUB_GLOBAL_COCA_COLA_LIFE_BRAND_TEAM          = 'Hub Global Coca-Cola Life Brand Team';
    global static final String HUB_GLOBAL_GLACEAU_BRAND_TEAM                 = 'Hub Global Glaceau Brand Team';
    global static final String HUB_OLYMPICS_CHARTER_TEAM                     = 'Hub Olympics Charter team';
    global static final String HUB_GLOBAL_PAC_TEAM                           = 'Hub Global PAC Team';
    global static final String HUB_STRATEGIC_SECURITY                        = 'Hub Strategic Security';
    //
    global static final String TWITTER_CASE_ORIGIN                      = 'Twitter';
    global static final String CASE_POTENTIAL_NO_RISK                   = 'No Risk';
    global static final String FB_CASE_ORIGIN                           = 'Facebook';
    global static final String WEB_CASE_ORIGIN                          = 'Web';
    global static final String IBERIA_REGION                            = 'Iberia';
    global static final String GERMANY_REGION                           = 'Germany';
    global static final String NWEN_REGION                              = 'NWEN';
    global static final String LCBU_REGION                              = 'LCBU';
    global static final String CSE_REGION                               = 'CSE';
    global static final String CCE_NWEN                                 = 'CCE';
    global static final String SABU_REGION                              = 'SABU';
    global static final String PLANT                                    = 'Plant';
    global static final String COCA_COLA_ENTERPRISES                    = 'Coca-Cola Enterprises';
    global static final String SABU_Quality_Coordinator_ROLE_ID         = 'SABU Quality Coordinator';
    global static final String SABU_SAMPLE_COLLECTOR_ROLEID             = 'SABU Sample Collector';
    global static final String HIGH_RISK                                = 'High Risk';
    global static final String MEDIUM_RISK                              = 'Medium Risk';
    
    //HUB Constants for Brand on Inteligence case    
    global static final String HUB_BRAND_COCA_COLA                      = 'Coca-Cola';
    global static final String HUB_BRAND_COCA_COLA_LIGHT                = 'Diet Coke/Coca-Cola light';
    global static final String HUB_BRAND_FANTA                          = 'Fanta';
    global static final String HUB_BRAND_SPRITE                         = 'Sprite';
    global static final String HUB_BRAND_POWERADE                       = 'POWERADE';
    global static final String HUB_BRAND_COCA_COLA_ZERO                 = 'Coca-Cola Zero';
    global static final String HUB_BRAND_COCA_COLA_LIFE                 = 'Coca-Cola Life';
    global static final String HUB_BRAND_COCA_COLA_VITAMIN              = 'glacéau vitaminwater';
    global static final String HUB_BRAND_FIFA                           = 'FIFA';
    global static final String HUB_BRAND_OLYMPICS                       = 'Olympics';
    global static final String HUB_BRAND_SECURITY                       = 'Security';
    global static final String NEW_COMPLAINT                            = 'New Complaint';
       
    global static final String IBERIA_BOTTLER_QUAILITY_ROLEID           = 'Iberia Bottler Quality';
    global static final String IBERIA_INFOLINE_SUPERVISOR_ROLEID        = 'Iberia Infoline Supervisor';
    global static final String IBERIA_EXTERNAL_RELATION_ROLEID          = 'Iberia External Relations';
    global static final String IBERIA_POTENTIAL_RISK_USERID             = 'Use Id for Potential Risk';
    //Case types
    
    global static final String INQUIRY_CASETYPE                 =   'Inquiry';
    global static final String QUALITY_COMPLAINT_CASETYPE       =   'Quality Complaint';
    global static final String NONQUALITY_COMPLAINT_CASETYPE    =   'Non-Quality Complaint';
    global static final String COMMENT_CASETYPE                 =   'Comment';
    global static final String COMPLIMENT_CASETYPE              =   'Compliment';
    global static final String SPAM_CASETYPE                    =   'Spam';
    global static final String USELESS_CASETYPE                 =   'Useless';
    
    global static final String TREND_STATUS_CANCELLED           = 'Cancelled';
    global static final String TREND_STATUS_INACTIVE            = 'Inactive';
    global static final String TREND_STATUS_ACTIVE              = 'Active';
    
    //Common Constants for Generic SOQL Queries On RecordTypes
    global static final String RECORDTYPE_BY_DEVELOPERNAME_EQUAL ='RecordTypeByDeveloperNameEqual';
    global static final String RECORDTYPE_BY_DEVELOPERNAME_CONTAINS ='RecordTypeByDeveloperNameContains';
    global static final String RECORDTYPE_BY_SOBJECT_TYPE ='RecordTypeBySobjectType';
    global static final String CASE_RECORDTYPE_BY_DEVELOPERNAME ='CaseRecordTypeByDeveloperName';
    
    

/***** CIC-616, set KeyStakeholders in Profession_Function field *****/
    global static final Set<String> KEY_STAKEHOLDERS_PROFESSION = new Set<String>{
        'Health professional (dietician, nurse, etc.)',
        'Government employee',
        'NGO Employee (environment, health, etc.)',
        'Academic or scientist',
        'Journalist',
        'VIP',
        'Lawyer',
        'Doctor'
    }; 

    global static final String[] ACTION_PLAN_PARAM_2 = new String[]{
        'actionPlan2',
        'testUniqueName'+(Math.random()).format(),
        '6',
        COUNTRY_CODE_UK,
        CASE_ORIGIN_PHONE,
        QUALITY_COMPLAINT_REASON_PACKAGE,
        CASE_CATEGORY_LEVEL_3_PACKAGE_QUALITY_FILL_LEVEL,
        CASE_CATEGORY_LEVEL_4_PACKAGE_QUALITY_FILL_LEVEL 
    };

    global static final String[] ACTION_PLAN_PARAM_3 = new String[]{
        'actionPlan3',
        'testUniqueName'+(Math.random()).format(),
        '7',
        COUNTRY_CODE_US,
        CASE_ORIGIN_PHONE,
        QUALITY_COMPLAINT_REASON_PRODUCTS,
        CASE_CATEGORY_LEVEL_3_PRODUCT_QUALITY_FOREIGN_MATTER,
        CASE_CATEGORY_LEVEL_4_PRODUCT_QUALITY_FOREIGN_MATTER
     };
    
    //Action Plan Item fields:  Name,Item_Unique_Name__c,Task_Number__c(Integer), Subject, Modem, Priority, Type
    global static final String[] ACTION_PLAN_ITEM_PARAM_1 = new String[]{'testAPIName',
        'testItemUniqueName'+(Math.random()).format(), '5' ,'testSubject1','Key', 'High', 'Email'};
    global static final String[] ACTION_PLAN_ITEM_PARAM_2 = new String[]{'testAPIName',
        'testItemUniqueName'+(Math.random()).format(), '5' ,'testSubject2','Conditional', 'Normal', 'Email'};
    global static final String[] ACTION_PLAN_ITEM_PARAM_3 = new String[]{'testAPIName',
        'testItemUniqueName'+(Math.random()).format(), '5' ,'testSubject3','Optional', 'Low', 'Email'};

    
    global static String COMMA_DEL = ',';
    global static String SEMICOLON = ';';

    global static String[] USER_FIELDS = new String[]{
        'Quality_Case_Owner__c',
        'Quality_Admin_Assistant__c',
        'Consumer_Complaint_Manager__c',
        'Service_Manager__c',
        'Quality_Manager__c'
        };
        
    global final static String[] BOTTLER_FIELDS = new String[]{
        'Bottler_External_Relations__c',
        'Bottler_Quality_Manager__c',
        'Bottler_Quality__c'
        };
        
    global final static String[] REGION_USER_FIELDS = new String[]{
        'Bottler_External_Relations__c',
        'Bottler_Quality_Manager__c',
        'Bottler_Quality_Owner__c',
        'Distributor_External_Relations__c',
        'Distributor_Quality__c',
        'Distributor_Quality_Manager__c'
        };        
        
    global final static String[] OPEN_ALERT_RECIPIENT_FIELDS = buildOpenAlertRecipientFieldArray();
    
    @testVisible private static String[] buildOpenAlertRecipientFieldArray()
    {
        Set<String> openAlertRecipientFieldSet = new Set<String>();
                    openAlertRecipientFieldSet.addAll(USER_FIELDS);
                    openAlertRecipientFieldSet.addAll(REGION_USER_FIELDS);
        return new List<String>(openAlertRecipientFieldSet);
    }
        
    global final static String[] CASE_FIELDS = new String[] {
        'Can_Process__c',
        'Compensation_Product__c',
        'Customer_Complaint__c',
        'Damage_Caused__c',
        'External_Collector__c',
        'Gift_Compensation__c',
        'Has_ShippingAddress__c',
        'IMCR_Issue__c',
        'Insurance__c',
        'Origin',
        'Potential_Risk__c',
        'Product_Package__c',
        'Quality_Status__c',
        'Risk_Type__c',
        'Sample_Collected__c',
        'Sample_Collector__c',
        'Status',
        'Type_of_Gift__c'
    };

    global final static String[] TASK_FIELDS = ECICUtils.getSObjectEditableFields(Task.sObjectType);

    global final static String SELECT_CASE = 'select Country_Code__c, Action_plan__c, ownerid ' 
        + ECICCommonConstants.COMMA_DEL 
        + String.join(ECICCommonConstants.CASE_FIELDS, ECICCommonConstants.COMMA_DEL) 
        + ECICCommonConstants.COMMA_DEL 
        + String.join(ECICCommonConstants.USER_FIELDS, ECICCommonConstants.COMMA_DEL) 
        + ECICCommonConstants.COMMA_DEL
        + String.join(REGION_USER_FIELDS, ECICCommonConstants.COMMA_DEL) 
        + ' from case';
        
    global final static String SELECT_REGION = 'select Country_Code__c' 
        + ECICCommonConstants.COMMA_DEL 
        + String.join(ECICCommonConstants.BOTTLER_FIELDS, ECICCommonConstants.COMMA_DEL) 
        + ' from Region__c';
      
   /**
    * @author       Pavel Slepenkov (Pavel_Slepenkov@epam.com).
    * @date         04 Feb 2013
    * @description  The following method is created for access to Case record types ids from VF page
    */        
    global String getQualityComplaintRT() {
        return CASE_QUILITY_COMPLAINT_RT_ID.substring(0,15);
    }
    
    global String getNonQualityComplaintRT() {
        return CASE_NON_QUILITY_COMPLAINT_RT_ID.substring(0,15);
    }
    
    global String getInquiryRT() {
        return CASE_INQUIRY_RT_ID.substring(0,15);
    }    
    
    global String getJokeRT() {
        return CASE_JOKE_RT_ID.substring(0,15);
    }
    
    global String getThanksRT() {
        return CASE_THANKS_RT_ID.substring(0,15);
    }

}