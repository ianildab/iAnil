public /* with sharing */ class ECICGroupDao {
	
	public static Group findQueueByDeveloperName(String name) {
		return getFirstResult([SELECT id FROM Group WHERE type = 'Queue' AND developerName = :name]);
	}
	
	private static Group getFirstResult(Group[] resultList) {
		return (! resultList.isEmpty()) ? resultList.get(0) : null;
	}
}