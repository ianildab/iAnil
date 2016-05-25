@isTest
public class ECICCaseTestHelper {

	public static  final User 						TEST_RUN_USER 			= ECICRunUserTestHelper.create();  

	public class CaseConfig
	{
		public Id			  recordTypeId				    = null;
		public String		  type							= null;
		public String  		  reason                        = null;
		public String 		  categoryLevel3			    = null;
		public String 		  categoryLevel4			    = null;
		public String		  name						    = null;
		public String  		  countryCode                   = null;
		public String  		  subject                       = null;
		public String  		  description                   = null;
		public String  		  analystLabManagerComments     = null;
		public String  		  origin                        = null;
		public String  		  priority                      = null;
		public String  		  processType                   = null;
		public Id			  actionPlanId 			        = null;
		public Id 			  packageSupplierId    	        = null;
		public String		  packageBatch	    	        = null;
		public Id 			  plantId 		    	        = null;
		public Id 			  pointOfSaleId	    	        = null;
		public Id 			  pointOfSaleKeyAccountId       = null;
	    public Id 			  productId	  			        = null;
	    public Id 	  		  productionLineId		        = null;
	    public String  		  productionCode    	        = null;
	    public Id	  		  regionOfPurchaseId            = null;
		public Id			  bottlerId   		  	        = null;
		public Id			  bottlerExternalRelationsId    = null;
		public String		  bottlerName 			        = null;
		public Id			  bottlerQualityManagerId       = null;
		public Id			  bottlerQualityOwnerId         = null;
		public Id			  distributorEternalRelationsId = null;
		public Id			  distributorQualityId		    = null;
		public Id			  distributorQualityManagerId   = null;
		public Id			  ownerId					    = null;
		public Id			  contactId					    = null;
		public Id			  serviceManagerId			    = null;
		public String 		  status 	 			        = null; 	
		public String 		  infolineStatus 	 	        = null; 	
		public String 		  qualityStatus 	 	        = null; 	
	    public Boolean 		  noQualityStatusChange         = null;
	    public Date    		  bbeDate             	        = null;
	    public String		  suppliedEmail					= null;
	    public Integer		  numberOfPacks					= null;
	    public Double	 	  productUnitPrice				= null;
	    public String		  potentialRisk				    = null;
	    public String		  riskType					    = null;
	    public Boolean		  imcrIssue					    = null;
	    public String         channelOfAnswer				= null;
		public String		  sysomosHbWebUrl			    = null;
	    public Boolean		  sampleCollected			    = null;
	    public Date			  createdDate					= null;

		public CaseConfig () {} 
		public CaseConfig (String status) { this.status = status; } 
		public CaseConfig (Action_Plan__c actionPlan) { this.actionPlanId = actionPlan.id; } 
		public CaseConfig (String status, Action_Plan__c actionPlan) { this.status = status; this.actionPlanId = actionPlan.id; } 
	}

    public static Case createDummyCase (
	    							String caseOrigin, String caseReason, String caseCatLevel3, String caseCatLevel4,
	    							String apChannel,  String apReason,   String apCatLevel3,   String apCatLevel4,
	    							Boolean insertNow 
    							)
    { 
    	Action_Plan__c actionPlan = ECICActionPlanTestHelper.createDummyActionPlan(true);
    				   actionPlan.Case_Channel__c = apChannel;
			  		   actionPlan.Case_Reason__c = apReason;
			  		   actionPlan.Category_Level3__c = apCatLevel3;
			  		   actionPlan.Category_Level4__c = apCatLevel4;
    			update actionPlan;
    				   
    	Case dummyCase = createDummyCase(new CaseConfig(actionPlan));
	  			 dummyCase.Country_Code__c = 'UK';
	    		 dummyCase.Origin = caseOrigin;
	  			 dummyCase.Reason = caseReason;
	  			 dummyCase.Category_Level3__c = caseCatLevel3;
	  			 dummyCase.Category_Level4__c = caseCatLevel4;
		
		if (insertNow) { insert dummyCase; }	  			 
	  	return dummyCase;
    }

