public class ECICCaseAccountWorkstream 
{
    public enum WorkstreamEnum { CIC, CRM, STM }

    public static Map<WorkstreamEnum, Contact[]> findWorkstreamContacts (String email, String phone, Contact[] contactArray)
    {
        Map<WorkstreamEnum, Contact[]> resultWorkstreamMap = new Map<WorkstreamEnum, Contact[]>();
        
        for (Contact contact : contactArray) 
        {
        	String ownerProfileName =  (!Test.isRunningTest() || (contact.owner.profile.name != null))
        	                               ? contact.owner.profile.name
        	                               : ((contact.id != null) ? TEST_MockHelper.getMockString(contact.id, 'owner.profile.name') : null);
            
            WorkstreamEnum workstream = selectWorkstreamEnum (ownerProfileName);
            if ( (workstream != null) && (hasContactDetails(contact, email, phone))) 
            {
               	mapContact(resultWorkstreamMap, workstream, contact);
            }
        }
        
        return resultWorkstreamMap;
    }
    

   /**
    * Personal Accounts also (presently, dubiously) has a field Facebook_ID__c but we can't check it from here without first radical refactoring,
    * but it would be better to [re]move the misplaced and redunctant field, which may be handled by CRM-360.
    **/
    @testVisible private static Boolean hasContactDetails (Contact contact, String email, String phone)
    {
    	return (
                           ( hasContactDetail (contact.Email,       email) )
                        || ( hasContactDetail (contact.Phone,       phone) )
                        || ( hasContactDetail (contact.MobilePhone, phone) )
                        || ( hasContactDetail (contact.HomePhone,   phone) )
                        || ( hasContactDetail (contact.OtherPhone,  phone) )
                );
    }
        
    @testVisible private static Boolean hasContactDetail (String fieldValue, String detailValue)
    {
        return ((fieldValue == detailValue) && String.isNotEmpty(detailValue));
    }
    
    @testVisible private static void mapContact(Map<WorkstreamEnum, Contact[]> contactListByWorkstreamMap, WorkstreamEnum workstream, Contact contact)
    {
    	if (!contactListByWorkstreamMap.containsKey(workstream))
    	{
    		contactListByWorkstreamMap.put(workstream, new List<Contact>());
    	}
        contactListByWorkstreamMap.get(workstream).add(contact);
    }
    
    @testVisible private static WorkstreamEnum selectWorkstreamEnum (String ownerProfileName)
    {
    	if (ownerProfileName == null) { return null; }
    	
        WorkstreamEnum workstream = null;

        if      (ownerProfileName.startsWith('CRM'))           { return WorkstreamEnum.CRM; }
        else if (ownerProfileName.startsWith('STM'))           { return WorkstreamEnum.STM; }
        else if (ownerProfileName.startsWith('ECIC'))          { return WorkstreamEnum.CIC; }

        // Potential FIX FOR IGNORED "System Administrator" profile:
        // else if (ownerProfileName == ECICCommonConstants.PROFILE_SYSTEM_ADMIN) { return WorkstreamEnum.CIC; }

    	return workstream;
    }
    
    public static Contact getWorkstreamContact (Map<WorkstreamEnum, Contact[]> WorkstreamEnumContactMap)
    {
        Contact nonCICContact = null;
        
        if (WorkstreamEnumContactMap.containsKey(WorkstreamEnum.CRM) && ! WorkstreamEnumContactMap.get(WorkstreamEnum.CRM).isEmpty()) 
        {
            nonCICContact = WorkstreamEnumContactMap.get(WorkstreamEnum.CRM).get(0);       
        } 
        else if (WorkstreamEnumContactMap.containsKey(WorkstreamEnum.STM) && ! WorkstreamEnumContactMap.get(WorkstreamEnum.STM).isEmpty()) 
        {
            nonCICContact = WorkstreamEnumContactMap.get(WorkstreamEnum.STM).get(0);
        }

        return nonCICContact;
    }
}