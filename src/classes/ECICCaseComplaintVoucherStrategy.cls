public class ECICCaseComplaintVoucherStrategy extends ECICCaseProcessingStrategyAbstract {

    public override boolean OnBeforeInsert(List<sObject> newValues) 
    {
        Case[] complaintCases = filterAllComplaintCases((List<Case>)newValues);
        execute(null, complaintCases);
        return true;
    }

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) 
    {
        Case[] complaintCases = filterAllComplaintCases((List<Case>)newValuesMap.values());
        execute((Map<ID, Case>)oldValuesMap, complaintCases);
        return true;
    }
    
    @testVisible private void execute(Map<ID, Case> oldCasesMap, Case[] casesList) 
    {
        for (Case newCase : casesList) {
            Case oldCase = oldCasesMap != null ? oldCasesMap.get(newCase.id) : null;
            
            if (oldCase == null
                || oldCase.No_of_Packs__c != newCase.No_of_Packs__c
                || oldCase.Product_Unit_Price__c != newCase.Product_Unit_Price__c) {

                setVaucherValue(newCase);
                setNumberOfVouchers(newCase);
            }
        }
    }
    
    @testVisible private void setVaucherValue(Case currentCase) 
    {
        if (currentCase.No_of_Packs__c == null || currentCase.Product_Unit_Price__c == null) 
        {
            currentCase.Value_of_Vouchers__c = null;
            return;
        }
        
        Country_Specific_Settings__c countrySpecificSettings = Country_Specific_Settings__c.getValues(currentCase.Country_code__c);
        Decimal                      countrySpecificBonus    =      (countrySpecificSettings != null)  ? countrySpecificSettings.bonus__c : null;
        Decimal                      bonusMultiplier         = 1 + ((countrySpecificBonus    != null)  ? countrySpecificBonus/100         : 0);

        currentCase.Value_of_Vouchers__c = Math.ceil(currentCase.Product_Unit_Price__c * currentCase.No_of_Packs__c * bonusMultiplier);    
    }
    
    @testVisible private void setNumberOfVouchers(Case currentCase) {
        if (currentCase.Value_of_Vouchers__c != null) {
            currentCase.No_2Euro_vouchers__c = math.floor(currentCase.Value_of_Vouchers__c/2);
            currentCase.No_1Euro_vouchers__c = math.mod(Integer.valueof(currentCase.Value_of_Vouchers__c), 2);
        }
    }
}