    public static Case createDummyCase (
	    							String caseOrigin, String caseReason, String caseCatLevel3, String caseCatLevel4,
	    							String apChannel,  String apReason,   String apCatLevel3,   String apCatLevel4
    							)
   	{
		return createDummyCase (caseOrigin, caseReason, caseCatLevel3, caseCatLevel4, apChannel,  apReason,   apCatLevel3,   apCatLevel4, false);
   	} 

	
	public static Case createDummyCase(CaseConfig config, Boolean insertNow)
    {
	   	config.countryCode = TEST_ConfigHelper.chooseValue(config.countryCode, 	'GB');

    	if (Country_Specific_Settings__c.getValues(config.countryCode) == null)
    	{
    		TEST_DummyCountrySpecificSettingsFactory.create(new TEST_DummyCountrySpecificSettingsFactory.Config(config.countryCode), true);
    	}
    	
    	TEST_UniqueHelper unique = new TEST_UniqueHelper('Dummy Case'); 

    	if (config.packageSupplierId       == null) { config.packageSupplierId  	 = insertAccountAndReturnId(ECICAccountTestHelper.createSupplier()); 		}
    	if (config.pointOfSaleId           == null) { config.pointOfSaleId 			 = insertAccountAndReturnId(ECICAccountTestHelper.createPointOfSale()); 	}
    	if (config.pointOfSaleKeyAccountId == null) { config.pointOfSaleKeyAccountId = insertAccountAndReturnId(ECICAccountTestHelper.createPoSKeyAccount());   }
    	if (config.regionOfPurchaseId      == null) { Region__c region = ECICTestHelper.createRegion(ECICCommonConstants.TEST_CITY_STATE_AND_REGION); insert region;  config.regionOfPurchaseId = region.id; 	}
    	if (config.plantId                 == null) { Plant__c dummyPlant = ECICTestHelper.createPlant(); dummyPlant.region__c = config.regionOfPurchaseId; Account bottler = ECICAccountTestHelper.createBottler(); insert bottler; dummyPlant.Bottler__c = bottler.Id; insert   dummyPlant; config.plantId = dummyPlant.id; }
    	if (config.productId			   == null) { Product__c dummyProduct = ECICTestHelper.createProduct(); insert dummyProduct; config.productId = dummyProduct.Id; }
		if (config.productionLineId        == null) { Production_Line__c dummyProductionLine = ECICTestHelper.createProductionLine(config.plantId); insert dummyProductionLine; config.productionLineId = dummyProductionLine.Id; }
    	
	  	Case   dummyCase = createCase();	
			   dummyCase.Country_Code__c                    = config.countryCode;
			   dummyCase.Package_Supplier__c                = config.packageSupplierId;
			   dummyCase.Point_of_Sale__c                   = config.pointOfSaleId;
			   dummyCase.PoS_Key_Account__c                 = config.pointOfSaleKeyAccountId;
			   dummyCase.Region_Of_Purchase__c              = config.regionOfPurchaseId;
          	   dummyCase.Plant__c                           = config.plantId;
               dummyCase.Product__c                         = config.productId;
               dummyCase.Production_Line__c 		        = config.productionLineId;
               //#Ecic Template Test
			   dummyCase.RecordTypeId                       = TEST_ConfigHelper.chooseValue(config.recordTypeId,					Schema.SObjectType.Case.getRecordTypeInfosByName().get(ECICCommonConstants.INQUIRY_IBERIA_RTNAME).getRecordTypeId());
			   dummyCase.type				                = TEST_ConfigHelper.chooseValue(config.type,							null);
			   dummyCase.Reason                             = TEST_ConfigHelper.chooseValue(config.reason, 							ECICCommonConstants.QUALITY_COMPLAINT_REASON_PRODUCTS);
			   dummyCase.Category_Level3__c                 = TEST_ConfigHelper.chooseValue(config.categoryLevel3,					null);
			   dummyCase.Category_Level4__c                 = TEST_ConfigHelper.chooseValue(config.categoryLevel4,	 				null);
			   dummyCase.Subject                            = TEST_ConfigHelper.chooseValue(config.subject, 						ECICCommonConstants.CASE_SUBJECT);
	  		   dummyCase.Status 	                        = TEST_ConfigHelper.chooseValue(config.status, 							ECICCommonConstants.STATUS_NEW);
	  		   dummyCase.Infoline_Status__c                 = TEST_ConfigHelper.chooseValue(config.infolineStatus, 					ECICCommonConstants.STATUS_OPEN);
	  		   dummyCase.Bottler__c		                    = TEST_ConfigHelper.chooseValue(config.bottlerId,	 					ECICAccountTestHelper.getBottler().Id);
			   dummyCase.Origin                             = TEST_ConfigHelper.chooseValue(config.origin, 							ECICCommonConstants.CASE_ORIGIN);
          	   dummyCase.Production_Code__c                 = TEST_ConfigHelper.chooseValue(config.productionCode, 					ECICCommonConstants.TEST_PRODUCTION_LINE_NAME);
			   dummyCase.Priority                           = TEST_ConfigHelper.chooseValue(config.priority,						ECICCommonConstants.CASE_PRIORITY);
               dummyCase.No_Quality_Status_Change__c        = TEST_ConfigHelper.chooseValue(config.noQualityStatusChange, 			true);		  	 	   
	  		   dummyCase.Quality_Status__c                  = TEST_ConfigHelper.chooseValue(config.qualityStatus, 					'New complaint');
			   dummyCase.Package_Batch__c                   = TEST_ConfigHelper.chooseValue(config.packageBatch, 					'test');
			   dummyCase.Process_Type__c                    = TEST_ConfigHelper.chooseValue(config.processType,			  			'TIPO 2.5');
               dummyCase.BBE_Date__c                        = TEST_ConfigHelper.chooseValue(config.bbeDate, 						System.today());
			   dummyCase.Description                        = TEST_ConfigHelper.chooseValue(config.description, 					unique.uniqueSpaceless + 'Description');
			   dummyCase.Comments_of_analyst_lab_manager__c = TEST_ConfigHelper.chooseValue(config.analystLabManagerComments,	 	null);
	  		   dummyCase.Action_Plan__c                     = TEST_ConfigHelper.chooseValue(config.actionPlanId, 					(Id) null);
	  		   dummyCase.Bottler_External_Relations__c		= TEST_ConfigHelper.chooseValue(config.bottlerExternalRelationsId,		(Id) null);
	  		   dummyCase.Bottler_Name__c		            = TEST_ConfigHelper.chooseValue(config.bottlerName,	 					null);
	  		   dummyCase.Bottler_Quality_Manager__c		    = TEST_ConfigHelper.chooseValue(config.bottlerQualityManagerId,			(Id) null);
	  		   dummyCase.Bottler_Quality_Owner__c		    = TEST_ConfigHelper.chooseValue(config.bottlerQualityOwnerId,			(Id) null);
	  		   dummyCase.Distributor_External_Relations__c	= TEST_ConfigHelper.chooseValue(config.distributorEternalRelationsId,	(Id) null);
	  		   dummyCase.Distributor_Quality__c		        = TEST_ConfigHelper.chooseValue(config.distributorQualityId,	 		(Id) null);
	  		   dummyCase.Distributor_Quality_Manager__c		= TEST_ConfigHelper.chooseValue(config.distributorQualityManagerId,		(Id) null);
               dummyCase.SuppliedEmail                      = TEST_ConfigHelper.chooseValue(config.suppliedEmail,					null);
	  		   dummyCase.ContactId					        = TEST_ConfigHelper.chooseValue(config.contactId,				 		(Id) null);
	  		   dummyCase.Service_Manager__c			        = TEST_ConfigHelper.chooseValue(config.serviceManagerId,	 			(Id) null);
	  		   dummyCase.No_of_Packs__c						= TEST_ConfigHelper.chooseValue(config.numberOfPacks,			 		null);
	  		   dummyCase.Product_Unit_Price__c				= TEST_ConfigHelper.chooseValue(config.productUnitPrice,		 		null);
			   dummyCase.Potential_Risk__c					= TEST_ConfigHelper.chooseValue(config.potentialRisk,		 			'No Risk');
			   dummyCase.Risk_Type__c						= TEST_ConfigHelper.chooseValue(config.riskType,			 			''); // Intentional non-null!
			   dummyCase.IMCR_Issue__c						= TEST_ConfigHelper.chooseValue(config.imcrIssue,	 					false);
			   dummyCase.channel_of_answer__c				= TEST_ConfigHelper.chooseValue(config.channelOfAnswer,					null);
			   dummyCase.Sample_Collected__c				= TEST_ConfigHelper.chooseValue(config.sampleCollected,					false);
			   dummyCase.sysomosHB__web_url__c				= TEST_ConfigHelper.chooseValue(config.sysomosHbWebUrl,					null);
               dummyCase.createdDate                        = TEST_ConfigHelper.chooseValue(config.createdDate, 					null);
	  		   if (config.ownerId != null) { dummyCase.OwnerId = config.ownerId; } 
		  	if (insertNow) { insert dummyCase; }
		  	return dummyCase;
	}


