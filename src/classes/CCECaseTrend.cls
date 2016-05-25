/*
Change Description - Class creates and updates Trends for NWEN Quality Complaints on Case Creation / Updation.
Author - Poornima Padki
Change Date - 22/05/2015
*/

global class CCECaseTrend{
//    private static 
    private static final Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);
    private static String developerNameRT;
    private static Set<string> caseProductSet = new Set<string>();
    private static Set<string> caseProdLineSet = new Set<string>();
    private static Set<Date> caseProdDateSet = new Set<Date>();
    private static Set<string> caseCategorySet = new Set<string>();
    private static Set<string> caseStatusSet = new Set<string>();
    private static List<CCE_Trend__c> prevTrendList = new List<CCE_Trend__c>();
    private static List<Case> otherCaseList = new List<Case>();
    private static Set<Case> trendingCaseSet = new Set<Case>();
    private static List<CCE_Trend__c> changeStatusTrendList = new List<CCE_Trend__c>();
    private static boolean checkTrend = False;
    private static Decimal numOpenCase = 0;
    private Static Decimal numTotalCase = 0;
    private Static Boolean changeCaseCount = False;
    private Static Map<Id,Set<Case>> TrendCaseMap = new Map<Id,Set<Case>>();
    private Static List<Case> checkCaseList = new List<Case>();
    private Static List<Case> updateCaseList = new List<Case>();
    private Static List<CCE_Trend__c> trendInsertList = new List<CCE_Trend__c>();
    private Static Boolean CheckCaseCountUpdate = False;
    private Static List<Id> updateCaseCountList = new List<Id>(); 
    private Static List<Id> updateOnlyCaseCountList = new List<Id>();
    private Static Map<Id,CCE_Trend__c> UniqueTrendMap = new Map<Id,CCE_Trend__c>();
    private Static String brandP = '';
    private static String flavourP = '';
    private static string packagingP = '';
    private static string sizeP = '';
    private static string countryCodeP = '';
    private static string prodDayP = '';
   
  /*-----------This code block is for Routing the cases to respective trend classes based on the Case record type---------*/

    private  List<Case> nwenCases = new List<Case>();
    public  List<Case> lcbuCases = new List<Case>();
    public  List<Case> sabuCases = new List<Case>();
    private  List<Case> nwenCasesOld = new List<Case>();
    private  List<Case> lcbuCasesOld = new List<Case>();
    private  List<Case> sabuCasesOld = new List<Case>();
    private static Boolean isNWEN = false;
    private static Boolean isLCBU = false;
    private static Boolean isSABU = false;
    //This method routes newly created cases to respective trend classes bases on recordtypes-- Author-- Sagar Madkaikar
    public static void checkTrendInsert(List<Case> newCases)
    {   
        CCECaseTrend cce = new CCECaseTrend();
        cce = checkCases(newCases);
        //checkCases(newCases);
        
        if(isNWEN){
            insertCaseCheck(cce.nwenCases); //calls insertCaseCheck in same class
                }
        if(isLCBU){
            
            LCBUCaseTrend.insertCaseCheck(cce.lcbuCases);// calls insertCaseCheck of LCBUCaseTrend class
        }
        if(isSABU){
            SABUcaseTrend.insertCaseCheck(cce.sabuCases);// calls insertCaseCheck of SABUCaseTrend class
        }
  
    }
    //This method routes updated cases to respective trend classes bases on recordtypes-- Author-- Sagar Madkaikar
    public static void checkTrendUpdate(List<Case> newCases,List<Case> oldCases)
    {    CCECaseTrend cce = new CCECaseTrend();
         cce = checkCases(newCases);
        For(Case c:oldCases)
        {
            developerNameRT = RECORD_TYPES_BY_ID_MAP.get(c.RecordTypeID).DeveloperName;
            if(developerNameRT == ECICCommonConstants.NWEN_QUALITY_COMPLAINT_DEVNAME)
                cce.nwenCasesOld.add(c);   
            else if(developerNameRT == ECICCommonConstants.LCBU_QUALITY_COMPLAINT_DEVNAME)
                cce.lcbuCasesOld.add(c);  
            else if(developerNameRT == ECICCommonConstants.SABU_QUALITY_COMPLAINT_DEVNAME)
                cce.sabuCasesOld.add(c);
        }
        
        
        if(isNWEN){
            updateCaseCheck(cce.nwenCases,cce.nwenCasesOld); //calls updateCaseCheck in same class
        }
        if(isLCBU){
            LCBUCaseTrend.updateCaseCheck(cce.lcbuCases,cce.lcbuCasesOld);// calls updateCaseCheck of LCBUCaseTrend class
        }
        if(isSABU){
            SABUCaseTrend.updateCaseCheck(cce.sabuCases,cce.sabuCasesOld);// calls updateCaseCheck of SABUCaseTrend class
        }
    }
    
    //This method checks the record types of cases..... Author - Sagar Madkaikar
    private static CCECaseTrend checkCases(List<Case> newCases)       
    {
        CCECaseTrend cce = new CCECaseTrend();
        For(Case c:newCases)
        {
            developerNameRT = RECORD_TYPES_BY_ID_MAP.get(c.RecordTypeID).DeveloperName;
            if(developerNameRT == ECICCommonConstants.NWEN_QUALITY_COMPLAINT_DEVNAME)
            {
                cce.nwenCases.add(c);
                isNWEN = true;
            }
            else if(developerNameRT == ECICCommonConstants.LCBU_QUALITY_COMPLAINT_DEVNAME)
            {
                
                //cce.lcbuCases.add(c);
                cce.lcbuCases.add(c);
                
                isLCBU = true;
            }   
            else if(developerNameRT == ECICCommonConstants.SABU_QUALITY_COMPLAINT_DEVNAME)
            {
                
                cce.sabuCases.add(c);
                isSABU = true;
            }  
        }
        
        return cce;
    }
   /* ---------------------------------------------------------------------------------------------------*/
    
    public static void insertCaseCheck(List<Case> newCases){
    try{
        //check if any trend is associated, if not, then call checkCreateTrend Method
        for(Case cInst:newCases){
            developerNameRT = RECORD_TYPES_BY_ID_MAP.get(cInst.RecordTypeID).DeveloperName;
            
            if(developerNameRT == ECICCommonConstants.NWEN_QUALITY_COMPLAINT_DEVNAME || developerNameRT == ECICCommonConstants.SABU_QUALITY_COMPLAINT_DEVNAME){
                //remove any existing trend associated to new Casee, cloning of case also clones Trend Details
                if(cInst.CCE_Trend__c != Null){
                    cInst.CCE_Trend__c = Null;
                    cInst.CCE_Trend_Association_Date__c = Null;
                }
                //if status is not cancelled, new and none of the matching parameters are null(like in case of unknown products)
                if(cInst.Status != ECICCommonConstants.STATUS_CANCELLED && cInst.Status != ECICCommonConstants.STATUS_NEW && (cInst.Flavour_Product__c != Null) && (cInst.Product_Brand__c != Null) && (cInst.Packaging__c!= Null) && (cInst.Size_Product__c != Null) && (cInst.Production_Date__c != Null)){
                    checkTrend = True;
                    caseProductSet.add(cInst.CCE_Product__c);
                    caseProdLineSet.add(cInst.Production_Line__c);
                    caseProdDateSet.add(cInst.Production_Date__c);
                    caseCategorySet.add(cInst.Category_Level3__c);
                    caseStatusSet.add(ECICCommonConstants.STATUS_CANCELLED);
                    caseStatusSet.add(ECICCommonConstants.STATUS_NEW);
                }
                
            }    
        }        
    if(checkTrend == True){
            checkCreateTrend(newCases);
        }
        
        TriggerContextUtility.setFirstRunFalse();
        }
        catch(DMLException e ){
            Id caseId = e.getDMLId(0);
            Case caseRec = [SELECT Id,CaseNumber FROM Case WHERE ID =: caseId];
            for(Case caseInst:newCases){
                if(caseInst.Id != caseid){
                    caseInst.adderror(e.getDMLMessage(0)+' for Case ' + caseRec.CaseNumber);
                }
                else{
                    caseInst.adderror(e.getDmlMessage(0));
                }
            }
        }
    }
    
    //method call on update of case from Case Trigger
    public static CCECaseTrend updateCaseCheck(List<Case> newCases,List<Case> oldCases)
    {
        try
        {
            //nullify the boolean value that leads to trend creation / association
            checkTrend = False;
            //to avoid recursion
            if(TriggerContextUtility.isFirstRun() || Test.isRunningTest())
            {
                if(newCases.size() > 0)
                {
                    for(Case cInst:newCases)
                    {
                        developerNameRT = RECORD_TYPES_BY_ID_MAP.get(cInst.RecordTypeID).DeveloperName;
                        //if status is not new and none of the matching parameters are null(like in case of unknown products)
                        if((developerNameRT == ECICCommonConstants.NWEN_QUALITY_COMPLAINT_DEVNAME || developerNameRT == ECICCommonConstants.SABU_QUALITY_COMPLAINT_DEVNAME) && cInst.Status != ECICCommonConstants.STATUS_NEW && (cInst.Flavour_Product__c != Null) && (cInst.Product_Brand__c != Null) && (cInst.Packaging__c!= Null) && (cInst.Size_Product__c != Null) && (cInst.Production_Date__c != Null))
                        {                       
                            //in case of Trend already associated but change in Case parameters / status
                            if(cInst.CCE_Trend__c != Null)
                            {                               
                                //if case status is cancelled, deassociate Trend on Case
                                if(cInst.Status == ECICCommonConstants.STATUS_CANCELLED)
                                {
                                    updateCaseCountList.add(cInst.CCE_Trend__c);
                                    CheckCaseCountUpdate = True;
                                }
                                else
                                {
                                    for(Case oldCInst:oldCases)
                                    {
                                        if(cInst.Id == oldCInst.Id)
                                        {                                       
                                            //In case of Status Change, need to update Case Count on Trend Record
                                            if(cInst.Status != oldCInst.Status)
                                            {                                               
                                                updateOnlyCaseCountList.add(cInst.CCE_Trend__c);
                                                changeCaseCount = True;
                                
                                            }
                                             
                                             //in case of parameter change of case, deassociate case from trend and check if it needs to be associate with new trend.
                                             if(cInst.CCE_Product__c != oldCInst.CCE_Product__c || cInst.Production_Line__c != oldCInst.Production_Line__c || cInst.Production_Date__c != oldCInst.Production_Date__c || cInst.Category_Level3__c != oldCInst.Category_Level3__c)
                                            {                                                
                                                 updateCaseCountList.add(cInst.CCE_Trend__c);
                                                 CheckCaseCountUpdate = True;
                                                 checkTrend = True;
                                            }
                                        }
                                    }
                                }
                            }                               
                            //if any Trend is not associated with this case
                            else
                            {
                                if(cInst.Removed_from_Trend__c == True)
                                {
                                    for(Case oldCInst:oldCases)
                                    {                                   
                                        //if Case is removed from Trend and Parameters change, to Uncheck the Removed from Trend Checkbox
                                        if(cInst.CCE_Product__c != oldCInst.CCE_Product__c || cInst.Production_Line__c != oldCInst.Production_Line__c || cInst.Production_Date__c != oldCInst.Production_Date__c || cInst.Category_Level3__c != oldCInst.Category_Level3__c)
                                        {
                                             cInst.Removed_from_Trend__c = False;
                                             //checkTrend = True;
                                        }
                                    }
                                }
                               if(cInst.Removed_from_Trend__c == False && cInst.CCE_Trend_Association_Date__c == Null && cInst.status !=ECICCommonConstants.STATUS_CANCELLED)
                                  {
                                    for(Case oldCInst:oldCases)
                                    {
                                        if(cInst.Id == oldCInst.Id)
                                        {
                                        
                                            //if case's status changes(mainly new-to-open scenario or other parameters change such that a trend with those parameters might exist in the system
                                            if(cInst.Status != oldCInst.Status || cInst.CCE_Product__c != oldCInst.CCE_Product__c || cInst.Production_Line__c != oldCInst.Production_Line__c || cInst.Production_Date__c != oldCInst.Production_Date__c || cInst.Category_Level3__c != oldCInst.Category_Level3__c || cInst.Removed_from_Trend__c != oldcInst.Removed_from_Trend__c){
                                                checkTrend = True;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if(CheckCaseCountUpdate == True)
                {            
                    //to udpate Case Count on Trend once Case is deassociated from Trend
                    CountCaseOnTrendDeasso(updateCaseCountList,newCases);
                }
                if(changeCaseCount == True)
                {
                    //Change Case Count on Trend for Case Status's Change
                    changeOnlyCaseCount(updateOnlyCaseCountList,newCases,oldCases);
                }
                if(checkTrend == True)
                {
                    for(Case cInst:newCases)
                    {                
                        //sets the match parameters
                        caseProductSet.add(cInst.CCE_Product__c);
                        caseProdLineSet.add(cInst.Production_Line__c);
                        caseProdDateSet.add(cInst.Production_Date__c);
                        caseCategorySet.add(cInst.Category_Level3__c);
                        caseStatusSet.add(ECICCommonConstants.STATUS_CANCELLED);
                        caseStatusSet.add(ECICCommonConstants.STATUS_NEW);
                    }
                    //call the method where Trend is created/associated with case
                    checkCreateTrend(newCases);
                }           
            }
        }
        catch(DMLException e )
        {
            Id caseId = e.getDMLId(0);
            Case caseRec = [SELECT Id,CaseNumber FROM Case WHERE ID =: caseId];
            for(Case caseInst:newCases)
            {
                if(caseInst.Id != caseid)
                {
                        caseInst.adderror(e.getDMLMessage(0)+' for Case ' + caseRec.CaseNumber);
                 }
                else
                {
                    caseInst.adderror(e.getDmlMessage(0));
                }
            }
        }
        return null;
    }
        
        //to check if any trend exists with matching parameters or create new trend
        public static void checkCreateTrend(List<Case> newCases){
        //Check if any Trend exists with the Trend Parameters
        prevTrendList = [SELECT Id,Name,CCE_Product__c,Brand__c,Packaging__c,Flavour__c,Size__c,Production_Line__c,Production_Date__c,Category_Level_3__c,Status__c,No_of_Open_Cases__c,No_of_Total_Cases__c FROM CCE_Trend__c WHERE (Production_Date__c IN:caseProdDateSet AND Production_Line__c IN: caseProdLineSet AND Category_Level_3__c IN: caseCategorySet) ];
        
        if(prevTrendList.size()>0){
            for(Case cInst:newCases){
                
                for(CCE_Trend__c tInst:prevTrendList){
                    //check if trend and case parameters match
                    if(cInst.Product_Brand__c == tInst.Brand__c && cInst.Flavour_Product__c == tInst.Flavour__c && cInst.Packaging__c == tInst.Packaging__c && cInst.Size_Product__c == tInst.Size__c && cInst.Production_Line__c == tInst.Production_Line__c && cInst.Production_Date__c == tInst.Production_Date__c && cInst.Category_Level3__c == tInst.Category_Level_3__c){
                        
                        cInst.CCE_Trend__c = tInst.Id;
                        cInst.CCE_Trend_Association_Date__c = system.today();
                        cInst.Removed_from_Trend__c = False;
                        changeCaseCount = True;
                        
                        //count the number of open cases
                        if(cInst.Status != ECICCommonConstants.STATUS_CLOSED){
                            tInst.No_of_Open_Cases__c = tInst.No_of_Open_Cases__c + 1;
                        }
                        //count the number of closed cases
                        tInst.No_of_Total_Cases__c = tInst.No_of_Total_Cases__c + 1;
                        if((tInst.Status__c == ECICCommonConstants.TREND_STATUS_INACTIVE || tInst.Status__c == ECICCommonConstants.TREND_STATUS_CANCELLED) && tInst.No_of_Total_Cases__c >2){
                            tInst.Status__c = ECICCommonConstants.TREND_STATUS_ACTIVE;
                        }
                            // to avoid duplicates in Trend
                            UniqueTrendMap.put(tInst.Id,tInst);                                             
                    }
                }
            }
            update UniqueTrendMap.values();
        }
        
        else{   
        List<id> trendIdList = new List<Id>();
            //cases that have same matching parameters as the current case
            otherCaseList = [SELECT Id,CCE_Product__c,CCE_Product__r.Flavour__c,Flavour_Product__c,CCE_Product__r.Brand__c,Product_Brand__c,CCE_Product__r.Size__c,Size_Product__c,CCE_Product__r.Packaging__c,Packaging__c,Production_Line__c,Production_Line__r.Name,Production_Date__c,Category_Level3__c,Status,CCE_Trend_Association_Date__c,Plant__r.Country_Code__c, Production_DayNWEN__c FROM Case WHERE (Category_Level3__c IN: caseCategorySet AND Production_Line__c IN: caseProdLineSet AND Production_Date__c IN: caseProdDateSet AND CCE_Product__c IN: caseProductSet AND Removed_from_Trend__c =: False AND (Status NOT IN:caseStatusSet))];
            //otherCaseList = [SELECT Id,CCE_Product__c,CCE_Product__r.Flavour__c,Flavour_Product__c,CCE_Product__r.Brand__c,Product_Brand__c,CCE_Product__r.Size__c,Size_Product__c,CCE_Product__r.Packaging__c,Packaging__c,Production_Line__c,Production_Line__r.Name,Production_Date__c,Category_Level3__c,Status,CCE_Trend_Association_Date__c,Plant__r.Country_Code__c, Production_DayNWEN__c FROM Case];
            //otherCaseList = [SELECT Id,Subject FROM Case];
             /*Error_log__c log = new Error_log__c();
                            log.Error_Description__c = 'error now' + otherCaseList[0].Subject;
                            insert log;*/
            if(otherCaseList.size()>1){
            //reached the parameters
               /*Error_log__c log = new Error_log__c();
                            log.Error_Description__c = 'error now' + otherCaseList[0].Category_Level3__c;
                            insert log;            */
                   
            
                for(Case cInst:newCases){
                    
                    cInst.Removed_from_Trend__c = False;
                    numOpenCase = 0;
                    numTotalCase = 0;
                    if(cInst.Status != ECICCommonConstants.STATUS_CLOSED){
                        //open case count for current case 
                        numOpenCase = 1;
                    }
                    //total case count for current case
                    numTotalCase = 1;
                    trendingCaseSet = new Set<Case>();
                    for(Case coInst: otherCaseList){
                        if(coInst.Id != cInst.Id){
                            /*if(cInst.CCE_Product__c != Null && coInst.CCE_Product__c != Null && cInst.Production_Line__c != Null && coInst.Production_Line__c != Null && cInst.Production_Date__c != Null && coInst.Production_Date__c != Null && cInst.Category_Level3__c != Null && coInst.Category_Level3__c != Null){*/
                                if(cInst.Product_Brand__c == coInst.Product_Brand__c && cInst.Size_Product__c == coInst.Size_Product__c &&  cInst.Flavour_Product__c == coInst.Flavour_Product__c && cInst.Packaging__c == coInst.Packaging__c && cInst.Production_Line__c == coInst.Production_Line__c && cInst.Production_Date__c == coInst.Production_Date__c && cInst.Category_Level3__c == coInst.Category_Level3__c){
                                    
                                    //some values  to be inserted on Trends
                                    brandP = coInst.CCE_Product__r.Brand__c;
                                    flavourP = coInst.CCE_Product__r.Flavour__c;
                                    sizeP = coInst.CCE_Product__r.Size__c;
                                    countryCodeP = coInst.Plant__r.Country_Code__c;
                                    packagingP = coInst.CCE_Product__r.Packaging__c;
                                    prodDayP =  coInst.Production_DayNWEN__c;
                                    if(coInst.Status != ECICCommonConstants.STATUS_CLOSED){
                                        numOpenCase = numOpenCase + 1;
                                    }
                                    numTotalCase  = numTotalCase + 1;
                                    
                                    trendingCaseSet.add(coInst);
                                    
                                }
                        
                            /*}*/
                        }
                        
                    }
                        if(!trendingCaseSet.contains(cInst)){
                            trendingCaseSet.add(cInst);
                        }
                    if(trendingCaseSet.size()>2){
                        
                        //create a new Trend 
                        CCE_Trend__c newTrend = new CCE_Trend__c();
                        newTrend.name = cInst.Category_Level3__c;
                        newTrend.Brand__c = brandP;
                        newTrend.Flavour__c = flavourP;
                        newTrend.Packaging__c = packagingP;
                        newTrend.Size__c = sizeP;
                        newTrend.Production_Line__c = cInst.Production_Line__c;
                        newTrend.Production_Date__c = cInst.Production_Date__c;
                        newTrend.Category_Level_3__c = cInst.Category_Level3__c;
                        newTrend.Plant__c = cInst.Plant__c;
                        newTrend.Country_Code__c = countryCodeP;
                        newTrend.Production_Day__c = prodDayP;
                        newTrend.Status__c = 'Active';
                        newTrend.No_of_Total_Cases__c = numTotalCase;
                        newTrend.No_of_Open_Cases__c = numOpenCase;
                        trendInsertList.add(newTrend);
                        
                        cInst.is_Trend_Creator_Case__c = TRUE; //mark case as the trend creator.used to fire workflow to send email alert to site QESH NWEN.
                    }      
                }
                insert trendInsertList;
                Set<Case> CaseTrendAstnSet = new Set<Case>();
                
                //for Trend case association map, once trend id is available
                for(CCE_Trend__c tInst:trendInsertList){
                    trendIdList.add(tinst.Id);
                    for(Case cChInst:trendingCaseSet){
                        if(cChInst.Product_Brand__c == tInst.Brand__c && cChInst.Size_Product__c == tInst.Size__c && cChInst.Flavour_Product__c == tInst.Flavour__c && cChInst.Packaging__c == tInst.Packaging__c && cChInst.Production_Line__c == tInst.Production_Line__c && cChInst.Production_Date__c == tInst.Production_Date__c && cChInst.Category_Level3__c == tInst.Category_Level_3__c){
                            CaseTrendAstnSet.add(cChInst);      
                        }
                    }
                   TrendCaseMap.put(tInst.Id,CaseTrendAstnSet);
                }
                //call method that associates trends to all cases
                attachTrendToAllCases(trendIdList,TrendCaseMap,newCases);
               
            }
        }
    }
    
    //associates trends to cases
    public static void attachTrendToAllCases(List<Id> trendId,Map<Id,Set<Case>> TrendCaseMapCheck,List<Case> newCaseList){
            for(Id trendIdInst:trendId){
                Set<Case> caseSetRef = TrendCaseMapCheck.get(trendIdInst);
                for(Case caseSetInst:CaseSetRef){
                    caseSetInst.CCE_Trend__c = trendIdInst;
                    caseSetInst.CCE_Trend_Association_Date__c = system.today();
                    checkCaseList.add(caseSetInst);
                }
            }
            
            for(Case cInst:newCaseList){
                for(Case coInst:checkCaseList){
                    if(cInst.Id != coInst.id){
                        updateCaseList.add(coInst);
                    }
                }
            }
            update updateCaseList;
            
    }
    
    //updates case count on trend on case status update
    public static void changeOnlyCaseCount(List<Id> TrendId,List<Case> newCaseList, List<Case> oldCaseList){
        List<CCE_Trend__c> OnlyCaseCountList = new List<CCE_Trend__c>();
        List<CCE_Trend__c> finalUpdateList = new List<CCE_Trend__c>();
        decimal changedOpenCaseCount = 0;
        decimal changedTotalCaseCount = 0;
        decimal existingOpenCasesCount = 0;
        boolean newStatusNotClosed = false;
        OnlyCaseCountList = [SELECT Id,Name,Status__c,No_of_Open_Cases__c,No_of_Total_Cases__c FROM CCE_Trend__c WHERE ID IN: TrendId];
        for(CCE_Trend__c tInst:OnlyCaseCountList){
            changedOpenCaseCount = 0;       
            existingOpenCasesCount = tInst.No_of_Open_Cases__c;
            
            for(Case cInst:newCaseList){
                if(cInst.CCE_Trend__c == tInst.Id){
                    
                    if(cInst.Status == ECICCommonConstants.STATUS_CLOSED){
                        //count the number of cases that are closed
                        changedOpenCaseCount = changedOpenCaseCount + 1;                       
                    }
               }
           }
           if(tInst.No_of_Open_Cases__c - changedOpenCaseCount != existingOpenCasesCount){
               //reduce the total number of open cases from trend
               tInst.No_of_Open_Cases__c = existingOpenCasesCount - changedOpenCaseCount;
               finalUpdateList.add(tInst);
           }
           //for Case's old Status
           changedOpenCaseCount = 0;
           existingOpenCasesCount = tInst.No_of_Open_Cases__c;
           for(Case cInst:oldCaseList){
               if(cInst.CCE_Trend__c == tInst.Id){
                    
                    if(cInst.Status == ECICCommonConstants.STATUS_CLOSED){
                        //count the number of cases that were closed before, now open
                        changedOpenCaseCount = changedOpenCaseCount + 1;                       
                    }
               }
           }
               if(tInst.No_of_Open_Cases__c + changedOpenCaseCount != existingOpenCasesCount){
                   //increase the total number of open cases in trend
                   tInst.No_of_Open_Cases__c = existingOpenCasesCount + changedOpenCaseCount;
                   finalUpdateList.add(tInst);
               }
           
       }                 
        update finalUpdateList;
    }
   
    //counts the number of case on Trend Deassociation
    public static void CountCaseOnTrendDeasso(List<Id> TrendId,List<Case> newCasesList){
        decimal reducedTotalCaseCount = 0;
        decimal reducedOpenCaseCount = 0;
        decimal originalTotalCaseCount = 0;
        List<CCE_Trend__c> updateTrendCaseCountList = new List<CCE_Trend__c>();
        changeStatusTrendList = [SELECT Id,Name,Status__c,No_of_Open_Cases__c,No_of_Total_Cases__c FROM CCE_Trend__c WHERE ID IN: TrendId];
        for(CCE_Trend__c tInst:changeStatusTrendList){
            originalTotalCaseCount = tInst.No_of_Total_Cases__c;
            reducedTotalCaseCount = 0;
            reducedOpenCaseCount = 0;
            for(Case cInst:newCasesList){
                if(cInst.CCE_Trend__c == tInst.Id){
                    cInst.CCE_Trend__c = Null;
                    cInst.CCE_Trend_Association_Date__c = Null;
                    reducedTotalCaseCount = reducedTotalCaseCount + 1;
                    if(cInst.Status != ECICCommonConstants.STATUS_CLOSED){
                        reducedOpenCaseCount = reducedOpenCaseCount + 1;    
                    }
                    //need to consider scenario where status of case has changed to closed from open,, in above logic, not here
                }
                
            }
                if((tInst.No_of_Total_Cases__c - reducedTotalCaseCount) != originalTotalCaseCount){
                    tInst.No_of_Total_Cases__c = tInst.No_of_Total_Cases__c - reducedTotalCaseCount;
                    tInst.No_of_Open_Cases__c = tInst.No_of_Open_Cases__c - reducedOpenCaseCount;
                    if(tInst.No_of_Total_Cases__c < 3)
                    {
                        tInst.Status__c = ECICCommonConstants.TREND_STATUS_CANCELLED;
                    }
                    else{
                        tInst.Status__c = ECICCommonConstants.TREND_STATUS_ACTIVE;
                    }
                    updateTrendCaseCountList.add(tInst);
            }
        
        }
        update updateTrendCaseCountList;
        
        
    }
    //Button Click on Trend Page Layout on Case Related List - to remove Case - Trend Association for marked Cases
    Webservice static void RemoveCaseFromTrend(Id[] Ids){
        List<Case> RemoveCaseList = new List<Case>();
        List<Case> CaseList = [Select id,CCE_Trend__c,Status from Case WHERE Id IN:Ids];
        Id TrendId = CaseList[0].CCE_Trend__c;
        List<CCE_Trend__c> TrendInstList = [SELECT Id,Status__c,No_of_Open_Cases__c,No_of_Total_Cases__c FROM CCE_Trend__c WHERE ID =: TrendId limit 1];
        if(TrendInstList.size()>0)
         {
        CCE_Trend__c TrendInst = TrendInstList.get(0);
        decimal OpenCases = 0;
        decimal TotalCases = 0;
         
            for(Case caseInst:CaseList){
                    CaseInst.CCE_Trend__c = Null;
                    caseInst.CCE_Trend_Association_Date__c = Null;
                    CaseInst.Removed_from_Trend__c = True;
                RemoveCaseList.add(CaseInst);
                if(CaseInst.Status !=ECICCommonConstants.STATUS_CLOSED){
                    OpenCases = OpenCases + 1;
                }
                TotalCases = TotalCases + 1;
            }
            
            TrendInst.No_of_Open_Cases__c = TrendInst.No_of_Open_Cases__c - OpenCases;
            TrendInst.No_of_Total_Cases__c = TrendInst.No_of_Total_Cases__c - TotalCases;
            if(TrendInst.No_of_Total_Cases__c < 3){
                TrendInst.Status__c = ECICCommonConstants.TREND_STATUS_CANCELLED;
            }
   
            update TrendInst;
            update RemoveCaseList;   
         }
    }
}