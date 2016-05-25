@isTest
public class HUB_TranslateCaseClsTest{
    public static HUB_TranslateCaseCls  ext;
    public static PageReference page;
    public static Case caseObject;
    public static Account accountObject;
    public static id caseId;
    
   public static List<RecordType> rt = [select id,Name from RecordType where SobjectType='Case' and Name='HUB_Issue_Tracker' Limit 1];
    
    public static void testCaseSubjectAndDescriptionTranslation(){
        Case cs = new Case( Subject ='Αυτό είναι φοβερό',Description ='Αυτό είναι φοβερό',HUB_Risk_type__c ='Opportunity', HUB_Category__c ='Business', HUB_Issue__c ='Obesity', Origin ='Call Center', Priority ='Medium', Status ='New', HUB_Risk__c= 'Green',HUB_Channel__c ='Traditional Media', HUB_Velocity__c='Low', HUB_Impact__c='Category',HUB_Region__c ='Global' , HUB_Business_Unit__c='Global',HUB_Country__c ='Global');
        
        Test.startTest();
        insert cs;
        caseId = cs.Id;
        
        page = new PageReference(caseId);
        System.test.setCurrentpage(page);
         
        ApexPages.standardController controller = new ApexPages.StandardController(cs);
        ext = new HUB_TranslateCaseCls(controller);
        Test.stopTest();
       // System.assertEquals(cs.Subject_Auto_Translate_EN__c, 'This is awesome');
    }
    
    
}