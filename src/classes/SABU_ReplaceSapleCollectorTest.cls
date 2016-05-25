@isTest
public class SABU_ReplaceSapleCollectorTest {
    static testMethod void replaceSC()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
      User u1 = new User(Alias = 'standt1', 
                        Email='standarduser1@testorg.com', 
                                                                                EmailEncodingKey='UTF-8', 
                        LastName='Testing2', 
                        LanguageLocaleKey='en_US', 
                                                                                LocaleSidKey='en_US', 
                         Country_Code__c='ZA',
                         Enabled_Countries__c='ZA; BW; NA; LS; SZ; ZW; ZM; MW; AO',
                         
                        ProfileId = p.Id, 
                                                                                TimeZoneSidKey='America/Los_Angeles', 
                        UserName='cokestandarduser1@testorg.com');
                        insert u1;
      
      User u2 = new User(Alias = 'standt2', 
                        Email='standarduser2@testorg.com', 
                                                                                EmailEncodingKey='UTF-8', 
                        LastName='Testing2', 
                        LanguageLocaleKey='en_US', 
                                                                                LocaleSidKey='en_US', 
                         Country_Code__c='ZA',
                         Enabled_Countries__c='ZA; BW; NA; LS; SZ; ZW; ZM; MW; AO',
                         
                        ProfileId = p.Id, 
                                                                                TimeZoneSidKey='America/Los_Angeles', 
                        UserName='cokestandarduser2@testorg.com');
                        insert u2;
        User u3 = new User(Alias = 'standt3', 
                        Email='standarduser3@testorg.com', 
                                                                                EmailEncodingKey='UTF-8', 
                        LastName='Testing3', 
                        LanguageLocaleKey='en_US', 
                                                                                LocaleSidKey='en_US', 
                         Country_Code__c='IA',
                         Enabled_Countries__c='',
                         
                        ProfileId = p.Id, 
                                                                                TimeZoneSidKey='America/Los_Angeles', 
                        UserName='cokestandarduser3@testorg.com');
                        insert u3;
        
	    City__c city = new City__c(CountryCode__c='ZA', Name='Test City');  
        insert city;
        
        Plant__c p1 = new Plant__c(Active__c = true,
                              name = 'TestPlant ',
                              Country_Code__c = 'ZA'
                              );
        insert p1;
        
        Geo_Mapping__c geomapping = new Geo_Mapping__c(City__c = city.Id, Plant__c = p1.Id  ,Unique_City__c='test' );
        insert geomapping;
        
        Sample_Collector__c sc = new Sample_Collector__c( Geo_Mapping__c= geomapping.Id , User__c = u1.Id);
        insert sc;
        
        Sample_Collector__c sc1 = new Sample_Collector__c( Geo_Mapping__c= geomapping.Id , User__c = u3.Id);
        insert sc1;
        
        List<SABU_Replace_Sample_Collector__c> srsc= new List<SABU_Replace_Sample_Collector__c>();
        srsc.add(new SABU_Replace_Sample_Collector__c(User_To_Be_Replaced__c = u1.Id));
        srsc.add(new SABU_Replace_Sample_Collector__c(User_Who_Will_Replace__c = u2.Id));
   		insert srsc;
        SABU_ReplaceSampleCollector.replaceSampleCollectorAfterInsert(srsc);
        
        List<SABU_Replace_Sample_Collector__c> srsc1= new List<SABU_Replace_Sample_Collector__c>();
        srsc1.add(new SABU_Replace_Sample_Collector__c(User_To_Be_Replaced__c = u2.Id));
        srsc1.add(new SABU_Replace_Sample_Collector__c(User_Who_Will_Replace__c = u3.Id));
   		insert srsc1;
        try{
        SABU_ReplaceSampleCollector.replaceSampleCollectorAfterInsert(srsc1);
        }catch(Exception e){
            Boolean expectedException =  e.getMessage().contains('There is no sample collector present with this User.') ? true : false;
			System.AssertEquals(expectedException, true);
      
            
        }
        
        List<SABU_Replace_Sample_Collector__c> srsc3= new List<SABU_Replace_Sample_Collector__c>();
        srsc3.add(new SABU_Replace_Sample_Collector__c(User_To_Be_Replaced__c = u3.Id));
        srsc3.add(new SABU_Replace_Sample_Collector__c(User_Who_Will_Replace__c = u2.Id));
   		insert srsc3;
        try
        {
       		SABU_ReplaceSampleCollector.replaceSampleCollectorAfterInsert(srsc3);
        }
        catch(Exception e)
        {
           	Boolean expectedException =  e.getMessage().contains('User should be from same Business Unit') ? true : false;
			System.AssertEquals(expectedException, true);
                
            
        }


    }
}