	public static Case createDummyCase(
											CaseConfig config,
											ECICCaseAccountTestHelper caseAccountHelper, ECICCaseRegionTestHelper caseRegionHelper,
											Plant__c dummyBottlerPlant, Production_Line__c dummyProductionLine,
											Map<String, User> originalAssignedUserMap, String[] fieldsToTestArray,
											Boolean insertNow
										)
	{
		Action_Plan__c 		dummyActionPlan 	   = ECICActionPlanTestHelper.createEmptyDummyActionPlan(false); 
							dummyActionPlan.Name   = ECICCommonConstants.QUALITY_COMPLAINT;
							dummyActionPlan.case_reason__c = ECICCommonConstants.QUALITY_COMPLAINT_REASON_PRODUCTS;
		if (config.countryCode != null) 
		{ 
							dummyActionPlan.country_code__c = config.countryCode;
		}
					 insert dummyActionPlan;  
				
		ECICActionPlanItemTestHelper.createDummyActionPlanItemList(dummyActionPlan, fieldsToTestArray);
		
				   config.status				  = ECICCommonConstants.STATUS_OPEN;
				   config.actionPlanId			  = dummyActionPlan.id;				
				   config.reason			   	  = ECICCommonConstants.QUALITY_COMPLAINT_REASON_PRODUCTS;
				   config.pointOfSaleId			  = caseAccountHelper.DUMMY_POINT_OF_SALE_ACCOUNT.id;
				   config.pointOfSaleKeyAccountId = caseAccountHelper.DUMMY_POINT_OF_SALE_KEY_ACCOUNT.id;
				   config.packageSupplierId 	  = caseAccountHelper.DUMMY_SUPPLIER_ACCOUNT.id;
				   config.bottlerId				  = caseAccountHelper.DUMMY_BOTTLER_ACCOUNT.id;
				   config.regionOfPurchaseId	  = caseRegionHelper.DUMMY_DISTRIBUTOR_REGION.id;
				   config.plantId				  = dummyBottlerPlant.id;
				   config.productionLineId		  = dummyProductionLine.id;
				 
    	Case dummyCase= createDummyCase(config, false);
    	for (String fieldToTest : fieldsToTestArray) { dummyCase.put(fieldToTest, originalAssignedUserMap.get(fieldToTest).id); }
	  	if (insertNow) { insert dummyCase; }
		return dummyCase;
	}

