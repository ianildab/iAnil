public class ECICEmailMessageDao {
	
	public static EmailMessage[] findByParentIds(Set<ID> parentIds) {
		return [SELECT id, subject FROM EmailMessage WHERE parentId IN :parentIds];
		
	}
}