/**
 *  ECIC-414 - If PoS is filled and changed and RoP is not, trigger should find the region for the chosen PoS account,
 *  and update RoP.
 */
public class ECICCaseQComplaintPOSSetterStrategy extends ECICCaseProcessingStrategyAbstract 
{
	@testVisible private Map<Id, Account> regionAccountByIdMap = ECICCaseTriggerAccountCache.getRegionAccountByIdMap();

    public override boolean OnBeforeInsert(List<sObject> newValues) {
    	Case[] qualityComplaintCases = filterQualityComplaintCases((List<Case>)newValues);
        execute(null, qualityComplaintCases);
        
        return true;
    }

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        Case[] qualityComplaintCases = filterQualityComplaintCases((List<Case>)newValuesMap.values());
        execute((Map<ID, Case>)oldValuesMap, qualityComplaintCases);
        
        return true;
    }

    @testVisible private void execute(Map<ID, Case> oldCasesMap, Case[] newQualityComplaintCasesList) 
    {    	 
        for (Case newCase : newQualityComplaintCasesList) 
        {
        	Case oldCase = (oldCasesMap != null) ? (oldCasesMap.get(newCase.id)) : (null);
            setPOSData(newCase, oldCase);
        }
        }
    
    @testVisible private void setPOSData(Case newCase, case oldCase) 
    {
        if (hasNewPointOfSaleData(newCase, oldCase))
        { 
	        if (newCase.Point_of_Sale__c   != null)  
	        { 
	        	updatePointOfSaleData    (newCase, regionAccountByIdMap.get(newCase.Point_of_Sale__c));   
	        }
	        
	        if (newCase.PoS_Key_Account__c != null)  
	        { 
	        	Account newRegionAccount =  getRegionAccount(newCase);
	        	Account oldRegionAccount =  getRegionAccount(oldCase);
	        	updatePointOfSaleKeyData (newCase, oldCase, newRegionAccount,  oldRegionAccount); 
	        }
        }
    }
    
    @testVisible private Account getRegionAccount(Case currentCase)
    {
		return (
					   (currentCase 				   != null)
					&& (currentCase.PoS_Key_Account__c != null) 
					&& (regionAccountByIdMap.containsKey(currentCase.PoS_Key_Account__c))
				) 
					? regionAccountByIdMap.get(currentCase.PoS_Key_Account__c) 
					: null;    	
    }
    
    @testVisible private Boolean hasNewPointOfSaleData(Case newCase, Case oldCase)
    {
    	return (
						( oldCase                       == null						    ) 
                    ||  ( newCase.PoS_Key_Account__c    == null                         )
					||  ( newCase.PoS_Key_Account__c 	!= oldCase.PoS_Key_Account__c 	)
					||  ( newCase.Point_of_Sale__c   	!= oldCase.Point_of_Sale__c 	)
					||  ( newCase.Place_of_Purchase__c 	!= oldCase.Place_of_Purchase__c )
				 );	
    }
    
    @testVisible private void updatePointOfSaleData (Case newCase, Account account)
    {
        if( account != null )
        {
            newCase.Region_of_Purchase__c = account.Region__c;
            newCase.PoS_Key_Account__c 	  = account.ParentID;
            newCase.PoS_Key_Account__r 	  = account.Parent;
        }
            }
    
    @testVisible private void updatePointOfSaleKeyData (Case newCase, Case oldCase, Account newAccount, Account oldAccount)
    {
        if( newAccount != null )
        {
            if (newCase.PoS_Key_Account__r == null) { newCase.PoS_Key_Account__r = newAccount; }
            
            String newPosKeyAccountName = newCase.PoS_Key_Account__r.name;
            
            newCase.Place_of_Purchase__c = (String.isNotEmpty(newCase.Place_of_Purchase__c))
            								? resetPlaceOfPurchase(newCase, oldCase, newPosKeyAccountName, (oldAccount != null) ? oldAccount.name : null)
            								: newPosKeyAccountName;
        }
    }
    
    @testVisible private String resetPlaceOfPurchase(Case newCase, Case oldCase, String newPosKeyAccountName, String oldPosKeyAccountName)
    {
    	// Should not replace if old value had a value NOT containing the oldPOSKeyAccountName.
    	return (requiresPosKeyAccountNameUpdate (newCase, oldCase, oldPosKeyAccountName))
					?   (
							(newCase.Place_of_Purchase__c.contains(oldPosKeyAccountName ))
							? ( newCase.Place_of_Purchase__c.replaceFirst(oldPosKeyAccountName, newPosKeyAccountName)) 
							: ( newCase.Place_of_Purchase__c														 )		// Keeps OLD value.
						)
					: (newPosKeyAccountName  + ' ' + newCase.Place_of_Purchase__c);
    }
    
    @testVisible private Boolean requiresPosKeyAccountNameUpdate (Case newCase, Case oldCase, String oldPosKeyAccountName)
    {
    	return (                                                                       // FALSE if
                     (oldPosKeyAccountName          != null                       )    //    1. Has no old account name
        		  && ( (oldCase != null) && (oldCase.PoS_Key_Account__c != null)  )    //    2. Has no old account
        		  && (newCase.PoS_Key_Account__c   	!= null						  )    //    3. Has no new account
        		  && (newCase.PoS_Key_Account__c 	!= oldCase.PoS_Key_Account__c )    //    4. Account has not changed.
        	);
    }
    
}