	public static Case createDummyCase(
											ECICCaseAccountTestHelper caseAccountHelper, ECICCaseRegionTestHelper caseRegionHelper,
											Plant__c dummyBottlerPlant, Production_Line__c dummyProductionLine,
											Map<String, User> originalAssignedUserMap, String[] fieldsToTestArray,
											Boolean insertNow
										)
	{
		CaseConfig config = new CaseConfig();
				   config.recordTypeId = ECICCaseQualityComplaintRecordTypeHelper.DEFAULT_QUALITY_COMPLAINT_ID;
		return createDummyCase(config, caseAccountHelper, caseRegionHelper, dummyBottlerPlant, dummyProductionLine, originalAssignedUserMap, fieldsToTestArray, insertNow );
	}

	public static Case createDummyCase(
											ECICCaseAccountTestHelper caseAccountHelper, ECICCaseRegionTestHelper caseRegionHelper,
											Plant__c dummyBottlerPlant, Production_Line__c dummyProductionLine,
											Map<String, User> originalAssignedUserMap, String[] fieldsToTestArray
										)
	{ 
		return createDummyCase(caseAccountHelper, caseRegionHelper, dummyBottlerPlant, dummyProductionLine, originalAssignedUserMap, fieldsToTestArray, true ); 
	}

	public static List<Case> createDummyCaseList(Integer numberOfCases, CaseConfig caseConfig, Boolean insertNow)
	{
		List<Case> dummyCaseList = new List<Case>();
		for (Integer i=1; i<=numberOfCases; i++)
		{
			dummyCaseList.add(createDummyCase(caseConfig, false));
		}
	  	if (insertNow) { insert dummyCaseList; }
		return dummyCaseList;
	}

