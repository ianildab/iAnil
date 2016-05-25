@isTest
public class TEST_DummyInsertModeEnumHelper 
{
	public static Set<TEST_DummyInsertModeEnum> DML_CAPABLE_INSERT_MODE_SET = new Set<TEST_DummyInsertModeEnum>{ TEST_DummyInsertModeEnum.REAL, TEST_DummyInsertModeEnum.DML_LATER };
	
    public static Boolean isRealRequired (TEST_DummyInsertModeEnum insertMode)
    {
    	return DML_CAPABLE_INSERT_MODE_SET.contains(insertMode);
    } 
}