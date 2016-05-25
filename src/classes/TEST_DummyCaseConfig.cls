@isTest
public class TEST_DummyCaseConfig 						  // SFDC does not allow/support abstract/virtual test classes.  :-(
{
	public Id		  recordTypeId				     	= null;	  // Should be set by specific factory, but can be overridden if required.

	// Lookups
		// Account Ids
            public Id         accountId                         = null;
			public Id		  bottlerAccountId	  	         	= null;
			public Id 		  packageSupplierAccountId 	        = null;
			public Id 		  pointOfSaleAccountId	  	        = null;
			public Id 		  pointOfSaleKeyAccountId        	= null;

		// User Ids
			public Id		  bottlerExternalRelationsUserId 	= null;
			public Id		  bottlerQualityManagerUserId    	= null;
			public Id		  bottlerQualityOwnerUserId      	= null;
			public Id		  distributorEternalRelationsUserId = null;
			public Id		  distributorQualityUserId		    = null;
			public Id		  distributorQualityManagerUserId   = null;
			public Id		  ownerUserId					 	= null;	// Alias for ownerId, which might not be user.
            public Id         nextOpenTaskResponsibleUserId     = null;
            public Id         qualityAdminAssistantUserId       = null;
            public Id         qualityCaseOwnerUserId            = null;
            public Id         qualityManagerUserId              = null;
			public Id		  serviceManagerUserId		     	= null;
			
		// Other Ids
			public Id		  actionPlanId 			         	= null;
			public Id		  contactId					     	= null;
			public Id		  ownerId						 	= null;
			public Id 		  plantId 		    	         	= null;
		    public Id 		  productId	  			         	= null;
		    public Id         beverageId                        = null;
		    public Id         packageId                         = null;
		    public Id 		  productionLineId		         	= null;
		    public Id		  regionOfPurchaseId             	= null;
			public Id		  trendId		  			     	= null;
		    

	// Boolean ("Checkbox") fields
		    public Boolean 	  noQualityStatusChange         	= null;
		    public Boolean	  imcrIssue					    	= null;
		    public Boolean	  sampleCollected			    	= null;
			public Boolean	  thirdComplaint					= null;
		    

	// String fields
			public String  	  analystLabManagerComments     	= null;
			public String	  bottlerName 			        	= null;
			public String 	  categoryLevel3			    	= null;
			public String 	  categoryLevel4			    	= null;
		    public String     channelOfAnswer					= null;
			public String  	  countryCode           	        = null;
			public String  	  description       	            = null;
			public String 	  infolineStatus	 	 	        = null; 	
			public String	  name							    = null;
			public String  	  origin                	        = null;
			public String	  packageBatch	    		        = null;
            public String     placeOfPurchase                   = null;
		    public String	  potentialRisk					    = null;
			public String  	  priority      	                = null;
			public String  	  processType   	                = null;
		    public String  	  productionCode    	        	= null;
			public String 	  qualityStatus 	 	    	    = null; 	
			public String  	  reason    	                    = null;
            public String     regionBottlerName                 = null;
		    public String	  riskType						    = null;
			public String 	  status 	 				        = null; 	
			public String  	  subject	                       	= null;
		    public String	  suppliedEmail						= null;
			public String	  sysomosHbWebUrl				    = null;
			public String	  trendKey							= null;
			public String	  type								= null;

		// Date fields
	  	  	public Date    	  bbeDate             	        	= null;
	   	 	public Datetime   createdDate						= null;
			public Datetime	  trendMark							= null;

		// Number fields
	    	public Integer	  numberOfPacks						= null;
	    	public Double	  productUnitPrice					= null;
	    	public Double	  voucherValue						= null;

	    // Task user testing configuration parameters
	        public List<String>      userLookupFieldsToTestList = null;    // This is used to create a dummy Action Plan with corresponding Items for these users.
	        public Map<String, User> assignedUserByFieldNameMap = null;    // This is used to assign Users to the indicated fields (note: fields use the true SFDC names).

	// Mock fields
	        public Boolean	  skipStrategies 	  	    = true;

			/**
			 *	If strategyListMapByTriggerType is set,
			 * 		1) skipStrategies will be changed to false
			 * 		2) This Map will be consulted INSTEAD of either custom settings or the DefaultStrategies.
			 **/
			public Map<SEPTriggerTypeEnum, List<SEPTriggerHandlerStrategy>> strategyListMapByTriggerType = null; 
	
	public TEST_DummyCaseConfig(){}
}