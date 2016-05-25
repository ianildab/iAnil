/*
 * "Complaint" is a bit misleading now as also Inquiry Cases are covered.
 */
public class ECICCaseComplaintEscalationStrategy extends ECICCaseProcessingStrategyAbstract 
{
    private static final Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);
    
    public override boolean OnBeforeInsert(List<sObject> newValues) {
        execute((List<Case>)newValues,null);
        return true;
    }

    public override boolean OnBeforeUpdate(Map<ID, sObject> oldValuesMap, Map<ID, sObject> newValuesMap) {
        execute((List<Case>)newValuesMap.values(),(Map<ID, Case>)oldValuesMap);
        return true;
    }

    @testVisible private void execute(Case[] casesList, Map<ID, Case> oldValuesMap) {
        for (Case currentCase : casesList)  
        {
            Case oldCase = (oldValuesMap!=null) ? oldValuesMap.get(currentCase.ID) : null;
            
           // Boolean isInquiryOrComplaint = currentCase.RecordTypeID == ECICCaseHelper.INQUIRY_RECORD_TYPE_ID
           //                             || currentCase.RecordTypeID == ECICCaseHelper.NON_QUALITY_COMPLAINT_RECORD_TYPE_ID
           //                             || ECICCaseQualityComplaintRecordTypeHelper.isQualityComplaint(currentCase.RecordTypeID);
            //#RecordType          
            //Updated by Balmukund, checking if Case is of Quality or Non Quality Complaint by matching developer names.     
            String developerName = RECORD_TYPES_BY_ID_MAP.get(currentCase.RecordTypeID).DeveloperName;
             
            Boolean isInquiryOrComplaint = developerName.StartsWith(ECICCommonConstants.INQUIRY_DEVNAME)
                                        || developerName.StartsWith(ECICCommonConstants.NONQUALITY_COMPLAINT_DEVNAME)
                                        || ECICCaseQualityComplaintRecordTypeHelper.isQualityComplaint(currentCase.RecordTypeID);
          
                
            Boolean isNewRisk = (currentCase.Potential_Risk__c != null
                && currentCase.Potential_Risk__c != 'No Risk'
                && currentCase.Potential_Risk__c != 'No' //Change for Nwen CCE to stop changing status to escalated if potential risk is marked as no
                && currentCase.Risk_Type__c != '3rd Complaint')
                || currentCase.IMCR_issue__c == true;
            
            if (isInquiryOrComplaint 
                && isNewRisk
                && currentCase.Status == ECICCommonConstants.STATUS_OPEN)
            {
                if (oldCase != null && oldCase.Status == ECICCommonConstants.STATUS_ESCALATED)
                {
                    currentCase.addError(Label.PreventComplaintStatusEscalationChange);
                }
                else
                {
                    currentCase.Status = ECICCommonConstants.STATUS_ESCALATED;
                }
            }
            
            if(oldCase!=null)
            {
                 if(oldCase.Status == ECICCommonConstants.STATUS_ESCALATED && currentCase.IMCR_issue__c == false && currentCase.Potential_Risk__c == 'No' && developerName == ECICCommonConstants.NWEN_QUALITY_COMPLAINT_DEVNAME)
                    {
                        currentCase.Status = ECICCommonConstants.STATUS_OPEN;
                    }
            
            }
        }
    }
}