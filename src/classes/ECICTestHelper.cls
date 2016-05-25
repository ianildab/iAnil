/**
     * @desccription  This class contains global test constants, helper methods to create different object for test's purposes.
     *                  every object type (exclude User object) has an 3 method:
     *                      .createItemName(parameters){create object with parametrized fields and return it WHITOUT INSETING to DB}
     *                      .createItemName(){ the wrapper fpr first method, which is pass defaults as a parameters }
     *                      .getItemName(){ the wrapper for first method, which is pass defaults as a parameters and return object AFTER
     *                      INSERTING to DB  }
     *  
     */
@isTest
public with sharing class ECICTestHelper
{
    public static  final User   TEST_RUN_USER                      = ECICRunUserTestHelper.create();  
    
    public static final String MASTER_DATA_INSERTION_MODE_SINGLE = 'Single';
    public static final String MASTER_DATA_INSERTION_MODE_MULTI = 'Multi';
    
    public static Account bottler;
    public static Account testSupplier;
    public static Region__c region;
    public static Region__c region2;
    public static Plant__c plant;
    public static Product__c product;
    public static Product__c productMonth;    
    public static Production_Line__c productionLine;
    public static Promotion__c promotion;
    public static Promotion_Type__c promotionType;
    public static Action_Plan__c actionPlan;
    public static Action_Plan_Item__c actionPlanItem;
    public static User testUser;
    public static List<Action_Plan__c> actionPlans;
    public static List<Action_Plan_Item__c> actionPlanItems;
    
// Master data which is initialized in MASTER_DATA_INSERTION_MODE_MULTI
    public static Map<String,Region__c> regionsByNames;
    public static List<Account> bottlers;
    public static List<Account> testSuppliers;
    public static List<Plant__c> plants;
    public static List<Product__c> products;
    public static List<Production_Line__c> productionLines;
    public static List<Promotion__c> promotions;
    public static List<Promotion_Type__c> promotionTypes;
    
    public static Integer AMOUT_OF_ACTION_PLAN_ITEMS = 4;
    public static List<String[]> actionPlanParams           = new List<String[]>
    { 
        new String[] { ECICCommonConstants.COUNTRY_CODE_SPAIN, ECICCommonConstants.CASE_ORIGIN_PHONE,           ECICCommonConstants.QUALITY_COMPLAINT_REASON_PRODUCTS, ECICCommonConstants.CASE_CATEGORY_LEVEL_3_PRODUCT_QUALITY_CARBONATION,    ECICCommonConstants.CASE_CATEGORY_LEVEL_4_PRODUCT_QUALITY_CARBONATION    },
        new String[] { ECICCommonConstants.COUNTRY_CODE_SPAIN, ECICCommonConstants.CASE_ORIGIN_EMAIL,           ECICCommonConstants.QUALITY_COMPLAINT_REASON_PRODUCTS, ECICCommonConstants.CASE_CATEGORY_LEVEL_3_PACKAGE_QUALITY_FILL_LEVEL,     ECICCommonConstants.CASE_CATEGORY_LEVEL_4_PACKAGE_QUALITY_FILL_LEVEL     },
        new String[] { ECICCommonConstants.COUNTRY_CODE_SPAIN, ECICCommonConstants.CASE_ORIGIN_COMMERCIAL_DEPT, ECICCommonConstants.QUALITY_COMPLAINT_REASON_PRODUCTS, ECICCommonConstants.CASE_CATEGORY_LEVEL_3_PRODUCT_QUALITY_FOREIGN_MATTER, ECICCommonConstants.CASE_CATEGORY_LEVEL_4_PRODUCT_QUALITY_FOREIGN_MATTER }
    };
    public static Map<Action_Plan__c, List<Action_Plan_Item__c>> actionPlanItemsByActionPlan;
    
    private static User                     currentUser = [SELECT Id, Country_Code__c FROM User WHERE Id = :UserInfo.getUserId()];

    // Often Required (Especially for Case-Related) Non-Setup Objects ---------------------------------------------------------------------------------------------------------------
    
    /**
    * @author           Pavel Slepenkov (Pavel_Slepenkov@epam.com).
    * @description      initialize test environment. This method SHOULD be involved in each testMethod
    * @param            masterDataMode define a @TODO
    */
    public static void initTestEnvironment(String masterDataMode) 
    {
       loadCustomSettings();
       //-------------------------------------- Master data objects insertion -----------------------------------------
       if      (masterDataMode == MASTER_DATA_INSERTION_MODE_SINGLE) { setupMasterDataInsertionModeSingle(); } 
       else if (masterDataMode == MASTER_DATA_INSERTION_MODE_MULTI)  { setupMasterDataInsertionModeMulti(); } 
       else { System.debug(LoggingLevel.ERROR ,'ECICTestHelper.initTestEnvironmentByUser::incorrect param masterDataMode'); }
       setupDummyPlantsLaboratory();        
    }

    /**
    * @author          Pavel Slepenkov (Pavel_Slepenkov@epam.com).
    * @date            13 Feb 2013
    * @description     The vrapper method for createTestUser() & initTestEnvironment() methods
    * @param           String masterDataMode define a mode of insertion Action Plan related objects
    * @param           String[] userParam - parameters for user creation: username, profileName, userRole, countryCode
    * @return          User which is owner of masterData objects & custom settings
    */
    public static User initTestEnvironmentByUser(String masterDataMode, String[] userParam) 
    {
        return initTestEnvironmentByUser(masterDataMode, createTestUser(userParam[0], userParam[1], userParam[2], userParam[3]));
    }

    public static User initTestEnvironmentByUser(String masterDataMode, User user) 
    {
        System.runAs(user) { initTestEnvironment(masterDataMode); }
        return user;
    }


    private static void setupMasterDataInsertionModeSingle()
    {
            region = createRegion(ECICCommonConstants.TEST_CITY_STATE_AND_REGION);
            region2 = createRegion(ECICCommonConstants.REGION_2_NAME);
            insert new List<Region__c> { region, region2 };
        
            bottler = ECICAccountTestHelper.createBottler();
            insert bottler;
        
            region.bottler__c =  bottler.Id;
            region2.bottler__c =  bottler.Id;
            update new List<Region__c> { region, region2 };
                    
            plant = getPlant();
            plant.Bottler__c = bottler.Id;
            update plant;
            
            product = getProduct();
            productMonth = getProductMonth();
            productionLine = getProductionLine();
    }
    
    private static void setupMasterDataInsertionModeMulti()
    {
            String[] regionNames = new String[]{ '', '', '', '' };
            prepopulateRegions(regionNames);
            Account tmpAccount;
            for (String regionName : regionNames) 
            {
                tmpAccount = ECICAccountTestHelper.createAccount(regionName, ECICCommonConstants.ACCOUNT_TYPE_BOTTLER);
                tmpAccount.ShippingState = regionName;
                bottlers.add(tmpAccount);
            }
            insert bottlers;
            updateRegions();
            
            testSuppliers = new List<Account>();
            plants = new List<Plant__c>();
            products = new List<Product__c>();
            productionLines = new List<Production_Line__c>();
            promotions = new List<Promotion__c>();
            promotionTypes = new List<Promotion_Type__c>();
    }

    private static void setupDummyPlantsLaboratory()
    {
        Account plantsLaboratory = ECICAccountTestHelper.createLaboratory();
        plantsLaboratory.Name = 'Plant\'s Laboratory';
        plantsLaboratory.Account_Ext_Id__c = 'ES_PLANTS_LABORATORY';
        insert plantsLaboratory;        
    }

    // Custom Settings (Setup Objects!) ---------------------------------------------------------------------------------------------------------------
    
    /**
    * @author       Pavel Slepenkov (Pavel_Slepenkov@epam.com)
    * @date         22 Feb 2013
    * @description  dedicated from initTestEnvironment(). Create custom settings which will used during tests
    * @param        
    * @return       
    */
    public static void loadCustomSettings()                                         //TODO: Check all custom settings & to add if something else needed
    {
        System.runAs(TEST_RUN_USER)
        {
    		TEST_DummyCountrySpecificSettingsFactory.setupDummyCountrySpecificSettings(currentUser.Country_Code__c); 
            setupDummyPCDaySymbolESN();
    		TEST_DummyGeneralSettingsFactory.create(true);
            TEST_DummyProfileMappingFactory.createDefaultList(TEST_DummyInsertModeEnum.REAL); 
            setupDummyCaseRecordType();
  			TEST_DummyUserLookupMappingFactory.createDefaultList(currentUser.Country_Code__c, TEST_DummyInsertModeEnum.REAL);
        }
    }
    
    private static void setupDummyPCDaySymbolESN()
    {
        List<PC_Day_Symbol_ESN__c> ListPCDaySymbolESN = new List<PC_Day_Symbol_ESN__c>();
        String[] pcDSE = new String[]{'A','C','D','E','F','G','H','J','K','M','N','P','Q','R','S','T','U','V','W','X','Y','2','3','4','5','6','7','8','9','0','1'}; // It's correct that 'B' is absent
        for (Integer i = 0; i < pcDSE.size(); i++) 
        {
            PC_Day_Symbol_ESN__c PCDaySymbolESN = new PC_Day_Symbol_ESN__c();
            PCDaySymbolESN.Name = pcDSE[i];
            PCDaySymbolESN.Day__c = String.valueOf(i);
            ListPCDaySymbolESN.add(PCDaySymbolESN);
        }
        insert ListPCDaySymbolESN;
    }

    private static void setupDummyCaseRecordType()
    {
        Map<String, Schema.RecordTypeInfo> infos = Schema.SObjectType.Case.getRecordTypeInfosByName();
        CaseRecordType__c crt = new CaseRecordType__c();
        crt.JOKE_RECORD_TYPE_ID__c                  = infos.get(ECICCommonConstants.JOKE_USELESS).getRecordTypeId();
        crt.NON_QUALITY_COMPLAINT_RECORD_TYPE_ID__c = infos.get(ECICCommonConstants.NON_QUALITY_COMPLAINT).getRecordTypeId();
        crt.INQUIRY_RECORD_TYPE_ID__c               = infos.get(ECICCommonConstants.INQUIRY).getRecordTypeId();
        crt.THANKS_RECORD_TYPE_ID__c                = infos.get(ECICCommonConstants.THANKS).getRecordTypeId();
        insert crt;
    }
    
    // -----------------------------------------------------------------------------------------------------------------------------------------
    
    /**
    * @author          Pavel Slepenkov (Pavel_Slepenkov@epam.com).
    * @date            13 Feb 2013
    * @description     Reset all static Boolean fields in trigger helpers. Sometime we need to imitate a user behavior when
    *                  he create some instance as precondition and one instance as target test instance, e.g. Case trending,
    *                  We need one existing Case record with some same fields as a testing Case record, and we should to 
    *                  create it in the one test method, but Boolean variables which is reseted in this method is static and
    *                  for second instance will have incorrect values, therefore we should to reset it.  
    */
    public static void resetTestEnvironment() 
    {
         ECICCaseHelper.caseTriggerToRun         = true;
         ECICCaseHelper.CASE_BEFORETRIGGER_TORUN = true;
         ECICCaseHelper.CASE_AFTERTRIGGER_TORUN = true;
         
         ECICActionPlanHelper.AP_CREATION_HASRUN = false;
         ECICActionPlanHelper.APT_CREATION_HASRUN = false;
    }  
    
//-------------------------------------- Objects creation methods ------------------------------------------------------

    public static Contact createContact() {
        Account account = ECICAccountTestHelper.createAccount();        
        Contact testContact = new Contact(firstname = ECICCommonConstants.CONTACT_FIRSTNAME,
                                            lastname       = ECICCommonConstants.CONTACT_LASTNAME,
                                            email          = ECICCommonConstants.EMAIL,
                                            phone          = ECICCommonConstants.PHONE,
                                            accountId      = account.Id,
                                            MailingCity    = ECICCommonConstants.TEST_CITY_STATE_AND_REGION,
                                            MailingCountry = ECICCommonConstants.TEST_COUNTRY);
        insert testContact;
        testContact = [SELECT Id, firstname, lastname, email, phone, AccountId FROM Contact WHERE firstname =: ECICCommonConstants.CONTACT_FIRSTNAME][0];
        System.debug( Logginglevel.FINEST , 'ECICTestHelper.createContact() created object::' + testContact);
        return testContact;
    }   

//-------------------------------------Master Data Objects Helper Method -----------------------------------------------
    public static Region__c createRegion(String regionName) {
        Region__c testRegion = new Region__c(name   = regionName,
                Bottler_Quality__c                  = UserInfo.getUserId(),
                Bottler_Quality_Manager__c          = UserInfo.getUserId(),
                Bottler_External_Relations__c       = UserInfo.getUserId()
                );
        return testRegion;
    }
    
    public static Region__c getRegion(String regionName, ID bottlerId) 
    {
        Region__c testRegion = new Region__c(
                name                                = regionName,
                Bottler_Quality__c                  = bottlerId,
                Bottler_Quality_Manager__c          = bottlerId,
                Bottler_External_Relations__c       = bottlerId,
                bottler__c                          = ECICAccountTestHelper.createBottler().Id
                );
        insert testRegion;
        return [SELECT Id, Name, Bottler__c, Bottler_Quality__c, Bottler_Quality_Manager__c, Bottler_External_Relations__c FROM Region__c  WHERE Id = :testRegion.Id][0];
    }

    public static Region__c getRegion(String regionName) { return getRegion(regionName, null); }
    
    /**
    * @author        Pavel Slepenkov (Pavel_Slepenkov@epam.com)
    * @date          22 Feb 2013
    * @description    
    */
    private static void prepopulateRegions(String[] regionsNames) 
    {
        if (regionsByNames == null || regionsByNames.isEmpty()) 
        {
            List<Region__c> tmpRegions = new List<Region__c>();
            for (String regionName: regionsNames) 
            {
                Region__c  tmpReg = createRegion(regionName);
                regionsByNames.put(regionName, tmpReg);
                tmpRegions.add(tmpReg);
            }
            insert tmpRegions;
        }
    }
    
    /**
    * @author       Pavel Slepenkov (Pavel_Slepenkov@epam.com)
    * @date         22 Feb 2013
    * @description  
    */
    private static void updateRegions() 
    {
        if (!regionsByNames.isEmpty() || regionsByNames != null) 
        {
            List<Region__c> regs = new List<Region__c>();
            for (Account a : bottlers) 
            {
                Region__c  tmpRegion = regionsByNames.get(a.Name);
                tmpRegion.bottler__c = a.Id;
                regs.add(tmpRegion);
            }
            update regs;
        }
    }
    
//----------------------------------------------------------------------------------------------------------------------    

    public static Promotion__c createPromotion() 
    {
        return new Promotion__c( Name = ECICCommonConstants.TEST_PROMOTION, Active__c = true, Description__c = ECICCommonConstants.TEST_PROMOTION );
    }
    
    public static Promotion_Type__c createPromotionType()  { return new Promotion_Type__c( Name = ECICCommonConstants.TEST_PROMOTION ); }
    
    public static Competitor_Product__c createCompetitorProduct()  { return new Competitor_Product__c( Name = ECICCommonConstants.TEST_COMPETITOR_PRODUCT, Active__c = true ); }
    
    public static Plant__c createPlant()  { return new Plant__c(Name = ECICCommonConstants.TEST_PLANT, Active__c = true ); }
    
    public static Plant__c getPlant() 
    {
        if (plant != null) { return plant; } 
        else 
        {
            plant = createPlant();
            insert plant;
        }
        return [SELECT Id, Name, Active__c FROM Plant__c WHERE Id =:plant.Id];
    }


//----------------------------------------------------------------------------------------------------------------------    

    public static Product__c createProduct(String name, Integer shelfLife, String unit) 
    {
        return new Product__c( 
                            Name                    = name,
                            Flavour__c = ECICCommonConstants.PRODUCT_FLAVOUR_DEFAULT,
                            Active__c = true,
                            Currently_Sold__c = true,
                            Shelf_Life__c = shelfLife,
                            Unit__c = unit,
                            Type__c = ECICCommonConstants.PRODUCT_TYPE_DEFAULT,
                            Size__c = ECICCommonConstants.PRODUCT_SIZE_DEFAULT,
                            Packaging__c = ECICCommonConstants.PRODUCT_PACKAGING_DEFAULT,
                            Product_Unit_Price__c = ECICCommonConstants.PRODUCT_UNIT_PRICE_DEFAULT
                            );
    }
    
    public static Product__c createProduct()  { return createProduct( ECICCommonConstants.PRODUCT_NAME_DEFAULT, ECICCommonConstants.PRODUCT_SHELF_LIFE_DEFAULT, ECICCommonConstants.PRODUCT_UNIT_DEFAULT); }

    private static Product__c insertAndSelectProduct(Product__c tmpProduct)
    {
        insert tmpProduct;
        return [SELECT Id, Name, Active__c, Shelf_Life__c, Unit__c, Type__c, Size__c, Packaging__c FROM Product__c WHERE id =: tmpProduct.Id];
    }
    
    public static Product__c getProduct()      { return insertAndSelectProduct(createProduct()); }
    public static Product__c getProductMonth() { return insertAndSelectProduct(createProduct( ECICCommonConstants.PRODUCT_NAME_DEFAULT, ECICCommonConstants.PRODUCT_SHELF_LIFE_DEFAULT, ECICCommonConstants.PRODUCT_UNIT_MONTH)); }
    
    public static Production_Line__c createProductionLine(Id dummyPlantId)                { return new Production_Line__c(plant__c = dummyPlantId, Name = ECICCommonConstants.TEST_PRODUCTION_LINE_NAME); }
    public static Production_Line__c createProductionLine(Plant__c tmpPlant)              { return createProductionLine(tmpPlant.id); }
    public static Production_Line__c createProductionLine(Plant__c tmpPlant, String name) { return new Production_Line__c(plant__c = tmpPlant.id, Name = name); }

    private static Production_Line__c insertAndSelectProductionLine (Production_Line__c prodLine)
    {
        insert prodLine;
        return [SELECT  Production_Line_Name__c, Plant__c, Name, Country_Code__c, Active__c, Id FROM Production_Line__c WHERE Id =: prodLine.Id];
    }

    public static Production_Line__c getProductionLine()                                   { return insertAndSelectProductionLine (createProductionLine(getPlant())); }
    public static Production_Line__c getSpecProductionLine(Plant__C tmpPlant, String name) { return insertAndSelectProductionLine (createProductionLine(tmpPlant, name)); }
        
    public static Task createTask() 
    {
        return new Task(Subject = 'test subject', Priority = 'High', Status = 'Not Started', OwnerId = UserInfo.getUserId(), International_Name__c = 'International Name' );
    }
    
    public static Task createTask(sObject s) 
    {
        Task t = createTask();
        t.WhatId = s.Id;
        return t;
    }
    
    //---------------------------------Trend Helper Method-------------------------------------------------------------
    
    public static Trend__c createTrend() 
    {
        Plant__c tmpPlant = createPlant();                          insert tmpPlant;
        Product__c p = createProduct();                             insert p;
        Production_Line__c pL = createProductionLine(tmpPlant);     insert pL;
                    
        return new Trend__c(
                Name                = 'testTrend',
                Production_LIne__c = pL.Id,
                Product__c = p.Id,
                bbe_date__c = System.today(),
                Country_Code__c = 'ES'
                );
    }
        
    //---------------------------------Action Plan + Action Plan Item methods------------------------------------------
    
    /**
    * @author       Pavel Slepenkov (Pavel_Slepenkov@epam.com)
    * @date         18 Feb 2013
    * @description  
    */
    public static Map<Action_Plan__c, List<Action_Plan_Item__c>> initializeActionPlanFramework() 
    {
        actionPlans = createActionPlans(actionPlanParams);
        insert actionPlans;

        List<Action_Plan_Item__c> allAPIs = new List<Action_Plan_Item__c>();
        actionPlanItemsByActionPlan = new Map<Action_Plan__c, List<Action_Plan_Item__c>>();
        
        for (Action_Plan__c ap: actionPlans) 
        {
            List<Action_Plan_Item__c> tmpAPIs = new List<Action_Plan_Item__c>();
            for (Integer i = 0; i < AMOUT_OF_ACTION_PLAN_ITEMS; i++) 
            {
                Action_Plan_Item__c api = createActionPlanItem();
                api.Action_Plan__c = ap.Id;
                api.Item_Unique_Name__c = ap.Name + i;
                api.International_Name__c = ap.International_Name__c + i;
                tmpAPIs.add(api);
            }
            allAPIs.addAll(tmpAPIs);
            actionPlanItemsByActionPlan.put(ap, tmpAPIs);
        }
        insert allAPIs;
        return actionPlanItemsByActionPlan;
    }
    
    public static Action_Plan__c createActionPlan(String[] actionPlanParam) 
    {
        return new Action_Plan__c( Name = actionPlanParam[0],
                Unique_Name__c          = actionPlanParam[1],
                Rank__c                 = Integer.valueOf(actionPlanParam[2]),
                //Country_Code__c       = actionPlanParam[3],
                Case_Channel__c         = actionPlanParam[4],
                Case_Reason__c          = actionPlanParam[5],
                Active__c               = true,
                Category_Level3__c      = actionPlanParam[6],
                Category_Level4__c      = actionPlanParam[7],
                International_Name__c   = 'International Name',
                Country_Code__c         = 'ES');
    }
    
    /**
    * @author       Pavel Slepenkov (Pavel_Slepenkov@epam.com)
    * @date         21 Feb 2013
    * @description  create Action Plan with specified rank
    */
    public static Action_Plan__c createaActionPlan(String[] params, Integer rank) 
    {
         String name = generateUniqueName(params, 80);
         return new Action_Plan__c( Name = name,
                                    Unique_Name__c          = name + String.valueOf((Integer)ECICTestHelperAddon.getUniqueRandom() * 1000),
                                    Rank__c                 = rank,
                                    Country_Code__c         = params[0],
                                    Case_Channel__c         = params[1],
                                    Case_Reason__c          = params[2],
                                    Active__c               = true,
                                    Category_Level3__c      = params[3],
                                    Category_Level4__c      = params[4],
                                    International_Name__c   = name
                                  );
    }

    /**
    * @author       Pavel Slepenkov (Pavel_Slepenkov@epam.com)
    * @date         18 Feb 2013
    * @description  
    * @param        
    * @return       
    */
    public static List<Action_Plan__c> createActionPlans(List<String[]> args) {
        List<Action_Plan__c> results = new List<Action_Plan__c>();
        Integer rankCounter = args.size();
        for (String[] params: args) {
            String name = params[0] + '_' + params[1] + '_' + params[3]; // Name + Unique Name: e.g. ES_Phone_Product
            results.add(new Action_Plan__c( Name                  = name, 
                                            Unique_Name__c        = name + String.valueOf((Integer)ECICTestHelperAddon.getUniqueRandom() * 1000),
                                            Rank__c               = rankCounter--,
                                            Country_Code__c       = params[0],
                                            Case_Channel__c       = params[1],
                                            Case_Reason__c        = params[2],
                                            Category_Level3__c    = params[3],
                                            Category_Level4__c    = params[4],
                                            International_Name__c = name,
                                            Active__c             = true
            )); 
        }
        return results;
    }
    
    public static Action_Plan__c createActionPlan() { return createActionPlan(ECICCommonConstants.ACTION_PLAN_PARAM_1); }

    public static Action_Plan__c getActionPlan() {
        Action_Plan__c tmpActionPlan = createActionPlan(ECICCommonConstants.ACTION_PLAN_PARAM_1);
        insert tmpActionPlan;
        return tmpActionPlan;
    }
    
    public static List<Action_Plan__c> createActionPlans() {
        return new Action_Plan__c[]{
                createActionPlan(ECICCommonConstants.ACTION_PLAN_PARAM_1),
                createActionPlan(ECICCommonConstants.ACTION_PLAN_PARAM_2),
                createActionPlan(ECICCommonConstants.ACTION_PLAN_PARAM_3)
        };
    }
    
    public static Action_Plan_Item__c createActionPlanItem(String[] actionPlanItemParam) {
        return new Action_Plan_Item__c( Name = actionPlanItemParam[0],
                Item_Unique_Name__c = actionPlanItemParam[1],
                Task_Number__c = Integer.valueOf(actionPlanItemParam[2]),
                Active__c = true,
                ActivityDate__c = System.Today(),
                Mode__c = actionPlanItemParam[4],
                Priority__c = actionPlanItemParam[5],
                Type__c  = actionPlanItemParam[6],
                International_Name__c = 'International Name',
                International_Description__c = 'International Description',
                Assignee__c = 'OwnerId');
    }
    
    public static Action_Plan_Item__c createActionPlanItem() {
        return createActionPlanItem(ECICCommonConstants.ACTION_PLAN_ITEM_PARAM_1);
    }

    public static Action_Plan_Item__c getActionPlanItem() {
        Action_Plan_Item__c tmpActionPlanItem  = createActionPlanItem(ECICCommonConstants.ACTION_PLAN_ITEM_PARAM_1);
        insert tmpActionPlanItem;
        return tmpActionPlanItem;
    }
    
    public static List<Action_Plan_Item__c> createActionPlanItems() {
        return new Action_Plan_Item__c[]{  
                    createActionPlanItem(ECICCommonConstants.ACTION_PLAN_ITEM_PARAM_1),
                    createActionPlanItem(ECICCommonConstants.ACTION_PLAN_ITEM_PARAM_2),
                    createActionPlanItem(ECICCommonConstants.ACTION_PLAN_ITEM_PARAM_3)
                };
    } 
    
    public static AP_Task_Condition__c createAPTaskEqualsCondition(String fieldName, String value) {
        return new AP_Task_Condition__c(Field_Name__c = fieldName, Operator__c = 'equals', Values__c = value);
    }
    
    public static AP_Task_Condition__c createAPTaskNotEqualsCondition(String fieldName, String value) {
        return new AP_Task_Condition__c(Field_Name__c = fieldName, Operator__c = 'not equals', Values__c = value);
    }
    
    //--------------------------------- Users Method--------------------------------------------------------------------

    public static User createTestUser(String username, String profileName, String userRole, String countryCode, Boolean insertNow)
    {
        testUser = null;
        try 
        { 
        	testUser = ECICRunUserTestHelper.create( username, 
        				SEPProfileCache.getProfilesByNameMap().get(profileName).id, SEPUserRoleCache.getUserRolesByDevNameMap().get(userRole).id, 
        				countryCode,  insertNow ); 
        }
        catch(System.QueryException qEx) { System.debug(loggingLevel.ERROR, 'ECICTestHelper.createTestUser:' + qEx); }
        return testUser;
    	
    } 

    public static User createTestUser(String username, String profileName, String userRole, String countryCode) { return createTestUser(username, 			   profileName, 		  userRole, 						countryCode, 			true); 		}
    public static User createTestUser(String profileName)  					 									{ return createTestUser(profileName, 		   profileName, 		  ECICCommonConstants.ROLE_DEFAULT, null, 					true);      }
    public static User createTestUser(String profileName, Boolean insertNow) 									{ return createTestUser(profileName, 		   profileName, 		  ECICCommonConstants.ROLE_DEFAULT, null, 					insertNow); }
    public static User createTestUser(String[] userParameterArray)  											{ return createTestUser(userParameterArray[0], userParameterArray[1], userParameterArray[2], 			userParameterArray[3], 	true); 		}
    public static User createTestUser(String[] userParameterArray, Boolean insertNow) 							{ return createTestUser(userParameterArray[0], userParameterArray[1], userParameterArray[2], 			userParameterArray[3], 	insertNow); }
    
    /**
    * @author       Pavel Slepenkov (Pavel_Slepenkov@epam.com)
    * @date         19 Feb 2013
    * @description  
    * @param        String[] args - argunents for generating name
    * @param        Integer maxLength - maximul length of fields where unique name will used
    */
    public static String generateUniqueName(String[] args, Integer maxLength) 
    {
        String result = '';
        for (Integer i = 0; i < args.size(); i++) 
        {
          result += ((args[i]) + '_');
          if (result.length() >= (maxLength - 5)) 
          {
            return (result.substring(maxLength - 5) + (Integer)(ECICTestHelperAddon.getUniqueRandom() * 10000) );
          }
        }
        return result;
    }
    
    /**
    * @author       Pavel Slepenkov (Pavel_Slepenkov@epam.com)
    * @date         26 Feb 2013
    * @description  The simplified wrapper for generateUniqueName()
    */
    public static String generateUniqueName(String name) {
        return generateUniqueName(new String[]{name} ,ECICCommonConstants.DEFAULT_NAME_FIELD_LENGTH);
    }
    
    /**
    * @author       Pavel Slepenkov (Pavel_Slepenkov@epam.com)
    * @date         26 Feb 2013
    * @description  The specified email wrapper for generateUniquename
    */
    public static String generateUniqueEmail(String name) {
        return generateUniqueName(new String[]{name} ,ECICCommonConstants.DEFAULT_NAME_FIELD_LENGTH) + '@test.test';
    }
    

    
}