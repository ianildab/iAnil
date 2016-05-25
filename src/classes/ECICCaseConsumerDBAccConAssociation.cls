/* 
 
    Account and Contact Association on case 
    Condition 1: Account exist in Consumer DB and not in Person account 
          Value: Create a new person account and associated case with the same
    Condition 2: Account exist in both Consumer DB and in Person account
          Value: Associate case with person account
          
  Name    CreatedOn     Description
  Neha    19/03/2015    Account and contact association after case insert if Consumer db account exist
*/
public class ECICCaseConsumerDBAccConAssociation {
/*
    List<String> suplliedemail = new List<String>();
    List<String> suppliedphone = new List<String>();
    Set<Account> Accountset = new Set<Account>();
    Map<id,string> suppliedemailcase =new Map<id,string>();
    Map<id,Account> insert_account=new Map<id,Account>();
    List<case> update_case= new List<Case>();
    List<case> Final_case= new List<Case>();
    Set<id> account_id= new set<id>();
    Map<string,list<Account>> PersonAccountMap=new Map<string,list<Account>>();
    Map<string,list<Account>> CustomerDbAccountMap=new Map<string,list<Account>>();
    Case updatecase1;
    Contact ContactSearch;
    Map<id,id> mapaccid_conid=new Map<id,id>();
    

    Public  void addAccountContact(list<Case> cs){
    Map<String,String> mapRecordType = new Map<String,String>();
    List<Recordtype> lstrecordtype = [Select Id,Name from Recordtype where SobjectType = 'Account'];
     
     for(Recordtype r:lstrecordtype)
     {
         mapRecordType.put(r.Name,r.Id);
     }
     
    for(Case c: cs){
        if(c.Origin == 'Web' && c.SuppliedEmail!=null)
        {
        suplliedemail.add(c.SuppliedEmail);
        suppliedphone.add(c.SuppliedPhone);
        }
    }
    
     List<Account> Accpersonal = new List<Account>();
     List<Account> Accphpersonal = new List<Account>();
     List<Account> AccConsumerDB = new List<Account>();
     
    if(suplliedemail.size()>0)
    {
        Accpersonal=[Select Id,name,Phone,PersonEmail from Account where PersonEmail in:suplliedemail  and recordtypeId =: mapRecordType.get('Person')];
        Accphpersonal=[Select Id,name,Phone,PersonEmail from Account where Phone in:suppliedphone  and recordtypeId =: mapRecordType.get('Person')];
        AccConsumerDB=[Select Id,name,PersonEmail from Account where PersonEmail in:suplliedemail  and recordtypeId =:mapRecordType.get('Consumer DB Person')];
        Accountset.addall(Accpersonal);
        Accountset.addall(Accphpersonal);
    }
    
    for(Account pacc:Accpersonal){
    if(PersonAccountMap.containsKey(pacc.PersonEmail)) {
            List<Account> peracc = PersonAccountMap.get(pacc.PersonEmail);
            peracc.add(pacc);
            PersonAccountMap.put(pacc.PersonEmail,peracc); 
        } else {
            PersonAccountMap.put(pacc.PersonEmail,new List<Account>{pacc});
        }
          
    }
    
    for(Account DBacc:AccConsumerDB){
    if(CustomerDbAccountMap.containsKey(DBacc.PersonEmail)) {
            List<Account> DBacco = CustomerDbAccountMap.get(DBacc.PersonEmail);
            DBacco.add(DBacc);
            CustomerDbAccountMap.put(DBacc.PersonEmail,DBacco); 
        } else {
            CustomerDbAccountMap.put(DBacc.PersonEmail,new List<Account>{DBacc});
        }
            
    }
    for(Case cse:cs){
    list<Account> Listpersonalaccount=PersonAccountMap.get(cse.SuppliedEmail);
    system.debug('+++++++++++++++Listpersonalaccount++++++++++++'+Listpersonalaccount);
    list<Account> ListDBaccount=CustomerDbAccountMap.get(cse.SuppliedEmail);
    system.debug('+++++++++++++++ListDBaccount++++++++++++'+ListDBaccount);
    AccnConAssociation(Listpersonalaccount,ListDBaccount,cse);
    }
    if(insert_account.values()!=null){
    Database.SaveResult[] lsr = Database.insert(insert_account.values(),false);
        for(Database.SaveResult sr:lsr){
        if(sr.isSuccess())
        account_id.add(sr.getId());
        }
    list<Contact> personalcontact=[Select Id,AccountId from Contact where AccountId IN :account_id];
    for(Contact con:personalcontact){
    mapaccid_conid.put(con.AccountId,con.id);
    }
    for(case cas:update_case){
    id accid=insert_account.get(cas.id).id;
    cas.AccountId=accid;
    cas.ContactId = mapaccid_conid.get(accid);
    Final_case.add(cas);
    }
    update Final_case;
}
}
    public void AccnConAssociation(list<Account>Listpaccount,list<Account>ListDaccount,case c){
    Account insertacc;
    Map<String,String> mapRecordType1 = new Map<String,String>();
    List<Recordtype> lstrecordtype1 = [Select Id,Name from Recordtype where SobjectType = 'Account'];
     
     for(Recordtype r:lstrecordtype1)
     {
         mapRecordType1.put(r.Name,r.Id);
     }
    
        if((Listpaccount== null && ListDaccount!=null))
            {
                insertacc = new Account();
                updatecase1 = new Case(Id = c.Id);              
                        
                        insertacc.RecordTypeId = mapRecordType1.get('Person');
                        insertacc.LastName = c.SuppliedLastName__c;
                        insertacc.FirstName = c.SuppliedFirstName__c;
                        insertacc.Age_GB__pc = c.Supplied_Age_Range__c;
                        insertacc.Title__pc = c.Supplied_Title__c;
                        insertacc.PersonEmail = c.SuppliedEmail;
                        insertacc.PersonHomePhone = c.SuppliedPhone;
                        insertacc.Gender__pc = c.Supplied_Gender__c;
                        insertacc.Country_Code__pc = c.Country_Code__c;
                        insertacc.mailing_administrativearea__pc = c.SuppliedMailingCity__c;
                        insertacc.Mailing_Streetname1__pc = c.SuppliedMailing_Streetname1__c;
                        insertacc.Mailing_Streetname2__pc = c.SuppliedMailing_Streetname2__c;
                      
                
                insert_account.put(c.Id,insertacc);              
                update_case.add(updatecase1);
            }
            
            if((Listpaccount!=null && ListDaccount!=null && Listpaccount.size()==1))
            {                                          
                    updatecase1 = new Case(Id = c.Id);
                    updatecase1.AccountId=Listpaccount[0].Id;
                
                ContactSearch = [Select Id from Contact where AccountId =: Listpaccount[0].Id];
                updatecase1.ContactId = ContactSearch.Id;
                
                update updatecase1;
            }
      
            


    }
  */  
}