	public static Case createDummyCase(
											CaseConfig caseConfig,
											ECICCaseAccountTestHelper caseAccountHelper, ECICCaseRegionTestHelper caseRegionHelper,
											Plant__c dummyBottlerPlant, Production_Line__c dummyProductionLine,
											String origin, Boolean insertNow
										)
	{
						  caseConfig.origin			   	  	  = origin;
						  caseConfig.pointOfSaleId			  = caseAccountHelper.DUMMY_POINT_OF_SALE_ACCOUNT.id;
						  caseConfig.pointOfSaleKeyAccountId  = caseAccountHelper.DUMMY_POINT_OF_SALE_KEY_ACCOUNT.id;
						  caseConfig.packageSupplierId 	      = caseAccountHelper.DUMMY_SUPPLIER_ACCOUNT.id;
						  caseConfig.regionOfPurchaseId	      = caseRegionHelper.DUMMY_DISTRIBUTOR_REGION.id;
						  caseConfig.plantId				  = dummyBottlerPlant.id;
						  caseConfig.productionLineId		  = dummyProductionLine.id;
		return createDummyCase (caseConfig, insertNow);
	}

	public static List<Case> createDummyCaseList(
											List<CaseConfig> caseConfigList,
											ECICCaseAccountTestHelper caseAccountHelper, ECICCaseRegionTestHelper caseRegionHelper,
											Plant__c dummyBottlerPlant, Production_Line__c dummyProductionLine,
											String origin, Boolean insertNow
										)
	{
		List<Case> dummyCaseList = new List<Case>();
		for (CaseConfig config : caseConfigList)
		{
				   config.origin			   	  = origin;
				   config.pointOfSaleId			  = caseAccountHelper.DUMMY_POINT_OF_SALE_ACCOUNT.id;
				   config.pointOfSaleKeyAccountId = caseAccountHelper.DUMMY_POINT_OF_SALE_KEY_ACCOUNT.id;
				   config.packageSupplierId 	  = caseAccountHelper.DUMMY_SUPPLIER_ACCOUNT.id;
				   config.regionOfPurchaseId	  = caseRegionHelper.DUMMY_DISTRIBUTOR_REGION.id;
				   config.plantId				  = dummyBottlerPlant.id;
				   config.productionLineId		  = dummyProductionLine.id;
			dummyCaseList.add(createDummyCase(config, false));
		}
	  	if (insertNow) { insert dummyCaseList; }
		return dummyCaseList;
	}

	private static Id insertAccountAndReturnId (Account dummyAccount)
	{
		insert dummyAccount;
		return dummyAccount.id;
	}
	
	public static Case createDummyCase(CaseConfig caseConfig) { return createDummyCase (caseConfig      , false);     }
	public static Case createDummyCase(Boolean insertNow)     { return createDummyCase (new CaseConfig(), insertNow); }  
	public static Case createDummyCase() 					  { return createDummyCase (false);     				  }

	private static Case createCase(String recordTypeName, String caseReason, String caseSubject) {
		Id rtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
		
		Account pointOfSale = ECICAccountTestHelper.createPointOfSale();
		Account supplier    = ECICAccountTestHelper.createSupplier();
		Region__c region    = ECICTestHelper.createRegion(ECICCommonConstants.TEST_CITY_STATE_AND_REGION);
		Account POSKey = ECICAccountTestHelper.createPoSKeyAccount();
		insert pointOfSale;
		insert supplier;
        insert POSKey;
		insert region;		
		
		Case tmpCase = new Case( RecordTypeId = rtId,
				Reason                      = caseReason,
				Status                      = ECICCommonConstants.STATUS_NEW,
				Origin                      = ECICCommonConstants.CASE_ORIGIN,
				Priority                    = ECICCommonConstants.CASE_PRIORITY,
				Subject                     = caseSubject,
				bbe_date__c                 = System.today(),
				Process_Type__c             = 'TIPO 2.5',
				Point_of_Sale__c            = ECICAccountTestHelper.createPoSKeyAccount().id,
				Region_Of_Purchase__c       = region.Id,
				No_Quality_Status_Change__c = true,
				Package_Supplier__c         = ECICAccountTestHelper.createSupplier().Id,
				Package_Batch__c            = 'test',
                PoS_Key_Account__c			= POSKey.id,
                Description                 = '',
                Infoline_Status__c          = ECICCommonConstants.STATUS_OPEN,
                Comments_of_analyst_lab_manager__c = '',
                Quality_Status__c           = 'New complaint'                
				);
		
		return tmpCase;
	}

