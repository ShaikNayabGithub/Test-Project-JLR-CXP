/******************************************************************************************
*  Name        : VME_WBS_Process_Test
*  
*  Company     : Marlabs
*    
*  Purpose     : Class used to test VME_WBS_Process 
* 
*  Developer   : Tejashree J
*
*  Created Date: 17/07/2019
----------------------------------------------------------------------
*/
@isTest
private class VME_WBS_Process_Test {
	public static Id p;
        public static User user;
	 @testSetup
        public static void initialize() {
                User usr = [Select id from User where Id = : UserInfo.getUserId()];
                System.RunAs(usr) {
                        
                        p = [select id from profile where name = 'Standard Sales User'].id;
                        user = new User(alias = 'test123', email = 'tester@wbsprocess.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = p, country = 'United States', IsActive = true, Market__c = 'IN', Is_Marketing_User__c = true, timezonesidkey = 'America/Los_Angeles', username = 'tester@wbsprocess.com');
                        insert user;
                        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Standard_Sales_User_permission_set_VME'];
                        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
                }
            }
    @isTest
        public static void successful_Batch_Execution(){
            		User user = [Select Id,Market__c,profileid from User where username = 'tester@wbsprocess.com' LIMIT 1];
                		System.runAs(user) {
                			VME_WBS_Process.Transaction_Wrapper result = VME_WBS_Process.callingBatch();
                			System.assertEquals(result.statusOfTransaction,'STARTED-PROCESSING','The processing is get started');
                		}
        }
        @isTest
        public static void unSuccessful_Batch_Execution(){
            			User user = [Select Id,Market__c,profileid from User where username = 'tester@wbsprocess.com' LIMIT 1];
        				user.Market__c = 'AB';
        				update user;
                		System.runAs(user) {
                			VME_WBS_Process.Transaction_Wrapper result = VME_WBS_Process.callingBatch();
                			System.assertEquals(result.statusOfTransaction,'FAIL','Batch got failed');
                		}
        }
        @isTest
        public static void invalid_Market_Test(){
				User user = [Select Id,Market__c,profileid from User where username = 'tester@wbsprocess.com' LIMIT 1];
        				user.Market__c = null;
        				update user;
                		System.runAs(user) {
                			VME_WBS_Process.Transaction_Wrapper result = VME_WBS_Process.callingBatch();
                			System.assertEquals(result.statusOfTransaction,'MARKET-UNAVAILABLE','Market is unavailable on the user level');
                		}
        }
        @isTest
        public static void admin_TestRun(){
                            VME_WBS_Process.Transaction_Wrapper result = VME_WBS_Process.callingBatch();
                            System.assertEquals(result.statusOfTransaction,'INSUFFICIENT PRIVILEGES','Permission issue');
        }
}