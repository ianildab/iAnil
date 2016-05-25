public with sharing class ECICCaseController 
{
    private static String QUERY_CASE = 'SELECT casenumber, CreatedDate, Production_Code__c, Subject, '
                                           + ' Product__r.name, Product__r.Product_Description__c, Bottler__r.Name, Plant__r.Name, Product__r.Packaging__c, Product__r.Package_Type__c, ' 
                                           + ' Product__r.Size__c, Bbe_date__c, Account.Name, Point_Of_Sale__r.Name, Place_of_Purchase__c, Region_of_Purchase__r.Name '
                                       + ' FROM Case';

    public String cntrCode {get;set;}
    public String langCode {get;set;}
    public sObject obj {get;set;}
    public Boolean includeClosedCases {get;set;}

    private String[]    cntrCodes;

    public  List<Case>  cases 
    {
        get 
        {  
            if (cases != null) { return cases; }
                  
            String query = QUERY_CASE ;
            if      (obj instanceOf Trend__c)        
            { 
                if (includeClosedCases == null) { includeClosedCases = false; }
                query += ' WHERE ' + ((includeClosedCases) ? ' status != \'Closed\' AND ' : '' ) + ' trend__c = \'' + obj.id + '\''; 
            }
            else if (obj instanceOf Closed_Trend__c) { query += ' WHERE id IN (SELECT case__c FROM closed_trend_case__c WHERE closed_trend__c = \'' + obj.id + '\' )'; }
            else if (obj instanceOf Open_Alert__c)   
            {
                List<String> fields = new List<String>();
                for (Schema.FieldSetMember m : ECICCommonConstants.OPEN_ALERT_CASE_FIELDS) { fields.add(m.fieldPath); }
                
                query = 'select CaseNumber, Plant__r.name, Product__r.name, CCE_Product__r.name, Region_of_Purchase__r.name, Closure_Supplier__r.name, Package_Supplier__r.name, ' 
                        + ' Beverage__r.Name, Promotion__r.Name, Outsourcing_Company__r.Name, Point_Of_Sale__r.Name, PoS_Key_Account__r.Name, Production_Line__r.Name, '
                        + ' Owner_lookup__r.name, '
                        + String.join(fields, ECICCommonConstants.COMMA_DEL)
                        + ' from case where id in (select case__c from open_alert_case__c where open_alert__c = \'' + obj.id + '\' )';
            }
            
            cases = database.query(query);
            return cases;
        }
        set;
    }


    public ECICCaseController () {}
    
    public String[] getLangCodes() 
    {
        if (String.isNotEmpty(langCode)) { return langCode.split(ECICCommonConstants.SEMICOLON); }
        
        Set<String> langCodeSet = new Set<String>();
        for (String code : cntrCode.split(ECICCommonConstants.SEMICOLON)) 
        {
            Country_Specific_Settings__c countrySpecificSetting = Country_Specific_Settings__c.getValues(code);
            if (countrySpecificSetting != null) 
            {
                String offlangs = countrySpecificSetting.Official_Languages__c;
                if (!ECICUtils.isEmpty(offlangs)) { langCodeSet.addAll(offlangs.split(';')); }
            }
        }

        String [] codeArray = new String[]{};
                  codeArray.addAll(langCodeSet);
           return codeArray;
                }
            }