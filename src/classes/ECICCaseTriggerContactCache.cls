public class ECICCaseTriggerContactCache 
{
	@testVisible private static Map<ID, Contact> webCaseContactByIdCache = new Map<ID, Contact>();
	public  static Map<ID, Contact> getWebCaseContactByIdMap() { return webCaseContactByIdCache; }
	
    @testVisible private static List<Contact> emailOrWebContactCache = new List<Contact>(); 
    public  static List<Contact> getEmailWebContactCache() { return emailOrWebContactCache; }
	
	public static void populate(List<Case> currentCaseList)
	{
       Set<ID> webCaseContactIdSet = new Set<ID>();
       List<Case> emailOrWebOriginCaseList = new List<Case>();
       
       // filter Web originated Cases
       for (Case currentCase : currentCaseList) 
       {
         	if ((currentCase.Origin == 'Web') && (currentCase.ContactId != null)) 
         	{
           		webCaseContactIdSet.add(currentCase.ContactId);
         	}
         	
         	if ((currentCase.Origin == 'Email' && String.isNotBlank(currentCase.SuppliedEmail)) || (currentCase.Origin == 'Web')) {
         		emailOrWebOriginCaseList.add(currentCase);
         	}
       }
       
       Map<ID, Contact>   webCaseContactByIdMap = null;
       
       // TODO: Consolidate ECICContactDao queries into single query; filter afterwards.
       if (! webCaseContactIdSet.isEmpty())  { webCaseContactByIdMap = ECICContactDao.findByIds(webCaseContactIdSet); 	}
       if (webCaseContactByIdMap != null)	 { webCaseContactByIdCache.putAll (webCaseContactByIdMap); 		 			} 
       if (! emailOrWebOriginCaseList.isEmpty()) { emailOrWebContactCache = ECICContactDao.findContactList(emailOrWebOriginCaseList); }
	}
}