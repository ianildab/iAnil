public with sharing class HUB_RatingController {
        public HUB_Learning_Ratings__c objRating {get;set;}
        public HUB_Best_Practices__c objLearning{get;set;} //added
        public Integer totalRecord {get;set;}//added
        public Id recordId {get;set;}
        public Decimal total {get;set;}
        public Boolean isUpsert {get;set;}
        public Decimal averageRating {get;set;}
        
        public HUB_RatingController (ApexPages.StandardController controller) {
                total = 0;
                isUpsert =  false;
                averageRating = 0;
                recordId = ApexPages.currentPage().getParameters().get('Id');
                objLearning = [select id, Total_Rating__c from HUB_Best_Practices__c where Id =:recordId];//modified
                totalRecord = [select count() from HUB_Learning_Ratings__c where  Learning__c =: recordId]; //modified
                if(objLearning.Total_Rating__c != null && totalRecord != 0){
                        
                        //get total from learning rollup summary and divded by count + scale to 1 decimal palce
                        averageRating = (objLearning.Total_Rating__c/totalRecord).setScale(1, RoundingMode.HALF_UP);
                        
                }
                
                
                list<HUB_Learning_Ratings__c> lstRating = [select id, Learning__c, Ratings__c , User__c from HUB_Learning_Ratings__c
                                        where Learning__c =: recordId and User__c =: UserInfo.getUserId()];
                                        system.debug(lstRating.size()+'list size==');
                                        if(lstRating.size() > 0){
                                                objRating = lstRating[0];
                                                chatterOpt = string.valueOf(objRating.Ratings__c);
                                                isUpsert =  true;
                                        }
        }
        
        // save rating for learning
        public void saveRating(){
            system.debug(chatterOpt+'chatterOpt+++');
                if(chatterOpt == '0'){
                            delete objRating;
                            isUpsert = false;
                        }
                else{
                     if(isUpsert){
                            objRating.Ratings__c =Decimal.valueOf(chatterOpt);
                            update objRating;     
                    }else{
                            objRating = new HUB_Learning_Ratings__c();
                            objRating.Learning__c = recordId;
                            objRating.User__c = UserInfo.getUserId();  
                            objRating.Ratings__c =Decimal.valueOf(chatterOpt);
                            insert objRating;
                            isUpsert = true;
                    }
                }
               
                //added 
                objLearning = [select id, Total_Rating__c,Average__c,Total_Vote__c from HUB_Best_Practices__c where Id =:recordId];
                totalRecord = [select count() from HUB_Learning_Ratings__c where  Learning__c =: recordId];
                if(objLearning.Total_Rating__c != null && totalRecord != 0){
                        
                        //get total from learning rollup summary and divded by count + scale to 1 decimal palce
                        averageRating = (objLearning.Total_Rating__c/totalRecord).setScale(1, RoundingMode.HALF_UP);
                        objLearning.Average__c = averageRating;
                        objLearning.Total_Vote__c = totalRecord;
                        update objLearning;
                }else{
                    objLearning.Average__c = 0;
                    objLearning.Total_Vote__c = 0;
                    update objLearning;
                    averageRating = 0;
                }
                
        }
        
        //setting the value of ratings
        public String chatterOpt{get;set;}
        public List<SelectOption> getChatterOptions() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('0','-' ));
            options.add(new SelectOption('1','1'));
            options.add(new SelectOption('2','2'));
            options.add(new SelectOption('3','3'));
            options.add(new SelectOption('4','4'));
            options.add(new SelectOption('5','5'));
            return options;
        }
}