@IsTest
public class CreateQueueForRetailerAccount_Test {
	
	@IsTest
	static void Test_QueueIsNotCreatedWhenAccountIsNotRetailer() {
		Account acc = new Account();
		acc.BillingCity = 'Mumbai';
		acc.Name = 'Test Account';
		insert acc;
		List<Group> queue = [select Name from Group where type = 'Queue' and Name = :acc.Name + ' ' + acc.BillingCity + ' ' + acc.Dealer_CI_Code__c];
		System.AssertEquals(queue.size(), 0);
	}
	
	@IsTest(SeeAllData=true)
	static void Test_QueueIsCreatedWhenAccountIsRetailer() {
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.RunAs(thisUser)
		{
			Account acc = new Account();
			acc.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
			acc.Name = 'Test Account';
			acc.Record_Sub_Type__c = 'Dual Brand';
			acc.BillingCity = 'Leeds';
			acc.Dealer_CI_Code__c = 'test123';
			acc.Alternative_Key__c = 'test123';
			acc.Primary_Dealer_Code__c = 'test123';
			acc.Secondary_Dealer_Code__c = 'test123';
			insert acc;
			List<Group> queue = [select Name from Group where type = 'Queue' and Name = :acc.Name + ' ' + acc.BillingCity + ' ' + acc.Dealer_CI_Code__c];
			System.Assert(queue.size() == 1);
			Group accQueue = queue[0];
			System.AssertEquals(acc.Name + ' ' + acc.BillingCity + ' ' + acc.Dealer_CI_Code__c, accQueue.Name);
		}
	}
}