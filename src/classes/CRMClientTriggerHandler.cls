// CRMClientTriggerHandler handles the Client insertion.
// There is a need to create the lookup manually from the Client to
// the property representation via the client id field on the
// property representation object
public /* with sharing */ class CRMClientTriggerHandler extends SEPTriggerHandlerAbstract {
    
    //It is a property to save some unnecessary SOQL calls
    private Map <Id,Account> mapIdToAccount{get;set;}
    
    //This is for checking easily if a field with an exact name exists or not
    private Set<String> setAccFieldNames{get;set;}
    
    // Collects all the property representation for the selected client ids (Property__c.Property_Representation_Client_ID__c)
    private Map<String, Property__c> mapPropRepCIDToProperty {get;set;}
    
    //Relevant clients
    private List<Client__c> valuesToProccess {get;set;}
        
    public CRMClientTriggerHandler(boolean isTriggerExecuting) {
        super(isTriggerExecuting);
    }

    // The property representation lookups will be filled up based on the client id field
    public override void OnBeforeInsert(List<sObject> newValues) {
        createAccountMap((List<Client__c>)newValues);
        updatePropertyRepresentationLookup((List<Client__c>)newValues);
        updateContactLookup((List<Client__c>)newValues);
    }
    
    public override void OnAfterInsert(List<sObject> newValues, Map<ID, sObject> newValuesMap) {
        createAccountMap((List<Client__c>)newValues);
        updateRelatedAccounts((List<Client__c>)newValues);      
    }

    public override void OnAfterUpdate(List<sObject> oldValues, List<sObject> newValues, Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        createAccountMap((List<Client__c>)newValues);
        updateRelatedAccounts((List<Client__c>)newValues);      
    }
    
    private void retrievePropertyRepresentationLookup(List<Client__c> newValues){
        // Filter all the values which contains valid non empty client ids and
        // mark records with error in which the client id is null or empty.
        // AND
        // If the client id is valid it keeps it for further usage
        valuesToProccess = new List<Client__c>();
        Set<String> clientIds = new Set<String>();
        for(Client__c c : newValues) {
            String clientId = c.clientId__c;
            if(clientId == null) {
                c.addError('Client ID was null');
            } else if(clientId == '') {
                c.addError('Client ID was empty string');
            } else {
                valuesToProccess.add(c);
                clientIds.add(clientId);
            }
        }
        mapPropRepCIDToProperty =  CRMPropertyDao.findByClientIds(clientIds);
    }
    
    
    // Sets all the property representation lookups in the given client
    // records, based on the values of the clientId field, which should contain
    // non-emtpy values which refer a property representation record
    // through the property representation client id field
    private void updatePropertyRepresentationLookup(List<Client__c> newValues) {
        
        retrievePropertyRepresentationLookup(newValues);
        
        // Sets all the Property_Representation__c lookups with the salesforce Ids
        // if the salesforce id is found, otherwise mark the record with an error
        for(Client__c c : valuesToProccess) {
            String clientId = c.clientId__c;
            system.debug('mapPropRepCIDToProperty:'+mapPropRepCIDToProperty);
            system.debug('clientId');
            if(mapPropRepCIDToProperty!=null && mapPropRepCIDToProperty.containsKey(clientId)) {
                c.Property_Representation__c = mapPropRepCIDToProperty.get(clientId).Id;
            } else {
                // ERROR PATH: This id should be found within the property representation records
                c.addError('There is no property representation in the system for the cleint id: ' + clientId);
            }
        }
        
    }
    
    //Inserting proper Ids to Contact__c fields
    private void updateContactLookup(List<Client__c> newValues) {
        
        for(Client__c loopClient : newValues){
            if(mapIdToAccount.containsKey(loopClient.Account__c)){
                loopClient.Contact__c = mapIdToAccount.get(loopClient.Account__c).PersonContactId;
            }       
            else{
                loopClient.addError('There is no Account attached for the Client(Id:'+loopClient.Id+')');
            }
        }
    }
    
    private void updateRelatedAccounts(List<Client__c> newValues){
        //Should be first to fill mapPropRepCIDToProperty with values
        retrievePropertyRepresentationLookup(newValues);
        updateAccountFirstLoginField(newValues);
        update mapIdToAccount.values();
    }
    
    
   private void updateAccountFirstLoginField(List<Client__c> newValues){
         
       Date today = Date.today();
       Date yesterday = Date.today().addDays(-1);
       Date tomorrow = Date.today().addDays(+1);
       
       for(Client__c loopClient :  newValues) {
            String ClientID = loopClient.ClientId__c;
            //To determine if the ClientID is filled
            Boolean isFilled = (ClientID != null && ClientID != '');
            
            if(isFilled && loopClient.firstLogin__c!=null) {
                Account myAccount = mapIdToAccount.get(loopClient.Account__c);
                 
                //Determine whether it was the first login to the paricular property representation
                Boolean notContained = (myAccount.visitedProperties__c == null || !myAccount.visitedProperties__c.contains(mapPropRepCIDToProperty.get(ClientID).Parent__c));
                
                //Determine if the client actually registered to the property representation
                //Boolean areDatesEqual = (loopClient.lastLogin__c == loopClient.firstLogin__c);                
                    
                if(notContained /*&& areDatesEqual*/ ){
                    
                    //If true we will put the incoming property ID to the firstLoginTo_1__c otherwise to the firstLoginTo_2__c
                    Boolean case1 =  myAccount.welcomeEmailDate_2__c!=today && myAccount.welcomeEmailDate_1__c!=yesterday;
                    
                    Id parentId = mapPropRepCIDToProperty.get(ClientID).Parent__c;
                    
                    Boolean canBeAddedToTheField2 = 
                        (
                            myAccount.welcomeEmailDate_2__c!=yesterday
                            &&
                            myAccount.welcomeEmailDate_2__c!=tomorrow
                         )
                        || 
                        (
                            myAccount.welcomeEmailDate_2__c==tomorrow 
                            && 
                            (
                                myAccount.firstLoginTo_2__c==null 
                                || 
                                myAccount.firstLoginTo_2__c.length()<=236
                            )
                        );
                    
                    Boolean canBeAddedToTheField1 =
                        (
                            myAccount.welcomeEmailDate_1__c!=yesterday
                            &&
                            myAccount.welcomeEmailDate_1__c!=tomorrow
                        ) 
                        || 
                        (
                            myAccount.welcomeEmailDate_1__c==tomorrow 
                            && 
                            (
                                myAccount.firstLoginTo_1__c==null 
                                || 
                                myAccount.firstLoginTo_1__c.length()<=236
                            )
                        );
                        
                    if(case1){
                        // If the id cannot be added anywhere
                        if(myAccount.firstLoginTo_1__c!=null && myAccount.firstLoginTo_1__c.length()>=237 && !canBeAddedToTheField2){
                            //We could throw an error here if asked later.
                            //loopClient.addError('The id of visited property: '+parentId+'could not been added to the list bacause there are too many properties for today.');
                            
                        }
                        // If the id just can added to the tomorrow list
                        else if (myAccount.firstLoginTo_1__c!=null && myAccount.firstLoginTo_1__c.length()>=237 && canBeAddedToTheField2){
                            if(myAccount.welcomeEmailDate_2__c==null || myAccount.welcomeEmailDate_2__c!=tomorrow){
                                myAccount.firstLoginTo_2__c='';
                                myAccount.welcomeEmailDate_2__c=tomorrow;
                            }
                            
                            //Inserting comma if needed to firstLoginTo__c field
                            if(myAccount.firstLoginTo_2__c==null){
                                myAccount.firstLoginTo_2__c='';
                            }
                            else if(myAccount.firstLoginTo_2__c!=''){
                                myAccount.firstLoginTo_2__c += ',';
                            }
                            
                            //Inserting the new id at the end
                            myAccount.firstLoginTo_2__c += parentId;
                        }
                        //The id can be added normally
                        else{                        
                            if(myAccount.welcomeEmailDate_1__c==null || myAccount.welcomeEmailDate_1__c!=today){
                                myAccount.firstLoginTo_1__c='';
                                myAccount.welcomeEmailDate_1__c=today;
                            }
                            
                            //Inserting comma if needed to firstLoginTo__c field
                            if(myAccount.firstLoginTo_1__c==null){
                                myAccount.firstLoginTo_1__c='';
                            }
                            else if(myAccount.firstLoginTo_1__c!=''){
                                myAccount.firstLoginTo_1__c += ',';
                            }                        
                            //Inserting the new id at the end
                            myAccount.firstLoginTo_1__c += parentId;
                        }
                    }
                    else{
                         // If the id cannot be added anywhere
                        if(myAccount.firstLoginTo_2__c!=null && myAccount.firstLoginTo_2__c.length()>=237 && !canBeAddedToTheField1){
                            //We could throw an error here if asked later.
                            //loopClient.addError('The id of visited property: '+parentId+'could not been added to the list bacause there are too many properties for today.');                            
                        }
                        // If the id just can added to the tomorrow list
                        else if(myAccount.firstLoginTo_2__c!=null && myAccount.firstLoginTo_2__c.length()>=237 && canBeAddedToTheField1){
                            
                            if(myAccount.welcomeEmailDate_1__c==null || myAccount.welcomeEmailDate_1__c!=tomorrow){
                                myAccount.firstLoginTo_1__c='';
                                myAccount.welcomeEmailDate_1__c=tomorrow;
                            }
                            
                            //Inserting comma if needed to firstLoginTo__c field
                            if(myAccount.firstLoginTo_1__c==null){
                                myAccount.firstLoginTo_1__c='';
                            }
                            else if(myAccount.firstLoginTo_1__c!=''){
                                myAccount.firstLoginTo_1__c += ',';
                            }                        
                            //Inserting the new id at the end
                            myAccount.firstLoginTo_1__c += parentId;
                        }
                        //The id can be added normally
                        else{ 
                            if(myAccount.welcomeEmailDate_2__c==null || myAccount.welcomeEmailDate_2__c!=today){
                                myAccount.firstLoginTo_2__c='';
                                myAccount.welcomeEmailDate_2__c=today;
                            }
                            
                            //Inserting comma if needed to firstLoginTo__c field
                            if(myAccount.firstLoginTo_2__c==null){
                                myAccount.firstLoginTo_2__c='';
                            }
                            else if(myAccount.firstLoginTo_2__c!=''){
                                myAccount.firstLoginTo_2__c += ',';
                            }
                            
                            //Inserting the new id at the end
                            myAccount.firstLoginTo_2__c += parentId;
                        }
                    }
                    
                    //Inserting comma if needed to visitedProperties__c field 
                    if(myAccount.visitedProperties__c==null){
                        myAccount.visitedProperties__c='';
                    }
                    else if(myAccount.visitedProperties__c!=''){
                        myAccount.visitedProperties__c += ',';
                    }
                    myAccount.visitedProperties__c += mapPropRepCIDToProperty.get(ClientID).Parent__c;
                }
            }
        }
    }
    
    
    private void createAccountMap(List<Client__c> newValues){
        if(mapIdToAccount==null){
            setAccFieldNames = new Set<String>();
            //Collecting accountIds to a set of Ids
            Set<Id> accountIds = new Set<Id>();
            for(Client__c loopClient:newValues){
                accountIds.add(loopClient.Account__c);
            }           
            
            Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Account.fields.getMap();
            List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
            String theQuery = 'SELECT ';
            for(Schema.SObjectField s : fldObjMapValues)
            {              
               String fieldName = s.getDescribe().getName();
               setAccFieldNames.add(fieldName);
               // Continue building your dynamic query string
               theQuery += fieldName + ',';
            }

            // Triming the last comma
            theQuery = theQuery.subString(0, theQuery.length() - 1);

            // Finalize query string
            theQuery += ' FROM Account WHERE Id IN :accountIds';
            
            system.debug('Dynamic Query: '+theQuery);
            
            // Making the dynamix call
            if(Test.isRunningTest()){
                 createAccountMapForTest(accountIds);
            }else{
                mapIdToAccount = new Map<Id, Account>((List<Account>)Database.query(theQuery));
            }
        }
    }
    
    private Map<Id, Account> createAccountMapForTest(Set<id> accountIds){
        mapIdToAccount = new Map<Id, Account>();
        
                List<Account> listAccount = [SELECT
                LastName,
                Salutation,
                FirstName,
                PersonBirthdate,
                PersonEmail,
                PersonHasOptedOutOfEmail,
                BillingStreet,
                ShippingStreet,
                PersonMailingStreet,
                PersonOtherStreet,
                Country_Code__pc,
                Fax,
                Phone,
                PersonHomePhone,
                PersonMobilePhone,
                PersonOtherPhone,
                Screen_Name__pc,
                //sf4twitter__Fcbk_User_Id__pc,
                //sf4twitter__Twitter_User_Id__pc,
                Identity_Card_Number__pc,
                Website,
                firstLoginToYesterday__c,
                firstLoginTo_1__c,
                firstLoginTo_2__c,
                welcomeEmailDate_1__c,
                welcomeEmailDate_2__c,
                PersonContactId,
                visitedProperties__c 
            FROM
                Account
            WHERE
                Id IN :accountIds
            ];
            
            for(Account acc : listAccount){
                mapIdToAccount.put( acc.id, acc);
            }
            return mapIdToAccount;
    }
    
}