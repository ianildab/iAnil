/*This class is used for calling BU spesific SMS helper class and this class has been called in Case trigger
*/
public class ECICCommonSMSHelper{

    private static Map<Id,RecordType> RECORD_TYPES_BY_ID_MAP = SEPRecordTypesCache.GetRecordTypesByIdMap(Case.SObjectType);

    public static void callSMSHelper(List<Case> newCaseList, List<Case> oldCaseList){
    
        List<Case> lstSABUCase = new List<Case>();
        integer i = 0;
        
        
        for(Case objCase : newCaseList)
        {
            RecordType objRecord = RECORD_TYPES_BY_ID_MAP.get(objCase.RecordTypeId);
            
            If(objRecord.DeveloperName.containsIgnoreCase('SABU'))
            {                        
                If((objCase.Status <> ECICCommonConstants.STATUS_NEW && objCase.Status <> ECICCommonConstants.STATUS_CANCELLED 
                && objCase.Status <> ECICCommonConstants.STATUS_CLOSED) && (oldCaseList == null || (oldCaseList != null && oldCaseList.get(i).Status == ECICCommonConstants.STATUS_NEW)))
                    lstSABUCase.add(objCase);
            }
            i++;
        }
        
        If(lstSABUCase != null && lstSABUCase.size() > 0)
        {
            SABU_SMS_Helper objSMSHelper = new SABU_SMS_Helper();
            objSMSHelper.sendSABUsmsList(lstSABUCase);
        }
    
    }
    


}