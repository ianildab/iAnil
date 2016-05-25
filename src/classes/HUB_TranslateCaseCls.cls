public with sharing class HUB_TranslateCaseCls {

    public String subject{get;set;}
    public String outputSubject{set;get;}
    public String sourceLanguage{set;get;}
    public Case thisCase{get;set;}
    public String id;
    
    public HUB_TranslateCaseCls(ApexPages.StandardController stdController) {
         id= stdController.getId();    
    } // end of method

    public void translateNupdate(){
        
         thisCase = [select Id,Subject,Description,Subject_Auto_Translate_EN__c,isDescriptionChange__c,isSubjectChange__c,Description_Auto_Translate_EN__c,Reason,CategoryLevel3__c from Case where id=:id limit 1];
        //Translate subject
         System.debug('Subject: ' + thisCase.Subject);
         if(thisCase.isDescriptionChange__c || thisCase.isSubjectChange__c ){
            if(thisCase.Subject!=null){
                 if(thisCase.isSubjectChange__c){
                     String s=thisCase.Reason + '-' + thisCase.CategoryLevel3__c;
                     String ss=thisCase.Subject.replace(s,'');
                     System.debug('ssss  '+ss);
                     sourceLanguage=HUB_TranslateUtil.googleDetectTextLanguage(ss);
                     if(sourceLanguage == 'en'){
                            thisCase.Subject_Auto_Translate_EN__c = '';
                            
                     }else{
                             if(sourceLanguage!=null){
                                 String output;
                                 output=HUB_TranslateUtil.googleTranslateText(sourceLanguage,ss);
                                 if(output!=null){
                                     output=output.replaceAll('&#39;','\'');
                                     output=output.replaceAll('&quot;','\'');
                                     thisCase.Subject_Auto_Translate_EN__c= output;
                                     
                                 }
                             }else{
                                 thisCase.Subject_Auto_Translate_EN__c='System could not recognize the Subject language';
                                 }
                     }
                     
                }
            }    
         // Translate Description
         sourceLanguage=null;
         if(thisCase.Description!=null){
             if(thisCase.isDescriptionChange__c){
                 sourceLanguage=HUB_TranslateUtil.googleDetectTextLanguage(thisCase.Description);
                 if(sourceLanguage == 'en'){
                        thisCase.Description_Auto_Translate_EN__c = '';
                        }else{
                     if(sourceLanguage!=null){
                         String output=HUB_TranslateUtil.googleTranslateText(sourceLanguage,thisCase.Description);
                         if(output!=null){
                             output=output.replaceAll('&#39;','\'');
                             output=output.replaceAll('&quot;','\'');
                             thisCase.Description_Auto_Translate_EN__c=output;
                             }
                     }else{
                         thisCase.Description_Auto_Translate_EN__c='System could not recognize the Description language';
                         
                     }
                 }
               }  
               
         }
            
            thisCase.isDescriptionChange__c =false;
            thisCase.isSubjectChange__c =false;
            Database.update(thisCase);
            }
            
        
    }

} // end of class