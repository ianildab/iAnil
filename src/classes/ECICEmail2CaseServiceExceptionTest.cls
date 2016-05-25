@isTest
private class ECICEmail2CaseServiceExceptionTest {
    private static testMethod void exceptionTest() {
        Boolean exceptionCaught = false;
        ECICEmail2CaseServiceException testException = new ECICEmail2CaseServiceException();
        
        try { throw testException; }
        catch (ECICEmail2CaseServiceException e) { exceptionCaught = true; }
        
        System.assert(exceptionCaught);
        System.assertEquals('test', testException.testStr);
    }
}