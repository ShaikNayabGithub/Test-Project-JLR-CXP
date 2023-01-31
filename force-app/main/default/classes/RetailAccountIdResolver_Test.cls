@isTest
public class RetailAccountIdResolver_Test {
	static testMethod void SetChildIds_DoesNotSetId_GivenEmptyAccount() {
		RetailAccountIdResolver retailAccountIdResolver = new RetailAccountIdResolver();
		Account account = BuildChildAccount();

		retailAccountIdResolver.SetChildIds(account);

		System.assertEquals(null, account.Id);
	}

	static testMethod void SetChildIds_DoesNotSetParentId_GivenEmptyAccount() {
		RetailAccountIdResolver retailAccountIdResolver = new RetailAccountIdResolver();
		Account account = BuildChildAccount();

		retailAccountIdResolver.SetChildIds(account);

		System.assertEquals(null, account.Id);
	}

	static testMethod void SetChildIds_SetsId_GivenExistingAccount() {
		RetailAccountIdResolver retailAccountIdResolver = new RetailAccountIdResolver();
		Account account = BuildChildAccount();
		insert account;
		account.Id = null;

		retailAccountIdResolver.SetChildIds(account);

		System.assertNotEquals(null, account.Id);
	}

	static testMethod void SetChildIds_SetsParentId_GivenExistingAccounts() {//functionality removed
		RetailAccountIdResolver retailAccountIdResolver = new RetailAccountIdResolver();
		Account childAccount = BuildChildAccountWithRetailer('Sales Dealer');
		Account parentAccount = BuildParentAccountWithRetailer(childAccount,'Sales Dealer');
		insert parentAccount;

		retailAccountIdResolver.SetChildIds(childAccount);

		//System.assertEquals(parentAccount.Id, childAccount.ParentId);
	}
    
    static testMethod void SetChildIds_SetsParentId_GivenWithNoParent() {//functionality removed
		RetailAccountIdResolver retailAccountIdResolver = new RetailAccountIdResolver();
		Account childAccount = BuildChildAccountWithRetailer('After Sales Dealer');
		Account parentAccount = BuildParentAccountWithRetailer(childAccount,'Main Dealer');
		insert parentAccount;

		retailAccountIdResolver.SetChildIds(childAccount);

		//System.assertEquals(parentAccount.Id, childAccount.ParentId);
	}

	private static Account BuildChildAccount()
	{
		Account account = new Account();
		account.Name = 'test';
		account.Primary_Dealer_Code__c = 'JIN10000';
		account.Secondary_Dealer_Code__c = 'JIN20000';
		return account;
	}
    
    private static Account BuildChildAccountWithRetailer(String retailerType)
	{
		Account account = new Account();
		account.Name = 'test';
		account.Primary_Dealer_Code__c = 'JIN10000';
		account.Secondary_Dealer_Code__c = 'JIN20000';
        account.Retailer_Type__c = retailerType;
		return account;
	}

	private static Account BuildParentAccount(Account child)
	{
		Account account = new Account();
		account.Name = 'test';
		account.Primary_Dealer_Code__c = child.Secondary_Dealer_Code__c.right(7);
		return account;
	}
    private static Account BuildParentAccountWithRetailer(Account child,String retailerType)
	{
		Account account = new Account();
		account.Name = 'test';
        account.Retailer_Type__c = retailerType;
		account.Primary_Dealer_Code__c = 'JIN10000';
		return account;
	}
}