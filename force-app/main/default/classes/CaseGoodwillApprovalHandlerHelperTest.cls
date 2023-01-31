@isTest
public class CaseGoodwillApprovalHandlerHelperTest {
    
    static testMethod void testGetAllUsersHelper()
    {
    	CaseGoodwillApprovalHandlerHelper handler = new CaseGoodwillApprovalHandlerHelper();
    	
    	Map<Id, User> userList = handler.getAllUsersHelper();
    	
    	system.assertEquals(false, userList.isEmpty());
    }
}