/*This class is used for assigning case team members on the basis of case country and its region
 *it will pick predefined case team members and will add on the case as case team members. 
 *Created by : Balmukund
 *Created on : 9/10/2014
*/


public class ECICCaseTeamMembersAssignment {
    
    private static final Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);
    private static boolean isQualityIberia = false;
    private static boolean isQualityGermany = false;
    private static boolean isQualityNWEN = false;
    private static boolean isQualitySABU = false;
    private static boolean isNWENPlantChanged = false;
    private static boolean isPotentialRisk = false;
    private static boolean isNonQorInquiryRiskLCBU = false;
    private static boolean isNonQPotentialRisk = false;
    private static boolean isNonQorInquiryIberia = false;
    private static boolean isNonQorInquiryRiskSABU = false;             
    private static boolean isRecordTypeChanged = false;
    private static boolean isAllowedNWENCountries = false;
    private static boolean riskUpdateCheckFlagLCBU = false;
    private static boolean riskUpdateCheckSABU = false;
    private static boolean isCountryCodeChanged = false;
    private static Set<String> templateNames = new Set<String>();
    //private static List<Sample_Collector__c> SampleCollect = new List<Sample_Collector__c>();
    private static Map<String,Plant__c> plantsByName;
    private static Set<CaseTeamMember> caseTeamMemberList = new Set<CaseTeamMember>();
    private static Map<Id,CaseTeamMember> caseTeamMemberMap = new Map<Id,CaseTeamMember>();
    private static Map<ID, Region__c> bottlerRegionByIdMap = new Map<ID, Region__c>();
    private static Map<ID, Plant__c> plantRegionByIdMap = ECICCaseTriggerRegionCache.getPlantByIdMap();  
    private static String developerName = '';
    private static String developerNameOld = '';
    private static Map<String,ECICAllowedCountriesNWEN__c> allowedCountriesNWEN = ECICAllowedCountriesNWEN__c.getAll();
    private static Map<String,ECICAllowedPlantsNWEN__c> allowedPlantsNWEN = ECICAllowedPlantsNWEN__c.getAll();
   // private static String CRCountries1 = LCBURegionsMarkets__c.getInstance('CR').Markets__c;
    private static LCBURegionsMarkets__c lcb =LCBURegionsMarkets__c.getValues('CR');
    private static String CRCountries1;// = lcb.Markets__c;
    private static List<String> tempList ;//= CRCountries1.split(',');
    private static Set<String> CRCountries =  new Set<String>();//{'CR','SV','GT','NI','HN','PA','TT'};
    private static boolean isIberiaPlantChanged = false;  //Iberia -CR-CICCP-21
    private static Map<String,ECICAllowedPlantsIberia__c> allowedPlantsIberia = ECICAllowedPlantsIberia__c.getAll();//Iberia CR-CICCP-21
    //private static List<String> secondaryTopic1 =  new List<String>{'Acesulfame-K','Alcohol','Arsenic','Artificiality','Aspartame','Biotechnology / GMO','Bisphenol A (BPA)','Brominated Vegetable Oil (BVO)','Caffeine','Caramel / 4-ME','Carbonation','Cyclamate','Emerging Topic','Energy Drinks','Erythritol','Food Colorings & Preservatives','Formulation','Guideline Daily Amounts (GDAs)','High Fructose Corn Syrup (HFCS','Nutrition Labeling','Palm Oil','Phosphoric acid','Rumors/ Rumours','Saccharine','Sodium','Stevia (Rebiana)','Sugar/Sucrose','Addiction','Content Simulation & Satiety','Arthritis','Bone Health','Cancer','Cellulitis','Dental Health','Diabetes','Emerging Topic','Energy Balance','Gastrointestinal Health','Heart (Cardiovascullar)Disease','HIV(AIDS)','Hydration','Hyperactivity','Kidney Disease & Kidney Stone','Metabloic Syndrome','Moderation','Obesity'} ;
    //private static List<String> secondaryTopic2 =  new List<String>{'Competitor','Customers/Partners','Emerging Topics','News','AntiAmericanism','Desaster Response','Emerging Topic','Gender Parity','Human Rights','Israel/palestine','Leagal Action','Lobbing','Local Political Issue','Political Contribution','Public Policy/Regulatory','Public Private Collabotation','Religion','Tax/Tax Reform','Agriculture','Climate','Emerging Topic','Energy','Packaging','Pesticides','Recycling (including legislation)','Sanitation','Waste Disposal','Water','Diversity','Emerging Topic','Employee Recognition','Labor','Security','Workplace Rights','Workplace Safety'};
    private static Map<String,HUB_secondaryTopic1__c> secondaryTopic1 = HUB_secondaryTopic1__c.getAll();
    private static Map<String,HUB_secondaryTopic2__c> secondaryTopic2 = HUB_secondaryTopic2__c.getAll();
                                
    
    public static void addMemberAfterInsert(List<Case> newValues,List<Case> oldValues){
        
        Case caseObjNew = newValues.get(0);
        
        developerName = RECORD_TYPES_BY_ID_MAP.get(caseObjNew.RecordTypeID).DeveloperName;
   
        TriggerContextUtility.log += ' '+developerName ;
        if(developerName.StartsWith(ECICCommonConstants.QUALITY_COMPLAINT_DEVNAME) && developerName.contains(ECICCommonConstants.NWEN_REGION))
        {

          //Only Allowed Country Case Allowed
            if(allowedCountriesNWEN.containsKey(caseObjNew.Country_Code__c))
            {
                isAllowedNWENCountries = true;
                if(templateNames.size()>0){
                     templateNames.clear();
                     caseTeamMemberMap.clear();
                }
            }
        }
        if(developerName.contains(ECICCommonConstants.LCBU_Region))
        {
            setLCBUCountries(lcb);
            riskUpdateCheckFlagLCBU = true;
            
        }
        if(developerName.contains(ECICCommonConstants.SABU_Region))
        {
           
            riskUpdateCheckSabu = true;
            
        }
       
        
        execute(caseObjNew,null);
        
    }
    
    public static void addMemberBeforeUpdate(List<Case> newValues,List<Case> oldValues){
        
       
        Case caseObjNew = newValues.get(0);
        Case caseObjOld = oldValues.get(0);
       
        setLCBUCountries(lcb);
        developerName = RECORD_TYPES_BY_ID_MAP.get(caseObjNew.RecordTypeID).DeveloperName;
        developerNameOld = RECORD_TYPES_BY_ID_MAP.get(caseObjOld.RecordTypeID).DeveloperName;
        if(caseObjNew.RecordTypeId != caseObjOld.RecordTypeId){
            isRecordTypeChanged = true;
            deleteAllCaseTeams(caseObjNew,caseObjOld);  
           
            if(templateNames.size()>0){
                 templateNames.clear();
                 caseTeamMemberMap.clear();
            }
            TriggerContextUtility.log += ' deleted case teams '+templateNames.size()+'$'; 
                       
        }
        
        
        if(developerName.StartsWith(ECICCommonConstants.QUALITY_COMPLAINT_DEVNAME) && developerName.contains(ECICCommonConstants.LCBU_REGION))
        {   
            //if LCBU Country Code is changed then flush case teams
            if(caseObjOld.Country_Code__c != caseObjNew.Country_Code__c)
            {
                deleteAllCaseTeams(caseObjNew,caseObjOld);  
               
                if(templateNames.size()>0){
                     templateNames.clear();
                     caseTeamMemberMap.clear();
                }
            }
            //If Plant changed or removed on case then clean up Case Team members of corrosponding old plant plant for LCBU Quality complaint
            if((caseObjOld.Plant__c != null && caseObjNew.Plant__c != null && caseObjOld.Plant__c != caseObjNew.Plant__c)||(caseObjOld.Plant__c != null && caseObjNew.Plant__c == null))
            {
                deleteAllCaseTeams(caseObjNew,caseObjOld);  
                
                if(templateNames.size()>0){
                     templateNames.clear();
                     caseTeamMemberMap.clear();
                }
                //when plant is changed, update the plant code as well
                plantsByName = ECICCaseTriggerRegionCache.getPlantByNameMap();                
                Plant__c plant = plantsByName.get(caseObjNew.Plant_Name__c);              
                caseObjNew.LCBU_Plant_Code__c=plant.LCBU_Plant_Code__c;
                
            } 
        }
        
        //to check if Potential risk is updated from other values to High Risk
        if(developerName.contains(ECICCommonConstants.LCBU_REGION)&& ((caseObjOld.Potential_Risk__c != ECICCommonConstants.HIGH_RISK && caseObjNew.Potential_Risk__c == ECICCommonConstants.HIGH_RISK)||(caseObjOld.Potential_Risk__c!= ECICCommonConstants.MEDIUM_RISK && caseObjNew.Potential_Risk__c == ECICCommonConstants.MEDIUM_RISK)))
        {
            riskUpdateCheckFlagLCBU = true;
        }
        
        if(developerName.contains(ECICCommonConstants.SABU_REGION)&& ((caseObjOld.Potential_Risk__c!= ECICCommonConstants.HIGH_RISK && caseObjNew.Potential_Risk__c == ECICCommonConstants.HIGH_RISK)||(caseObjOld.Potential_Risk__c!= ECICCommonConstants.MEDIUM_RISK && caseObjNew.Potential_Risk__c == ECICCommonConstants.MEDIUM_RISK)))
        {
            riskUpdateCheckSABU = true;
            
        }   
          
                 
        if(developerName.StartsWith(ECICCommonConstants.QUALITY_COMPLAINT_DEVNAME) && developerName.contains(ECICCommonConstants.NWEN_REGION)){
                    
            //Only Allowed Country Case Allowed
            if(allowedCountriesNWEN.containsKey(caseObjNew.Country_Code__c))
            {
                isAllowedNWENCountries = true;
                if(templateNames.size()>0){
                     templateNames.clear();
                     caseTeamMemberMap.clear();
                }
            }
          
            //If Plant changed on case then clean up Case Team members of corrosponding old plant plant for NWEN Quality complaint
            if(caseObjOld.Plant__c != null && caseObjNew.Plant__c != null && caseObjOld.Plant__c != caseObjNew.Plant__c){
                isNWENPlantChanged = true;
                deleteAllCaseTeams(caseObjNew,caseObjOld);  
               
                if(templateNames.size()>0){
                     templateNames.clear();
                     caseTeamMemberMap.clear();
                }
                
            } 
            //If Plant deleted form case then clean up Case Team members of corrosponding plant for NWEN Quality complaint 
            if(caseObjOld.Plant__c != null && caseObjNew.Plant__c == null){
                
                deleteAllCaseTeams(caseObjNew,caseObjOld);  
               
                if(templateNames.size()>0){
                     templateNames.clear();
                     caseTeamMemberMap.clear();
                }
                
            }
            
        }
        if(developerName.StartsWith(ECICCommonConstants.QUALITY_COMPLAINT_DEVNAME)&&developerName.contains(ECICCommonConstants.IBERIA_REGION)){         
                if((caseObjOld == null && caseObjNew.Plant__c != null ) || (caseObjOld != null && caseObjNew.Plant__c != caseObjOld.Plant__c))      
               {        
                    deleteAllCaseTeams(caseObjNew,caseObjOld);          
                
            if(templateNames.size()>0){     
                 templateNames.clear();     
                 caseTeamMemberMap.clear();     
            }       
                }                       
        }
        /*Written By Anil Jadhav*/
        /*Case team changes when any updation on case.*/
        if(developerName.StartsWith(ECICCommonConstants.QUALITY_COMPLAINT_DEVNAME) && developerName.contains(ECICCommonConstants.SABU_REGION)){
            if(caseObjOld.Plant__c != null && caseObjNew.Plant__c != null && caseObjOld.Plant__c != caseObjNew.Plant__c || ( caseObjOld.City__c!= null && caseObjNew.City__c!= null && caseObjOld.City__c != caseObjNew.City__c)){
                deleteAllCaseTeams(caseObjNew,caseObjOld);  
                if(templateNames.size()>0){     
                     templateNames.clear();     
                     caseTeamMemberMap.clear();     
                }  
            }               
        
        }        
        
        // if(!caseObjNew.Is_Social_Media__c) 
        execute(caseObjNew,caseObjOld);
    }   
    
    public static void execute(Case caseObjNew,Case caseObjOld ){
        
        
        String templateName = getCaseTeamTemplate(developerName,caseObjNew,caseObjOld);
        
        /* --Added for HUB Case Team Solution --- Sagar Madkaikar --------------------------*/
        if(developerName.equalsIgnoreCase(ECICCommonConstants.HUB_DEVNAME))
        {
            if(caseObjNew.HUB_Brand__c == ECICCommonConstants.HUB_BRAND_COCA_COLA )
            {
                templateNames.add(ECICCommonConstants.HUB_GLOBAL_COKE_BRAND_TEAM);
            }
            else if(caseObjNew.HUB_Brand__c == ECICCommonConstants.HUB_BRAND_COCA_COLA_LIGHT)
            {
                templateNames.add(ECICCommonConstants.HUB_GLOBAL_DIET_COKE_BRAND_TEAM);
            }
            else if(caseObjNew.HUB_Brand__c == ECICCommonConstants.HUB_BRAND_FANTA)
            {
                templateNames.add(ECICCommonConstants.HUB_GLOBAL_FANTA_BRAND_TEAM);
            } 
            else if(caseObjNew.HUB_Brand__c == ECICCommonConstants.HUB_BRAND_SPRITE)
            {
                templateNames.add(ECICCommonConstants.HUB_GLOBAL_SPRITE_BRAND_TEAM);
            } 
            else if(caseObjNew.HUB_Brand__c == ECICCommonConstants.HUB_BRAND_POWERADE)
            {
                templateNames.add(ECICCommonConstants.HUB_GLOBAL_POWERADE_BRAND_TEAM);
            } 
            else if(caseObjNew.HUB_Brand__c == ECICCommonConstants.HUB_BRAND_COCA_COLA_ZERO)
            {
                templateNames.add(ECICCommonConstants.HUB_GLOBAL_COKE_ZERO_BRAND_TEAM);
            } 
            else if(caseObjNew.HUB_Brand__c == ECICCommonConstants.HUB_BRAND_COCA_COLA_LIFE)
            {
                templateNames.add(ECICCommonConstants.HUB_GLOBAL_COCA_COLA_LIFE_BRAND_TEAM);
            } 
            else if(caseObjNew.HUB_Brand__c == ECICCommonConstants.HUB_BRAND_COCA_COLA_VITAMIN)
            {
                templateNames.add(ECICCommonConstants.HUB_GLOBAL_GLACEAU_BRAND_TEAM);
            } 
            
            if(caseObjNew.HUB_Secondary_Issue__c != null && (caseObjNew.HUB_Issue__c.contains(ECICCommonConstants.HUB_BRAND_FIFA) || caseObjNew.HUB_Secondary_Issue__c.contains(ECICCommonConstants.HUB_BRAND_FIFA)))
            {
                templateNames.add(ECICCommonConstants.HUB_FIFA_CHARTER_TEAM);
            }
            
            if(caseObjNew.HUB_Secondary_Issue__c != null && (caseObjNew.HUB_Issue__c.contains(ECICCommonConstants.HUB_BRAND_OLYMPICS) || caseObjNew.HUB_Secondary_Issue__c.contains(ECICCommonConstants.HUB_BRAND_OLYMPICS)))
            {
                templateNames.add(ECICCommonConstants.HUB_OLYMPICS_CHARTER_TEAM);
            }
            
            if(caseObjNew.HUB_Secondary_Issue__c != null && (caseObjNew.HUB_Issue__c.contains(ECICCommonConstants.HUB_BRAND_SECURITY) || caseObjNew.HUB_Secondary_Issue__c.contains(ECICCommonConstants.HUB_BRAND_SECURITY)))
            {
                templateNames.add(ECICCommonConstants.HUB_STRATEGIC_SECURITY);
            }
            
            
            set<String> st1 = new set<String>();
            st1=secondaryTopic1.keySet();
            
            for(String topic: st1)
            {
                if(caseObjNew.HUB_Secondary_Issue__c != null &&  caseObjNew.HUB_Secondary_Issue__c.contains(topic))
                 {
                       templateNames.add(ECICCommonConstants.HUB_GLOBAL_SRA_TEAM);
                 }
                if(caseObjNew.HUB_Issue__c != null && caseObjNew.HUB_Issue__c.contains(topic))
                 {
                       templateNames.add(ECICCommonConstants.HUB_GLOBAL_SRA_TEAM);
                 }
                
            }
            
           set<String> st2 = new set<String>();
            st2=secondaryTopic2.keySet();
            
            for(String topic : st2)
            {
                if(caseObjNew.HUB_Secondary_Issue__c != null &&  caseObjNew.HUB_Secondary_Issue__c.contains(topic))
                 {
                       templateNames.add(ECICCommonConstants.HUB_GLOBAL_PAC_TEAM);
                 }
                if(caseObjNew.HUB_Issue__c != null && caseObjNew.HUB_Issue__c.contains(topic))
                 {
                       templateNames.add(ECICCommonConstants.HUB_GLOBAL_PAC_TEAM);
                 }
            }
        }
        /* ---------------------------------------------------------------------------------*/
        if(caseObjOld == null || caseObjNew.RecordTypeId != caseObjOld.RecordTypeId){
            
            if(developerName.contains(ECICCommonConstants.IBERIA_REGION) && (isQualityIberia || isNonQorInquiryIberia)){
                templateNames.add(templateName);
            }else if(!developerName.contains(ECICCommonConstants.IBERIA_REGION)){
                templateNames.add(templateName);
                
            }
            TriggerContextUtility.log += ' caseObjOld '+templateNames;
        }      
        //Add prefefined case team name in Set for NWEN
        if(isQualityNWEN && caseObjOld != null && caseObjOld.Plant__c == null && caseObjNew.Plant__c != null)
        {
            templateNames.add(templateName);
        }
       
         if(isNWENPlantChanged){  
                templateNames.add(templateName);

            }
        if(isPotentialRisk)
            templateNames.add(ECICCommonConstants.POTENTIAL_RISK_IBERIA_CASETEAM);
        
        if(isNonQorInquiryRiskLCBU)
        {
            templateNames.add(templateName);
        }
        if(isNonQorInquiryRiskSABU)
        {
            templateNames.add(templateName);
        }
        
        if(isQualityIberia && !Test.isRunningTest()){
            TriggerContextUtility.log += 'isQualityIberia='+isQualityIberia;
            bottlerRegionByIdMap = ECICCaseTriggerRegionCache.getRegionByIdMap();    
            addPlantCaseTeam(caseObjNew,caseObjOld);            
            addROPCaseTeam(caseObjNew,caseObjOld);
        }
          /*  //If potential iCase field is checked in Care case then adding relevent users in Case team
         if(caseObjNew.HUB_Potential_iCase__c){
            List<Contact> contList = ECICCaseTriggerRegionCache.getMktIntliAnalystContacts(caseObjNew.country_code__c);
            if(contList.size() > 0){
                for(Contact conList:contList){
                    if(conList.country_code__c == caseObjNew.country_code__c && ECICCommonConstants.MKT_INTELI_ANALYST_ROLE_NAME == conList.contact_type__c){
                        addQualityTeamMember(caseObjNew,ECICCommonConstants.MKT_INTELI_ANALYST_ROLE_NAME,conList.id);
                    }
                }  
            }      
        }*/
        //If potential iCase field is checked in Care case then adding relevent users in Case team
         if(caseObjNew.HUB_Potential_iCase__c){
            List<Case_Team_User__c > cUserList = ECICCaseTriggerRegionCache.getMktIntliAnalystCaseTeamUser(caseObjNew.country_code__c);
             if(cUserList.size() > 0){
                for(Case_Team_User__c cUser:cUserList){
                    if(cUser.Country_Code__c == caseObjNew.country_code__c && ECICCommonConstants.MKT_INTELI_ANALYST_ROLE_NAME == cUser.Type__c ){
                        addQualityTeamMember(caseObjNew,ECICCommonConstants.MKT_INTELI_ANALYST_ROLE_NAME,cUser.Contact__c);
                    }
                }  
            }      
        }    
        
        
        
        addCaseTeamMembers(caseObjNew); 
        
        List<CaseTeamMember> caseMemberList = new List<CaseTeamMember>();
        caseMemberList = caseTeamMemberMap.values();
       // Boolean flag = isCaseTeamNotAdded(caseMemberList,caseObjNew);
        if(isCaseTeamNotAdded(caseMemberList,caseObjNew) && caseObjOld != null){
            
        
        
         //   TriggerContextUtility.log += ' before calling  '+'##'+isCaseTeamNotAdded(caseMemberList,caseObjNew)+' Size-'+isNonQPotentialRisk;
            if(TriggerContextUtility.isFirstRun() && developerName.contains(ECICCommonConstants.CSE_REGION)){
            
                if(caseMemberList.size() >0){
                    insert caseMemberList;
                    TriggerContextUtility.setFirstRunFalse();
                     TriggerContextUtility.log += 'bool before for CSE';
                }           
                
            }else if(caseObjOld !=null && TriggerContextUtility.isFirstRun() && (caseObjNew.Origin == ECICCommonConstants.TWITTER_CASE_ORIGIN || caseObjNew.Origin == ECICCommonConstants.FB_CASE_ORIGIN) && !developerName.contains(ECICCommonConstants.CSE_REGION)){
                if(caseMemberList.size() >0){
                    insert caseMemberList;
                    TriggerContextUtility.setFirstRunFalse();
                     TriggerContextUtility.log += 'bool before '+TriggerContextUtility.isFirstRun();
                }
            
            }else if(TriggerContextUtility.isFirstRun() && !developerName.contains(ECICCommonConstants.CSE_REGION)){
                if(caseMemberList.size() >0){
                TriggerContextUtility.log += ' bool after '+TriggerContextUtility.isFirstRun();
                    upsert caseMemberList;
                }
                
            }
        }else if(caseObjOld == null){
            if(caseMemberList.size() >0){
                try{
                    insert caseMemberList;
                }	
                catch(Exception e){
                    caseObjNew.addError('Case Team contains inactive user. Add active user.');
                    
                }    
                }
            
        }
        
      
    }
    
    
    
    
    //Fetching case team members based on the country/region
    private static String getCaseTeamTemplate(String caseType,Case caseObj,Case caseObjOld){
        
        String templateName = '';
        
        
        //Setting TemplateName based on the type of case type and region 
        if(caseType.StartsWith(ECICCommonConstants.QUALITY_COMPLAINT_DEVNAME)){
            if(caseType.contains(ECICCommonConstants.IBERIA_REGION)){
                //setting case team for ES or PT bases on teh country code of case
                templateName = ECICCommonConstants.QUALITY_COMPLAINT_CASETEAM+' '+caseObj.Country_Code__c+' '+ECICCommonConstants.IBERIA_REGION;
                templateNames.add(templateName);
                /*if(caseObj.Country_Code__c == 'ES')
                    templateName = ECICCommonConstants.QUALITY_COMPLAINT_SPAIN;
                else if(caseObj.Country_Code__c == 'PT')
                    templateName = ECICCommonConstants.QUALITY_COMPLAINT_PORTUGAL;*/
               // templateName = ECICCommonConstants.QUALITY_COMPLAINT_PORTUGAL;
                isQualityIberia = true;
                //Allow Only Iberian Plant Iberia CR-CICCP-21
                if(caseObj.Plant__c != null && (caseObj.Country_Code__c == ECICCommonConstants.COUNTRY_CODE_SPAIN || caseObj.Country_Code__c == ECICCommonConstants.COUNTRY_CODE_PT ))
                { 
                     Plant__c casePlant = plantRegionByIdMap.get(caseObj.Plant__c);
                     if(allowedPlantsIberia.containsKey(casePlant.Name))
                     {
                        templateName = ECICCommonConstants.IBERIAN_PLANT+' '+casePlant.Name;
                         templateNames.add(templateName);
                     }
                
                }   
                if(caseObj.Potential_Risk__c != null && caseObj.Potential_Risk__c != '' && caseObj.Potential_Risk__c != 'No Risk')
                    isPotentialRisk = true;
            }else if(caseType.contains(ECICCommonConstants.NWEN_REGION)){
                
                isQualityNWEN = true;
                //Adding Central QESH team for CCE as this case team will always be added for NWEN quality complaint
                templateNames.add(ECICCommonConstants.CASE_TEAM_CENTRAL_QESH);
                
               
                //Allow Only BENELUX sites
                if(caseObj.Plant__c != null && isAllowedNWENCountries)
                { 
                     Plant__c casePlant = plantRegionByIdMap.get(caseObj.Plant__c);
                    if(casePlant.CCE_Bottler__c != ECICCommonConstants.COCA_COLA_ENTERPRISES) // CCE CR CICCP-22/24
                    {
                        templateNames.add(ECICCommonConstants.CCE_CO_PACKER_QESH_NWEN);
                    }
                     if(allowedPlantsNWEN.containsKey(casePlant.Name))
                     {
                        templateName = ECICCommonConstants.CCE_NWEN+' '+casePlant.Name+' '+ECICCommonConstants.NWEN_REGION;
                     }
                
                }
                
            }else if(caseType.contains(ECICCommonConstants.CSE_REGION)){
                
                templateName = ECICCommonConstants.QUALITY_COMPLAINT_CASETEAM+' '+caseObj.Country_Code__c+' '+ECICCommonConstants.CSE_REGION;
            
            }else if(caseType.contains(ECICCommonConstants.GERMANY_REGION)){
                
                templateName = ECICCommonConstants.QUALITY_COMPLAINT_GERMANY;
                isQualityGermany = true;            
            }
            else if(caseType.contains(ECICCommonConstants.LCBU_REGION)){
                //if(CRCountries.contains(caseObj.Country_Code__c))
                //    {
                //        templateName = ECICCommonConstants.QUALITY_COMPLAINT_CASETEAM+' CR '+ECICCommonConstants.LCBU_REGION;
                //        templateNames.add(templateName);
                       
                 //   }   
                 //   else
                 //   {
                        templateName = ECICCommonConstants.QUALITY_COMPLAINT_CASETEAM+' '+caseObj.Country_Code__c+' '+ECICCommonConstants.LCBU_REGION;
                        templateNames.add(templateName);
                 //   }
                
                if(caseObj.Plant__c != null)
                {   
                    templateName = ECICCommonConstants.PLANT+' '+caseObj.LCBU_Plant_Code__c+' '+ECICCommonConstants.LCBU_REGION;
                    templateNames.add(templateName);
                }

            }
            /*Written by Anil Jadhav
              To add central team, sample collector and case team members   */
            else if(caseType.containsIgnoreCase(ECICCommonConstants.SABU_REGION) ){
                         plantsByName = ECICCaseTriggerRegionCache.getPlantByNameMap();   
                         Plant__c casePlant = plantRegionByIdMap.get(caseObj.Plant__c);
                         if(caseObj.City__c != null && (casePlant == null || (casePlant != null && casePlant.SABU_Add_Sample_Collector__c == EcicCommonConstants.SABU_From_Geo_Mappings))){  
                            addSampleCollector(caseObj,caseObjOld);
                         } 
                         if(casePlant!= null &&  plantsByName.containsKey(casePlant.Name)){
                                 templateName = ECICCommonConstants.SABU_REGION +' '+ casePlant.LCBU_Plant_Code__c +' '+ ECICCommonConstants.PLANT;
                                 templateNames.add(templateName);
                         }
                         templateNames.add(ECICCommonConstants.CASE_TEAM_CENTRAL_SABU);
                         
                         
            }
        } 
        else{
            if(caseType.contains(ECICCommonConstants.IBERIA_REGION)){
               
                if(caseType.StartsWith(ECICCommonConstants.INQUIRY_DEVNAME) || caseType.StartsWith(ECICCommonConstants.NONQUALITY_COMPLAINT_DEVNAME)){
                    isNonQorInquiryIberia = true;
                    templateName = ECICCommonConstants.CASE_TEAM+' '+caseObj.Country_Code__c+' '+ECICCommonConstants.IBERIA_REGION;
                    //templateName = ECICCommonConstants.CASE_TEAM_IBERIA;
                }
            }else if(caseType.contains(ECICCommonConstants.NWEN_REGION)){
                templateName = ECICCommonConstants.CASE_TEAM+' '+caseObj.Country_Code__c+' '+ECICCommonConstants.NWEN_REGION;
            }else if(caseType.contains(ECICCommonConstants.CSE_REGION)){
                templateName = ECICCommonConstants.CASE_TEAM+' '+caseObj.Country_Code__c+' '+ECICCommonConstants.CSE_REGION;
            }else if(caseType.contains(ECICCommonConstants.GERMANY_REGION)){
                templateName = ECICCommonConstants.CASE_TEAM_GERMANY;
            }
            else if(caseType.contains(ECICCommonConstants.LCBU_REGION)){
                if(caseObj.Potential_Risk__c != null && caseObj.Potential_Risk__c != '' && (caseObj.Potential_Risk__c == 'High Risk'||caseObj.Potential_Risk__c == 'Medium Risk') && riskUpdateCheckFlagLCBU)
                {
                    
                    isNonQorInquiryRiskLCBU = true;
                    
                    if(CRCountries.contains(caseObj.Country_Code__c))
                    {
                       templateName = ECICCommonConstants.CASE_TEAM+' CR '+ECICCommonConstants.LCBU_REGION;
                       
                    }   
                    else
                    {
                        templateName = ECICCommonConstants.CASE_TEAM+' '+caseObj.Country_Code__c+' '+ECICCommonConstants.LCBU_REGION;
                    }
                }
            }
                
            /* Created By Anil Jadhav */
            /* Adding case team for the record types Non Quality and Inquiry Type case for SABU.*/
            else if(caseType.contains(ECICCommonConstants.SABU_REGION)){
                    if(caseType.StartsWith(ECICCommonConstants.INQUIRY_DEVNAME) || caseType.StartsWith(ECICCommonConstants.NONQUALITY_COMPLAINT_DEVNAME)){
                            if(caseObj.Potential_Risk__c != null && caseObj.Potential_Risk__c != '' && (caseObj.Potential_Risk__c == 'High Risk'||caseObj.Potential_Risk__c == 'Medium Risk')&& riskUpdateCheckSABU) {
                                    templateName = ECICCommonConstants.SABU_REGION +' ' +ECICCommonConstants.CASE_TEAM ; 
                                isNonQorInquiryRiskSABU = True;
                                
                            }    
                    }
                
            }       
            
                
        }
                return templateName;
        
    }
    
    
    //This method is used for adding bottler quality  and bottler external relation user of the associated region of purchase in the case team template
    private static void addROPCaseTeam(Case caseObjNew,Case caseObjOld){
        String log = '';
        if((caseObjOld == null && caseObjNew.Region_of_Purchase__c != null) || (caseObjOld != null && caseObjNew.Region_of_Purchase__c != null && caseObjOld.Region_of_Purchase__c == null)){
            
            addBottlerQualityUsers(caseObjNew,caseObjOld);
            
        }   
        
        if(caseObjOld != null && caseObjNew.Region_of_Purchase__c != null && caseObjOld.Region_of_Purchase__c != null && caseObjNew.Region_of_Purchase__c !=  caseObjOld.Region_of_Purchase__c){
        
            String regionId;
            Region__c regionUsers = bottlerRegionByIdMap.get(caseObjOld.Region_of_Purchase__c);     
                
            Set<String> userSet = new Set<String> {regionUsers.Bottler_Quality__c,regionUsers.Bottler_External_Relations__c};
            
            List<CaseTeamMember> teamMemberList = [select id from CaseTeamMember where MemberId IN: userSet and ParentId =:caseObjOld.id];
            if(teamMemberList.size() > 0){
                delete teamMemberList;
                
            }
        }
        
        addBottlerQualityUsers(caseObjNew,caseObjOld);
                
    }
    
    
    
    private static void addCaseTeamMembers(Case caseObjNew){
        
        List<CaseTeamTemplate> caseTeamTempList;
        //Not executing in test run
      //  if(!Test.isRunningTest())
        caseTeamTempList = [select id,name from CaseTeamTemplate where Name IN : templateNames];
        
        Set<id> caseTeamTemplateIds = new Set<id>();
        for(CaseTeamTemplate caseTeam:caseTeamTempList){
            caseTeamTemplateIds.add(caseTeam.id);
            
        }
        //Not executing in test run
        List<CaseTeamTemplateMember> caseTeamList;
      //  if(!Test.isRunningTest())
        caseTeamList = [Select c.TeamTemplateId, c.TeamRoleId, c.MemberId From CaseTeamTemplateMember c where TeamTemplateId IN : caseTeamTemplateIds];
        
        for(CaseTeamTemplateMember caseTeam:caseTeamList){
        
            CaseTeamMember caseTeamMember = new CaseTeamMember();   
            caseTeamMember.MemberId = caseTeam.MemberId;
            caseTeamMember.ParentId = caseObjNew.id;
            caseTeamMember.TeamRoleId = caseTeam.TeamRoleId;
            caseTeamMemberMap.put(caseTeam.MemberId,caseTeamMember);
            
        }
    }
    
    private static void addQualityTeamMember(Case caseObjNew,String roleId,Id memberId){
        
        CaseTeamMember caseTeamMember = new CaseTeamMember();
        caseTeamMember.MemberId = memberId;
        caseTeamMember.ParentId = caseObjNew.id;
        caseTeamMember.TeamRoleId = Case_Team_Role__c.getValues(roleId).CaseTeamRoleId__c;
        caseTeamMemberMap.put(memberId,caseTeamMember);
        
    }
    
    //This method is used for actually adding users in case team 
    private static void addBottlerQualityUsers(Case caseObjNew,Case caseObjOld){
        
        
            Region__c regionCase = bottlerRegionByIdMap.get(caseObjNew.Region_of_Purchase__c);
            if(regionCase != null){
            
            String externalRelationROP = regionCase.Bottler_External_Relations__c;
            String bottlerQualityROP = regionCase.Bottler_Quality__c;       
            String areaROP = regionCase.Area__c;
            
            
            //Adding bottler Qulaity and External Relation users in the list of case team members
            
            if(externalRelationROP != null && externalRelationROP != ''){
                List<CaseTeamMember> teamMember = [select id from CaseTeamMember where MemberId =: externalRelationROP and ParentId =:caseObjNew.id];
                if(teamMember.size() == 0 && !Test.isRunningTest()){
                    addQualityTeamMember(caseObjNew,ECICCommonConstants.IBERIA_EXTERNAL_RELATION_ROLEID,externalRelationROP);
                    //caseObjNew.Test_Log__c = caseObjNew.Test_Log__c +' externalRelationROP added ';
                }
            }
            if(bottlerQualityROP != null && bottlerQualityROP != ''){
                List<CaseTeamMember> teamMember = [select id from CaseTeamMember where MemberId =: bottlerQualityROP and ParentId =:caseObjNew.id];
                if(teamMember.size() == 0 && !Test.isRunningTest()){
                    addQualityTeamMember(caseObjNew,ECICCommonConstants.IBERIA_BOTTLER_QUAILITY_ROLEID,bottlerQualityROP);
                    //caseObjNew.Test_Log__c = caseObjNew.Test_Log__c +' bottlerQualityROP added ';
                }
            }
            }
        
    }
    
    private static void deleteAllCaseTeams(Case caseObjNew,Case caseObjOld){
        List<CaseTeamMember> teamMemberList = [select id from CaseTeamMember where ParentId =:caseObjNew.id];
        
        if(teamMemberList.size() > 0){
            delete teamMemberList;
        }
        if(isRecordTypeChanged)
        clearCaseQualityFields(caseObjNew,caseObjOld);
    
    }
    
    //This method is used for adding bottler quality user of the associated plant in the case team template
    private static void addPlantCaseTeam(Case caseObjNew,Case caseObjOld){
        String log = '';
        
        Plant__c casePlant = plantRegionByIdMap.get(caseObjNew.Plant__c);
        
        if(casePlant != null){
            String bottlerQualityPlant = casePlant.Region__r.bottler_quality__c; 
            
            String areaPlant = casePlant.Region__r.Area__c;
            
            if(areaPlant != null && areaPlant != ''){
                if((caseObjOld == null && caseObjNew.Plant__c != null ) || (caseObjOld != null && caseObjNew.Plant__c != caseObjOld.Plant__c)){
                    
                    String templateRegion = ECICCommonConstants.CASE_TEAM+' '+areaPlant+' '+ECICCommonConstants.IBERIA_REGION;
                    
                    templateNames.add(templateRegion);
                }
            }
            
            
            if(bottlerQualityPlant != null && bottlerQualityPlant != ''){
                List<CaseTeamMember> teamMember = [select id,memberId from CaseTeamMember where MemberId =: bottlerQualityPlant and ParentId =:caseObjNew.id];
                if(teamMember.size() == 0 && !Test.isRunningTest()){
                    //caseObjNew.test_log__c = 'addQualityCalled '+teamMember.size()+' bottlerQualityPlant='+bottlerQualityPlant;
                    addQualityTeamMember(caseObjNew,ECICCommonConstants.IBERIA_BOTTLER_QUAILITY_ROLEID,bottlerQualityPlant);
                }
            }
        }        
        
    }
    
    private static boolean isCaseTeamNotAdded(List<CaseTeamMember> caseMemberList,Case caseObjNew){
        List<CaseTeamMember> caseMemberListTemp = new List<CaseTeamMember>();
        boolean isMemberNotExists = true;
        List<CaseTeamMember> teamMemberList = [select id,MemberId from CaseTeamMember where ParentId =:caseObjNew.id];
        
        //checking if any of the user exists in case team if added then will be removed and only will be returned true if none of the user exists in case team
        for(Integer j = 0; j < caseMemberList.size(); j++){
            for(Integer k = 0; k < teamMemberList.size(); k++){
                if(caseMemberList.size() > 0 && teamMemberList.size() > 0 && j >= 0 && k >= 0){
                    if(caseMemberList[j].MemberId == teamMemberList[k].MemberId){
                        caseMemberList.remove(j);
                        if(caseMemberList.size() > 0)
                            j--;
                    }
                }
            }
        }
  
        
        if(caseMemberList.size() == 0)
            isMemberNotExists = false;
        return isMemberNotExists;
    }
    /*Method added by Anil Jadhav
      To add Sample Collector in case team based on City    */
    public static void addSampleCollector(Case caseObjNew,Case caseObjOld){
                
                String roleId = ECICCommonConstants.SABU_SAMPLE_COLLECTOR_ROLEID ;
                List<Sample_Collector__c> sampleCollectorCity = [select Id,User_Role__c,Name,User__c from Sample_Collector__c where Geo_Mapping__r.City__c =: caseObjNew.city__c ] ;
                
                For(Sample_Collector__c sc : sampleCollectorCity){
                        CaseTeamMember caseTeamMember = new CaseTeamMember();
                        caseTeamMember.MemberId = sc.User__c;
                        caseTeamMember.ParentId = caseObjNew.id;
                        caseTeamMember.TeamRoleId = SABU_User_vs_Case_Team_Role__c.getValues(sc.User_Role__c).Case_Team_Role_Id__c;
                        caseTeamMemberMap.put(sc.User__c,caseTeamMember); 
                        
                }
    }
    
     @testVisible private static void clearCaseQualityFields(Case c,Case caseObjOld) {
        
        if(!developerName.startsWith(ECICCommonConstants.INQUIRY_DEVNAME) && !developerName.startsWith(ECICCommonConstants.QUALITY_COMPLAINT_DEVNAME) && !developerName.startsWith(ECICCommonConstants.NONQUALITY_COMPLAINT_DEVNAME)){
            
            c.Potential_Risk__c = null;
            c.Risk_Type__c = null;
        }
         
         //Sets  Quality Status to New Complaint when Record type is changed from Inquiry NWEN to Quality Complaint NWEN
         if((developerNameOld.StartsWith(ECICCommonConstants.INQUIRY_DEVNAME) || developerNameOld.StartsWith(ECICCommonConstants.NONQUALITY_COMPLAINT_DEVNAME)) && developerNameOld.contains(ECICCommonConstants.NWEN_REGION)
               && developerName.StartsWith(ECICCommonConstants.QUALITY_COMPLAINT_DEVNAME) && developerName.contains(ECICCommonConstants.NWEN_REGION))
         {
             c.Quality_Status__c = ECICCommonConstants.NEW_COMPLAINT;
             c.Potential_Risk__c = 'No'; 
             //c.Status = 'New';
             c.IMCR_Issue__c = false;
         }
         
         if(RECORD_TYPES_BY_ID_MAP.get(caseObjOld.RecordTypeID).DeveloperName.contains(ECICCommonConstants.QUALITY_COMPLAINT_DEVNAME)){
         
        
             //clear product info
            c.Text_BBE_Date__c = null;
            c.bbe_date__c = null;
            c.production_code__c = null;
            c.production_line__c = null;
            c.plant__c = null;
            c.bottler__c = null;
            c.Production_date__c = null;
            c.Pack_Type__c = null;
            c.Days_Remaining_NWEN__c = null;
            c.Production_Leg__c   = null;
            c.Production_DayNWEN__c = null;
            c.Production_Time__c = null;
            c.Pallet_Code__c = null;
            //c.Promotion__c = null;
            c.CCE_Product__c = null;
            c.Reimbursement_Type__c = null;
            c.Reimbursement_Value__c = null;
            c.Reimbursement_Date__c = null;
            c.Laboratory_of_Analysis_NWEN__c = null;
            c.Lab_Category_Level_1__c = null;
            c.Lab_Category_Level_2__c = null;
            c.Lab_Category_Level_3__c = null;
            c.Lab_Category_Level_4__c = null;
            c.Sample_Received_Date__c = null;
            c.Sample_Storage_Location__c = null;
            c.Overall_Results__c = null;
            c.Intergrum_Reference__c = null;
            c.Can_Base__c = null;
            c.PCF_Reference__c = null;
            c.No_of_Closed_Samples__c = null;
            c.Product_Location__c = null;
            c.Point_of_Sale_CCE_NWEN__c = null;
            c.Quantity_Complained__c = null;
            c.Reason_no_Samples__c = null;
            c.Size_of_box__c = null;
           
            
            //clear Consumer Sample Information
            c.Content_Available__c = false;
            c.Sample_Collected__c = false;
            c.Sample_Collector__c = null;
            c.Package_Available__c = false;
            c.Package_Closed__c = false;
            c.Damage__c = false;
            c.Date_of_Purchase__c = null;
            c.Point_Of_Sale__c = null;
            c.Place_of_Purchase__c = null;
            c.PoS_Key_Account__c = null;
            c.Region_of_Purchase__c = null;
            c.Sample_Comments__c = null;
            c.No_of_Packages__c = null;
            c.Sample_Collection_Date__c = null;
            c.Sample_Arrival_Date__c = null;
            
            //ECIC-2237--26/06/2012 -------------------------->>
            c.Bottler_External_Relations__c  = null;
            c.Bottler_Quality_Owner__c = null;
            c.Distributor_Quality_Manager__c = null;
            c.Distributor_Quality__c = null;
            c.Distributor_External_Relations__c = null;
            //<<------------------------------------------------
            c.bottler_name__c = null;
            c.region_bottler_name__c = null;
            //Quality Information
            c.Quality_Case_Owner__c = null;
            c.Bottler_Quality_Manager__c = null;
            //c.Quality_Status__c = 'New Complaint';
            c.Package_Supplier__c = null;
            c.Closure_Supplier__c = null;
            c.Trend__c = null;
            c.Communicate_to_Infoline__c = false;
            c.Technical_Notes__c = null;
            c.No_Quality_Status_Change__c = false;
            c.Package_Batch__c = null;
            c.Closure_Batch__c = null;
            
            //clear Quality Report 
            c.Date_of_the_report__c = null;
            c.Comments_of_analyst_lab_manager__c = null;
            c.Quality_Technical_Reason__c = null;
            c.Root_Cause_Identification__c = null;
            c.Cause_of_Complaint__c = null;
            c.Process_Type__c = null;
            c.Food_Safety_toxicological__c = false;
            c.Food_Safety_Toxicological_txt__c = null;
            c.Comments_of_analyst_labmgr_full__c = null;
            
            //clear Consumer Sample Analysis
            c.Laboratory_of_Analysis__c = null;
            c.Lab_Reception_Date__c = null;
            c.No_of_Open_Samples__c = null;
            c.No_of_Closed_Samples__c = null;
            c.Retention_Sample__c = false;
            c.Retention_Sample_Txt__c = null;
            c.Shipment_Time__c = null;
            c.Appearance_of_Package__c = false;
            c.Appearance_of_Package_Txt__c = null;
            c.Appearance_of_Product__c = false;
            c.Appearance_of_Product_Txt__c = null;
            c.Sensory_Evaluation__c = false;
            c.Sensory_Evaluation_Txt__c = null;
            c.Chemical_Analysis__c = false;
            c.Chemical_Analysis_Txt__c = null;
            c.Physical_Analysis__c = false;
            c.Physical_Analysis_Txt__c = null;
            c.Microbiological_Analysis__c = false;
            c.Microbiological_Analysis_Txt__c = null;
            c.Health_Risk__c = false;
            c.Health_Risk_Txt__c = null;
            
            //clear hidden fields
            c.Action_Plan__c = null;
            c.Quality_Case_Owner__c = null;
            c.Quality_Admin_Assistant__c = null;
            c.Consumer_Complaint_Manager__c = null;
            
            c.trend_mark__c = null;
            
        }
         
    }
    public static void setLCBUCountries(LCBURegionsMarkets__c lcbuRegionMarket)
    {
            if(lcbuRegionMarket != null)
            {
                CRCountries1 = lcbuRegionMarket.Markets__c;
                tempList = CRCountries1.split(',');
                CRCountries.addAll(tempList);
            }
        
        
    }
    
}