	public static Case createCase() {
		return createCase(ECICCommonConstants.QUALITY_COMPLAINT, ECICCommonConstants.QUALITY_COMPLAINT_REASON_PRODUCTS, ECICCommonConstants.CASE_SUBJECT);
	}
	
	public static Case getCase() {
	    Case testInstance = createCase();
	    insert testInstance;
	    return [SELECT  Id,
					    Reason,
						Status,
						Origin,
						Priority,
						Subject,
						bbe_date__c,
						Process_Type__c,
						Point_of_Sale__c,
						Region_Of_Purchase__c,
						No_Quality_Status_Change__c,
						Package_Supplier__c,
						Package_Batch__c,
                		PoS_Key_Account__c
 				FROM Case WHERE id=:testInstance.Id];
	}
	
	public static Case createQualityComplaint() {
	    return createCase(ECICCommonConstants.QUALITY_COMPLAINT, ECICCommonConstants.QUALITY_COMPLAINT_REASON_PRODUCTS, ECICCommonConstants.CASE_SUBJECT);
	}
	
	/**
	* @author		Pavel Slepenkov (Pavel_Slepenkov@epam.com)
	* @date			18 Feb 2013
	* @return 	    Case object with status = 'Open'	
	*/
	public static Case createOpenQualityComplaint() {
		Case c = createQualityComplaint();
		c.Status = 'Open';
		c.Bottler__c = ECICAccountTestHelper.getBottler().Id;
		c.Plant__c =   ECICTestHelper.plant.Id;
		c.Product__c = ECICTestHelper.product.Id;
		c.No_Quality_Status_Change__c = true;
		return c;
	}
	
	public static Case getQualityComplaint() {
		Case testInstance = createQualityComplaint();
		insert testInstance;
	    return [
		    		SELECT  Id, Reason, Status, Origin, Priority, Subject, bbe_date__c, Process_Type__c, Point_of_Sale__c, Region_Of_Purchase__c, No_Quality_Status_Change__c, 
		    				Package_Supplier__c, Package_Batch__c, PoS_Key_Account__c
	 				FROM Case 
	 				WHERE id=:testInstance.Id
 				];
	}	
	
	/**
    * @author       Pavel Slepenkov (Pavel_Slepenkov@epam.com)
    * @date         18 Feb 2013
    * @return       Inserted Case record with status = 'Open'   
    */
	public static Case getOpenQualityComplaint() {
		Case testInstance = createOpenQualityComplaint();
        insert testInstance;
        return [
	        		SELECT  Id, Bottler__c, bbe_date__c, No_Quality_Status_Change__c, Origin,
	                        Package_Batch__c, Package_Supplier__c, Plant__c, Point_of_Sale__c, PoS_Key_Account__c, Priority, Product__c, Process_Type__c,
	                        Reason, Region_Of_Purchase__c, Status, Subject
	                FROM Case 
	                WHERE id=:testInstance.Id
               ];
	}

	public static Case createNonQualityComplaint() { return createCase(ECICCommonConstants.NON_QUALITY_COMPLAINT, ECICCommonConstants.NON_QUALITY_COMPLAINT_REASON, ECICCommonConstants.CASE_SUBJECT); }
	public static Case createInquiry()             { return createCase(ECICCommonConstants.INQUIRY, 			  ECICCommonConstants.INQUIRY_REASON, 				ECICCommonConstants.CASE_SUBJECT); }
	public static Case createThanks() 			   { return createCase(ECICCommonConstants.THANKS, 				  ECICCommonConstants.THANKS_REASON, 				ECICCommonConstants.CASE_SUBJECT); }
	public static Case createJokeUseless() 		   { return createCase(ECICCommonConstants.JOKE_USELESS, 		  ECICCommonConstants.JOKE_USELESS_REASON,          ECICCommonConstants.CASE_SUBJECT); }
}