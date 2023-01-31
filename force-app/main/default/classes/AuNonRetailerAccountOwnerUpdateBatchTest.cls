@isTest(seeAllData=false)
public class AuNonRetailerAccountOwnerUpdateBatchTest {
	@testSetup static void setup() {
		Account personAccount = TestClass_AccountCreator.createPersonAccount_Australia(); //TestClass_AccountCreator saves Account
    }
    static testmethod void testBusinessAccounts(){
        Test.startTest();
        database.executeBatch(new AuNonRetailerAccountOwnerUpdateBatch('select id, OwnerId from Account','0051o00000DJPS4'));
        Test.stopTest();
    }
}